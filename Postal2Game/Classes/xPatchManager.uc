//=============================================================================
// xPatchManager.uc
// by Man Chrzan 
// 2022-09-02
//
// Manager thing for xPatch, to make handling new options easier.
// Should always be spawned by P2GameInfoSingle just like SaveInfo.
//=============================================================================

class xPatchManager extends Info
	config(xPatch)
	placeable;

///////////////////////////////////////////////////////////////////////////////
// Configs
///////////////////////////////////////////////////////////////////////////////

// General
//var globalconfig bool 	bLocalizedDialog;
//var globalconfig bool 	bHUDCrosshair;
//var globalconfig bool 	bWSAchievements;	// NOTE: Mod-exclusive
//var globalconfig bool 	bMarkSaves;			// NOTE: Mod-exclusive

// Blood & Gore
// NOTE: The rest is in BaseFX > xEffectMaker.uc
//var globalconfig byte  GutsType;
//var globalconfig byte  HeadEffectType;
var globalconfig bool  bKeepBlood;		
//var globalconfig bool  bExtraGore;		

// Weapons
var globalconfig byte 	iMFEffect;
var globalconfig byte 	iGlockMode;
var globalconfig byte 	iRevolverMode;
var globalconfig bool 	bSuperRifle;
var globalconfig bool 	bSteamGrenadeLauncher;
var globalconfig bool 	bBaseballCounter;
var globalconfig bool 	bDynamicLights;
var globalconfig bool 	bSPHeadshots;		// NOTE: Mod-exclusive 
var globalconfig bool 	bShellCases;	
var globalconfig float 	ShellSoundVol;	
var globalconfig byte 	ShellLifetime;	
var globalconfig bool 	bRandomGuns;

// Weapons Skins
//var globalconfig bool 	bAltNapalmSkin;
//var globalconfig bool 	bAltRifleSkin;
//var globalconfig bool 	bAltBatSkin;
//var globalconfig bool 	bAltChainsawSkin;
//var globalconfig bool 	bAltFlameSkin;
//var globalconfig bool 	bAltBetaShotgunSkin;
//var globalconfig bool 	bHDDudeSkin;		
//var globalconfig int 	iHandsSkin;

// Player
var globalconfig bool 	bEatEffect;
var globalconfig bool 	bDualEffect;
var globalconfig bool 	bCatnipEffect;

// Viewmodels
var globalconfig bool 	bOverwriteWeaponProperties;
var globalconfig byte 	iWeaponBrightness;
var globalconfig float 	fWeaponFOV;
var globalconfig float 	fWeaponBob;
var globalconfig float 	fWeaponXoffset;
var globalconfig float 	fWeaponYoffset;
var globalconfig float 	fWeaponZoffset;

// Menu
//var globalconfig bool bHideParadiseLost;	// NOTE: Mod-exclusive
//var globalconfig bool bUnlockHolidays;		// NOTE: Mod-exclusive
var globalconfig bool bClassicBackground;
var globalconfig bool bMoveAchevements;		

// Classic Options
var globalconfig bool	bAlwaysOGWeapons;
var globalconfig bool 	bClassicLoadScreens;
var globalconfig bool 	bClassicHands;
var globalconfig array<string> ClassicModeExceptionList;

// Interchangeable Classic Options
// RG - Regular Game
var globalconfig bool 	bNoAWWeapons;
var globalconfig bool 	bNoAWWeaponsRG;
var globalconfig bool 	bAllowExceptions;
var globalconfig bool 	bAllowExceptionsRG;
var globalconfig bool 	bClassicAnimations;
var globalconfig bool 	bClassicAnimationsRG;
var globalconfig bool 	bClassicHUDIcons;
var globalconfig bool 	bClassicHUDIconsRG;
var globalconfig bool 	bClassicZombies;
var globalconfig bool 	bClassicZombiesRG;
var globalconfig bool 	bClassicMelee;
var globalconfig bool 	bClassicMeleeRG;
var globalconfig bool 	bClassicCars;
var globalconfig bool 	bClassicCarsRG;
var globalconfig bool 	bClassicDude;
var globalconfig bool 	bClassicDudeRG;

