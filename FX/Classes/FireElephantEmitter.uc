//=============================================================================
// FireElephantEmitter.
//=============================================================================
class FireElephantEmitter extends FireTorsoEmitter;

const BONE_MIDDLE						= 'Bip01 Spine1';


///////////////////////////////////////////////////////////////////////////////
// setup my pawn and start one for the head too
///////////////////////////////////////////////////////////////////////////////
function SetPawns(FPSPawn newpawn, FPSPawn doerpawn)
{
	local FireElephantHeadEmitter fehe;

	Super.SetPawns(newpawn, doerpawn);

	// Also make fire for the giant head.
	fehe= Spawn(class'FireElephantHeadEmitter',,,newpawn.Location);
	fehe.SetFireType(bIsNapalm);
	fehe.SetPawns(newpawn, doerpawn);
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

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	
	// Invoke non-scaling version of HurtRadius
	HurtRadiusEX(Damage*DeltaTime, CollisionRadius, MyDamageType, 0, Location, true);
	
	/*
	foreach VisibleCollidingActors( class 'Actor', Victims, CollisionRadius, Location )
	{
		if( (Victims != self) 
			&& Victims != MyPawn
			&& (Victims.Role == ROLE_Authority) )
		{
			dir = Normal(Victims.Location - Location);
			//damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				Damage*DeltaTime,
				Instigator, 
				Victims.Location - Victims.CollisionRadius*dir,
				vect(0,0,0),
				MyDamageType
			);
		} 
	}
	*/
	
	bHurtEntry = false;
}

///////////////////////////////////////////////////////////////////////////////
// update location
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	local int UseDamage;
	SetLocation(MyPawn.Location + MyPawn.Velocity/12);

	Super.Tick(DeltaTime);

	// slowly hurt the guy you're burning
	PawnDamagePortion += DeltaTime*Damage;
	UseDamage = PawnDamagePortion;
	if(UseDamage > 0)
	{
		// Hurt him by that much
		MyPawn.TakeDamage
		(
			UseDamage,
			Instigator, 
			Location,
			vect(0, 0, 0),
			class'OnFireDamage'
		);
		// remove what we've used, but keep the rest for next tick
		PawnDamagePortion -= UseDamage;
	}

	//log(MyPawn$" my health "$MyPawn.health$" our damage  "$usedamage$" with extra "$pawndamageportion);

	// go out when he's dead
	if(MyPawn.Health <= 0)
		GotoState('Fading');

	//log("my owner "$Owner);
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
		MyPawn.AttachToBone(self, BONE_MIDDLE);
		//log("now fading");
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
}

defaultproperties
{
	 Damage=10
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=70
         SpinParticles=True
         StartLocationRange=(X=(Min=-125.000000,Max=125.000000),Y=(Min=-125.000000,Max=125.000000),Z=(Min=-125.000000,Max=125.000000))
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
         LifetimeRange=(Min=0.700000,Max=0.900000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=270.000000,Max=380.000000))
         Name="SuperSpriteEmitter6"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter6'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        MaxParticles=30
        StartLocationRange=(X=(Min=-125.000000,Max=125.000000),Y=(Min=-125.000000,Max=125.000000),Z=(Max=150.000000))
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
        LifetimeRange=(Min=2.500000,Max=3.500000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter13'
     LifeSpan=30.000000
     bDynamicLight=True
     Physics=PHYS_Trailer
	 AutoDestroy=true
	 CollisionRadius=160
	 CollisionHeight=200
	 WaitAfterFadeTime=3.0
}
