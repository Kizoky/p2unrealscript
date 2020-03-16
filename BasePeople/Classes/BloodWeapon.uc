///////////////////////////////////////////////////////////////////////////////
// BloodWeapon
// This is a duplicate class for compatibility purposes
// If you're making a new melee weapon you should use P2BloodWeapon as the
// superclass instead of this because it has more functionality.
///////////////////////////////////////////////////////////////////////////////

class BloodWeapon extends P2Weapon;

var travel bool bShowHint1;
var bool bStopAtDoor;		// If this is set, then we care about hitting doors first and people
							// later. This is really for just the foot. Most of the time we kick doors
							// open. If we directly kick a door open, but a person was on the other side
							// we *don't* want them pissed off (attacking) because we couldn't know they	
							// we're on the other side and for the most part we didn't mean to do that.

var int BloodTextureIndex;			// index into following array
var array<Texture> BloodTextures;	// bloodier versions of this weapon skin

var float AlertRadius;		// how big an area to tell people i'm going to hit about me

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
	local PersonPawn Victims;

	//log(self$" send swing alert ");
	if(Owner != None)
	{
		endpt = Owner.Location + UseMeleeDist*vector(Owner.Rotation);
	}
	else
	{
		endpt = Location;
	}

	foreach VisibleCollidingActors( class'PersonPawn', Victims, UseRadius, endpt )
	{
		//log(self$" seeing "$victims);
		// If they're valid, tell them about your swing
		if(Victims != None
			&& !Victims.bDeleteMe
			&& Victims.Health > 0)
		{
			Victims.BigWeaponAlert(PersonPawn(Owner));
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set the texture that would handle the blood
///////////////////////////////////////////////////////////////////////////////
function SetBloodTexture(Texture NewTex)
{
	Skins[1] = NewTex;
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
	SetBloodTexture(Texture(default.Skins[1]));
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
		CleanWeapon();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
}
