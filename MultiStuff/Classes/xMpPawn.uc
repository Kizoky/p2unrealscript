// This is the common base class from which all specific multiplayer characters
// should extend.
class xMpPawn extends Dude
	placeable;

var Controller OldController;

var KevlarMesh ArmorMesh;		// Model of kevlar armor you're wearing on your person

const POP_UP_HACK_VAL = 3;
const VEST_BONE_NAME = 'MALE01 spine1';

const DAMAGE_THRESH_1 = 0.67;
const DAMAGE_THRESH_2 = 0.33;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function UnPossessed()
{
	OldController = Controller;
	Super.UnPossessed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	// Do this or people who leave games with kevlar on will leave a kevlar
	// floating in mid-air
	DestoryArmorMesh();

	// Notify other things that we were killed, because for some unknown (and
	// unknowable) reason, epic chose not to kill the pawn the usual way when
	// a player suddenly exits the game (using "exit" or "quit")
	if (Level.Game != None)
		Level.Game.NotifyKilled(None, Controller, self);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	local int i, randpick;
	local Inventory thisinv;
	local P2PowerupInv pinv;
	local P2Weapon p2weap;
	local class<P2Weapon> p2weapclass, p2shortclass;
	local class<P2WeaponPickup> pickupclass;
	local int usedam;
	local int Count;

	// Only let this be called once
	if (!bGotDefaultInventory)
	{
		//Log(self$" PersonPawn.AddDefaultInventory() is adding inventory");
		// Everyone gets hands, so add that explicitly here
		if(bShortSleeves)
			thisinv = CreateInventoryByClass(class'Inventory.HandsWeaponSS');
		else
			thisinv = CreateInventoryByClass(class'Inventory.HandsWeapon');

		if(DeathMatch(Level.Game) != None)
		{
			// Add in the extra stuff now
			for ( i=0; i<DeathMatch(Level.Game).GameBaseEquipment.Length; i++ )
			{
				p2weapclass = class<P2Weapon>(DeathMatch(Level.Game).GameBaseEquipment[i].weapclass);

				if (p2weapclass != None)
				{
					pickupclass = class<P2WeaponPickup>(p2weapclass.default.PickupClass);
					if(bShortSleeves && pickupclass != None)
					{
						p2shortclass = class<P2Weapon>(pickupclass.default.ShortSleeveType);
						if(p2shortclass != None)
							p2weapclass = p2shortclass;
					}
					//log(self$" base equipment "$i$" weap "$p2weapclass$" short "$p2shortclass);

					// Create the weapon from this base equipment index
					thisinv = CreateInventoryByClass(p2weapclass);

					// Special weapon handling:
					// Keep track of the foot now, because we can't do it below (like the urethra)
					// --it's not added to the inventory list
					// Link up your foot
					if(FootWeapon(thisinv) != None)
					{
						MyFoot = P2Weapon(thisinv);
						MyFoot.GotoState('Idle');
						MyFoot.bJustMade=false;
						if(Controller != None)
							Controller.NotifyAddInventory(MyFoot);
						ClientSetFoot(P2Weapon(thisinv));
					}
				}
				else if(DeathMatch(Level.Game).GameBaseEquipment[i].weapclass != None)
				{
					thisinv = CreateInventoryByClass(DeathMatch(Level.Game).GameBaseEquipment[i].weapclass);
				}
			}
		}

		// tell the weapons they've been made now
		thisinv = Inventory;
		while(thisinv != None)
		{
			if(P2Weapon(thisinv) != None)
			{
				// After the creation of the weapon, while  normal weapons link up their ammo, 
				// we wait and finally link up the urethra. Don't do it above, during the creation
				// of the weapon, it must wait till here.
				if(UrethraWeapon(thisinv) != None)
				{
					MyUrethra = Weapon(thisinv);
					MyUrethra.GiveAmmo(self);
					ClientSetUrethra(P2Weapon(thisinv));
				}

				P2Weapon(thisinv).bJustMade=false;
			}
			thisinv = thisinv.inventory;
			Count++;
			if (Count > 5000)
				break;
		}

		// Note that we got our default inventory
		bGotDefaultInventory = true;
		//log(self$" initting for new level, game info diff "$P2GameInfoSingle(Level.Game).GameDifficulty$" game state diff "$P2GameInfoSingle(Level.Game).TheGameState.GameDifficulty$" GET game state diff "$P2GameInfoSingle(Level.Game).GetGameDifficulty());
	}
}

///////////////////////////////////////////////////////////////////////////////
// return true if was controlled by a Player (AI or human)
///////////////////////////////////////////////////////////////////////////////
simulated function bool WasPlayerPawn()
{
	return ( (OldController != None) && OldController.bIsPlayer );
}

function Controller GetKillerController()
{
	if ( Controller != None )
		return Controller;
	if ( OldController != None )
		return OldController;
	return None;
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	if ( (OldController != None) && (OldController.PlayerReplicationInfo != None) )
		return OldController.PlayerReplicationInfo.Team;
	return None;
}

simulated function Tick(float DeltaTime)
{
	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Controller != None )
		OldController = Controller;
	Super.Tick(DeltaTime);
}

simulated function ClientRestart()
{
	Super.ClientRestart();
	if ( Controller != None )
		OldController = Controller;
}

