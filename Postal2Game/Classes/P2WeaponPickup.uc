///////////////////////////////////////////////////////////////////////////////
// Our buffer class between their weaponpickup class and our weapon pickups.
// WeaponPickup is the version of the weapon that the player picks up and 
// which generates the inventory version of the weapon that he actually uses
// to shoot. See P2Weapon.uc.
//
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// 8/11 kamek backport from AW.
///////////////////////////////////////////////////////////////////////////////
class P2WeaponPickup extends WeaponPickup
	abstract;

///////////////////////////////////////////////////////////////////////////////
// vars, const
///////////////////////////////////////////////////////////////////////////////
var (Pickup) bool	bPersistent;		// whether this pickup will persist
var (Pickup) int	AmmoGiveCount;		// How much ammo this thing gives the weapon when you pick it up
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

var range DeadNPCAmmoGiveRange;	// Range of ammo a weapon pickup gets when dropped from a dead NPC. Usually
								// different (and less) than AmmoGiveCount default for the pickup placed
								// in the level.

var Sound BounceSound;			// Noise to make as you hit the ground
var bool bBounced;				// If it's bounced yet or not

// Special variables to attract animals
var String	AnimalClassString;
var class<AnimalPawn>	MyAnimalClass;

var bool bAllowedToRespawn;		// Instead of having gameinfo decide across the board, dropped
								// pickups need to never respawn.

var(Pickup) int MPAmmoGiveCount;// How much ammo this thing gives the weapon when you pick it up
								// but only for multiplayer games. Normal AmmoGiveCount is only for
								// single player games.

var bool bTossedOut;			// Because we sever the Inventory link in the pickup to make level transitions
								// work in SP we need to set this variable independently when it's tossed out
var class<Inventory> ShortSleeveType;// If, in MP game, you need a short sleeve mesh, make the seperate weapon because
								// changing the mesh on the weapon in PostNetBeginPlay doesn't work (the mesh
								// remains the same. So we use a different (though inheriting) class to do it.

var bool bNoBotPickup;			// If true, we don't want the bot/morons to pick this up during MP play (things
								// that they can't use well, like grenades, usually)

var Controller DropperController; // Controller who dropped me.

const CHECK_FOR_GROUND_DIST	=	2048;
const BOUNCE_AWAY_VEL		=	150;
const DOG_RADIUS			=	2048;
const DESTROY_DELAY			=	500; // make sure it's a while and that people have had time to grab it (5 minutes)

var(Zombie) float ZombieSearchFreq;		// how often to look for zombies
var float ZombieCheckRad;		// how far away to look for them

const PlaguePath = "Postal2Game.P2Player bPlegg";
const FlubberPath = "Postal2Game.P2Player bFlubber";
const BetaPath = "Postal2Game.P2Player bOldskool";
const NutsPath = "Postal2Game.P2Player bNuts";
const ProtestPath = "Postal2Game.P2Player bProtest";
const RadPath = "Postal2Game.P2Player bRads";

// xPatch: Reload Support
var byte SaveReloadCount;			// Keep reload count after you dropped reloadable guns
var bool bReloadableWeaponPickup;	// Player will get full ReloadCount and 0 AmmoInv if this is true.
var bool bAmmoDropped, bAmmoDroppedNPC;
var localized string GroupFullMessage, GroupFullMessage2A, GroupFullMessage2B, MeleeModeMessage;

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
	if(bForTransferOnly)
		bAllowMovement=false;
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
// PreTravel so the clipboard can magic itself back into the Dude's inventory
///////////////////////////////////////////////////////////////////////////////
function PreTravel(Pawn Other)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Go to the right state to be grabbed
///////////////////////////////////////////////////////////////////////////////
function PrepForGrabbing()
{
	GotoState('Pickup');
}

///////////////////////////////////////////////////////////////////////////////
// Allows pickup to save essential info before the current level is changed.
// The info is passed to PersistentRestore() when the level is loaded again.
///////////////////////////////////////////////////////////////////////////////
function PersistentSave(out FPSGameState.PersistentWeaponInfo info)
	{
	info.ClassName = String(Class);
	info.Tag = Tag;
	info.Location = Location;
	info.Rotation = Rotation;
	info.AmmoGiveCount = AmmoGiveCount;
	}


///////////////////////////////////////////////////////////////////////////////
// Restore  pickup using the saved info.  See PersistentSave().
// (Static function because it's called before the object exists.)
///////////////////////////////////////////////////////////////////////////////
static function P2WeaponPickup PersistentRestore(out FPSGameState.PersistentWeaponInfo info, Actor other)
	{
	local P2WeaponPickup pickup;
	local class<Actor> aclass;

	aclass = class<Actor>(DynamicLoadObject(info.ClassName, class'Class'));
	pickup = P2WeaponPickup(other.Spawn(aclass, other, info.Tag, info.Location, info.Rotation));
	pickup.AmmoGiveCount = info.AmmoGiveCount;
	pickup.bPersistent = true;
	pickup.bRecordAfterPickup = false;	// This is now being saved in a different manner, so don't
										// handle it with the same code
	pickup.FindGround();

	return pickup;
	}

