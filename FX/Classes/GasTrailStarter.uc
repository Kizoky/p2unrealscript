///////////////////////////////////////////////////////////////////////////////
// GasTrailStarter
// Set numbers particular to gasoline.
// No visual representation
///////////////////////////////////////////////////////////////////////////////
class GasTrailStarter extends FluidTrailStarter;

/*
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter9
        UseDirectionAs=PTDU_Normal
        FadeOutStartTime=0.300000
        FadeOut=True
        MaxParticles=20
        DrawStyle=PTDS_AlphaBlend
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=15.000000))
        Texture=Texture'nathans.Skins.gassplat1'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        LifetimeRange=(Min=0.600000,Max=0.800000)
        Name="SuperSpriteEmitter9"
     End Object
     Emitters(0)=SuperSpriteEmitter'Fx.SuperSpriteEmitter9'
*/
defaultproperties
{
     SpawnClass=Class'Fx.GasFlowTrail'
     PuddleClass=Class'Fx.GasPuddle'
     MyType=FLUID_TYPE_Gas
     bCanBeDamaged=false
	 DripFeederClass = Class'GasDripFeeder'
	 AutoDestroy=true
}
