//ProtestSign weapon.  -MrD

class ProtestSignWeapon extends ProtestSignWeaponBase;

var ProtestSign A;

// Change by NickP: MP fix
var Texture InvisSkinTex;
// End

///////////////////////////////////////////////////////////////////////////////
// Set the texture that would handle the blood
///////////////////////////////////////////////////////////////////////////////
function SetBloodTexture(Material NewTex)
{
// Change by Man Chrzan: Commented out to not change our various skins
//	if (A != None)
//		A.Skins[BloodSkinIndex] = NewTex;
}

///////////////////////////////////////////////////////////////////////////////
// Remove all blood from blade
///////////////////////////////////////////////////////////////////////////////
function CleanWeapon()
{
// Change by Man Chrzan: Commented out to not change our various skins 
//	BloodTextureIndex = 0;
//	SetBloodTexture(A.default.Skins[BloodSkinIndex]);
	//log(self$" clean weapon "$BloodTextureIndex$" new skin "$Skins[1]);
}


// Attach protest sign to pawn. If they're protesting, don't set the relative location/rotation (messes up the third-person protest anim)
simulated function AttachToPawn(Pawn P)
{
	local name BoneName;

	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}
	BoneName = P.GetWeaponBoneFor(self);
	if ( BoneName == '' )
	{
		ThirdPersonActor.SetLocation(P.Location);
		ThirdPersonActor.SetBase(P);
	}
	else
		P.AttachToBone(ThirdPersonActor,BoneName);

	if (!P.Controller.IsInState('ProtestToTarget'))
	{
		ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
		ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
	}

	if (ProtestSkin != None)
	{
		if (A != None)
			A.Skins[0] = ProtestSkin;
		if (ThirdPersonActor != None)
			ThirdPersonActor.Skins[0] = ProtestSkin;
	}
}

simulated function PostNetBeginPlay()
{
	// Change by NickP: MP fix
    /*local PlayerController PC;
	local Pawn P;

    Super.PostNetBeginPlay();

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

   	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
	{
        A = Spawn(Class'P2R.ProtestSign');
        AttachToBone( A, 'shuvel' );
    }
   	else
	{
		if(Instigator != None)
	   {
		 if(Instigator.Mesh != None
			&& A != None)
		 {

             A.Destroyed();
             A = None;
			}
	   }
	}*/
	Super.PostNetBeginPlay();
	AttachFPPart();
	// End
}

// Change by NickP: MP fix
simulated function AttachFPPart()
{
    local PlayerController PC;
	local Pawn P;

    P  = Pawn(Owner);
	PC = PlayerController(P.Controller);

	if( P.IsLocallyControlled() && PC != None && !PC.bBehindView )
	{
		if( A == None )
			A = Spawn(class'ProtestSign',self);
		AttachToBone(A, 'shuvel');
	}

	if( A != None && A.AttachmentBone == '' )
		A.Skins[0] = InvisSkinTex;
}

simulated function BringUp()
{
    Super.BringUp();
	AttachFPPart();
}
// End

///////////////////////////////////////////////////////////////////////////////
// Toss this item out.
//
// Same as DropFrom in Inventory.uc, but we pass the instigator along to
// the spawned pickup as its owner, because we want to know who most recently
// dropped this for persistance
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	local Pickup P;
	local Inventory Inv;
	local bool bAmmoInUse;

	// 11/18 - don't drop weapons for a dead dude
	if ((Instigator.IsA('Dude') || Instigator.IsA('AWDude'))
		&& Instigator.Health <= 0)
		return;

	// spawn it earlier, so the instigator isn't cleared yet.
	P = spawn(PickupClass,Instigator,,StartLocation);

	if(P != None)
	{
		if(P != None)
			P.Instigator = Instigator;

		// Remove the weapon from the inventory
		if ( Instigator != None )
		{
			DetachFromPawn(Instigator);
		}
		// Remove the ammo from the inventory
		// But only if it's not being used
		bAmmoInUse = false;
		if ( Instigator != None )
		{			
			for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
			{				
				if (Inv != Self
					&& Weapon(Inv) != None
					&& Weapon(Inv).AmmoType == AmmoType)
				{
					bAmmoInUse = true;
					break;
				}
			}
			
			if (!bAmmoInUse)
				AmmoType.DetachFromPawn(Instigator);
		}

		ClientWeaponThrown();
		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
		{
			Instigator.DeleteInventory(self);
			// Only clear this out too if your still alive, if not
			// then don't clear it because it will break the link in
			// P2GameInfo as DiscardInventory drops everything (and
			// it wouldn't matter anyway, because your dead).
			// If we don't have this, then in SP you can drop your weapons
			// and pick them back up for double the ammo--bad!
			if(Instigator.Health > 0)
			{
				if(AmmoType != None
					&& !bAmmoInUse)
					Instigator.DeleteInventory(AmmoType);
			}
		}

		SetDefaultDisplayProperties();
		Inventory = None;
		StopAnimating();
		bTossedOut = true;
		if(P != None)
		{
			P.Skins[0] = ProtestSkin;
			P2WeaponPickup(P).bTossedOut=true;
			P.InitDroppedPickupFor(self);
			if(!P.bDeleteMe)
				P.Velocity = Velocity;
		}

		Velocity = vect(0,0,0);
		Instigator = None;
		Destroy();
		//A.Destroyed(); // Change by NickP: MP fix
	}	

	// Change by NickP: MP fix
	if( A != None )
	{
		DetachFromBone(A);
		A.Destroy();
		A = None;
	}
	// End
}

simulated function Destroyed()
{
   Super.Destroyed();

  if( A != None )
  {
    DetachFromBone(A);
    A.Destroy();
    A = None;
  }
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzn: xPatch 2.0
// Setup the weapon skin to match it's pickup
///////////////////////////////////////////////////////////////////////////////
state Active
{
	function BeginState()
	{
		Super.BeginState();
		SetupSign(ProtestSkin);
	}
}

function SetupSign(Material ProtestSkin)
{
	if (ProtestSkin != None)
	{
		if (A != None)
			A.Skins[0] = ProtestSkin;
		if (ThirdPersonActor != None)
			ThirdPersonActor.Skins[0] = ProtestSkin;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
	// Change by NickP: MP fix
	InvisSkinTex=Shader'P2R_Tex_D.Weapons.fake'
	// End

	GroupOffset=68 //owe ya one.
	AmmoName=Class'ProtestSignAmmoInv'
	PickupClass=Class'ProtestSignPickup'
	AttachmentClass=Class'ProtestSignAttachment'
	Mesh=SkeletalMesh'P2R_Anims_D.MP_LS_ShovelSign'
	Skins[0]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	Skins(1)=Shader'P2R_Tex_D.Weapons.fake'

	// Make it a bit faster than the shovel, since it's lighter
	WeaponSpeedHolster = 1.75
	WeaponSpeedLoad    = 1.25
	WeaponSpeedReload  = 1.25
	WeaponSpeedShoot1  = 1.4
	WeaponSpeedShoot1Rand=0.1
	WeaponSpeedShoot2  = 1.7
	ThirdPersonRelativeRotation=(Pitch=5000,Roll=2000)
	ItemName="Protest Sign"
	BloodTextures[0]=Texture'WeaponSkins_Bloody.protest19_blood01'
	BloodTextures[1]=Texture'WeaponSkins_Bloody.protest19_blood02'
	BloodSkinIndex=0
}
