//=============================================================================
// FireElephantHeadEmitter.
//=============================================================================
class FireElephantHeadEmitter extends FireTorsoEmitter;

const BONE_MIDDLE						= 'Bip01 Head';


///////////////////////////////////////////////////////////////////////////////
// setup my pawn and link my bone
///////////////////////////////////////////////////////////////////////////////
function SetPawns(FPSPawn newpawn, FPSPawn doerpawn)
{
	Super.SetPawns(newpawn, doerpawn);

	MyPawn.AttachToBone(self, BONE_MIDDLE);
}

///////////////////////////////////////////////////////////////////////////////
// doesn't hurt things, only the head part
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// update location
// doesn't really hurt things
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	// go out when he's dead
	if(MyPawn.Health <= 0)
		GotoState('Fading');
}

/*

///////////////////////////////////////////////////////////////////////////////
// Try to hurt actors around you
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	if(Damage != 0)
	{
		//log("deal damage "$self);
		//log("CollisionLoc "$CollisionLocation);
		//log("Location "$Location);
		// 0 here for momentumtransfer (second from end)
		// And project the hurting radius off the ground(the hitnormal) by the radius.
		HurtRadius(DeltaTime*Damage, CollisionRadius, MyDamageType, 0, Location );
	}
}
*/

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Fading
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Fading
{
	simulated function Timer()
	{
		GotoState('WaitAfterFade');
	}
	function Tick(float DeltaTime)
	{
		Emitters[0].StartSizeRange.X.Max+=(2*SizeChange*DeltaTime);
		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Max+=(VelZChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Min+=(VelZChange*DeltaTime);
		Emitters[0].InitialParticlesPerSecond+=EmissionChange*DeltaTime;
		Emitters[0].ParticlesPerSecond+=EmissionChange*DeltaTime;

		// Don't hurt stuff here, in this state
	}
	
	function BeginState()
	{
		//MyPawn.AttachToBone(self, BONE_MIDDLE);
		//log("now fading");
		LifeSpan = FadeTime + WaitAfterFadeTime;
		SetTimer(FadeTime, false);
		SizeChange=-Emitters[0].StartSizeRange.X.Min/(2*FadeTime);
		VelZChange=-Emitters[0].StartVelocityRange.Z.Min/(FadeTime);
		EmissionChange = -(Emitters[0].ParticlesPerSecond)/(2*FadeTime);
	}
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=30
         SpinParticles=True
         StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-50.000000,Max=125.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=45.000000,Max=65.000000))
         ParticlesPerSecond=30.000000
         InitialParticlesPerSecond=30.000000
         AutomaticInitialSpawning=False
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=270.000000,Max=380.000000))
         Name="SuperSpriteEmitter6"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter6'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        MaxParticles=25
        StartLocationRange=(X=(Min=-125.000000,Max=125.000000),Y=(Min=-125.000000,Max=125.000000),Z=(Min=50.000000,Max=150.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=75.000000,Max=125.000000))
        ParticlesPerSecond=3.000000
        InitialParticlesPerSecond=3.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter13'
     LifeSpan=30.000000
     bDynamicLight=True
     Physics=PHYS_Trailer
	 AutoDestroy=true
	 CollisionRadius=100;
	 CollisionHeight=100;
}
