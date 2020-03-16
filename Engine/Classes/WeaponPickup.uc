
class WeaponPickup extends Pickup
	abstract;

#exec Texture Import File=Textures\S_Weapon.pcx Name=S_Weapon Mips=Off MASKED=1

var() bool	  bWeaponStay;


function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetWeaponStay();
	MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

function SetWeaponStay()
{
	bWeaponStay = bWeaponStay || Level.Game.bWeaponStay;
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;

	// bots adjust their desire for their favorite weapons
	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	// see if bot already has a weapon of this type
	AlreadyHas = Weapon(Bot.FindInventoryType(InventoryType)); 
	if ( AlreadyHas != None )
	{
		if ( (RespawnTime < 10) 
			&& ( bHidden || (AlreadyHas.AmmoType == None) 
				|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo)) )
			return 0;

		// can't pick it up if weapon stay is on
		if ( bWeaponStay && ((Inventory == None) || Inventory.bTossedOut) )
			return 0;

		// bot wants this weapon for the ammo it holds
		if ( AlreadyHas.HasAmmo() )
			return FMax( 0.25 * desire, 
					AlreadyHas.AmmoType.PickupClass.Default.MaxDesireability
					 * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo/AlreadyHas.AmmoType.AmmoAmount) ); 
		else
			return 0.05;
	}
	
	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4) )
		return 2*desire;

	return desire;
}

defaultproperties
{
     PickupMessage="You got a weapon"
     RespawnTime=30.000000
     Texture=Texture'S_Weapon'
     MaxDesireability=0.5000
}