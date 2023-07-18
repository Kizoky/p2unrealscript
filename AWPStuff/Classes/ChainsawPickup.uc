class ChainsawPickup extends P2WeaponPickup;

var() int SavedBloodTextureIndex;	// 0 none; 1 bloody; 2 more bloody etc

///////////////////////////////////////////////////////////////////////////////
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local ChainsawWeapon chainweap;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
	{
		GetCopy(Other, Copy);
	}

	chainweap = ChainsawWeapon(Copy);
	// Set this here, to tell the weapon selection and SwitchPriority that
	// even though we don't yet ammo (because we add it right afterwards) that we
	// actually could have ammo, so judge us accordingly.
	if(chainweap != None)
		chainweap.bJustMade=true;

	Copy.GiveTo( Other );

	if(chainweap != None)
	{
		// Multiplayer has different balancing for how much ammo you get with things
		if(Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			chainweap.GiveAmmoFromPickup(Other, AmmoGiveCount);
		else
			chainweap.GiveAmmoFromPickup(Other, MPAmmoGiveCount);
		
		// Here goes our saved texture index
		if(Owner != None)
		{
			if(SavedBloodTextureIndex != 0)
			{
				chainweap.BloodTextureIndex = SavedBloodTextureIndex;
				chainweap.bForceBlood = true;
			}
		}
		
		chainweap.bJustMade=false;
	}

	return Copy;
}

defaultproperties
{
	AmmoGiveCount=10
	DeadNPCAmmoGiveRange=(Min=5.000000,Max=10.000000)
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'
	ShortSleeveType=Class'ChainsawWeapon'
	InventoryType=Class'ChainsawWeapon'
	PickupMessage="You picked up a Chainsaw!"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ED_TPMeshes.Weapons.TP_Chainsaw'
	Skins[0]=Texture'xPatchTex.Weapons.chainsawskin1'	// non-bloody skin
}