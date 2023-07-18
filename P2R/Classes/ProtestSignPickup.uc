class ProtestSignPickup extends P2WeaponPickup;

var travel Material SaveProtestSkin;

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ ProtestPath @ "true");

	Super.AnnouncePickup(Receiver);
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzn: xPatch 2.0
// Same as P2WeaponPickup but with some changes for seting up the skin
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local P2Weapon p2weap;
	local ProtestSignWeaponBase signweap;

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
	signweap = ProtestSignWeaponBase(Copy);
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
		p2weap.bJustMade=false;
		
		// Here goes our saved skin
		SaveProtestSkin = Skins[0];
		
		if(Owner != None && signweap != None)
			signweap.ProtestSkin = SaveProtestSkin;
	}

	return Copy;
}

defaultproperties
{
     BounceSound=Sound'MiscSounds.Props.woodhitsground1'
     ShortSleeveType=Class'ProtestSignWeaponSS'
     InventoryType=Class'ProtestSignWeapon'
     PickupMessage="You're ready to protest."
     DrawType=DT_StaticMesh
     RelativeRotation=(Roll=16383)
     StaticMesh=StaticMesh'P2R_Meshes_D.Weapons.Protest_PU'
     DrawScale=1.0
	 Skins[0]=Texture'Timb.picket.protest19'	// Default skin
}
