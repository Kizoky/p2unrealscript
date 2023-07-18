//=============================================================================
// FireMatch.
//=============================================================================
class FireMatch extends FireEmitter;

var vector Acc;
var float UseColRad;
var bool bFluidBeenHurt;
var bool bPawnBeenHurt;
var bool bHitSomething;
var float StartLightRadius, StartLightBrightness;

const DAMPEN_MULT	=	0.15;
const MIN_BOUNCE_SPEED	=	60;
const SLOPE_CHECK	=	0.7;
const MATCH_LAUNCH_VEL_MAG	=	800;


///////////////////////////////////////////////////////////////////////////////
// If we already have our velocity set, don't set it (like if we bounced
// off a window right off the bat, that would have set it, so don't set it here)
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();
	if(VSize(Velocity) == 0)
		Velocity = MATCH_LAUNCH_VEL_MAG*vector(Rotation);
}

///////////////////////////////////////////////////////////////////////////////
// hurt things in your tick
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	DealDamage(DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Fall to the ground, and hurt things along the way
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Expanding
{
	ignores BeginState;

	///////////////////////////////////////////////////////////////////////////////
	// Only fall
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		// make it fall
		Velocity += Acc*DeltaTime;
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Sit and hurt things 
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Burning
{
	///////////////////////////////////////////////////////////////////////////////
	// Do full damage
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		// make it fall
		if(Physics != PHYS_None)
			Velocity += Acc*DeltaTime;
		
		DealDamage(DeltaTime);
	}
	///////////////////////////////////////////////////////////////////////////////
	// set up times
	///////////////////////////////////////////////////////////////////////////////
	function BeginState()
	{
		LifeSpan=OrigLifeSpan + (FadeTime+WaitAfterFadeTime);

		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Don't hurt things, and fade away
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Fading
{
	simulated function Timer()
	{
		// make a nice little wisp of smoke roll up from the match
		// extinguishing.
		spawn(class'SmokeFireMatch');

	}
	function Tick(float DeltaTime)
	{
		Emitters[0].StartSizeRange.X.Max+=(SizeChange*DeltaTime);
		Emitters[0].StartSizeRange.X.Min+=(SizeChange*DeltaTime);
		LightRadius+=(StartLightRadius*DeltaTime);					// xPatch
		LightBrightness+=(StartLightBrightness*DeltaTime);			// xPatch
		// Don't hurt stuff here, in this state
	}
	
	function BeginState()
	{
		SetTimer(FadeTime, false);
		SizeChange=-Emitters[0].StartSizeRange.X.Min/(FadeTime+1);
		StartLightRadius=-default.LightRadius/(FadeTime+1);			// xPatch
		StartLightBrightness=-default.LightBrightness/(FadeTime+1);	// xPatch
	}
}

///////////////////////////////////////////////////////////////////////////////
// Basically just hurt fluids here
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
	local Fluid Victims, KeepFluid;
	local GasTrail gtrail;
	local vector dir;
	local float currdist, keepdist;
	local bool DoCollide;

	// If we've finished bouncing then we're probably not going to hurt anything,
	// so turn this portion off (people running across matches will still work because 
	// that's handled by a touch.
	//if(!bBounce)
	//	return;
	// Taht doesn't work for matches on the ground that you then pour fire on...
	// figure something else out.

	// Only allow one fluid to be hurt by this match (to speed up things)
	if( bFluidBeenHurt )
		return;

	if(Damage != 0)
	{
		if( bHurtEntry )
			return;

		bHurtEntry = true;
		keepdist = 65536;

		foreach RadiusActors( class 'Fluid', Victims, CollisionRadius, Location)
		{
			//log("victims "$Victims);
			gtrail = GasTrail(Victims);
			DoCollide=false;
			if(gtrail != None)
			{
				DoCollide = ThickLineCylinderCollide(gtrail.Location, 
								SuperSpriteEmitter(gtrail.Emitters[0]).LineEnd, 
								gtrail.UseColRadius,
								gtrail.UseColRadius,
								Location,
								UseColRad,
								UseColRad);
			}
			else
				DoCollide=true;

			if(DoCollide)
			{
				// Check distance too fluid and compare to current one
				currdist = VSize(Victims.Location - Location);
				if(currdist < keepdist)
				{
					keepdist = currdist;
					KeepFluid = Victims;
				}
			}
		}

		// Here we take *one* fluid and allow the match to try to hit it. That's all.
		if(KeepFluid != None
			&& KeepFluid.CheckSmallFireHit(DeltaTime*Damage,
						UseColRad,
						Location))// - 0.5 * (fp.CollisionHeight + fp.CollisionRadius) * dir);
		{
			bFluidBeenHurt=true;
		}

		bHurtEntry=false;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Has hit a surface, so update
///////////////////////////////////////////////////////////////////////////////
function SurfaceHit(optional vector HitNormal)
{
	local float speed;

	speed = VSize(Velocity);

	bHitSomething=true;

	if ( (speed < MIN_BOUNCE_SPEED) && 
		(HitNormal.Z > SLOPE_CHECK) )
	{
		SetPhysics(PHYS_none);
		bBounce = false;
	}

	CollisionLocation = Location;

	if(IsInState('Expanding'))
		GotoState('Burning');
}

///////////////////////////////////////////////////////////////////////////////
// you've mave contact with a surface
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	local FPSPawn thepawn;

	thepawn = FPSPawn(Other);

	if(Other != Owner
		&& thepawn != None)
	{
		// cheap reflect velocity, dampen x, y
		Velocity.x = -DAMPEN_MULT*Velocity.x;
		Velocity.y = -DAMPEN_MULT*Velocity.y;

		SurfaceHit();

		// Catch the person on fire if they're soaked in gasoline
		if(thepawn.bExtraFlammable
			|| thepawn.Controller.IsInState('Farting'))
		{
			if(LambController(thepawn.Controller) != None)
				LambController(thepawn.Controller).CatchOnFire(FPSPawn(Instigator));
			else
				thepawn.SetOnFire(FPSPawn(Instigator));
		}
		else // otherwise they'll probably just get annoyed that you flicked a match at them
		{
			if(LambController(thepawn.Controller) != None)
				LambController(thepawn.Controller).InterestIsAnnoyingUs(Owner, false);
		}
	}
	else if(PeoplePart(Other) != None)
	{
		PeoplePart(Other).HitByMatch(FPSPawn(Owner));
	}
	// xPatch
	else if(P2Projectile(Other) != None)
	{
		P2Projectile(Other).HitByMatch();
	}
	// End
	else if(Prop(Other) != None)
	{
		if(VSize(Velocity) == 0
			&& !bHitSomething)
			Velocity = MATCH_LAUNCH_VEL_MAG*vector(Rotation);
		// cheap reflect velocity, dampen x, y
		Velocity.x = -DAMPEN_MULT*Velocity.x;
		Velocity.y = -DAMPEN_MULT*Velocity.y;

		SurfaceHit();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Bounce off things
///////////////////////////////////////////////////////////////////////////////
function Bump(Actor Other)
{
	// cheap reflect velocity, dampen x, y
	Velocity.x = -DAMPEN_MULT*Velocity.x;
	Velocity.y = -DAMPEN_MULT*Velocity.y;

	SurfaceHit();
}

///////////////////////////////////////////////////////////////////////////////
// you've mave contact with a surface
///////////////////////////////////////////////////////////////////////////////
simulated function HitWall (vector HitNormal, actor Wall)
{
	// Reflect off Wall w/damping
	Velocity = DAMPEN_MULT*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);

	/*
	if (bFirstHit && speed<400) 
	{
		bFirstHit=False;
		bRotatetoDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;	
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.roll=0;
	}
	RotationRate.Yaw = RotationRate.Yaw*0.75;
	RotationRate.Roll = RotationRate.Roll*0.75;
	RotationRate.Pitch = RotationRate.Pitch*0.75;
	*/

	SurfaceHit(HitNormal);

	/*
	local float dotcheck;

	// Stop when you hit the ground
	dotcheck = HitNormal dot Velocity;
	log("dot check "$dotcheck);

	//Velocity = vect(0, 0, 0);
	Velocity.x = 0;
	Velocity.y = 0;
	//Acc = vect(0, 0, 0);

	CollisionLocation = Location;
	//if(Velocity.
	//	Super.HitWall(HitNormal, Wall);
	GotoState('Burning');
	*/
}

///////////////////////////////////////////////////////////////////////////////
// Debug lines
///////////////////////////////////////////////////////////////////////////////
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

//	if(Damage != 0)
//	{
		// position
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.z+=UseColRad;
		usevect2 = Location;
		usevect2.z-=UseColRad;
		Canvas.Draw3DLine(usevect, usevect2);
		// col radius
		tempcolor.R=255;
		tempcolor.G=0;
		tempcolor.B=0;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.x+=UseColRad;
		usevect2 = Location;
		usevect2.x-=UseColRad;
		Canvas.Draw3DLine(usevect, usevect2);
//	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// Change by NickP: MP fix
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	// End
	
	// xPatch:
	 LightType=LT_SubtlePulse
     LightBrightness=90.000000
     LightHue=43
     LightSaturation=132
     LightRadius=15.000000
     LightPeriod=20
	// End

	 DamageDistMag=1500;
	 Damage = 500;


     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
		SecondsBeforeInactive=0.0
        Acceleration=(Z=50.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(B=255))
        ColorScale(1)=(RelativeTime=0.300000,Color=(G=128,R=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(R=255))
        FadeOutStartTime=0.500000
        FadeOut=True
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.050000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.350000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
        StartSizeRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.FireMatch'
        LifetimeRange=(Min=0.800000,Max=0.800000)
        StartVelocityRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
        Name="SpriteEmitter14"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter14'
     bDynamicLight=True
     Physics=PHYS_Projectile
     LifeSpan=3.000000
     CollisionRadius=5.000000
     CollisionHeight=10.000000
	 Acc=(Z=-400)
	 UseColRad=25
     bCollideWorld=True
	 bCollideActors=True
	 bBounce=true
	 AutoDestroy=true
}
