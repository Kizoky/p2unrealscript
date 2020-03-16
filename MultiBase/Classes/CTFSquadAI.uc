class CTFSquadAI extends SquadAI;

var float LastSeeFlagCarrier;
var CTFFlag FriendlyFlag, EnemyFlag; 

/* GoPickupFlag()
have bot go pickup dropped friendly flag
*/
function bool GoPickupFlag(Bot B)
{
	if ( FindPathToObjective(B,FriendlyFlag) )
	{
		if ( Level.TimeSeconds - CTFTeamAI(Team.AI).LastGotFlag > 6 )
		{	
			CTFTeamAI(Team.AI).LastGotFlag = Level.TimeSeconds;
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('GOTOURFLAG'), 20, 'TEAM');
		}
		B.GoalString = "Pickup friendly flag";
		return true;
	}
	return false;
}

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float result;

	result = Super.AssessThreat(B,NewThreat,bThreatVisible);

	if ( NewThreat == FriendlyFlag.Holder )
		result += 1.5;

	return result;
}

function actor FormationCenter()
{
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		return SquadObjective;
	if ( (EnemyFlag.Holder != None) && (GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController') )
		return EnemyFlag.Holder;
	return SquadLeader.Pawn;
}

/* OrdersForFlagCarrier()
Tell bot what to do if he's carrying the flag
*/	
function bool OrdersForFlagCarrier(Bot B)
{
	// pickup dropped flag if see it nearby
	// FIXME - don't use pure distance - also check distance returned from pathfinding
	if ( !FriendlyFlag.bHome && (FriendlyFlag.Holder == None) && B.LineOfSightTo(FriendlyFlag.Position())  
			&& (VSize(B.Pawn.Location - FriendlyFlag.Location) < 1500.f) 
			&& GoPickupFlag(B) )
		return true;

	if ( (B.Enemy != None) && (B.Pawn.Health < 60 ))
		B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDBACKUP'), 25, 'TEAM');
	B.GoalString = "Return to Base with enemy flag!";
	if ( !FindPathToObjective(B,FriendlyFlag.HomeBase) )
	{
		B.GoalString = "No path to home base for flag carrier";
		// FIXME - suicide after a while
		return false;
	}
	if ( B.MoveTarget == FriendlyFlag.HomeBase )
	{
		B.GoalString = "Near my Base with enemy flag!";
		if ( !FriendlyFlag.bHome )
		{
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('NEEDOURFLAG'), 25, 'TEAM');
			B.GoalString = "NEED OUR FLAG BACK!";
			return false;
		}
		if ( VSize(B.Pawn.Location - FriendlyFlag.Location) < FriendlyFlag.HomeBase.CollisionRadius )
			FriendlyFlag.Touch(B.Pawn);
	}
	return true;
}

function bool MustKeepEnemy(Pawn E)
{
	if ( (E == FriendlyFlag.Holder) && (E != None) && (E.Health > 0) )
		return true;
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	local bool bSeeFlag;
	local actor FlagCarrierTarget;
	local controller FlagCarrier;

	if ( EnemyFlag.Holder == B.Pawn )
		return OrdersForFlagCarrier(B);

	if ( !FriendlyFlag.bHome  )
	{
		bSeeFlag = B.LineOfSightTo(FriendlyFlag.Position());

		if ( bSeeFlag )
		{
			if ( FriendlyFlag.Holder == None ) 
			{
				if ( GoPickupFlag(B) )
					return true;
			}
			else
			{
				SetEnemy(B,FriendlyFlag.Holder);
				if ( Level.TimeSeconds - LastSeeFlagCarrier > 6 )
				{
					LastSeeFlagCarrier = Level.TimeSeconds;
					B.SendMessage(None, 'OTHER', B.GetMessageIndex('ENEMYFLAGCARRIERHERE'), 10, 'TEAM');
				} 
				B.GoalString = "Attack enemy flag carrier";
				if ( B.IsSniping() )
					return false;
				return ( FindPathToObjective(B,FriendlyFlag.Holder) );
			}
		}

		if ( GetOrders() == 'Attack' )
		{
			// break off attack only if needed
			// FIXME - 8 should be value gotten from Level's LevelGameRules actor
			if ( bSeeFlag || (EnemyFlag.Holder != None) 
				|| ((Level.TimeSeconds - FriendlyFlag.TakenTime > 8) && !EnemyFlag.Homebase.BotNearObjective(B)) )
			{
				B.GoalString = "Go after enemy holding flag rather than attacking";
				return FindPathToObjective(B,FriendlyFlag.Position());
			}
		}
		else if ( (PlayerController(SquadLeader) == None) && !B.IsSniping() && (HoldSpot(B.GoalScript) == None) )
		{
			// FIXME - try to leave one defender at base
			B.GoalString = "Go find my flag";
			return FindPathToObjective(B,FriendlyFlag.Position());
		}
	}

	if ( (SquadObjective == EnemyFlag.Homebase) && (B.Enemy != None) && FriendlyFlag.Homebase.BotNearObjective(B) )
	{
		B.SendMessage(None, 'OTHER', B.GetMessageIndex('INCOMING'), 15, 'TEAM'); 
		B.GoalString = "Intercept incoming enemy!";
		return false;
	}

	if ( EnemyFlag.Holder == None )
	{
		if ( EnemyFlag.Homebase.BotNearObjective(B) )
		{
			B.GoalString = "Near Flag base!";
			return FindPathToObjective(B,EnemyFlag.Homebase);
		}
	}
	else
	{
		// make flag carrier squad leader if on same squad
		FlagCarrier = EnemyFlag.Holder.Controller;
		if ( (SquadLeader != FlagCarrier) && IsOnSquad(FlagCarrier)	&& !SquadLeader.IsA('PlayerController') 
			&& (Bot(FlagCarrier) != None) )
			SetLeader(FlagCarrier);

		if ( (SquadLeader == FlagCarrier) || ((GetOrders() != 'Defend') && !SquadLeader.IsA('PlayerController'))  )
		{
			if ( (AIController(SquadLeader) != None)
				&& (SquadLeader.MoveTarget != None)
				&& (SquadLeader.InLatentExecution(SquadLeader.LATENT_MOVETOWARD)) )
				FlagCarrierTarget = SquadLeader.MoveTarget;
			else
				FlagCarrierTarget = SquadLeader.Pawn;
			FindPathToObjective(B,FlagCarrierTarget);
			if ( B.MoveTarget == FlagCarrierTarget )
			{
				if ( B.Enemy != None ) 
				{
					B.GoalString = "Fight enemy while waiting for flag carrier";
					B.FightEnemy(false);
					return true;
				}
				if ( !B.bInitLifeMessage )
				{
					B.bInitLifeMessage = true;
					B.SendMessage(EnemyFlag.Holder.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
				}
				if ( (FlagCarrierTarget == SquadLeader) && (SquadLeader.Acceleration == vect(0,0,0)) )
				{
					B.WanderOrCamp(true);
					B.GoalString = "Back up the flag carrier!";
					return true;
				}
			}
			B.GoalString = "Find the flag carrier - move to "$B.MoveTarget;
			return ( B.MoveTarget != None );
		}
	}
	return Super.CheckSquadObjectives(B);
}

function EnemyFlagTakenBy(Controller C)
{
	local Bot M;

	if ( SquadLeader != C )
		SetLeader(C);

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M.MoveTarget == EnemyFlag) || (M.MoveTarget == EnemyFlag.HomeBase) )
			M.MoveTimer = -1;
}

