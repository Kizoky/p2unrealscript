
class xNPCUrethraWeapon extends UrethraWeapon;

const FEM_PEE_BONE = 'MALE01 pelvis';


///////////////////////////////////////////////////////////////////////////////
// Attach to pawn
///////////////////////////////////////////////////////////////////////////////
simulated function AttachToPawn(Pawn P)
{
	local name BoneName;

	if(AttachmentClass != None)
	{
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
			P.AttachToBone(ThirdPersonActor,FEM_PEE_BONE);

		ThirdPersonActor.SetRelativeLocation(ThirdPersonRelativeLocation);
		ThirdPersonActor.SetRelativeRotation(ThirdPersonRelativeRotation);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide and spawn the actual stream
///////////////////////////////////////////////////////////////////////////////
function SpawnStream()
{
	if(UrethraAmmoInv(AmmoType)==None)
		return;

	// Make sure the old one is done
	ForceEndFire();

	if(P2GameInfoSingle(Level.Game) != None)
		UrineStream = spawn(class'UrinePourFeeder',Instigator,,,Rotation);
	else
		UrineStream = spawn(class'UrinePourFeederMP',Instigator,,,Rotation);
	// Make sure the all versions of piss can still trigger urine buckets (like in the piss on dad's grave errand)
	UrineStream.MyDamageType=class'UrinePourFeeder'.default.MyDamageType;

	//UrineStream.MyOwner = Instigator;
	SnapUrineStreamToGun(true);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	AutoSwitchPriority=1
	InventoryGroup=1
	ViolenceRank=1
	MaxRange=150
	ThirdPersonRelativeLocation=(Y=-20)
}
