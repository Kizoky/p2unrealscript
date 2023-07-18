///////////////////////////////////////////////////////////////////////////////
// p2 weapon attachment
// Buffer class just in case, between WeaponAttachment and our
// own weapon attachments. WeaponAttachments are the new visual representation
// of the weapon a 3rd person character.
//
// Taken mainly from WarfareWeaponAttachment in warfare 927.
//
///////////////////////////////////////////////////////////////////////////////
class P2WeaponAttachment extends WeaponAttachment
	abstract;

var MuzzleFlashAttachment MuzzleFlash3rd;
var class<MuzzleFlashAttachment> MuzzleFlashClass;
var vector MuzzleOffset;
var rotator MuzzleRotationOffset;
var class<P2Weapon> WeapClass;			// Type of weapon we represent

var vector HitLoc;						// Used to say where a trace hit occured
var vector EffectLocationOffset[2];		// Used for 1st person vs 3rd person Effects

// Weapon attachment gets it's ThirdPersonEffects called on all remote
// clients all the time when things are fired. Instead of having PlayOwnedSound
// *also* getting replicated to all remote clients to play the firing sound
// for fast-firing things like guns, I put it into here. It's messier, but
// it saves bandwidth.
var Sound FireSound;

// xPatch: Cat Silencer in 3rd person baby!
var xCatSilencer CatSilencer3rd;
var() vector CatOffset;

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		HitLoc,EffectLocationOffset;
		
	reliable if (bNetDirty && Role==ROLE_Authority)
		MuzzleFlash3rd;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Adjust(int Person, vector Adjustment)
{
	EffectLocationOffset[Person] = EffectLocationOffset[Person]+Adjustment;

	if (Person==0)
		log("#### New 3rd Person Offset: "$EffectLocationOffset[Person]);
	else
		log("#### New 1st Person Offset: "$EffectLocationOffset[Person]); 
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	local name BoneName;
	local Pawn P;
	
	Super.PostBeginPlay();

	P = Pawn(Owner);
	
	if (P!=None && MuzzleFlashClass!=None)
	{
		MuzzleFlash3rd = spawn(MuzzleFlashClass,Owner);
		BoneName = P.GetWeaponBoneFor(P.Weapon);
		if (BoneName == '')
		{
			MuzzleFlash3rd.SetLocation(P.Location);
			MuzzleFlash3rd.SetBase(P);
		}
		else
			P.AttachToBone(MuzzleFlash3rd,BoneName);

		MuzzleFlash3rd.SetRelativeRotation(MuzzleRotationOffset);
		MuzzleFlash3rd.SetRelativeLocation(MuzzleOffset);
	}

	// By default, go into stasis, because you don't usually use timers, or animate, as an attachment.
	bStasis=true;

	if(Weapon(Owner) != None)
		Weapon(Owner).FlashCount=0;
	if(Instigator != None)
		Instigator.FlashCount=0;
}


