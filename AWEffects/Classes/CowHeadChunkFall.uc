///////////////////////////////////////////////////////////////////////////////
// Chunks that rain down after a cow's head blows up. The first emitter has
// a range high up, the second one is the splats the pieces make
///////////////////////////////////////////////////////////////////////////////
class CowHeadChunkFall extends P2Emitter;

const Z_CHECK	= 630;
const Z_BUFFER	= 30;
const Z_MIN		= 200;

///////////////////////////////////////////////////////////////////////////////
// Reach up and find a ceiling if there is one
// If so, move the emitter range up to that, the one that drops the big
// chunks
///////////////////////////////////////////////////////////////////////////////
function bool SetupHeight()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, checkpoint;
	local float offz;

	checkpoint = Location;
	checkpoint.z+=Z_CHECK;

	HitActor = Trace(HitLocation, HitNormal, checkpoint, Location);
	if(HitActor == None)
		HitLocation = checkpoint;
	// move down from 'ceiling'
	HitLocation.z -= Z_BUFFER;
	offz = HitLocation.z - Location.z;
	if(offz > Z_MIN)
	{
		// Move first emitter range up
		if(Emitters.Length > 0)
		{
			Emitters[0].StartLocationOffset.Z+=offz;
		}
		return true;
	}
	return false;
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
         Acceleration=(Z=-800.000000)
         UseCollision=True
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         UseMaxCollisions=True
         MaxCollisions=(Min=1.000000,Max=1.000000)
         SpawnFromOtherEmitter=1
         SpawnAmount=1
         CollisionSound=PTSC_LinearGlobal
         CollisionSoundIndex=(Max=1.000000)
         CollisionSoundProbability=(Min=1.000000,Max=1.000000)
         Sounds(0)=(Sound=Sound'WeaponSounds.bullet_hitflesh2',Radius=(Min=100.000000),Pitch=(Min=1.050000,Max=0.950000),Weight=1,Volume=(Min=1.000000,Max=0.700000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(1)=(Sound=Sound'WeaponSounds.bullet_hitflesh3',Radius=(Min=100.000000),Pitch=(Min=1.050000,Max=0.950000),Weight=1,Volume=(Min=1.000000,Max=0.700000),Probability=(Min=1.000000,Max=1.000000))
         MaxParticles=10
         RespawnDeadParticles=False
         StartLocationRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.500000),Y=(Min=0.500000,Max=1.500000),Z=(Min=0.800000,Max=2.000000))
         InitialParticlesPerSecond=4.000000
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         InitialDelayRange=(Min=0.600000,Max=1.000000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-100.000000,Max=-200.000000))
         Name="MeshEmitter1"
     End Object
     Emitters(0)=MeshEmitter'AWEffects.MeshEmitter1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter123
         UseDirectionAs=PTDU_Normal
         MaxParticles=25
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=20.000000,Max=30.000000),Y=(Min=20.000000,Max=30.000000))
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodimpacts'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=10.000000,Max=15.000000)
         Name="SpriteEmitter123"
     End Object
     Emitters(1)=SpriteEmitter'AWEffects.SpriteEmitter123'
     AutoDestroy=True
     LifeSpan=20.000000
}
