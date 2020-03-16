///////////////////////////////////////////////////////////////////////////
// UrineStreamMP
//
// Visual-only fluid effect (doesn't support collision or any interesting 
// physics)
//
// Checks the remote client owner pawns' bSteadyFiring variable to know if
// it should stay alive.
//
///////////////////////////////////////////////////////////////////////////
class UrineStreamMP extends P2Emitter;

var float InitialPourSpeed, InitialSpeedZPlus, SpeedVariance;
var int ReadyToDie;

const READY_TO_DIE_COUNT=8;

///////////////////////////////////////////////////////////////////////////
// Make the emitter shoot out of Rotation
///////////////////////////////////////////////////////////////////////////
function SetDir(vector newloc, vector dir, optional float velmag, optional bool bInitArc)
{
	local int i;
	//local vector dir;
	local float addzmag, usevelmag, zcheck;
	local vector ownervel;

	/*
	// find a factor of how inline with velocity motion, this direction is
	usevelmag = VSize(Owner.Velocity);
	if(usevelmag > 0)
		addzmag = ((VEL_Z_DOT_PLUS*(MyOwner.Velocity Dot dir))/usevelmag);
	else
		addzmag = 0;
		*/
	addzmag = InitialSpeedZPlus;
	//ownervel = -0.8*MyOwner.Velocity;

	// record velocity for collision particles
	//CollisionVelocity = InitialPourSpeed*dir - ownervel;
	//CollisionVelocity.z+= addzmag;

	// make it wobble a little
	//dir += VaryDir;

	for(i=0; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max = 	InitialPourSpeed*dir.x + -ownervel.x ;
			Emitters[i].StartVelocityRange.X.Min = 	Emitters[i].StartVelocityRange.X.Max;
			Emitters[i].StartVelocityRange.Y.Max = 	InitialPourSpeed*dir.y + -ownervel.y ;
			Emitters[i].StartVelocityRange.Y.Min = 	Emitters[i].StartVelocityRange.Y.Max;
			Emitters[i].StartVelocityRange.Z.Max = 	InitialPourSpeed*dir.z + -ownervel.z + addzmag;
			Emitters[i].StartVelocityRange.Z.Min = 	Emitters[i].StartVelocityRange.Z.Max;
		}
	}
	for(i=1; i<Emitters.length; i++)
	{
		if(Emitters[i] != None)
		{
			Emitters[i].StartVelocityRange.X.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.X.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Y.Min -= (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Max += (SpeedVariance);
			Emitters[i].StartVelocityRange.Z.Min -= (SpeedVariance);
		}
	}
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	local vector Dir;
	local Rotator Userot;
	local float OwnerPitch;

	if(Pawn(Owner) == None
		|| Pawn(Owner).bDeleteMe)
		Destroy();
	else
	{
		OwnerPitch = Pawn(Owner).ViewPitch * 256;     
		if (OwnerPitch > 32768) 
			OwnerPitch -= 65536;

		UseRot = Owner.Rotation;
		Userot.Pitch = OwnerPitch;
		Dir = vector(UseRot);

		SetDir(Location, Dir);

		if(!Pawn(Owner).bSteadyFiring)
		{
			ReadyToDie++;
			if(ReadyToDie >= READY_TO_DIE_COUNT)
				Destroy();
		}
		else
			ReadyToDie=0;
	}
}

defaultproperties
{
    Begin Object Class=StripEmitter Name=StripEmitter0
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-2000.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeInEndTime=0.300000
        FadeIn=True
	    FadeOut=True
        MaxParticles=17
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScaleRepeats=3.000000
        StartSizeRange=(X=(Min=0.500000,Max=2.500000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.pour1'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-1000.000000,Max=-1000.000000),Z=(Min=300.000000,Max=300.000000))
		//ZTest=false
		//ZWrite=true
        Name="StripEmitter0"
    End Object
    Emitters(0)=StripEmitter'StripEmitter0'
    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		SecondsBeforeInactive=0.0
        Acceleration=(Z=-1800.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=128,G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
        FadeOutStartTime=1.100000
        FadeOut=True
        MaxParticles=25
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.600000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.800000,Max=1.800000),Y=(Min=0.800000,Max=1.800000))
        InitialParticlesPerSecond=0.000000
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.drips1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=1.300000,Max=1.600000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=150.000000,Max=150.000000),Z=(Min=200.000000,Max=200.000000))
		//ZTest=false
		//ZWrite=true
        Name="SpriteEmitter1"
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'
    AutoDestroy=true
	RemoteRole=ROLE_SimulatedProxy

	InitialPourSpeed=600
	InitialSpeedZPlus=500
	SpeedVariance=15
}
