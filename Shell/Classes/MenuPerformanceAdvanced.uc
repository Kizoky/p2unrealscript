///////////////////////////////////////////////////////////////////////////////
// MenuPerformanceAdvanced.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The Advanced Performance menu.
//
// 11/05/12 JWB     Added FOV slider
///////////////////////////////////////////////////////////////////////////////
//
// This menu allows one to fine tune all exposed details of performance.
//
// Might want to let user know that smoke and fire changes will only affect
// new fire.
//
///////////////////////////////////////////////////////////////////////////////
class MenuPerformanceAdvanced extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var localized String PerformanceTitleText;

const c_fUnitsPerMeter		= 80.0;	// Our dude is 160 units tall so that's 80 units per meter.
const c_fMinFogMeters		= 40.0;
const c_fMaxFogMeters		= 200.0;
const c_fFogStepMeters		= 5.0;
const c_fFogOffValue		= 50000.0;
const c_fDefaultFogValue	= 8000.0;
const c_fMinSnipeFogValue   = 8000.0;

var UWindowHSliderControl GenEndSlider;
var localized string GenEndText;
var localized string GenEndHelp;
const GenFogStartPath		= "Postal2Game.P2GameInfo GeneralFogStart";
const GenFogEndPath			= "Postal2Game.P2GameInfo GeneralFogEnd";
const GenFogStartRatio		= 0.15;

const SnipeToGenRatio		= 2.0;	// Ratio of sniper end to general end.
const SnipeFogStartPath		= "Postal2Game.P2GameInfo SniperFogStart";
const SnipeFogEndPath		= "Postal2Game.P2GameInfo SniperFogEnd";
const SnipeFogStartRatio	= 0.15;

var UWindowCheckbox  InfiniteViewCheckbox;
var localized string InfiniteViewText;
var localized string InfiniteViewHelp;

var UWindowHSliderControl SmokeSlider;
var localized string SmokeText;
var localized string SmokeHelp;
const SmokeSliderPath = "Postal2Game.P2GameInfo SmokeDetail";

var UWindowHSliderControl FireSlider;
var localized string FireText;
var localized string FireHelp;
const FireSliderPath = "Postal2Game.P2GameInfo FireDetail";

// Shadows cause crashes so they are temporarily disabled
//var UWindowHSliderControl ShadowSlider;
var localized string ShadowText;
var localized string ShadowHelp;
const ShadowSliderPath = "Postal2Game.P2GameInfo ShadowDetail";

var UWindowCheckbox BloodSpoutCheckbox;
var localized string BloodSpoutText;
var localized string BloodSpoutHelp;
const BloodSpoutCheckboxPath = "Postal2Game.P2GameInfo BloodSpouts";

// This doesn't do anything! It's used in the game code!
//var UWindowHSliderControl WorldDetailSlider;
var localized string WorldDetailSliderText;
var localized string WorldDetailSliderHelp;
const WorldDetailSliderPath = "Postal2Game.P2GameInfo WorldDetail";

var localized array<string> astrDetailVals3;
var localized array<string> astrDetailVals4;

var UWindowHSliderControl TextureDetailWorldSlider;
var localized string TextureDetailWorldText;
var localized string TextureDetailWorldHelp;
const TextureDetailWorldSliderPath = "ini:Engine.Engine.ViewportManager TextureDetailWorld";
const TextureDetailWorldSliderPath2 = "ini:Engine.Engine.ViewportManager TextureDetailTerrain";

var UWindowHSliderControl TextureDetailSkinSlider;
var localized string TextureDetailSkinText;
var localized string TextureDetailSkinHelp;
const TextureDetailSkinSliderPath = "ini:Engine.Engine.ViewportManager TextureDetailSkin";
const TextureDetailSkinSliderPath2 = "ini:Engine.Engine.ViewportManager TextureDetailWeapon";

var UWindowHSliderControl TextureDetailLightmapSlider;
var localized string TextureDetailLightmapText;
var localized string TextureDetailLightmapHelp;
const TextureDetailLightmapSliderPath = "ini:Engine.Engine.ViewportManager TextureDetailLightmap";

var UWindowCheckbox WorldDetailObjsCheckbox;
var localized string WorldDetailObjsText;
var localized string WorldDetailObjsHelp;
const WorldDetailObjsPath = "Engine.GameInfo bGameHighDetail";
var localized string WorldDetailObjsWarningTitle;
var localized string WorldDetailObjsWarningText;

//var UWindowCheckbox GameDetailCheckbox;
var localized string GameDetailText;
var localized string GameDetailHelp;
const GameDetailPath = "Postal2Game.P2GameInfo HighDetail";

