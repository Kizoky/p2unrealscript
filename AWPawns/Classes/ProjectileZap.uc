///////////////////////////////////////////////////////////////////////////////
// ProjectileZap
// Lightning bolt that shoots out of the awbosseye and
// Makes projectiles fall the ground uselessly
// 
///////////////////////////////////////////////////////////////////////////////
class ProjectileZap extends P2Emitter;

var float HitTime;
var float HitRange;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PointHere(vector useloc, Actor zapme, bool bNoActor)
{
	if(Emitters.Length > 0)
	{
		if(bNoActor)
		{
			BeamEmitter(Emitters[0]).DetermineEndPointBy = PTEP_OffsetAsAbsolute;
		}
		else
			BeamEmitter(Emitters[0]).BeamEndPoints[0].ActorTag = zapme.Tag;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.X.Max = useloc.x + HitRange;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.X.Min = useloc.x - HitRange;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.Y.Max = useloc.y + HitRange;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.Y.Min = useloc.y - HitRange;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.Z.Max = useloc.z + HitRange;
		BeamEmitter(Emitters[0]).BeamEndPoints[0].Offset.Z.Min = useloc.z - HitRange;
	}
}

auto state Hitting
{
Begin:
	Sleep(HitTime);
	SelfDestroy();
}

defaultproperties
{
     HitTime=0.500000
     HitRange=30.000000
     Begin Object Class=BeamEmitter Name=BeamEmitter4
         BeamDistanceRange=(Min=120.000000,Max=120.000000)
         BeamEndPoints(0)=(Weight=1.000000)
         DetermineEndPointBy=PTEP_Actor
         LowFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         LowFrequencyPoints=5
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=1.000000,Max=3.000000))
         UseColorScale=True
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(R=255))
         ColorScaleRepeats=1.000000
         FadeOut=True
         MaxParticles=5
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=20.000000,Max=30.000000))
         Texture=Texture'nathans.Skins.lightning6'
         LifetimeRange=(Min=0.400000,Max=0.600000)
         StartVelocityRange=(X=(Min=250.000000,Max=300.000000),Y=(Min=300.000000,Max=300.000000),Z=(Min=100.000000,Max=100.000000))
         Name="BeamEmitter4"
     End Object
     Emitters(0)=BeamEmitter'AWPawns.BeamEmitter4'
     AutoDestroy=True
}
