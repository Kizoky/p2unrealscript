//=============================================================================
// AWPerson
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Base class for all bystander characters in AW.
//
//=============================================================================
//class AWPerson extends InvPerson
class AWPerson extends PersonPawn
	notplaceable
	Abstract;

// Keep these the same length!
var const array<name> SeverBone;		// names for bones to scale during severing them
var array<Stump>	Stumps;				// pointers to stumps so when we explode we can remove them too
var array<byte>		BoneArr;			// 1 for a bone corresponding to SeverBone that he still has
var float HeadMomMag;					// magnitude for heads flying off after sever
var float LimbMomMag;					// magnitude for heads flying off after sever
var float TopMomMag;					// Cut in half momentum for halves
var class<P2Emitter> StumpBloodClass;	// type of blood stumps make
var class<Stump> StumpClass;			// type of stumps made
var class<Limb> LimbClass;				// type of limbs made
var class<TorsoGuts> GutsClass;// type of guts that come out the bottom of torso
var class<P2Emitter> GutsEmitterClass1, GutsEmitterClass2; // type of guts emitter
var class<GurgleBlood> GurgleClass;		// type of blood that gurgles out the top

var Sound FleshHit;						// general sound for flesh getting cut
var Sound CutLimbSound;					// sound for cutting a limb
var Sound CutInHalfSound;				// sound for being sliced in half
var Sound BladeCleaveNeckSound;			// slicing through neck to decapitate

var bool bPants;						// Mesh has pants
var bool bSleeves;						// Mesh has long sleeves
var bool bSkirt;						// Mesh has skirt

var name StartState;					// state we started into after the load

var (Character) bool bMPAnims;	// Must be true if we want to play MP anims
var (PawnAttributes) float TakesSledgeDamage; // Susceptibility to sledgehammer damage, 1.0 takes all, 0.5, takes half, etc.
									// TakesSledgeDamage of 0.0 makes them just get stunned by the thing and it does no damage
var (PawnAttributes) float TakesMacheteDamage; // Susceptibility to sledgehammer damage, 1.0 takes all, 0.5, takes half, etc.
var (PawnAttributes) float TakesScytheDamage; // Susceptibility to sledgehammer damage, 1.0 takes all, 0.5, takes half, etc.
var (PawnAttributes) float TakesDervishDamage; // Susceptibility to cat dervish damage, 1.0 takes all, 0.5, takes half, etc.
var (PawnAttributes) name  InitAttackTag;	// Tag to attack when you get triggered
var (PawnAttributes) bool  bStartMissingLegs;	// Start with your legs cut off
var (PawnAttributes) float TimeTillDissolve;		// How long till we dissolve after death
var (PawnAttributes) bool  bCheapBloodSpouts;	// If you want the neck blood spout to not be as processor
											//intensive and go on as long, set this to true--good for zombie hoards
var (PawnAttributes) float TakesZombieSmashDamage; // big smash by zombie to smash head
var (Character) bool bNoDismemberment;	// Prevents dismemberment on this pawn
var (Character) MeshAnimation AW_SPMeshAnim; // more single player anims for AW characters

var bool bBig;							// If the limbs on this guy are big, like military or some rednecks
var class<Stump> StumpBigClass;			// type of stumps made if we're big
var class<Limb> LimbBigClass;			// type of limbs made if we're big

// These two animations are seperate becuase I was trying to keep from having a link back to the top half
// for whatever reason. I thought it'd be to messy. So before the bottom half is made, you need to grab
// these two rotations two different ways. 
var rotator		OldTopHalfRotationAnim;	// Rotation of top half cut from my bottom (only valid when cut in
										// half and you are the bottom half), valid if the bottom needs to animate
var rotator		OldTopHalfRotationKarma;// Same rotation, but valid if the bottom needs to ragdoll
var bool		bBottomHalfNewSpawn;	// If true, the bottom half was just made and needs to be 
										// evaluated in PlayDying about it's proper rotation/animation/ragdoll
var bool		bBottomWarpDeathAnim;	// If you started out alive and then chopped in half, you'll want to
										// play the death anim... if not, you'll want to warp to the end of your
										// death anim. Do that if this is true.
										
var bool bMasochistPlayer;				// xPatch: Allows to dismember player's limbs 

const PANTS_STR		=	'_Pants';
const SKIRT_STR		=	'_Skirt';
const BIG_STR		=	'_Big';
const HEAD_OFFSET_MACHETE= 10.0;
const HEAD_OFFSET_SCYTHE = 15.0;
const LEG_OFFSET_SCYTHE  = 15.0;
const MOVE_LIMB		=	25;
const CHOP_MIN		=	60;

const INVALID_LIMB	=	-2;
const HEAD_INDEX	=	-1;
const LEFT_ARM		=	0;
const RIGHT_ARM		=	2;
const LEFT_LEG		=	4;
const RIGHT_LEG		=	6;
const TORSO_INDEX	=	9;
const TOP_TORSO		= 'MALE01 spine1';
const BOTTOM_TORSO	= 'MALE01 spine';
const SEVER_RAND				  = 6;	// 4 limbs, 1 to cut in half, and 1 to do nothing

const SHRINK_PELVIS = 1000.0f;		// in order to get the body to cut in half, we must shrink the whole body by
									// 1/1000, then grow it just the top half back by 1000. This must be greater than 1.0

const HACK_OTHER_LIMB_RATIO	= 0.2;
const BLOW_OFF_LIMBS_DOT	= 0.97;
const SLOMO_DEATH_TIME		= 0.1;
const CRAWLING_BIAS	=	0.5;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//var(Footsteps) Sound FootStepSounds[5];
//var(Footsteps) bool bDoFootsteps;

var(Character) array<MeshAnimation> ExtraAnims;						// List of extra animations to be linked up
var(Character) MeshAnimation PLAnims, PLAnims_Fat, PLAnims_Mini;	// PL animation references for normal, fat, and mini versions of this pawn

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var float StuckTime;				// How long the player has been 'stuck'. Determined below. If they are not
									// moving in Z for too long (MAX_STUCK_TIME),
									// then warp them to the nearest good pathnode.
var float StuckCheckRadius;			// Size around which you check for pathnodes to warp to
var PathNode LastUnstuckPoint;		// Save the last point we warped to, after being unstuck. Don't use it
									// the very next time, to keep us from infinite unsticking--still stuck
									// scenarios.
var bool bPlayingFootstepSound;	// Set to true when you play a step, false after timer is
								// called again
var float LastStuckCheck;								

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
const MAX_STUCK_TIME				=	2.0;
const STUCK_RADIUS					=	2048;

const RUN_FOOTSTEP_TIME		=	0.35;
const WALK_FOOTSTEP_TIME	=	0.60;

const WALK_VOL				= 0.07;
//=	0.07;
const RUN_VOL				= 0.1;
//=	0.2;
const LAND_VOL				= 0.5;

const FOOTSTEP_RADIUS			=	100;
const FOOTSTEP_RADIUS_MP		=	200;
const FOOTSTEP_RADIUS_LOCAL_MP	=	20;

const INSANE_MEDGUN_PCT			= 0.5;
const INSANE_BIGGUN_PCT			= 0.25;
const INSANE_UBERGUN_PCT		= 0.005;
const INSANE_MELEE_PCT			= 0.25;

const MOVE_BUFFER = 100;

const MIN_HEALTH_TO_SLIT_THROAT = 30.0;

// Added by Man Chrzan: xPatch 2.0	
const MIN_HEALTH_TO_BULLET_CUT = 30.0;
var class<P2Emitter> NewGutsEmitterClass1[3];
var class<P2Emitter> NewGutsEmitterClass2[3];
const GutsPath = "Postal2Game.P2Player GutsType";	


