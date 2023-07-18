///////////////////////////////////////////////////////////////////////////////
// MenuImageKeys.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The how-to-use-the-keys screen.
//
///////////////////////////////////////////////////////////////////////////////
class MenuImageKeys_SteamDeck extends MenuImageKeys;

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
{
    Super.Created();
    
    ImageArea.bStretch = true;
    ImageArea.bModernNoStretch = false;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	TextureImageName = "p2misc.Vital_Keys_SteamDeck"
	}
