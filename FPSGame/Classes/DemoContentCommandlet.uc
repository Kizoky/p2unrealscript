///////////////////////////////////////////////////////////////////////////////
// DemoContent
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all dialog in this game.
//
/// Usage:
///    ucc.exe DemoContent
//
///////////////////////////////////////////////////////////////////////////////
class DemoContentCommandlet extends Commandlet
	native;

defaultproperties
	{
	HelpCmd="DemoContent"
	HelpOneLiner="Generate demo content"
	HelpUsage="DemoContent (no parameters)"
	HelpWebLink=""
	HelpParm(0)="IntParm"
	HelpDesc(0)="An integer parameter"
	HelpParm(1)="StrParm"
	HelpDesc(1)="A string parameter"

	LogToStdout=false
	IsServer=true
	IsClient=true
	IsEditor=true
	LazyLoad=false
	ShowErrorCount=true
	ShowBanner=true
	}