// Dynamic lights on guns has some bugs and hasn't been fully tested so it's been temporarily removed
//var UWindowCheckbox DynamicLightsCheckbox;
var localized string DynamicLightsText;
var localized string DynamicLightsHelp;
const DynamicLightsCheckPath = "Postal2Game.P2GameInfo DynamicWeaponLights";

var UWindowHSliderControl DecalSlider;
var localized string DecalText;
var localized string DecalHelp;
const DecalSliderPath = "Postal2Game.P2GameInfo SplatDetail";

var UWindowHSliderControl FluidSlider;
var localized string FluidText;
var localized string FluidHelp;
const FluidSliderPath = "Postal2Game.P2GameInfo FluidDetail";
var localized string FluidSliderWarningTitle;
var localized string FluidSliderWarningText;

// Turn off all projectors all together
var UWindowCheckbox ProjectorsCheckbox;
var localized string ProjectorsText;
var localized string ProjectorsHelp;
const ProjectorsCheckboxPath = "Engine.Projector bUseProjectors";

var UWindowHSliderControl BodiesSlider;
var localized string BodiesSliderText;
var localized string BodiesSliderHelp;
const BodiesSliderPath = "Postal2Game.P2GameInfo BodiesSliderMax";

var UWindowHSliderControl PawnSlider;
var localized string PawnText;
var localized string PawnHelp;
const PawnSliderPath = "Postal2Game.P2GameInfo SliderPawnGoal";
var bool bChangedPawnSlider;
var localized string PawnSliderChangedWarningTitle, PawnSliderChangedWarningText;

var UWindowHSliderControl RagdollSlider;
var localized string RagdollText;
var localized string RagdollHelp;
const RagdollSliderPath = "Postal2Game.P2Player RagdollMax";

// 11/05/12 JWB AF Combo
var UWindowComboControl AnisotropyCombo;
var localized string AnisotropyText;
var localized string AnisotropyHelp;
const AnisotropyComboPath = "ini:Engine.Engine.RenderDevice LevelOfAnisotropy";
var string AnisotropyLevel[5];

// 11/05/12 JWB FOV slider
var UWindowHSliderControl FOVSlider;
var localized string FOVText;
var localized string FOVHelp;
const FOVSliderPath = "Engine.PlayerController DefaultFOV";

// 11/05/13 JWB Detail Texture
var UWindowCheckbox DetailTextureCheckbox;
var localized string DetailTextureText;
var localized string DetailTextureHelp;
const DetailTextureCheckBoxPath = "ini:Engine.Engine.RenderDevice DetailTextures";

// 11/19 Dismemberment Toggle
var UWindowCheckbox DismembermentCheckbox;
var localized string DismembermentText;
var localized string DismembermentHelp;
const DismembermentCheckBoxPath = "Postal2Game.P2GameInfo bEnableDismemberment";

// Dismemberment Physics
var UWindowCheckbox DismembermentPCheckbox;
var localized string DismembermentPText;
var localized string DismembermentPHelp;
const DismembermentPCheckBoxPath = "Postal2Game.P2GameInfo bEnableDismembermentPhysics";

// 12/20 Bolton Toggle
var UWindowCheckbox BoltonCheckbox;
var localized string BoltonText, BoltonHelp;
const BoltonCheckBoxPath = "GameTypes.ChameleonPlus bUseExtendedBoltons";
var localized string BoltonChangedWarningTitle, BoltonChangedWarningText;

// Needed to turn off shadows if they're not on d3d (for now!)
//const RenderDevicePath = "ini:Engine.Engine RenderDevice";

// Shadows
var UWindowCheckbox SimpleShadowsCheckbox;
var localized string SimpleShadowsText;
var localized string SimpleShadowsHelp;
const SimpleShadowsCheckBoxPath = "Postal2Game.P2GameInfo bSimpleShadows";

// In future, if we want to add shadows the various objects, we'll let them
// pick what objects they want shadows on
// Player (P2Pawn) Shadows Path
const PlayerShadowsCheckBoxPath = "Postal2Game.P2GameInfo bPlayerShadows";

var localized string	PerformanceWarningTitle;
var localized string	PerformanceWarningText;
var localized string MapChangeWarningTitle;
var localized string MapChangeWarningText;

var localized string LimitTexturesTitle;
var localized string LimitTexturesText;

var bool bUpdate;
var bool bAsk;

