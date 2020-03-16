///////////////////////////////////////////////////////////////////////////////
// SoundRepeater.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A sound repeater allows you to use the same sound settings at many different
// places in a level.
//
//	History:
//		07/07/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
//
// This simple object allows you to use the same sound settings at many
// different places in a level without having to actually duplicate those
// settings.  The advantage over a simple copy-and-paste is that if you want
// to change the settings, you only have to change them in a single place
// instead of having to remember to go around and change every copy.
//
// A SoundRepeater references a SoundThing by tag.  On startup, the repeater
// copies all the settings from the SoundThing and then it's completely on its
// own.  This means it will be randomly selecting pitch, volume, sounds all
// on its own, indepent of the source or any other sound repeater.  In other
// words, only the settings are copied, and then once the repeater is running,
// it runs completely independently of the source or any other repeater.
//
///////////////////////////////////////////////////////////////////////////////
class SoundRepeater extends SoundThing
	placeable
	hidecategories(SoundThingSettings);

#exec Texture Import File=Textures\SoundRepeater.pcx Name=SoundRepeaterIcon Mips=Off MASKED=1


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() Name				SoundThingTag;


///////////////////////////////////////////////////////////////////////////////
// Copy sound settings from the specified SoundThing
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
	{
	local SoundThing source;
	local bool bFound;

	// Make sure a tag was specified
	if (SoundThingTag != 'None')
		{
		// Loock for SoundThing with specified tag
		ForEach AllActors(class'SoundThing', Source, SoundThingTag)
			{
			// Make sure it's not a reference to itself or to a SoundRepeater
			if(Source != self && SoundRepeater(Source) == None)
				{
				// Copy settings from source to this object
				Settings = Source.Settings;
				Super.PostBeginPlay();
				bFound = true;
				}
			}
		if(!bFound)
			Warn(self$" ERROR: could not find SoundThing with tag "$SoundThingTag);
		}
	else
		Log("SoundRepeater.PostBeginPlay(): WARNING: No source was specified!");
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Texture=Texture'PostEd.Icons_256.SoundRepeater'
	DrawScale=0.25
	}