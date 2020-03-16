///////////////////////////////////////////////////////////////////////////////
// FPSScriptedSequence
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This started as UnrealScriptedSequence, but we eventually wiped it clean
// because we aren't implementing the kinds of bots that epic is using.
//
///////////////////////////////////////////////////////////////////////////////
class FPSScriptedSequence extends ScriptedSequence;

defaultproperties
	{
	ScriptControllerClass=class'FPSController'
	}