const	FOG_SPREAD = 1000;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	TitleAlign = TA_Center;
	AddTitle(PerformanceTitleText, TitleFont, TitleAlign);

	// 12/17/02 NPF Use a smaller font than was set by the base class.
	ItemFont	= F_FancyM;

	GenEndSlider   = AddSlider(GenEndText,   GenEndHelp,   ItemFont, 0, 1);
	GenEndSlider  .SetRange(c_fMinFogMeters, c_fMaxFogMeters, c_fFogStepMeters);	// Have to reset range to set step.  Can reach in to Step field but this function makes sure the value is set to a step.
	InfiniteViewCheckbox = AddCheckbox(InfiniteViewText, InfiniteViewHelp, ItemFont);	// 01/19/03 JMI Added to disable fog.
	//TextureDetailWorldSlider = AddSlider(TextureDetailWorldText, TextureDetailWorldHelp, ItemFont, 1, 3);	// Don't allow lower than 1 or engine will crash
	//TextureDetailWorldSlider.SetVals(astrDetailVals4);
	//TextureDetailSkinSlider = AddSlider(TextureDetailSkinText, TextureDetailSkinHelp, ItemFont, 1, 3);	// Don't allow lower than 1 or engine will crash
	//TextureDetailSkinSlider.SetVals(astrDetailVals4);
	//TextureDetailLightmapSlider = AddSlider(TextureDetailLightmapText, TextureDetailLightmapHelp, ItemFont, 1, 3);	// Don't allow lower than 1 or engine will crash
	//TextureDetailLightmapSlider.SetVals(astrDetailVals4);
	//GameDetailCheckbox = AddCheckbox(GameDetailText, GameDetailHelp, ItemFont);
	//WorldDetailSlider = AddSlider(WorldDetailSliderText, WorldDetailSliderHelp, ItemFont, 0, 1);
	//ShadowSlider = AddSlider(ShadowText, ShadowHelp, ItemFont, 0, 2);
	//ShadowSlider.SetVals(astrDetailVals3);
	//DynamicLightsCheckbox = AddCheckbox(DynamicLightsText, DynamicLightsHelp, ItemFont);
	FireSlider = AddSlider(FireText, FireHelp, ItemFont, 0, 10);
	SmokeSlider = AddSlider(SmokeText, SmokeHelp, ItemFont, 0, 10);
	BloodSpoutCheckbox = AddCheckbox(BloodSpoutText, BloodSpoutHelp, ItemFont);
	DecalSlider = AddSlider(DecalText, DecalHelp, ItemFont, 0, 10);
	FluidSlider = AddSlider(FluidText, FluidHelp, ItemFont, 1, 11);
	//ProjectorsCheckbox = AddCheckbox(ProjectorsText, ProjectorsHelp, ItemFont);
	PawnSlider = AddSlider(PawnText, PawnHelp, ItemFont, 0, 30);
	bChangedPawnSlider = false;
	BodiesSlider = AddSlider(BodiesSliderText, BodiesSliderHelp, ItemFont, 0, 200);
	RagdollSlider = AddSlider(RagdollText, RagdollHelp, ItemFont, 0, 10);
	AnisotropyCombo = AddComboBox(AnisotropyText, AnisotropyHelp, ItemFont);
    FOVSlider = AddSlider(FOVText, FOVHelp, ItemFont, 80, 110);
    DetailTextureCheckbox = AddCheckbox(DetailTextureText, DetailTextureHelp, ItemFont);
    DismembermentCheckbox = AddCheckbox(DismembermentText, DismembermentHelp, ItemFont);
    DismembermentPCheckbox = AddCheckbox(DismembermentPText, DismembermentPHelp, ItemFont);
    BoltonCheckbox = AddCheckbox(BoltonText, BoltonHelp, ItemFont);
	//SimpleShadowsCheckbox = AddCheckbox(SimpleShadowsText, SimpleShadowsHelp, ItemFont);
	
	// 02/16/03 JMI Moved to bottom--this is where the other quantitative values are and this is one
	//				we prefer they don't turn off so it's last.
	//WorldDetailObjsCheckbox = AddCheckbox(WorldDetailObjsText, WorldDetailObjsHelp, ItemFont);

	RestoreChoice	= AddChoice(RestoreText,	RestoreHelp,	ItemFont, ItemAlign);
	BackChoice		= AddChoice(BackText,		"",				ItemFont, ItemAlign, true);

	LoadValues();
	}

function GoBack()
{
	Super.GoBack();

	// If they changed the pawn slider, say something about it here
	if (bChangedPawnSlider)
		ShowWarning(PawnSliderChangedWarningTitle, PawnSliderChangedWarningText);
}
	
