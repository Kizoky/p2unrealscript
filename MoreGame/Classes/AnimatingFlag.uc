///////////////////////////////////////////////////////////////////////////////
// AnimatingFlag.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// A flag using vertex animations that can be set to slowly rotate as if
// responding to changes in the wind direction.  But not really.
//
///////////////////////////////////////////////////////////////////////////////
class AnimatingFlag extends Prop;

// Vertex animation isn't supported by the editor so we do this the old-fashioned way
#exec MESH IMPORT MESH=FlagAnim ANIVFILE=Models\FlagAnim_a.3d DATAFILE=Models\FlagAnim_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=FlagAnim X=-1050 Y=0 Z=0
#exec MESH SEQUENCE MESH=FlagAnim SEQ=All      STARTFRAME=0 NUMFRAMES=41
#exec MESH SEQUENCE MESH=FlagAnim SEQ=FlagAnim STARTFRAME=0 NUMFRAMES=41
#exec TEXTURE IMPORT NAME=FlagAnimTex FILE=Textures\FlagAnim1.PCX GROUP=Skins FLAGS=2 // TWOSIDED
#exec MESHMAP NEW   MESHMAP=FlagAnim MESH=FlagAnim
#exec MESHMAP SCALE MESHMAP=FlagAnim X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=FlagAnim NUM=1 TEXTURE=FlagAnimTex


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() float				CycleTime;
var() float				PlusMinusDegrees;

var() array<float>		AnimRates;
var int					RateNum;

var float				LastTime;
var float				ElapsedTime;
var rotator				OriginalRot;


///////////////////////////////////////////////////////////////////////////////
// Setup
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();
	PlayAnim('All', AnimRates[RateNum]);

	OriginalRot = Rotation;
	ElapsedTime = 0.0;
	LastTime = Level.TimeSeconds;
	SetTimer(0.2, true);
	}

///////////////////////////////////////////////////////////////////////////////
// Cycle the animation, playing at different rates each time if desired
///////////////////////////////////////////////////////////////////////////////
event AnimEnd(int Channel)
	{
	RateNum++;
	if (RateNum == AnimRates.length)
		RateNum = 0;

	PlayAnim('All', AnimRates[RateNum]);
	}

///////////////////////////////////////////////////////////////////////////////
// Flag slowly rotates back and forth from it's starting rotation
///////////////////////////////////////////////////////////////////////////////
event Timer()
	{
	local float CurrentTime;
	local float Percent;
	local float Degrees;
	local rotator NewRot;

	CurrentTime = Level.TimeSeconds;
	ElapsedTime += CurrentTime - LastTime;
	if (ElapsedTime >= CycleTime)
		ElapsedTime -= CycleTime;
	LastTime = CurrentTime;

	Percent = FClamp(ElapsedTime / CycleTime, 0.0, 1.0);
	Degrees = sin(Percent * 6.283185) * PlusMinusDegrees;

	NewRot = OriginalRot;
	NewRot.Yaw += int((Degrees / 360.0) * 65536.0);
	SetRotation(NewRot);
	}

///////////////////////////////////////////////////////////////////////////////
// defaultproperties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
    DrawType=DT_Mesh
    Mesh=FlagAnim

	CycleTime = 20.0;
	PlusMinusDegrees = 30;

	AnimRates(0)=1.0
	AnimRates(1)=0.9
	AnimRates(2)=0.8
	AnimRates(3)=0.7
	AnimRates(4)=0.8
	AnimRates(5)=0.9
	}
