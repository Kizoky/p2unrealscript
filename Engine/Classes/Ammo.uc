//=============================================================================
// Ammo.
//=============================================================================
class Ammo extends Pickup
	abstract
	native;

#exec Texture Import File=Textures\Ammo.pcx Name=S_Ammo Mips=Off MASKED=1

var() int AmmoAmount;	// How much ammo to give

function float BotDesireability(Pawn Bot)
{
	local Ammunition AlreadyHas;

	AlreadyHas = Ammunition(Bot.FindInventoryType(InventoryType));
	if ( AlreadyHas == None )
		return (0.35 * MaxDesireability);
	if ( AlreadyHas.AmmoAmount == 0 )
		return MaxDesireability;
	if (AlreadyHas.AmmoAmount >= AlreadyHas.MaxAmmo) 
		return -1;

	return ( MaxDesireability * FMin(1, 0.15 * AmmoAmount/AlreadyHas.AmmoAmount) );
}

function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);
	Ammunition(Copy).AmmoAmount = AmmoAmount;
	return Copy;
}

defaultproperties
{
     PickupMessage="You picked up some ammo."
     RespawnTime=+00030.000000
     MaxDesireability=+00000.200000
     Texture=Engine.S_Ammo
}