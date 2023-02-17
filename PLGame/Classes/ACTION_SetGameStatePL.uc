///////////////////////////////////////////////////////////////////////////////
// ACTION_SetGameStatePL
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
//
// Set values in the PL GameState.
// This class is deprecated, use ACTION_SetDynamicVariable instead
///////////////////////////////////////////////////////////////////////////////
class ACTION_SetGameStatePL extends ACTION_SetDynamicVariable
	noteditinlinenew;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
// DEPRECATED SHIT
var deprecated ACTION_IfGameStatePL.ETest ValueToSet;
enum EAction
{
	EA_Add,				// Adds to current value
	EA_Multiply,		// Multiplies current value
	EA_SetValue			// Sets current value
};
var deprecated EAction ValueAction;
var deprecated float ValueAmount;
