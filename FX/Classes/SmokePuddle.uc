//=============================================================================
// SmokePuddle. (filled circle emitting smoke)
//=============================================================================
class SmokePuddle extends SmokeEmitter;

var SmokePuddleCeiling MyCeilingEmitter;

const EMISSION_RATIO = 0.13;
const PARTICLE_RATIO = 0.3;
const MIN_PARTICLE_USE=10;
const MIN_NORMAL_Z_TO_MAKE=-0.9;
const MAX_CEILING_Z_START_RANGE = -150;

replication
{
	// functions server sends to client
	unreliable if(Role == ROLE_Authority)
		ClientPrepSize;
}

///////////////////////////////////////////////////////////////////////////////
// setup lifetimes
///////////////////////////////////////////////////////////////////////////////
simulated function SetupLifetime(float uselife)
{
	Super.SetupLifetime(uselife);
	if(MyCeilingEmitter != None)
		MyCeilingEmitter.SetupLifetime(uselife);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PrepSize(float UseRadius)
{
	local float count;

	count = UseRadius*PARTICLE_RATIO;
	count+=MIN_PARTICLE_USE;
	// Decrease smoke detail 
	if(P2GameInfo(Level.Game) != None)
		count = P2GameInfo(Level.Game).ModifyBySmokeDetail(count);

	ClientPrepSize(UseRadius, count);

	if(count != 0)
	{
		CheckWallsForWind();
		CheckToMakeCeilingEmitter();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function ClientPrepSize(float UseRadius, float count)
{
	Emitters[0].SphereRadiusRange.Max = UseRadius;

	if(count != 0)
	{
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(count);
		Emitters[0].ParticlesPerSecond = Emitters[0].MaxParticles*EMISSION_RATIO;
		if(Emitters[0].ParticlesPerSecond < 0)
			Emitters[0].ParticlesPerSecond=1;
		Emitters[0].InitialParticlesPerSecond = Emitters[0].ParticlesPerSecond;

		SuperSpriteEmitter(Emitters[0]).LocationShapeExtend=PTLSE_Circle;
		WindCheckDist = 3*UseRadius;
	}
	else
		Emitters[0].Disabled=true;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function CheckToMakeCeilingEmitter()
{
	local vector StartPos, EndPos, HitLocation, MakeLocation, HitNormal;
	local float checkdist, ceilingheight;


	checkdist = ((Emitters[0].LifetimeRange.Max+Emitters[0].LifetimeRange.Min)/2)*
					((Emitters[0].StartVelocityRange.Z.Max+Emitters[0].StartVelocityRange.Z.Min)/2);
	checkdist += (Emitters[0].StartSizeRange.X.Max + Emitters[0].StartSizeRange.X.Min)/2;

	StartPos = Location;
	EndPos = Location;
	EndPos.z += checkdist;
	// Check center first, then two edges to see if we have a good ceiling
	if(Trace(HitLocation, HitNormal, EndPos, StartPos, false) != None)
	{
		ceilingheight=HitNormal.z - StartPos.z;
		// Make sure the ceiling is flat
		if(HitNormal.z >= MIN_NORMAL_Z_TO_MAKE)
			return;

		// This is where we will make it if the following tests work
		MakeLocation = HitLocation;

		StartPos.x+=Emitters[0].SphereRadiusRange.Max;
		EndPos.x+=Emitters[0].SphereRadiusRange.Max;
		if(Trace(HitLocation, HitNormal, EndPos, StartPos, false) != None)
		{
			// Make sure the ceiling is flat and not too high
			if(HitNormal.z >= MIN_NORMAL_Z_TO_MAKE
				&& HitNormal.z - StartPos.z > ceilingheight)
				return;

			// test back on the other side
			StartPos.x-=(2*Emitters[0].SphereRadiusRange.Max);
			EndPos.x-=(2*Emitters[0].SphereRadiusRange.Max);
			if(Trace(HitLocation, HitNormal, EndPos, StartPos, false) != None)
			{
				// Make sure the ceiling is flat and not too high
				if(HitNormal.z < MIN_NORMAL_Z_TO_MAKE
					&& HitNormal.z - StartPos.z <= ceilingheight)
				{
					MyCeilingEmitter = spawn(class'SmokePuddleCeiling',Owner,,MakeLocation);
					MyCeilingEmitter.SetupLifetime(OrigLifeSpan);
					MyCeilingEmitter.PrepSize(Emitters[0].SphereRadiusRange.Max);
					// squish in z appropriately
					ceilingheight = -ceilingheight/2;
					if(ceilingheight < MAX_CEILING_Z_START_RANGE)
						ceilingheight = MAX_CEILING_Z_START_RANGE;
					MyCeilingEmitter.ClientSquishZ(ceilingheight);
					//log("check me "$spc.Emitters[0].StartLocationRange.Z.Min);
				}
			}
		}
	}
}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter13
		SecondsBeforeInactive=0.0
        MaxParticles=30
        StartLocationRange=(Z=(Min=-60.000000,Max=60.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=150.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="SuperSpriteEmitter13"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter13'
     LifeSpan=30.000000
     AutoDestroy=true
}
