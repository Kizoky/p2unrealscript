///////////////////////////////////////////////////////////////////////////////
// ACTION_SetDynamicVariable
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Set values in the GameState.
// Now uses the new dynamic variable system
///////////////////////////////////////////////////////////////////////////////
class ACTION_SetDynamicVariable extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Action) Name VarName;					// Variable name to set
var(Action) GameState.EVarType VarType;	// Variable type to set(number or string)
var(Action) GameState.EOperatorSet Operator;	// Operator to perform (+, *, or =)
var(Action) float Number;					// Number to add, multiply, or set
var(Action) string Text;					// Text to set
var(Action) bool bCurrentDayOnly;			// If true, the variable will last only for the rest of the day.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool InitActionFor(ScriptedController C)
{
	local GameState UseGS;
	
	UseGS = P2GameInfoSingle(C.Level.Game).TheGameState;
	if (UseGS != None)
	{
		UseGS.SetDynamicVariable(VarName, VarType, Operator, Number, Text, bCurrentDayOnly);
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// FIXME
///////////////////////////////////////////////////////////////////////////////
function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Set Dynamic Variable"
	bRequiresValidGameInfo=true
	bCurrentDayOnly=true
	Operator=EOS_SetValue
}