///////////////////////////////////////////////////////////////////////////////
// Display performance warning.
// 01/25/03 JMI Started.
///////////////////////////////////////////////////////////////////////////////
function ShowWarning(string strTitle, string strMsg)
{
	if (bAsk)
	{
		MessageBox(strTitle, strMsg, MB_OK, MR_OK, MR_OK);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Set all values to defaults
///////////////////////////////////////////////////////////////////////////////
function SetDefaultValues()
	{
	local float val;
	local String detail;

	bAsk = false;

	// Restore the previous saved default values.
	RestoreDefaultValues();

	bAsk = true;

	// Now that we've restored the values, update the UI.
	LoadValues();
	}

///////////////////////////////////////////////////////////////////////////////
// Load all values from ini files
///////////////////////////////////////////////////////////////////////////////
function LoadValues()
	{
	local int		Index;
	local float val;
	local bool flag;
	local String detail;
	local int    iDef;

	// Store the values that need to be restored when the restore choice is chosen.
	// Note that we initialize the array here b/c the defaultproperties doesn't support
	// constants which is ridiculous.
	aDefaultPaths[iDef++] = GenFogStartPath;
	aDefaultPaths[iDef++] = GenFogEndPath;
	aDefaultPaths[iDef++] = SnipeFogStartPath;
	aDefaultPaths[iDef++] = SnipeFogEndPath;
	aDefaultPaths[iDef++] = SmokeSliderPath;
	aDefaultPaths[iDef++] = FireSliderPath;
	aDefaultPaths[iDef++] = BloodSpoutCheckboxPath;
	aDefaultPaths[iDef++] = DecalSliderPath;
	aDefaultPaths[iDef++] = FluidSliderPath;
	aDefaultPaths[iDef++] = PawnSliderPath;
	aDefaultPaths[iDef++] = BodiesSliderPath;
	aDefaultPaths[iDef++] = RagdollSliderPath;
    aDefaultPaths[iDef++] = AnisotropyComboPath;
    aDefaultPaths[iDef++] = FOVSliderPath;
    aDefaultPaths[iDef++] = DetailTextureCheckBoxPath;
	aDefaultPaths[iDef++] = DismembermentCheckBoxPath;
	aDefaultPaths[iDef++] = DismembermentPCheckBoxPath;
	aDefaultPaths[iDef++] = BoltonCheckBoxPath;
	StoreDefaultValues();

	bUpdate = False;
	bAsk = false;

	val = float(GetPlayerOwner().ConsoleCommand("get" @ GenFogEndPath));
	GenEndSlider.SetValue(Units2Meters(val) );

	InfiniteViewCheckbox.SetValue(val == c_fFogOffValue);

	// Value 0 to 10
	val = float(GetPlayerOwner().ConsoleCommand("get" @ FireSliderPath));
	FireSlider.SetValue(val);

	// Value 0 to 10
	val = float(GetPlayerOwner().ConsoleCommand("get" @ SmokeSliderPath));
	SmokeSlider.SetValue(val);

	// Value 0 or 1
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ BloodSpoutCheckboxPath));
	BloodSpoutCheckbox.SetValue(flag);

	// Value 0-10
	val = float(GetPlayerOwner().ConsoleCommand("get" @ DecalSliderPath));
	DecalSlider.SetValue(val);

	// Value 1-11
	val = float(GetPlayerOwner().ConsoleCommand("get" @ FluidSliderPath));
	FluidSlider.SetValue(val);

	// Value 0-50
	val = float(GetPlayerOwner().ConsoleCommand("get" @ PawnSliderPath));
	PawnSlider.SetValue(val);

	// Value 0 or 200
	val = float(GetPlayerOwner().ConsoleCommand("get" @ BodiesSliderPath));
	BodiesSlider.SetValue(val);

	// Value 0-10
	val = float(GetPlayerOwner().ConsoleCommand("get" @ RagdollSliderPath));
	RagdollSlider.SetValue(val);

	// Anisotropic Filtering
	AnisotropyCombo.Clear();
	    for(Index = 0; Index < ArrayCount(AnisotropyLevel); Index++)
		{
	        AnisotropyCombo.AddItem(AnisotropyLevel[Index]);
		}
    AnisotropyCombo.SetValue(GetPlayerOwner().ConsoleCommand("get" @ AnisotropyComboPath));

    // Value from 80 - 110
    val = float(GetPlayerOwner().ConsoleCommand("get" @ FOVSliderPath));
	FOVSlider.SetValue(val);

	// Value is a boolean
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ DetailTextureCheckBoxPath) );
	DetailTextureCheckbox.SetValue(flag);

	// Value is bool
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ DismembermentCheckBoxPath));
	DismembermentCheckBox.SetValue(Flag);

	// Value is bool
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ DismembermentPCheckBoxPath));
	DismembermentPCheckBox.SetValue(Flag);

	// Value is bool
	flag = bool(GetPlayerOwner().ConsoleCommand("get" @ BoltonCheckBoxPath));
	BoltonCheckBox.SetValue(Flag);

	bUpdate = True;
	bAsk    = true;
	}

