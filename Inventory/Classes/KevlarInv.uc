///////////////////////////////////////////////////////////////////////////////
// KevlarInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Kevlar armor.. usually gets used instantly when you get it
//
///////////////////////////////////////////////////////////////////////////////

class KevlarInv extends OwnedInv;

var class<KevlarMesh> ArmorMeshClassClean;	// class of kevlar mesh we use
var class<KevlarMesh> ArmorMeshClassDam1;
var class<KevlarMesh> ArmorMeshClassDam2;
var class<P2Emitter>	EffectClass;		// effect made by it when it's shot/hurt
var float ArmorAmount;						// Temp variable to store how much armor
											// we had when on the guy, so when he dies, if it was
											// damaged that lesser value will be copied over
											// to the pickup to use.

///////////////////////////////////////////////////////////////////////////////
// Give him armor
///////////////////////////////////////////////////////////////////////////////
function Activate()
{
	local P2Pawn CheckPawn;
	local float UseArmor;

	CheckPawn = P2Pawn(Owner);	

	// In case it's been dropped and the value is lowered from damage, then
	// decide which amount to use. ArmorAmount in the inventory will only
	// be non-zero if it's been set by Personpawn after someone dropped it.
	if(ArmorAmount != 0)
		UseArmor = ArmorAmount;
	else
		UseArmor = class'KevlarPickup'.default.ArmorAmount;

	CheckPawn.AddArmor(UseArmor, 
					Texture(Icon),
					class);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'KevlarPickup'
	ArmorMeshClassClean=class'KevlarMesh'
	ArmorMeshClassDam1=class'KevlarMeshDam1'
	ArmorMeshClassDam2=class'KevlarMeshDam2'
	EffectClass=class'KevlarChunks'
	Icon=Texture'HUDPack.Icon_Special_Vest'
	InventoryGroup =123
	bPaidFor=true
	bAutoActivate=true
	bUseUpAutoActivate=true
	}
