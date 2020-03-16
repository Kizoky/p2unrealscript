//=============================================================================
// RainEmitter. MrD - just tired of hunting for it when needed.
//=============================================================================
class RainEffect extends WeatherEffect;
	
	

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         UseDirectionAs=PTDU_Up
         UseCollision=True
         UseMaxCollisions=True
         MaxCollisions=(Max=1.000000)
         SpawnFromOtherEmitter=1
         SpawnAmount=1
         MaxParticles=100
         StartLocationRange=(X=(Min=-2310.000000,Max=2310.000000),Y=(Min=-2600.000000,Max=2600.000000))
         StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=50.000000,Max=50.000000))
         Texture=Texture'Zo_MonsoonTex.SkyBox.zo_raindrop'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=-10000.000000,Max=-10000.000000))
         Name="SpriteEmitter14"
     End Object
     Emitters(0)=SpriteEmitter'FX2.SpriteEmitter14'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter74
         MaxParticles=100
         RespawnDeadParticles=False
         StartLocationRange=(Z=(Min=6.000000,Max=6.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.025000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.150000)
         Texture=Texture'Zo_MonsoonTex.CubeMaps.zo_rainsplat3'
         LifetimeRange=(Min=0.300000,Max=0.300000)
         Name="SpriteEmitter74"
     End Object
     Emitters(1)=SpriteEmitter'FX2.SpriteEmitter74'
     bNoDelete=False
     bAlwaysRelevant=True
	Texture=Texture'PostEd.Icons_256.RainEmitter'
	DrawScale=0.25
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.RainEmitter'
}