///////////////////////////////////////////////////////////////////////////////
// Copy of Engine.Pickup function
// But now we check to make sure the player isn't starting up, if it's the player
///////////////////////////////////////////////////////////////////////////////
function AnnouncePickup( Pawn Receiver )
{
	local P2GameInfoSingle checkg;

	Receiver.HandlePickup(self);

	//log(self$" announce pickup "$Receiver$" player "$P2Pawn(Receiver).bPlayer$" starting "$P2Pawn(Receiver).bPlayerStarting);
	if(!P2Pawn(Receiver).bPlayer
		|| !P2Pawn(Receiver).bPlayerStarting)
	{
		Receiver.PlaySound( PickupSound,,2.0 );
	}

	SetRespawn();

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
// I've fallen to the ground, see if the closest, alive zombie would 
// like to grab me.
///////////////////////////////////////////////////////////////////////////////
event Landed(Vector HitNormal)
{
	local P2MoCapPawn invp, keepp;
	local float checkdist, keepdist;

	Super.Landed(HitNormal);

	HandleBounceEffects(HitNormal);

	if(P2Pawn(Instigator) != None
		&& P2Pawn(Instigator).bPlayer)
	{
		// Send out a call to a dog and let him know about the dropped pickup
		CallDog();
	}

	// Set not moving or ticking
	SetPhysics(PHYS_None);
	bAlwaysRelevant = true;
	bOnlyReplicateHidden = true;

	// Make sure we're still valid before checking
	if(!bDeleteMe
		&& Frand() < ZombieSearchFreq)
	{
		keepdist = ZombieCheckRad;
		foreach RadiusActors(class'P2MoCapPawn', invp, ZombieCheckRad)
		{
			if(invp != None
				&& !invp.bDeleteMe
				&& invp.bZombie
				&& invp.SeeWeaponDrop(self))
			{
				checkdist = VSize(invp.Location - Location);
				if(checkdist < keepdist)
				{
					keepp = invp;
				}
			}
		}
		if(keepp != None)
		{
			keepp.WeaponDropped(self);
		}
	}

	// Change by NickP: MP fix
	P2GameInfo(Level.Game).NotifyPickupDropped(self);
	// End
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

	//log(self$" find ground "$checkpos$" loc "$Location);
	HitActor = Trace(HitLocation, HitNormal, checkpos, Location, false);
	if(HitActor != None)
	{
		//log(self$" find ground "$HitLocation);
		HitLocation+=CollisionHeight*HitNormal;
		//log(self$" find ground "$HitLocation);
		SetLocation(HitLocation);
	}
}

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
		log("now using "$Location);
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

///////////////////////////////////////////////////////////////////////////////
// Spawn a new weapon for SpawnCopy (extended in P2WeaponPickupErrand)
///////////////////////////////////////////////////////////////////////////////
function GetCopy(pawn Other, out Inventory Copy)
{
	//log(self$" get copy "$Other$" "$P2Pawn(Other).bShortSleeves$" short sleeve type "$ShortSleeveType);
	if(!Level.Game.bIsSinglePlayer
		&& P2Pawn(Other).bShortSleeves
		&& ShortSleeveType != None)
		Copy = spawn(ShortSleeveType,Other,,,rot(0,0,0));
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));
//	Copy = spawn(InventoryType,Other,,,rot(0,0,0));
}

///////////////////////////////////////////////////////////////////////////////
// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
///////////////////////////////////////////////////////////////////////////////
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local P2Weapon p2weap;

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
	// Set this here, to tell the weapon selection and SwitchPriority that
	// even though we don't yet ammo (because we add it right afterwards) that we
	// actually could have ammo, so judge us accordingly.
	if(p2weap != None)
		p2weap.bJustMade=true;

	Copy.GiveTo( Other );

	if(p2weap != None)
	{
		// xPatch: We are picking up Reloadable weapon we don't have yet, give us only in-mag ammo.
		if (bReloadableWeaponPickup && !bAmmoDropped
			&& AmmoGiveCount == default.AmmoGiveCount		// Make sure it's not modified
			&& MPAmmoGiveCount == default.MPAmmoGiveCount
			|| (bAmmoDroppedNPC && bReloadableWeaponPickup))	
		{
			AmmoGiveCount = 0;
			MPAmmoGiveCount = 0;
		}
		// End
		
		// Multiplayer has different balancing for how much ammo you get with things
		if(Level.Game != None
			&& FPSGameInfo(Level.Game).bIsSinglePlayer)
			p2weap.GiveAmmoFromPickup(Other, AmmoGiveCount);
		else
			p2weap.GiveAmmoFromPickup(Other, MPAmmoGiveCount);
		
		// xPatch: Restore ReloadCount
		if(Owner != None)
			p2weap.ReloadCount = SaveReloadCount;
		// End
		
		p2weap.bJustMade=false;
	}

	return Copy;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure the amount we had carries over
