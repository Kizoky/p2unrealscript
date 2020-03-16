//=============================================================================
// FireTorsoEmitter.
//=============================================================================
class FireTorsoEmitter extends FireEmitter;

var FPSPawn MyPawn;

var float PawnDamagePortion;	// because the retarded pawn only has an int for health,
								// we have to keep track of the health and slowly give
								// it to take damage as pass 1.0 otherwise the int
								// cast will round off our nicely calculated damage

var bool bIsNapalm;				// Whether this is napalm fire or not
var float NapalmSpeedRatio;		// how much faster this fire moves
var Texture NapalmTexture;		// what image to use
var bool bAlreadyDead;			// Set when you start up

const PLAY_DAMAGE_RATIO		= 2.5;	// Speed with which pawn is damaged and inverse time emitter lasts
const ALREADY_DEAD_RATIO	= 3.0;	// Make dead bodies go out quicker

const BONE_MIDDLE			= 'MALE01 Pelvis';


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(MyPawn != None)
		MyPawn.UnhookPawnFromFire();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// KEEp the owner.. unlike super fireemitter, don't blank out the owner,
// or the fire won't keep up with you when you move. And it's good that
// the burning sound is in your ears because.. it is! That is, if you have
// this happening to you, you're actually on fire, and you should 
// hear the burning in your ears.
///////////////////////////////////////////////////////////////////////////////
simulated function PostNetBeginPlay()
{
	Super(Wemitter).PostNetBeginPlay();
}

