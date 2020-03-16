//=============================================================================
// TeamAI.
// strategic team AI control for TeamGame
// 
//=============================================================================
class TeamAI extends Info;

var MpTeamInfo Team;
var MpTeamInfo EnemyTeam;
var	int	NumSupportingPlayer; 
var GameObjective Objectives; // list of objectives to be defended or attacked by this team
var GameObjective PickedObjective;	// objective that was picked from a list of equal priority objectives
var SquadAI Squads;		
var SquadAI AttackSquad, FreelanceSquad;
var class<SquadAI> SquadType;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(5.0,true);
}

function Timer()
{
	ReAssessStrategy();
}

/* ReAssessStrategy()
Look at current strategic situation, and decide whether to update squad objectives
*/
function ReAssessStrategy()
{
	local GameObjective O;
	local int PlusDiff, MinusDiff;

	if ( FreelanceSquad == None )
		return;

	// decide whether to play defensively or aggressively
	if ( TeamGame(Level.Game).TimeLimit > 0 )
	{
		PlusDiff = 0;
		MinusDiff = 2;
		if ( TeamGame(Level.Game).RemainingTime < 180 )
			MinusDiff = 0;
	}
	else
	{
		PlusDiff = 2;
		MinusDiff = 2;
	}

	FreelanceSquad.bFreelanceAttack = false;
	FreelanceSquad.bFreelanceDefend = false;
	if ( Team.Score > EnemyTeam.Score + PlusDiff )
	{
		FreelanceSquad.bFreelanceDefend = true;
		O = GetLeastDefendedObjective();
	}
	else if ( Team.Score < EnemyTeam.Score - MinusDiff )
	{
		FreelanceSquad.bFreelanceAttack = true;
		O = GetPriorityAttackObjective();
	}
	else
		O = GetPriorityFreelanceObjective();

	if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
		FreelanceSquad.SetObjective(O);
}

function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
		S.NotifyKilled(Killer,Killed,KilledPawn);
}

/* FindNewObjective()
pick a new objective for a squad that has completed its current objective
*/
function FindNewObjectiveFor(SquadAI S)
{
	local GameObjective O, Temp;
	
	if ( PlayerController(S.SquadLeader) != None )
		return;
	if ( S.bFreelance )
		O = GetPriorityFreelanceObjective();
	else if ( S.GetOrders() == 'Attack' )
		O = GetPriorityAttackObjective();
	if ( O == None )
	{
		O = GetLeastDefendedObjective();
		if ( (O != None) && (O.DefenseSquad != None) )
		{
			if ( S.GetOrders() == 'Attack' )
			{
				S.MergeWith(O.DefenseSquad);
				return;
			}
			else
			{
				Temp = O;
				O = GetPriorityAttackObjective();
				if ( O == None )
				{
					S.MergeWith(Temp.DefenseSquad);
					return;
				}
			}
		}
	}
	if ( (O == None) && (S.bFreelance || (S.GetOrders() == 'Defend')) )
		O = GetPriorityAttackObjective();
	S.SetObjective(O);
}

function RemoveSquad(SquadAI Squad)
{
	local SquadAI S;

	if ( Squad == Squads )
	{
		Squads = Squads.NextSquad;
		return;
	}
	For ( S=Squads; S!=None; S=S.NextSquad )
		if ( S.NextSquad == Squad )
		{
			S.NextSquad = S.NextSquad.NextSquad;
			return;
		}
}

function ClearOrders(Controller Leaving)
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
		S.ClearOrders(Leaving);
}

function bool OnThisTeam(Pawn Other)
{
	if ( Other.PlayerReplicationInfo != None )
		return ( Other.PlayerReplicationInfo.Team == Team );
	return false;
}

function SquadAI FindSquadOf(Controller C)
{
	local SquadAI S;

	if ( Bot(C) != None )
		return Bot(C).Squad;

	for ( S=Squads; S!=None; S=S.NextSquad )
		if ( S.SquadLeader == C )
			return S;
	return None;
}

function bool FriendlyToward(Pawn Other)
{
	return OnThisTeam(Other);
}	

function SetObjectiveLists()
{
	local GameObjective O;

	ForEach AllActors(class'GameObjective',O)
		if ( O.bFirstObjective )
		{
			Objectives = O;
			break;
		}
}

function SquadAI FindHumanSquad()
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
		if ( S.SquadLeader.IsA('PlayerController') )
			return S;
}

function SquadAI AddHumanSquad()
{	
	local SquadAI S;
	local Controller P;
	
	S = FindHumanSquad();
	if ( S != None )
		return S;

	// add human squad		
	For ( P=Level.ControllerList; P!=None; P= P.NextController )
		if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo.Team == Team)
			&& !P.PlayerReplicationInfo.bOnlySpectator )
		return AddSquadWithLeader(P,None);
}

