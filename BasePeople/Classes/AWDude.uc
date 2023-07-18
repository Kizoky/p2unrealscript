//=============================================================================
// AWDude.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Weekend pack version
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
class AWDude extends AWBystander
	notplaceable;

var AnimNotifyActor usegrenade;	// Grenade we have in our hand for grenade suicides
var StaticMesh grenade;

//var Sound FootStepSounds[5];
//var Sound MPFootStepSounds[5];

var bool bPlayingFootstepSound;	// Set to true when you play a step, false after timer is
								// called again
var(Character) MeshAnimation	CoreMPMeshAnim;		// Core MP animations (used in addition to special animations)
var(Character) Mesh				CoreSPMesh;		// Original, non-MP mesh. Make the default the MP mesh

var travel int			HasHeadInjury;	// if you have head injury effects occuring, 1 if true
var travel int			P2BloodWeaponTextureIndex;	// Index into blood this current weapon
													// is at, for travelling between levels
var	travel int			GaryHeads;
var class<P2Emitter> dblastclass;
var class<P2Emitter> dblastexplclass;
var Sound BlastBlockSound; //reflector wave thing blocks damage

var travel bool bLeprechaunMode;
var float LeprechaunDrawScale;
var float LeprechaunVoicePitch;
var float LeprechaunHatScale;
var float LeprechaunBeardScale;
var vector LeprechaunHatPivot;
var vector LeprechaunBeardPivot;
var StaticMesh LeprechaunHatBolton;
var StaticMesh LeprechaunBeardBolton;

const HAND_OFFSET	=	vect(8, -3.5, 0);
const HEAD_OFFSET	=	vect(-1, 8, -1.3);
const HEAD_ROTATION	=	vect(0, 0, 16000);
const GRENADE_SCALE = 0.65;
const GRENADE_FORWARD_MOVE  =   10;

const RUN_FOOTSTEP_TIME		=	0.35;
const WALK_FOOTSTEP_TIME	=	0.60;

const WALK_VOL				= 0.03;
const RUN_VOL				= 0.1;
const LAND_VOL				= 0.5;

const OTHERS_PITCH			= 0.9;

const FOOTSTEP_RADIUS			=	100;
const FOOTSTEP_RADIUS_MP		=	200;
const FOOTSTEP_RADIUS_LOCAL_MP	=	20;

const MOVE_BUFFER = 100;
const UPDATE_SURFACE_TIME = 0.2;	// How often we update our surfacetype if our velocity > 0 but accel == 0

var float FootstepTime;		// Time in seconds that the current footstep should last
var float LastFootstepTime;	// Last time we played a footstep
var float LastSurfaceTime;	// Last time we updated our surface type
var float FootprintTime;	// Time in seconds that the current footprint should last
var float LastFootprintTime;// Last time we dropped a footprint

// Moved to TakeFallDamage - Rick
/*
event PostBeginPlay()
{
	Super.PostBeginPlay();
	// Let 'em fall safely from higher distances for... reasons :O
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		MaxFallSpeed *= 2;
}
*/

///////////////////////////////////////////////////////////////////////////////
// PlayWalking
// Player characters using a gamepad can control walk/run with the analog stick
///////////////////////////////////////////////////////////////////////////////
simulated function PlayWalking(bool bWalk)
{
	// Only allow if they're actually in a position where they could walk or run.
	if (Physics != PHYS_Walking									// Don't allow if not actually in walking mode
		|| (Controller != None && Controller.bPreparingMove)	// No controller
		|| (PlayerController(Controller) == None)				// No Player Controller
		|| bIsCrouched											// Not while crouched
		|| bIsWalking)											// If bIsWalking then the player is probably using kb/m and doesn't need this anyway
		return;

	
}

