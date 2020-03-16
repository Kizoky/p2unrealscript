class GameObjective extends NavigationPoint
	abstract;

var bool bDisabled;		// true when objective has been destroyed
var bool bFirstObjective; // First objective in list of objectives defended by same team
var() bool bTeamControlled;	// disabling changes the objectives team rather than removing it
var() bool bAccruePoints;	// controlling team accrues points

var() byte DefenderTeamIndex;	// 0 = defended by team 0
var byte StartTeam;
var() byte DefensePriority;	// Higher priority defended/attacked first
var() int Score;			// score given to player that completes this objective
var() localized string ObjectiveName;
var() localized string DestructionMessage;
var() localized string LocationPrefix, LocationPostfix;
var() Name DefenseScriptTags;	// tags of scripts that are defense scripts

var GameObjective NextObjective;	// list of objectives defended by the same team
var MpScriptedSequence DefenseScripts;
var SquadAI DefenseSquad;	// squad defending this objective;
var AssaultPath AlternatePaths;
var() name AreaVolumeTag;
var Volume MyBaseVolume;
var() float BaseExitTime;		// how long it takes to get entirely away from the base
var() float BaseRadius;			// radius of base

var localized string ObjectiveStringPrefix, ObjectiveStringSuffix;

function float GetDifficulty()
{
	return 0;
}

function bool CanDoubleJump(Pawn Other)
{
	return true;
}

function PostBeginPlay()
{
	local GameObjective O, CurrentObjective;
	local AssaultPath A;
	local MpScriptedSequence W;

	Super.PostBeginPlay();

	StartTeam = DefenderTeamIndex;
	
	// find defense scripts
	if ( DefenseScriptTags != '' )
		ForEach AllActors(class'MpScriptedSequence', DefenseScripts, DefenseScriptTags)
			if ( DefenseScripts.bFirstScript )
				break;

	// clear defense scripts bFreelance
	for ( W=DefenseScripts; W!=None; W=W.NextScript )
		W.bFreelance = false;

	// add to objective list
	if ( bFirstObjective )
	{
		CurrentObjective = self;
		ForEach AllActors(class'GameObjective',O)
			if ( O != CurrentObjective )
			{
				CurrentObjective.NextObjective = O;
				O.bFirstObjective = false;
				CurrentObjective = O;
			}
	}

	// set up AssaultPaths
	ForEach AllActors(class'AssaultPath', A)
		if ( A.ObjectiveTag == Tag )
			A.AddTo(self);

	// find AreaVolume
	ForEach AllActors(class'Volume', MyBaseVolume, AreaVolumeTag)
		break;

	if ( (MyBaseVolume != None) && (MyBaseVolume.LocationName ~= "unspecified") )
		MyBaseVolume.LocationName = LocationPrefix@GetHumanReadableName()@LocationPostfix;

	// RWS CHANGE: Make sure it's a team game just in case this used in a non-team setting
	if ( bAccruePoints && TeamGame(Level.Game) != None )
		SetTimer(1.0,true);
}

function PlayAlarm();

function bool BotNearObjective(Bot B)
{
	if ( ((MyBaseVolume != None) && B.Pawn.IsInVolume(MyBaseVolume))
		|| ((B.RouteGoal == self) && (B.RouteDist < 2500))
		|| ((VSize(Location - B.Pawn.Location) < BaseRadius) && (B.bWasNearObjective || B.LineOfSightTo(self))) )
	{
		B.bWasNearObjective = true;
		return true;
	}
	
	B.bWasNearObjective = false;
	return false;
}
	
function Timer()
{
	if ( DefenderTeamIndex < 2 && TeamGame(Level.Game).Teams[DefenderTeamIndex] != None)
	{
		TeamGame(Level.Game).Teams[DefenderTeamIndex].Score += Score;
		Level.Game.TeamScoreEvent(DefenderTeamIndex,Score,"game_objective_score");
	}
}

function bool OwnsDefenseScript(MpScriptedSequence S)
{
	local MpScriptedSequence W;

	for ( W=DefenseScripts; W!=None; W=W.NextScript )
		if ( W == S )
			return true;

	return false;
}

simulated function string GetHumanReadableName()
{
	if ( Default.ObjectiveName != "" )
		return Default.ObjectiveName;

/*	// RWS NOTE: Tried to change this to use the actual team name but it would require
	// getting hold of the GRI on the client side without running any other code in this
	// class on the client side.  It just wasn't worth the effort.
	if ( (GRI != None) && (DefenderTeamIndex < 2) )
		MyTeamName = GRI.Teams[DefenderTeamIndex].TeamName;
	else
		MyTeamName = NoTeamName;
	return ObjectiveStringPrefix$MyTeamName$ObjectiveStringSuffix;
*/
	return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ObjectiveStringSuffix;
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	return B.Squad.FindPathToObjective(B,self);
}
	
function int GetNumDefenders()
{
	if ( DefenseSquad == None )
		return 0;
	return DefenseSquad.GetSize();
	// fiXME - max defenders per defensepoint, when all full, report big number
}

function DisableObjective(Pawn Instigator)
{
	if ( DestructionMessage != "" )
	{
		if ( DestructionMessage == Default.DestructionMessage )
			DestructionMessage = TeamGame(Level.Game).Teams[DefenderTeamIndex].TeamName@DestructionMessage;
		Level.Game.Broadcast(self,DestructionMessage,'CriticalEvent');
	}
	if ( bTeamControlled )
		DefenderTeamIndex = Instigator.PlayerReplicationInfo.Team.TeamIndex;
	else
		bDisabled = true;

	TriggerEvent(Event, self, Instigator);
	if ( bAccruePoints )
		Level.Game.ScoreObjective(Instigator.PlayerReplicationInfo, 0);
	else
		Level.Game.ScoreObjective(Instigator.PlayerReplicationInfo, Score);

//	TeamGame(Level.Game).FindNewObjectives(self);
	MpPlayerReplicationInfo(Instigator.PlayerReplicationInfo).Squad.FindNewObjective();
	DefenseSquad.FindNewObjective();
}

function bool BetterObjectiveThan(GameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( bDisabled || (DefenderTeamIndex != DesiredTeamNum) )
		return false;
	if ( (Best == None) || (Best.DefensePriority < DefensePriority) )
		return true;
	return false;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	bDisabled = false;
	DefenderTeamIndex = StartTeam;
}

defaultproperties
{
	ObjectiveStringPrefix=""
	ObjectiveStringSuffix=" Team Base"
	BaseExitTime=+8.0
	BaseRadius=+2000.0
	bReplicateMovement=false
	bOnlyDirtyReplication=true
	bMustBeReachable=true
	DestructionMessage="Objective Disabled!"
	bFirstObjective=true
	ObjectiveName=""
	LocationPrefix="Near"
	LocationPostfix=""
}