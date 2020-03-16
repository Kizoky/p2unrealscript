///////////////////////////////////////////////////////////////////////////////
// ACTION_NavigationPoint
// Copyright 2014, Running With Scissors, Inc.
//
// Lets you do cool things with navigation points
// Important: Do not attempt to change navigation point properties at the
// start of the level. The GameInfo does various things with them on startup,
// such as randomly assigning ExtraCost values for more varied pathmaking,
// and, more importantly, unblocking any navigation points not linked to a
// blocked Dayblocker. If you need to block navigation points at the start
// of the level, do it after an ACTION_Timer of a few seconds or so, to give
// the GameInfo time to do its thing.
///////////////////////////////////////////////////////////////////////////////
class ACTION_NavigationPoint extends ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Action) name UseTag;		// Any NavigationPoints with this tag will be affected
var(Action) enum ENavPointAction
{
	ENP_None,			// No action, only log
	ENP_SetBlocked,		// Sets whether the navpoint is blocked or not.
	ENP_SetOneWay,		// Sets whether the navpoint is one-way or not.
	ENP_AdjustCost		// Adjusts ExtraCost value
} Action;				// Defines which action to take with said navigation points
var(Action) enum ENavPointActionValue
{
	ENPV_False,			// Sets to false
	ENPV_True,			// Sets to true
	ENPV_Toggle,		// Toggles current setting
	ENPV_Set,			// Sets value to ActionValueNum
	ENPV_Add,			// Adds ActionValueNum to current value to get new value
	ENPV_Multiply		// Multiplies ActionValueNum with current value to get new value
} ActionValue;
var(Action) float ActionValueNum;

///////////////////////////////////////////////////////////////////////////////
// Goes through all navpoints in the level and performs action on them.
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local NavigationPoint N;
	
	foreach C.AllActors(class'NavigationPoint', N, UseTag)
	{
		switch (Action)
		{
			// Do nothing.
			case ENP_None:
				break;
				
			// Set bBlocked
			case ENP_SetBlocked:
				N.bBlocked = GetBooleanValueFor(N.bBlocked);
				break;
				
			// Set bOneWayPath
			case ENP_SetOneWay:
				N.bOneWayPath = GetBooleanValueFor(N.bOneWayPath);
				break;
				
			// Adjusts ExtraCost
			case ENP_AdjustCost:
				SetIntValueFor(N.ExtraCost);
				break;
		}
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool GetBooleanValueFor(bool bUseVal)
{
	switch (ActionValue)
	{
		case ENPV_False: return false; break;
		case ENPV_True: return true; break;
		case ENPV_Toggle: return !bUseVal; break;
		default:
			warn("Illegal ActionValue in"@Self);
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetIntValueFor(out int UseVal)
{
	local float TempVal;
	TempVal = UseVal;
	switch (ActionValue)
	{
		case ENPV_Set: TempVal = ActionValueNum;
		case ENPV_Add: TempVal += ActionValueNum;
		case ENPV_Multiply: TempVal *= ActionValueNum;
		default:
			warn("Illegal ActionValue in"@Self);
			break;
	}
	UseVal = int(TempVal);
}

function string GetActionString()
{
	return ActionString@UseTag;
}

defaultproperties
{
	ActionString="Set NavigationPoint"