///////////////////////////////////////////////////////////////////////////////
// Version 
// NOTE: Mod-exclusive
///////////////////////////////////////////////////////////////////////////////
//var string 	Version;
//var globalconfig bool bWorkshopVersion;
//var string WSFilePath;			// Path to check for Workshop version.

///////////////////////////////////////////////////////////////////////////////
// Get various settings with console command (not used anymore)
///////////////////////////////////////////////////////////////////////////////	
/*
static function bool GetBool(Actor Player, string SettingName)
{
	if(Player != None)
		return bool(Player.ConsoleCommand("get" @ "Postal2Game.xPatchManager" @ SettingName));
}

static function int GetInt(Actor Player, string SettingName)
{
	if(Player != None)
		return int(Player.ConsoleCommand("get" @ "Postal2Game.xPatchManager" @ SettingName));
}

static function float GetFloat(Actor Player, string SettingName)
{	
	if(Player != None)
		return float(Player.ConsoleCommand("get" @ "Postal2Game.xPatchManager" @ SettingName));
}
*/

///////////////////////////////////////////////////////////////////////////////
// Checks if weapon is exception for Classic Mode
///////////////////////////////////////////////////////////////////////////////
function bool IsException(string WeaponClass)
{
	local int i;
	local bool Result;
	
	Result = false;
	
	if(bAllowExceptions)
	{
		for( i = 0 ; i < ClassicModeExceptionList.Length ; i++ )
		{
			if(ClassicModeExceptionList[i] == WeaponClass)
				Result = true;
		}
	}
	return Result;
}

///////////////////////////////////////////////////////////////////////////////
// Static check for DayBase
///////////////////////////////////////////////////////////////////////////////
static function bool GetClassicLoading()
{
	if(default.bClassicLoadScreens)
		return true;
	else
		return false;
}

/*
///////////////////////////////////////////////////////////////////////////////
// Checks xPatch version
///////////////////////////////////////////////////////////////////////////////
static function string GetVersionName()
{
	local string WSText;
	if(default.bWorkshopVersion)
		WSText = "(Workshop Cut)";
	return default.Version@WSText;
}

static function bool IsStandaloneVersion()
{
	local int n, n2;
	local bool returnval;
	
	n = FileSize(default.WSFilePath);
	
	if( n > -1 )
		returnval = true;
		
	return returnval;
}*/

defaultproperties
{
	// Version Info
	//Version="xPatch 3.0"
	
	// Default INI settings
	fWeaponBob=1.1
	iWeaponBrightness=128
	bEatEffect=True
	bDualEffect=True
	bCatnipEffect=True
//	bWSAchievements=True
	bSuperRifle=True
	bRandomGuns=True
	bClassicBackground=False
	iMFEffect=0
	iGlockMode=2
	ShellLifetime=3
	ShellSoundVol=0.5
	
	// Classic Mode
	bNoAWWeapons=True
	bClassicAnimations=True
	bClassicHUDIcons=True
	bClassicZombies=True
	bClassicMelee=True
	bClassicCars=True

	// NOTE: Defaults for testing exception list
	// Comment out before release!
	//ClassicModeExceptionList[0]="EDStuff.BaliPickup"
	//ClassicModeExceptionList[1]="EDStuff.BaliWeapon"
	//ClassicModeExceptionList[2]="AWPStuff.BaseballBatPickup"
	//ClassicModeExceptionList[3]="AWPStuff.BaseballBatWeapon"
	//ClassicModeExceptionList[4]="AWPStuff.NukePickup"	
	//ClassicModeExceptionList[5]="AWPStuff.NukeWeapon"	
	//ClassicModeExceptionList[6]="AWPStuff.ChainSawPickup"
	//ClassicModeExceptionList[7]="AWPStuff.ChainSawWeapon"
}