///////////////////////////////////////////////////////////////////////////////
// Callback for when control has changed
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);

	switch (E)
		{
		case DE_Change:
			switch (C)
				{
				case InfiniteViewCheckbox:
					InfiniteViewCheckboxChanged();
					break;
				case GenEndSlider:
					GenEndSliderChanged();
					break;

				case SmokeSlider:
					SmokeSliderChanged();
					break;
				case FireSlider:
					FireSliderChanged();
					break;
				//case ShadowSlider:
				//	ShadowSliderChanged();
				//	break;
				case BloodSpoutCheckbox:
					BloodSpoutCheckboxChanged();
					break;
				//case WorldDetailSlider:
				//	WorldDetailSliderChanged();
				//	break;
				//case TextureDetailWorldSlider:
					//TextureDetailWorldSliderChanged();
					//break;
				//case TextureDetailSkinSlider:
					//TextureDetailSkinSliderChanged();
					//break;
				//case TextureDetailLightmapSlider:
					//TextureDetailLightmapSliderChanged();
					//break;
				//case GameDetailCheckbox:
				//	GameDetailCheckboxChanged();
				//	break;
				//case DynamicLightsCheckbox:
				//	DynamicLightsCheckboxChanged();
				//	break;
				//case WorldDetailObjsCheckbox:
				//	WorldDetailObjsCheckboxChanged();
				//	break;
				case DecalSlider:
					DecalSliderChanged();
					break;
				case FluidSlider:
					FluidSliderChanged();
					break;
				//case ProjectorsCheckbox:
				//	ProjectorsCheckboxChanged();
				//	break;
				case PawnSlider:
					PawnSliderChanged();
					break;
				case BodiesSlider:
					BodiesSliderChanged();
					break;
				case RagdollSlider:
					RagdollSliderChanged();
					break;
				case AnisotropyCombo:
					AnisotropyComboChanged();
					break;
                case FOVSlider:
					FOVSliderChanged();
					break;
                case DetailTextureCheckbox:
					DetailTextureCheckboxChanged();
					break;
				case SimpleShadowsCheckbox:
				    SimpleShadowsCheckboxChanged();
				    break;
				case DismembermentCheckBox:
					DismembermentCheckBoxChanged();
					break;
				case DismembermentPCheckBox:
					DismembermentPCheckBoxChanged();
					break;
				case BoltonCheckbox:
					BoltonCheckBoxChanged();
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case RestoreChoice:
					SetDefaultValues();
					break;
				}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Convert a fog value in units to meters.
// 01/19/03 JMI Started.
///////////////////////////////////////////////////////////////////////////////
function float Units2Meters(float fFogVal)
{
	// How about 40 meters (3,200 units) as the min and 200 meters (16,000 units) as the max.  5 meter (400 unit) increments seem nice, but that's 32 increments total.  That sounds like too many tick marks?  If it doesn't work, maybe use 16 tick marks but they can still increment it to the in-between values (that works now, I just don't know if anyone will know it).  Ick, this is the only bad part.
	return fFogVal / c_fUnitsPerMeter;
}

///////////////////////////////////////////////////////////////////////////////
// Convert a distance in meters to a fog value in units.
// 01/19/03 JMI Started.
///////////////////////////////////////////////////////////////////////////////
function float Meters2Units(float fFogMeters)
{
	return fFogMeters * c_fUnitsPerMeter;
}

///////////////////////////////////////////////////////////////////////////////
// Update values when controls have changed.
// - only update the real value if bUpdate is true
// - only ask for user confirmation if bAsk is true
///////////////////////////////////////////////////////////////////////////////
function InfiniteViewCheckboxChanged()
{
	if (bUpdate)
	{
		if (InfiniteViewCheckbox.bChecked)
		{
			GetPlayerOwner().ConsoleCommand("set" @ GenFogEndPath @ c_fFogOffValue);
			GetPlayerOwner().ConsoleCommand("set" @ GenFogStartPath @ c_fFogOffValue);
			GetPlayerOwner().ConsoleCommand("set" @ SnipeFogEndPath @ c_fFogOffValue);
			GetPlayerOwner().ConsoleCommand("set" @ SnipeFogStartPath @ c_fFogOffValue);

			ShowWarning(PerformanceWarningTitle, PerformanceWarningText);

			// Update the fog now, in the level the player is in
			P2GameInfo(GetPlayerOwner().Level.Game).SetZoneFogPlanes();
			P2GameInfo(GetPlayerOwner().Level.Game).SetSniperZoneFog(GetPlayerOwner());
		}
		else
		{
			// Set to defaults when enabled.
			GenEndSlider.SetValue(Units2Meters(c_fDefaultFogValue) );
			GenEndSliderChanged();
		}
	}
}

function GenEndSliderChanged()
{
	local float fUnits;
	if (bUpdate)
	{
		fUnits = Meters2Units(GenEndSlider.GetValue() );

		GetPlayerOwner().ConsoleCommand("set" @ GenFogEndPath @ fUnits);
		GetPlayerOwner().ConsoleCommand("set" @ GenFogStartPath @ fUnits * GenFogStartRatio);

		fUnits = FClamp(fUnits * SnipeToGenRatio, c_fMinSnipeFogValue, Meters2Units(c_fMaxFogMeters) );	// 02/16/03 JMI Calculate sniper value from general value.
		GetPlayerOwner().ConsoleCommand("set" @ SnipeFogEndPath @ fUnits);
		GetPlayerOwner().ConsoleCommand("set" @ SnipeFogStartPath @ fUnits * SnipeFogStartRatio);

		// Update the fog now, in the level the player is in
		P2GameInfo(GetPlayerOwner().Level.Game).SetZoneFogPlanes();
		P2GameInfo(GetPlayerOwner().Level.Game).SetSniperZoneFog(GetPlayerOwner());

		// If the slider was changed, enable the fog checkbox.
		bUpdate = false;
		InfiniteViewCheckbox.SetValue(false);
		bUpdate = true;
	}
}

function SmokeSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ SmokeSliderPath @ SmokeSlider.GetValue());
	}

function FireSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ FireSliderPath @ FireSlider.GetValue());
	}

/*
function ShadowSliderChanged()
{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ ShadowSliderPath @ ShadowSlider.GetValue());
		ShowWarning(PerformanceWarningTitle, PerformanceWarningText);	// 02/02/03 JMI Added.
	}
}
*/
function BloodSpoutCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		if (BloodSpoutCheckbox.bChecked)
			val = 1;
		GetPlayerOwner().ConsoleCommand("set" @ BloodSpoutCheckboxPath @ val);
		}
	}
/*
function WorldDetailSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ WorldDetailSliderPath @ WorldDetailSlider.GetValue());
	}
*/
function TextureDetailWorldSliderChanged()
	{
	local bool bDontSet;
	if (bUpdate)
		{
		if(GetLevel().IsDemoBuild())
			{
			if(TextureDetailWorldSlider.GetValue() > 2)
				{
				MessageBox(LimitTexturesTitle, LimitTexturesText, MB_OK, MR_OK, MR_OK);
				TextureDetailWorldSlider.SetValue(2);
				bDontSet=true;
				}
			}

		if(!bDontSet)
			{
			GetPlayerOwner().ConsoleCommand("set" @ TextureDetailWorldSliderPath @ DetailValToName(TextureDetailWorldSlider.GetValue()));
			GetPlayerOwner().ConsoleCommand("set" @ TextureDetailWorldSliderPath2 @ DetailValToName(TextureDetailWorldSlider.GetValue()));
			GetPlayerOwner().ConsoleCommand("flush");
			}
		}
	}

function TextureDetailSkinSliderChanged()
	{
	if (bUpdate)
		{
		// Allow the full range of character skin settings in demo
		GetPlayerOwner().ConsoleCommand("set" @ TextureDetailSkinSliderPath @ DetailValToName(TextureDetailSkinSlider.GetValue()));
		GetPlayerOwner().ConsoleCommand("set" @ TextureDetailSkinSliderPath2 @ DetailValToName(TextureDetailSkinSlider.GetValue()));
		GetPlayerOwner().ConsoleCommand("flush");
		}
	}

function TextureDetailLightmapSliderChanged()
	{
	local bool bDontSet;

	if (bUpdate)
		{
		if(GetLevel().IsDemoBuild())
			{
			if(TextureDetailLightmapSlider.GetValue() > 2)
				{
				MessageBox(LimitTexturesTitle, LimitTexturesText, MB_OK, MR_OK, MR_OK);
				TextureDetailLightmapSlider.SetValue(2);
				bDontSet=true;
				}
			}

		if(!bDontSet)
			{
			GetPlayerOwner().ConsoleCommand("set" @ TextureDetailLightmapSliderPath @ DetailValToName(TextureDetailLightmapSlider.GetValue()));
			GetPlayerOwner().ConsoleCommand("flush");
			}
		}
	}
/*
function GameDetailCheckboxChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ GameDetailPath @ GameDetailCheckbox.bChecked);
	}
*/
/*
function DynamicLightsCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		{
		if (DynamicLightsCheckbox.bChecked)
			val = 1;
		GetPlayerOwner().ConsoleCommand("set" @ DynamicLightsCheckboxPath @ val);
		}
	}
*/
function WorldDetailObjsCheckboxChanged()
	{
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set" @ WorldDetailObjsPath @ WorldDetailObjsCheckbox.bChecked);
		// Warn about looking like crap--so they know exactly what they did that made everything look bad.
		if (WorldDetailObjsCheckbox.bChecked == false)
			ShowWarning(WorldDetailObjsWarningTitle, WorldDetailObjsWarningText);
		}
	}
function DecalSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ DecalSliderPath @ DecalSlider.GetValue());
	}
