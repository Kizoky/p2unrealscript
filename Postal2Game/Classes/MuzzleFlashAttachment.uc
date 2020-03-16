///////////////////////////////////////////////////////////////////////////////
//  MuzzleFlashAttachment
//
//	These are attached to WeaponAttachments and are flashed
//	when a shot is fired. Mostly copied over from MuzzleFlashAttachment
//	in warfare 927.
//
//	Now not using lighttypes and all. If you don't set LightType, then
// 8 other variables aren't replicated--saves a lot for us each shot.
//
// (c) 2002, RWS, Inc - All Rights Reserved
///////////////////////////////////////////////////////////////////////////////

class MuzzleFlashAttachment extends InventoryAttachment;

var int TickCount;	// How long to display it

// No longer using these--saves replication
var(MuzzleFlash) ELightType FlashLightType;
var(MuzzleFlash) ELightEffect FlashLightEffect;

///////////////////////////////////////////////////////////////////////////////
// Check to enable dynamic lights
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// User menu option for allowing guns, when they fire, to dynamically
	// light up the area around them--independent of muzzle flashes
	if(P2GameInfo(Level.Game) != None
		&& P2GameInfo(Level.Game).AllowDynamicWeaponLights())
		bDynamicLight=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event Timer()
{
	bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Flash()
{
	GotoState('Visible');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Visible
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated state Visible
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated event Tick(float Delta)
	{
		if (TickCount>2)
			gotoState('');
			
		TickCount++;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function EndState()
	{
		// Go to sleep
		bHidden=true;
		LightEffect=LE_None;
		LightType=LT_None;
	}
	
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		local Rotator R;
		local vector V;
		local P2Weapon pweap;
	
		TickCount=0;
		R = RelativeRotation;
		R.Roll = Rand(65535);
		SetRelativeRotation(R);
	
		V=Default.DrawScale3D;
		V.Z += frand() - 0.5;
		V.X += frand() - 0.5;
		V.Y += frand() - 0.5;
	
		SetDrawScale3D(v);

		bHidden=false;
		
		//LightEffect=FlashLightEffect;
		//LightType=FlashLightType;

		if(Pawn(Owner) != None)
		{
			pweap = P2Weapon(Pawn(Owner).Weapon);
			// This won't get called on the non-local client in MP!! The weapon
			// doesn't exist! But for the moment that's okay because we're not doing
			// dynamic lighting on the muzzle flashes.
			if(pweap != None)
			{
				// set the light values on the weapon
				pweap.PickLightValues();
				// now copy them over for yourself to this object
				LightBrightness = pweap.LightBrightness;
				LightSaturation = pweap.LightSaturation;
				LightHue = pweap.LightHue;
				LightRadius = pweap.LightRadius;
			}
		}
	}
		
}		
		
defaultproperties
{
	bAcceptsProjectors=false

	bHidden=true

	FlashLightEffect=LE_NonIncidence
	FlashLightType=LT_Steady

	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockPlayers=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	bBlockKarma=false
}