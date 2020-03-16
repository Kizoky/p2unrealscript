class ZFloatBlast extends P2Emitter;

var class<AWZombie>	OrigZClass;
var vector			OrigZLocation;
var Material		OrigZSkin;
var int trycount;
var AWZombie		newguy;
var P2Player		awp;

const TRY_MAX	=	10;
const TRY_TIME	=	0.1;
const TRY_Z_BOOST = 30.0;
const FIRST_WAIT=	0.5;
const FIRST_WAIT_COUNT = 5;
const FINAL_WAIT=	0.7;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(awp != None)
		awp.RaisedZombie();
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function StoreZombie(AWZombie orig)
{
	//log(self$" store "$orig);
	if(orig != None)
	{
		OrigZClass = orig.class;
		OrigZLocation = orig.Location;
		OrigZSkin = orig.Skins[0];
		orig.zfblast = None;
		orig.Destroy();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function RecreateZombie()
{
	//log(self$" recreate "$OrigZClass$" loc "$OrigZLocation);
	if(OrigZClass != None)
	{
		newguy = spawn(OrigZClass,,,OrigZLocation);
		//log(self$" tried to make "$newguy);
		if(newguy != None)
		{
			newguy.Skins[0] = OrigZSkin;
			newguy.SetToFloating();
			//log(self$" my new controller "$newguy.Controller);
		}
		else
		{
			trycount++;
			OrigZLocation.z=OrigZLocation.z + TRY_Z_BOOST;
			//log(self$" new loc "$origzlocation);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Find our owner and recreate him
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state FindingZombie
{
Begin:
	// Play crazy sound from player
	if(awp != None)
		awp.PlaySound(awp.RadarTargetMusic, SLOT_Misc, 1.0,,1000);
WaitLoop:
	Sleep(FIRST_WAIT);
	// Shake view of player
	if(awp != None)
		awp.BigShake();
	trycount++;
	if(trycount < FIRST_WAIT_COUNT)
		goto('WaitLoop');
	trycount=0;
	StoreZombie(AWZombie(Owner));
TryToMakeHim:
	Sleep(TRY_TIME);
	RecreateZombie();
	if(newguy == None
		&& trycount < TRY_MAX)
		goto('TryToMakeHim');
	// continue to go for a little while, then die
	Sleep(FINAL_WAIT);
	SelfDestroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter89
         UseDirectionAs=PTDU_Up
         Acceleration=(Z=100.000000)
         UseColorScale=True
         ColorScale(0)=(Color=(B=179,G=179,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.400000
         FadeOut=True
         FadeInEndTime=0.200000
         FadeIn=True
         MaxParticles=150
         StartLocationOffset=(Z=-30.000000)
         StartLocationRange=(X=(Min=-45.000000,Max=45.000000),Y=(Min=-45.000000,Max=45.000000),Z=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=110.000000,Max=150.000000))
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.waterblobs'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=300.000000,Max=500.000000))
         VelocityLossRange=(Z=(Max=1.500000))
         Name="SpriteEmitter89"
     End Object
     Emitters(0)=SpriteEmitter'SpriteEmitter89'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter88
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         ColorScale(0)=(Color=(B=128,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
         FadeOutStartTime=0.400000
         FadeOut=True
         FadeInEndTime=0.200000
         FadeIn=True
         MaxParticles=12
         SpinParticles=True
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=0.400000,Max=0.600000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=140.000000,Max=180.000000))
         UniformSize=True
         DrawStyle=PTDS_Darken
         Texture=Texture'nathans.Skins.bigfluidripple'
         LifetimeRange=(Min=0.600000,Max=0.700000)
         StartVelocityRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000))
         Name="SpriteEmitter88"
     End Object
     Emitters(1)=SpriteEmitter'SpriteEmitter88'
     AutoDestroy=True
     AmbientSound=Sound'LevelSoundsToo.Napalm.napalmBallRoll'
     SoundRadius=600.000000
     SoundVolume=255
     SoundPitch=2
     TransientSoundVolume=255.000000
     TransientSoundRadius=600.000000
}
