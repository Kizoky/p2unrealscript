///////////////////////////////////////////////////////////////////////////////
// AWGrenadeWeapon
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Grenades that you throw.
//
// Ensures you can kick them back and it hits the original thrower on contact
//
///////////////////////////////////////////////////////////////////////////////

class AWGrenadeWeapon extends GrenadeWeapon;


var class<AWGrenadeProjectile> throwclass;
var class<AWGrenadeProjectile> dropclass;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ThrowGrenade()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local AWGrenadeProjectile gren;

	if(P2AmmoInv(AmmoType) != None
		&& AmmoType.HasAmmo())
	{
		CalcAIChargeTime();
		FireOffset = AltFireOffset;
		// Alt-firing the grenade, drops it at your feet, and doesn't
		// arm it
		if(bAltFiring)
		{
			ChargeTime = 0.0;
			FireOffset = AltFireOffset;
		}
		else
			FireOffset = default.FireOffset;

		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		StartTrace = GetFireStart(X,Y,Z); 
		AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
		// Make sure we're not generating this on the other side of a thin wall
		// Also, bump anything along the way, so the grenade can break a window if
		// you're standing really close to one.
		//if(FastTrace(Instigator.Location, StartTrace))
		HitActor = Trace(HitLocation, HitNormal, Instigator.Location, StartTrace, true);
		if(HitActor == None
			|| (!HitActor.bStatic
				&& !HitActor.bWorldGeometry))
		{
			if(!bAltFiring)
				gren = spawn(throwclass,Instigator,,StartTrace, AdjustedAim);
			else
				gren = spawn(dropclass,Instigator,,StartTrace, AdjustedAim);

			// Make sure it got made, it could have gotten spawned in a wall and not made
			if(gren != None)
			{
				gren.Instigator = Instigator;

				// Compensate for catnip time, if necessary. Don't do this for NPCs
				if(FPSPawn(Instigator) != None
					&& FPSPawn(Instigator).bPlayer)
					ChargeTime /= Level.TimeDilation;

				gren.SetupThrown(ChargeTime);
				//gren.AddRelativeVelocity(Instigator.Velocity);
				P2AmmoInv(AmmoType).UseAmmoForShot();
				// Touch any actor that was in between, just in case.
				if(HitActor != None)
					HitActor.Bump(gren);
			}
		}
	}
	// Turn off the thing in his hand as it leaves
	if(ThirdPersonActor != None)
		ThirdPersonActor.bHidden=true;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     throwclass=Class'AWInventory.AWGrenadeProjectile'
     dropclass=Class'AWInventory.AWGrenadeAltProjectile'
     Skins(0)=Texture'MP_FPArms.LS_arms.LS_hands_dude'
}
