///////////////////////////////////////////////////////////////////////////////
// Sample Workshop Game Info
//
// This is a sample Workshop GameInfo based off of GameSinglePlayer.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This builds off our Sandbox Game and adds in a full stock of weaponry
// with infinite ammo.
// This could also be possible with a game mod, but I'm just using it to demonstrate
// how to make your own game classes.
// Also included is a demonstration on how to make your own Startup map that
// the workshop browser will load first before starting a new game.
//
// There are many, many functions in P2GameInfoSingle and its parent classes
// that are not covered here, which you can use to gain even more control
// over how the game works. For details, see their respective classes
// in the source code:
//		Postal2Game.P2GameInfoSingle
//		Postal2Game.P2GameInfo
//		FPSGame.FPSGameInfo
//		Engine.GameInfo
///////////////////////////////////////////////////////////////////////////////
class UltimateSandboxGamePL extends SandboxGamePL;

///////////////////////////////////////////////////////////////////////////////
// Vars (config)
///////////////////////////////////////////////////////////////////////////////
var config bool bAllWeapons;			// If TRUE, the player is granted all weapons when starting a new game.
var config bool bInfiniteAmmo;			// If TRUE, the player is granted infinite ammo on these weapons.
var config array<String> WeaponsToGive;	// The player can add/remove weapons by using the config file.

///////////////////////////////////////////////////////////////////////////////
// Called from P2Player.TravelPostAccept(), which is after the player pawn
// has traveled to (or been created in) a new level.
//
// This ultimately gets called in three basic situations, shown here along
// with how to differentiate them:
//
//  Loaded game: TheGameState != None
//	New game:    TheGameState == None and player's inventory does NOT contain GameState
//  New level:   TheGameState == None and player's inventory contains GameState
//
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
{
	local Inventory Created;
	local Ammunition Ammo;
	local int i;
	
	// Call Super first
	Super.PostTravel(PlayerPawn);
	
	// If this is a new game, and bAllWeapons is true, give the Dude all the weapons in the game.
	if (!bLoadedSavedGame
		&& bAllWeapons)
	{
		// Loop through all the defined weapons and give them to the player.
		for (i=0; i < WeaponsToGive.Length; i++)
		{
			Created = PlayerPawn.CreateInventory(WeaponsToGive[i]);
			// If the weapon got created successfully, jack up their ammo too.
			// Careful -- there's a few weapons we DON'T want to mess with the ammo of.
			if (Created != None
				&& Weapon(Created) != None
				&& ClipboardWeapon(Created) == None
				&& ShockerWeapon(Created) == None
				&& UrethraWeapon(Created) == None)
			{
				Ammo = Weapon(Created).AmmoType;
				if (Ammo != None)
					Ammo.AmmoAmount = Ammo.MaxAmmo;
					
				// If they asked for unlimited ammo, give it to 'em here too.
				if (bInfiniteAmmo
					&& P2AmmoInv(Ammo) != None)
				{
					P2AmmoInv(Ammo).bInfinite = true;
					P2AmmoInv(Ammo).bShowAmmoOnHud = false;
				}
			}
		}
	}
}

