///////////////////////////////////////////////////////////////////////////////
// BodyArmorInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Silicon Carbide ceramic plates inside a kevlar vest. Tougher than Kevlar armor
//
///////////////////////////////////////////////////////////////////////////////

class BodyArmorInv extends KevlarInv;

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
		UseArmor = class'BodyArmorPickup'.default.ArmorAmount;

	CheckPawn.AddArmor(UseArmor, 
					Texture(Icon),
					class,
					class'BodyArmorPickup'.default.ArmorAmount);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ArmorMeshClassClean=class'KevlarMeshSic'
	ArmorMeshClassDam1=class'KevlarMeshSicDam1'
	ArmorMeshClassDam2=class'KevlarMeshSicDam2'
	PickupClass=class'BodyArmorPickup'
	EffectClass=class'KevlarSicChunks'
	Icon=Texture'HUDPack.Icon_Inv_KevlarHeavy'
	InventoryGroup =130
	bPaidFor=true
	bAutoActivate=true
	bUseUpAutoActivate=true
	}
