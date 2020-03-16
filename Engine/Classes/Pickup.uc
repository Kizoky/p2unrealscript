//=============================================================================
// Pickup items.
//
// Pickup is the base class of actors that when touched by an appropriate pawn,
// will create and place an Inventory actor in that pawn's inventory chain.  Each
// pickup class has an associated inventory class (its InventoryType).  Pickups are
// placed by level designers.  Pickups can only interact with pawns when in their
// default Pickup state.  Pickups verify that they can give inventory to a pawn by
// calling the GameInfo's PickupQuery() function.  After a pickup spawns an inventory
// item for a pawn, it then queries the GameInfo by calling the GameInfo's
// ShouldRespawn() function about whether it should remain active, enter its Sleep
// state and later become active again, or destroy itself.
//
// When navigation paths are built, each pickup has an InventorySpot (a subclass
// of NavigationPoint) placed on it and associated with it
// (the Pickup's MyMarker== the InventorySpot,
// and the InventorySpot's markedItem == the pickup).
//
//=============================================================================
class Pickup extends Actor
	abstract
	placeable
	native
	nativereplication
	hidecategories(Force,Karma,LightColor,Lighting,Shadow);

#exec Texture Import File=Textures\S_Inventory.pcx Name=S_Inventory Mips=Off MASKED=1

//-----------------------------------------------------------------------------
// AI related info.

var() float		  MaxDesireability;	  // Maximum desireability this item will ever have.
var	  InventorySpot MyMarker;
var() class<Inventory> InventoryType;
var() bool		bInstantRespawn;	  // Can be tagged so this item respawns instantly.
var	  bool		bOnlyReplicateHidden;	// only replicate changes in bHidden (optimization for level pickups)
var(Display) bool bAmbientGlow;		  // Whether to glow or not.
var() float     RespawnTime;          // Respawn after this time, 0 for never respawn again.

var() localized string PickupMessage; // Human readable description when picked up.
var() sound PickupSound;

//-----------------------------------------------------------------------------
// Ambient glow related info.


function Destroyed()
{
	if (MyMarker != None )
		MyMarker.markedItem = None;	
	if (Inventory != None )
		Inventory.Destroy();	
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( Inventory != None 
		// RWS Change, 07/18/03, it apparently has been dropped by something, so destroy it.
		|| RespawnTime == 0)
		destroy();
	else
	{
		GotoState('Pickup');
		Super.Reset();
	}
}

/* Pickups have an AI interface to allow AIControllers, such as bots, to assess the 
 desireability of acquiring that pickup.  The BotDesireability() method returns a 
 float typically between 0 and 1 describing how valuable the pickup is to the 
 AIController.  This method is called when an AIController uses the 
 FindPathToBestInventory() navigation intrinsic.
*/
function float BotDesireability( pawn Bot )
{
	local Inventory AlreadyHas;
	local float desire;

	desire = MaxDesireability;

	if ( RespawnTime < 10 )
	{
		AlreadyHas = Bot.FindInventoryType(InventoryType); 
		if ( AlreadyHas != None ) 
		{
			if ( Inventory != None )
			{
				if( Inventory.Charge <= AlreadyHas.Charge )
					return -1;
			}
			else if ( InventoryType.Default.Charge <= AlreadyHas.Charge )
				return -1;
		}
	}
	return desire;
}

// Either give this inventory to player Other, or spawn a copy
// and give it to the player Other, setting up original to be respawned.
//
function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));

	Copy.GiveTo( Other );
	/*	// RWS Change 09/25/03, don't destroy here because you've still got functions to call
	// Destroy is moved outside of this, in extended Touches.
	if( Level.Game.ShouldRespawn(self) )
		StartSleeping();
	else
		Destroy();
		*/
	return Copy;
}

function StartSleeping()
{
	GotoState('Sleeping');
}

function AnnouncePickup( Pawn Receiver )
{
	Receiver.HandlePickup(self);
	Receiver.PlaySound( PickupSound,,2.0 );
	SetRespawn();
}

//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
	if( Level.Game.ShouldRespawn(self) )
		GotoState('Sleeping');
	else
		Destroy();
}

// HUD Messages

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	GotoState('');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
}

function bool ReadyToPickup(float MaxWait)
{
	return false;
}

event Landed(Vector HitNormal)
{
	GotoState('Pickup');
}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.

auto state Pickup
{
	function bool ReadyToPickup(float MaxWait)
	{
		return true;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).Health <= 0) )
			return false;

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}
		
	// When touched by an actor.
	function Touch( actor Other )
	{
		local Inventory Copy;

		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			Copy = SpawnCopy(Pawn(Other));
			AnnouncePickup(Pawn(Other));
			Copy.PickupFunction(Pawn(Other));
			// RWS change, destroy afterwards instead of inside SpawnCopy
			SetRespawn();
		}
		// don't allow inventory to pile up (frame rate hit)
		else if ( (Inventory != None) && Other.IsA('Pickup')
				&& (Pickup(Other).Inventory != None) )
				Destroy();
	}

	// Make sure no pawn already touching (while touch was disabled in sleep).
	function CheckTouching()
	{
		local Pawn P;

		ForEach TouchingActors(class'Pawn', P)
			Touch(P);
	}

	function Timer()
	{
		if ( Inventory != None )
		{
			if (  (FRand() < 0.1) || !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(3.0, true);
		}
	}

	function BeginState()
	{
		if ( Inventory != None )
			SetTimer(20, false);
	}

Begin:
	CheckTouching();
}


//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.

function float PlaySpawnEffect()
{
	return 0.1;
}

State Sleeping
{
	ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return (LatentFloat < MaxWait);
	}

	function StartSleeping() {}

	function BeginState()
	{
		bHidden = true;
	}
	function EndState()
	{
		bHidden = false;
	}			
Begin:
	Sleep( ReSpawnTime );
	Sleep( PlaySpawnEffect() );
	GoToState( 'Pickup' );
}

defaultproperties
{
	NetUpdateFrequency=8
    PickupMessage="Snagged an item."
	bAlwaysRelevant=true
	RemoteRole=ROLE_DumbProxy
	bHidden=false
	NetPriority=+1.4
	bCollideActors=true
	bCollideWorld=true
     bAmbientGlow=false
     bFixedRotationDir=True
     RotationRate=(Yaw=5000)
     DesiredRotation=(Yaw=30000)
     Texture=Texture'S_Inventory'
     MaxDesireability=0.005000
	 DrawType=DT_Mesh
	 bOnlyReplicateHidden=true
	 bOrientOnSlope=true
	 bUseCylinderCollision=true
	 bShouldBaseAtStartup=true
	 CullDistance=4000.0
}
