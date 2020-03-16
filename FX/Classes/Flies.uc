//=============================================================================
// Flies.
//=============================================================================
class Flies extends P2Emitter;

var vector AccDir;
var float dir1;

const ACC_MAX	=	100;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.15, true);
//	log("flies object was begun");
}

function Timer()
{
	local vector randvect;
	AccDir.x+=dir1;
	AccDir.y-=dir1/2;
	AccDir.z+=dir1/3;
	if(AccDir.x > 1.0 && dir1 > 0)
		dir1 = -dir1;
	else if(AccDir.x < -1.0 && dir1 < 0)
		dir1 = -dir1;
//	randvect.x = FRand() - 0.5;
//	randvect.y = FRand() - 0.5;
//	randvect.z = FRand() - 0.5;
//	Normal(randvect);
	randvect = Normal(AccDir);

	Emitters[0].Acceleration = (FRand()*ACC_MAX)*randvect;
//	log("new flies acceleration "$Emitters[0].Acceleration);

	//SetTimer(FRand()+0.1, false);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
		SecondsBeforeInactive=0.0
        Acceleration=(Z=200.000000)
        MaxParticles=8
        StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=30.000000,Max=40.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.000000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=0.800000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=6.000000,Max=10.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.Fly'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=5.000000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
        Name="SpriteEmitter8"
     End Object
     Emitters(0)=SpriteEmitter'Fx.SpriteEmitter8'
	 dir1=0.05;
	 AutoDestroy=true
}