defaultproperties
{
	// Default bAllWeapons and bInfiniteAmmo to TRUE
	bAllWeapons=True
	bInfiniteAmmo=True

	// The following array defines the weapons the player will receive at the start of the game
	// (if he requests them)
	WeaponsToGive[0]="AWInventory.MacheteWeapon"
	WeaponsToGive[1]="AWInventory.SledgeWeapon"
	WeaponsToGive[2]="AWInventory.ScytheWeapon"
	WeaponsToGive[3]="Inventory.BatonWeapon"
	WeaponsToGive[4]="Inventory.ShovelWeapon"
	WeaponsToGive[5]="Inventory.ShockerWeapon"
	WeaponsToGive[6]="Inventory.PistolWeapon"
	WeaponsToGive[7]="Inventory.ShotgunWeapon"
	WeaponsToGive[8]="Inventory.MachinegunWeapon"
	WeaponsToGive[9]="Inventory.GasCanWeapon"
	WeaponsToGive[10]="Inventory.CowHeadWeapon"
	WeaponsToGive[11]="Inventory.GrenadeWeapon"
	WeaponsToGive[12]="Inventory.ScissorsWeapon"
	WeaponsToGive[13]="Inventory.MolotovWeapon"
	WeaponsToGive[14]="Inventory.RifleWeapon"
	WeaponsToGive[15]="Inventory.LauncherWeapon"
	WeaponsToGive[16]="Inventory.NapalmWeapon"
	WeaponsToGive[17]="AWPStuff.BaseballBatWeapon"
	WeaponsToGive[18]="AWPStuff.ChainSawWeapon"
	WeaponsToGive[19]="AWPStuff.DustersWeapon"
	WeaponsToGive[20]="AWPStuff.FlameWeapon"
	WeaponsToGive[21]="AWPStuff.SawnOffWeapon"
	WeaponsToGive[22]="EDStuff.ShearsWeapon"
	WeaponsToGive[23]="EDStuff.AxeWeapon"
	WeaponsToGive[24]="EDStuff.BaliWeapon"
	WeaponsToGive[25]="EDStuff.DynamiteWeapon"
	WeaponsToGive[26]="EDStuff.GSelectWeapon"
	WeaponsToGive[27]="EDStuff.GrenadeLauncherWeapon"
	WeaponsToGive[28]="EDStuff.MP5Weapon"
	WeaponsToGive[29]="PLInventory.RevolverWeapon"
	WeaponsToGive[30]="PLInventory.LeverActionShotgunWeapon"
	WeaponsToGive[31]="PLInventory.WeedWeapon"
	WeaponsToGive[32]="PLInventory.FGrenadeWeapon"
	WeaponsToGive[33]="PLInventory.BeanBagWeapon"
	
	// Days, errands, etc. are defined in SandboxGame, so we don't need to
	// include them here too.	
	
	// Advanced users: define an alternate startup map, main menu, and game menu.
	// Can be used for "total conversion"-style games.
	// Don't mess with these unless you have a good working knowledge of the game's startup and menu system	

	// bShowStarrtupOnNewGame: if true, opens up the game's defined MainMenuURL when starting a new game, instead of StartFirstDayURL.
	// This should be a cinematic startup-style map, like POSTAL 2's Startup.fuk
	bShowStartupOnNewGame=true
	// MainMenuURL: URL of map to load when bShowStartupOnNewGame is true
	// This map is also loaded when quitting the game, so it should have a scripted action to show the main menu.
	MainMenuURL="PL-UltimateSandboxStartup"
	// MainMenuName: class of menu to load after quitting the game. Should be PLShell.PLMenuMain unless you know exactly what you're doing
	MainMenuName="PLShell.PLMenuMain"
	// StartMenuName: class of menu to load when starting a new game with bShowStartupOnNewGame=true
	// Typically this will have two options: "Start" and "Quit"
	// If you don't have a specialized start menu, bShowStartupOnNewGame MUST be set to FALSE.
	StartMenuName="Shell.ExpansionMenuStart"
	// GameMenuName: class of menu to use for the Escape menu in-game. Should be Shell.MenuGame unless you know exactly what you're doing
	GameMenuName="Shell.MenuGame"
	
	// Game logo to be displayed in game menus
	MenuTitleTex="PL-UltimateSandboxTex.UltimateSandboxMenuTitlePL"

	// Game Name displayed in the Workshop Browser.
	GameName="PL Ultimate Sandbox Game"
	// Game Name displayed in the Save/Load Game Menu.
	GameNameShort="PL Ultimate Sandbox"
	// Game Description displayed in the Workshop Browser.
	GameDescription="The ultimate sandbox: just you, a crapload of weapons, more ammo than your ass can handle, and the setting of your choice. (Paradise Lost Version)"
}