///////////////////////////////////////////////////////////////////////////////
// Make sure if they are crouching they don't fall through the ground when
// newly dead. (This only seems to be a problem in MP)
///////////////////////////////////////////////////////////////////////////////
simulated function PopUpDead()
{
	local vector OldLocation;

	OldLocation = Location;
	OldLocation.z += POP_UP_HACK_VAL;
	SetLocation(OldLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DestoryArmorMesh()
{
	if(ArmorMesh != None)
	{
		DetachFromBone(ArmorMesh);
		ArmorMesh.Destroy();
		ArmorMesh=None;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Change textures/icons/models if we're wearing armor
///////////////////////////////////////////////////////////////////////////////
function UsingNewArmor(Texture HudArmorIcon, 
					   class<Inventory> HudArmorClass)
{
	local float ArmorPer, UseMax;

	Super.UsingNewArmor(HudArmorIcon, HudArmorClass);

	// Check the armor for the third person mesh to spawn for him
	if(ArmorMesh == None
			|| class<KevlarInv>(HudArmorClass).default.ArmorMeshClassClean != ArmorMesh.class)
	{
		// Get rid of old one (if we have one)
		DestoryArmorMesh();
		UseMax = class<KevlarPickup>(HudArmorClass.default.PickupClass).default.ArmorAmount;
		ArmorPer = Armor/UseMax;
		// Make new one. We have to check how much armor we're picking up. It could be
		// less than full.
		if(ArmorPer > DAMAGE_THRESH_1)
		{
			// clean armor has a small range down to the first threshold
			ArmorMesh = spawn(class<KevlarInv>(HudArmorClass).default.ArmorMeshClassClean, self);
			if(ArmorMesh != None)
				AttachToBone(ArmorMesh, VEST_BONE_NAME);
		}
		else if(ArmorPer <= DAMAGE_THRESH_1
			&& ArmorPer > DAMAGE_THRESH_2)
		{
			// slightly damaged
			DestoryArmorMesh();
			ArmorMesh = spawn(class<KevlarInv>(P2Player(Controller).HudArmorClass).default.ArmorMeshClassDam1, self);
			if(ArmorMesh != None)
				AttachToBone(ArmorMesh, VEST_BONE_NAME);
		}
		else
		{
			// heavily damaged
			DestoryArmorMesh();
			ArmorMesh = spawn(class<KevlarInv>(P2Player(Controller).HudArmorClass).default.ArmorMeshClassDam2, self);
			if(ArmorMesh != None)
				AttachToBone(ArmorMesh, VEST_BONE_NAME);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// ReduceArmor
// Take away some armor
///////////////////////////////////////////////////////////////////////////////
function ReduceArmor(float ArmorDamage, Vector HitLocation)
{
	local float beforeper, afterper, UseMax;

	if(Health > 0)
	{
		// Grab the armor max out of the pickup class, stored in the inventory that's stored
		// in the player -- long!
		UseMax = class<KevlarPickup>((P2Player(Controller).HudArmorClass).default.PickupClass).default.ArmorAmount;
		beforeper = Armor/UseMax;

		Super.ReduceArmor(ArmorDamage, HitLocation);

		afterper = Armor/UseMax;

		if(P2Player(Controller) != None
			&& Armor > 0)
		{
			// Change armor as it gets damage (delete the old one and make a new one)
			if(beforeper > DAMAGE_THRESH_1
				&& afterper <= DAMAGE_THRESH_1)
			{
				DestoryArmorMesh();
				ArmorMesh = spawn(class<KevlarInv>(P2Player(Controller).HudArmorClass).default.ArmorMeshClassDam1, self);
				if(ArmorMesh != None)
					AttachToBone(ArmorMesh, VEST_BONE_NAME);
			}
			else if(beforeper > DAMAGE_THRESH_2
				&& afterper <= DAMAGE_THRESH_2)
			{
				DestoryArmorMesh();
				ArmorMesh = spawn(class<KevlarInv>(P2Player(Controller).HudArmorClass).default.ArmorMeshClassDam2, self);
				if(ArmorMesh != None)
					AttachToBone(ArmorMesh, VEST_BONE_NAME);
			}
		}
	}

	if(Armor == 0)
	{
		DestoryArmorMesh();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Get rid of any armor meshes we may have on
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	DestoryArmorMesh();

	Super.Died(Killer, damageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Dying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// prone body should have low height, wider radius
	///////////////////////////////////////////////////////////////////////////////
	function ReduceCylinder()
	{
		local vector OldLocation;

		SetCollision(bCollideActors,False,False);
		SetCollisionSize(CollisionRadius, CarcassCollisionHeight);
	}
}


defaultproperties
	{
	bRandomizeHeadScale=false	// don't let head scale or it may clip with helmets

	ControllerClass=class'MultiBase.Bot'

//	GameObjOffset=(x=15,Y=16,Z=0)
//	GameObjRot=(Pitch=32768,Yaw=16384,Roll=-16384)
	GameObjOffset=(x=0,Y=0,Z=0)
	GameObjRot=(Pitch=0,Yaw=0,Roll=0)

	MaxFallSpeed=2000

	DudeSuicideSound = Sound'WMaleDialog.wm_postal_forgiveme'

	CrouchHeight=+52.0
	CrouchRadius=+25.0

	CarcassCollisionHeight=35.00000

	HeadClass=class'MPHead'
	}