///////////////////////////////////////////////////////////////////////////////
// Handles updatting the attachment in the pawn which effects the anims.
///////////////////////////////////////////////////////////////////////////////
simulated function UpdatePawnAttachment(bool bClear)
{
	local P2Pawn p2p;

	if(Level.NetMode == NM_Client
		&& !bNetOwner)
	{
		p2p = P2Pawn(Owner);
		if(p2p != None
			&& p2p.Weapon == None)
		{
			if(!bClear)
				p2p.MyWeapAttach = self;
			else
				p2p.MyWeapAttach = None;
			p2p.ChangeAnimation();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Only in MP, on the non-local client should this matter. Then, when Pawn.Weapon
// is invalid, the pawn won't be able to get the hold style out for animations.
// so instead, we can reproduce it here.
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	UpdatePawnAttachment(false);

	if(Instigator != None)
	{
		Instigator.FlashCount=0;
		if(Instigator.Weapon != None)
			Instigator.Weapon.FlashCount=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Network backups for when the weapon doesn't exist on the non-local client
///////////////////////////////////////////////////////////////////////////////
simulated function EWeaponHoldStyle GetHoldStyle()
{
	return WeapClass.default.holdstyle;
}
simulated function EWeaponHoldStyle GetSwitchStyle()
{
	return WeapClass.default.switchstyle;
}
simulated function EWeaponHoldStyle GetFiringStyle()
{
	return WeapClass.default.firingstyle;
}

///////////////////////////////////////////////////////////////////////////////
// When you're destroyed, change the MyWeapAttach so the hold style will
// default to nothing.
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	UpdatePawnAttachment(true);

	if (MuzzleFlash3rd!=None)
	{
		if(Pawn(Owner) != None)
			Pawn(Owner).DetachFromBone(MuzzleFlash3rd);
		MuzzleFlash3rd.Destroy();
		MuzzleFlash3rd = None;
	}
	SwapCatOff(); // xPatch
	
	Super.Destroyed();
}

simulated function GetEffectStart(out vector Start, out rotator Rot)
{
	local PlayerController PC;
	local Pawn P;
	local vector x,y,z,S,E;
	local coords C;
	//local barrel b;

	P  = Pawn(Owner);
	PC = PlayerController(P.Controller); 

	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
		Start = Instigator.Weapon.Location + EffectLocationOffset[1];
	else
	{
		C = Instigator.GetBoneCoords(Instigator.GetWeaponBoneFor(None));
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		Start = C.Origin + (X*EffectLocationOffset[0].X) + (Y*EffectLocationOffset[0].Y) + (Z*EffectLocationOffset[0].Z);

	}
	Rot = Instigator.GetViewRotation();
}	

simulated function float GetRandPitch()
{
	if(WeapClass != None)
		return WeapClass.default.WeaponFirePitchStart + (FRand()*WeapClass.default.WeaponFirePitchRand);
	else
		return 1.0;
}

simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
	
	// xPatch: Bug Fix
	if (MuzzleFlash3rd == None 
		&& MuzzleFlashClass != None)
		PostBeginPlay();
	// End

	if (MuzzleFlash3rd!=None 
		&& CatSilencer3rd == None)
	{
		MuzzleFlash3rd.Flash();

		// Play MP sounds on everyone's computers
		if(FireSound != None
			&& MuzzleFlash3rd.GetStateName() == 'Visible'
			&& (Level.Game == None
				|| !FPSGameInfo(Level.Game).bIsSinglePlayer))
			Instigator.PlaySound(FireSound, SLOT_None, 1.0, true, TransientSoundRadius, GetRandPitch());
	}
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: add our awesome cat silencer
///////////////////////////////////////////////////////////////////////////////
simulated function SwapCatOn()
{
	local name BoneName;
	local vector GetCatOffset;
	local Pawn P;
	
	P = Pawn(Owner);
	
	if (P!=None)
	{
		BoneName = P.GetWeaponBoneFor(P.Weapon);
		if (BoneName == '')
			return;
			
		if(CatOffset.X == 0 
		&& CatOffset.Y == 0 
		&& CatOffset.Z == 0)
			GetCatOffset = MuzzleOffset;
		else
			GetCatOffset = CatOffset;
		
		CatSilencer3rd = spawn(Class'xCatSilencer',Owner);
		P.AttachToBone(CatSilencer3rd,BoneName);
		CatSilencer3rd.SetRelativeRotation(MuzzleRotationOffset);
		CatSilencer3rd.SetRelativeLocation(GetCatOffset);
	}
}

simulated function SwapCatOff()
{
	if(CatSilencer3rd != None)
	{
		if(Pawn(Owner) != None)
			Pawn(Owner).DetachFromBone(CatSilencer3rd);
		CatSilencer3rd.Destroy();
		CatSilencer3rd = None;
	}
}

defaultproperties
{
	TransientSoundRadius=100
}
