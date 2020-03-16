///////////////////////////////////////////////////////////////////////////////
// ChainSaw Weapon
//
// Requires some special coding since we use gascan ammo.
///////////////////////////////////////////////////////////////////////////////
class ChainsawWeapon extends P2WeaponStreaming;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var() sound IdleSound;								// sound made during idle
var() sound HitWallSound;							// Hit-wall sound
var() array<sound> BodySound;						// Hit-body sound
var() class<DamageType> DamageTypeInflicted;		// damage type
var() class<DamageType> BodyDamage;					// body damage
var() float DamageAmount;							// damage amount
var() float SeverMag;								// sever momentum
var() float MomentumHitMag;							// hit momentum
var() class<TimedMarker> IdleMarkerMade;	// timed marker we constantly throw while making chainsaw noises
var() sound PrepStartSound;							// Prep start sound
var() sound PrepEndSound;							// Prep end sound
var() sound PullCordSound1;							// Pull cord sound
var() sound PullCordSound2;							// Pull cord sound

var float CurrentDelta;
var float MaxDelta;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
const HEAD_OFFSET	=	10.0;
const PAWN_NECK		=	'MALE01 neck';

const SHOOTDOWN1	=	'Shoot1Down1';
const SHOOTDOWN2	=	'Shoot1Down2';
const SHOOTLEFT		=	'Shoot1Left';
const SHOOTRIGHT	=	'Shoot1Right';

