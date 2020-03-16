//=============================================================================
// FireStreak. (line of fire)
//=============================================================================
class FireStreak extends FireEmitter;

//var vector UseNormal;
var vector RightDir;
var vector HitStart;
var vector HitEnd;
var vector UseNormal;
var float DistToParticleRatio;

const DAMAGE_FOR_NON_LINE=200;
const MIN_PARTICLES = 10;
const PARTICLE_EMISSION_RATIO=1.4;

///////////////////////////////////////////////////////////////////////////////
// Do all the work you need to do to accomodate hitting this normal
///////////////////////////////////////////////////////////////////////////////
function FitToNormal(vector HNormal)
{
	local float usez;
	// Make velocity push away from walls
	// This first part will make the fire go more sideways than anything, if it's on a ceiling like surface
	if(HNormal.z < -0.1)
	{	// spreads
		usez = (HNormal.z*Emitters[0].StartVelocityRange.Z.Max)/2;
		Emitters[0].StartVelocityRange.X.Max-=usez;
		Emitters[0].StartVelocityRange.X.Min+=usez;
		Emitters[0].StartVelocityRange.Y.Max-=usez;
		Emitters[0].StartVelocityRange.Y.Min+=usez;
	}
	else if(HNormal.z < 0.1) // like a wall or something (not a ceiling)
		// then make it sort of point away from the wall.
	{
//		Emitters[0].StartVelocityRange.X.Max+=usez;
//		Emitters[0].StartVelocityRange.X.Min+=usez;
//		Emitters[0].StartVelocityRange.Y.Max+=usez;
//		Emitters[0].StartVelocityRange.Y.Min+=usez;
		// and move it up some
//		Emitters[0].StartVelocityRange.Z.Max+=usez;
//		Emitters[0].StartVelocityRange.Z.Min+=usez;

		usez = (Emitters[0].StartVelocityRange.Z.Max)/2;
		Emitters[0].StartVelocityRange.X.Max=(HNormal.x+1)*usez;
		Emitters[0].StartVelocityRange.X.Min=(HNormal.x-1)*usez;
		Emitters[0].StartVelocityRange.Y.Max=(HNormal.y+1)*usez;
		Emitters[0].StartVelocityRange.Y.Min=(HNormal.y-1)*usez;
		// and move it up some
		Emitters[0].StartVelocityRange.Z.Max+=usez;
		Emitters[0].StartVelocityRange.Z.Min+=usez;
		// and give it more z range
		Emitters[0].StartLocationRange.Z.Max = 15;
		//Emitters[0].StartVelocityRange.Z.Max=(HNormal.z+1)*VEL_Z_MAX;
		//Emitters[0].StartVelocityRange.Z.Min=(HNormal.z-1)*VEL_MAX/2;
	}
	Emitters[0].StartVelocityRange.Z.Max+=(HNormal.z*Emitters[0].StartVelocityRange.Z.Max);
	Emitters[0].StartVelocityRange.Z.Min+=(HNormal.z*Emitters[0].StartVelocityRange.Z.Min);
	UseNormal = HNormal;

//	SetCollisionLocation(HNormal);
	CollisionLocation = Location;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function FindRightDir(vector HNormal, vector ForwardDir)
{
	// Find the cross between the direction of travel and the normal for the 
	// surface. This new vector will be used to move the collision line around for
	// greater hit coverage.
//	ForwardDir = SuperSpriteEmitter(Emitters[0]).LineStart - SuperSpriteEmitter(Emitters[0]).LineEnd;
//	ForwardDir = Normal(ForwardDir);
	RightDir = HNormal Cross ForwardDir;
}
/*
///////////////////////////////////////////////////////////////////////////////
// Trace a line and hurt things along it
///////////////////////////////////////////////////////////////////////////////
function HurtLine(float DamageAmount, class<DamageType> DamageType, float Momentum, 
				vector StartLoc, vector EndLoc )
{
	local actor Victims;
	local Fluid thisfluid;
	local float damageScale, dist;
	local vector dir;
	local vector OutHitNorm, OutHitLoc;
	
	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach TraceActors( class 'Actor', Victims, OutHitLoc, OutHitNorm, EndLoc, StartLoc )
	{
		if( Victims != self )
		{
			dir = Victims.Location - OutHitLoc;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			//damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			damageScale=1;
			thisfluid = Fluid(Victims);
			log("victims "$Victims);
			if(thisfluid == None
				|| thisfluid.bCanBeDamaged == true)
				// If it's a liquid and can be damaged by fire or anything else, hit
				// it like normal
			{
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator, 
					OutHitLoc,//Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageType
				);
			}
			else // if it's a liquid that CAN'T be damaged by fire it means it
				// can damaged THE FIRE itself (by putting it out)
			{
				TakeDamage
				(
					10,//thisfluid.DamageAmount,
					Pawn(thisfluid.MyOwner),
					OutHitLoc,//Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(-damageScale * Momentum * dir),
					class'ExtinguishDamage'
				);
			}
		} 
	}
	bHurtEntry = false;
}
*/
///////////////////////////////////////////////////////////////////////////////
// Try to hurt actors around you
///////////////////////////////////////////////////////////////////////////////
function DealDamage(float DeltaTime)
{
//	local int offset;
//	local P2Pawn p2p;
//	local vector HitStart, HitEnd;

	local actor Victims;
	local bool bAllowHit;
//	local float damageScale, dist;
//	local vector dir;
//	local vector OutHitNorm, OutHitLoc;

	if(Damage != 0)
	{
		/*
		if(Fluid(HurtMe) != None)
			return;

		if(ThickLineCylinderCollide(SuperSpriteEmitter(Emitters[0]).LineStart, 
							SuperSpriteEmitter(Emitters[0]).LineEnd, 
							DefCollHeight,
							DefCollRadius,
							HurtMe.Location,
							HurtMe.CollisionRadius,
							HurtMe.CollisionHeight))
		{
			p2p = P2Pawn(Hurtme);
			if(p2p != None)
				log("hurting "$p2p.Health);

			HurtMe.TakeDamage
			(
				1,//DeltaTime*Damage,
				Instigator,
				HurtMe.Location,//Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				vect(0, 0, 0),
				MyDamageType
			);
		}
		*/


		if( bHurtEntry )
			return;

		bHurtEntry = true;
		/*
		foreach RadiusActors( class 'Actor', Victims, CollisionRadius, Location)
		{
			if( Victims != self 
				&& !Victims.bHidden)
			{
				if(FluidPuddle(Victims) != None)
				{
					bAllowHit = true;
				}
				else
				{
					bAllowHit = ThickLineCylinderCollide(SuperSpriteEmitter(Emitters[0]).LineStart, 
										SuperSpriteEmitter(Emitters[0]).LineEnd, 
										DefCollRadius,
										DefCollHeight,
										Victims.Location,
										Victims.CollisionRadius,
										Victims.CollisionHeight);
				}

				if(bAllowHit)
				{
					Victims.TakeDamage
					(
						DeltaTime*Damage,
						Instigator,
						Victims.Location,//Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						vect(0, 0, 0),
						MyDamageType
					);
				}
			}
		}
		*/
		FireHurtRadius(DeltaTime*Damage, CollisionRadius, MyDamageType, SuperSpriteEmitter(Emitters[0]).LineStart, SuperSpriteEmitter(Emitters[0]).LineEnd, DefCollRadius, DefCollHeight);
		
		bHurtEntry = false;

/*							
		if(SuperSpriteEmitter(Emitters[0]).LocationShapeExtend == PTLSE_Line)
		{
			// 0 here for momentumtransfer (second from end)
			// Make the line segment be from the start to the end of this emitter
			HitStart = SuperSpriteEmitter(Emitters[0]).LineStart;
			HitStart.z+=DamageDistMag;
			HitEnd = SuperSpriteEmitter(Emitters[0]).LineEnd;
			HitEnd.z+=DamageDistMag;
			// Flipflop the vector around the original orientation, so that
			// you cover a wider area, but with a single collision line
			offset = Rand(2*DamageDistMag) - DamageDistMag;
			HitStart = HitStart + offset*RightDir;
			HitEnd = HitEnd + offset*RightDir;
			HurtLine(DeltaTime*Damage, MyDamageType, 0, 
					HitStart, HitEnd );
		}
		else
			Super.DealDamage(DeltaTime, HurtMe);
*/
  
	}
}

///////////////////////////////////////////////////////////////////////////////
// You're ready to really burn because the starter has completed its run
///////////////////////////////////////////////////////////////////////////////
function StarterAtEnd(float SetDist)
{
	local SmokeStreak sstreak;
	local vector newsize;
	local float newheight;

	//log("at the end");
	// Check to make sure it moved
	if(SuperSpriteEmitter(Emitters[0]).LocationShapeExtend == PTLSE_Line)
	{
		// If after the line has supposedly moved and it's done moving, but
		// the line segment is collapsed, then turn the UseLine back off.
		if(VectorsInFuzz(SuperSpriteEmitter(Emitters[0]).LineStart, 
										SuperSpriteEmitter(Emitters[0]).LineEnd, 0.1) == true)
		{
			SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_None;
			// increase the damage distance if not a full line
			DamageDistMag=DAMAGE_FOR_NON_LINE;
		}
	}
	// start up the smoke coming from this finished (ready to hurt things) streak
	sstreak = spawn(class 'SmokeStreak',,,Location);
	sstreak.CalcParticleNeed(VSize(SuperSpriteEmitter(Emitters[0]).LineStart - SuperSpriteEmitter(Emitters[0]).LineEnd));
	sstreak.SetLine(SuperSpriteEmitter(Emitters[0]).LineStart, SuperSpriteEmitter(Emitters[0]).LineEnd,
		Emitters[0].StartVelocityRange, UseNormal);

	// point fire to your smoke
	MySmoke = sstreak;
	// update your smoke's lifespan
	MySmoke.SetupLifetime(OrigLifeSpan);

	// Calc the size of the collision for this
	newsize = SuperSpriteEmitter(Emitters[0]).LineStart - SuperSpriteEmitter(Emitters[0]).LineEnd;
	newheight = newsize.z;
	newsize.z=0;

	SetCollisionSize(VSize(newsize) + DefCollRadius, newheight + DefCollHeight);
}

///////////////////////////////////////////////////////////////////////////////
// Figure out how many particles to use.
// Figure out if we should play a sound or not
///////////////////////////////////////////////////////////////////////////////
function CalcStartupNeeds(float newdist)
{
	local int newmax;
	local FireStreak fs;
	local float dist;
	local int count;
	
	newmax = newdist/DistToParticleRatio;

	if(newmax < MIN_PARTICLES)
		newmax = MIN_PARTICLES;

	// Decrease fire detail 
	newmax = P2GameInfo(Level.Game).ModifyByFireDetail(newmax);

	Emitters[0].ParticlesPerSecond = PARTICLE_EMISSION_RATIO*newmax;
	Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;
	SuperSpriteEmitter(Emitters[0]).SetMaxParticles(newmax);
	//log(self$" new particle max decided "$newmax);

	DoSoundAndLight();
}

/*
simulated event RenderOverlays( canvas Canvas )
{
	local color tempcolor;
	local vector usevect, usevect2;

//	if(Damage != 0)
//	{
		//tempcolor.R=255;
		tempcolor.G=255;
		Canvas.DrawColor = tempcolor;
		//Canvas.Draw3DLine(HitStart, HitEnd);
		Canvas.Draw3DLine(SuperSpriteEmitter(Emitters[0]).LineStart, SuperSpriteEmitter(Emitters[0]).LineEnd);

		if(SuperSpriteEmitter(Emitters[0]).LineStart != Location)
		{
			log("l 1 "$SuperSpriteEmitter(Emitters[0]).LineStart);
			log("l 2 "$SuperSpriteEmitter(Emitters[0]).LineEnd);
			log("l 3 "$Location);
		}

		// position
		tempcolor.B=255;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.z+=CollisionHeight;
		usevect2 = Location;
		usevect2.z-=CollisionHeight;
		Canvas.Draw3DLine(usevect, usevect2);
		// col radius
		tempcolor.R=255;
		tempcolor.G=0;
		tempcolor.B=0;
		Canvas.DrawColor = tempcolor;
		usevect = Location;
		usevect.x+=CollisionRadius;
		usevect2 = Location;
		usevect2.x-=CollisionRadius;
		Canvas.Draw3DLine(usevect, usevect2);
//	}
}
*/

/*
auto state Expanding
{
	function BeginState()
	{
		GotoState('BurningGasOff');	// no start up for default, go now to burning
	}
}

state BurningGasOff
{
	function Tick(float DeltaTime)
	{
		// hurt stuff around me
		DealDamage(DeltaTime);
		UseColor0.x += InterpColor.x*DeltaTime;
		UseColor0.y += InterpColor.y*DeltaTime;
		UseColor0.z += InterpColor.z*DeltaTime;
		Emitters[0].ColorScale[0].Color.R = UseColor0.x;
		Emitters[0].ColorScale[0].Color.G = UseColor0.y;
		Emitters[0].ColorScale[0].Color.B = UseColor0.z;
	}

	simulated function Timer()
	{
		Emitters[0].ColorScale[0] = Emitters[0].ColorScale[1];
		GotoState('Burning');
	}
	function BeginState()
	{
		SetTimer(OrigLifeSpan, false);
	}
}

        UseColorScale=True
        ColorScale(0)=(Color=(B=255, R=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=146,G=220,R=239))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=23,G=95,R=202))

*/

defaultproperties
{
	 Damage=50
	 DamageDistMag=80
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter4
		SecondsBeforeInactive=0.0
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=25
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-5.000000))
         StartLocationOffset=(Z=-5.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=80.000000))
         ParticlesPerSecond=25.000000
         InitialParticlesPerSecond=25.000000
         AutomaticInitialSpawning=False
		 DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.450000,Max=0.700000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=120.000000,Max=220.000000))
         Name="SuperSpriteEmitter4"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter4'
     LifeSpan=25.000000
	 DefCollRadius=100
	 DefCollHeight=100
	 DistToParticleRatio=6
	 bCollideActors=true
	 AutoDestroy=true
}
