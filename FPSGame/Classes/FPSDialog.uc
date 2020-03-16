///////////////////////////////////////////////////////////////////////////////
// FPSDialog
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all dialog in this game.
//
///////////////////////////////////////////////////////////////////////////////
class FPSDialog extends Info
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// Info for each sound
struct DynSound
	{
	var String Name;
	var Sound Snd;
	var float BleepTime1;	// time at which bleep is required
	var float BleepTime2;	// time at which bleep is required
	var float BleepTime3;	// time at which bleep is required
	};

// There are often multiple choices of dialog for any particular situation.
// All those pieces of dialogs are stored in a Sounds struct, and then we
// can randomly choose one of them whenever this dialog is needed.
struct SLine
	{
	var int i;
	var array<DynSound> sounds;
	var bool bCoreyLine;
	};


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	}
