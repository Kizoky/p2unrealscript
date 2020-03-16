///////////////////////////////////////////////////////////////////////////////
// MenuTheyHateMe.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Menu to explain TheyHateMe difficulty. This is extra hard and has most 
// people attacking the dude on sight.
//
///////////////////////////////////////////////////////////////////////////////
class MenuNightmare extends MenuTheyHateMe;

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	HateTitleText = "POSTAL Difficulty"

	Msg(2)="In POSTAL Mode, not only do all bystanders get guns (like Hestonworld), "
	Msg(3)="but they also hate your guts (like They Hate Me)! "
	Msg(4)="As if that weren't bad enough, you are only allowed one save per level, "
	Msg(5)="and you can no longer store health powerups!\\n"
	Msg(6)="Only the most hardcore POSTAL fanatics should attempt this difficulty."
	}
