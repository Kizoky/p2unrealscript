///////////////////////////////////////////////////////////////////////////////
// P2BloodWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Any cutting/bludgeoning weapon that gets more bloody as it hits bodies.
// Machete, scythe, sledgehammer, shovel, and so on.
///////////////////////////////////////////////////////////////////////////////

class P2BloodWeapon extends P2Weapon;

var travel bool bShowHint1;
var() bool bStopAtDoor;		// If this is set, then we care about hitting doors first and people later.
							// This is really for just the foot. Most of the time we kick doors
							// open. If we directly kick a door open, but a person was on the other side
							// we *don't* want them pissed off (attacking) because we couldn't know they	
							// we're on the other side and for the most part we didn't mean to do that.

// xPatch Edit: BloodTextureIndex now travels between levels.
var travel int BloodTextureIndex;			// index into following array
var() array<Material> BloodTextures;		// bloodier versions of this weapon skin
var() int BloodSkinIndex;					// Index of weapon model that gets more and more bloody. This will be 1 for most weapons but some models may have the skins reversed.

var float AlertRadius;		// how big an area to tell people i'm going to hit about me

// xPatch 2.0 Additions
var bool bForceBlood;							// Forces weapon to restore blood no matter the setting (used by Sledge, Scythe and TravelPostAccept).
var() int ThirdPersonBloodSkinIndex;			// Index of weapon attachment that gets more and more bloody.  			 			

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if(bShowHint1)
			str1=HudHint1;
		else
			str2=HudHint2;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	Super.RefreshHints();
	bShowHint1=true;
}

///////////////////////////////////////////////////////////////////////////////
// Tell them your about to smash things
///////////////////////////////////////////////////////////////////////////////
function SendSwingAlert(float UseRadius)
{
	local vector endpt;
	local P2MoCapPawn Victims;

	//log(self$" send swing alert ");
	if(Owner != None)
	{
		endpt = Owner.Location + UseMeleeDist*vector(Owner.Rotation);
	}
	else
	{
		endpt = Location;
	}

	foreach VisibleCollidingActors( class'P2MoCapPawn', Victims, UseRadius, endpt )
	{
		//log(self$" seeing "$victims);
		// If they're valid, tell them about your swing
		if(Victims != None
			&& !Victims.bDeleteMe
			&& Victims.Health > 0)
		{
			Victims.BigWeaponAlert(P2MoCapPawn(Owner));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the texture that would handle the blood
///////////////////////////////////////////////////////////////////////////////
function SetBloodTexture(Material NewTex)
{
	Skins[BloodSkinIndex] = NewTex;
	
	//xPatch
	if (ThirdPersonActor != None && ThirdPersonBloodSkinIndex != -1)
		ThirdPersonActor.Skins[ThirdPersonBloodSkinIndex] = NewTex;
	//end
}

///////////////////////////////////////////////////////////////////////////////
// Add more blood the weapon by incrementing into the blood texture array for
// skins
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	// Can add more blood, so do
	if(BloodTextureIndex < BloodTextures.Length)
	{
		// update the texture
		SetBloodTexture(BloodTextures[BloodTextureIndex]);
		BloodTextureIndex++;	
	}
	//log(self$" drew blood "$BloodTextureIndex$" new skin "$Skins[1]);
}

///////////////////////////////////////////////////////////////////////////////
// Remove all blood from blade
///////////////////////////////////////////////////////////////////////////////
function CleanWeapon()
{
	BloodTextureIndex = 0;
	SetBloodTexture(default.Skins[BloodSkinIndex]);
	//log(self$" clean weapon "$BloodTextureIndex$" new skin "$Skins[1]);	
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Weapon gets cleaned when you bring it back out each time
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Active
{
	function BeginState()
	{
		Super.BeginState();
		
		if(!RestoreBlood())	// xPatch: Check for restoring blood.
			CleanWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Returns if we should clean or not + restores blood if needed. 
///////////////////////////////////////////////////////////////////////////////
function bool RestoreBlood()
{
	if((P2GameInfoSingle(Level.Game) != None && P2GameInfoSingle(Level.Game).xManager.bKeepBlood && BloodTextureIndex != 0)
	|| (bForceBlood && BloodTextureIndex != 0))
	{
		SetBloodTexture(BloodTextures[BloodTextureIndex - 1]);	// NOTE: BloodTextureIndex defines the next blood skin so do -1
		bForceBlood=False;
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Always restore blood after the player goes to the next level
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	if (Instigator.Weapon == self)
		bForceBlood = true;
		
	Super.TravelPostAccept();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	BloodSkinIndex=1
	ThirdPersonBloodSkinIndex=-1	// -1 = Disabled
}
