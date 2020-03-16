class BoxLauncherPickup extends P2WeaponPickup;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	if(P2Pawn(Receiver).bPlayer
		&& P2GameInfoSingle(Level.Game) != None)
		//P2GameInfoSingle(Level.Game).WriteCoolness();
		Level.ConsoleCommand("set" @ FlubberPath @ "true");

	Super.AnnouncePickup(Receiver);
}

///////////////////////////////////////////////////////////////////////////////
// Destroy if not enhanced mode.
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	Super.Tick(dT);
	if (P2GameInfoSingle(Level.Game) == None
		|| P2GameInfoSingle(Level.Game).TheGameState == None)
		return;
		
	if (!P2GameInfoSingle(Level.Game).VerifySeqTime())
		Destroy();		
}

defaultproperties
{
	BounceSound=Sound'MiscSounds.Props.MetalCrateDoor'          
	InventoryType=Class'BoxLauncherWeapon'
	PickupMessage="You picked up a... strange-looking rocket launcher."
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Launcher'
	CollisionRadius=60.000000
	CollisionHeight=20.000000
	Skins(0)=Texture'AW7Tex.AMN.BLauncher'
	Skins(1)=Texture'WeaponSkins.fuel_gauge_NEW'
	AmmoGiveCount=100
	DeadNPCAmmoGiveRange=(Max=100)        
}
