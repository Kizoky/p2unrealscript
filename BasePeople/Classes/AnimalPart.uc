///////////////////////////////////////////////////////////////////////////////
// AnimalPart
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Part of an animal
//
///////////////////////////////////////////////////////////////////////////////
class AnimalPart extends Limb
	placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var bool bIsDog;
var bool bIsCat;

var byte DogI, CatI;	// indices into Meshes array


///////////////////////////////////////////////////////////////////////////////
// Conversion functions to keep all the various classes and permutations down
// a little. This is only for single player. MP games will want each class
// created seperately.
///////////////////////////////////////////////////////////////////////////////
function ConvertToFrontHalf()
{
	if(bIsDog)
		SetStaticMesh(Meshes[DogI]);
	else
		SetStaticMesh(Meshes[CatI]);
}
function ConvertToBackHalf()
{
	if(bIsDog)
		SetStaticMesh(Meshes[DogI+1]);
	else
		SetStaticMesh(Meshes[CatI+1]);
}

///////////////////////////////////////////////////////////////////////////////
// Setup the animal part
///////////////////////////////////////////////////////////////////////////////
simulated function SetupAnimalPart(Material NewSkin, byte NewAmbientGlow, rotator LimbRot,
						optional bool bNewDog, optional bool bNewCat)
{
	// Ambient glow should match body
	AmbientGlow = NewAmbientGlow;

	// setup appropriate skin
	Skins[0]=NewSkin;

	// orient along original limb direction
	//log(self$" start rot "$Rotation$" limb rot "$LimbRot);
	SetRotation(LimbRot);

	bIsDog = bNewDog;
	bIsCat = bNewCat;
}

///////////////////////////////////////////////////////////////////////////////
// You tossed the limb around! If a dog is around, he'll come and want to play
// This will call the first dog it comes across, only one dog
// This *used* to check your animal friend
// first, but once I made it possible to train multiple ones, still attracting
// the closest dog first was best.
///////////////////////////////////////////////////////////////////////////////
function bool CallDog(P2Pawn Tosser)
{
	local AnimalPawn CheckP, UseP;
	local AnimalController cont;
	local byte StateChange;
	local P2Player p2p;
	local float dist, keepdist;
	local int i;

	dist = 65536;
	keepdist = dist;
	// Tell the closest dog around, about the fun limb to pick up
	ForEach CollidingActors(class'AnimalPawn', CheckP, DOG_RADIUS)
	{
		// If it's a dog and he's alive and he can see it,
		// then check for him to run over
		// and grab up the pickup and bring it back to you.
		if(CheckP.class == MyAnimalClass
			&& CheckP.Health > 0
			&& CheckP.Controller != None)
		{
			dist = VSize(CheckP.Location - Location);
			if(dist < keepdist)
				//&& FastTrace(CheckP.Location, Location))
			{
				keepdist = dist;
				UseP = CheckP;
			}
		}
	}

	if(UseP != None)
	{
		cont = AnimalController(UseP.Controller);
		cont.RespondToAnimalCaller(Tosser, self, StateChange);
		if(StateChange == 1)
			return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Do crazy effects
///////////////////////////////////////////////////////////////////////////////
function ExplodeLimb(vector HitLocation, vector Momentum)
{
	local CatExplosion exp;

	if(class'P2Player'.static.BloodMode())
	{
		// Should make this inside ChunkUp, but we needs special distance stuff
		// so we do it out here
		exp = spawn(class'CatExplosion',,,Location);
		if(exp != None)
			exp.PlaySound(ExplodeLimbSound,,,,,GetRandPitch());
	}
	else
		spawn(class'RocketSmokePuff',,,Location);	// gotta give the lame no-blood mode something!

	// Have the Limb wait just a moment
	GotoState('Exploding');
}

defaultproperties
{
     CatI=2
     ExplodeLimbSound=Sound'WeaponSounds.flesh_explode'
     LimbBounce(0)=Sound'AWSoundFX.Body.limbflop1'
     LimbBounce(1)=Sound'AWSoundFX.Body.limbflop2'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.Dog_frontchunk'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.Dog_rearchunk'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.Cat_frontchunk'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.Cat_rearchunk'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot'
     Meshes(6)=StaticMesh'awpeoplestatic.Limbs.L_arm_limb'
     Meshes(7)=StaticMesh'awpeoplestatic.Limbs.L_arm_forearm'
     Meshes(8)=StaticMesh'awpeoplestatic.Limbs.L_hand'
     Meshes(9)=StaticMesh'awpeoplestatic.Limbs.R_arm_limb'
     Meshes(10)=StaticMesh'awpeoplestatic.Limbs.R_arm_forearm'
     Meshes(11)=StaticMesh'awpeoplestatic.Limbs.R_hand'
     SleeveMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_limb_pants'
     SleeveMeshes(1)=StaticMesh'awpeoplestatic.Limbs.L_leg_foot_pants'
     SleeveMeshes(2)=StaticMesh'awpeoplestatic.Limbs.L_leg_calf_pants'
     SleeveMeshes(3)=StaticMesh'awpeoplestatic.Limbs.R_leg_limb_pants'
     SleeveMeshes(4)=StaticMesh'awpeoplestatic.Limbs.R_leg_foot_pants'
     SleeveMeshes(5)=StaticMesh'awpeoplestatic.Limbs.R_leg_calf_pants'
     bCanCutInHalf=False
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
}
