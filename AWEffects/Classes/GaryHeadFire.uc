///////////////////////////////////////////////////////////////////////////////
// GaryHeadFire
// Just visual--no actual burning
// Particles don't move up though, just use the old head position, as it moves
///////////////////////////////////////////////////////////////////////////////
class GaryHeadFire extends P2Emitter;

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter35
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=10
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=30.000000,Max=50.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=25.000000,Max=50.000000))
         Name="SuperSpriteEmitter35"
     End Object
     Emitters(0)=SuperSpriteEmitter'AWEffects.SuperSpriteEmitter35'
     AutoDestroy=True
     Physics=PHYS_Trailer
//     AmbientSound=Sound'WeaponSounds.fire_large'
//     SoundRadius=40.000000
//     SoundVolume=255
     TransientSoundVolume=255.000000
     TransientSoundRadius=40.000000

	// Change by NickP: MP fix
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	// End
}
