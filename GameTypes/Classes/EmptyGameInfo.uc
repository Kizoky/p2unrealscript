///////////////////////////////////////////////////////////////////////////////
// EmptyGameInfo
// A bare-bones GameInfo with the barest of essentials, no Errands, etc.
// Base class for all Workshop GameInfos
// Do not copy/paste this class -- see SampleWorkshopGameInfo in WorkshopSample
// instead
///////////////////////////////////////////////////////////////////////////////
class EmptyGameInfo extends P2GameInfoSingle;

///////////////////////////////////////////////////////////////////////////////
// In nightmare mode, give the dude a fish radar
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
	{
	local Inventory InvAdd;
	local P2PowerupInv ppinv;

	const NIGHTMARE_RADAR_MIN = 2000;
	
	Super.PostTravel(PlayerPawn);

	// In nightmare mode, give him a radar with a long battery life
	if (InNightmareMode())
	{
		invadd = PlayerPawn.CreateInventoryByClass(class'RadarInv');
		//log(Self$" invadd "$invadd);
		// Make sure they have enough--if you have more than this, that's fine.
		ppinv = P2PowerupInv(invadd);
		if(ppinv != None
			&& ppinv.Amount < NIGHTMARE_RADAR_MIN)
			ppinv.SetAmount(NIGHTMARE_RADAR_MIN);
			
		// Force it to activate immediately if not already active.
		if (ppinv != None
			&& !ppinv.IsInState('Operating'))
			ppinv.Activate();
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player has watched the last movie in the game and successfully beaten
// the game! Put up the stats screen as we load the main menu.
///////////////////////////////////////////////////////////////////////////////
function EndOfGame(P2Player player)
{
	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();

	// If we haven't called time yet, do so now
	TheGameState.TimeStop = Level.GetMillisecondsNow();
	bGameIsOver = true;

	// Set that you want the stats
	bShowStatsDuringLoad=true;

	// Send player to main menu
	SendPlayerTo(player, MainMenuURL);
}

///////////////////////////////////////////////////////////////////////////////
// Reach into entry and put a new reference to every chameleon texture/meshes in this
// level.
///////////////////////////////////////////////////////////////////////////////
function StoreChams()
{
	local LevelInfo lev;
	local TextureLoader texl;
	local MeshLoader mesher;
	local Actor checkme;
	local PersonPawn checkpawn;

	lev = GetPlayer().GetEntryLevel();

	//log(self$" StoreChams "$lev);

	foreach lev.AllActors(class'Actor', checkme)
	{
		if(TextureLoader(checkme) != None)
			texl = TextureLoader(checkme);
		else if(MeshLoader(checkme) != None)
			mesher = MeshLoader(checkme);
	}

	//log(self$" checking texture loader "$mesher$" mesh loader "$mesher);
	if(texl != None
		&& mesher != None)
	{
		// Clear the lists
		texl.ClearArray();
		mesher.ClearArray();
		// Now go through each pawn and put their textures/meshes into the list
		foreach DynamicActors(class'PersonPawn', checkpawn)
		{
			texl.AddTexture(checkpawn.Skins[0]);
			mesher.AddMesh(checkpawn.Mesh);
			if(checkpawn.MyHead != None)
			{
				texl.AddTexture(checkpawn.MyHead.Skins[0]);
				mesher.AddMesh(checkpawn.MyHead.Mesh);
			}
		}
	}
}

defaultproperties
{
	// Blank Day
	Begin Object Class=DayBase Name=BlankDay
		Description="Blank Day"
		LoadTex="p2misc_full.Load.loading-screen"
		PlayerInvList(0)=(InvClassName="Inventory.MoneyInv",NeededAmount=20)
		PlayerInvList(2)=(InvClassName="Inventory.CopClothesInv",bEnhancedOnly=true)
		PlayerInvList(3)=(InvClassName="Inventory.StatInv")
		PlayerInvList(4)=(InvClassName="Inventory.PistolWeapon")
	End Object
	
	// Game Definition
	Days(0)=DayBase'BlankDay'

	GameSpeed=1.000000
	MaxSpectators=2
	DefaultPlayerName="TheDude"
	PlayerControllerClassName="GameTypes.DudePlayer"
	IntroURL			= ""
	StartFirstDayURL	= "suburbs-3"
	StartNextDayURL		= "suburbs-3"
	FinishedDayURL		= "homeatnight"
	JailURL				= "police.fuk#cell"
	GameStateClass=Class'AWGameState'
	ApocalypseTex="AW7Tex.Misc.ApocalypseNewspaper"
	ChameleonClass=class'ChameleonPlus'
	DefaultPlayerClassName="GameTypes.AWPostalDude"
	HUDType="GameTypes.AchievementHUD"
	KissEmitterClass=class'FX2.KissEmitter'
	MenuTitleTex="P2Misc.Logos.postal2underlined"
	GameName="Sandbox"
	GameNameshort="Sandbox"
	GameDescription="A bare-bones sandbox game mode. Useful for playing custom maps."
	HolidaySpawnerClassName="Postal2Holidays.HolidaySpawner"
}
