//=============================================================================
// SnowEmitter. MrD - just tired of hunting for it when needed.
//=============================================================================
class SnowEffect extends WeatherEffect;

	

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter21
         UseCollision=True
         UseMaxCollisions=True
         MaxCollisions=(Min=1.000000,Max=1.000000)
         FadeInEndTime=0.500000
         FadeIn=True
         MaxParticles=200
         StartLocationRange=(X=(Min=-3400.000000,Max=3400.000000),Y=(Min=-4400.000000,Max=4400.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Min=0.300000,Max=0.700000),Y=(Min=0.300000,Max=0.700000))
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         Texture=Texture'spew.spewage.flake-sw'
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(Z=(Min=-192.000000,Max=-256.000000))
         Name="SpriteEmitter21"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitter21'
     bNoDelete=False
     bAlwaysRelevant=True
	Texture=Texture'PostEd.Icons_256.SnowEmitter'
	DrawScale=0.25
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.SnowEmitter'
}