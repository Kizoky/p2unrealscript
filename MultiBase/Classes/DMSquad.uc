//=============================================================================
// DMSquad.
// operational AI control for DeathMatch
// each bot is on its own squad
//=============================================================================

class DMSquad extends SquadAI;

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string EnemyList;
	local int i;

	Canvas.SetDrawColor(255,255,255);	
	EnemyList = "     Enemies: ";
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] != None )
			EnemyList = EnemyList@Enemies[i].GetHumanReadableName();
	Canvas.DrawText(EnemyList, false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function AddBot(Bot B)
{
	Super.AddBot(B);
	SquadLeader = B;
}

function RemoveBot(Bot B)
{
	if ( B.Squad != self )
		return;
	Destroy();
}

/* 
Return true if squad should defer to C
*/
function bool ShouldDeferTo(Controller C)
{
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	return false;
}

function bool WaitAtThisPosition(Pawn P)
{
	return false;
}

function bool NearFormationCenter(Pawn P)
{
	return true;
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious()
{
	return ( (SquadMembers.Skill >= 4)
		&& (FRand() < 0.65 - 0.15 * Level.Game.NumBots) );
}

function name GetOrders()
{
	return CurrentOrders;
}

function SetEnemy( Bot B, Pawn NewEnemy )
{
	if ( (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None) 
		|| ((Bot(NewEnemy.Controller) != None) && (Bot(NewEnemy.Controller).Squad == self)) )
		return;

	// add new enemy to enemy list - return if already there
	if ( !AddEnemy(NewEnemy) )
		return;

	// reassess squad member enemy
	FindNewEnemyFor(B,(B.Enemy !=None) && B.LineOfSightTo(SquadMembers.Enemy));
}

function bool FriendlyToward(Pawn Other)
{
	return false;
}

function byte PriorityObjective(Bot B)
{
	return 0;
}

function BotVoiceMessage(Bot B, name messagetype, byte messageID, Controller Sender)
{
}
		
function bool WhatToDoNext(Bot B)
{
	return FindNewEnemyFor(B,false);
}

/* NeedWeapon()
returns true if need to go find a weapon or ammo overrides following orders
FIXME - should pass in a 0-1 priority level which must be overcome to ignore orders
*/
function bool NeedWeapon(Bot B)
{
	// check if need ammo
	if ( B.NeedAmmo() )
		return true;

	return ( B.Pawn.Weapon.AIRating < 0.4 );
}

function CallForHelp(Bot B)
{
}

function bool HandleHelpMessageFrom(Controller Other)
{
	return false;
}

defaultproperties
{
	CurrentOrders=Freelance
}