///////////////////////////////////////////////////////////////////////////////
function InitDroppedPickupFor(Inventory Inv)
{
	local P2Weapon pweap;
	local Inventory ThisInv;
	local bool bAmmoInUse;
	local bool bAllowEmpty;

	Super.InitDroppedPickupFor(Inv);

	PrepForGrabbing();

	// You can't respawn at that spot, because you just got dropped
	bAllowedToRespawn=false;
	RespawnTime=0;
	if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
	{
		// Normal weapons should last a long time in MP, but eventually disappear
		LifeSpan = DESTROY_DELAY;
	}

	// Mark the pickup as persistent if the player dropped it
	if(Instigator != None
		&& Instigator.Controller != None
		&& Instigator.Controller.bIsPlayer)
	{
		//Log("DropFrom(): marking as persistent");
		bPersistent = true;
	}

	// Save controller who made me on drop.
	DropperController = Instigator.Controller;

	// If *anyone* has dropped this pickup, *don't* record it
	bRecordAfterPickup=false;

	// Always allow movement after it's dropped.
	if (!bForTransferOnly)
		bAllowMovement=true;

	pweap = P2Weapon(Inv);
	// Look to seperate and kill the item we came from
	if(pweap != None)
	{
		// xPatch: If we have a reloadable weapon which still has ReloadCount or
		// if a group is limited and full we DON'T want to destroy it.
		if( (P2Player(Instigator.Controller) != None && P2Player(Instigator.Controller).UseGroupLimit())
			 || (pweap.ReloadCount > 0 && bReloadableWeaponPickup) )
			bAllowEmpty=True;
		
		// For MP games, check first to make sure there's any ammo at all. It might be (like with
		// a single molotov thrown on death) that it had 1, but he threw it and now has 0, but it thought
		// he still had 1 at the time. So when it gets to here and finally realizes there's 0, we need
		// to check for it.
		if(P2AmmoInv(pweap.AmmoType).AmmoAmount > 0
			|| P2AmmoInv(pweap.AmmoType).bInfinite
			|| bAllowEmpty) // xPatch: Don't destroy if allowed
		{
			// xPatch: For limited inventory we want to always keep ammo.
			// (so we can swap weapons and keep it between them)
			if (P2GameInfoSingle(Level.Game) != None 
				&& P2Player(Instigator.Controller) != None
				&& P2GameInfoSingle(Level.Game).GetPlayer().UseGroupLimit())
				bAmmoInUse = True;
			else
			{
				bAmmoInUse = false;
				for (ThisInv = Instigator.Inventory; ThisInv != None; ThisInv = ThisInv.Inventory)
				{				
					if (ThisInv != Inv
						&& Weapon(ThisInv) != None
						&& Weapon(ThisInv).AmmoType == P2Weapon(Inv).AmmoType)
					{
						bAmmoInUse = true;
						break;
					}
				}
			}
			// If the dude's holding the ammo for something else, say it drops zero ammo
			if (bAmmoInUse)
			{
				AmmoGiveCount = 0;
				MPAmmoGiveCount = 0;
			}

			// If an NPC dropped it, or if it was infinite ammo, just use the default pickup amount
			// for weapons (so don't modify this value) but if not
			// then use the ammo that was in the gun when it was dropped (like if the dude
			// drops the weapon)
			else if(P2AmmoInv(pweap.AmmoType) == None
				|| !P2AmmoInv(pweap.AmmoType).bInfinite)
			{
				AmmoGiveCount = P2AmmoInv(pweap.AmmoType).AmmoAmount;
				MPAmmoGiveCount = AmmoGiveCount;
			}
			else	
			{	// If it was dropped from an NPC, then use the random range
				// for ammo to be given from dead npc's for this weapon.
				AmmoGiveCount = DeadNPCAmmoGiveRange.Min + Rand(DeadNPCAmmoGiveRange.Max - DeadNPCAmmoGiveRange.Min);
				MPAmmoGiveCount = AmmoGiveCount;
				
				// xPatch
				if(bReloadableWeaponPickup)
				{
					SaveReloadCount = AmmoGiveCount;
					bAmmoDroppedNPC = True;
				}
			}
			
			// xPatch: Keep ReloadCount
			if(pweap.ReloadCount > 0 && !bAmmoDroppedNPC)
				SaveReloadCount = P2Weapon(Inv).ReloadCount;
			
			bAmmoDropped=True;
			// End

			Inventory.Destroy();
		}
		else // Don't really make this since we didn't really have ammo
		{
			Destroy();
		}
	}

	// Always detach the pickup inventory from the real inventory. (this was set in default InitDroppedPickupfor)
	Inventory=None;
}

