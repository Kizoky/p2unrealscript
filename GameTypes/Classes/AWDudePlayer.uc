///////////////////////////////////////////////////////////////////////////////
// Apocalypse Weekend dude controller
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
///////////////////////////////////////////////////////////////////////////////
class AWDudePlayer extends AWPlayer;


var class<P2Emitter>	HeadStartClass;		// head injury starting effects, like stars
var class<P2Emitter>	HeadFlowClass;		// head injury effects that play ambiently
var P2Emitter	HeadFlowEffects;
var Sound StartHeadSound;					// head injury start sound
var Sound EndHeadSound;						// head injury ending sound
var class<GaryHeadWeapon> GWeapClass;
var class<GaryHeadOrbitDude> GaryHeadSpawnClass;
var Sound GaryHeadLine;
var int NewHeadsToGive;
var int GaryHeadMax;
var bool bOldSwitchOnPickup;
var class<HeadStartBlast> headblastclass;

const START_INJURY_COUNT	= 3;
const STOP_INJURY_COUNT		= 3;
const HEAD_TEX_TRIGGER		= 'HeadTexTrig';
const DUDE_HEAD_LAUNCH_SPEED= 200;

var bool bWaitForGaryHeads;

function ContraCode()
{
	local Inventory invadd;
	local P2PowerupInv ppinv;

	invadd = MyPawn.CreateInventory("Inventory.FastFoodInv");

	ppinv = P2PowerupInv(invadd);
	if(ppinv != None)
		ppinv.AddAmount(29);
		
	Pawn.SelectedItem = Powerups(invadd);
}
/*
// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	local GaryHeadOrbitDude GHead;
	
	// Remove the Gary Heads when unpossessed. Looks cool in cinematic but causes all kinds of problems.
	SavedGaryHeads = AWDude(Pawn).GaryHeads;
	foreach DynamicActors(class'GaryHeadOrbitDude', GHead)
		GHead.Destroy();

	Super.UnPossess();
}

// Possess a pawn
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	// If we have heads, init them
	if (SavedGaryHeads > 0)
	{
		AWDude(Pawn).GaryHeads = SavedGaryHeads;
		SavedGaryHeads = 0;
		DoGaryPowers(true);
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
// Called after a level travel
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept()
{
	Super.TravelPostAccept();
	//log(self$" heads after travel "$AWDude(Pawn).GaryHeads$" load "$P2GameInfoSingle(Level.Game).bLoadedSavedGame);
	// If we have heads, setup to init them
	if(AWDude(Pawn).GaryHeads > 0
		&& !P2GameInfoSingle(Level.Game).bLoadedSavedGame)
		bWaitForGaryHeads = true;
}

// Previously the gary heads were set up immediately in TravelPostAccept.
// However, if the level starts with a cutscene (as many levels in AW do), the gary heads would spawn while
// the playercontroller was still attached to the dude, and then the playercontroller would be detatched
// to run the cinematic, and the gary heads didn't know what to do. This caused all kinds of nasty glitches
// like the player losing access to their entire inventory.
// Solution: stuff the re-init function here in PlayerTick and wait for a valid pawn before actually
// resuming the gary powers.
event PlayerTick( float DeltaTime )
{
	Super.PlayerTick(DeltaTime);
	
	if (bWaitForGaryHeads
		&& Pawn != None)
	{
		DoGaryPowers(true);
		bWaitForGaryHeads = false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	local MaterialTrigger mattrig;

	Super.PostLoadGame();

	// Find the head injury triggers and prepare them, if there are any
	foreach AllActors(class'MaterialTrigger', mattrig, HEAD_TEX_TRIGGER)
		break;
	
	if(mattrig != None)
	{
		mattrig.SetCurrentMaterialSwitch(AWDude(MyPawn).HasHeadInjury);
	}

	// Restart gary effect if you have the heads to do it
	log(self$" restarting gary head effect?? "$AWDude(Pawn).GaryHeads);
	if(AWDude(Pawn).GaryHeads > 0)
		P2Hud(myHUD).DoGaryEffects();
}

///////////////////////////////////////////////////////////////////////////////
// Start the dude's head injury effects
///////////////////////////////////////////////////////////////////////////////
function StartHeadInjury()
{
	//log(Self$" start head "$AWDude(Pawn).HasHeadInjury);
	if(AWDude(Pawn).HasHeadInjury == 0)
	{
		AWDude(Pawn).HasHeadInjury=1;
		Pawn.PlaySound(StartHeadSound, SLOT_Misc, 1.0,,TransientSoundRadius);
		GotoState('PlayerStartingHeadInjury');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stop the dude's head injury effects
// Sound is played down in end state for head, to better coincide
// with head injury effect
///////////////////////////////////////////////////////////////////////////////
function StopHeadInjury()
{
	//log(Self$" stop head "$AWDude(Pawn).HasHeadInjury);
	if(AWDude(Pawn).HasHeadInjury == 1)
	{
		AWDude(Pawn).HasHeadInjury=0;
		Pawn.PlaySound(EndHeadSound, SLOT_Misc, 1.0,,TransientSoundRadius);
		GotoState('PlayerStoppingHeadInjury');
	}
}

///////////////////////////////////////////////////////////////////////////////
// Generate some gary heads.
// bTravelRevive looks at you're *supposed* to have, and then remakes them all, but
// doesn't try to delete them--use only after a level transition. After
// loads, the heads are still around so don't use it then.
// Return true, if you made any new heads
///////////////////////////////////////////////////////////////////////////////
function bool DoGaryPowers(optional bool bTravelRevive)
{
	local int i, HeadsToMake, CheckNum;
	local GaryHeadOrbitDude ghead;
	local vector useloc; 
	local HeadStartBlast hsb;

	//log(self$" do gary powers ");
	// spawn heads
	if(bTravelRevive)
	{
		HeadsToMake = AWDude(Pawn).GaryHeads;
		AWDude(Pawn).GaryHeads = 0;	// Blank the the number, because as they're made, the number will increment
	}
	else
		HeadsToMake = NewHeadsToGive;
	// Check to make sure we don't make too many heads
	CheckNum = GaryHeadMax - AWDude(Pawn).GaryHeads;
	if(CheckNum < HeadsToMake)
		HeadsToMake = CheckNum;
	//log(self$" check num "$checknum$" heads to make "$headstomake);
	if(HeadsToMake > 0)
	{
		// Show a cool effect when you add new heads
		if(!bTravelRevive)
		{
			useloc = Pawn.Location;
			useloc.z-=Pawn.CollisionHeight;
			hsb = spawn(headblastclass,self,,useloc);
			hsb.SetBase(Pawn);
		}
		// Commet on coolness
		Pawn.PlaySound(GaryHeadLine, SLOT_Misc, 1.0,,TransientSoundRadius);
		// spawn weapon
		P2Pawn(Pawn).CreateInventoryByClass(GWeapClass);
		SwitchToThisWeapon(GWeapClass.default.InventoryGroup, GWeapClass.default.GroupOffset);
		// Make heads now
		for(i=0; i<HeadsToMake; i++)
		{
			ghead = spawn(GaryHeadSpawnClass, Pawn, , Pawn.Location);
			ghead.PrepVelocity(DUDE_HEAD_LAUNCH_SPEED*vector(Rotation));
		}
		return true;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HeadAdded()
{
	if(AWDude(Pawn) != None)
	{
		AWDude(Pawn).GaryHeads++;
		//log(self$" added, num "$AWDude(Pawn).GaryHeads);
		P2Hud(myHUD).DoGaryEffects();
		// Make sure he won't swap to a new weapon on pickup
		bOldSwitchOnPickup = bNeverSwitchOnPickup;
		bNeverSwitchOnPickup = true;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HeadRemoved()
{
	local GaryHeadWeapon Gweap;
	if(AWDude(Pawn) != None)
	{
		AWDude(Pawn).GaryHeads--;
		//log(self$" removed, num "$AWDude(Pawn).GaryHeads);
		// Powers are over, remove cool weapon
		if(AWDude(Pawn).GaryHeads <= 0)
		{
			// Yank weapon
			GWeap = GaryHeadWeapon(AWDude(Pawn).FindInventoryType(GWeapClass));
			if(GWeap != None)
				GWeap.RemoveMe();
			// Stop hud effects
			P2Hud(myHUD).StopGaryEffects();
			// Return switch status back
			bNeverSwitchOnPickup = bOldSwitchOnPickup;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function PrevWeapon()
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		Super.PrevWeapon();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function NextWeapon()
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		Super.NextWeapon();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function SwitchWeapon (byte F )
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		Super.SwitchWeapon(F);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToBestWeapon()
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		Super.SwitchToBestWeapon();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool SwitchToThisWeapon(int GroupNum, int OffsetNum, optional bool bForceReady)
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		return Super.SwitchToThisWeapon(GroupNum, OffsetNum, bForceReady);
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
exec function SwitchToLastWeaponInGroup(int GroupNum)
{
	// Only let you switch weapons if you don't have any heads
	if(AWDude(Pawn).GaryHeads == 0)
		Super.SwitchToLastWeaponInGroup(GroupNum);
}

///////////////////////////////////////////////////////////////////////////////
// Same as Engine.PlayerController version except we
// use our own distance numbers for the camera
///////////////////////////////////////////////////////////////////////////////
function DeadCalcBehindViewAW(vector UseLoc, float CollHeight, 
							out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;
	local coords checkcoords;

	// We used to look at the dude's head, but now we just look at his center. It makes sure
	// the camera is less likely to be inside things
	//checkcoords = MyPawn.GetBoneCoords(CAMERA_TARGET_BONE);
	// Set the location now to the head
	//CameraLocation = checkcoords.Origin;
	CameraLocation = UseLoc;
	CameraLocation.z += CollHeight;

	// Now modify it based on your surroundings.
	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Going into your head injury period
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerStartingHeadInjury extends PlayerWalking
{
	ignores CanBeMugged, Suicide, CheckMapReminder,
		SomeoneDied, CommentOnCheating, ReadyForCashier, IsSaveAllowed, DudeShoutGetDown;

	///////////////////////////////////////////////////////////////////////////////
	// Go to walking again if it's time
	///////////////////////////////////////////////////////////////////////////////
	function FinishInjuryTransition()
	{
		if(StateCount >= START_INJURY_COUNT)
		{
			// Make stuff flow by you the whole time
			if(HeadFlowClass != None)
			{
				HeadFlowEffects = spawn(HeadFlowClass,MyPawn,,MyPawn.Location);
				HeadFlowEffects.SetBase(MyPawn);
			}
			P2Hud(myHUD).DoWalkHeadInjury();
			GotoState('PlayerWalking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Do visual effects
	///////////////////////////////////////////////////////////////////////////////
	function PrepHud()
	{
		local P2Emitter headstarteffects;

		// Make stars come out for moment
		if(HeadStartClass != None)
		{
			HeadStartEffects = spawn(HeadStartClass,MyPawn,,MyPawn.Location);
			HeadStartEffects.SetBase(MyPawn);
		}
		P2Hud(myHUD).StartHeadInjury();
	}

	///////////////////////////////////////////////////////////////////////////////
	// Clean up in anyway (state stuff, for instance) after being
	// sent to jail
	///////////////////////////////////////////////////////////////////////////////
	function GettingSentToJail()
	{
		// Exit this state
		GotoState('PlayerWalking');
	}

	function EndState()
	{
		Super.EndState();
		//mypawnfix
		if(P2Pawn(Pawn) != None)
			P2Pawn(Pawn).bCanClimbLadders=P2Pawn(Pawn).default.bCanClimbLadders;
	}

	function BeginState()
	{
		Super.BeginState();
		//mypawnfix
		if(P2Pawn(Pawn) != None)
		{
			P2Pawn(Pawn).SetWalking(true);
			P2Pawn(Pawn).bCanClimbLadders=false;
		}
		StateCount=0;
		// Get rid of old effects if necessary
		if(HeadFlowEffects != None)
		{
			HeadFlowEffects.Destroy();
			HeadFlowEffects=None;
		}
	}
Begin:
	PrepHud();
Resetting:
	Sleep(REPORT_LOOKS_SLEEP_TIME);
	//mypawnfix
	P2Pawn(Pawn).ReportPlayerLooksToOthers(RadarPawns, (RadarState != ERadarOff), RadarInDoors);
	CheckForCrackUse(REPORT_LOOKS_SLEEP_TIME);
	FollowCatnipUse(REPORT_LOOKS_SLEEP_TIME);
	StateCount++;
	FinishInjuryTransition();
	Goto('Resetting');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Leaving your head injury period
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state PlayerStoppingHeadInjury extends PlayerStartingHeadInjury
{
	///////////////////////////////////////////////////////////////////////////////
	// Go to walking again if it's time
	// Used to have an effect playing.. not anymore but still here just in case
	///////////////////////////////////////////////////////////////////////////////
	function FinishInjuryTransition()
	{
		if(StateCount >= STOP_INJURY_COUNT)
		{
			GotoState('PlayerWalking');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Do visual effects
	///////////////////////////////////////////////////////////////////////////////
	function PrepHud()
	{
		P2Hud(myHUD).StopHeadInjury();
		// Play here to coincide better with effect end
		MyPawn.PlaySound(EndHeadSound, SLOT_Misc, 1.0,,TransientSoundRadius);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dead
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
	{
		if(Pawn != None)
		{
			DeadCalcBehindViewAW(Pawn.Location, Pawn.CollisionHeight, 
							CameraLocation, CameraRotation, Dist);
		}
		// In case the pawn is none, use our almost always available mypawn!
		else if(MyPawn != None)
		{
			DeadCalcBehindViewAW(MyPawn.Location, MyPawn.CollisionHeight, 
							CameraLocation, CameraRotation, Dist);
		}
		else
		{
			Super.CalcBehindView(CameraLocation, CameraRotation, Dist);
		}
	}
}

defaultproperties
{
     HeadStartClass=Class'AWEffects.InjuryStartEffects'
     HeadFlowClass=Class'AWEffects.InjuryFlowEffects'
     StartHeadSound=Sound'LevelSoundsFo.Misc.ringing'
     EndHeadSound=Sound'LevelSoundsFo.Misc.ringing'
     GWeapClass=Class'AWInventory.GaryHeadWeapon'
     GaryHeadSpawnClass=Class'AWInventory.GaryHeadOrbitDude'
     GaryHeadLine=Sound'AWDialog.Dude.Dude_LostMind'
     NewHeadsToGive=3
     GaryHeadMax=9
     headblastclass=Class'AWEffects.HeadStartBlast'
     DudeButtHit(0)=Sound'AWDialog.Dude.Dude_CowAss_1'
     DudeButtHit(1)=Sound'AWDialog.Dude.Dude_CowAss_2'
     DudeButtHit(2)=Sound'AWDialog.Dude.Dude_CowAss_3'
     DudeButtHit(3)=Sound'AWDialog.Dude.Dude_CowAss_4'
     DudeBladeKill(0)=Sound'AWDialog.Dude.Dude_EdgedWeapon_1'
     DudeBladeKill(1)=Sound'AWDialog.Dude.Dude_EdgedWeapon_2'
     DudeBladeKill(2)=Sound'AWDialog.Dude.Dude_EdgedWeapon_3'
     DudeBladeKill(3)=Sound'AWDialog.Dude.Dude_EdgedWeapon_4'
     DudeBladeKill(4)=Sound'AWDialog.Dude.Dude_UseBlade_1'
     DudeBladeKill(5)=Sound'AWDialog.Dude.Dude_UseBlade_2'
     DudeBladeKill(6)=Sound'AWDialog.Dude.Dude_UseBlade_3'
     DudeMacheteThrow(0)=Sound'AWDialog.Dude.Dude_AltBlade_1'
     DudeMacheteThrow(1)=Sound'AWDialog.Dude.Dude_AltBlade_2'
     DudeMacheteThrow(2)=Sound'AWDialog.Dude.Dude_AltBlade_3'
     DudeMacheteCatch(0)=Sound'AWDialog.Dude.Dude_Machete_Daddy'
     DudeMacheteCatch(1)=Sound'AWDialog.Dude.Dude_Machete_Fingers'
     DudeMacheteCatch(2)=Sound'AWDialog.Dude.Dude_Machete_ImGood'
     DudeMacheteCatch(3)=Sound'AWDialog.Dude.Dude_Machete_ThereItIs'
     GarySkins(0)=Texture'ChameleonSkins.Special.Gary'
     GarySkins(1)=Texture'MPSkins.BlueTeam.MB__136__Mini_M_Jacket_Pants'
     GarySkins(2)=Texture'MPSkins.RedTeam.MB__137__Mini_M_Jacket_Pants'
     DeathHints1(0)="Hmmm... looks like you're dying pretty quickly."
     DeathHints1(1)="Instead of just standing around enjoying the pain,"
     DeathHints1(2)="try running and hiding from your aggressors."
     DeathHints1(3)="Wait and hide from them and then attack them"
     DeathHints1(4)="when they come running around the corner to find you."
     DeathHints2(0)="Make sure to conserve your health powerups for the worst"
     DeathHints2(1)="fire-fights. Try to keep and eye on your health for the"
     DeathHints2(2)="best time for a health boost. Gather up lots of powerups"
     DeathHints2(3)="before going into a big battle."
     DeathHints3(0)="Take a slower pace when you get into fire-fights."
     DeathHints3(1)="If you rush through an area of people who are trying to"
     DeathHints3(2)="kill you, get ready for a lot of damage."
     DeathHints3(3)="Try moving along slowly, letting only a few of their"
     DeathHints3(4)="buddies know about you at once. They'll be easier to handle."
     FireDeathHints1(0)="That sure looks hot. I bet it hurts too."
     FireDeathHints1(1)="Did you know there's a way to put yourself out"
     FireDeathHints1(2)="when you're on fire? Yup... there sure is."
     FireDeathHints1(3)="Try thinking with your lower half next time."
}
