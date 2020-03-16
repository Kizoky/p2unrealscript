///////////////////////////////////////////////////////////////////////////////
// Our buffer class between their pickup class and our powerup/inventory pickups.
// This generates the inventory item set in InventoryType.
//
// Powerup pickups are the version that lies around the level and is picked 
// up by the player. 
// (powerup inv is the inventory version)
///////////////////////////////////////////////////////////////////////////////
class P2PowerupPickup extends Pickup
	abstract;

// External variables
var() float		AmountToAdd;	// how much of this thing to add

// Internal variables
var bool  bUseForErrands;	// whether or not to use this for the errands, to check for completion
var int   Tainted;			// been pissed on or something.
var bool  bEdible;			// Food or medkit
var() bool	bPersistent;	// whether this pickup will persist
var() bool	bForTransferOnly;	// Used when things have been taken from the dude on a level startup
								// (such as getting put in jail). If this is true, then anything
								// taken from the dude that matches this class type (like ShotgunWeapon)
								// will go where this one is. If you enter a level without having things
								// taken from you, these pickups are destroyed by the gameinfo.
var() bool  bDestroyAfterTransfer;	// If bForTransferOnly is set to true, and this is set, then
								// when the dude comes through and finds this item, it's removed from
								// his inventory, but then not put back (this pickup is deleted)
var() bool	bForRobberyOnly;	// If set to true, this is where the Dude's stuff went after he got robbed.								
var() bool	bRecordAfterPickup;	// Independent (possibly) of bPeristent, this defaults to true, meaning
								// when a level designer places this, and a pawn comes across it and picks
								// it up, it's rememebered that it's been picked up. If a pawn drops an
								// item and makes a pickup, it's turned off, so dropped items are re-recorded
								// after pickup
var() bool	bAllowMovement;		// True for most things.. means if you damage it, it will get moved.
								// If it's false, you can't move it, until the player picks it up once
								// and then drops it again
var() bool bStartTainted;		// If level designers set this, it will start tainted
var() bool bAutoActivateOnce;	// if bAutoActivate should turn off after they drop the pickup. Makes it
								// so only the versions made by level designers are auto activated.
								// This only works correctly in single player mode. Any other player
								// that comes across a thing dropped by another player won't have
								// that thing properly AutoActivate on pickup for that other player.
		// Example: the newspaper has it default to true, but the one in the Jail is set to false
		// because you've already gotten it, and we don't want it spinning up when you grab it out of the
		// evidence room.
var	  bool bBreaksWindows;		// If it's heavy enough to break windows.. most things are
var	  bool bBounced;				// If it's bounced yet or not

// Marker that tells the pawns around me who care, that this powerup is here and looking desireable
// If this the class is null, it doesn't set this
var DesiredThingMarker DesireMarker;
var class<DesiredThingMarker> DesireMarkerClass;

// Special variables to attract animals
var String	AnimalClassString;
var class<AnimalPawn>	MyAnimalClass;

var Sound BounceSound;			// Noise to make as you hit the ground

var bool bNoBotPickup;			// If true, we don't want the bot/morons to pick this up during MP play (things
								// that they can't use well, like fastfood, usually)

var Controller DropperController; // Controller who dropped me.
var() class<Inventory> NightmareInventoryType;	// Pickup to be granted in Nightmare Mode instead.
var bool bNoReorientHandOver;	// Skips reorienting the pickup when handed over (for valentine vase)


// consts
const CHECK_FOR_GROUND_DIST	=	2048;
const BOUNCE_AWAY_VEL		=	150;
const DOG_RADIUS			=	2048;
const DESTROY_DELAY			=	500; // make sure it's a while and that people have had time to grab it (5 minutes)

// Kamek Edit
var bool bOKToGrab; // Can't pick up until this value is true.

const MunchPath = "Postal2Game.P2Player bMunch";