///////////////////////////////////////////////////////////////////////////////
// When touched by an actor.
///////////////////////////////////////////////////////////////////////////////
function CheapBounce( actor Other )
{
	local Inventory Copy;
	local vector BounceVel, HitNormal;
	
	// don't allow inventory to pile up (frame rate hit)
	if (Pickup(Other) != None
		&& bAllowMovement
		&& !bForTransferOnly)
	{
		bAlwaysRelevant = false;
		bOnlyReplicateHidden = false;
		// Instead of destroying it like Epic does, we'll bounce ours
		// in two different directions
		// Same as in P2PowerupPickup
		HitNormal = Normal(Other.Location - Location);
		BounceVel = HitNormal;
		BounceVel.z += 0.5;	// make sure it goes up
		BounceVel = (FRand()*BOUNCE_AWAY_VEL + BOUNCE_AWAY_VEL)*BounceVel;
		// pop both up in the air, away from one another
		SetPhysics(PHYS_Falling);
		bBounce=false;
		Velocity = -BounceVel;
		Velocity.z = abs(Velocity.z);

		if((P2PowerupPickup(Other) != None
				&& P2PowerupPickup(Other).bAllowMovement
				&& !P2PowerupPickup(Other).bForTransferOnly)
			|| (P2AmmoPickup(Other) != None
				&& P2AmmoPickup(Other).bAllowMovement)
			|| (P2WeaponPickup(Other) != None
				&& P2WeaponPickup(Other).bAllowMovement
				&& !P2WeaponPickup(Other).bForTransferOnly))
		{
			// Make other pickup bounce away
			// Wake it up
			Other.bAlwaysRelevant = false;
			Pickup(Other).bOnlyReplicateHidden = false;
			Other.SetPhysics(PHYS_Falling);
			Other.GotoState('Pickup');
			Other.bBounce=false;
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
		&& !bForTransferOnly
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
	///////////////////////////////////////////////////////////////////////////////
	// ValidTouch()
	// Validate touch (if valid return true to let other pick me up and trigger event).
	//
	///////////////////////////////////////////////////////////////////////////////
	function bool ValidTouch( actor Other )
	{
		local vector Top, Bottom, OtherTop, OtherBottom;
		local int MaxInGr;

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
			
		// xPatch: Melee Mode
		if(P2GameInfo(Level.Game).InHardLiebermode())
		{
			if(!Class<P2Weapon>(InventoryType).default.bMeleeWeapon)
			{
				if(P2Player(Pawn(Other).Controller) != None)
					P2Player(Pawn(Other).Controller).MyHUD.LocalizedMessage(MessageClass, ,,,,MeleeModeMessage);
				return false;
			}
		}
			
		// xPatch: Veteran Mode
		if(P2Player(Pawn(Other).Controller) != None 
			&& P2Player(Pawn(Other).Controller).GetWeaponGroupFull(InventoryType, MaxInGr))
		{
			if(MaxInGr > 1)
				P2Player(Pawn(Other).Controller).MyHUD.LocalizedMessage(MessageClass, ,,,,GroupFullMessage2A@MaxInGr@GroupFullMessage2B@InventoryType.default.InventoryGroup$".");
			else
				P2Player(Pawn(Other).Controller).MyHUD.LocalizedMessage(MessageClass, ,,,,GroupFullMessage@InventoryType.default.InventoryGroup$".");
			return false;
		}

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
	// ForTransferOnly pickup fix. See Tick above.
Begin:
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
	CollisionRadius=50.000000
	CollisionHeight=10.000000
	//bOrientOnSlope=false
	DrawScale=1.5
	PickupSound=Sound'WeaponSounds.weapon_pickup'
	BounceSound=Sound'MiscSounds.PickupSounds.PickupBounce'
	bRecordAfterPickup=true
	bAllowMovement=true
	DeadNPCAmmoGiveRange=(Min=1,Max=1)
	AmbientGlow=255
	bAllowedToRespawn=true
	AmmoGiveCount=1
	MPAmmoGiveCount=1
	ZombieSearchFreq=0.000000
	ZombieCheckRad=500.000000
	GroupFullMessage="You can only carry one weapon in group"
	GroupFullMessage2A="You can only carry"
	GroupFullMessage2B="weapons in group"
	MeleeModeMessage="You can't carry any of these in this game mode!"
}