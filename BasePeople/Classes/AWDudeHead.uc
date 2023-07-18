//=============================================================================
// AWDudeHead
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// We only really need this because the last moment the dude head was
// still modelled with an incorrect poly on his head and we
// couldn't get the modeller back here in time to fix it. 
//=============================================================================
class AWDudeHead extends AWHead
	placeable;

///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var int HeadSkinIndex;		// index to use as the head skin--AW dude head is a little
							// weird, he uses index 1 instead of 0 for his main head skin

// Added by Man Chrzan: xPatch 2.0		
//var int HairSkinIndex;					
//var Material ExpectedHeadSkin;	

///////////////////////////////////////////////////////////////////////////////
// Switch to a burned texture
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	if(class'P2Player'.static.BloodMode()) {
		Skins[HeadSkinIndex] = BurnVictimHeadSkin;
		Skins[0] = BurnVictimHeadSkin;	// xPatch: Bug fix - not burning gimp/old head
	}
}

///////////////////////////////////////////////////////////////////////////////
// Setmainskin
///////////////////////////////////////////////////////////////////////////////
function SetMainSkin(Material NewHeadSkin)
{	
	Skins[HeadSkinIndex] = NewHeadSkin;
	
	// NOTE: Commented out, found a better method to do it in AWPostalDude.
	
	// xPatch: This will fix our issue with changing back from Gimp clothes.
	// But THIS TIME will not f00k up any player mods from workshop.
	//if(NewHeadSkin == ExpectedHeadSkin || NewHeadSkin == default.Skins[1])
	//	Skins[HairSkinIndex] = default.Skins[HairSkinIndex]; 	 
}

///////////////////////////////////////////////////////////////////////////////
// Setup the head
// Specify head skin index because the dude head got modelled all kooky-like!
///////////////////////////////////////////////////////////////////////////////
simulated function Setup(Mesh NewMesh, Material NewSkin, Vector NewScale, byte NewAmbientGlow)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// Each head can be differently shaped
	RealScale = NewScale;
	SetDrawScale3D(NewScale);
	
	Skins[HeadSkinIndex] = NewSkin;
	if (NewMesh != None)
	{
		LinkMesh(NewMesh);
		LinkSkelAnim(GetDefaultAnim(SkeletalMesh(NewMesh)));
		SetupAnims();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     HeadSkinIndex=1
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
     Skins(0)=Texture'AW_Characters.Special.Alphatex'
     Skins(1)=Texture'AW_Characters.Special.Dude_AW_Bandage'
     Skins(2)=Texture'AW_Characters.Special.Dude_shades'
	 
	 // Added by Man Chrzan: xPatch 2.0
	 //HairSkinIndex=0
	 //ExpectedHeadSkin=Texture'AW_Characters.Special.Dude_AW'
}
