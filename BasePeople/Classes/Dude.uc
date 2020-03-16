///////////////////////////////////////////////////////////////////////////////
// WARNING: This class is used in multiplayer only
///////////////////////////////////////////////////////////////////////////////

//=============================================================================
// Dude.uc
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Dude controls footsteps here, they aren't done through notifies. It's 
// done with timers, that way we're not dealing with every other character
// in the game except the dude ignoring footstep notifies
//
//
// We've been talking it through, and currently we'd like the Dude to inherit from
// Bystander and not something special like Dude. The reason is becuase checks
// by other controllers for pawns can treat the dude like any other bystander (which
// he's supposed to be--except he has a big gun). Otherwise you have to do a Bystander
// AND Dude check when searching for pawns it just doesn't seem necessary.
//
//=============================================================================
class Dude extends Bystander
	Abstract;

var AnimNotifyActor usegrenade;	// Grenade we have in our hand for grenade suicides
var StaticMesh grenade;

var Sound FootStepSounds[5];
var Sound MPFootStepSounds[5];

var bool bPlayingFootstepSound;	// Set to true when you play a step, false after timer is
								// called again
var(Character) MeshAnimation	CoreMPMeshAnim;		// Core MP animations (used in addition to special animations)
var(Character) Mesh				CoreSPMesh;		// Original, non-MP mesh. Make the default the MP mesh


var bool bNoDropItem;			// If false, allow an item to be dropped, if true, don't. Inverse so there's
								// nothing to set it the default properties. 
								// Used to fix the 'fastfood/health pipe cheat/bug'

const HAND_OFFSET	=	vect(8, -3.5, 0);
const HEAD_OFFSET	=	vect(-1, 8, -1.3);
const HEAD_ROTATION	=	vect(0, 0, 16000);
const GRENADE_SCALE = 0.65;
const GRENADE_FORWARD_MOVE  =   10;

const RUN_FOOTSTEP_TIME		=	0.35;
const WALK_FOOTSTEP_TIME	=	0.60;

const WALK_VOL				= 0.3;
//=	0.07;
const RUN_VOL				= 0.6;
//=	0.2;
const OTHERS_PITCH			= 0.9;

const FOOTSTEP_RADIUS			=	100;
const FOOTSTEP_RADIUS_MP		=	200;
const FOOTSTEP_RADIUS_LOCAL_MP	=	20;

const MOVE_BUFFER = 100;

const DROP_AGAIN	=	0.6; // Time you can drop a pickup again to fix the healthpipe/fastfood cheat

///////////////////////////////////////////////////////////////////////////////
// PreBeginPlay
// Warn modder that this class cannot be used for single player mode.
///////////////////////////////////////////////////////////////////////////////
event PreBeginPlay()
{
	if (P2GameInfoSingle(Level.Game) != None)
		warn("=============== Dude class is deprecated for single play. Use AWDude instead.");

	Super.PreBeginPlay();
}
///////////////////////////////////////////////////////////////////////////////
// Link this pawn to the anims it needs
///////////////////////////////////////////////////////////////////////////////

// Ignore this shit, let it call super instead where the fisting and stuff is rigged.

