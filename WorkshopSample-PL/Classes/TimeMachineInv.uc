///////////////////////////////////////////////////////////////////////////////
// TimeMachineInv
// 2015, Rick F.
//
// Time Machine inventory item that warps the Dude back and forth between
// the ruined Paradise (PL maps) and the regular Paradise (non-PL maps)
///////////////////////////////////////////////////////////////////////////////
class TimeMachineInv extends P2PowerupInv;

#exec TEXTURE IMPORT FILE=Textures\TimeMachineIcon.dds NAME=TimeMachineIcon

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, etc.
///////////////////////////////////////////////////////////////////////////////
var() localized String ReadyHint;		// Hint displayed when time machine is ready.
var() localized String ChargingHint;	// Hint displayed when time machine is recharging.
var() float MaxCharge;					// How much energy we need to activate the time machine
var() float RechargeRate;				// How quickly we recharge energy (charge/sec)
var() Sound ActivateSoundEmpty;			// Sound made when attempting to activate without enough charge
var() Sound ActivateSound1, ActivateSound2;	// Sounds made when activating
var() Sound FailSound;					// Sound made on a failed time travel
var() array<String> ValidMaps;			// Valid maps we can time-travel to or from

///////////////////////////////////////////////////////////////////////////////
// Always set the most recent thing you picked up to this item
///////////////////////////////////////////////////////////////////////////////
function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);
	GotoState('Charging');
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function GetHints(P2Pawn PawnOwner, out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if (Amount >= MaxCharge)
			str1 = ReadyHint;
		else
			str1 = ChargingHint;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Adds a flashbang overlay but without the flashbang sound.
///////////////////////////////////////////////////////////////////////////////
function AddFlashOverlay()
{
	local PLHud Hud;
	
	if (Pawn(Owner) != None
		&& Pawn(Owner).Controller != None
		&& PlayerController(Pawn(Owner).Controller) != None
		&& PlayerController(Pawn(Owner).Controller).MyHUD != None
		&& PLHud(PlayerController(Pawn(Owner).Controller).MyHUD) != None)
	{
		Hud = PLHud(PlayerController(Pawn(Owner).Controller).MyHUD);
		
		// If flashbang effect is already present, get rid of it before adding another
		if (Hud.FlashbangStartTime != 0)
			Hud.OurPlayer.RemoveCameraEffect(Hud.FlashbangEffect);
		
		// Start up our flashbang time and add in the blur effect.
		Hud.FlashbangStartTime = Level.TimeSeconds;
		Hud.OurPlayer.AddCameraEffect(Hud.FlashbangEffect);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Do the actual time travel and send the player to the other time frame
///////////////////////////////////////////////////////////////////////////////
function PerformTimeTravel()
{
	local int i;
	local String CurrentMap, NewMap, PLMap;
	
	CurrentMap = P2GameInfo(Level.Game).ParseLevelName(Level.GetLocalURL());
	if (Left(CurrentMap, 3) ~= "PL-")
		PLMap = Right(CurrentMap, Len(CurrentMap) - 3);
	
	// We don't have a way to check for the existence of a particular map from script, so we check from a list of known maps
	for (i = 0;
	(i < ValidMaps.Length && NewMap == "");
	i++)
	{
		if (CurrentMap ~= ValidMaps[i])
			NewMap = "PL-"$CurrentMap;
		else if (PLMap ~= ValidMaps[i])
			NewMap = ValidMaps[i];
	}
	
	// Check for specific special-case maps
	if (CurrentMap ~= "PL-BanditHideout")
		NewMap = "ParcelCenter";
	if (CurrentMap ~= "PL-WinterWonderland")
		NewMap = "Police";
	if (CurrentMap ~= "ParcelCenter")
		NewMap = "PL-BanditHideout";
	if (CurrentMap ~= "Police")
		NewMap = "PL-WinterWonderland";
	
	if (NewMap != "")
		P2GameInfoSingle(Level.Game).SendPlayerTo(P2GameInfoSingle(Level.Game).GetPlayer(), NewMap);
	else
	{
		Owner.PlaySound(FailSound);
		SetTimer(1.0, false);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Timer - Dude mentions it didn't work
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	if (P2Pawn(Owner) != None)
		P2Pawn(Owner).Say(P2Pawn(Owner).MyDialog.lApologize);
}

///////////////////////////////////////////////////////////////////////////////
// Charging state: recharges battery, cannot activate yet
///////////////////////////////////////////////////////////////////////////////
state Charging
{
	///////////////////////////////////////////////////////////////////////////
	// Activate
	// This item is NOT ready to rock yet...
	///////////////////////////////////////////////////////////////////////////
	function Activate()
	{
		Owner.PlaySound(ActivateSoundEmpty);
		RefreshHints();
		SetTimer(1.0, false);
	}
	
Begin:
	RefreshHints();
	Sleep(1.0/RechargeRate);
	AddAmount(1);
	if (Amount >= MaxCharge)
	{
		RefreshHints();
		GotoState('');
	}
	GotoState('Charging','Begin');
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	ignores Activate;

Begin:
	ReduceAmount(Amount - 1);
	Owner.PlaySound(ActivateSound1);
	Sleep(3.0);
	Owner.PlaySound(ActivateSound2);
	AddFlashOverlay();
	Sleep(3.0);
	PerformTimeTravel();
	// If for some reason the time travel fails, go back to recharging
	GotoState('Charging');
}

defaultproperties
{
	bCanThrow=false
	ReadyHint="Press %KEY_InventoryActivate% to use time machine."
	ChargingHint="Time machine is charging..."
	InventoryGroup=780
	Icon=Texture'TimeMachineIcon'
	bCannotBeStolen=true
	PickupClass=class'TimeMachinePickup'
	bThrowIndividually=false
	ActivateSoundEmpty=Sound'MiscSounds.Radar.RadarClick'
	ActivateSound1=Sound'AmbientSounds.633'
	ActivateSound2=Sound'AmbientSounds.273'
	FailSound=Sound'AmbientSounds.fart1'
	RechargeRate=1.666667
	MaxCharge=100
	ValidMaps[0]="Brewery"
	ValidMaps[1]="Church"
	ValidMaps[2]="Compound"
	ValidMaps[3]="EastMall"
	ValidMaps[4]="Estates"
	ValidMaps[5]="Forest"
	ValidMaps[6]="Greenbelt1"
	ValidMaps[7]="Greenbelt2"
	ValidMaps[8]="Highlands"
	ValidMaps[9]="Industry"
	ValidMaps[10]="Industry2"
	ValidMaps[11]="Junkyard"
	ValidMaps[12]="RWSBlock"
	ValidMaps[13]="Suburbs-1"
	ValidMaps[14]="Suburbs-2"
	ValidMaps[15]="Suburbs-3"
	ValidMaps[16]="Suburbs-4"
	ValidMaps[17]="ToraBora"
	ValidMaps[18]="Underhub"
	ValidMaps[19]="WestMall"
}