function FluidSliderChanged()
	{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ FluidSliderPath @ FluidSlider.GetValue());
		// Warn if we set this to infinite.
		if (FluidSlider.GetValue() == 11)
			ShowWarning(FluidSliderWarningTitle, FluidSliderWarningText);
	}
	}
function ProjectorsCheckboxChanged()
	{
	local int val;

	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ ProjectorsCheckboxPath @ ProjectorsCheckbox.bChecked);
	}
function PawnSliderChanged()
	{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ PawnSliderPath @ PawnSlider.GetValue());
		bChangedPawnSlider = true;
	}
	}
function BodiesSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ BodiesSliderPath @ BodiesSlider.GetValue());
	}
function RagdollSliderChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ RagdollSliderPath @ RagdollSlider.GetValue());
	}
function FOVSliderChanged()
	{
	if (bUpdate)
    {
		GetPlayerOwner().ConsoleCommand("set" @ FOVSliderPath @ FOVSlider.GetValue());
        GetPlayerOwner().ConsoleCommand("fov" @FOVSlider.GetValue());   // 11/05/12 JWB Setting the ini doesn't set the current fov, so do it now.
    }
    }
function AnisotropyComboChanged()
	{
	local string SameRes;
	if (bUpdate)
		{
		GetPlayerOwner().ConsoleCommand("set" @ AnisotropyComboPath @ AnisotropyCombo.GetValue());
	    //GetPlayerOwner().ConsoleCommand("FLUSH");
	    // This setting only works if you reset the resolution..
	    SameRes = GetPlayerOwner().ConsoleCommand("GetCurrentRes");
	    // Switch to the new res
	    GetPlayerOwner().ConsoleCommand("SetRes "$SameRes);

		}
	}
function DetailTextureCheckboxChanged()
	{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ DetailTextureCheckBoxPath @ DetailTextureCheckbox.bChecked);
	}

function SimpleShadowsCheckboxChanged()
	{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ SimpleShadowsCheckBoxPath @ SimpleShadowsCheckbox.bChecked);
		// Just set PlayerShadows when Simple Shadows are enabled. Until we upgrade and organize
		// performance menu.
		GetPlayerOwner().ConsoleCommand("set" @ PlayerShadowsCheckBoxPath @ SimpleShadowsCheckbox.bChecked);
	}
	}

function DismembermentCheckBoxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ DismembermentCheckBoxPath @ DismembermentCheckBox.bChecked);
}
function DismembermentPCheckBoxChanged()
{
	if (bUpdate)
		GetPlayerOwner().ConsoleCommand("set" @ DismembermentPCheckBoxPath @ DismembermentPCheckBox.bChecked);
}
function BoltonCheckBoxChanged()
{
	if (bUpdate)
	{
		GetPlayerOwner().ConsoleCommand("set" @ BoltonCheckBoxPath @ BoltonCheckBox.bChecked);
		ShowWarning(BoltonChangedWarningTitle, BoltonChangedWarningText);
	}
}

