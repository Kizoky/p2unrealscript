//=============================================================================
// ChemHeadEmitter.
//=============================================================================
class ChemHeadEmitter extends P2Emitter;

var PeoplePart MyHead;

var float Damage;
var class<P2Damage> MyDamageType;
var float HurtTime;				// Frequency of damage

const BONE_MIDDLE			= 'MALE01 Pelvis';


///////////////////////////////////////////////////////////////////////////////
// Be sure to free us from our owner
///////////////////////////////////////////////////////////////////////////////
function Destroyed()
{
	if(MyHead != None)
		MyHead.MyPartChem=None;
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Assign us the pawn we're burning
///////////////////////////////////////////////////////////////////////////////
function SetOwners(PeoplePart NewHead, FPSPawn Doer)
{
	MyHead = NewHead;
	MyHead.MyPartChem=self;
	Instigator = Doer;
	// Randomize the hit on the processor, in case there were lots set off at the
	// same time
	HurtTime = default.HurtTime + Frand()*0.5;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Hurting
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Hurting
{
Begin:
	Sleep(HurtTime);
	if(MyHead == None
		|| MyHead.bDeleteMe)
		GotoState('WaitAfterFade');
	MyHead.HurtRadius(Damage, CollisionRadius, MyDamageType, 0, Location);
	Goto('Begin');
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
}

defaultproperties
{
	HurtTime=1.0
	 Damage=30
	 MyDamageType = class'ChemDamage'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter6
	 	 SecondsBeforeInactive=0.0
         UseColorScale=true
         ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=200,R=150))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
         Acceleration=(Z=-100.000000)
         FadeOut=True
         MaxParticles=8
        StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         SizeScaleRepeats=3.000000
         StartSizeRange=(X=(Min=2.000000,Max=4.000000))
         Texture=Texture'nathans.Skins.bubbles'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=20.000000,Max=50.000000))
         Name="SuperSpriteEmitter6"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter6'
    Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter14
        FadeInEndTime=0.300000
        FadeIn=True
        FadeOutStartTime=0.300000
        FadeOut=True
		SecondsBeforeInactive=0.0
        UseColorScale=true
        ColorScale(0)=(RelativeTime=0.000000,Color=(B=50,G=150,R=150))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=255,R=50))
        MaxParticles=2
        SpinParticles=True
        StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseRegularSizeScale=True
        StartSizeRange=(X=(Min=20.000000,Max=40.000000))
		DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=1.200000,Max=1.400000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=0.000000,Max=30.000000))
        Name="SuperSpriteEmitter14"
    End Object
    Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter14'
	 AutoDestroy=true
     LifeSpan=0.000000
     Physics=PHYS_Trailer
	 CollisionRadius=150
	 CollisionHeight=150
}