function PutBotOnSquadLedBy(Controller C, Bot B)
{
	local SquadAI S;

	for ( S=Squads; S!=None; S=S.NextSquad )
		if ( S.SquadLeader == C )
			break;

	if ( S != None )
		S.AddBot(B);		
}	

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local SquadAI S;

	S = spawn(SquadType);
	S.Initialize(Team,O,C);
	S.NextSquad = Squads;
	Squads = S;
	return S;
}

function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( !O.bDisabled && (O.DefenderTeamIndex == Team.TeamIndex)
			&& ((Best == None) || (Best.DefensePriority	< O.DefensePriority)
				|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() < O.GetNumDefenders()))) )
			Best = O;
	}
	return Best;
}

function GameObjective GetMostDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( !O.bDisabled && (O.DefenderTeamIndex == Team.TeamIndex)
			&& ((Best == None) || (Best.DefensePriority	< O.DefensePriority)
				|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() > O.GetNumDefenders()))) )
			Best = O;
	}	
	return Best;
}

function GameObjective GetPriorityAttackObjective()
{
	local GameObjective O;

	if ( (PickedObjective != None) && PickedObjective.bDisabled )
		PickedObjective = None;
	if ( PickedObjective == None )
	{
		for ( O=Objectives; O!=None; O=O.NextObjective )
		{
			if ( !O.bDisabled && (O.DefenderTeamIndex != Team.TeamIndex)
				&& ((PickedObjective == None) || (PickedObjective.DefensePriority < O.DefensePriority) 
					|| ((PickedObjective.DefensePriority == O.DefensePriority) && (FRand() < 0.3))) )
				PickedObjective = O;
		}	
	}
	return PickedObjective;
}

function GameObjective GetPriorityFreelanceObjective()
{
	return GetPriorityAttackObjective();
}

function bool PutOnDefense(Bot B)
{
	local GameObjective O;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		if ( O.DefenseSquad == None )
			O.DefenseSquad = AddSquadWithLeader(B, O);
		else
			O.DefenseSquad.AddBot(B);
		return true;
	}
	return false;
}

function PutOnOffense(Bot B)
{
	if ( (AttackSquad == None) || (AttackSquad.Size >= AttackSquad.MaxSquadSize) )
		AttackSquad = AddSquadWithLeader(B, GetPriorityAttackObjective());
	else
		AttackSquad.AddBot(B);
}

function PutOnFreelance(Bot B)
{
	if ( (FreelanceSquad == None) || (FreelanceSquad.Size >= FreelanceSquad.MaxSquadSize) )
		FreelanceSquad = AddSquadWithLeader(B, GetPriorityFreelanceObjective());
	else
		FreelanceSquad.AddBot(B);
	FreelanceSquad.bFreelance = true;
}

/*
SetBotOrders - based on RosterEntry recommendations

FIXME - need assault type pick leader when leader dies for attacking
freelance squad - backs up defenders under attack, or joins in attacks
*/
function SetBotOrders(Bot NewBot, RosterEntry R)
{
	local SquadAI HumanSquad;

	if ( Objectives == None )
		SetObjectiveLists();

	if ( ((R==None) || R.RecommendDefense()) && PutOnDefense(NewBot) )
		return;

	if ( (R==None) || R.RecommendFreelance() )
	{
		PutOnFreelance(NewBot);
		return;
	}

	// Follow any human player
	HumanSquad = AddHumanSquad();
	if ( HumanSquad != None )				
	{
		HumanSquad.AddBot(NewBot);
		return;
	}
	PutOnOffense(NewBot);
}	

/* SetOrders()
Called when player gives orders to bot
*/
function SetOrders(Bot B, name NewOrders, Controller OrderGiver)
{
	if ( HoldSpot(B.GoalScript) != None )
		B.FreeScript();
	if ( NewOrders == 'Hold' )
	{
		PutBotOnSquadLedBy(OrderGiver,B);
		B.GoalScript = PlayerController(OrderGiver).ViewTarget.Spawn(class'HoldSpot');
		if ( PlayerController(OrderGiver).ViewTarget.Physics == PHYS_Ladder )
			B.GoalScript.SetPhysics(PHYS_Ladder);
	}
	else if ( NewOrders == 'Defend' )
		PutOnDefense(B);
	else if ( NewOrders == 'Attack' )
		PutOnOffense(B);
	else if ( NewOrders == 'Follow' )
	{
		B.FreeScript();
		PutBotOnSquadLedBy(OrderGiver,B);
	}
}

function CallForHelp(Bot B)
{
	local SquadAI S;

	// FIXME - decide which squads to pass the message on to
	for ( S = Squads; S!=None; S=S.NextSquad )
		S.HandleHelpMessageFrom(B);
}

function RemoveFromTeam(Controller Other)
{
	local SquadAI S;
	
	if ( PlayerController(Other) != None )
	{
		for ( S=Squads; S!=None; S=S.NextSquad )
			S.RemovePlayer(PlayerController(Other));	
	}
	else if ( Bot(Other) != None )
	{
		for ( S=Squads; S!=None; S=S.NextSquad )
			S.RemoveBot(Bot(Other));
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	SquadType=class'MultiBase.SquadAI'
}