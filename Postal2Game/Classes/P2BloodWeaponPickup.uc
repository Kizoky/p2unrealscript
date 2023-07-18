///////////////////////////////////////////////////////////////////////////////
// P2BloodWeaponPickup
// by Man Chrzan. 2021/11/19
//
// Pickup for blood weapons to keep the blood on it (Sledge and Scythe).
///////////////////////////////////////////////////////////////////////////////

class P2BloodWeaponPickup extends P2WeaponPickup;

var() travel int SavedBloodTextureIndex;	// 0 none; 1 bloody; 2 more bloody etc

///////////////////////////////////////////////////////////////////////////////
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local P2Weapon p2weap;
	local P2BloodWeapon p2bloodweap;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
	{
		GetCopy(Other, Copy);
	}

	p2weap = P2Weapon(Copy);
	// Set this here, to tell the weapon selection and SwitchPriority that
	// even though we don't yet ammo (because we add it right afterwards) that we
	// actually could have ammo, so judge us accordingly.
	if(p2weap != None)
		p2weap.bJustMade=true;

	Copy.GiveTo( Other );

	if(p2weap != None)
	{
		// Multiplayer has different balancing for how much ammo you get with things
		if(Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			p2weap.GiveAmmoFromPickup(Other, AmmoGiveCount);
		else
			p2weap.GiveAmmoFromPickup(Other, MPAmmoGiveCount);
		
		// xPatch: Here goes our saved texture index
		p2bloodweap = P2BloodWeapon(Copy);
		if(Owner != None && p2bloodweap != None)
		{
			if(SavedBloodTextureIndex != 0)
			{
				p2bloodweap.BloodTextureIndex = SavedBloodTextureIndex;
				p2bloodweap.bForceBlood = true;
			}
		}
		
		p2weap.bJustMade=false;
	}

	return Copy;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	SavedBloodTextureIndex = 0 // No blood by default
}