///////////////////////////////////////////////////////////////////////////////
// Tick
// We had a problem with ForTransferOnly pickups falling to the ground,
// preventing LD's from arranging them neatly. Despite setting bAllowMovement
// to false and preventing the code from allowing it to move if a transfer
// pickup, the UnrealEd Goblin still sneaked in at the beginning of every
// level and would set the physics to PHYS_Falling for one tick, causing
// the weapons to fall and lose their positioning.
// Hackjob solution: force PHYS_None every tick until the pickup goes into
// Pickup state for about a second. Then disable Tick to improve performance.
// Weapons stay in their position, the Goblin is defeated, and the peasants
// rejoiced.
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	Super.Tick(dT);
	if (!bAllowMovement)
		SetPhysics(PHYS_None);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
	Super.PreBeginPlay();
	MyAnimalClass = class<AnimalPawn>(DynamicLoadObject(AnimalClassString, class'Class'));
	SetPhysics(PHYS_None);
	// If we start tainted (from a level designer setting) then set it so
	if(bStartTainted)
		Taint();
	if(bForTransferOnly)
		bAllowMovement=false;
	//log(self$" prebeginplay");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	// Don't let powerups move in MP
	if(Level.Game == None
		|| !FPSGameInfo(Level.Game).bIsSinglePlayer)
		bAllowMovement=false;
}

