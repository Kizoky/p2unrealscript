///////////////////////////////////////////////////////////////////////////////
// TorsoGuts
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
// Guts coming out of the bottom of the severed torso top half
//
///////////////////////////////////////////////////////////////////////////////
class TorsoGuts extends Stump;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var float ScaleMax;	// As big as we want to get, scale
var float ScaleSpeed;
var float PosMax;	// Relative motion
var float PosSpeed;
var float SplitTime, TotalTime;

var StaticMesh FemMesh;

///////////////////////////////////////////////////////////////////////////////
// CONSTS
///////////////////////////////////////////////////////////////////////////////
const UPDATE_TIME   = 1.0;
const SCALE_INC	    = 0.1;
const WAIT_TIME		= 2.0;

const SCALE_MAX		= 0.7;
const SCALE_MAX_ADD	= 0.4;
const POS_MAX		= -8.0;
const POS_MAX_ADD	= -4.0;
const DAMPEN_SCALE  = 0.9;
const DAMPEN_MOVE	= 0.95;
const DAMPEN_TIME	= 0.5;
const MOVE_TIME_MAX	= 25.0;

///////////////////////////////////////////////////////////////////////////////
// You'll be made again after the load, so don't let yourself be loaded
///////////////////////////////////////////////////////////////////////////////
event PostLoadGame()
{
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	ScaleMax = SCALE_MAX + FRand()*SCALE_MAX_ADD;
	PosMax = POS_MAX + FRand()*POS_MAX_ADD;
}

///////////////////////////////////////////////////////////////////////////////
// After a load, you should already be sticking out
///////////////////////////////////////////////////////////////////////////////
function SetToFullSize()
{
	local vector usev;

	// Handle scale
	usev = DrawScale3D;
	usev.X = ScaleMax;
	SetDrawScale3D(usev);
	// Handle offset
	usev = RelativeLocation;
	usev.X = PosMax;
	SetRelativeLocation(usev);
	GotoState('');
}

///////////////////////////////////////////////////////////////////////////////
// Setup the stump
///////////////////////////////////////////////////////////////////////////////
simulated function SetupStump(Material NewSkin, byte NewAmbientGlow,
							 bool bNewFat, bool bNewFemale, bool bNewPants,
							 bool bNewSkirt)
{
	Super.SetupStump(NewSkin, NewAmbientGlow, bNewFat, bNewFemale, bNewPants,
					bNewSkirt);
	if(bNewFemale)
		SetStaticMesh(FemMesh);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait a bit before sliding out
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Waiting
{
Begin:
	Sleep(WAIT_TIME + FRand()*WAIT_TIME);
	GotoState('Moving');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Moving down and around
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Moving
{
	function Tick(float DeltaTime)
	{
		local vector newv;
		local bool bDone;

		bDone=true;
		SplitTime+=DeltaTime;
		TotalTime+=DeltaTime;
		//log(self$" moving down "$RelativeLocation$" speed "$PosSpeed$" posmax "$PosMax);
		//log(self$"    scale "$DrawScale3D$" ScaleSpeed "$ScaleSpeed$" smax "$ScaleMax);
		if(DrawScale3D.X < ScaleMax)
		{
			newv = DrawScale3D;
			newv.x+=(ScaleSpeed*DeltaTime);
			SetDrawScale3D(newv);
			bDone=false;
		}
		if(RelativeLocation.X > PosMax)
		{
			newv = RelativeLocation;
			newv.x+=(PosSpeed*DeltaTime);
			SetRelativeLocation(newv);
			bDone=false;
		}
		if(SplitTime > DAMPEN_TIME)
		{
			ScaleSpeed*=DAMPEN_SCALE;
			PosSpeed*=DAMPEN_MOVE;
			SplitTime -= DAMPEN_TIME;
		}

		if(bDone
			|| TotalTime > MOVE_TIME_MAX) // Done moving down
			GotoState('');
	}
}

defaultproperties
{
     ScaleSpeed=0.400000
     PosSpeed=-1.000000
     FemMesh=StaticMesh'awpeoplestatic.Limbs.Guts_Fem'
     Meshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump'
     Meshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump'
     Meshes(2)=StaticMesh'awpeoplestatic.Limbs.L_arm_stump'
     Meshes(3)=StaticMesh'awpeoplestatic.Limbs.R_arm_stump'
     Meshes(4)=StaticMesh'awpeoplestatic.Limbs.male_upper_torso'
     Meshes(5)=StaticMesh'awpeoplestatic.Limbs.male_lower_torso'
     FemaleMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_Fem'
     FemaleMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_Fem'
     FemaleMeshes(4)=StaticMesh'awpeoplestatic.Limbs.fem_upper_torso'
     FemaleMeshes(5)=StaticMesh'awpeoplestatic.Limbs.fem_lower_torso'
     SkirtMeshes(0)=StaticMesh'awpeoplestatic.Limbs.L_leg_stump_skirt'
     SkirtMeshes(1)=StaticMesh'awpeoplestatic.Limbs.R_leg_stump_skirt'
     RelativeRotation=(Pitch=0)
     StaticMesh=StaticMesh'awpeoplestatic.Limbs.Guts'
     DrawScale3D=(X=0.100000)
     Skins(0)=Texture'ChameleonSkins.Special.RWS_Shorts'
}
