///////////////////////////////////////////////////////////////////////////////
// DialogLoader.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Ensures dialog sounds are loaded before the full game is loaded. By placing
// this in Entry, it maintains a reference to dialog classes that keep them
// from having to be loaded before each level.
//
///////////////////////////////////////////////////////////////////////////////
class DialogLoader extends Info
	config(system)
	placeable;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

// 1 means it will preload a lot of dialog using the DialogLoader in the Entry level. 0 means it won't
// let the dialogloader do anything.
var ()globalconfig int PreloadDialogOnStartup;


// All characters share a single instance of each dialog class.  This array
// of structs is used to keep track of which classes have already been loaded.
struct LDialogObjects
	{
	var string strClass;
	var P2Dialog dialog;
	};
var array<LDialogObjects> Dialogs;

var() array< class<P2Dialog> > DialogClasses;	// List of dialog classes to be preloaded


///////////////////////////////////////////////////////////////////////////////
// Connect our references
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(PreloadDialogOnStartup != 0)
		DoDialogLoad();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DoDialogLoad()
{
	local int i;

	log(self$" Preloading dialog...");
	for(i=0; i<DialogClasses.Length; i++)
	{
		log(self$" Preloading "$DialogClasses[i]);
		GetDialogObj(String(DialogClasses[i]));
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get a reference to the shared instance of the specified dialog class.
//
// All objects share a single instance of each dialog class, and this is the
// sole method by which they should obtain a reference to that instance.
///////////////////////////////////////////////////////////////////////////////
function P2Dialog GetDialogObj(string strClass)
{
	local class<P2Dialog> dialogclass;
	local P2Dialog dialog;
	local int i;

	// Check if specified class was already loaded
	dialog = None;
	for (i = 0; i < Dialogs.Length; i++)
	{
		if (Dialogs[i].strClass == strClass)
		{
			// Return reference to existing object
			dialog = Dialogs[i].dialog;
			break;
		}
	}

	// If not already loaded, then load it now
	if (dialog == None)
	{
		// Try to load specified class
		dialogclass = class<P2Dialog>(DynamicLoadObject(strClass, class'Class'));
		if (dialogclass != None)
		{
			// Try to spawn an object of that class
			dialog = spawn(dialogclass);
			if (dialog != None)
			{
				// Add class to list
				Dialogs.Insert(i, 1);
				Dialogs[i].dialog = dialog;
				Dialogs[i].strClass = strClass;
			}
			else
			{
				Warn("GetDialogObj() - spawn failed for class "$dialogclass);
			}
		}
		else
		{
			Warn("GetDialogObj() - DynamicLoadObject() failed using name "$strClass);
		}
	}

	return dialog;
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	// We don't need to just load male/female because all these extended
	// dialog classes already load thus plus all their special stuff
	DialogClasses[0] = class'BasePeople.DialogFemaleCop'
	DialogClasses[1] = class'BasePeople.DialogMaleCop'
	DialogClasses[2] = class'BasePeople.DialogDude'
	PreloadDialogOnStartup=1
	}