function bool AllowTaunt(Bot B)
{
	return ( (FRand() < 0.5) && (PriorityObjective(B) < 1));
}

function bool ShouldDeferTo(Controller C)
{
	if ( C.PlayerReplicationInfo.HasFlag != None )
		return true;
	return Super.ShouldDeferTo(C);
}

function byte PriorityObjective(Bot B)
{
	if ( B.PlayerReplicationInfo.HasFlag != None )
	{
		if ( FriendlyFlag.HomeBase.BotNearObjective(B) )
			return 255;
		return 2;
	}

	if ( FriendlyFlag.Holder != None )
		return 1;

	return 0;
}

function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	if ( (NewThreat.PlayerReplicationInfo != None)
		&& (NewThreat.PlayerReplicationInfo.HasFlag != None)
		&& bThreatVisible )
	{
		if ( (VSize(B.Pawn.Location - NewThreat.Location) < 1500) || B.Pawn.Weapon.bSniping
			|| (VSize(NewThreat.Location - EnemyFlag.HomeBase.Location) < 2000) )
			return current + 6;
		else
			return current + 1.5;
	}
	else if ( NewThreat.IsHumanControlled() )
		return current + 0.5;
	else
		return current;
}

function bool HandleHelpMessageFrom(Controller Other)
{
	if ( (SquadLeader.PlayerReplicationInfo.HasFlag != None)
		&& (Other != SquadLeader) )
		return false;

	return Super.HandleHelpMessageFrom(Other);
}

defaultproperties
{
	MaxSquadSize=3
}