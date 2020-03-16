///////////////////////////////////////////////////////////////////////////////
// ScriptedAction.uc
//
// Base class for all scripted actions.  By convention, all extended classes
// should be named ACTION_NameOfAction.uc.
//
//
// WARNING !!! 
//
// All ScriptedActions are Objects so they are subject to the typical engine
// issues related to Objects containing references to Actors.  Specifically,
// any such references can cause crashes when loading saved games unless they
// are handled very carefully.
//
// The general solution to this problem is to make sure any Actor reference
// is marked "transient".  This will prevent it from being saved and will
// ensure that it will be None after a load, both of which are very important.
// The second part of the solution is to make sure that any such references
// will be re-initialized if they are None (which is the case after a load).
// So don't use "None" to indicate something special.
// 
///////////////////////////////////////////////////////////////////////////////
class ScriptedAction extends Object
		abstract
		hidecategories(Object)
		collapsecategories
		editinlinenew
		native;

cpptext
{
	const TCHAR* UScriptedAction::GetHelpText();
}

var localized string ActionString;
var bool bValidForTrigger;
// RWS Change: some actions need a valid GameInfo to work properly
var bool bRequiresValidGameInfo;

function bool InitActionFor(ScriptedController C)
{
	return false;
}

function bool EndsSection()
{
	return false;
}

function bool StartsSection()
{
	return false;
}

function ScriptedSequence GetScript(ScriptedSequence S)
{
	return S;
}

function ProceedToNextAction(ScriptedController C)
{
	C.ActionNum += 1;
}

function ProceedToSectionEnd(ScriptedController C)
{
	local int Nesting;
	local ScriptedAction A;

	While ( C.ActionNum < C.SequenceScript.Actions.Length )
	{
		A = C.SequenceScript.Actions[C.ActionNum];
		if ( A.StartsSection() )
			Nesting++;
		else if ( A.EndsSection() )
		{
			Nesting--;
			if ( Nesting < 0 )
				return;
		}
		C.ActionNum += 1;
	}
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="unspecified action"
	bValidForTrigger=true
}