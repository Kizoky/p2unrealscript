///////////////////////////////////////////////////////////////////////////////
// BucketWeapon
// Copyright 2014, Running With Scissors, Inc.
//
// Weapon used for milking cows
///////////////////////////////////////////////////////////////////////////////
class BucketWeapon extends P2WeaponStreaming;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, enums, etc
///////////////////////////////////////////////////////////////////////////////
var() Material MilkTex;			// Material of milk level
var() Color ProgressBarColor;	// Color of milk percentage bar.
var() localized string HudHint_GetCloser1, HudHint_GetCloser2, HudHint_GetCloser3;	// HUD hints encouraging the player to move in closer to the cow.
var() localized string HudHint_NoMilk1, HudHint_NoMilk2;		// HUD hints reminding the player that the cow is out of milk.
var() localized string HudHint_StopWalking1, HudHint_StopWalking2;	// HUD hints reminding the player that he can't milk while walking.
var() array<Sound> MilkingSounds;	// Sounds made while milking

// Variables to trigger a "halfway point" event
var float SecondaryMilkRequired;
var name SecondaryEvent;
var bool bSecondaryEventTriggered;

var PLCowPawn MilkingCow;
var Rotator BucketRot;
var float MilkMilked;		// Float value of milk we've milked so far
var float MilkSoundTime;	// Current duration of milking sound, if any
var float MilkSoundDuration;// Expected duration of milking sound

var bool bCowEmpty;		// True if we've commented about this cow being milked dry

var int HintStatus;		// 0 = normal hints, 1 = get closer hints, 2 = no milk hints

const FIND_A_COW_RADIUS = 224.0;
const MILK_COW_DOT = -0.50;
const BUCKET_BONE = 'Bucket';
const MILK_TEX_INDEX = 2;
const MIN_MILK_VELOCITY = 0;

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
// Ensure hint stays on the screen until they figure out how to milk a cow.
///////////////////////////////////////////////////////////////////////////////
function bool GetHints(out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	//InfiniteHintTime = 1;
	switch (HintStatus)
	{
		// 0 = normal hints.
		case 0:
			return Super.GetHints(Str1, Str2, Str3, InfiniteHintTime);
			break;
		// 1 = dude needs to get closer to a cow and face its udders
		case 1:
			str1 = HudHint_GetCloser1;
			str2 = HudHint_GetCloser2;
			str3 = HudHint_GetCloser3;
			return true;
			break;
		// 2 = dude needs to find another cow, this one's dry
		case 2:
			str1 = HudHint_NoMilk1;
			str2 = HudHint_NoMilk2;
			return true;
			break;
		// 3 = dude needs to stop walking before firing
		case 3:
			str1 = HudHint_StopWalking1;
			str2 = HudHint_StopWalking2;
			return true;
			break;
		// Failsafe
		default:
			return false;
	};
	
}