///////////////////////////////////////////////////////////////////////////////
// Say the specified line of dialog and animate face appropriately.
// Returns the duration of the specified line.
///////////////////////////////////////////////////////////////////////////////
function float Say(out P2Dialog.SLine line, optional bool bImportant,
				   optional bool bIndexValid, optional int SpecIndex)
{
	local float duration;
	// Let super class handle audio
	duration = Super.Say(line, False, bIndexValid, SpecIndex);
	
	if (line.bCoreyLine)
		P2Player(Controller).SaidCoreyLine(duration);
	
	return duration;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event TravelPostAccept() {
    super.TravelPostAccept();

    if (bLeprechaunMode)
        TurnIntoLeprechaun();
}

///////////////////////////////////////////////////////////////////////////////
// TakeFallingDamage
// Adjust falling damage based on surface type, and whether or not enhanced
// game is active
///////////////////////////////////////////////////////////////////////////////
function TakeFallingDamage()
{
	local float Shake, DamageAmount, UseMaxFallSpeed;
	local ESurfaceType UseST;
	local Vector HitLocation, HitNormal, TraceEnd, TraceStart;
	local Material OutMaterial;
	local Actor HitActor;
	local int i;

	const MAX_ENHANCED_FALL_DAMAGE = 0.05;	// Max fall damage as a percentage of current health. Enhanced game only
	
	// Start with the basics
	UseMaxFallSpeed = MaxFallSpeed;
	
	// If in enhanced mode, double it
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
	{
		UseMaxFallSpeed *= 2.0;
	}
	
	// Find current surfacetype, try based actor first
	if (Base != None && LevelInfo(Base) == None && Base.SurfaceType != EST_Default)
		UseST = Base.SurfaceType;
	// otherwise, do it the hard way, with a trace
	else
	{
		TraceStart = Location /*+ (Vect(0,0,1) * CollisionHeight)*/;
		TraceEnd = TraceStart - (Vect(0,0,2) * CollisionHeight);
		HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, , , OutMaterial);
		if (OutMaterial != None)
			UseST = OutMaterial.SurfaceType;
	}
	
	// Find listed surface type
	for (i = 0; i < SurfaceTypeTensions.Length; i++)
	{
		if (SurfaceTypeTensions[i].SurfaceType == UseST)
		{
			// Adjust falling speed if necessary
			if (SurfaceTypeTensions[i].MaxFallMult != 0)
				UseMaxFallSpeed *= SurfaceTypeTensions[i].MaxFallMult;
		}
	}
	
	// Now do the actual falling damage
	if (Velocity.Z < -0.5 * UseMaxFallSpeed)
	{
		MakeNoise(FMin(2.0,-0.5 * Velocity.Z/(FMax(JumpZ, 150.0))));
		if (Velocity.Z < -1 * UseMaxFallSpeed)
		{
			if ( Role == ROLE_Authority )
			{
				DamageAmount = -100 * (Velocity.Z + UseMaxFallSpeed)/UseMaxFallSpeed;
				// Reduce damage in Enhanced Game, but don't eliminate it completely. There should be some penalty for fucking up with the flying shovel
				if (P2GameInfoSingle(Level.Game) != None
					&& P2GameInfoSingle(Level.Game).VerifySeqTime())
						DamageAmount = FMin(HealthMax * MAX_ENHANCED_FALL_DAMAGE, DamageAmount);

				TakeDamage(DamageAmount, None, Location, vect(0,0,0), class'Fell');
			}
		}
		if ( Controller != None )
		{
			Shake = FMin(1, -1 * Velocity.Z/UseMaxFallSpeed);
			// RWS Change 01/06/03 start. 
			// vr 2141
			Controller.ShakeView(Shake * vect(30,0,0), 
               120000 * vect(1,0,0), 
               0.15 + 0.005 * Shake, 
               Shake * vect(0,0,0.03), 
               vect(1,1,1), 
               0.2);
			// vr. 927	
			//Controller.ShakeView(0.175 + 0.1 * Shake, 850 * Shake, Shake * vect(0,0,1.5), 120000, vect(0,0,10), 1);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called after a saved game has been loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Super.PostLoadGame();
	// If we have a head injury, tell the hud about it.
	if(HasHeadInjury == 1)
		P2Hud(P2Player(Controller).myHUD).DoWalkHeadInjury();
}

///////////////////////////////////////////////////////////////////////////////
// Switch to this new mesh
///////////////////////////////////////////////////////////////////////////////
function SwitchToNewMesh(Mesh NewMesh,
						 Material NewSkin,
						 Mesh NewHeadMesh,
						 Material NewHeadSkin,
						 optional Mesh NewCoreMesh)
{
	// Setup body (true means "keep anim state")
	SetMyMesh(NewMesh, NewCoreMesh, true);
	SetMySkin(NewSkin);
	PlayWaiting();

	// Setup head
	if (NewHeadMesh != None)
	{
		MyHead.LinkMesh(NewHeadMesh, true);
		// Because our headmesh is screwey, ask the head what it wants to set
		if(AWDudeHead(MyHead) != None)
			AWDudeHead(MyHead).SetMainSkin(NewHeadSkin);
		else
			MyHead.Skins[0] = NewHeadSkin;
	}
}

///////////////////////////////////////////////////////////////////////////////
// You've bloodied your weapon some how or another (use other
// more specific functions below when you know exactly what happened)
///////////////////////////////////////////////////////////////////////////////
function DrewBlood()
{
	if(P2BloodWeapon(Weapon) != None)
		P2BloodWeapon(Weapon).DrewBlood();
}

///////////////////////////////////////////////////////////////////////////////
// You cut a limb off someone
///////////////////////////////////////////////////////////////////////////////
function CutLimb(AWPerson cutme)
{
	// Record limb hacking by dude
	if(P2GameInfoSingle(Level.Game) != None)
	{
		P2GameInfoSingle(Level.Game).TheGameState.LimbsHacked+=1.0;
	}
	if(P2BloodWeapon(Weapon) != None && Cutme.MyRace < RACE_Automaton)
		P2BloodWeapon(Weapon).DrewBlood();
}

///////////////////////////////////////////////////////////////////////////////
// You cut someone in half
///////////////////////////////////////////////////////////////////////////////
function CutHalf(FPSPawn cutme)
{
	//log(Self$" cut me in half "$Weapon);
	if(P2BloodWeapon(Weapon) != None && (P2MocapPawn(Cutme) == None || P2MocapPawn(Cutme).MyRace < RACE_Automaton))
		P2BloodWeapon(Weapon).DrewBlood();
}

///////////////////////////////////////////////////////////////////////////////
// You cut off someone's head
///////////////////////////////////////////////////////////////////////////////
function CutOffHead(FPSPawn cutme)
{
	//log(Self$" cut off my head "$Weapon);
	if(P2BloodWeapon(Weapon) != None && (P2MocapPawn(Cutme) == None || P2MocapPawn(Cutme).MyRace < RACE_Automaton))
		P2BloodWeapon(Weapon).DrewBlood();
}

///////////////////////////////////////////////////////////////////////////////
// You crushed a person's or animals head with a sledge or scythe or machete
///////////////////////////////////////////////////////////////////////////////
function CrushedHead(FPSPawn cutme)
{
	//log(Self$" sledged my head "$Weapon);
	if(P2BloodWeapon(Weapon) != None && (P2MocapPawn(Cutme) == None || P2MocapPawn(Cutme).MyRace < RACE_Automaton))
		P2BloodWeapon(Weapon).DrewBlood();
}

///////////////////////////////////////////////////////////////////////////////
// Tell other people around you that you have a big weapon(or not). They might care
// Don't allow this in MP--have radar handle finding players
// Also tell zombies about you
///////////////////////////////////////////////////////////////////////////////
function ReportPlayerLooksToOthers(out array<P2Pawn> PawnsAroundMe, bool bRecordPawns,
									out byte InDoors)
{
	local P2Pawn CheckP;
	local PersonController Personc;
	local vector loc, AboveMe;

	//log(self@"AWPostalDude reporting player looks"@Health@Controller,'Debug');
	// Don't do it if you're dead or have no controller
	if(Health <= 0
		|| Controller == None)
		return;

	// Tell the pawns around me what i look like,
	// but tell them from the top of my head.
	loc = Location;
	loc.z += CollisionHeight;

	if(Level.Game != None
		&& FPSGameInfo(Level.Game).bIsSinglePlayer)
	{
		if(bRecordPawns)
		// If they are recorded, then they're stuffed into an array for the radar.
		// The radar uses this list to display the 'fish'.
		{
			if(PawnsAroundMe.Length > 0)
				PawnsAroundMe.Remove(0, PawnsAroundMe.Length);

			// Check a good ways above us, and see if we're "in doors".
			AboveMe = Location;
			AboveMe.z += NO_CEILING_CHECK;
			if(FastTrace(Location, AboveMe))
				InDoors=0;
			else
				InDoors=1;

			ForEach CollidingActors(class'P2Pawn', CheckP, ReportLooksRadius, loc)
			{
				// If not me
				if(CheckP != self
					// if still alive (and not dying)
					&& CheckP.Health > 0)
				{
					// Record them for the radar (players and NPCs)
					if(CheckP.Controller != None
						&& !CheckP.bNoRadar)
					{
						//log("logging pawn"@CheckP,'Debug');
						PawnsAroundMe.Insert(PawnsAroundMe.Length, 1.0);
						PawnsAroundMe[PawnsAroundMe.Length-1] = CheckP;
					}

					// Tell the SP NPC's about the player.
					Personc = PersonController(CheckP.Controller);
					if(Personc != None)
					{
						//log("reporting looks to"@PersonC,'Debug');
						Personc.CheckObservePawnLooks(self);
					}
				}
			}
		}
		else	// Not recording the pawns means you're just telling
			// the single player AI what you're doing. This is how it knows
			// how to react to you in various ways.
		{
			// Sure VisibleCollidingActors is faster, but it doesn't seem to work! People
			// behind crotch level obstructions don't get updates. Seems a lot like 'visible'
			// means not rendered and "can't trace from center to center". Bad, bad.. use CollidingActors from now on
			ForEach CollidingActors(class'P2Pawn', CheckP, ReportLooksRadius, loc)
			{
				// If not me
				if(CheckP != self
					// if still alive (and not dying)
					&& CheckP.Health > 0)
				{
					Personc = PersonController(CheckP.Controller);
					if(Personc != None)
					{
						//log("reporting looks to"@PersonC,'Debug');
						Personc.CheckObservePawnLooks(self);
					}
				}
			}
		}
	}
}

// Handled in AWPerson
/*
///////////////////////////////////////////////////////////////////////////////
// Link this pawn to the anims it needs
///////////////////////////////////////////////////////////////////////////////
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

	// Also put in more AW single player anims.
	LinkSkelAnim(AW_SPMeshAnim);
	}
*/

/** Overriden to support the proper base height when in Leprechaun mode */
event EndCrouch(float HeightAdjust) {
	if (!bUpdateEyeHeight)
		EyeHeight += HeightAdjust;

	OldZ += HeightAdjust;

	if (bLeprechaunMode) {
	    BaseEyeHeight = default.BaseEyeHeight * LeprechaunDrawScale;
	    SetCollisionSize(default.CollisionRadius * LeprechaunDrawScale,
                         default.CollisionHeight * LeprechaunDrawScale);
    }
    else
	    BaseEyeHeight = default.BaseEyeHeight;

	SetAnimEndCrouching();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated event PlayFalling()
	{
	if (IsInstate('Dying')) return;
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
// Turns the Dude into a Leprechaun by shortening him, adjusting his collision
// radius and height, adjusting his voice pitch, and adding a beard and hat
///////////////////////////////////////////////////////////////////////////////
function TurnIntoLeprechaun() {
    local BoltonPart Bolton;

    VoicePitch = LeprechaunVoicePitch;

    BaseEyeHeight *= LeprechaunDrawScale;
    CrouchHeight *= LeprechaunDrawScale;
    BaseMovementRate *= LeprechaunDrawScale;
    CrouchRadius *= LeprechaunDrawScale;
    CrouchHeight *= LeprechaunDrawScale;

    SetDrawScale(LeprechaunDrawScale);
    SetCollisionSize(default.CollisionRadius * LeprechaunDrawScale,
                     default.CollisionHeight * LeprechaunDrawScale);

    // Attach the Leprechaun Hat onto the Dude
    Bolton = Spawn(class'BoltonPart');
    if (Bolton != none) {
        Bolton.SetStaticMesh(LeprechaunHatBolton);
        Bolton.SetDrawType(DT_StaticMesh);
        Bolton.SetDrawScale(LeprechaunHatScale);
        Bolton.PrePivot = LeprechaunHatPivot;

        MyHead.AttachToBone(Bolton, 'NODE_Parent');
    }

    // Attach the Leprechaun Beard onto the Dude
    Bolton = Spawn(class'BoltonPart');
    if (Bolton != none) {
        Bolton.SetStaticMesh(LeprechaunBeardBolton);
        Bolton.SetDrawType(DT_StaticMesh);
        Bolton.SetDrawScale(LeprechaunBeardScale);
        Bolton.PrePivot = LeprechaunBeardPivot;

        MyHead.AttachToBone(Bolton, 'NODE_Parent');
    }
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
function BlastSpot(vector hitloc, class<Damagetype> dtype)
{
	local P2Emitter dblast;

	if(dblastclass != None
		// blocks these, just would bog down if it did an effect for every hit
		&& !ClassIsChildOf(dtype, class'AnthDamage')
		&& !ClassIsChildOf(dtype, class'BurnedDamage'))
	{
		// do blasty wave reflector shield thing where the spot was blocked
		if(ClassIsChildOf(dtype, class'ExplodedDamage')
			&& dblastexplclass != None)
			dblast = spawn(dblastexplclass, Owner, , hitloc);
		else
			dblast = spawn(dblastclass, Owner, , hitloc);
		dblast.PlaySound(BlastBlockSound, SLOT_Misc);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	// If we're a dude in a cinematic, bypass all damage until we regain control of our pawn.
	if ((P2Player(Controller) == None
		&& LambController(Controller) == None)
		|| Controller.IsInState('Scripting'))
		return;

	// This used to block all damage, but like God mode, this was boring.
	//if(GaryHeads > 0)
	// Have it block explosion damage now, to protect against our own gary heads
	if(GaryHeads > 0
		&& (ClassIsChildOf(damageType, class'BurnedDamage') || ClassIsChildOf(damageType, class'ExplodedDamage')))
	{
		// Blocks all damage sent to it
		BlastSpot(hitlocation, damageType);
	}
	else
		Super.TakeDamage(Damage, instigatedby, hitlocation, momentum, damagetype);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Died(Controller Killer, class<DamageType> DamageType,
              vector HitLocation) {
    if (bLeprechaunMode)
        SetDrawScale(default.DrawScale);

    super.Died(Killer, DamageType, HitLocation);
}

///////////////////////////////////////////////////////////////////////////////
// New footstep code
///////////////////////////////////////////////////////////////////////////////
function PlayFootstep(optional float Volume, optional float Radius, optional float Pitch)
{
	//log("Footstep"@LastFootstepTime@bPlayingFootstepSound);
	LastFootstepTime = 0;
	bPlayingFootstepSound=true;
	Super.PlayFootstep(Volume, Radius, Pitch);
}

///////////////////////////////////////////////////////////////////////////////
// Places a footprint in the snow, dirt, etc.
///////////////////////////////////////////////////////////////////////////////
function DrawFootprint(optional bool bJump)
{
	LastFootprintTime = 0;
	Super.DrawFootprint(bJump);
}

///////////////////////////////////////////////////////////////////////////////
//  Play sound
///////////////////////////////////////////////////////////////////////////////
simulated function FootstepTimer()
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
				//SetTimer(WALK_FOOTSTEP_TIME, false);
			}
			else
			{
				vol = RUN_VOL;
				// Updated, to account for joystick movement.
				//SetTimer(RUN_FOOTSTEP_TIME, false);
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
					//PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,vol,,userad,usepitch);
					PlayFootstep(vol, userad, usepitch);
				else
					//PlaySound(FootStepSounds[Rand(ArrayCount(MPFootStepSounds))],SLOT_Interact,vol,,userad,usepitch);
					PlayFootstep(vol, userad, usepitch);
			}
		}
		//else
			//SetTimer(WALK_FOOTSTEP_TIME, false);
	}
}

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
	// Check to change footstep speed
	///////////////////////////////////////////////////////////////////////////////
	/*
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
	*/
	
	///////////////////////////////////////////////////////////////////////////////
	// STUBBED dude handles footsteps through tick
	///////////////////////////////////////////////////////////////////////////////
	simulated function Timer();
	

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
			//PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,RUN_VOL,,userad);
			PlayFootstep(RUN_VOL, userad);
			DrawFootprint();
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
		if(Level.NetMode != NM_DedicatedServer)
		{
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				userad = FOOTSTEP_RADIUS;
			else
				userad = FOOTSTEP_RADIUS_LOCAL_MP;
			// Play footsteps/landed sound here
			//PlaySound(FootStepSounds[Rand(ArrayCount(FootStepSounds))],SLOT_Interact,1.0,,userad);
			PlayFootstep(LAND_VOL, userad);
			DrawFootprint(true);
			//SetTimer(RUN_FOOTSTEP_TIME, false);
		}
	}

	/*
	simulated function BeginState()
	{
		//log(self$" beginstate Living, role "$Role$" remote "$RemoteRole);
		SetTimer(RUN_FOOTSTEP_TIME, false);
	}
	*/
	
	simulated event Tick(float dT)
	{
		local float Speed;
		
		if (Controller == None) 
			return;
		
		Super.Tick(dT);
				
		Speed = VSize(Velocity);
		if (Speed > 0 && Controller.bRun == 0)
			// While moving, play footsteps based on movement speed
			FootstepTime = Default.GroundSpeed / Speed * RUN_FOOTSTEP_TIME;
		else if (Speed > 0)
			// When using walk button (keyboard only) we have to base our footstep timer on something else
			FootstepTime = Default.GroundSpeed * WalkingPct / Speed * WALK_FOOTSTEP_TIME;
		else if (LastFootstepTime > 0)
			// Play a step when we come to a stop
			FootstepTime = 0;
		else
		{
			// Play no steps while stopped
			LastFootstepTime = 0;
			LastFootprintTime = 0;
		}
		LastFootstepTime += dT;
		LastSurfaceTime += dT;
		LastFootprintTime += dT;
		if (Speed > 0 && LastSurfaceTime > UPDATE_SURFACE_TIME)
		{
			LastSurfaceTime = 0;
			UpdateSurfaceType();				
			SetGroundSpeedOn(SurfaceType);
		}
		if (FootstepTime != 0)
		{
			if (LastFootstepTime >= FootstepTime)
				FootstepTimer();
			if (LastFootprintTime >= FootstepTime / 2.0)
				DrawFootprint();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Allow running/walking backwards animations in SP for the Postal Dude
///////////////////////////////////////////////////////////////////////////////
simulated function bool AllowBackpeddle()
{
	return true;
}

//HeadMesh=Mesh'AW_Heads.Avg_Dude'

defaultproperties
{
	bLeprechaunMode=false
	LeprechaunDrawScale=0.5f
	LeprechaunVoicePitch=1.5f
	LeprechaunHatScale=1.0f
	LeprechaunBeardScale=0.75f
	LeprechaunHatPivot=(X=0.0f,Y=2.0f,Z=0.0f)
	LeprechaunBeardPivot=(X=0.0f,Y=0.0f,Z=0.0f)
	LeprechaunHatBolton=StaticMesh'StPatricksMesh.leprechaun_gary_hat'
	LeprechaunBeardBolton=StaticMesh'StPatricksMesh.Beard1'

    Grenade=StaticMesh'stuff.stuff1.Grenade'
	//FootStepSounds(0)=Sound'MoreMiscSounds.QuietFootsteps.footstep1q'
	//FootStepSounds(1)=Sound'MoreMiscSounds.QuietFootsteps.footstep2q'
	//FootStepSounds(2)=Sound'MoreMiscSounds.QuietFootsteps.footstep4q'
	//FootStepSounds(3)=Sound'MoreMiscSounds.QuietFootsteps.footstep5q'
	//FootStepSounds(4)=Sound'MoreMiscSounds.QuietFootsteps.footstep6q'
	//MPFootStepSounds(0)=Sound'MoreMiscSounds.loudfootsteps.footstep1h'
	//MPFootStepSounds(1)=Sound'MoreMiscSounds.loudfootsteps.footstep2h'
	//MPFootStepSounds(2)=Sound'MoreMiscSounds.loudfootsteps.footstep4h'
	//MPFootStepSounds(3)=Sound'MoreMiscSounds.loudfootsteps.footstep5h'
	//MPFootStepSounds(4)=Sound'MoreMiscSounds.loudfootsteps.footstep6h'
	CoreMPMeshAnim=MeshAnimation'MP_Characters.anim_MP'
	CoreSPMesh=SkeletalMesh'Characters.Avg_Dude'
	dblastclass=Class'AWEffects.DamageBlock'
	dblastexplclass=Class'AWEffects.DamageBlockExplosion'
	BlastBlockSound=Sound'WeaponSounds.bullet_ricochet1'
	bPants=True
	TakesSledgeDamage=0.010000
	TakesMacheteDamage=0.200000
	TakesScytheDamage=0.200000
	TakesDervishDamage=0.200000
	TakesZombieSmashDamage=0.900000
	HeadClass=Class'AWDudeHead'
	HeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
	HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	bRandomizeHeadScale=False
	bIsTrained=True
	bStartupRandomization=False
	TakesMachinegunDamage=0.750000
	ReportLooksRadius=2048.000000
	dialogclass=Class'BasePeople.DialogDude'
	HealthMax=300.000000
	DamageMult=2.400000
	bCanPickupInventory=True
	Mesh=SkeletalMesh'Characters.Avg_Dude'
	Skins(0)=Texture'ChameleonSkins.Special.Dude'
	TransientSoundRadius=1024.000000
	ADJUST_RELATIVE_HEAD_Y=-2

	RandomizedBoltons(0)=None
	bNoChamelBoltons=True
	CrouchHeight=+40.0
	ExtraAnims(2)=MeshAnimation'MP_Characters.Anim_MP'
	bMPAnims=true
}
