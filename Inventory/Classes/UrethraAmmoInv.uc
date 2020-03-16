///////////////////////////////////////////////////////////////////////////////
// Ammo (volume) for peeing
///////////////////////////////////////////////////////////////////////////////

class UrethraAmmoInv extends P2AmmoInv;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool	bAmmoNotNormal;		// it's bloodied or diseased or something.
var int AmmoAmountToReturnToNormal;	// Amount of ammo to use till you return to normal, set
								// when bloodied or diseased.
// These are seperate because you could be infected, get bloodied and then need to stay infected,
// after the blood clears.
//var travel int Infected;		// Whether or not you have gonorrhea (urethra only)
var int Bloodied;				// Whether or not you are massively traumatized (urethra only)

///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////
const BLOOD_AMOUNT_TO_USE		=	3;
const GONORRHEA_AMOUNT_TO_USE	=	5;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	// Skip the 9999 ammo in enhanced mode -- doesn't make sense for the urethra
	Super(Ammunition).PostBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Only say it has ammo if you've been overriden and someone pressed the 'P' 
// key or whatever, to allow you to piss. You're not allowed to select this
// weapon with the mouse wheel or the number keys.
///////////////////////////////////////////////////////////////////////////////
simulated function bool HasAmmo()
{
	if(bReadyForUse)
		return Super.HasAmmo();
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Say you are bloody or not
///////////////////////////////////////////////////////////////////////////////
function SetBloodied(bool bOn)
{
	if(bOn 
		&& class'P2Player'.static.BloodMode())
	{
		Bloodied=1;
		// This gets set, saying, you have to use this much ammo up, to 
		// make the blood go away.
		AmmoAmountToReturnToNormal=BLOOD_AMOUNT_TO_USE;
		bAmmoNotNormal=true;
	}
	else
		Bloodied=0;
}
/*
///////////////////////////////////////////////////////////////////////////////
// Set if you are infected or not
///////////////////////////////////////////////////////////////////////////////
function SetInfected(bool bOn)
{
	if(bOn)
		Infected=1;
	else
		Infected=0;
}

///////////////////////////////////////////////////////////////////////////////
// Say you are infected or not
///////////////////////////////////////////////////////////////////////////////
function bool IsInfected()
{
	return (Infected==1);
}
*/
///////////////////////////////////////////////////////////////////////////////
// Say you are bloodied or not
///////////////////////////////////////////////////////////////////////////////
function bool IsBloodied()
{
	return (Bloodied==1);
}

///////////////////////////////////////////////////////////////////////////////
// Take some ammo
// E3HACK 
// don't test for infinite here
///////////////////////////////////////////////////////////////////////////////
function UseAmmoForShot(optional float UseThisAmmo)
{
	if(UseThisAmmo == 0)
		UseThisAmmo = AmmoCountPerShot;

	// Take some ammo
	AmmoAmount-=UseThisAmmo;

	// record for how much you peed during the whole game
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2Pawn(Instigator) != None
		&& P2Pawn(Instigator).bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.PeeTotal++;
	}

	if(bAmmoNotNormal)
	{
		AmmoAmountToReturnToNormal-=UseThisAmmo;

		// When this goes below 0 (or we're out of urine in general), 
		// report to the urethra, so you can be clean again
		if(AmmoAmountToReturnToNormal <= 0
			|| AmmoAmount == 0)
		{
			AmmoAmountToReturnToNormal=0;
			bAmmoNotNormal=false;
			// Because having the ammo link to the weapon presents all sorts of
			// weird issues (since it isn't done down in the engine code)
			// we'll just reach into the p2pawn and grab the urethra there
			// to tell it, we're done being abnormal.
			UrethraWeapon(P2Pawn(Owner).MyUrethra).MakeClean();
		}
	}
}

defaultproperties
{
	MaxAmmo=20
	bInstantHit=true
	bInfinite=false
	Texture=Texture'nathans.Inventory.zipper'
	bReadyForUse=false
//	bCannotBeStolen=true
}