///////////////////////////////////////////////////////////////////////////////
// MP anims copied from Dude
// Most bystanders won't use these, but they're here just in case
///////////////////////////////////////////////////////////////////////////////
simulated event PlayFalling()
	{
	if (IsInstate('Dying')) return;
	if (!bMPAnims) return;
		// Don't play this if we're initial-falling into the world
		if (Controller != None
			&& Controller.IsInState('InitFall'))
			return;
		
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
	if (!bMPAnims) return;
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
	if (!bMPAnims) return;
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
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	// Only let this be called once
	if (!bGotDefaultInventory)
	{
		// Give them a cell phone
		if (bCellUser && CellPhoneClass != None)
			CreateInventoryByClass(CellPhoneClass);
		else // No cell phone class means no calls
			bCellUser = False;
			
		Super.AddDefaultInventory();		
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PlayCellIn()
{
	PersonController(Controller).SwitchToThisWeapon(CellPhoneClass.default.InventoryGroup, CellPhoneClass.default.GroupOffset);
//	PlayAnim('s_idle_cellin', 1.0, 0.2);
}

simulated function PlayCellOut()
{
	PlayAnim('s_idle_cellout', 1.0, 0.2);
	PlaySound(CellBeep, SLOT_TALK);
	PersonController(Controller).SwitchToHands();
}

simulated function PlayCellOn()
{
	PlayAnim('s_idle_cellon2', 1.1, 0.2);
	PlaySound(CellBeep, SLOT_TALK);
}

simulated function PlayCellLoop()
{
	PlayAnim('s_idle_cell', 0.8);
}

simulated function float PlayIncomingCall()
{
	PlaySound(CellRing, SLOT_TALK);
	return GetSoundDuration(CellRing);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function SetupBoltons()
{
	local int i;

	Super.SetupBoltons();

	for (i=0; i<ArrayCount(Boltons); i++)
	{
		if (Boltons[i].Part != None && Boltons[i].bAttachToHead)
			Boltons[i].Part.SetDrawScale3d(MyHead.DrawScale3D);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Decide if he's stuck or not
///////////////////////////////////////////////////////////////////////////////
function bool DetectStuckPlayer(float DeltaTime)
{
	// If you're falling and not moving for too long, you're stuck
	if(Physics == PHYS_Falling
		&& !bIsCrouched)
	{
		// If you're not moving in z for too long
		if(Velocity.z == 0)
		{
			StuckTime += DeltaTime;

			// Now that he's really stuck, move him
			if(StuckTime > MAX_STUCK_TIME)
			{
				StuckTime = 0;
				return true;
			}
		}
		else
			StuckTime = 0;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Find the nearest free pathnode to the stuck player, and put him there
// Warps him to each possible spot to make sure it will work. But it doesn't
// warp him back, it just uses the oldloc to test from. The last one you warped
// him to will have to be the closest to oldloc.
///////////////////////////////////////////////////////////////////////////////
function HandleStuckPlayer()
{
	local PathNode pn, savepn;
	local float closedist, usedist;
	local vector useloc, oldloc;

	Warn(self$" ERROR! NPC WAS STUCK here: "$Location);

	oldloc = Location;

	closedist = StuckCheckRadius;
	// Check pathnodes in a given radius
	foreach RadiusActors(class'Pathnode', pn, StuckCheckRadius, oldloc)
	{
		usedist = VSize(pn.Location - oldloc);
		if(LastUnstuckPoint	!= pn		// Not where we last unstuck ourself from
			&& usedist < closedist		// closest one
			&& !pn.bBlocked)			// not blocked
		{
			// Warp the player there now, to make sure the spot was
			// okay for him to be there. If this happens, it will only
			// work with the closest node, so this will also be the final move
			useloc = pn.Location;
			// Add just enough buffer to pathnode, to make sure he somehow doesn't
			// get warped to a point below the floor, and then fall through the floor.
			useloc.z += (CollisionHeight/2);
			if(SetLocation(useloc))
			{
				closedist = usedist;
				savepn = pn;
			}
		}
	}

	if(savepn != None)
	{
		//mypawnfix
		StuckCheckRadius = STUCK_RADIUS;
		LastUnstuckPoint = savepn;	// Save where we last unstuck from so as to not use it again, next time
		Warn(self$" UNsticking NPC--warping him to "$savepn);
	}
	else
	{
		Warn(self$" UNsticking warp failed");
		// You've failed, then increase you're check area
		StuckCheckRadius += STUCK_RADIUS;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Play 3rd person shooting anims
// Includes fisting anims
///////////////////////////////////////////////////////////////////////////////
simulated function PlayFiring(float Rate, name FiringMode)
{
	local EWeaponHoldStyle wstyle;
	local bool StandingStill;

	// If he's not moving and not rotating make a recoil
	// Some weapons (like guns) don't want a recoil if you're
	// moving too much
	StandingStill = (NoLegMotion()
					&& (!bPlayer
						|| (Controller != None
							&& Controller.DesiredRotation == Controller.Rotation)));

	wstyle = GetWeaponFiringStyle();

	if (FiringMode == 'FISTS')
	{
		// Choose appropriate shooting animation and blend it into
		// current animation.  We assume the current animation is
		// amenable to shooting; if it isn't, this will look stupid.
		if(StandingStill)
		{
			AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
			WeaponBlendTime = FIRING_BLEND_TIME;
		}
		
		if (FistsWeapon(Weapon) != None)
		{
			if (bIsFat)
			{
				switch (FistsWeapon(Weapon).ThirdAnimUsed)
				{
					case 0:
						PlayAnim('fat_fist_left_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
	//				case 1:
	//					PlayAnim('fat_fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
	//					break;
					case 1:
						PlayAnim('fat_fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 2:
						PlayAnim('fat_fist_right_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 3:
						PlayAnim('fat_fist_right_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
				}
			}
			else if (CharacterType == CHARACTER_Mini)
			{
				switch (FistsWeapon(Weapon).ThirdAnimUsed)
				{
					case 0:
						PlayAnim('mini_fist_left_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
	//				case 1:
	//					PlayAnim('mini_fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
	//					break;
					case 1:
						PlayAnim('mini_fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 2:
						PlayAnim('mini_fist_right_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 3:
						PlayAnim('mini_fist_right_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
				}
			}
			else
			{
				switch (FistsWeapon(Weapon).ThirdAnimUsed)
				{
					case 0:
						PlayAnim('fist_left_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
	//				case 1:
	//					PlayAnim('fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
	//					break;
					case 1:
						PlayAnim('fist_left_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 2:
						PlayAnim('fist_right_jab', Rate, 0.1, WEAPONCHANNEL);
						break;
					case 3:
						PlayAnim('fist_right_hook', Rate, 0.1, WEAPONCHANNEL);
						break;
				}
			}
		}
	}
	else
		Super.PlayFiring(Rate, FiringMode);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	DetermineClothing(GetItemName(String(Skins[0])));
	DetermineClothing(GetItemName(String(Mesh)));

	StuckCheckRadius = STUCK_RADIUS;
	
	// Force cheap blood spouts for now.
	//bCheapBloodSpouts = true;
}

///////////////////////////////////////////////////////////////////////////////
// If I'm used for an errand, tell them I died
///////////////////////////////////////////////////////////////////////////////
function CheckForErrandCompleteOnDeath(Controller Killer)
{
	// Make sure the dude's still alive before triggering this.
	if(Killer != None
		&& Killer.Pawn != None
		&& Killer.Pawn.Health > 0)
		Super.CheckForErrandCompleteOnDeath(Killer);
}

///////////////////////////////////////////////////////////////////////////////
// blow up into little pieces (implemented in subclass)		
///////////////////////////////////////////////////////////////////////////////
simulated function ChunkUp(int Damage)
{
	// If we didn't already trigger this event (because karma killed us or something)
	// do it now
	if(Health > 0)
		TriggerEvent(Event, self, None);

	Super.ChunkUp(Damage);
}

///////////////////////////////////////////////////////////////////////////////
// Record pawn dead, if player killed them
///////////////////////////////////////////////////////////////////////////////
// 8/28 stubbed out -- assumes AW-only game with no cops, etc, and we need to call Super to check for death achievements.
/*
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& Killer != None
		&& Killer.bIsPlayer)
	{
		// Record him dying as a zombie 
		if(AWZombie(self) != None)
			P2GameInfoSingle(Level.Game).TheGameState.ZombiesKilledOverall++;
		else // or as a person
			P2GameInfoSingle(Level.Game).TheGameState.PeopleKilled++;

		// If you killed him with fire, record that too
		if(ClassIsChildOf(damageType, class'BurnedDamage')
			|| ClassIsChildOf(damageType, class'OnFireDamage'))
		{
			P2GameInfoSingle(Level.Game).TheGameState.PeopleRoasted++;
		}
	}

	Super(MpPawn).Died(Killer, damageType, HitLocation);
}
*/

///////////////////////////////////////////////////////////////////////////////
// Link this pawn to the anims it needs
///////////////////////////////////////////////////////////////////////////////
simulated function LinkAnims()
{
	local int i;
	
	// Ignore if we're still setting up in the chameleon
	if (bInitialSetup)
		return;
		
	// Also put in AW7 anims.
	for (i=0; i<ExtraAnims.Length; i++)
	{
		//log(self@"link extra anim"@ExtraAnims[i],'Debug');
		LinkSkelAnim(ExtraAnims[i]);
	}

	// Also put in more AW single player anims.
	//log(self@"link skel anim"@AW_SPMeshAnim,'Debug');
	LinkSkelAnim(AW_SPMeshAnim);

	// Links to the special specified mesh for SP games. 
	///log(self@"link skel anim"@GetDefaultAnim(SkeletalMesh(Mesh)),'Debug');
	LinkSkelAnim(GetDefaultAnim(SkeletalMesh(Mesh)));

	// Always link to the core anims, too, because some characters use a mixture
	// of their own anims plus some core anims.  Linking to core anims twice,
	// which can happen if default anims happen to match core anims, is safe.
	//log(self@"link skel anim"@CoreMeshAnim,'Debug');
	LinkSkelAnim(CoreMeshAnim);

	if(CharacterType == CHARACTER_mini)
		LinkSkelAnim(PLAnims_Mini);
	else if (bIsFat)
		LinkSkelAnim(PLAnims_Fat);
	else
		LinkSkelAnim(PLAnims);
}

///////////////////////////////////////////////////////////////////////////////
// Prep for climbing a ladder
///////////////////////////////////////////////////////////////////////////////
function ClimbLadder(LadderVolume L)
{
	//log(Self$" climb ladder "$L);
	Super.ClimbLadder(L);
	if(LambController(Controller) != None)
		LambController(Controller).StartClimbLadder();
}

///////////////////////////////////////////////////////////////////////////////
// Remove old stump
///////////////////////////////////////////////////////////////////////////////
static function RemoveOldStump(int checkindex, AWPerson usepawn, bool bDestroyStump)
{
	local int i;
	local Stump usestump;

	for(i=0; i<usepawn.Stumps.Length; i++)
	{
		if(usepawn.Stumps[i] != None
			&& usepawn.Stumps[i].StumpIndex == checkindex)
		{
			usestump = usepawn.Stumps[i];
			usepawn.Stumps.Remove(i, 1);
			break;
		}
	}
	if(bDestroyStump
		&& usestump != None
		&& !usestump.bDeleteMe)
	{
		usestump.Destroy();
	}
}
static function RemoveGuts(AWPerson usepawn, bool bDestroyStump)
{
	local int i;
	local Stump usestump;

	for(i=0; i<usepawn.Stumps.Length; i++)
	{
		if(usepawn.Stumps[i] != None
			&& TorsoGuts(usepawn.Stumps[i]) != None)
		{
			usestump = usepawn.Stumps[i];
			usepawn.Stumps.Remove(i, 1);
			break;
		}
	}
	if(bDestroyStump
		&& usestump != None
		&& !usestump.bDeleteMe)
		usestump.Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Also let people hop off zombies
///////////////////////////////////////////////////////////////////////////////
// Moved the AWZombie check to P2Pawn -- BaseChange is singular, and calls to Super won't work.
/*
singular event BaseChange()
{
	if(AWZombie(Base) != None)
	{
		// Always jump off zombies, even when they're death crawling
		JumpOffPawn();
	}
	else
		Super.BaseChange();
}
*/

// Moved to P2MoCapPawn
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/*
simulated function name GetAnimBlockMelee()
{
	return's_block';
}
simulated function PlayBlockMeleeAnim()
{
	//log(self$" play block melee");
	ChangePhysicsAnimUpdate(false);
	AnimBlendParams(EXCHANGEITEMCHANNEL, 1.0, 0,0);
	PlayAnim(GetAnimBlockMelee(), 1.0, 0.1, EXCHANGEITEMCHANNEL);
}
simulated function ContinueBlockAnim(int channel)
{
	if(channel == EXCHANGEITEMCHANNEL)
		PlayBlockMeleeAnim();
}
simulated function bool IsBlockChannel(int channel)
{
	return (channel == EXCHANGEITEMCHANNEL);
}
simulated function FinishBlockAnim()
{
	AnimEnd(EXCHANGEITEMCHANNEL); // Stop animating block
}

///////////////////////////////////////////////////////////////////////////////
// Someone is about to attack us with a big weapon! (like a sledge or scythe)
// Do something!
// Humans try to block, zombies use this and attack or run
///////////////////////////////////////////////////////////////////////////////
function BigWeaponAlert(PersonPawn Swinger)
{
	//log(Self$" big weapon alert "$swinger);
	BlockMelee(Swinger);
}

///////////////////////////////////////////////////////////////////////////////
// Flying machete coming our way--check to block it!
///////////////////////////////////////////////////////////////////////////////
function BlockMelee(Actor MeleeAttacker)
{
	local vector Rot, dir;
	local float dot1;

	//log(self$" BlockMelee "$MeleeAttacker$" weapon "$weapon$" firing style "$P2Weapon(Weapon).GetFiringStyle());
	if(Health > 0					// alive
		&& !bDeleteMe				// not deleted
		&& bHasViolentWeapon		// can block with the weapon
		&& MyBodyFire == None		// not on fire
		&& !bIsCrouched				// not crouching
		&& !bIsDeathCrawling		// not crawling
		&& FRand() < BlockMeleeFreq	// randomly decide to block or not
		&& P2Weapon(Weapon) != None	// has a weapon
		&& (P2Weapon(Weapon).GetFiringStyle() == WEAPONHOLDSTYLE_Both			// has a two-handed weapon
			|| P2Weapon(Weapon).GetFiringStyle() == WEAPONHOLDSTYLE_Double))
	{
		// Check now if you can see the actor to block against
		Rot = vector(Rotation);
		dir = MeleeAttacker.Location - Location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		//log(self$" check melee, dot "$dot1$" hit loc "$MeleeAttacker.Location);

		if(dot1 > BLOCK_MELEE_DOT)
		{
			if(PersonController(Controller) != None)
				PersonController(Controller).PerfomBlockMelee(MeleeAttacker);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//  If we can block this melee attack
///////////////////////////////////////////////////////////////////////////////
function CheckBlockMelee(vector HitLocation, out byte StateChange)
{
	local vector Rot, dir;
	local float dot1;

	//log(self$" check block melee "$controller$" state "$controller.getstatename());
	// Check to complete block the melee attack
	if(Controller != None
		&& !Controller.bDeleteMe
		&& Controller.IsInState('BlockMelee'))
	{
		//log(Self$" doing block ");
		// See if they are facing our direction enough to block the attack
		Rot = vector(Rotation);
		dir = HitLocation - Location;
		dir.z=0;
		dir = Normal(dir);
		dot1 = Rot Dot dir;
		//log(self$" block melee, dot "$dot1$" hit loc "$HitLocation);

		if(dot1 > BLOCK_MELEE_DOT)
		{
			if(PersonController(Controller) != None)
				PersonController(Controller).DidBlockMelee(StateChange);
		}
		//log(self$" after block state "$statechange);
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// Set up how you start without legs
///////////////////////////////////////////////////////////////////////////////
function bool StartMissingLegs()
{
	if(bStartMissingLegs)
	{
		bMissingBottomHalf=true;
		RemoveLimbsAfterLoad(self);
		BoneArr[LEFT_LEG]=0;
		BoneArr[RIGHT_LEG]=0;
		bMissingLegParts=true;
		bMissingLimbs=true;
		if(LambController(Controller) != None)
		{
			LambController(Controller).StartInHalf();
			return true;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Detonate head
///////////////////////////////////////////////////////////////////////////////
function ExplodeHead(vector HitLocation, vector Momentum)
{
	local int i, BloodDrips;

	if (HitLocation == vect(0,0,0))
		HitLocation = MyHead.Location;

	Super(P2Pawn).ExplodeHead(HitLocation, Momentum);

	Head(MyHead).PinataStyleExplodeEffects(HitLocation, Momentum);

	BloodDrips = FRand()*4;
	for(i=0; i<BloodDrips; i++)
		DripBloodOnGround(Momentum);

	// Simply don't put spouts in MP.
	if(FluidSpout == None
		&& Level.Game != None
		&& Level.Game.bIsSinglePlayer)
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole
		if(Head(MyHead).PukeStream != None)
		{
			// Make the head stop puking, we'll take it from here.
			Head(MyHead).StopPuking();
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
		else if(P2GameInfo(Level.Game).AllowBloodSpouts())
			// If our head is removed while not puking, then make blood squirt out
		{
			if(bCheapBloodSpouts)
				FluidSpout = spawn(class'BloodSpoutFeederCheap',self,,Location);
			else
				FluidSpout = spawn(class'BloodSpoutFeeder',self,,Location);
		}

		if(FluidSpout != None)
		{
			FluidSpout.MyOwner = self;
			FluidSpout.SetStartSpeeds(100, 10.0);
			AttachToBone(FluidSpout, BONE_NECK);
			SnapSpout(true);
		}
	}
	// No more head
	MyHead = None;
	bHasHead=false;
}

///////////////////////////////////////////////////////////////////////////////
// Once, you've landed, this is called from LambController. It's supposed to
// setup complicated things for your initial controller state. 
///////////////////////////////////////////////////////////////////////////////
function bool PrepInitialState()
{
	if(!StartMissingLegs())
		return Super.PrepInitialState();
	else
		return true;
}

///////////////////////////////////////////////////////////////////////////////
// Removes limbs and places stumps, but doesn't make seperate limbs on the ground
// those are saved seperately.
// Also removes your bottom or top, if it needs to be
///////////////////////////////////////////////////////////////////////////////
static function RemoveLimbsAfterLoad(AWPerson usepawn, optional bool bDestroyOldTorsoStumps)
{
	local Stump usestump;
	local coords usecoords;
	local int i;

	//log(usepawn$" RemoveLimbsAfterLoad, missing bottom "$usepawn.bMissingBottomHalf$" top "$usepawn.bMissingTopHalf);
	if(usepawn != None)
	{
		// Remove old torso, pelvis, and guts stumps from stump array
		RemoveOldStump(class'Stump'.default.PelvisI, usepawn, bDestroyOldTorsoStumps);
		RemoveOldStump(class'Stump'.default.TorsoI, usepawn, bDestroyOldTorsoStumps);
		RemoveGuts(usepawn, bDestroyOldTorsoStumps);

		// Missing top half
		if(usepawn.bMissingTopHalf)
		{
			// Shrink top half
			usepawn.SetBoneScale(TORSO_INDEX, 0.0, TOP_TORSO);
			// Put stump on top of pelvis
			usecoords = usepawn.GetBoneCoords(BOTTOM_TORSO);
			usestump = usepawn.spawn(usepawn.StumpClass,usepawn,,usecoords.origin);
			usepawn.Stumps.Insert(usepawn.Stumps.Length, 1);
			usepawn.Stumps[usepawn.Stumps.Length-1] = usestump;
			usepawn.AttachToBone(usestump, BOTTOM_TORSO);
			usestump.SetupStump(usepawn.Skins[0], usepawn.AmbientGlow, 
				usepawn.bIsFat, usepawn.bIsFemale, usepawn.bPants, usepawn.bSkirt);
			usestump.ConvertToPelvis();
			usestump.SetRelativeLocation(usepawn.Default.StumpAdjust);
		}
		// missing bottom half
		if(usepawn.bMissingBottomHalf)
		{
			// Shrink bottom half
			// Shrink everything down all over, to very small. This number
			// must be greater than 0, or the matrices for the bones will be lots
			usepawn.SetBoneScale(TORSO_INDEX, 1/SHRINK_PELVIS, BONE_PELVIS);
			// Grow it back up, but only for the top of the body
			usepawn.SetBoneScale(TORSO_INDEX+1, SHRINK_PELVIS, TOP_TORSO);
			// Put stump on bottom of torso
			usecoords = usepawn.GetBoneCoords(BONE_MID_SPINE);
			usestump = usepawn.spawn(usepawn.StumpClass,usepawn,,usecoords.origin);
			usepawn.Stumps.Insert(usepawn.Stumps.Length, 1);
			usepawn.Stumps[usepawn.Stumps.Length-1] = usestump;
			usepawn.AttachToBone(usestump, BONE_MID_SPINE);
			usestump.SetupStump(usepawn.Skins[0], usepawn.AmbientGlow, 
				usepawn.bIsFat, usepawn.bIsFemale, usepawn.bPants, usepawn.bSkirt);
			usestump.ConvertToTorso();
			usestump.SetRelativeLocation(-usepawn.Default.StumpAdjust);
			// Attach guts to bottom side
			usecoords = usepawn.GetBoneCoords(TOP_TORSO);
			usestump = usepawn.spawn(usepawn.GutsClass,usepawn,,usecoords.origin);
			usestump.SetupStump(None, usepawn.AmbientGlow, 
				usepawn.bIsFat, usepawn.bIsFemale, usepawn.bPants, usepawn.bSkirt);
			TorsoGuts(usestump).SetToFullSize();
			usepawn.Stumps.Insert(usepawn.Stumps.Length, 1);
			usepawn.Stumps[usepawn.Stumps.Length-1] = usestump;
			usepawn.AttachToBone(usestump, TOP_TORSO);
		}
		// missing left arm
		if(usepawn.BoneArr[LEFT_ARM] == 0)
		{
			usepawn.TransferStump(LEFT_ARM, class'Stump'.default.LeftArmI, usepawn);
		}
		// missing right arm
		if(usepawn.BoneArr[RIGHT_ARM] == 0)
		{
			usepawn.TransferStump(RIGHT_ARM, class'Stump'.default.RightArmI, usepawn);
		}
		// missing left leg
		if(usepawn.BoneArr[LEFT_LEG] == 0)
		{
			usepawn.TransferStump(LEFT_LEG, class'Stump'.default.LeftLegI, usepawn);
		}
		// missing right leg
		if(usepawn.BoneArr[RIGHT_LEG] == 0)
		{
			usepawn.TransferStump(RIGHT_LEG, class'Stump'.default.RightLegI, usepawn);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Restore your animation if you had one, otherwise, just changeanimation.
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	if(!bPostLoadCalled)
	{
		Super.PostLoadGame();

		// If they aren't dead, but are missing limbs, put them in a
		// state that waits for a split second until all the limbs
		// and stumps are loaded, before it tries to reconnect any stumps
		if(!bDeleteMe
			&& bMissingLimbs
			&& Health > 0)
		{
			// Save the state we're in--if it's none, it will actually
			// return the tag of the character. Keep none in the variable
			// by not assigning things.
			if(GetStateName() != Tag
				&& GetStateName() != class.Name)
				StartState = GetStateName();
			GotoState('WaitingOnLimbsAfterLoad');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// OrigSave will be deleted. He's making NewDead, and should transfer
// anything else over he needs to
///////////////////////////////////////////////////////////////////////////////
function static DeadGuySetup(AWPerson OrigSave, AWPerson NewMe)
{
	newme.bPostLoadCalled=true;
	newme.Health=0;
	newme.bHidden=true;// Hide him while he animates to the ground, dead
	newme.PreRagdollRotation = newme.Rotation;
	// Copy over a few important FPSPawn values
	newme.bPersistent=OrigSave.bPersistent;
	newme.bCanTeleportWithPlayer=OrigSave.bCanTeleportWithPlayer;

	SwapGuy(OrigSave, NewMe, true);

	newme.GotoState('AWLoadedDying');
}

///////////////////////////////////////////////////////////////////////////////
// If the guy your recreating isn't supposed to have a head, get rid of it here
///////////////////////////////////////////////////////////////////////////////
function SwapDestroyOldHead(AWPerson NewMe)
{
	newme.DestroyHeadBoltons();
	newme.MyHead.Destroy();
	newme.MyHead = None;
}

///////////////////////////////////////////////////////////////////////////////
// Shave off limbs and such of new guy based on old guy's setup
///////////////////////////////////////////////////////////////////////////////
function static SwapGuy(AWPerson OrigSave, AWPerson NewMe, bool bDoCham)
{
	local int i;
	local Chameleon cham;

	if(bDoCham)
	{
		// Restore correct skins and heads and meshes
		cham = P2GameInfo(OrigSave.Level.Game).GetChameleon();
		if (cham != None)
		{
			cham.UseCurrentSkin(newme);
			// Head skin go set before, so clear here, so the new, spawned skin
			// can take over, if he's a chameleon
			if(newme.default.HeadSkin == None)
			{
				newme.HeadSkin = None;
				newme.SetupHead();
			}
		}
	}

	// Remove head of new guy if he is missing one 
	if(OrigSave.MyHead == None)
	{
		OrigSave.SwapDestroyOldHead(newme);
	}
	// Set to burn if I was burned
	if(OrigSave.Skins.Length > 0
		&& OrigSave.Skins[0] == OrigSave.BurnSkin)
	{
		newme.SwapToBurnVictim();
	}
	newme.bReportDeath = OrigSave.bReportDeath;
	// Copy over bones too
	i = OrigSave.BoneArr.Length - NewMe.BoneArr.Length;
	if(i > 0)
		NewMe.BoneArr.Insert(NewMe.BoneArr.Length, i);
	for(i=0;i<NewMe.BoneArr.Length; i++)
	{
		NewMe.BoneArr[i] = OrigSave.BoneArr[i];
	}
	// Copy over stumps too
	i = OrigSave.Stumps.Length - NewMe.Stumps.Length;
	if(i > 0)
		NewMe.Stumps.Insert(NewMe.Stumps.Length, i);
	for(i=0;i<NewMe.Stumps.Length; i++)
	{
		NewMe.Stumps[i] = OrigSave.Stumps[i];
		// Now remove the connection for the origsave to that stump
		OrigSave.Stumps[i] = None;
	}
	// Copy over if we're missing our top or bottom
	NewMe.bMissingTopHalf =		OrigSave.bMissingTopHalf;
	NewMe.bMissingBottomHalf =	OrigSave.bMissingBottomHalf;
	NewMe.bMissingLegParts =	OrigSave.bMissingLegParts;
	NewMe.bMissingLimbs =		OrigSave.bMissingLimbs;
	// Copy over tag and event
	NewMe.Tag = OrigSave.Tag;
	NewMe.Event = OrigSave.Event;
}

///////////////////////////////////////////////////////////////////////////////
// Remove limbs if dead, and cut in half properly
///////////////////////////////////////////////////////////////////////////////
// Play special anims to 'reinit' a ragdoll (it doesn't get saved well)
// We take this old pawn, and make a new one just like him (we hope) right where
// we are, then we animate him to the ground very fast and destroy the old one.
// The point of this is because once a pawn has ragdolled (after death), the 
// version 927 ragdolls don't save/load correctly AND you can't just animate
// this same pawn because he doesn't go from anims to ragdolls and back to anims
// and all.
///////////////////////////////////////////////////////////////////////////////
function SetupDeadAfterLoad()
{
	local Actor HitActor;
	local AWPerson newme;
	local vector startloc, endloc, newloc, HitLocation, HitNormal;
	local bool bHadKarma;
	local Material PickSkin;

	//log(self$" SetupDeadAfterLoad");

	if(KParams != None)
		bHadKarma=true;
	KParams = None;
	SetCollision(false, false, false);
	bCollideWorld=false;
	startloc = Location;
	startloc.z+=1;
	endloc = Location;
	endloc.z-=default.CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, endloc, startloc, true);
	if(HitActor != None)
	{
		newloc = HitLocation;
		// Move him off the ground if your not from a load
		if(GetStateName() != 'AWLoadedDying')
			newloc.z+=default.CollisionHeight;
		else
			newloc.z+=default.CarcassCollisionHeight;
	}
	else
	{
		newloc = Location;
		// Move him off the ground if your not from a load
		if(GetStateName() != 'LoadedDying')
			newloc.z+=CollisionHeight;
	}
	
	if(Skins.Length > 0
		&& Skins[0] != BurnSkin)
		PickSkin = Skins[0];

	//log(self$" my picked skin "$Skins[0]$" new loc "$newloc$" location "$Location$" start "$startloc$" end "$endloc$" hit actor "$HitActor$" old rotation "$PreRagdollRotation);

	newme = spawn(class,,,newloc,PreRagdollRotation,PickSkin);
	if(newme != None)
		DeadGuySetup(self, newme);

	// Get rid of the old me now, the one that had been animating and stopped, and was
	// probably ragdolling. I'm no good anymore.
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// Determine clothing for limb cutting, look at the skin and mesh for naming
///////////////////////////////////////////////////////////////////////////////
function DetermineClothing(string checkname)
{
	local int pos;

	pos = InStr(checkname, PANTS_STR);
	if(pos > 0)
		bPants=true;
	pos = InStr(checkname, BIG_STR);
	if(pos > 0)
	{
		bBig=true;
		// Switch limb classes, if we're big
		if(LimbBigClass != None)
			LimbClass = LimbBigClass;
		if(StumpBigClass != None)
			StumpClass = StumpBigClass;
	}
	//log(Self$" determine clothing, name "$checkname$" pants "$bpants$" big "$bBig$" limbs "$limbclass);
	pos = InStr(checkname, SKIRT_STR);
	if(pos > 0)
		bSkirt=true;

}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{
	local int i;
	// Destroy all his stumps too
	for(i=0; i<Stumps.Length;i++)
	{
		if(Stumps[i] != None)
			Stumps[i].Destroy();
	}
	Stumps.Remove(0, Stumps.Length);

	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Add in new variables
///////////////////////////////////////////////////////////////////////////////
function InitBySpawner(PawnSpawner initsp)
{
	local AWBasePawnSpawner newsp;

	Super.InitBySpawner(initsp);

	newsp = AWBasePawnSpawner(initsp);
	if(newsp != None)
	{
		if(newsp.InitTakesSledgeDamage != DEF_SPAWN_FLOAT)
			TakesSledgeDamage		= newsp.InitTakesSledgeDamage;	
		if(newsp.InitTakesMacheteDamage != DEF_SPAWN_FLOAT)
			TakesMacheteDamage		= newsp.InitTakesMacheteDamage;	
		if(newsp.InitTakesScytheDamage != DEF_SPAWN_FLOAT)
			TakesScytheDamage		= newsp.InitTakesScytheDamage;	
		if(newsp.InitTakesZombieSmashDamage != DEF_SPAWN_FLOAT)
			TakesZombieSmashDamage		= newsp.InitTakesZombieSmashDamage;	
		if(newsp.InitbStartMissingLegs == 1)
		{
			bStartMissingLegs=true;
			StartMissingLegs();
		}
		if(newsp.InitbLookForZombies == 1)
			bLookForZombies=true;
		if(newsp.InitTimeTillDissolve != DEF_SPAWN_FLOAT)
		{
			TimeTillDissolve=newsp.InitTimeTillDissolve;
		}
		if(newsp.InitbCheapBloodSpouts == 1)
		{
			bCheapBloodSpouts=true;
		}
		if (newsp.InitbNoDismemberment == 1)
			bNoDismemberment=true;
	}
	//else
		//warn("Can't use old pawn spawner--use AWPawnSpawner");
}

///////////////////////////////////////////////////////////////////////////////
// Swap out to our burned mesh, and make sure to 
// change the skin on any stumps on us
///////////////////////////////////////////////////////////////////////////////
simulated function SwapToBurnVictim()
{
	local int i;
	if(class'P2Player'.static.BloodMode())
	{
		// set stump skins too
		for(i=0; i<Stumps.Length;i++)
		{
			Stumps[i].Skins[0] = BurnSkin;
		}
	}
	Super.SwapToBurnVictim();
}

///////////////////////////////////////////////////////////////////////////////
//  Handle effects side of things for body fire
///////////////////////////////////////////////////////////////////////////////
function SetOnFire(FPSPawn Doer, optional bool bIsNapalm)
{
	if(Skins[0] != BurnSkin)
		Super.SetOnFire(Doer, bIsNapalm);
}

///////////////////////////////////////////////////////////////////////////////
// Looking at where the hit was, determine which bone to cut off
///////////////////////////////////////////////////////////////////////////////
function int DecideSeverBone(vector HitLocation, class<damageType> dtype)
{
	local vector diff, armcross;
	local float zdiff;
	local float armdot;
	local coords usecoords;
	local int i, pickI;
	local float checkdist, fardist;

	const LEG_Z			=	25.0;	// how much further down the torso someone's legs are
	// If it's below the legs, then let it chop off anything anyway, or if it's
	// on the sides, then chop off the arm, otherwise, hit the torso

	if(Health > 0
		&& !bIsDeathCrawling
		&& !bIsCrouched)
	{
		diff = HitLocation - Location;
		zdiff = diff.z;
		diff.z = 0;
		armdot = vector(Rotation) dot Normal(diff);
		armcross = vector(Rotation) cross Normal(diff);

		// Check to cut off the head first
		usecoords = GetBoneCoords(BONE_NECK);
		if(HitLocation.z > (usecoords.origin.z - HEAD_OFFSET_MACHETE))
		{
			if(!bMissingTopHalf)
				return HEAD_INDEX;
			else
				return INVALID_LIMB;
		}
		// arms
		else if(zdiff > -LEG_Z)
		{
			if(!bMissingTopHalf)
			{
				if(armcross.z < 0)
					return LEFT_ARM;
				else 
					return RIGHT_ARM;
			}
			else
				return INVALID_LIMB;
		}
		else // legs
		{
			if(!bMissingBottomHalf)
			{
				// Because they don't have torso seperating them, check to cut off the other, if the 
				// opposite is already removed
				// left side and we still have the left leg
				if((armcross.z < 0
						&& BoneArr[LEFT_LEG] == 1)
					// or if the right leg if already cut
					|| BoneArr[RIGHT_LEG] == 0)
					return LEFT_LEG;
				else 
					return RIGHT_LEG;
			}
			else
				return INVALID_LIMB;
		}
	}
	else	// dead, or crawling, check bones individually
	{
		// Check for closest hit
		// check head first
		if(MyHead != None)
		{
			usecoords = GetBoneCoords(BONE_NECK);
			checkdist = VSize(usecoords.origin - hitlocation);
			fardist = checkdist;
			// If they were hit when crawling and still alive,
			// and it's a flying machete
			// then bias the hit, so as to usually pick the head
			if(Health > 0
				&& bMissingLegParts
				&& dtype == class'FlyingMacheteDamage')
				fardist=CRAWLING_BIAS*fardist;
		}
		else
			fardist = 65535; // head invalid, but still keep the index
		pickI=HEAD_INDEX;
		// check limbs too
		for(i=0; i<SeverBone.Length; i+=2)
		{
			// If they have the bone, check the distance, if they don't
			// then randomly decide to check the distance. So they could be hacking
			// at another limb trying to hit a new one, so give them a chance to miss sometimes
			if(BoneArr[i] == 1
				|| FRand() < HACK_OTHER_LIMB_RATIO)
			{
				usecoords = GetBoneCoords(SeverBone[i]);
				checkdist = VSize(usecoords.origin - hitlocation);
				if(checkdist < fardist)
				{
					fardist = checkdist;
					pickI=i;
				}
			}
		}
		// Return invalid, if we try to cut off a limb that's on a half
		// that we don't have
		if(bMissingTopHalf
			&& pickI < LEFT_LEG)
			return INVALID_LIMB;
		else if(bMissingBottomHalf
			&& pickI >= LEFT_LEG
			&& pickI < TORSO_INDEX)
			return INVALID_LIMB;
		// Returned the closest limb cut
		return pickI;

		/*
		// Check for closest hit
		// check head first
		usecoords = GetBoneCoords(BONE_NECK);
		checkdist = VSize(usecoords.origin - hitlocation);
		fardist = checkdist;
		pickI=HEAD_INDEX;
		log(self$" head dist "$checkdist);
		// check limbs too
		for(i=0; i<SeverBone.Length; i+=2)
		{
			usecoords = GetBoneCoords(SeverBone[i]);
			checkdist = VSize(usecoords.origin - hitlocation);
			log(self$" this bone "$SeverBone[i]$" dist "$checkdist);
			if(checkdist < fardist)
			{
				log(self$" picking that limb ");
				fardist = checkdist;
				pickI=i;
			}
		}
		// If any two things of the three things on the top of the body (head, 2 arms)
		// are missing and the any of those three are picked, let them have the third.
		// All those limbs are so close together, it's hard for a player to hit just what
		// he may want.
		// missing right arm, head, pick left arm
		if((pickI==RIGHT_ARM
				|| pickI==HEAD_INDEX)
			&& BoneArr[RIGHT_ARM] == 0
			&& MyHead == None)
			return pickI;
		// missing left arm, head, pick right arm
		else if((pickI==LEFT_ARM
				|| pickI==HEAD_INDEX)
			&& BoneArr[LEFT_ARM] == 0
			&& MyHead == None)
			return pickI;
		// missing right arm, left arm, pick head
		else if((pickI == LEFT_ARM
				|| pickI == RIGHT_ARM)
			&& BoneArr[LEFT_ARM] == 0
			&& BoneArr[RIGHT_ARM] == 0)
			return HEAD_INDEX; // head
		// Same with legs too, if you were aiming for one leg, and the other is already
		// off, but your still hitting, it give you former
		else if(pickI == LEFT_LEG
			&& BoneArr[LEFT_LEG]==0)
			return RIGHT_LEG;
		else if(pickI == RIGHT_LEG
			&& BoneArr[RIGHT_LEG]==0)
			return LEFT_LEG;
		else // whatever limb you were aiming at
			return pickI;
			*/
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Left arm check
///////////////////////////////////////////////////////////////////////////////
function bool HasLeftArm()
{
	if(BoneArr[LEFT_ARM] != 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Right arm check
///////////////////////////////////////////////////////////////////////////////
function bool HasRightArm()
{
	if(BoneArr[RIGHT_ARM] != 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Both arms check
///////////////////////////////////////////////////////////////////////////////
function bool HasBothArms()
{
	if(BoneArr[LEFT_ARM] != 0
		&& BoneArr[RIGHT_ARM] != 0)
		return true;
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
//	Decapitate the head and send it flying.
///////////////////////////////////////////////////////////////////////////////
function PopOffHead(vector HitLocation, vector Momentum)
{
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2Pawn(DamageInstigator) != None
		&& P2Pawn(DamageInstigator).bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.HeadsLopped++;
	}

	Super.PopOffHead(HitLocation, Momentum);
}

///////////////////////////////////////////////////////////////////////////////
// Given this index, cut off that limb
// Assumes it's there to cut
///////////////////////////////////////////////////////////////////////////////
function CutThisLimb(Pawn instigatedBy, int cutindex, vector momentum, float DoSound,
				 float DoBlood)
{
	local coords usec, usec2;
	local Limb uselimb;
	local rotator LimbRot;
	local Stump usestump;
	local P2Emitter sblood;
	local vector hitlocation, usev;

	// We got something chopped off
	bMissingLimbs=true;
	// Mark if it was a leg, specifically
	if(cutindex == LEFT_LEG
		|| cutindex == RIGHT_LEG)
		bMissingLegParts=true;
		
	// xPatch: Make sure they always drop weapon when they have their arms cut off.
	if (PersonController(Controller) != None 
		&& (cutindex == RIGHT_ARM || cutindex == LEFT_ARM))
		PersonController(Controller).ThrowWeapon();

	//log(self@"limb severed",'Debug');
	// Shrink bone just before it, completely
	SetBoneScale(cutindex+1, 0.0, SeverBone[cutindex+1]);
	// Mostly shrink the bone we've specified to keep some of the joint
	SetBoneScale(cutindex, 0.2, SeverBone[cutindex]);
	// Both bones are gone now
	BoneArr[cutindex+1] = 0;
	BoneArr[cutindex] = 0;

	// Generate limb cut off
	// Move hit location to bone joint of the next part down
	usec = GetBoneCoords(SeverBone[cutindex+1]);
	hitlocation = usec.origin;
	// momentum for limbs is different
	LimbRot=rotator(usec.Xaxis);
	// Move the limb forward a little too, because it's centered in the limb, but 
	// we want the joints to look close.
	hitlocation = MOVE_LIMB*vector(LimbRot) + hitlocation;
	Momentum = LimbMomMag*(Normal(HitLocation - Location) + 0.01*VRand());// + Velocity*Mass;
	//log(self@"spawning severed limb",'Debug');
	uselimb = spawn(LimbClass,self,,HitLocation,Rotation);
	if(uselimb != None)
	{
		uselimb.SetupLimb(Skins[0], AmbientGlow, LimbRot, bIsFat, bIsFemale, bPants);
		uselimb.GiveMomentum(Momentum);
		// Synch up your limbs to be dissolved the same as your body
		if(AWZombie(self) != None)
			uselimb.SetLimbToDissolve(TimeTillDissolve);
		if(cutindex < RIGHT_ARM) 
			uselimb.ConvertToLeftArm();
		else if(cutindex < LEFT_LEG) 
			uselimb.ConvertToRightArm();
		else if(cutindex < RIGHT_LEG) 
			uselimb.ConvertToLeftLeg();
		else
			uselimb.ConvertToRightLeg();
		// Make section you cut through explode
		usec2 = GetBoneCoords(SeverBone[cutindex]);
		// make it spawn about halfway between the two bones
		usev = (usec.origin + usec2.origin)/2;
	}

	//log(self@"spawning LimbExplode",'Debug');
	if(FRand() < DoBlood)
		spawn(class'LimbExplode',self,,usev);

	if(FRand() < DoSound)
		// play gross sound
		PlaySound(CutLimbSound,,,,,GetRandPitch());

	//log(self@"spawning stump",'Debug');
	// Now add stump to the bone that was cut on the person
	usestump = spawn(StumpClass,self,,usec2.origin);
	Stumps.Insert(Stumps.Length, 1);
	Stumps[Stumps.Length-1] = usestump;
	AttachToBone(usestump, SeverBone[cutindex]);
	usestump.SetupStump(Skins[0], AmbientGlow, bIsFat, bIsFemale, bPants, bSkirt);
	if(cutindex < RIGHT_ARM) 
		usestump.ConvertToLeftArm();
	else if(cutindex < LEFT_LEG) 
		usestump.ConvertToRightArm();
	else if(cutindex < RIGHT_LEG) 
		usestump.ConvertToLeftLeg();
	else
		usestump.ConvertToRightLeg();
	// attach blood too
	sblood= spawn(StumpBloodClass,self,,usec2.origin);
	AttachToBone(sblood, SeverBone[cutindex]);

	// Tell the dude if he did it
	if(AWDude(InstigatedBy) != None)
		AWDude(InstigatedBy).CutLimb(self);
}

// CheckForStumped
// check for Stumped achievement
function CheckIfStumped(Pawn instigatedBy)
{
	// If all four limbs are gone and we're STILL alive, give 'em props
	if (BoneArr[LEFT_ARM] == 0
		&& BoneArr[LEFT_LEG] == 0
		&& BoneArr[RIGHT_ARM] == 0
		&& BoneArr[RIGHT_LEG] == 0
		&& Health > 0
		&& PlayerController(InstigatedBy.Controller) != None
		&& AWZombie(Self) == None) // Too easy to do it to a zombie, make it be an actual living person
		{
		if( Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().EvaluateAchievement(PlayerController(InstigatedBy.Controller),'Stumped');		
		}
}

function ConvertToMacheteDamage(out class<DamageType> DamageType)
{
	if (DamageType == class'ChainsawBodyDamage')
		DamageType = class'ChainSawDamage';
	else
		DamageType = class'MacheteDamage';
}

function ConvertToCuttingDamage(out class<DamageType> DamageType)
{
	if (DamageType == class'ChainsawDamage'
		|| DamageType == class'ChainSawBodyDamage')
		DamageType = class'ChainSawCuttingDamage';
	else if (DamageType == class'MacheteDamageShovel')
		DamageType = class'CuttingDamageShovel';
	else
		DamageType = class'CuttingDamage';
}

///////////////////////////////////////////////////////////////////////////////
// Handle chopping off limbs and heads
// If you hit a limb, it will come off. If you hit the torso/pelvis area, 
// damage is simply inflicted with blood
//
// Return true if a limb came off, false, if it needs to go through the super takedamage
///////////////////////////////////////////////////////////////////////////////
function bool HandleSever(Pawn instigatedBy, vector momentum, out class<DamageType> damageType,
						  int cutindex, out int Damage, out vector hitlocation)
{
	// Don't allow in non-dismemberment mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| bNoDismemberment
		// Or in pussy non-blood mode
		|| !class'P2Player'.Static.BloodMode())
	{
		// Convert into normal cutting damage and run super instead
		ConvertToCuttingDamage(DamageType);		
		return false;
	}

	// Check where the hit was, if we weren't already passed one
	if(cutindex == INVALID_LIMB)
		cutindex = DecideSeverBone(HitLocation, damageType);
	// Make sure DecideSeverBone got a good limb
	if(cutindex == INVALID_LIMB)
	{
		// it's not there, so turn the damage into normal cutting damage
		ConvertToCuttingDamage(DamageType);
		return false;
	}
	else if(cutindex != HEAD_INDEX)
	{	
		// Cut limb off if it's still there
		if(BoneArr[cutindex] == 1
			// Only allow in dismemberment mode
			&& P2GameInfo(Level.Game).bEnableDismemberment
			&& !bNoDismemberment
			// And if blood is allowed
			&& class'P2Player'.Static.BloodMode()
			&& (P2Player(Controller) == None || Health <= 0)	// xPatch: No matter what don't cut off player's limbs if he's not dead
			)
		{
			if (DamageType == class'SuperShotgunBodyDamage'
				|| ClassIsChildOf(DamageType,class'BulletDamage')
				|| ClassIsChildOf(DamageType,class'ExplodedDamage'))
				// Don't play sound when dismembered by shotgun/explosion
				CutThisLimb(InstigatedBy, cutindex, momentum, 0, 1.0);
			else
				CutThisLimb(InstigatedBy, cutindex, momentum, 1.0, 1.0);
			CheckIfStumped(InstigatedBy);
			
			return true;
		}
		else // it's not there, so turn the damage into normal cutting damage
		{
			ConvertToCuttingDamage(DamageType);
			return false;
		}
	}
	else // cut off head
	{
		if(bHeadCanComeOff
			&& MyHead != None)
		{
			// momentum for head is different
			Momentum = HeadMomMag*(vect(0,0,1.0) + 0.05*VRand());
			PopOffHead(HitLocation, Momentum);
			PlaySound(BladeCleaveNeckSound,,,,,GetRandPitch());
			Damage = Health;
			// Tell the dude if he did it
			if(AWDude(InstigatedBy) != None)
				AWDude(InstigatedBy).CutOffHead(self);

			// Cut off the head. If it's a zombie, record it
			//log("head cut off by"@InstigatedBy@"and i'm a"@Self,'Debug');
			if (AWZombie(Self) != None
				&& PlayerController(InstigatedBy.Controller) != None)
				{
				if( Level.NetMode != NM_DedicatedServer ) 	PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'ZombiesBeheaded',1,true);
				}

			return true;
		}
		else // it's not there, so turn the damage into normal cutting damage
		{
			ConvertToCuttingDamage(DamageType);
			return true;
		}
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Handle chopping off limbs but no heads
///////////////////////////////////////////////////////////////////////////////
function bool HandleBulletSever(Pawn instigatedBy, vector momentum, out class<DamageType> damageType,
						  int cutindex, out int Damage, out vector hitlocation)
{
	local float DismChance;
	
	// Chance for dismember
	if (ClassIsChildOf(DamageType,class'SuperRifleDamage')
		|| ClassIsChildOf(DamageType,class'RifleDamage')
		|| ClassIsChildOf(DamageType,class'SuperShotgunBodyDamage'))
		DismChance = 1.00;	// Super Rifle	
	else if (ClassIsChildOf(damageType, class'ShotgunDamage'))
		DismChance = 0.35;	// Shotgun
	else if (ClassIsChildOf(damageType, class'MachineGunDamage'))
		DismChance = 0.12;	// Machine Gun
	else
		DismChance = 0.23;	// Pistol and other bullets 
	
	// Don't allow in non-dismemberment mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| bNoDismemberment
		// Or in pussy non-blood mode
		|| !class'P2Player'.Static.BloodMode()
		// No-Dismember Chance
		|| FRand() > DismChance 
		)
	{
		// Convert into normal cutting damage and run super instead
		//ConvertToCuttingDamage(DamageType);
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);		
		return false;
	}
	
	if((ClassIsChildOf(DamageType,class'MinigunDamage') && FRand() < 0.35)
		|| ClassIsChildOf(DamageType,class'SuperShotgunBodyDamage')) 
	{
		if(DecideScytheChop(InstigatedBy, momentum, damageType, Damage, HitLocation))
		return true;
	}

	// Check where the hit was, if we weren't already passed one
	if(cutindex == INVALID_LIMB)
		cutindex = DecideSeverBone(HitLocation, damageType);
	// Make sure DecideSeverBone got a good limb
	if(cutindex == INVALID_LIMB)
	{
		// it's not there, so turn the damage into normal cutting damage
		//ConvertToCuttingDamage(DamageType);
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
		return false;
	}
	else if(cutindex != HEAD_INDEX)
	{
		// Cut limb off if it's still there
		if(BoneArr[cutindex] == 1
			// Only allow in dismemberment mode
			&& P2GameInfo(Level.Game).bEnableDismemberment
			&& !bNoDismemberment
			// And if blood is allowed
			&& class'P2Player'.Static.BloodMode()
			)
		{
			// Don't play sound when dismembered by bullets
			CutThisLimb(InstigatedBy, cutindex, momentum, 0, 1.0);
	
			CheckIfStumped(InstigatedBy);
			
			return true;
		}
		else // it's not there, so turn the damage into normal cutting damage
		{
			//ConvertToCuttingDamage(DamageType);
			Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
			return false;
		}
	}
	else 
	{
		// turn the damage into normal cutting damage
		//ConvertToCuttingDamage(DamageType);
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
		return false; //true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Tear the torso from the extremities and send it flying backwards,
// while the limbs and head fall to the ground
// Must have all your limbs to start with
///////////////////////////////////////////////////////////////////////////////
function BlowOffHeadAndLimbs(Pawn InstigatedBy, vector momentum, out int Damage)
{
	local vector usemom, usev;
	local int i;

	// Tear off head
	usemom = vect(0,0,30000);
	PopOffHead(Location, usemom);
	PlaySound(BladeCleaveNeckSound,,,,,GetRandPitch());

	// Tear off all limbs
	// Only allow in dismemberment mode
	if (P2GameInfo(Level.Game).bEnableDismemberment
		&& !bNoDismemberment
		// And if blood is allowed
		&& class'P2Player'.Static.BloodMode()
		)
			for(i=0; i<SeverBone.Length; i+=2)
			{
				CutThisLimb(InstigatedBy, i, momentum, 0.5, 0.5);
			}

	// You'll definitely die from this
	Damage=Health;
	bSlomoDeath=true;
}

///////////////////////////////////////////////////////////////////////////////
// Smashes heads if hits above the belt, generally. Kills things fast
// Always used by zombie swipe smash (two armed smash to pop heads)
///////////////////////////////////////////////////////////////////////////////
function bool HandleSledge(Pawn instigatedBy, vector momentum, out class<DamageType> damageType,
						  out int Damage, out vector hitlocation)
{
	local vector usedir;
	local float damagedot;

	usedir = Normal(momentum);
	usedir.z=0;
	damagedot = vector(Rotation) dot usedir;
	
	//log(self@"handling sledge thrown by"@instigatedBy,'Debug');

	// Flying sledge can blow their head, arms, and legs off if your lucky
	if(InstigatedBy != None
		&& P2Player(InstigatedBy.Controller) != None
		&& P2Player(InstigatedBy.Controller).bLimbSnapper
		&& Health > 0
		&& MyHead != None
		&& abs(damagedot) > BLOW_OFF_LIMBS_DOT
		&& damageType == class'FlyingSledgeDamage'
		&& !bMissingLimbs)
	{
		BlowOffHeadAndLimbs(InstigatedBy, momentum, Damage);
		Momentum.x=Momentum.x*2;
		Momentum.y=Momentum.y*2;
		Momentum.z=Momentum.z/2;
		return true;
	}
	// Blows up head if it hits them high up,
	// or they're crawling, still alive, and it's a flying sledge/zombie smash
	else if(((bMissingLegParts
				&& Health > 0
				&& damagetype == class'FlyingSledgeDamage')
			|| Hitlocation.z > Location.z
			|| damagetype == class'SwipeSmashDamage')
		&& bHeadCanComeOff
		&& MyHead != None)
	{
		//log("it killed us",'Debug');
		if(class'P2Player'.static.BloodMode())
		{
			ExplodeHead(HitLocation, Momentum);
			// Tell the dude if he did it
			if(AWDude(InstigatedBy) != None)
				AWDude(InstigatedBy).CrushedHead(self);
			// And possibly get an achievement
			//log("try increasing stat with controller"@PlayerController(InstigatedBy.Controller),'Debug');
			if (PlayerController(InstigatedBy.Controller) != None
				// Don't give them the achievement for smashing heads with the baseball bat
				&& DamageType != class'BaseballBatDamage')
				{
				if( Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'SledgeFaceshots',1,true);
				}
		}
		Damage=Health;
		return true;
	}
	else // goes to super and hurts them really bad--probably kill them
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Add appropriate stumps for torso, head, arms when being cut in half
///////////////////////////////////////////////////////////////////////////////
function HalfTorsoStumps()
{
	local coords usecoords;
	local Stump usestump;
	local P2Emitter gutsemitter;
//	local int EffectsType;

	// Put stump on bottom of torso
	usecoords = GetBoneCoords(BONE_MID_SPINE);
	usestump = spawn(StumpClass,self,,usecoords.origin);
	Stumps.Insert(Stumps.Length, 1);
	Stumps[Stumps.Length-1] = usestump;
	AttachToBone(usestump, BONE_MID_SPINE);
	usestump.SetupStump(Skins[0], AmbientGlow, bIsFat, bIsFemale, bPants, bSkirt);
	usestump.ConvertToTorso();
	usestump.SetRelativeLocation(-StumpAdjust);
	// Attach guts to bottom side
	usecoords = GetBoneCoords(TOP_TORSO);
	usestump = spawn(GutsClass,self,,usecoords.origin);
	usestump.SetupStump(None, AmbientGlow, bIsFat, bIsFemale, bPants, bSkirt);
	Stumps.Insert(Stumps.Length, 1);
	Stumps[Stumps.Length-1] = usestump;
	AttachToBone(usestump, TOP_TORSO);
	// Make some guts spill out too
	gutsemitter = spawn(GutsEmitterClass1,self,,usecoords.origin);
	AttachToBone(gutsemitter, TOP_TORSO);
	gutsemitter = spawn(GutsEmitterClass2,self,,usecoords.origin);
	AttachToBone(gutsemitter, TOP_TORSO);

// xPatch: mod version stuff	
/*
	EffectsType = int(ConsoleCommand("get" @ GutsPath));
	
	if(EffectsType == 0)	// Use old var for compability with workshop gore mods.
		gutsemitter = spawn(GutsEmitterClass1,self,,usecoords.origin);
	else					// Use new var with multiple effect classes.
		gutsemitter = spawn(NewGutsEmitterClass1[EffectsType],self,,usecoords.origin);
	AttachToBone(gutsemitter, TOP_TORSO);
	
	if(EffectsType == 0)	// Use old var for compability with workshop gore mods.
		gutsemitter = spawn(GutsEmitterClass2,self,,usecoords.origin);
	else					// Use new var with multiple effect classes.
		gutsemitter = spawn(NewGutsEmitterClass2[EffectsType],self,,usecoords.origin);
	AttachToBone(gutsemitter, TOP_TORSO);
*/
// End
}

///////////////////////////////////////////////////////////////////////////////
// Pull cutindex off self person, and transfer it to bottomh
///////////////////////////////////////////////////////////////////////////////
function TransferStump(int cutindex, int stumpindex, AWPerson usepawn)
{
	local int i;
	local coords usecoords;
	local Stump usestump;

	if(BoneArr[cutindex] == 0)
	{
		if(usepawn != None)
		{
			// Shrink bone just before it, completely
			usepawn.SetBoneScale(cutindex+1, 0.0, SeverBone[cutindex+1]);
			// Mostly shrink the bone we've specified to keep some of the joint
			usepawn.SetBoneScale(cutindex, 0.2, SeverBone[cutindex]);
			// Both bones are gone now
			usepawn.BoneArr[cutindex+1] = 0;
			usepawn.BoneArr[cutindex] = 0;
		}
		// Find the leg stump from the original, and remove it
		for(i=0; i<Stumps.Length; i++)
		{
			if(Stumps[i] != None
				&& Stumps[i].StumpIndex == stumpindex)
			{
				usestump = Stumps[i];
				Stumps.Remove(i, 1);
				break;
			}
		}
		if(usestump != None)
		{
			// Detach it from the original
			DetachFromBone(usestump);
			if(usepawn != None)
			{
				usestump.SetOwner(usepawn);
				usestump.Instigator = usepawn;
				// Add it into the other pawns array
				usepawn.Stumps.Insert(usepawn.Stumps.Length, 1);
				usepawn.Stumps[usepawn.Stumps.Length-1] = usestump;
				// Attach now to the new bottom half
				usepawn.AttachToBone(usestump, SeverBone[cutindex]);
			}
			else // If we're not attaching again, then destroy us
				usestump.Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add appropriate stumps for pelvis, legs, when being cut in half
///////////////////////////////////////////////////////////////////////////////
function HalfPelvisStumps(AWPerson bottomh)
{
	local coords usecoords;
	local Stump usestump;
	local P2Emitter sblood;

	// Check if the body had any missing legs
	// If so, transfer those stump over to this new model, the bottom half
	TransferStump(LEFT_LEG, class'Stump'.default.LeftLegI, bottomh);
	TransferStump(RIGHT_LEG, class'Stump'.default.RightLegI, bottomh);
	// Put stump on top of pelvis
	usecoords = GetBoneCoords(BOTTOM_TORSO);
	usestump = spawn(StumpClass,self,,usecoords.origin);
	bottomh.Stumps.Insert(bottomh.Stumps.Length, 1);
	bottomh.Stumps[bottomh.Stumps.Length-1] = usestump;
	bottomh.AttachToBone(usestump, BOTTOM_TORSO);
	usestump.SetupStump(Skins[0], AmbientGlow, bIsFat, bIsFemale, bPants, bSkirt);
	usestump.SetRelativeLocation(StumpAdjust);
	usestump.ConvertToPelvis();
	// attach blood too
	sblood= spawn(StumpBloodClass,self,,usecoords.origin);
	bottomh.AttachToBone(sblood, BOTTOM_TORSO);
}

///////////////////////////////////////////////////////////////////////////////
// Chop person in half
// 
// Doesn't check if they still have a whole body to slice in half--just
// does it anyway, so be careful! Check bMissingTop/BottomHalf first. 
///////////////////////////////////////////////////////////////////////////////
function ChopInHalf(Pawn InstigatedBy, class<DamageType> DamageType, out vector momentum, out int Damage,
					out vector TrueHitLoc)
{
	local AWPerson bottomh;
	local coords usecoords;
	local rotator userot;
	local float Animf, AnimR;
	local name CurrAnim;
	local Actor HitActor;
	local vector HitLocation, HitNormal, checkpoint;
	local PawnExplosion exp;
	local bool bTopHalfStartedAlive;

	// Mark the bottom as missing becuase we're turning this bone into
	// the top half, and your missing your legs
	bMissingBottomHalf=true;
	bMissingLegParts=true;
	bMissingLimbs=true;

	// Save if we started alive or not for the bottom half to know how to animate if no ragdoll is around
	if(Health > 0)
		bTopHalfStartedAlive=true;

	// Make sure it kills them
	Damage = Health;

	// Do effects
	// Don't play sound if dismembered by shotgun/explosion
	if (DamageType != class'SuperShotgunBodyDamage'
		&& !ClassIsChildOf(DamageType,class'ExplodedDamage'))
		PlaySound(CutInHalfSound,,,,,GetRandPitch());
	spawn(class'LimbExplode',self,,Location);

	// Shrink bottom half
	// Shrink everything down all over, to very small. This number
	// must be greater than 0, or the matrices for the bones will be lots
	SetBoneScale(TORSO_INDEX, 1/SHRINK_PELVIS, BONE_PELVIS);
	// Grow it back up, but only for the top of the body
	SetBoneScale(TORSO_INDEX+1, SHRINK_PELVIS, TOP_TORSO);
	// Pop up the top half some
	momentum = VRand();
	momentum.z=0;
	momentum = (TopMomMag)*Normal(momentum);
	momentum.z += TopMomMag;
	TrueHitLoc.z+=(CollisionHeight/2); // make it hit above the center some for some spin
	// Turn off your collision
	SetCollision(false, false, false);
	// Make the bottom half, starting with the proper orientation
	usecoords = GetBoneCoords(BONE_PELVIS);
	userot = Rotator(usecoords.YAxis);
	userot.Yaw-=32768;
	// Check if they are too close to the ground to spawn
	checkpoint = Location;
	checkpoint.z-=CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true);
	if(HitActor != None)
	{
		// Move it up, off the ground
		HitLocation.z+=(1.5*CollisionHeight);
	}
	else // it's find where it is
		HitLocation = Location;

	// Add stumps for top half
	HalfTorsoStumps();

	// Spawn the bottom half
	if (Level.NetMode == NM_StandAlone) // Change by NickP: MP fix, there's no way to handle chopped body on client
		bottomh = spawn(class,Owner,,HitLocation);
	if(bottomh != None)
	{
		bottomh.bBottomHalfNewSpawn=true;
		// Remove head
		bottomh.DestroyHead();
		// Move bolt-ons from the bottom
		bottomh.DestroyBoltons();
		// Set mesh as the same
		bottomh.SetMyMesh(Mesh);
		// Set character type too (Gary)
		bottomh.CharacterType = CharacterType;
		// Make sure the bottom looks the same as the top
		bottomh.Skins[0] = Skins[0];
		// Set our clothing now that our skin is set, reset them first, then recheck them in the functions
		bottomh.bSkirt=false;
		bottomh.bPants=false;
		bottomh.DetermineClothing(GetItemName(String(Skins[0])));
		bottomh.DetermineClothing(GetItemName(String(Mesh)));
		// Get current anim 
		GetAnimParams(0, CurrAnim, AnimF, AnimR);
		bottomh.ShouldCower(bIsCowering);
		bottomh.ShouldCrouch(bIsCrouched);
		bottomh.ShouldDeathCrawl(bIsDeathCrawling);
		// Play anim same as current one, but make it start at the end
		bottomh.PlayAnimAt(CurrAnim, 1.0, 0.0, 0, 1.0);
		if(!bTopHalfStartedAlive)
			bottomh.bBottomWarpDeathAnim=true;
		// Shrink top half
		bottomh.SetBoneScale(TORSO_INDEX, 0.0, TOP_TORSO);
		// Kill it to turn it into karma/animation
		bottomh.Health=0;
		bottomh.OldTopHalfRotationKarma=userot;
		bottomh.OldTopHalfRotationAnim=Rotation;
		bottomh.PlayDying(class'ScytheDamage', Location);
		// And you're the bottom, that's missing it's top, including your arms
		bottomh.bMissingTopHalf=true;
		bottomh.bMissingLimbs=true;
		bottomh.BoneArr[LEFT_ARM]=0;
		bottomh.BoneArr[LEFT_ARM+1]=0;
		bottomh.BoneArr[RIGHT_ARM]=0;
		bottomh.BoneArr[RIGHT_ARM+1]=0;

		// Add stumps for bottom half
		HalfPelvisStumps(bottomh);
	}
	else // couldn't make the bottom, so make some explosion effects to show something happened
	{
		exp = spawn(class'PawnExplosion',,,usecoords.origin);
		exp.FitToNormal(usecoords.YAxis);
		// Check if the body had any missing legs
		// We didn't make the bottom half, but we still want to remove the stumps,
		// sending in None for our bottom half will do that for us.
		TransferStump(LEFT_LEG, class'Stump'.default.LeftLegI, None);
		TransferStump(RIGHT_LEG, class'Stump'.default.RightLegI, None);
	}

	// Make sure your legs are really gone too
	// Do this later, because the bottom half needs to know about missing limbs
	BoneArr[LEFT_LEG]=0;
	BoneArr[LEFT_LEG+1]=0;
	BoneArr[RIGHT_LEG]=0;
	BoneArr[RIGHT_LEG+1]=0;
	// Turn collision back on
	SetCollision(true, false, false);
	// Tell the dude if he did it
	if(AWDude(InstigatedBy) != None)
		AWDude(InstigatedBy).CutHalf(self);
}

///////////////////////////////////////////////////////////////////////////////
// Check to take off the head, cut in half, or cut off both legs, or nothing (return false)
///////////////////////////////////////////////////////////////////////////////
function bool DecideScytheChop(Pawn instigatedBy, out vector momentum, out class<DamageType> damageType,
						  out int Damage, out vector hitlocation)
{
	local int cutindex;
	local bool breturn1, breturn2;
	local coords usecoords;
	local float checkdist;
	
	// Don't bother in non-dismemberment or non-blood mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| bNoDismemberment
		|| !class'P2Player'.Static.BloodMode())
		return false;

	cutindex = INVALID_LIMB;
	// If the person is alive and standing up
	if(Health > 0
		&& !bIsDeathCrawling
		&& !bIsCrouched)
	{
		// Check to cut off the head first
		usecoords = GetBoneCoords(BONE_NECK);
		if(HitLocation.z > (usecoords.origin.z - HEAD_OFFSET_SCYTHE))
		{
			if(!bMissingTopHalf
				&& MyHead != None)
				cutindex = HEAD_INDEX;
		}
		// check to cut off both legs
		else if(HitLocation.z < Location.z - LEG_OFFSET_SCYTHE)
		{
			if(!bMissingBottomHalf)
				cutindex = LEFT_LEG;
		}
		// chop them in half
		else if(!bMissingTopHalf
			&& !bMissingBottomHalf)
		{
			cutindex = TORSO_INDEX;
		}
	}
	else // Dead or crouching--either way it's much harder to gauge their parts
	{
		// Check first to cut in half
		usecoords = GetBoneCoords(TOP_TORSO);
		checkdist = VSize(usecoords.origin - hitlocation);
		if(checkdist < CHOP_MIN
			&& !bMissingTopHalf
			&& !bMissingBottomHalf)
			cutindex = TORSO_INDEX;
		else
		{
			usecoords = GetBoneCoords(BONE_NECK);
			checkdist = VSize(usecoords.origin - hitlocation);
			if(!bMissingTopHalf
				&& MyHead != None)
			{
				// If they crawling, still alive, and it's a flying
				// scythe, then bias to most likley hit the head
				if(bMissingLegParts
					&& Health > 0
					&& damageType == class'FlyingScytheDamage')
					checkdist*=CRAWLING_BIAS;

				if(checkdist < CHOP_MIN)
					cutindex = HEAD_INDEX;
			}

			if(cutindex == INVALID_LIMB)
			{
				usecoords = GetBoneCoords(SeverBone[LEFT_LEG]);
				checkdist = VSize(usecoords.origin - hitlocation);
				if(checkdist < CHOP_MIN
					&& !bMissingBottomHalf)
					cutindex = LEFT_LEG;
			}
		}
	}

	if(cutindex == TORSO_INDEX)
		{
			ChopInHalf(InstigatedBy, DamageType, momentum, Damage, hitlocation);
			return true;
		}
	else if(cutindex != INVALID_LIMB)
	{
		breturn1 = HandleSever(instigatedBy, momentum, damageType, cutindex, Damage, hitlocation);
		// With the scythe, if your cutting off the left, also try to cut off the right leg
		if(cutindex == LEFT_LEG)
			breturn2 = HandleSever(instigatedBy, momentum, damageType, RIGHT_LEG, Damage, hitlocation);
		return (breturn1 || breturn2);
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
// Cut people in half
///////////////////////////////////////////////////////////////////////////////
function bool HandleScythe(Pawn instigatedBy, out vector momentum, out class<DamageType> damageType,
						  out int Damage, out vector hitlocation)
{
	// Check to see if you hit the person vaguely in the middle, to cut them in half
	if(DecideScytheChop(InstigatedBy, momentum, damageType, Damage, HitLocation))
	{
		// They did it! Grant an achievement
		if (PlayerController(InstigatedBy.Controller) != None
			// But only if it was done by the scythe proper (and not a chainsaw or something)
			&& (DamageType == class'ScytheDamage' || DamageType == class'FlyingScytheDamage')
			// And only if they're still *alive*
			&& !IsInState('Dying')
			)
			{
			if( Level.NetMode != NM_DedicatedServer ) PlayerController(InstigatedBy.Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(InstigatedBy.Controller),'PeopleScythed',1,true);
			}
		return true;
	}
	else // it's not there, so turn it into sever damage
	{
		ConvertToMacheteDamage(DamageType);
		return HandleSever(instigatedBy, momentum, damageType, INVALID_LIMB, Damage, hitlocation);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Cut throats
///////////////////////////////////////////////////////////////////////////////
function bool HandleBali(Pawn instigatedBy, out vector momentum, out class<DamageType> damageType,
						  out int Damage, out vector hitlocation)
{
	// Check to see if you hit the neck or above
	if(DecideSeverBone(HitLocation, class'MacheteDamage') == HEAD_INDEX
		&& Damage >= Health-MIN_HEALTH_TO_SLIT_THROAT
		&& !bHadThroatSlit
		// And if blood is allowed
		&& class'P2Player'.Static.BloodMode()
		)
	{	
		// They did it! Cut their throat
		SlitThroat(instigatedBy, HitLocation, Momentum);
		return true;
	}
	else // it's not there, so turn it into sever damage
		return false;
	return false;
}


//Used so that the head does not detach but the PourerFeeder still activates
function SlitThroat(Pawn instigatedBy, vector HitLocation, vector Momentum)
{
	local PoppedHeadEffects headeffects;
	local P2Emitter HeadBloodTrail;			// Blood trail I drip if I'm detached.

        //DOPAMINE DELETED
	//Super.PopOffHead(HitLocation, Momentum);



	// Create blood from neck hole
	if(FluidSpout == None
		&& P2GameInfo(Level.Game).AllowBloodSpouts())
	{
		// If we're puking at the time our head goes away, then
		// keep puke going out the neckhole

                /*DOPAMINE - this is unneeded I think
                if(Head(MyHead).PukeStream != None)
		{
			FluidSpout = spawn(class'PukePourFeeder',self,,Location);
			// Make it the same type of puke
			FluidSpout.SetFluidType(Head(MyHead).PukeStream.MyType);
		}
                */

                //dopamine try for our own bloodspout class
		//else// If our head is removed while not puking, then make blood squirt out
			FluidSpout = spawn(class'ThroatBloodSpoutFeeder',self,,Location);


		FluidSpout.MyOwner = self;
		FluidSpout.SetStartSpeeds(100, 10.0);
		AttachToBone(FluidSpout, BONE_HEAD);

		//Dopamine above function overrides spout direction
		SnapSpoutThroat(true);
	}
	
	bHadThroatSlit=True;
	
	// Let the controller know what happened
	if (PersonController(Controller) != None)
		PersonController(Controller).GotThroatCut(FPSPawn(instigatedBy));




	//Dopamine Removed all because we don't want the head to come off
	/**********************************************************************

	// Pop off the head
	//dopamine DELETED DetachFromBone(MyHead); AND REPLACED WITH
	//Super.DetachFromBone(MyHead);





	// Get it ready to fly
	Head(MyHead).StopPuking();
	Head(MyHead).StopDripping();
	MyHead.SetupAfterDetach();
	// Make a blood drip effect come out of the head
	HeadBloodTrail = Spawn(class'BloodChunksDripping ',self);
	HeadBloodTrail.Emitters[0].RespawnDeadParticles=false;
	HeadBloodTrail.SetBase(self);

	MyHead.GotoState('Dead');

	// Send it flying
	MyHead.GiveMomentum(Momentum);

	// Make some blood mist where it hit
	headeffects = spawn(class'PoppedHeadEffects',,,HitLocation);
	headeffects.SetRelativeMotion(Momentum, Velocity);

	//Remove connection to head but don't destroy it
	DissociateHead(false);
	
	**********************************************************************/
}

//Make the stream now shoot forwards instead of straight up
function SnapSpoutThroat(optional bool bInitArc)
{
	local vector startpos, X,Y,Z;
	local vector forward;
	local coords checkcoords;

	checkcoords = GetBoneCoords(BONE_NECK);
	FluidSpout.SetLocation(checkcoords.Origin);
	
	//dopamine REMINDER - blood direction is controled in ThroatBloodSpoutFeeder
	FluidSpout.SetDir(checkcoords.Origin, checkcoords.XAxis,,bInitArc);

}

///////////////////////////////////////////////////////////////////////////////
// Take damage (pawn call) but also save who attacked me
// Take limbs off in AW.
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local bool bUseSuper;
	local int actualDamage, StartDamage;
	local Controller Killer;
	local byte StateChange;	
	local class<DamageType> OriginalDamageType;
	
	//debuglog(self@"take damage of"@DamageType);

	/*
	// If we're using the no-dismemberment or no-blood mode,
	// convert dismembering damage types to non-dismembering ones.
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| !class'P2Player'.Static.BloodMode())
	{	
		if (DamageType == class'SuperShotgunBodyDamage')
			DamageType = class'ShotgunDamage';
		else if (ClassIsChildOf(DamageType, class'MacheteDamage')
			|| ClassIsChildOf(DamageType, class'ScytheDamage'))
			ConvertToCuttingDamage(DamageType);
	}
	*/
	
	//log(self$" take damage "$damagetype$" takes "$TakesZombieSmashDamage);
	// If we don't have a controller then we're either the player in a movie, or
	// we're an NPC starting out in a pain volume--either way, we don't
	// want to take damage in this state, without a controller.
	// For the player, this gives him god mode, while a movie is playing.
	if(Controller == None)
		return;

	StartDamage = Damage;
	DamageInstigator = instigatedBy;
	OriginalDamageType = damageType;

	// Reduce damage as necessary
	if(ClassIsChildOf(damageType, class'MacheteDamage'))
		Damage = TakesMacheteDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SledgeDamage'))
		Damage = TakesSledgeDamage*Damage;
	else if(ClassIsChildOf(damageType, class'SwipeSmashDamage'))
		Damage = TakesZombieSmashDamage*Damage;
	else if(ClassIsChildOf(damageType, class'ScytheDamage'))
		Damage = TakesScytheDamage*Damage;
	// Cat handles this
	//else if(ClassIsChildOf(damageType, class'DervishDamage'))
	//	Damage = TakesDervishDamage*Damage;
	
	// Can't cut off player limbs unless it's bMasochistPlayer (Ludicrous difficulty)
	if(P2Player(Controller) == None 
		|| (P2Player(Controller) != None && bMasochistPlayer && !P2Player(Controller).bGodMode))
	{
		// If it's a damage type and hasn't been lowered, allow limb severance
		// but if TakesMacheteDamage (for instance) is less than 1.0, then don't let limbs be cut
		if(ClassIsChildOf(damageType, class'MacheteDamage'))
		{
			if(Damage >= StartDamage || Damage > Health )
				bUseSuper = !(HandleSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
		else if(ClassIsChildOf(damageType, class'SledgeDamage')
				|| ClassIsChildOf(damageType, class'SwipeSmashDamage'))
		{
			if(Damage >= StartDamage || Damage > Health )
				bUseSuper = !(HandleSledge(InstigatedBy, momentum, damagetype, Damage, HitLocation));
			else if(TakesSledgeDamage > 0) // convert to lower damage type unless it was blocked completely
				damageType = class'BludgeonDamage';
		}
		else if(ClassIsChildOf(damageType, class'ScytheDamage')
				&& !ClassIsChildOf(damageType, class'SuperShotgunBodyDamage'))	// xPatch: SuperShotgunBodyDamage is handed differently now
		{
			if(Damage >= StartDamage || Damage > Health )
				bUseSuper = !(HandleScythe(InstigatedBy, momentum, damagetype, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
		else if(ClassIsChildOf(damageType, class'BaliDamage'))
		{
			if(Damage >= StartDamage || Damage > Health )
				bUseSuper = !(HandleBali(InstigatedBy, momentum, damagetype, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
// Added by Man Chrzan: xPatch 2.0
		// SuperShotgunBodyDamage is now handled with HandleBulletSever
		else if (ClassIsChildOf(DamageType,class'SuperShotgunBodyDamage'))
		{
			if(Damage >= StartDamage || Damage > Health )
				bUseSuper = !(HandleBulletSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation));
			else // convert to lower damage type
				ConvertToCuttingDamage(DamageType);
		}
		// Super Head-Exploding and Dismembering Rifle Damage
		else if (ClassIsChildOf(DamageType,class'SuperRifleDamage'))
		{
			if(Damage >= Health - MIN_HEALTH_TO_BULLET_CUT )
				HandleBulletSever(instigatedBy, momentum, damageType, INVALID_LIMB, Damage, hitlocation);
				
			bUseSuper=true;
		}
		// Bullet Dismemberment
/*		else if(ClassIsChildOf(damageType, class'BulletDamage'))
		{
			if( Damage >= Health
				&& class'P2Player'.Static.UseExtraGore() )
				HandleBulletSever(instigatedBy, momentum, damageType, INVALID_LIMB, Damage, hitlocation);
				
			bUseSuper=true;
		}	*/
// Man Chrzan: End
		else
			bUseSuper=true;

	}
	else // Make sure the player picks the super take damage
		bUseSuper=true;

	if(!bUseSuper)
	{
		// Multiply damage as necessary per pawn
		//Damage = FPSPawn(InstigatedBy).DamageMult*Damage;

		// Modify as necessary per game
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

		// Save the type that just hurt us
		LastDamageType = class<P2Damage>(DamageType);

		// Armor check.
		// Intercept damage, and if you have armor on, and it's a certain type of damage, 
		// modify the damage amount, based on the what hurt you.
		// Armor doesn't do anything for head shots
		if(Armor > 0
			&& bHasHead
			&& (Controller == None
				|| !Controller.bGodMode))
			ArmorAbsorbDamage(instigatedby, actualDamage, DamageType, HitLocation);

		// Don't call at all if you didn't get hurt
		// The above function does a better check on the head, so you may have shot too high or
		// something, at which point, it'll set the damage to 0, causing this to exit early
		if(Damage <= 0)
		{
			// Tell the character about the non-damage. Most of them will ignore this damage
			// but some people (like Krotchy) will use this to do things
			// Report the original damage asked to be delivered as a negative, so it's not
			// used as actual damage, but it's used to know how bad the damage would have been.
			if ( Controller != None )
				Controller.NotifyTakeHit(instigatedBy, HitLocation, -StartDamage, DamageType, Momentum);
			return;
		}

		// Send the real momentum to this function, please
		PlayHit(actualDamage, hitLocation, damageType, Momentum);

		// Take off health from damage
		Health = Health - actualDamage;

		// Check if he's dead
		if ( Health <= 0 )
		{
			// pawn died
			if ( instigatedBy != None )
				Killer = InstigatedBy.GetKillerController();
			if ( bPhysicsAnimUpdate )
				TearOffMomentum = Momentum / Mass;
			Died(Killer, damageType, HitLocation);
		}
		else
		{
			// Don't make things shoot you up into the air unless it's specific damage types
			if(class<P2Damage>(damageType) == None
				|| !class<P2Damage>(damageType).default.bAllowZThrow)
			{
				if(Physics == PHYS_Walking)
					momentum.z=0;
			}
			AddVelocity( momentum ); 

			// Tell the character about the damage
			if ( Controller != None )
				Controller.NotifyTakeHit(instigatedBy, HitLocation, Damage, DamageType, Momentum);
		}
	}
	else
	{
		//debuglog("going to super.");
		Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);

		// Change by NickP: MP fix
		if (Health <= 0)
		{
			MultiplayerDismemberment(OriginalDamageType, HitLocation);
			
			// xPatch: Dismemberment on explosion impact
			if(ClassIsChildOf(damageType, class'ExplodedDamage') && P2GameInfo(Level.Game).bEnableExplosionDismemberment)
				HandleExplosionDead(Damage, InstigatedBy, HitLocation, momentum, damageType);
		}
		// End
	}
}

// Change by NickP: MP fix
simulated function MultiplayerDismemberment(class<DamageType> damageType, vector HitLocation)
{
	// STUB
}
// End

///////////////////////////////////////////////////////////////////////////////
// Copy of P2MocapPawn, but changed the head setup because it caused karma
// crashes. 
///////////////////////////////////////////////////////////////////////////////
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocation, hitNormal, DeathImpulse, DeathVel;
	local actor tmpActor;
	local float maxDim;
	local bool bUsingRagdoll;

	// Save our rotation before we ragdolled.
	PreRagdollRotation = Rotation;

	bUsingRagdoll = AllowRagdoll(DamageType);

	//log(Self$" play dying "$bBottomHalfNewSpawn$" rot "$oldtophalfrotationAnim$" ragrot "$oldtophalfrotationkarma);
	bPlayedDeath = true;
	if ( bPhysicsAnimUpdate )
	{
		if(!bUsingRagdoll)
			PopUpDead();
		// only in MP
		if(Level.Game == None
			|| !Level.Game.bIsSinglePlayer)
			TearOffNetworkConnection(DamageType);
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(-1 * Health);
	}

	//log(self$" PlayDying, use ragdoll "$bUsingRagdoll);
	if(KParams == None
		// Don't let people who are supposed to die on start, to use ragdoll
		// unless they don't have a starting animation set
		// We disregard this after death.
		&& (PawnInitialState != EPawnInitialState.EP_Dead
			|| StartAnimation == '')
		&& bUsingRagdoll)
	{
		// Check to get a ragdoll skeleton from the game info.
		GetKarmaSkeleton();
	}

	if (Level.NetMode != NM_DedicatedServer
		&& (KarmaParamsSkel(KParams) != None) )
	{
		// If we're the bottom half of a cut up corpse and we were just spawned
		// and we need to be setup with rotation, etc, do it now
		if(bBottomHalfNewSpawn)
		{
			// Turn off the collision and move it back the proper spot
			SetPhysics(PHYS_None);
			SetCollision(false, false, false);
			SetRotation(OldTopHalfRotationKarma);
			SetCollision(true, false, false);
			bBottomHalfNewSpawn=false;
		}

		// Don't crouch or crawl anymore
		ShouldCrouch(false);
		ShouldDeathCrawl(false);

		StopAnimating();

		bPhysicsAnimUpdate = false;

		SetPhysics(PHYS_KarmaRagDoll);

		// Get things going first, for sure
		KWake();

		if((bIsDeathCrawling || bIsKnockedOut)
			&& !ClassIsChildOf(DamageType, class'ExplodedDamage'))
		{
			DeathVel = vect(0,0,0);
			DeathImpulse = vect(0,0,0);
		}
		else
		{
			// If the tear-off momentum is too small, give it a random kick so they don't slump over in the same position
			if (TearOffMomentum.Z < 10)
			{
				TearOffMomentum += 10*VRand();
				TearOffMomentum.Z = 0;
			}
			DeathVel = DeathVelMag * Normal(TearOffMomentum);
			DeathImpulse = Mass*TearOffMomentum;
		}

		CapKarmaMomentum(DeathImpulse, DamageType, 1.0, 1.0);

		// Set the guy moving in direction he was shot in general
		KSetSkelVel( DeathVel );

		// Move the body
		KAddImpulse(DeathImpulse, HitLoc);
	}

    SetTwistLook(0, 0);
    bDoTorsoTwist=false;

	TermSecondaryChannels();

	if(Physics != PHYS_KarmaRagDoll)
	{
		// If we're the bottom half of a torso, and we just got made, but the
		// ragdoll didn't work, then check if we have a rotation to match
		if(bBottomHalfNewSpawn)
		{
			//log(Self$" new rot "$oldtophalfrotationanim$" wants death "$bwantstodeathcrawl$" is death "$bisdeathcrawling);
			// Turn off the collision and move it back the proper spot
			SetPhysics(PHYS_None);
			SetCollision(false, false, false);
			SetRotation(OldTopHalfRotationAnim);
			SetCollision(true, false, false);
			bBottomHalfNewSpawn=false;
		}
		
		if(!bBottomWarpDeathAnim)
			PlayDyingAnim(DamageType,HitLoc);
		else
			PlayAnimAt(GetAnimDeathFallForward(), 1.0, 0.0, 0, 1.0);

		StopAcc();
	}

	// Set what happened to us on death
	DyingDamageType = class<P2Damage>(DamageType);

	// Check to make blood pool below us.
	// See if we already have blood squrting out of us in some other spot first
	// --if so, don't make this
	AttachBloodEffectsWhenDead();

	// If the head is still attached, then detach it, set collision ready
	// but don't make it fall. This way, people can get fairly accurate head
	// collision on dead bodies, so they can shoot the heads, even on dead
	// bodies
	if(AWHead(MyHead) != None)
	{
		if(AWHead(MyHead).CanDoDying())
		{
			// No matter what, always play the dead animation on the head
			MyHead.GotoState('Dead');
		}
	}

	GotoState('Dying');
}


///////////////////////////////////////////////////////////////////////////////
// Handle explosions blowing you apart
///////////////////////////////////////////////////////////////////////////////
function HandleExplosionDead(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local vector usevel;
	local int userand;
	
	// Don't do this in non-dismemberment or pussy no-blood mode
	if (!P2GameInfo(Level.Game).bEnableDismemberment
		|| !P2GameInfo(Level.Game).bEnableExplosionDismemberment	// xPatch
		|| bNoDismemberment
		|| !class'P2Player'.Static.BloodMode())
		return;

	// Randomly decide to cut off limbs or cut them in half
	userand = Rand(SEVER_RAND);	// 4 limbs, 1 to cut in half, and 1 to do nothing
	switch(userand)
	{
		// cut off right arm
		case 0: HandleSever(instigatedBy, momentum, damageType, RIGHT_ARM, Damage, hitlocation);
			break;
		// cut off left arm
		case 1: HandleSever(instigatedBy, momentum, damageType, LEFT_ARM, Damage, hitlocation);
			break;
		// cut off right leg
		case 2: HandleSever(instigatedBy, momentum, damageType, RIGHT_LEG, Damage, hitlocation);
			break;
		// cut off left leg
		case 3: HandleSever(instigatedBy, momentum, damageType, LEFT_LEG, Damage, hitlocation);
			break;
		// cut them in half
		case 4: 
			if(!bMissingTopHalf
				&& !bMissingBottomHalf)
				ChopInHalf(InstigatedBy, DamageType, momentum, Damage, hitlocation);
			break;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Functions for new fisting animations!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PlayWeaponDown()
{
	local EWeaponHoldStyle wstyle;
	local WeaponAttachment wpattach;

	wstyle = GetWeaponSwitchStyle();
	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

	if (WPAttach != None
		&& WPAttach.FiringMode == 'FISTS')
	{
		AnimEndSwitch();
		AnimBlendParams(WEAPONCHANNEL, 1.0, SWITCH_WEAPON_BLEND_TIME, 0, BONE_BLENDFIRING);
		WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
		if (bIsFat)
			PlayAnim('fat_fist_unload', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
		else if (CharacterType == CHARACTER_Mini)
			PlayAnim('mini_fist_unload', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
		else
			PlayAnim('fist_unload', PUT_DOWN_WEAPON_RATE, SWITCH_WEAPON_BLEND_TIME, WEAPONCHANNEL);
	}
	else
		Super.PlayWeaponDown();
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	local EWeaponHoldStyle wstyle;
	local WeaponAttachment wpattach;

	wstyle = GetWeaponSwitchStyle();

	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);

	// No fist bring-up anim yet?
	/*
	if (WPAttach != None
		&& WPAttach.FiringMode == 'FISTS')
	{
		
		AnimEndSwitch();
		
		// Make sure to reshow the grenade or anything coming out of your pockets.
		if(NewWeapon.AmmoType != None
			&& NewWeapon.AmmoType.HasAmmo()
			&& NewWeapon.ThirdPersonActor != None)
			NewWeapon.ThirdPersonActor.bHidden=false;
			
		AnimBlendParams(WEAPONCHANNEL, 1.0, BRING_UP_BLEND_TIME, 0, BONE_BLENDFIRING);
		WeaponBlendTime = SWITCH_WEAPON_BLEND_TIME;
		
	}
	else
	*/
		Super.PlayWeaponSwitch(NewWeapon);
}
/*
simulated function PlayFiring(float Rate, name FiringMode)
{
	local EWeaponHoldStyle wstyle;
	local bool StandingStill;

	// If he's not moving and not rotating make a recoil
	// Some weapons (like guns) don't want a recoil if you're
	// moving too much
	StandingStill = (NoLegMotion()
					&& (!bPlayer
						|| (Controller != None
							&& Controller.DesiredRotation == Controller.Rotation)));

	wstyle = GetWeaponFiringStyle();
	
	if (WPAttach.FiringMode == 'FISTS')
	{
	}
	else
		Super.PlayFiring(Rate, FiringMode);
}
*/

simulated function SetAnimStanding()
	{
	local EWeaponHoldStyle hold;
	local WeaponAttachment wpattach;

	// Check if player is typing
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
		return;

	hold = GetWeaponHoldStyle();
	if(MyWeapAttach != None)
		wpattach = MyWeapAttach;
	else if(Weapon != None)
		wpattach = WeaponAttachment(Weapon.ThirdPersonActor);
		
	if (WPAttach != None
		&& WPAttach.FiringMode == 'FISTS')
	{
		if (bIsFat)
			LoopIfNeeded('fat_fist_idle',1.0);
		else if (CharacterType == CHARACTER_Mini)
			LoopIfNeeded('mini_fist_idle',1.0);
		else
			LoopIfNeeded('fist_idle',1.0);
	}
	else
		Super.SetAnimStanding();
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto simulated state Living
{
	/*
	event Tick(float DeltaTime)
	{
		const STUCK_CHECK_DELTA = 0.5;
		Super.Tick(DeltaTime);
		
		LastStuckCheck += DeltaTime;
		if (LastStuckCheck > STUCK_CHECK_DELTA)
		{
			LastStuckCheck = 0;
			// Unsticking logic for NPCs.
			if (Controller != None && !Controller.bIsPlayer && DetectStuckPlayer(DeltaTime))
				HandleStuckPlayer();
		}
	}
	*/

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
	//  Play sound
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer()
	{
		local float vol, usepitch, userad;
		local vector usevel;
		local bool bOtherMp; // someone other than you

//		log(self$" timer, phys "$Physics$" walking "$bIsWalking$" velocity "$Velocity$" role "$Role$" viewport "$ViewPort(PlayerController(Controller).Player));

		// only on client or stand alone
		// don't play footsteps during cinema
		// also don't play footsteps while deathcrawling
		/*
		if(bDoFootsteps && !P2GameInfo(Level.Game).IsCinematic() && !bIsDeathCrawling)
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

				usepitch=1.0;
				userad = FOOTSTEP_RADIUS;

				if(VSize(Velocity) > 0)
				{
					//PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,vol,,userad,usepitch);
					PlayFootstep(vol, userad, usepitch);
					DrawFootprint();
					bPlayingFootstepSound=true;
				}
			}
			else
				SetTimer(WALK_FOOTSTEP_TIME, false);
		}
		*/
	}
	simulated function BeginState()
	{
//		log(self$" beginstate Living, role "$Role$" remote "$RemoteRole);
		SetTimer(RUN_FOOTSTEP_TIME, false);
	}
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
	// Get hurt, plus some ragdoll
	//
	// Only let you hurt the dead guys in single player, because in MP, the characters
	// won't match up with other people's computers and if you set someone on fire
	// they will be on fire in two different incorrect places (blood would shoot
	// out of weird places too.. ) It just makes a big mess.
	///////////////////////////////////////////////////////////////////////////////
	function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, 
							Vector Momentum, class<DamageType> DamageType)
	{
		local bool bUseSuper;

		//ErikFOV Change: Fix problem
		if (bPendingDelete || bDeleteMe)
			return;
		//End

		if(Level.Game != None
			&& Level.Game.bIsSinglePlayer)
		{
			if(class'P2Player'.static.BloodMode()
				// can't cut off player limbs
				&& P2Player(Controller) == None)
			{
				if(ClassIsChildOf(damageType, class'MacheteDamage'))
					bUseSuper = !(HandleSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation));
				else if(ClassIsChildOf(damageType, class'SledgeDamage'))
					bUseSuper = !(HandleSledge(InstigatedBy, momentum, damagetype, Damage, HitLocation));
				else if(ClassIsChildOf(damageType, class'ScytheDamage'))
					bUseSuper = !(HandleScythe(InstigatedBy, momentum, damagetype, Damage, HitLocation));
				
				/////////////////////////////////////
				// Added by Man Chrzan: xPatch 2.0 (EXTRA GORE Option)
										
				// Super Rifle always dismember corpses
				else if (ClassIsChildOf(DamageType,class'SuperRifleDamage'))
					{			
						HandleBulletSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation);
						Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
					}
				// Bullets dismember corpses if enabled
/*				else if (ClassIsChildOf(DamageType,class'BulletDamage') 
							&& class'P2Player'.Static.UseExtraGore())										
					{	  		
						HandleBulletSever(InstigatedBy, momentum, damagetype, INVALID_LIMB, Damage, HitLocation);
						Super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, damageType);
					}	*/
					
				// Man Chrzan: End
				/////////////////////////////////////
				else
					bUseSuper=true;
				if(ClassIsChildOf(damageType, class'CuttingDamage'))
					PlaySound(FleshHit,,,,,GetRandPitch());
			}

			if(bUseSuper)
			{
				// Check to cut off limbs, and pass it along to original TakeDamage
				// for momentum transfer
				if(class'P2Player'.static.BloodMode()
					&& ClassIsChildOf(damageType, class'ExplodedDamage'))
					HandleExplosionDead(Damage, InstigatedBy, HitLocation, momentum, damageType);

				Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		Super.BeginState();
	}
WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
	if(bSlomoDeath)
	{
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(0.1);
	}
	Sleep(SLOMO_DEATH_TIME);
	if(bSlomoDeath)
		if(P2GameInfoSingle(Level.Game) != None)
			P2GameInfoSingle(Level.Game).PossibleSetGameSpeed(1.0);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// WaitingOnLimbsAfterLoad
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitingOnLimbsAfterLoad
{
Begin:
	// Handle limb removal after load
	RemoveLimbsAfterLoad(self);
	if(StartState == GetStateName())
		GotoState('');
	else
		GotoState(StartState);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// AWLoadedDying
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AWLoadedDying extends Dying
{
	///////////////////////////////////////////////////////////////////////////////
	// LoadedDying is not normal. For instance, we don't want to retell people
	// around us that we died, or they'll freak out all over again.
	///////////////////////////////////////////////////////////////////////////////
	function bool DiedNormally()
	{
		return false;
	}

	///////////////////////////////////////////////////////////////////////////////
	// Disconnect my variable from my torso fire, now or later
	///////////////////////////////////////////////////////////////////////////////
	function UnhookPawnFromFire()
	{
		GotoState('AWLoadedDying', 'WaitToResetFire');
	}
WaitToResetFire:
	Sleep(FIRE_RESET_TIME);
	MyBodyFire=None;
Begin:
	RemoveLimbsAfterLoad(self);
	//.Fall to the ground
	SetPhysics(PHYS_Falling);
	PlayAnim(GetAnimDeathFallForward(),SUPER_FAST_RATE);
	Sleep(0.05);
	bHidden=false;
}

// Change by NickP: MP fix
simulated function ClientSetupStump(Stump aStump)
{
	local int i;

	if (aStump == None || aStump.bDeleteMe)
		return;

	aStump.SetupStump(Skins[0], AmbientGlow, bIsFat, bIsFemale, bPants, bSkirt);
	aStump.bTearOff = true;

	// Bottom torso removed
	if( aStump.AttachmentBone == BONE_MID_SPINE )
	{
		const USE_MAX_RENDER_TIME = 1.0;
		if ( (Level.TimeSeconds - LastRenderTime) < USE_MAX_RENDER_TIME )
		{
			SetBoneScale(TORSO_INDEX, 1/SHRINK_PELVIS, BONE_PELVIS);
			SetBoneScale(TORSO_INDEX+1, SHRINK_PELVIS, TOP_TORSO);
		}
		else aStump.bHidden = true;
	}
	// Top torso removed
	else if( aStump.AttachmentBone == BOTTOM_TORSO )
	{
		SetBoneDirection(SeverBone[0], rot(0,0,0), vect(0,0,0), 0);
		SetBoneDirection(SeverBone[1], rot(0,0,0), vect(0,0,0), 0);
		SetBoneDirection(SeverBone[2], rot(0,0,0), vect(0,0,0), 0);
		SetBoneDirection(SeverBone[3], rot(0,0,0), vect(0,0,0), 0);

		SetBoneDirection(TOP_TORSO, rot(0,0,0), vect(0,0,0), 0);
		SetBoneScale(TORSO_INDEX, 0.0, TOP_TORSO);
	}
	// Other limbs removed
	else
	{
		for( i = 0 ; i < SeverBone.Length ; i+=2 )
		{
			if( aStump.AttachmentBone == SeverBone[i] )
				break;
		}
		SetBoneDirection(SeverBone[i+1], rot(0,0,0), vect(0,0,0), 0);
		SetBoneScale(i+1, 0.0, SeverBone[i+1]);
		SetBoneDirection(SeverBone[i], rot(0,0,0), vect(0,0,0), 0);
		SetBoneScale(i, 0.2, SeverBone[i]);
	}

	// Since it's called client-side only we can use this array too
	Stumps.Insert(Stumps.Length, 1);
	Stumps[Stumps.Length-1] = aStump;
}
// End

defaultproperties
{
	SeverBone(0)="MALE01 L UpperArm"
	SeverBone(1)="MALE01 L Forearm"
	SeverBone(2)="MALE01 R UpperArm"
	SeverBone(3)="MALE01 R Forearm"
	SeverBone(4)="MALE01 L Thigh"
	SeverBone(5)="MALE01 L Calf"
	SeverBone(6)="MALE01 R Thigh"
	SeverBone(7)="MALE01 r calf"
	BoneArr(0)=1
	BoneArr(1)=1
	BoneArr(2)=1
	BoneArr(3)=1
	BoneArr(4)=1
	BoneArr(5)=1
	BoneArr(6)=1
	BoneArr(7)=1
	HeadMomMag=23000.000000
	LimbMomMag=12000.000000
	TopMomMag=25000.000000
	StumpBloodClass=Class'StumpBlood'
	StumpClass=Class'Stump'
	LimbClass=Class'Limb'
	GutsClass=Class'TorsoGuts'
	GutsEmitterClass1=Class'TorsoGutsCurl'
	GutsEmitterClass2=Class'TorsoGutsSnake'
	GurgleClass=Class'GurgleBlood'
	FleshHit=Sound'AWSoundFX.Body.limbflop2'
	CutLimbSound=Sound'AWSoundFX.Machete.machetelimbhit'
	CutInHalfSound=Sound'AWSoundFX.Scythe.scythehalfcut'
	BladeCleaveNeckSound=Sound'AWSoundFX.Machete.macheteslice'
	TakesSledgeDamage=1.000000
	TakesMacheteDamage=1.000000
	TakesScytheDamage=1.000000
	TakesDervishDamage=1.000000
	TakesZombieSmashDamage=1.000000
	BlockMeleeTime=2.000000
	AW_SPMeshAnim=MeshAnimation'AWCharacters.animAvg_AW'
	StumpBigClass=Class'StumpBigGuy'
	LimbBigClass=Class'LimbBigGuy'
	HeadClass=Class'AWHead'
	BodyHitSounds(0)=Sound'MiscSounds.People.bodyhitground1'
	BodyHitSounds(1)=Sound'MiscSounds.People.bodyhitground2'
	ChameleonMeshPkgs(0)="Characters"
	ChamelHeadSkins(0)="ChamelHeadSkins.MWA__001__AvgMale"
	ChamelHeadSkins(1)="ChamelHeadSkins.MBA__013__AvgBrotha"
	ChamelHeadSkins(2)="ChamelHeadSkins.MBA__014__AvgBrotha"
	ChamelHeadSkins(3)="ChamelHeadSkins.MMA__016__AvgMale"
	ChamelHeadSkins(4)="ChamelHeadSkins.MMF__024__FatMale"
	ChamelHeadSkins(5)="ChamelHeadSkins.MWA__002__AvgMale"
	ChamelHeadSkins(6)="ChamelHeadSkins.MMA__003__AvgMale"
	ChamelHeadSkins(7)="ChamelHeadSkins.MWA__004__AvgMale"
	ChamelHeadSkins(8)="ChamelHeadSkins.MWA__005__AvgMale"
	ChamelHeadSkins(9)="ChamelHeadSkins.FBA__063__FemSH"
	ChamelHeadSkins(10)="ChamelHeadSkins.MWA__007__AvgMale"
	ChamelHeadSkins(11)="ChamelHeadSkins.MWA__008__AvgMale"
	ChamelHeadSkins(12)="ChamelHeadSkins.MWA__009__AvgMale"
	ChamelHeadSkins(13)="ChamelHeadSkins.MWA__010__AvgMale"
	ChamelHeadSkins(14)="ChamelHeadSkins.MWA__011__AvgMale"
	ChamelHeadSkins(15)="ChamelHeadSkins.MWA__015__AvgMale"
	ChamelHeadSkins(16)="ChamelHeadSkins.MWA__021__AvgMaleBig"
	ChamelHeadSkins(17)="ChamelHeadSkins.MWA__035__AvgMale"
	ChamelHeadSkins(18)="ChamelHeadSkins.MWF__025__FatMale"
	ChamelHeadSkins(19)="ChamelHeadSkins.MWA__022__AvgMaleBig"
	ChamelHeadSkins(20)="ChamelHeadSkins.FBA__033__FemSH"
	ChamelHeadSkins(21)="ChamelHeadSkins.FMA__028__FemSH"
	ChamelHeadSkins(22)="ChamelHeadSkins.FMA__034__FemSH"
	ChamelHeadSkins(23)="ChamelHeadSkins.FWA__026__FemLH"
	ChamelHeadSkins(24)="ChamelHeadSkins.FWA__027__FemLH"
	ChamelHeadSkins(25)="ChamelHeadSkins.FWA__029__FemSH"
	ChamelHeadSkins(26)="ChamelHeadSkins.FWA__032__FemSH"
	ChamelHeadSkins(27)="ChamelHeadSkins.FWF__023__FatFem"
	ChamelHeadSkins(28)="ChamelHeadSkins.FWA__037__FemSHcropped"
	ChamelHeadSkins(29)="ChamelHeadSkins.FMA__038__FemSHcropped"
	ChamelHeadSkins(30)="ChamelHeadSkins.FMA__039__FemSHcropped"
	ChamelHeadSkins(31)="ChamelHeadSkins.FWA__040__FemSHcropped"
	ChamelHeadSkins(32)="ChamelHeadSkins.MBF__042__FatMale"
	ChamelHeadSkins(33)="ChamelHeadSkins.FBF__043__FatFem"
	ChamelHeadSkins(34)="ChamelHeadSkins.FMF__044__FatFem"
	ChamelHeadSkins(35)="ChamelHeadSkins.FWA__031__FemSH"
	ChamelHeadSkins(36)="End"
	ChamelHeadMeshPkgs(0)="heads"
	Conscience=0.500000
	bCellUser=True
	bDoFootsteps=True
	CellPhoneClass=class'CellPhoneWeapon'
	CellBeep=Sound'AWSoundFX.Phone.phonebeep'
	CellRing=Sound'AWSoundFX.Phone.cellring'
	//FootStepSounds(0)=Sound'MoreMiscSounds.loudfootsteps.footstep1h'
	//FootStepSounds(1)=Sound'MoreMiscSounds.loudfootsteps.footstep2h'
	//FootStepSounds(2)=Sound'MoreMiscSounds.loudfootsteps.footstep4h'
	//FootStepSounds(3)=Sound'MoreMiscSounds.loudfootsteps.footstep5h'
	//FootStepSounds(4)=Sound'MoreMiscSounds.loudfootsteps.footstep6h'
	ExtraAnims(0)=MeshAnimation'AW7Characters.animAvg_AW7'
	ExtraAnims(1)=MeshAnimation'AW7Characters.SyS_Fisting'
	//ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	ExtraAnims(2)=None
	ExtraAnims(3)=MeshAnimation'AW7Characters.SYS_HEDGETRIMMER'
	ExtraAnims(4)=MeshAnimation'AW7Characters.holdbag'
	ExtraAnims(5)=MeshAnimation'MoreCharacters.sitdown'
	ExtraAnims(6)=MeshAnimation'MoreCharacters.f_sit_idle'
	ExtraAnims(7)=MeshAnimation'MoreCharacters.valentine_anim'
	ExtraAnims(8)=MeshAnimation'AW7Characters.fat_fistsing'
	ExtraAnims(9)=MeshAnimation'xEDAnims.animED' // xPatch
	PLAnims=MeshAnimation'Characters.animAvg_PL'
	PLAnims_Fat=MeshAnimation'Characters.animFat_PL'
	PLAnims_Mini=MeshAnimation'Gary_Characters.animMini_PL'
	bNoDismemberment=False
}
