//=============================================================================
// FireHeadEmitter.
//=============================================================================
class FireHeadEmitter extends FireEmitter;

var PeoplePart MyHead;

var bool bIsNapalm;				// Whether this is napalm fire or not
var float NapalmSpeedRatio;		// how much faster this fire moves
var Texture NapalmTexture;		// what image to use

///////////////////////////////////////////////////////////////////////////////
// Be sure to free us from our owner
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(MyHead != None)
		MyHead.MyPartFire=None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Assign us the pawn we're burning
///////////////////////////////////////////////////////////////////////////////
function SetOwners(PeoplePart NewHead, FPSPawn Doer)
{
	MyHead = NewHead;
	MyHead.MyPartFire=self;
	Instigator = Doer;
}

///////////////////////////////////////////////////////////////////////////////
// Turn into napalm fire or not
///////////////////////////////////////////////////////////////////////////////
function SetFireType(bool bNapalm)
{
	local int i, count;

	bIsNapalm = bNapalm;

	if(Emitters.Length > 0)
	{
		// Decrease fire detail 
		count = Emitters[0].MaxParticles;
		count = P2GameInfo(Level.Game).ModifyByFireDetail(count);
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(count);
		// Decrease smoke detail 
		count = Emitters[1].MaxParticles;
		count = P2GameInfo(Level.Game).ModifyBySmokeDetail(count);
		if(count != 0)
			SuperSpriteEmitter(Emitters[1]).SetMaxParticles(count);
		else
			Emitters[1].Disabled=true;
	}

	// changes texture, speeds it up some
	if(bIsNapalm)
	{
		// modify fire look
		if(Emitters.Length > 0)
		{
			// increase speed
			Emitters[0].StartVelocityRange.X.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.X.Min *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Y.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Y.Min *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Z.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Z.Min *= NapalmSpeedRatio;
			// change texture
			Emitters[0].Texture=NapalmTexture;
		}
		// change the type of damage we deal
		MyDamageType = class'NapalmDamage';
	}


}

///////////////////////////////////////////////////////////////////////////////
// Try to hurt actors around you, but don't hurt yourself, because
// we'll hurt you slowly as we want.
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	local actor Victims;
	local float dist;
	local vector dir;
	local float usedamage;

	usedamage = Damage*DeltaTime;
	if(usedamage <= 1)
		usedamage = 1;

	// Invoke non-scaling version of HurtRadius
	HurtRadiusEX(UseDamage, CollisionRadius, MyDamageType, 0, Location, true);
	
	/*
	foreach CollidingActors( class 'Actor', Victims, CollisionRadius, Location )
	{
		if( (Victims != self) 
			&& Victims != MyHead
			&& (Victims.Role == ROLE_Authority) )
		{
			dir = Normal(Victims.Location - Location);
			//damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				usedamage,
				Instigator, 
				Victims.Location - Victims.CollisionRadius*dir,
				vect(0,0,0),
				MyDamageType
			);
		} 
	}
	*/
}

///////////////////////////////////////////////////////////////////////////////
// update location
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	local int UseDamage;

	if(MyHead == None || MyHead.bDeleteMe)
	{
		MyHead = None;
		GotoState('WaitAfterFade');
		return;
	}

	SetLocation(MyHead.Location + MyHead.Velocity/12);

	Super.Tick(DeltaTime);
}

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
		// Check with pawn and see if we killed him or not
		// if not, then he'll just keep living and doing whatever.

		SetBase(MyHead);//AttachToBone(self, BONE_MIDDLE);
		LifeSpan = FadeTime + WaitAfterFadeTime;
		SetTimer(FadeTime, false);
		SizeChange=-Emitters[0].StartSizeRange.X.Min/(2*FadeTime);
		VelZChange=-Emitters[0].StartVelocityRange.Z.Min/(FadeTime);
		EmissionChange = -(Emitters[0].ParticlesPerSecond)/(2*FadeTime);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Wait after the fade
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state WaitAfterFade
{
	ignores Tick;
	
	// Don't hurt stuff here, in this state
	function BeginState()
	{
		local int i;

		for(i=0;i<Emitters.Length; i++)
		{
			Emitters[i].RespawnDeadParticles = false;
			SuperSpriteEmitter(Emitters[i]).AllowParticleSpawn=false;
		}
	}
Begin:
	MyHead.MyPartFire=None;
}

defaultproperties
{
	 Damage=10
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=15
         SpinParticles=True
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=30.000000))
         ParticlesPerSecond=15.000000
         InitialParticlesPerSecond=15.000000
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
        MaxParticles=10
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=100.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=35.000000,Max=60.000000))
        ParticlesPerSecond=2.000000
        InitialParticlesPerSecond=2.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter13'
     LifeSpan=15.000000
     bDynamicLight=True
     Physics=PHYS_Trailer
	 AutoDestroy=true
	 CollisionRadius=100;
	 CollisionHeight=100;
	 FadeTime=5.0
	 WaitAfterFadeTime=3.0
}