// Prep sounds.
// Only play if the dude actually stopped on us and is going to use us, not if he's cycling through.
function Notify_PlayPullCord1()
{
	if (Instigator.Weapon == Self)
		Instigator.PlaySound(PullCordSound1, SLOT_None, 1.0, true);
}
function Notify_PlayPullCord2()
{
	if (Instigator.Weapon == Self)
		Instigator.PlaySound(PullCordSound2, SLOT_None, 1.0, true);
}
function Notify_PlayPrepStart()
{
	if (Instigator.Weapon == Self)
		Instigator.PlaySound(PrepStartSound, SLOT_None, 1.0, true);
}
function Notify_PlayPrepEnd()
{
	if (Instigator.Weapon == Self)
		Instigator.PlaySound(PrepEndSound, SLOT_None, 1.0, true);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientMacheteShake(bool bHitSolid)
{
	local P2Player p2p;

	p2p = P2Player(Instigator.Controller);
	if (p2p!=None)
	{
		if(bHitSolid)
			p2p.ShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, 
						ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
		else
			// Don't shake it as hard if we hit something not so solid
			p2p.ShakeView(ShakeRotMag/2, ShakeRotRate, ShakeRotTime/2,
						ShakeOffsetMag/2, ShakeOffsetRate, ShakeOffsetTime/2);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Use the distance between our guy and the HitPawn, take that magnitude
// and mult it by the direction the guy is facing, plus his aiming position in the world (startpt)
///////////////////////////////////////////////////////////////////////////////
function vector GetHitLocation(vector Xdir, vector StartPt, vector EndPt, FPSPawn HitPawn,
							   vector hitloc, out byte SeverHit)
{
	local float usedist, aimdot, dirdot;
	local vector usev, aimcross;
	local rotator userot;
	local coords usecoords;

	if(HitPawn.Health > 0)
	{
		usev = StartPt - HitPawn.Location;
		usev.z=0;
		aimdot = Normal(usev) dot vector(Instigator.Rotation);
		aimcross = usev cross vector(Instigator.Rotation);
		dirdot = Normal(usev) dot vector(HitPawn.Rotation);

		// check to cut off head
		usecoords = HitPawn.GetBoneCoords(PAWN_NECK);

		// hit head
		if(hitloc.z > (usecoords.origin.z - HEAD_OFFSET))
		{
			SeverHit=1;
			return hitloc;
		}
		else
		{
			const DIR_DOT_MAX	=	0.8;	// angle the player is around the character
											// if he's off to the side facing the arm, this
											// allows him to chop off the arm, even though aimdot says
											// he's aiming straight at the torso (which he is, but an
											// arm is in the way)
			const LEG_Z			=	25.0;	// how much further down the torso someone's legs are
			// If it's below the legs, then let it chop off anything anyway, or if it's
			// on the sides, then chop off the arm, otherwise, hit the torso
			usev = HitPawn.Location;
			usev.z -= LEG_Z;
			if(hitloc.z < (usev.z)
				|| aimdot > -0.995
				|| (dirdot > -DIR_DOT_MAX
					&& dirdot < DIR_DOT_MAX))
			{
				// if dirdot*aimcross.z is negative, they want the pawns left side
				if(dirdot*aimcross.z < 0)
				{
					userot = HitPawn.Rotation;
					userot.Yaw-=16383;
					usev = HitPawn.Location + 2*HitPawn.CollisionRadius*vector(userot);
					hitloc.x = usev.x;
					hitloc.y = usev.y;
					SeverHit=1;
					// keep the z height the same
					return hitloc;
				}
				else // otherwise, they want the right
				{
					userot = HitPawn.Rotation;
					userot.Yaw+=16383;
					usev = HitPawn.Location + 2*HitPawn.CollisionRadius*vector(userot);
					hitloc.x = usev.x;
					hitloc.y = usev.y;
					SeverHit=1;
					// keep the z height the same
					return hitloc;
				}
			}
			else // hit middle of body, no sever
			{			
				return hitloc;
			}
		}
	}
	else // Dead pawn, use average distance forward as hit point--it's a straight
		// forward shot from the dude's aim. The pawn will figure out which 
		// bone it probably hit
	{
		SeverHit = 1;
		return EndPt;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function DoHit( float Accuracy, float YOffset, float ZOffset )
{
	// Do a sphere test around where the weapon projects, and try to hurt stuff there
	local vector markerpos, markerpos2;
	local bool secondary;

	local vector HitLocation, HitNormal, StartTrace, EndTrace, StraightX, X,Y,Z, ExtendTrace;
	local actor FirstHit;
	local actor Victims;
	local FPSPawn PawnHit, CheckPawn;
	local float dist, UseTime, checkdist, fardist;
	local vector dir;
	local bool bDeliverDirectDamage;
	local bool bHitSomething, bHitSolid, bHitDoor;
	local byte SeverHit;

//	log(self@"dohit accuracy"@accuracy@"yoffset"@yoffset@"zoffset"@zoffset);

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);

//	log(self@"instigator viewrot"@Instigator.GetViewRotation()@"axes x"@X@"Y"@Y@"Z"@Z@"melee dist"@usemeleedist);

	StartTrace = GetFireStart(X,Y,Z);
	EndTrace = StartTrace + X*UseMeleeDist;
	ExtendTrace = EndTrace + X*UseMeleeDist;

//	log(self@"trace start"@StartTrace@"end trace"@EndTrace@"extend trace"@ExtendTrace);

	// This performs the collision but also records where it hit and records it
	FirstHit = Trace(LastHitLocation,HitNormal,ExtendTrace,StartTrace,true);
	if(FirstHit != None)
	{
		bDeliverDirectDamage=true;
		if(FirstHit.bStatic)
			bHitSolid=true;
		// If we hit a pawn, record that too
		else if(FPSPawn(FirstHit) != None)
			//&& FPSPawn(FirstHit).Health > 0)
			PawnHit = FPSPawn(FirstHit);
		// If we hit a door, don't let us hurt a person who may be on the FirstHit side
		// as we kick it open, if we are indeed kicking it open.
//		else if(DoorMover(FirstHit) != None
//			&& bStopAtDoor)
//			bHitDoor=true;

		// Handle hitting pawns later down the function
		if(PawnHit == None)
		{
			// Process the damage here
			ProcessTraceHit(FirstHit, LastHitLocation, HitNormal, X,Y,Z);
			bHitSomething=true;
		}
	}

	// If we didn't hit a door first, or a pawn, try to hit more
	if(!bHitDoor)
	{
		fardist = 2*UseMeleeDist;
		foreach VisibleCollidingActors( class 'Actor', Victims, UseMeleeDist, EndTrace )
		{
			if( (Victims != self)
				&& (!Victims.bStatic)
				&& (Victims.bCollideWorld)
				&& (Victims != Instigator)
				&& (Victims.Role == ROLE_Authority)
				&& (FirstHit != Victims))	// handle the straight forward hits below
			{
				// If it's friendly pawn, don't let this 'wide area collision check' hurt
				// them. Only let the above, direct check hurt them. If it's any other pawn
				// or anything else in general, hurt it. This is so it's harder to accidentally
				// hurt your friends with the wide bludgeoning attacks.
				if(FPSPawn(Victims) == None
					|| !FPSPawn(Victims).bPlayerIsFriend)
				{
					// Save the first thing we hit, so we can alert other people about the hit
					if(!bDeliverDirectDamage
						&& FirstHit == None)
					{
						FirstHit = Victims;
						LastHitLocation = Victims.Location;
					}

					if(FPSPawn(Victims) != None)
					// If we hit a pawn, record that too
					{
						checkdist = VSize(Victims.Location - EndTrace);
						if(checkdist < fardist
							&& FPSPawn(Victims) != None)
							//&& FPSPawn(Victims).Health > 0)
						{
							fardist = checkdist;
							CheckPawn = FPSPawn(Victims);
						}
					}
					else // if we hit anything else, say so
					{
						if(Victims.bStatic)
							bHitSolid=true;
						bHitSomething=true;
						// Check to deliver damage
						dir = Victims.Location - EndTrace;
						dist = FMax(1,VSize(dir));
						dir = dir/dist;

						ProcessTraceHit(Victims, 
										EndTrace,
										HitNormal, X,Y,Z);
					}
				}
			}
		}
	}
	if(CheckPawn != None)
		PawnHit = CheckPawn;

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(PawnHit != None)
	{
		bHitSolid=false;
		bHitSomething=true;

		HitLocation = GetHitLocation(X, StartTrace, EndTrace, PawnHit, ExtendTrace, SeverHit);

		// Process the damage here
		if(SeverHit == 1
			&& PersonPawn(PawnHit) != None)
			ProcessSeverHit(PawnHit, HitLocation, HitNormal, X,Y,Z);
		else
			ProcessTraceHit(PawnHit, HitLocation, HitNormal, X,Y,Z);
	}

	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientMacheteShake(bHitSolid);
		}
	}
	// If we didn't hit anything, we may want to do something about it
	//  That is, we want to tell people we were swinging/kicking in mid-air
//	else
//		HitNothing();

	// Say we just fired
	ShotCount++;
	
	// Set your enemy as the one you attacked.
	if(P2Player(Instigator.Controller) != None
		&& PawnHit != None
		&& PawnHit.Health > 0)
	{
		P2Player(Instigator.Controller).Enemy = PawnHit;
	}

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None)
		{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;
		
		// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
		if(PawnHit != None
			&& PawnHit.Health > 0
			&& PawnHitMarkerMade != None)
			{
			PawnHitMarkerMade.static.NotifyControllersStatic(
				Level,
				PawnHitMarkerMade,
				FPSPawn(Instigator),
				FPSPawn(Instigator), // We want the creator to be instigator also
				// because this is much more like a gunfire sort of thing, rather than a pawn hit by
				// a bullet
				PawnHitMarkerMade.default.CollisionRadius,
				PawnHit.Location);
			}
		}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local SmokeHitPuff smoke1;
	local DirtClodsMachineGun dirt1;
	local SparkHitMachineGun spark1;
	local Rotator NewRot;
	local vector Momentum;
	local byte BlockedHit;

//	log(self@"processtracehit other"@other@"hitloc"@hitlocation@"normal"@hitnormal@"x"@x@"y"@y@"z"@z);

	if ( Other == None )
		return;

	// Check if they're allowed to hit the person they did, if not, None out Other
	// so it's like a wall hit
	if(P2MoCapPawn(Other) != None)
	{
		// Instead of using hit location, ensure the block knows it comes from the
		// attacker originally, so use the weapon's owner
		P2MoCapPawn(Other).CheckBlockMelee(Owner.Location, BlockedHit);
		if(BlockedHit == 1)
			Other = None;	// don't let them hit Other!
	}

	if(Pawn(Other) == None
		&& PeoplePart(Other) == None)
	{
		// randomly orient the splat on the wall (rotate around the normal)
		NewRot = Rotator(-HitNormal);
		NewRot.Roll=(65536*FRand());

		smoke1 = Spawn(class'Fx.SmokeHitPuffMelee',Owner,,HitLocation, Rotator(HitNormal));
		if(FRand()<0.3)
		{
			dirt1 = Spawn(class'Fx.DirtClodsMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
		if(FRand()<0.15)
		{
			spark1 = Spawn(class'Fx.SparkHitMachineGun',Owner,,HitLocation, Rotator(HitNormal));
		}
	}


	if ( (Other != self) && (Other != Owner) )
	{
		// Sever limbs first (sever people is picked in the machete weapon itself)
		if(PeoplePart(Other) != None)
		{
			Momentum = SeverMag*(-X + VRand()/2);
			if(Momentum.z<0)
				Momentum.z=-Momentum.z;
			Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
		}
		else
		{
			if(FPSPawn(Other) == None
				|| HurtingAttacker(FPSPawn(Other)))
			{
				Momentum = -MomentumHitMag*(Z/2);

				Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, BodyDamage);
			}
		}

		if(FPSPawn(Other) != None
			|| PeoplePart(Other) != None)
		{
			Instigator.PlayOwnedSound(BodySound[Rand(BodySound.Length)], SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
		else
		{
			if(smoke1 != None
				&& Level.Game != None
				&& FPSGameInfo(Level.Game).bIsSinglePlayer)
				smoke1.PlaySound(HitWallSound, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
			else
				Instigator.PlayOwnedSound(HitWallSound, SLOT_None, 1.0,,TransientSoundRadius,GetRandPitch());
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// If it's a person using a weapon, make sure they only hurt their
// attacker. Usually used for NPC's to only hurt their attacker when they use
// a melee weapon
///////////////////////////////////////////////////////////////////////////////
function bool HurtingAttacker(FPSPawn Other)
{
	if(Other != None
		&& Instigator != None)
	{
		if(PersonController(Instigator.Controller) != None)
		{
			if(PersonController(Instigator.Controller).Attacker == Other)
				return true;	// NPC Attacking attacker
			else
				return false;
		}
		else
			return true;	// Dude/Animal attacking
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Handle a specific hit on a pawn that causes something to sever
///////////////////////////////////////////////////////////////////////////////
function ProcessSeverHit(FPSPawn Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector Momentum;

//	log(self@"processseverhit other"@other@"hitloc"@hitlocation@"normal"@hitnormal@"x"@X@"Y"@Y@"Z"@Z);

	if(Other == None)
		return;

	if(HurtingAttacker(Other))
	{
		Momentum = -SeverMag*((Z/2) + VRand());

		Other.TakeDamage(DamageAmount, Pawn(Owner), HitLocation, Momentum, DamageTypeInflicted);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Always notify controllers
///////////////////////////////////////////////////////////////////////////////
event Tick(float Delta)
{
	if(IsInState('Idle'))
	{
		CurrentDelta += Delta;
		if (CurrentDelta >= MaxDelta)
		{
			CurrentDelta = CurrentDelta - MaxDelta;
			if (IdleMarkerMade != None)
				IdleMarkerMade.static.NotifyControllersStatic(
					Level,
					IdleMarkerMade,
					FPSPawn(Instigator),
					FPSPawn(Instigator),
					IdleMarkerMade.default.CollisionRadius,
					Instigator.Location);
		}
	}
	else if (IsInState('Streaming') || IsInState('StartStream') || IsInState('EndStream'))
	{
		CurrentDelta += Delta;
		if (CurrentDelta >= MaxDelta)
		{
			CurrentDelta = CurrentDelta - MaxDelta;
			if (ShotMarkerMade != None)
				ShotMarkerMade.static.NotifyControllersStatic(
					Level,
					ShotMarkerMade,
					FPSPawn(Instigator),
					FPSPawn(Instigator),
					ShotMarkerMade.default.CollisionRadius,
					Instigator.Location);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Weapon is up and ready to fire, but not firing.
// extends original, to keep track of shot count
// Uses the same code below it's Begin:, except we use HasAmmoFinished for
// special weapons (like the shocker) that never want to switch, but need
// to recharge eventually.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Idle
{
	simulated event BeginState()
	{
		Super.BeginState();
		Instigator.AmbientSound = IdleSound;
		Instigator.SoundVolume = 96;
	}

	simulated event EndState()
	{
		Super.EndState();
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.Default.SoundVolume;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Streaming
// 'Fire' this weapon in a looping fashion, till it's done
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Streaming
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
//	function Notify_DoHit()
//	{
//		DoHit(TraceAccuracy, 0, 0);
//	}

	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	event Tick(float Delta)
	{
		Global.Tick(Delta);
		ReduceAmmo(Delta);
		DoHit(TraceAccuracy, 0, 0);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Set first person hands texture
///////////////////////////////////////////////////////////////////////////////
simulated function ChangeHandTexture(Texture NewHandsTexture, Texture DefHandsTexture, Texture NewFootTexture)
{
	Skins[2] = NewHandsTexture;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	PlayerMeleeDist=100.000000
	NPCMeleeDist=80.000000
	InventoryGroup=5
	GroupOffset=95
	PickupClass=class'ChainsawPickup'
	AmmoName=class'GasCanBulletAmmoInv'
	PickupAmmoCount=10
	TraceAccuracy=0.005000
	bMeleeWeapon=True
	aimerror=200.000000
	AIRating=0.110000
	MaxRange=95.000000
	bUsesAltFire=False
	ViolenceRank=8
	HolsterSound=Sound'EDWeaponSounds.Heavy.cs_holster'
	ShotCountMaxForNotify=10
	holdstyle=WEAPONHOLDSTYLE_Pour
	switchstyle=WEAPONHOLDSTYLE_Carry
	firingstyle=WEAPONHOLDSTYLE_Pour
	bNoHudReticle=True
	MinRange=25
	CombatRating=2.00
	WeaponSpeedLoad=0.85
	WeaponSpeedHolster=0.55
	WeaponSpeedShoot1Rand=0.01
	SoundStart=Sound'EDWeaponSounds.Heavy.cs_prepstart'
	SoundLoop1=Sound'EDWeaponSounds.Heavy.cs_shoot1'
	SoundEnd=Sound'EDWeaponSounds.Heavy.cs_prepend'
	AmmoUseRate=2.00
	bDelayedStartSound=True
	IdleSound=Sound'EDWeaponSounds.Heavy.cs_idle'
	BodyDamage=Class'ChainSawDamage'
	SeverMag=40000.000000
	DamageAmount=5
	MomentumHitMag=50000.000000
	DamageTypeInflicted=Class'ChainSawBodyDamage'
	AttachmentClass=Class'ChainsawAttachment'
	Mesh=SkeletalMesh'ED_Weapons.ED_Chainsaw_NEW'
	Skins[0]=Texture'ED_WeaponSkins.Melee.chainsawskin2'
	Skins[1]=TexPanner'ED_WeaponSkins.Melee.chainblur'
	Skins[2]=Texture'MP_FPArms.LS_arms.LS_hands_dude'
	HitWallSound=Sound'AWSoundFX.Machete.macheterichochet'
	BodySound(0)=Sound'Slawterhaus.BoneRip01'
	BodySound(1)=Sound'Slawterhaus.BoneRip02'
	BodySound(2)=Sound'Slawterhaus.BoneRip03'
	ShotMarkerMade=class'GunfireMarker'
	IdleMarkerMade=class'MeleeHitNothingMarker'
	MaxDelta=1.00
	CurrentDelta=1.00
//	IdleMarkerMade=
	ThirdPersonRelativeLocation=(X=-4.000000,Y=0.000000,Z=9.000000)	
	ThirdPersonRelativeRotation=(Pitch=30000,Roll=22000)
	OverrideHUDIcon=Texture'EDhud.hud_Chainsaw'

	PullCordSound1=Sound'EDWeaponSounds.Heavy.cs_pullcord1'
	PullCordSound2=Sound'EDWeaponSounds.Heavy.cs_pullcord2'
	PrepStartSound=Sound'EDWeaponSounds.Heavy.cs_prepstart'
	PrepEndSound=Sound'EDWeaponSounds.Heavy.cs_prepend'
	PawnHitMarkerMade=class'PawnBeatenMarker'
	ItemName="Chainsaw"
}