simulated function LinkAnims()
{
	// Also put in special MP anims that are important like jumping/landing, etc.
	LinkSkelAnim(CoreMPMeshAnim);

	// MP links to the special specified mesh for SP games. 
	LinkSkelAnim(GetDefaultAnim(SkeletalMesh(CoreSPMesh)));

	// Always link to the core anims, too, because some characters use a mixture
	// of their own anims plus some core anims.  Linking to core anims twice,
	// which can happen if default anims happen to match core anims, is safe.
	LinkSkelAnim(CoreMeshAnim);
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayFalling()
	{
		AnimBlendToAlpha(FALLINGCHANNEL,1.0,0.1);
		if ( abs(Velocity.X) > MOVE_BUFFER || abs(Velocity.Y) > MOVE_BUFFER )
		{
			if(bIsWalking)
				PlayAnim('s_walkjumpholdMP', , , FALLINGCHANNEL);
			else
				PlayAnim('s_runjumpholdMP', , , FALLINGCHANNEL);
		}
		else
			PlayAnim('s_jumpholdMP', , , FALLINGCHANNEL); 
	}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayJump()
	{
		AnimBlendToAlpha(FALLINGCHANNEL,1.0,0.1);
		if ( abs(Velocity.X) > MOVE_BUFFER || abs(Velocity.Y) > MOVE_BUFFER )
		{
			if(bIsWalking)
				PlayAnim('s_walkjumpMP', , , FALLINGCHANNEL);
			else
				PlayAnim('s_runjumpMP', , , FALLINGCHANNEL);
		}
		else
			PlayAnim('s_jumpMP', , , FALLINGCHANNEL); 
	}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayLanded(float impactVel)
	{	
//	BaseEyeHeight = Default.BaseEyeHeight;
		AnimBlendToAlpha(FALLINGCHANNEL,1.0,0.1);
		if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
		{
			if(bIsWalking)
				PlayAnim('s_walkjumplandMP', , , FALLINGCHANNEL);
			else
				PlayAnim('s_runjumplandMP', , , FALLINGCHANNEL);
		}
		else
			PlayAnim('s_jumplandMP', , , FALLINGCHANNEL); 
	/*
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	if ( impactVel > 0.17 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( (impactVel > 0.01) && !TouchingWaterVolume() )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	*/
	}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayLandingAnimation(float ImpactVel)
	{
	// STUB
	}

///////////////////////////////////////////////////////////////////////////////
// Make sure your weapons know about zone changes (the Rifle uses this currently
// for changing the fog in zoomed mode)
///////////////////////////////////////////////////////////////////////////////
event ZoneChange( ZoneInfo NewZone )
{
	if(Weapon != None)
		Weapon.ZoneChange(NewZone);
}

///////////////////////////////////////////////////////////////////////////////
// Die with a grenade in your mouth
// Can't get around this, even with God mode
///////////////////////////////////////////////////////////////////////////////
function GrenadeSuicide()
{
	local Controller Killer;
	local GrenadeHeadExplosion exp;
	local vector Exploc;
	local coords checkcoords;

	// Pick explosion point
	checkcoords = GetBoneCoords(BONE_NECK);
	Exploc = checkcoords.Origin;

	Exploc -= checkcoords.YAxis*GRENADE_FORWARD_MOVE;

	// remove the fake grenade from his head
	Notify_RemoveGrenadeHead();

	// Make a grenade explosion here
	exp = spawn(class'GrenadeHeadExplosion',self,,Exploc);
	exp.ShakeCamera(300);

	// We must be in blood mode to remove the head but still do
	// the explosion effect above
	if(class'P2Player'.static.BloodMode())
	{
		// Remove head
		ExplodeHead(Exploc, vect(0,0,0));
	}

	// Kill the pawn
	Health = 0;

	Died( Killer, class'Suicided', Location );
}

///////////////////////////////////////////////////////////////////////////////
// Anim notifies associated with the grenade suicide

///////////////////////////////////////////////////////////////////////////////
// Make a grenade in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHand()
{
	if(usegrenade == None)
	{
		usegrenade = spawn(class'AnimNotifyActor',,,Location);
		usegrenade.SetDrawType(DT_StaticMesh);
		usegrenade.SetStaticMesh(grenade);
		usegrenade.SetDrawScale(GRENADE_SCALE);
	}
	else
	{
		DetachFromBone(usegrenade);
	}

	AttachToBone(usegrenade, BONE_INVENTORY);
	usegrenade.SetRelativeLocation(HAND_OFFSET);
}

///////////////////////////////////////////////////////////////////////////////
// Take the spawned grenade from his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_RemoveGrenadeHand()
{
	if(usegrenade != None)
	{
		DetachFromBone(usegrenade);
		usegrenade.Destroy();
		usegrenade = None;
	}
}
///////////////////////////////////////////////////////////////////////////////
// Ready the mouth! (blend it to open wide)
///////////////////////////////////////////////////////////////////////////////
function Notify_PrepMouthForGrenade()
{
	MyHead.GotoState('Suicide');
}

///////////////////////////////////////////////////////////////////////////////
// Put the grenade in his head and open the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHead()
{
	if(MyHead == None)
		return;

	if(usegrenade == None)
	{
		usegrenade = spawn(class'AnimNotifyActor',,,Location);
		usegrenade.SetDrawType(DT_StaticMesh);
		usegrenade.SetStaticMesh(grenade);
		usegrenade.SetDrawScale(GRENADE_SCALE);
	}
	else
	{
		DetachFromBone(usegrenade);
	}

	MyHead.AttachToBone(usegrenade, 'node_parent');
	usegrenade.SetRelativeLocation(HEAD_OFFSET);
	usegrenade.SetRelativeRotation(rotator(HEAD_ROTATION));
}
///////////////////////////////////////////////////////////////////////////////
// Remove the grenade in his head and close the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_RemoveGrenadeHead()
{
	if(MyHead != None
		&& usegrenade != None)
	{
		MyHead.GotoState('');
		MyHead.DetachFromBone(usegrenade);
		usegrenade.Destroy();
		usegrenade = None;
	}
}
///////////////////////////////////////////////////////////////////////////////
// End of: Anim notifies associated with the grenade suicide

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Normal living
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state Living
{
	///////////////////////////////////////////////////////////////////////////////
	// toss out the weapon currently held
	///////////////////////////////////////////////////////////////////////////////
	function TossWeapon(vector TossVel)
	{
		if(!bNoDropItem
			|| Health <= 0)
		{
			// Is reset in 
			bNoDropItem=true;
			if(Health > 0)
				GotoState('Living', 'ResetDropTimer');

			Super.TossWeapon(TossVel);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// toss out the inventory passed in
	///////////////////////////////////////////////////////////////////////////////
	function bool TossThisInventory(vector TossVel, Inventory ThisInv)
	{
		if(!bNoDropItem
			|| Health <= 0)
		{
			bNoDropItem=true;
			if(Health > 0)
				GotoState('Living', 'ResetDropTimer');

			return Super.TossThisInventory(TossVel, ThisInv);
		}
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to change footstep speed
	///////////////////////////////////////////////////////////////////////////////
	simulated function SetWalking(bool bNewIsWalking)
	{
		local bool OldWalking;

		OldWalking = bIsWalking;

		Super.SetWalking(bNewIsWalking);

		if ( bNewIsWalking != OldWalking )
		{
			Timer();
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play a sound as you jump
	///////////////////////////////////////////////////////////////////////////////
	simulated function DoJump( bool bUpdating )
	{
		local EPhysics oldphys;
		local float userad;

		oldphys = Physics;

		Super.DoJump(bUpdating);

		if ( oldphys == PHYS_Walking 
			&&  Physics == PHYS_Falling
			&& Level.NetMode != NM_DedicatedServer)
		{
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				userad = FOOTSTEP_RADIUS;
			else
				userad = FOOTSTEP_RADIUS_LOCAL_MP;
			// Play footsteps/jumping sound here
			PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,RUN_VOL,,userad);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Play landed sound
	///////////////////////////////////////////////////////////////////////////////
	function Landed( vector HitNormal )
	{
		local float userad;

		Super.Landed(HitNormal);

		//log(self$" landed "$hitnormal);
		if(!bPlayingFootstepSound
			&& Level.NetMode != NM_DedicatedServer)
		{
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				userad = FOOTSTEP_RADIUS;
			else
				userad = FOOTSTEP_RADIUS_LOCAL_MP;
			// Play footsteps/landed sound here
			bPlayingFootstepSound=true;
			PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,1.0,,userad);
			SetTimer(RUN_FOOTSTEP_TIME, false);
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	//  Play sound
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		local float vol, usepitch, userad;
		local vector usevel;
		local bool bOtherMp; // someone other than you

		//log(self$" timer, phys "$Physics$" walking "$bIsWalking$" velocity "$Velocity$" role "$Role$" viewport "$ViewPort(PlayerController(Controller).Player));
		// only on client or stand alone
		if(Level.NetMode != NM_DedicatedServer)
		{
			bPlayingFootstepSound=false;

			if ( Physics == PHYS_Walking )
			{
				usepitch=1.0;
				if(bIsWalking
					|| bIsCrouched)
				{
					vol = WALK_VOL;
					SetTimer(WALK_FOOTSTEP_TIME, false);
				}
				else
				{
					vol = RUN_VOL;
					SetTimer(RUN_FOOTSTEP_TIME, false);
				}

				// Make others around you louder, so it's easier to hear them
				if(Controller == None
					|| (PlayerController(Controller) != None 
						&& ViewPort(PlayerController(Controller).Player) == None) )
				{
					vol=1.0;
					usepitch=OTHERS_PITCH;
					userad = FOOTSTEP_RADIUS_MP;
					bOtherMp=true;
				}
				else
				{
					usepitch=1.0;
					if(Level.Game != None
						&& Level.Game.bIsSinglePlayer)
						userad = FOOTSTEP_RADIUS;
					else
						userad = FOOTSTEP_RADIUS_LOCAL_MP;
				}

				if(VSize(Velocity) > 0)
				{
					if(!bOtherMp)
						PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,vol,,userad,usepitch);
					else
						PlaySound(FootStepSounds[Rand(ArrayCount(MPFootStepSounds))],SLOT_Interact,vol,,userad,usepitch);
					bPlayingFootstepSound=true;
				}
			}
			else
				SetTimer(WALK_FOOTSTEP_TIME, false);
		}
	}
	simulated function BeginState()
	{
		//log(self$" beginstate Living, role "$Role$" remote "$RemoteRole);
		SetTimer(RUN_FOOTSTEP_TIME, false);
	}

ResetDropTimer:
	Sleep(DROP_AGAIN);
	// Reset boolean that allows you to drop items
	bNoDropItem=false;
}

defaultproperties
	{
	BaseEquipment[0]=(weaponclass=class'Inventory.UrethraWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.FootWeapon')
	BaseEquipment[2]=(weaponclass=class'Inventory.MatchesWeapon')
	HealthMax=300
	DamageMult=2.4
	TakesMachinegunDamage=0.75
	ReportLooksRadius=2048
	bCanPickupInventory=true
	bIsTrained=true		
	bIsFeminine=false
	bRandomizeHeadScale=false
	bStartupRandomization=false
	VoicePitch=1.0
	MaxMoneyToStart=0
	bUsePawnSlider=false
	FootStepSounds[0]=Sound'MoreMiscSounds.QuietFootsteps.footstep1q'
	FootStepSounds[1]=Sound'MoreMiscSounds.QuietFootsteps.footstep2q'
	FootStepSounds[2]=Sound'MoreMiscSounds.QuietFootsteps.footstep4q'
	FootStepSounds[3]=Sound'MoreMiscSounds.QuietFootsteps.footstep5q'
	FootStepSounds[4]=Sound'MoreMiscSounds.QuietFootsteps.footstep6q'
	
	MPFootStepSounds[0]=Sound'MoreMiscSounds.LoudFootsteps.footstep1h'
	MPFootStepSounds[1]=Sound'MoreMiscSounds.LoudFootsteps.footstep2h'
	MPFootStepSounds[2]=Sound'MoreMiscSounds.LoudFootsteps.footstep4h'
	MPFootStepSounds[3]=Sound'MoreMiscSounds.LoudFootsteps.footstep5h'
	MPFootStepSounds[4]=Sound'MoreMiscSounds.LoudFootsteps.footstep6h'
	// too tap-dancy
//	FootStepSounds[5]=Sound'MiscSounds.People.footstep3'
	// CHANGE CHANGE CHANGE THE Max number of footsteps if you put this back in

	grenade=StaticMesh'stuff.stuff1.grenade'

	TransientSoundRadius=1024

	CoreMPMeshAnim=MeshAnimation'MP_Characters.anim_MP'
	CoreSPMesh=Mesh'Characters.Avg_Dude'
	RandomizedBoltons(0)=None
	bNoChamelBoltons=True
	CrouchHeight=+40.0
	}