///////////////////////////////////////////////////////////////////////////////
// Assign us the pawn we're burning
///////////////////////////////////////////////////////////////////////////////
function SetPawns(FPSPawn CheckP, FPSPawn Doer)
{
	MyPawn = CheckP;
	MyPawn.MyBodyFire=self;

	if(MyPawn.Health <= 0)
	{
		bAlreadyDead=true;
		SetupLifetime(default.Lifespan/ALREADY_DEAD_RATIO);
	}
	else	// If it's the player, hurt, him twice as much, but go away
			// twice as fast
	{
		if(P2Pawn(MyPawn) != None
			&& P2Pawn(MyPawn).bPlayer)
		{
			SetupLifetime(default.Lifespan/PLAY_DAMAGE_RATIO);
			Damage = PLAY_DAMAGE_RATIO*default.Damage;
			// Make it go out very quickly if touched by anything
			Health=10;
		}
		// Takes full damage and will die from this
		else if(P2Pawn(MyPawn) == None
			|| P2Pawn(MyPawn).TakesOnFireDamage == 1.0)
		{
			Damage = MyPawn.Health/default.Lifespan;
		}

		//log(self$" damage per second "$Damage$" lifespan "$Lifespan);
	}

	Instigator = Doer;

	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
		SetOwner(None);
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
	local Pawn useinst;
	local float dist;
	local vector dir;
	local float usedamage;

	usedamage = Damage*DeltaTime;
	if(usedamage <= 1)
		usedamage = 1;
	
	// Invoke non-scaling version of HurtRadius
	//!! FIXME if we ever go back to multiplayer in this build!!!
	HurtRadiusEX(UseDamage, CollisionRadius, MyDamageType, 0, Location, true);

	/*
	foreach CollidingActors( class 'Actor', Victims, CollisionRadius, Location )
	{
		if( (Victims != self) 
			&& Victims != MyPawn
			&& (Victims.Role == ROLE_Authority) )
		{
			dir = Normal(Victims.Location - Location);
			// In single player the player always wants to preserve himself as starting all the fires
			// so he gets more kills. In MP, each person who starts someone else on fire wants the kill.
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				useinst = Instigator; // backwards from the Takedamage tick check is intentional!
			else
				useinst = MyPawn; // backwards is intentional!
				
			Victims.TakeDamage
			(
				usedamage,
				useinst, 
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
simulated function Tick(float DeltaTime)
{
	local int UseDamage;
	local Pawn useinst;

	if(Role == ROLE_Authority)
	{
		if(MyPawn == None)
		{
			GotoState('WaitAfterFade');
			ClientGotoState('WaitAfterFade');
			return;
		}

		SetLocation(MyPawn.Location + MyPawn.Velocity/12);

		Super.Tick(DeltaTime);

		// Slowly hurt the guy you're burning
		PawnDamagePortion += DeltaTime*Damage;
		// Make sure this will not be rounded down to zero by his resistance...
		if(P2Pawn(MyPawn) != None)
		{
			if(int(int(PawnDamagePortion)*P2Pawn(MyPawn).TakesOnFireDamage) > 0)
				UseDamage = PawnDamagePortion;
		}
		else
			UseDamage = PawnDamagePortion;

		if(UseDamage > 0)
		{
			// MP games, make sure to preserve who set us on fire as hurting us,
			// in SP games, make sure that we are the one's that killed us.
			// Hurt him by that much
			
			// No don't do that, set the instigator as the one who set us on fire
			// that way the dude gets credit for the kill properly
			// This will preserve "pacifist" runs too, if the Dude wasn't the one
			// who started the original fire then he won't be Instigator here,
			// the one who attacked with fire first will be -- they will be set as
			// instigator for the original fire attack, which then gets "passed on"
			// as the bystanders run around and light each other on fire.
			
			//if(Level.Game != None
			//	&& Level.Game.bIsSinglePlayer)
			//	useinst = MyPawn;
			//else
				useinst = Instigator;
			MyPawn.TakeDamage
			(
				UseDamage,
				useinst, 
				Location,
				vect(0, 0, 0),
				class'OnFireDamage'
			);
			// remove what we've used, but keep the rest for next tick
			PawnDamagePortion -= UseDamage;
		}

		// Go out when he's dead, if he started alive, otherwise, burn nice
		// and long
		if(MyPawn.Health <= 0
			&& !bAlreadyDead)
		{
			GotoState('Fading');
			// Tell all clients so visually all emitters will be in synch
			spawn(class'FireEmitterTalk', self);
		}
	}
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
simulated state Fading
{
	simulated function Timer()
	{
		GotoState('WaitAfterFade');
		ClientGotoState('WaitAfterFade');
	}
	simulated function Tick(float DeltaTime)
	{
		Emitters[0].StartSizeRange.X.Max+=(2*SizeChange*DeltaTime);
		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Max+=(VelZChange*DeltaTime);
		Emitters[0].StartVelocityRange.Z.Min+=(VelZChange*DeltaTime);
		Emitters[0].InitialParticlesPerSecond+=EmissionChange*DeltaTime;
		Emitters[0].ParticlesPerSecond+=EmissionChange*DeltaTime;

		// Still hurt things here if not the player
		if(P2Pawn(MyPawn) != None
			&& !P2Pawn(MyPawn).bPlayer)
			Global.Tick(DeltaTime);
	}
	
	simulated function BeginState()
	{
		// Check with pawn and see if we killed him or not
		// if not, then he'll just keep living and doing whatever.
		if(MyPawn != None)
			MyPawn.AttachToBone(self, BONE_MIDDLE);
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
simulated state WaitAfterFade
{
	// Don't hurt stuff here, in this state
	simulated function BeginState()
	{
		local int i;

		for(i=0;i<Emitters.Length; i++)
		{
			Emitters[i].RespawnDeadParticles = false;
			SuperSpriteEmitter(Emitters[i]).AllowParticleSpawn=false;
		}

		if(P2Pawn(MyPawn) != None)
		{
			P2Pawn(MyPawn).StopAllDripping();
		}
		if(MyPawn != None)
			MyPawn.bExtraFlammable=false;
	}
}

defaultproperties
{
	 Damage=3
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=40
         SpinParticles=True
         StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-80.000000,Max=70.000000))
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=35.000000,Max=55.000000))
         ParticlesPerSecond=35.000000
         InitialParticlesPerSecond=35.000000
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
        MaxParticles=20
        StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-20.000000,Max=150.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=50.000000,Max=100.000000))
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
	 AutoDestroy=true
     LifeSpan=30.000000
     Physics=PHYS_Trailer
	 CollisionRadius=150;
	 CollisionHeight=150;
	 NapalmSpeedRatio=1.4
	 NapalmTexture=Texture'nathans.Skins.firenapalm'
	 FadeTime=2.0
	 WaitAfterFadeTime=3.0
	 Health=25
	 RemoteRole=ROLE_SimulatedProxy
	 bReplicateMovement=true
}