///////////////////////////////////////////////////////////////////////////////
// Go to the right state to be grabbed
///////////////////////////////////////////////////////////////////////////////
function PrepForGrabbing()
{
	GotoState('Pickup');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	if(DesireMarker != None)
	{
		DesireMarker.Destroy();
		DesireMarker = None;
	}
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Allows pickup to save essential info before the current level is changed.
// The info is passed to PersistentRestore() when the level is loaded again.
///////////////////////////////////////////////////////////////////////////////
function PersistentSave(out FPSGameState.PersistentPowerupInfo info)
	{
	info.ClassName = String(Class);
	info.Tag = Tag;
	info.Location = Location;
	info.Rotation = Rotation;
	info.AmountToAdd = AmountToAdd;
	info.StaticMesh = StaticMesh;	// for most powerups this is none, so it won't matter

	//log(" PersistentSave class"$info.ClassName$" loc "$Location);
	}

///////////////////////////////////////////////////////////////////////////////
// Restore  pickup using the saved info.  See PersistentSave().
// (Static function because it's called before the object exists.)
///////////////////////////////////////////////////////////////////////////////
static function P2PowerupPickup PersistentRestore(FPSGameState.PersistentPowerupInfo info, Actor other)
	{
	local P2PowerupPickup pickup;
	local class<Actor> aclass;

	aclass = class<Actor>(DynamicLoadObject(info.ClassName, class'Class'));
	pickup = P2PowerupPickup(other.Spawn(aclass, other, info.Tag, info.Location, info.Rotation));
	pickup.AmountToAdd = info.AmountToAdd;
	pickup.SetStaticMesh(info.StaticMesh);	// for most powerups this is none, so it won't matter
	pickup.bPersistent = true;
	pickup.bRecordAfterPickup = false;	// This is now being saved in a different manner, so don't
										// handle it with the same code
	pickup.FindGround();

	//log(pickup$" PersistentRestore class"$info.ClassName$" loc "$pickup.Location);
	return pickup;
	}

///////////////////////////////////////////////////////////////////////////////
// Trace down and find a point below us to be placed, after a level restore
// in case we've been thrown, or something stupid like that.
// BROKEN!
///////////////////////////////////////////////////////////////////////////////
function FindGround()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, checkpos;
	local Rotator userot;

	checkpos = Location;
	checkpos.z -= CHECK_FOR_GROUND_DIST;

	HitActor = Trace(HitLocation, HitNormal, checkpos, Location, false);
	if(HitActor != None)
	{
		HitLocation+=CollisionHeight*HitNormal;
		SetLocation(HitLocation);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Taint
///////////////////////////////////////////////////////////////////////////////
function Taint()
{
	Tainted=1;
}

///////////////////////////////////////////////////////////////////////////////
// Trigger
///////////////////////////////////////////////////////////////////////////////
function Trigger( Actor Other, Pawn EventInstigator)
{
//	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// copy your important things over from your maker
///////////////////////////////////////////////////////////////////////////////
function TransferStateBack(P2PowerupInv maker)
{
//	log(self$" transfer back "$maker.Tainted);
	if(maker.Tainted == 1)
		Tainted = 1;
}

///////////////////////////////////////////////////////////////////////////////
// Reduce the amount of the inventory we just got generated from
///////////////////////////////////////////////////////////////////////////////
function TakeAmountFromInv(P2PowerupInv p2Inv, int amounttoremove)
{
	p2Inv.ReduceAmount(amounttoremove,,,,true);
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	Super.InitDroppedPickupFor(Inv);

	PrepForGrabbing();

	// send things back to the pickup
	TransferStateBack(P2PowerupInv(Inv));

	// Check if the player dropped it
	if(Instigator != None
		&& Instigator.Controller != None
		&& Instigator.Controller.bIsPlayer)
	{
		// Mark the pickup as persistent if the player dropped it
		bPersistent = true;
	}

	// Save controller who made me on drop.
	DropperController = Instigator.Controller;

	// Anything that's been dropped by the player can't auto activate anymore. 
	bAutoActivateOnce=false;

	// If *anyone* has dropped this pickup, *don't* record it
	bRecordAfterPickup=false;

	// Always allow movement after it's dropped.
	bAllowMovement=true;

	// Don't let it respawn once you've dropped it
	RespawnTime=0;

	if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
	{
		// Normal powerups should last a long time in MP, but eventually disappear
		LifeSpan = DESTROY_DELAY;
	}

	if(P2PowerupInv(Inv).bThrowIndividually)
	{
		AmountToAdd = 1;
		//P2PowerupInv(Inv).Amount;	// carry over how much was in the inventory item
		// that we are dropping, to the pickup that we now make, so as to preserve
		// the contents.

		// Zero after the transfer. 
		//  For some reason -- investigate?-- no inventory gets deleted even after
		// DeleteInventory is called. It's simply unused.
		TakeAmountFromInv(P2PowerupInv(Inv), 1);
	}
	else
	{
		AmountToAdd = P2PowerupInv(Inv).Amount;	// carry over how much was in the inventory item
		// that we are dropping, to the pickup that we now make, so as to preserve
		// the contents.

		// Zero after the transfer. 
		//  For some reason -- investigate?-- no inventory gets deleted even after
		// DeleteInventory is called. It's simply unused.
		P2PowerupInv(Inv).Amount = 0;
	}
/*
	// Look to seperate and kill the item we came from
	if(P2PowerupInv(Inv) != None
		&& P2PowerupInv(Inv).Amount == 0)
	{
//		log(self$" what i'm connected to "$Inventory);
		Inventory.Destroy();
	}
*/
	// Always detach the pickup inventory from the real inventory. 
	// (this was opposite in Engine.Pickup::InitDroppedPickupfor)
	Inventory=None;
}

///////////////////////////////////////////////////////////////////////////////
// Record that you picked up this object
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	local P2GameInfoSingle checkg;

	Super.AnnouncePickup(Receiver);

	// Check if you've just been deleted.. if so, record yourself
	// in the list of dropped pickups per level, ONLY if you've been
	// placed in there by the level designers
	if(bDeleteMe
		&& bRecordAfterPickup)
	{
		checkg = P2GameInfoSingle(Level.Game);
		if(checkg != None)
		{
			// Remember it was picked up
			checkg.TheGameState.RecordPickup(name);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// First hit of this type, so add in what we've found
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;
	local P2Player checkp;
	local P2GameInfoSingle checkg;
	local P2PowerupInv ppinv;
	local Texture pickupskin;

//	Copy = Super.SpawnCopy(Other);

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else if (P2GameInfo(Level.Game).InNightmareMode()
		&& NightmareInventoryType != None
		&& !bUseForErrands)
		Copy = spawn(NightmareInventoryType,Other,,,rot(0,0,0));
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));

	Copy.GiveTo( Other );

	if(Skins.Length > 0)
		pickupskin = Texture(Skins[0]);

	ppinv = P2PowerupInv(Copy);
	ppinv.AddAmount(AmountToAdd, pickupskin, StaticMesh, Tainted);

	checkg = P2GameInfoSingle(Level.Game);
	if(checkg != None)
	{
		// See if this item is in an uncompleted errand
		if(bUseForErrands)
		{
			checkg.CheckForErrandCompletion(self, None, Other, P2Player(Other.Controller), false);
		}
	}

	// When this is picked up, set it to autoactivate once.
	if(bAutoActivateOnce)
		ppinv.bAutoActivate=true;
	// If this one isn't has already autoactivated once, but by default
	// this pickup has bAutoActivateOnce set to true, then it means 
	// we don't want the player auto using this on pickup any more
	else if(default.bAutoActivateOnce)
		ppinv.bAutoActivate=false;

	// copy important things over
	if(ppinv != None)
		ppinv.TransferState(self);

	return Copy;
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function UseTagToNearestActor(Name UseTag, out Actor UseActor, float randval, 
							  optional bool bDoRand, optional bool bSearchPawns)
{
	local Actor CheckA, LastValid;
	local float dist, keepdist;
	local class<Actor> useclass;

	if(UseTag != 'None')
	{
		dist = 65535;
		keepdist = dist;
		UseActor = None;
		
		if(bSearchPawns)
			useclass = class'FPSPawn';
		else
			useclass = class'Actor';

		ForEach AllActors(useclass, CheckA, UseTag)
		{
			// don't allow it to pick you, even if your tag is valid
			if(CheckA != self
				&& !CheckA.bDeleteMe)
			{
				LastValid = CheckA;
				dist = VSize(CheckA.Location - Location);
				if(dist < keepdist
					&& (!bDoRand ||	FRand() <= randval))
				{
					keepdist = dist;
					UseActor = CheckA;
				}
			}
		}

		if(UseActor == None)
			UseActor = LastValid;

		if(UseActor == None)
			log("ERROR: could not match with tag "$UseTag);
	}
	else
		UseActor = None;	// just to make sure
}

///////////////////////////////////////////////////////////////////////////////
// You threw out something! If a dog is around, he'll come and want to play
// This will call the first dog it comes across, only one dog
// This *used* to check your animal friend
// first, but once I made it possible to train multiple ones, still attracting
// the closest dog first was best.
///////////////////////////////////////////////////////////////////////////////
function bool CallDog()
{
	local AnimalPawn CheckP, UseP;
	local AnimalController cont;
	local byte StateChange;
	local P2Player p2p;
	local float dist, keepdist;
	local int i;

	if(!bEdible)
	{
		dist = 65536;
		keepdist = dist;
		// Tell the closet dog around you to come running for the newly
		// fallen powerup
		ForEach CollidingActors(class'AnimalPawn', CheckP, DOG_RADIUS)
		{
			// If it's a dog and he's alive and he can see it,
			// then check for him to run over
			// and grab up the pickup and bring it back to you.
			if(CheckP.class == MyAnimalClass
				&& CheckP.Health > 0
				&& CheckP.Controller != None)
			{
				dist = VSize(CheckP.Location - Location);
				if(dist < keepdist)
					//&& FastTrace(CheckP.Location, Location))
				{
					keepdist = dist;
					UseP = CheckP;
				}
			}
		}

		if(UseP != None)
		{
			cont = AnimalController(UseP.Controller);
			cont.RespondToAnimalCaller(FPSPawn(Instigator), self, StateChange);
			if(StateChange == 1)
				return true;
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Some effects for pickups hitting the ground
///////////////////////////////////////////////////////////////////////////////
function HandleBounceEffects(vector HitNormal)
{
	local PickupHitPuff smoke1;
	if(!bBounced)
	{
		// Throw out some hit effects, like dust or sparks
		smoke1 = spawn(class'PickupHitPuff',,,Location);

		// Bouncy noise
		PlaySound(BounceSound);
		bBounced=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// I've fallen to the ground
///////////////////////////////////////////////////////////////////////////////
event Landed(Vector HitNormal)
{
	Super.Landed(HitNormal);

	HandleBounceEffects(HitNormal);

	if(P2Pawn(Instigator) != None
		&& P2Pawn(Instigator).bPlayer)
	{
		// Send out a call to a dog and let him know about the dropped pickup
		CallDog();
	}

	// For some reason I had it so only the player would be able to drop things (like
	// money) and get people to respond to it. Now I've made it so anyone who's dropped money.

	// Mark this so other pawns want this thing
	if(DesireMarkerClass != None)
	{
		if(DesireMarker == None)
		{
			// Make a marker saying i'm a tastey desirable donut
			DesireMarker = spawn(DesireMarkerClass,self,,Location);
			// Manually notify now that we've set our enum
			DesireMarker.NotifyAndCount();
		}
		else
			DesireMarker.SetLocation(Location);
	}

	// Set not moving or ticking
	SetPhysics(PHYS_None);

	// Don't let powerups move in nightmare mode (allowing them to kick health "down the road" for later)
	if(P2GameInfo(Level.Game).InNightmareMode())
		bAllowMovement=false;
}

/*
///////////////////////////////////////////////////////////////////////////////
// Make it lie on the ground, sort of
///////////////////////////////////////////////////////////////////////////////
function FitToGround()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, checkpos;
	local Rotator userot;

	//log("physics in fit to ground "$Physics);
	//log("latching ");
	// Snap to the ground below you
	//log("loc "$Location);
	checkpos = Location;
	checkpos.z -= CHECK_FOR_GROUND_DIST;

	HitActor = Trace(HitLocation, HitNormal, checkpos, Location, false);
	if(HitActor != None)
	{
		HitLocation+=CollisionHeight*HitNormal;
		//log("set with loc "$HitLocation);
		SetLocation(HitLocation);
//		log("now using "$Location);
		// Fit to the ground
		userot = Rotator(HitNormal);
		//log("use rot "$userot);
		userot.Pitch=16383-userot.Pitch;
		userot.Pitch = userot.Pitch & 65535;
		userot.Roll+=16383;
		userot.Roll = userot.Roll & 65535;
		
		//log("use rot after "$userot);
		if(!Level.bStartup)
		{
			userot.Yaw = Rotation.Yaw;
			userot.Yaw = userot.Yaw & 65535;
		}
		else
		{	
			userot.Yaw +=32768;
			userot.Yaw = userot.Yaw & 65535;
		}
		SetRotation(userot);
		//log("after rotation"$Location);
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// When touched by an actor.
///////////////////////////////////////////////////////////////////////////////
function CheapBounce( actor Other )
{
	local Inventory Copy;
	local vector BounceVel, HitNormal;

	// don't allow inventory to pile up (frame rate hit)
	if (Pickup(Other) != None
		&& bAllowMovement)
	{
		// Allow it to move on both client and server
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;
		// Instead of destroying it like Epic does, we'll bounce ours
		// in two different directions
		// Same as in P2PowerupPickup
		HitNormal = Normal(Other.Location - Location);
		BounceVel = HitNormal;
		BounceVel.z += 1.0;	// make sure it goes up
		BounceVel = (FRand()*BOUNCE_AWAY_VEL + BOUNCE_AWAY_VEL)*BounceVel;
		// pop both up in the air, away from one another
		SetPhysics(PHYS_Falling);
		bBounced=false;
		Velocity = -BounceVel;
		Velocity.z = abs(Velocity.z);

		if((P2PowerupPickup(Other) != None
				&& P2PowerupPickup(Other).bAllowMovement)
			|| (P2AmmoPickup(Other) != None
				&& P2AmmoPickup(Other).bAllowMovement)
			|| (P2WeaponPickup(Other) != None
				&& P2WeaponPickup(Other).bAllowMovement))
		{
			// Make other pickup bounce away
			// Wake it up
			Other.bAlwaysRelevant = false;
			Pickup(Other).bOnlyReplicateHidden = false;
			Other.bBounce=false;
			Other.SetPhysics(PHYS_Falling);
			Other.GotoState('Pickup');
			Other.Velocity = BounceVel;
			Other.Velocity.z = abs(Other.Velocity.z);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take damage and be force around
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Dam, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
{
	if(bAllowMovement
		&& VSize(Momentum) > 0
		&& Dam > 0)
	{
		// Allow it to move on both client and server
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;

		// Dampen the momentum from explosions so you don't get thrown too far
		if(ClassIsChildOf(damageType, class'ExplodedDamage'))
			Momentum=Momentum/2;
		SetPhysics(PHYS_Falling);
		bBounced=false;
		Velocity = (Momentum/Mass);
		// Make sure it never gets hit down (caused it to go into the ground too much)
		if(Velocity.z < 0)
			Velocity.z = abs(Velocity.z);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Don't allow pick up here
///////////////////////////////////////////////////////////////////////////////
auto state Spawned
{
	ignores Touch;

	function BeginState()
	{
		///////////////////////////////////////////////////////////////////////////////
		// Pickups spawned during gameplay must set themselves up to be grabbed
		// that way the dude can drop a powerup and not grab it, but still grab
		// others in midair. Unless a thing gets spawned by something like a spawner
		// in which case having no Instigator should set it up correctly.
		///////////////////////////////////////////////////////////////////////////////
		if(Level.bStartup
			|| Instigator == None)
			PrepForGrabbing();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Pickup state: this inventory item is sitting on the ground.
///////////////////////////////////////////////////////////////////////////////
state Pickup
{
	// Kamek Edit
	event Timer()
	{
		bOKToGrab=true; // A tick has passed and the game's cleaned up behind our potential cheater
	}

	///////////////////////////////////////////////////////////////////////////////
	// ValidTouch()
	// Validate touch (if valid return true to let other pick me up and trigger event).
	//
	///////////////////////////////////////////////////////////////////////////////
	function bool ValidTouch( actor Other )
	{
		local vector Top, Bottom, OtherTop, OtherBottom;

		// Kamek Edit
		if (!bOKToGrab)
			return false;

		// make sure its a live player/not the one who dropped us, if it's
		// currently falling
		if ( (Pawn(Other) == None)
			|| !Pawn(Other).bCanPickupInventory 
			|| (Pawn(Other).Health <= 0)
			|| Pawn(Other).Controller == None
			|| (Pawn(Other).Controller == DropperController
				&& Physics == PHYS_Falling))
			return false;

		// Make sure it's not a bot trying to pick it up during MP play
		if(Level.Game != None
			&& !Level.Game.bIsSinglePlayer
			&& P2Player(Pawn(Other).Controller) == None
			&& bNoBotPickup)
			return false;

		// Form top and bottom of pickup
		Top = Location;
		Top.z += CollisionRadius;
		Bottom = Location;
		Bottom.z -= CollisionRadius;
		// form top and bottom of other
		OtherTop = Other.Location;
		OtherTop.z += Other.CollisionRadius;
		OtherBottom = Other.Location;
		OtherBottom.z -= Other.CollisionRadius;

		// make sure not touching through wall
		// But do a better job, by testing from the feet, the head, and the center
		if (!FastTrace(Other.Location, Location)	// check middle
			&& !FastTrace(OtherTop, Top)			// check top
			&& !FastTrace(OtherBottom, Bottom))		// check bottom
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// When touched by an actor.
	// Allow pawns to pick this up any time--even in the air just after dropping
	// it, but don't allow the one that dropped it, to grab it before it hits the
	// ground.
	///////////////////////////////////////////////////////////////////////////////
	function Touch( actor Other )
	{
		local Inventory Copy;
		local Trigger trig;
		local P2GameInfoSingle checkg;

		trig = Trigger(Other);

		if(trig != None)
		{
			// If you hit a trigger for looking for your class, and you have to do
			// with errands, check to complete an errand and destroy yourself
			if(trig.ClassIsChildOf(class, trig.ClassProximityType)
				&& bUseForErrands)
			{
				// See if this item is in an uncompleted errand
				checkg = P2GameInfoSingle(Level.Game);
				if(checkg != None)
					checkg.CheckForErrandCompletion(self, Other, Instigator, P2Player(Instigator.Controller), false);
				// Destroy it anyway, when it hits this
				Destroy();
				return;
			}
		}
		
		if(ValidTouch(Other))
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			Copy.PickupFunction(Pawn(Other));
			// Destroy possibly here instead of inside SpawnCopy
			SetRespawn();
		}
		// don't allow inventory to pile up (frame rate hit)
		else 
		{
			CheapBounce(Other);
		}
	}
Begin:
	SetTimer(0.1,false);
	// ForTransferOnly pickup fix. See Tick above.
	Sleep(1.0);
	Disable('Tick');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Waiting to respawn, make sure it can't be kicked/moved here
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
State Sleeping
{
	ignores TakeDamage;
}

defaultproperties
{
	AnimalClassString="People.DogPawn"
    RotationRate=(Yaw=0)
	MessageClass=class'PickupMessagePlus'
	bHidden=false
	//bOrientOnSlope=false
	PickupSound=Sound'WeaponSounds.weapon_picked_up'
	CollisionRadius=25.000000
	CollisionHeight=10.000000
	AmountToAdd=1
	bBreaksWindows=true
	bRecordAfterPickup=true
	bAllowMovement=true
	BounceSound=Sound'MiscSounds.PickupSounds.PickupBounce'
	AmbientGlow=255
    RespawnTime=30.000000
}