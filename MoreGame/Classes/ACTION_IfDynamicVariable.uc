///////////////////////////////////////////////////////////////////////////////
// ACTION_IfDynamicVariable
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Executes a section of actions only if the specified gamestate status is met.
// Now uses the new dynamic variable system
///////////////////////////////////////////////////////////////////////////////
class ACTION_IfDynamicVariable extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Action) Name VarName;		// Variable name to check
var(Action) GameState.EVarType VarType;	// Variable type to check (number or string)
var(Action) GameState.EOperatorCheck Operator;	// Operator to perform (equals, not equals etc)
var(Action) float Number;		// Number to compare
var(Action) string Text;		// Text to compare

///////////////////////////////////////////////////////////////////////////////
// Check with the GameState and have it do the grunt work for us
///////////////////////////////////////////////////////////////////////////////
function ProceedToNextAction(ScriptedController C)
{
	local bool bResult;
	local P2GameInfoSingle game;
	local GameState usegs;

	game = P2GameInfoSingle(C.Level.Game);
	if(game != None)
	{
		usegs = game.TheGameState;
		if (usegs != None)
		{
			bResult = usegs.CompareDynamicVariable(VarName, VarType, Operator, Number, Text);
		}
	}	

	C.ActionNum += 1;
	if (!bResult)
		ProceedToSectionEnd(C);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool StartsSection()
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// FIXME
///////////////////////////////////////////////////////////////////////////////
function string GetActionString()
{
	local string VarTypeStr, OperatorStr, CheckVarStr;
	
	switch (VarType)
	{
		case EVT_Number: VarTypeStr = "number"; break;
		case EVT_String: VarTypeStr = "text"; break;
	}
	switch (Operator)
	{
		case EOC_NotEqual: OperatorStr = "!="; break;
		case EOC_Equals: OperatorStr = "=="; break;
		case EOC_GreaterThan: OperatorStr = ">"; break;
		case EOC_GreaterEquals: OperatorStr = ">="; break;
		case EOC_LessThan: OperatorStr = "<"; break;
		case EOC_LessEquals: OperatorStr = "<="; break;
	}
	switch (VarType)
	{
		case EVT_Number: CheckVarStr = String(Number); break;
		case EVT_String: CheckVarStr = Text; break;
	}	
	
	return ActionString@VarName@VarTypeStr@OperatorStr@CheckVarStr;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActionString="If PL GameState"
	bRequiresValidGameInfo=true
	Operator=EOC_Equals
}