///////////////////////////////////////////////////////////////////////////////
// Play firing animation/sound/etc
///////////////////////////////////////////////////////////////////////////////
simulated function PlayStreamStart()
{
	PlayAnim('Holster', WeaponSpeedPrep, 0.05);
}
simulated function PlayStreamEnd()
{
	PlayAnim('Load', WeaponSpeedEnd, 0.05);
	HintStatus = 0;	// Reset any hints we popped up
	//UpdateHudHints();
	TurnOffHint();
}
simulated function PlayFiring()
{
	IncrementFlashCount();
	// Play MP sounds on everyone's computers
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		PlayOwnedSound(FireSound,SLOT_Interact,1.0,,,WeaponFirePitchStart + (FRand()*WeaponFirePitchRand),false);
	else // just on yours in SP games
		Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, , WeaponFirePitchStart + (FRand()*WeaponFirePitchRand));
	PlayAnim('Milk_Loop', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///////////////////////////////////////////////////////////////////////////////
// Don't allow firing unless the player is standing still
///////////////////////////////////////////////////////////////////////////////
simulated function Fire( float Value )
{
	//log(self$" FIRING");
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ForceFinish();
		return;
	}

	if (VSize(Instigator.Velocity) > MIN_MILK_VELOCITY)
	{
		HintStatus = 3;	// Tell 'em to stop walking
		UpdateHudHints();
		//RefreshHints();
		return;
	}
	else
	{
		HintStatus = 0;
		UpdateHudHints();
	}
		
	ServerFire();

	if ( Role < ROLE_Authority )
	{
		PrepStreaming();
		GotoState('StartStream');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this cow is eligible to be milked
// Must be close enough to the Dude, facing away, and have milk left
///////////////////////////////////////////////////////////////////////////////
function bool CanMilkCow(PLCowPawn CheckCow)
{
	local float DotProduct;
	local Vector Dir;
	
	// check for proximity and milk remaining
	if (VSize(Instigator.Location - CheckCow.Location) < FIND_A_COW_RADIUS)
		//&& CheckCow.CowMilk > 0)
	{
		// check direction. Must be mostly behind the cow
		Dir = Instigator.Location - CheckCow.Location;
		Dir.Z = 0;
		Dir = Normal(Dir);
		DotProduct = Vector(CheckCow.Rotation) dot Dir;
		if (DotProduct <= MILK_COW_DOT)
		{
			// If it's out of milk, maybe make a snarky remark
			if (CheckCow.CowMilk <= 0)
			{
				HintStatus = 2;	// Set hint status to get the dude to find another cow.
				UpdateHudHints();
				//RefreshHints();
				if (!bCowEmpty)
				{
					// Make comment
					P2Player(Instigator.Controller).MyPawn.Say(P2Player(Instigator.Controller).MyPawn.MyDialog.lDude_CowMilking_Empty);
					// Say that we've made a comment, so we don't make it again until the next milking
					bCowEmpty = true;
				}
			}
			else
			{
				// Mark that we've already commented on this cow being out of milk...
				// we only want to comment if the dude tries to go back and milk it again.
				bCowEmpty = true;
				return true;
			}
		}
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Plays various squirts
///////////////////////////////////////////////////////////////////////////////
function PlayMilkingSound(float DeltaTime)
{	
	local int i;
	
	// Keep playing current sound
	if (MilkSoundDuration != 0)
	{
		MilkSoundTime += DeltaTime;
		if (MilkSoundTime > MilkSoundDuration)
			MilkSoundDuration = 0;
	}
	
	// When sound is done play another
	if (MilkSoundDuration == 0)
	{
		i = rand(MilkingSounds.Length);
		MilkSoundDuration = GetSoundDuration(MilkingSounds[i]);
		MilkSoundTime = 0;
		Instigator.PlaySound(MilkingSounds[i]);
		//log("Playing"@MilkingSounds[i]@"Duration"@MilkSoundDuration);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Find a cow and milk it
///////////////////////////////////////////////////////////////////////////////
function MilkACow(float DeltaTime)
{
	local bool bCanMilk;
	
	if (MilkingCow == None)
	{
		// Find a new eligible cow
		foreach VisibleCollidingActors(class'PLCowPawn', MilkingCow, FIND_A_COW_RADIUS, Instigator.Location)
			if (CanMilkCow(MilkingCow))
			{
				bCanMilk = true;
				MilkingCow.BeingMilkedBy(Instigator);
				break;
			}
	}
	else if (CanMilkCow(MilkingCow))
		bCanMilk = true;
		
	// if we got here and hint status isn't 2, it probably means there's no cow in range
	if (MilkingCow == None && HintStatus != 2)
	{
		HintStatus = 1;
		UpdateHudHints();
	}
		
	if (bCanMilk)
	{
		// Turn on sounds
		//Instigator.AmbientSound = soundLoop1;
		PlayMilkingSound(DeltaTime);

		// Milk cow
		if (MilkingCow.CowMilk < DeltaTime)
		{
			MilkMilked += MilkingCow.CowMilk;
			//log("MilkMilked += MilkingCow.CowMilk"@MilkingCow.CowMilk@"="@MilkMilked);
			MilkingCow.CowMilk = 0;
		}
		else
		{
			MilkMilked += DeltaTime;
			//log("MilkMilked += DeltaTime"@DeltaTime@"="@MilkMilked);
			MilkingCow.CowMilk -= DeltaTime;
		}
	}
	else
	{
		// Turn off sounds
		//Instigator.AmbientSound = None;
		
		// No valid cow in range. Do nothing
		if (MilkingCow != None)
			MilkingCow.BeingMilkedBy(None);
		MilkingCow = None;
	}
	
	//log("Got here, milkmilked ="@MilkMilked);

	// Add up ammo while milking
	while (MilkMilked >= 0.99)	// This used to be 1.00, but apparently according to While, 1.00 != 1.00. Stupid engine. At least it works fine this way.
	{
		// They've gotten the hang of this, turn off the hint
		//TurnOffHint();
		
		AmmoType.AddAmmo(1);
		//log("1 ammo added ="@AmmoType.AmmoAmount);
		MilkMilked -= 1;
		//log("MilkMilked -= 1 ="@MilkMilked);
		// When full, trigger our event, if any. Cutscene will remove us
		if (AmmoType.AmmoAmount >= AmmoType.MaxAmmo
			&& Event != '')
			TriggerEvent(Event, Self, Instigator);
		// If we've hit a midway point, trigger that too.
		if (SecondaryMilkRequired != 0
			&& SecondaryEvent != ''
			&& !bSecondaryEventTriggered
			&& AmmoType.AmmoAmount >= SecondaryMilkRequired)
		{
			bSecondaryEventTriggered = true;
			TriggerEvent(SecondaryEvent, Self, Instigator);
		}			
	}
}

///////////////////////////////////////////////////////////////////////////////
// we don't shoot things
///////////////////////////////////////////////////////////////////////////////
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	// STUB
}
/*
///////////////////////////////////////////////////////////////////////////////
// Hold the bucket level so our milk won't spill out
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	Super.Tick(dT);
	
	BucketRot.Roll = -Instigator.Controller.Rotation.Pitch;	
	SetBoneRotation(BUCKET_BONE, BucketRot);
}
*/
///////////////////////////////////////////////////////////////////////////////
// Draw percentage bar
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPercBar(Canvas Canvas, float ScreenX, float ScreenY, float Width, float Height, float Border, Color Fore, float Perc)
{
	local float InnerWidth;
	local float InnerHeight;

	Canvas.Style = ERenderStyle.STY_Alpha;

	Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.SetDrawColor(0,0,0,byte(float(Fore.A)*0.75));
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

	InnerWidth = Width - 2 * Border;
	InnerHeight = Height - 2 * Border;

	Canvas.SetPos(ScreenX - (InnerWidth/2), ScreenY + Border);
	Canvas.DrawColor = Fore;
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', InnerWidth * Perc, InnerHeight);
}

///////////////////////////////////////////////////////////////////////////////
// Streaming, make gas come out in this mode
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	simulated function RenderOverlays(Canvas Canvas)
	{
		local float ScreenX, ScreenY, Width, Height, Border, Perc;
		
		if (MilkingCow != None
			&& MilkingCow.CowMilkMax > 0)
		{
			ScreenX = Canvas.SizeX/2;
			ScreenY = Canvas.SizeY*4/5;
			Width = Canvas.SizeX/4;
			Height = Canvas.SizeY/20;
			Border = 2;
			Perc = MilkingCow.CowMilk / MilkingCow.CowMilkMax;
			DrawPercBar(Canvas, ScreenX, ScreenY, Width, Height, Border, ProgressBarColor, Perc);
			Super.RenderOverlays(Canvas);
		}		
	}

	function Tick( float DeltaTime )
	{
		// Cut immediately if you stop early
		if(!Instigator.PressingFire())
			GotoState('EndStream');
		else
		{
			// Find a cow and milk it
			MilkACow(DeltaTime);
		}
	}

	function EndState()
	{
		// If they fill up the bucket past a certain level, turn on the milk texture
		if (AmmoType.AmmoAmount > 0.75*AmmoType.MaxAmmo)
			Skins[MILK_TEX_INDEX] = MilkTex;
			
		// Tell our cow, if any, we're done with them
		if (MilkingCow != None)
			MilkingCow.BeingMilkedBy(None);
			
		Super.EndState();
		ForceEndFire();
	}

	function BeginState()
	{
		Super.BeginState();
		// Reset our milking sounds
		MilkSoundTime = 0;
		MilkSoundDuration = 0;
	}	
Begin:
	// Null out streaming sounds, we only want them to play when the dude is milking
	Sleep(1.0);
	// If the dude tries to milk an "empty" cow for longer than a second, have him comment on it
	bCowEmpty = false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	function BeginState()
	{
		// If instigator doesn't want to fire anymore then we can finally
		// end the whole pouring sequence.
		if (!Instigator.PressingFire())
		{
			if (Owner != None)
				ForceEndFire();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	bNoHudReticle=true
	ItemName="Bucket"
	AmmoName=class'BucketAmmoInv'
	PickupClass=class'BucketPickup'
	AttachmentClass=class'BucketAttachment'
	bMeleeWeapon=true

	Mesh=Mesh'PLBucket.pl_bucket'

	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins[1]=Texture'PL_BucketTex.bucket_unwrap'
	Skins[2]=FinalBlend'PL_BucketTex.NoMalk'
	MilkTex=ConstantColor'PL_BucketTex.malk'
	FirstPersonMeshSuffix="pl_bucket"
	PlayerViewOffset=(X=2.0000,Y=0.000000,Z=-10.0000)
	FireOffset=(X=40.0000,Y=10.000000,Z=-1.00000)

	holdstyle=WEAPONHOLDSTYLE_Carry
	switchstyle=WEAPONHOLDSTYLE_Carry
	firingstyle=WEAPONHOLDSTYLE_Carry

	aimerror=0.000000
	ShakeOffsetMag=(X=1.0,Y=1.0,Z=1.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2
	ShakeRotMag=(X=50.0,Y=50.0,Z=50.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2

	AIRating=0.15
	AutoSwitchPriority=5
	InventoryGroup=0
	GroupOffset=99
	BobDamping=0.975000
	ReloadCount=0
	ViolenceRank=0
	bBumpStartsFight=false
	TraceAccuracy=0.9

	soundStart = None
	soundLoop1 = None
	soundLoop2 = None
	soundEnd = None
	MilkingSounds[0]=Sound'PL-Meadow_SND.Bucket.Milking01'
	MilkingSounds[1]=Sound'PL-Meadow_SND.Bucket.Milking02'
	MilkingSounds[2]=Sound'PL-Meadow_SND.Bucket.Milking03'
	MilkingSounds[3]=Sound'PL-Meadow_SND.Bucket.Milking04'
	MilkingSounds[4]=Sound'PL-Meadow_SND.Bucket.Milking05'
	RecognitionDist=900
	PlayerMeleeDist=200
	NPCMeleeDist=200.0

	WeaponSpeedHolster = 1.5
	WeaponSpeedLoad    = 1.5
	WeaponSpeedReload  = 1.5
	WeaponSpeedShoot1  = 1.0
	WeaponSpeedShoot1Rand=0.2
	WeaponSpeedShoot2  = 1.0

	HudHint1="Get close to the cow's udders"
	HudHint2="and hold %KEY_Fire% to milk it."
	HudHint_GetCloser1="You're not close enough to a cow."
	HudHint_GetCloser2="Move in closer and face the cow's udders"
	HudHint_GetCloser3="before holding %KEY_Fire% to milk it."
	HudHint_NoMilk1="This cow's already been milked dry."
	HudHint_NoMilk2="Go look for another cow to milk."
	HudHint_StopWalking1="You can't milk while you're walking."
	HudHint_StopWalking2="Stand completely still before holding %KEY_Fire%."
	bAllowHints=true
	bShowHints=true
	
	ProgressBarColor=(R=255,G=255,B=255,A=192)
}