///////////////////////////////////////////////////////////////////////////////
// default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	PerformanceTitleText="Performance"
	GenEndText="Max Fog Visibility (Meters)"
	GenEndHelp="Fog hides everything past this distance.  Lower values give better performance."
	InfiniteViewText="Infinite Visibility"
	InfiniteViewHelp="Lets you see everything no matter how far away.  Turn off for greatly improved performance."
	SmokeText="Smoke Effects Density"
	SmokeHelp="Controls density of smoke effects.  Lower values improve performance."
	FireText="Fire Effects Density"
	FireHelp="Controls density of fire effects.  Lower values improve performance."
	ShadowText="Character Shadows"
	ShadowHelp="Controls character shadows, which require very fast hardware.  Turn off to grealy improve performance."
	BloodSpoutText="Blood Spout Effects"
	BloodSpoutHelp="Controls whether blood squirts out.  Turn off to slightly improve performance."
	WorldDetailSliderText="World detail"
	WorldDetailSliderHelp="Controls number of objects in world.  Lower values improve performance."
	astrDetailVals3(0)="off"
	astrDetailVals3(1)="low"
	astrDetailVals3(2)="high"
	astrDetailVals4(0)="very low"
	astrDetailVals4(1)="low"
	astrDetailVals4(2)="medium"
	astrDetailVals4(3)="high"
	TextureDetailWorldText="World Texture Detail"
	TextureDetailWorldHelp="Controls detail level of world textures.  Lower values improve performance."
	TextureDetailSkinText="Character Texture Detail"
	TextureDetailSkinHelp="Controls detail level of character skins.  Lower values improve performance."
	TextureDetailLightmapText="Lightmap Texture Detail"
	TextureDetailLightmapHelp="Controls detail level of lightmaps.  Lower values improve performance."
	WorldDetailObjsText="World Detail Objects"
	WorldDetailObjsHelp="Controls non-essential objects like plants, trees, and furniture that make the world look good"
	WorldDetailObjsWarningTitle="Warning"
	WorldDetailObjsWarningText="The game will look totally barren without these objects.  Only turn this off as a last resort."
	GameDetailText="High Game Detail"
	GameDetailHelp="Controls high-end effects/visuals/people.  Turn off to improve performance."
	DynamicLightsText="Dynamic Weapon Lights"
	DynamicLightsHelp="Guns use dynamic lighting when shooting"
	DecalText="Decal Lifetime"
	DecalHelp="Controls how long blood splats and bullet holes last.  Lower values improve performance."
	FluidText="Fluid Lifetime"
	FluidHelp="Controls how long fluid trails last (such as urine, gasoline, blood).  Lower values improve performance but may adversely affect gameplay."
	ProjectorsText="Allow Projectors"
	ProjectorsHelp="Controls all projectors (grafitti, etc.) in game"
	BodiesSliderText="Corpse Population"
	BodiesSliderHelp="Controls max number of corpses before older ones are removed.  Lower values improve performance."
	PawnText="Bystander Population"
	PawnHelp="Controls number of bystanders.  Lower values improve performance."
	RagdollText="Ragdolls"
	RagdollHelp="Controls max number of simultaneous ragdoll physics. Lower values improve performance."
	AnisotropyText="Anisotropic Filtering"
	AnisotropyHelp="Filters out distance textures to make them appear more crisp. Has a minimal performance impact."
	FOVText="Field of Vision"
	FOVHelp="Controls the viewing angle. if you are experiencing motion sickness, try increasing this. Lower values improve performance."
	DetailTextureText="Detail Textures"
	DetailTextureHelp="Renders a texture over existing textures to increase detail.  Turn off to improve performance."
	SimpleShadowsText="(DEBUG) Simple Shadows"
	SimpleShadowsHelp="(DEBUG) Renders simple shadows on NPCs.  Turn off to greatly improve performance. WARNING: Currently broken on OPENGL"
	DismembermentText="Dismemberment"
	DismembermentHelp="Allows AW-style dismemberment of legs, arms, torsos, etc.  Turn off to improve performance."
	DismembermentPText="Dismemberment Physics"
	DismembermentPHelp="Enables physics on dismembered limbs. Turn off if you experience crashes."
	BoltonText="Accessories"
	BoltonHelp="Accessorizes characters with hats, glasses, etc.  Turn off to improve performance."
	PerformanceWarningTitle="Warning"
	PerformanceWarningText="Enabling this option could seriously impact performance"
	MapChangeWarningTitle="Warning"
	MapChangeWarningText="This option will not take effect until the next level transition"
	LimitTexturesTitle="Limited texture Detail"
	LimitTexturesText="To reduce demo memory size, the highest texture detail quality is not allowed in the demo version. The full version of the game allows this highest detail setting."
	MenuWidth=620.000000
	BorderLeft=15.000000
	BorderRight=15.000000
	TitleSpacingY=5.000000
	ItemHeight=22.000000
	ItemSpacingY=0.000000
	HintLines=3
	astrTextureDetailNames(0)="UltraLow"
	astrTextureDetailNames(1)="Low"
	astrTextureDetailNames(2)="Medium"
	astrTextureDetailNames(3)="High"
	bDefaultsStored=True
	aDefaultValues(0)="1000"
	aDefaultValues(1)="8000"
	aDefaultValues(2)="1000"
	aDefaultValues(3)="8000"
	aDefaultValues(4)="8"
	aDefaultValues(5)="8"
	aDefaultValues(6)="1"
	aDefaultValues(7)="4"
	aDefaultValues(8)="5"
	aDefaultValues(9)="15"
	aDefaultValues(10)="25"
	aDefaultValues(11)="10"
	aDefaultValues(12)="1"
	aDefaultValues(13)="85"
	aDefaultValues(14)="True"
	aDefaultValues(15)="True"
	aDefaultValues(16)="True"
	aDefaultValues(17)="True"
	AnisotropyLevel(0)="1"
	AnisotropyLevel(1)="2"
	AnisotropyLevel(2)="4"
	AnisotropyLevel(3)="8"
	AnisotropyLevel(4)="16"
	PawnSliderChangedWarningTitle="Information"
	PawnSliderChangedWarningText="Changes to the bystander population may not take effect until the next level transition"
	BoltonChangedWarningTitle="Information"
	BoltonChangedWarningText="Change will not take effect until the next level transition"
	FluidSliderWarningTitle="Warning"
	FluidSliderWarningText="This setting makes fluid trails near-infinite and could adversely affect performance"
}
