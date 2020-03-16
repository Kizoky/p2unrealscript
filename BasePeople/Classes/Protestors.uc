//=============================================================================
// Protestors
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all protestor characters.
//
//=============================================================================
class Protestors extends Marchers
	notplaceable
	Abstract;
	
///////////////////////////////////////////////////////////////////////////////
// Vars, consts, structs, etc
///////////////////////////////////////////////////////////////////////////////
var Material ProtestSignSkin;
var Material DefaultProtestTex;
var StaticMesh ExpectedProtestSign;
var String ProtestSignClass;
	
///////////////////////////////////////////////////////////////////////////////
// PreBeginPlay
// If they're carrying a skinnable protest sign, remove it from the boltons
// and have them carry the actual protest sign weapon
///////////////////////////////////////////////////////////////////////////////
event PreBeginPlay()
{
	local class<Inventory> UseClass;
	
	if (Boltons[0].StaticMesh == ExpectedProtestSign
		&& Boltons[0].Skin != None
		&& Boltons[0].Skin != DefaultProtestTex)
	{
		Boltons[0].bInActive = true;
		ProtestSignSkin = Boltons[0].Skin;

		// Don't screw with their weapon loadout if they have something else set
		if (BaseEquipment.Length == 1)
		{
			UseClass = class<Inventory>(DynamicLoadObject(ProtestSignClass, class'Class'));
			if (UseClass != None)
			{
				BaseEquipment.Length = 2;
				BaseEquipment[1].WeaponClass = BaseEquipment[0].WeaponClass;
				BaseEquipment[0].WeaponClass = UseClass;
				CloseWeaponIndex = 0;
				FarWeaponIndex = 1;
				WeapChangeDist = 150;
			}
		}
	}
	
	Super.PreBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// PawnSpawner sets some things for you
// The spawer can set the skin of the thing spawned. If they set a specific
// skin, then make sure we go through and set all the gender/race attributes
// associated with this specific skin. Reinit the head once we got the new
// skin.
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	// Nine times out of ten, spawning in a new protestor means he's just going to go attack the dude.
	// Turn off the bolton if it's still there.
	DestroyBolton(0);
	Super.InitBySpawner(InitSP);
}
	
///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	local Inventory Inv;
	Super.AddDefaultInventory();
	
	// If they have a protest sign, set its skins accordingly
	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		if (ProtestSignWeaponBase(Inv) != None)
			ProtestSignWeaponBase(Inv).ProtestSkin = ProtestSignSkin;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Confused before next state 
// Generally be confused then do your next state, like attack the guy
// you were confused about
// Requires InterestVect be set first for the focal point interest
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state ConfusedByDanger
{
	///////////////////////////////////////////////////////////////////////////////	
	///////////////////////////////////////////////////////////////////////////////
	function bool SayWhat()
	{
		return true;
	}
}

defaultproperties
	{
	ActorID="Protestor"
	ControllerClass=class'ProtestorController'
	bIsTrained=false
	// give protestors a picket sign (derived classes can assign different skins)
	Boltons[0]=(staticmesh=staticmesh'timb_mesh.items.picket_timb',bCanDrop=true)
	// protestors are always armed (imagine that)
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	Gang="Protestors"
	Psychic=0.15
	Talkative=0.0
	Cajones=1.0
	Rebel=1.0
	PainThreshold=1.0
	ViolenceRankTolerance=1
	
	ExpectedProtestSign=StaticMesh'Timb_mesh.Items.picket_timb'
	DefaultProtestTex=Texture'Timb.picket.protest19'
	ProtestSignClass="P2R.ProtestSignWeapon"
	}
