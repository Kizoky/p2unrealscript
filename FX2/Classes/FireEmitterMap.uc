class FireEmitterMap extends FireEmitter;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter20
		FadeOut=True
		MaxParticles=25
		StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-60.000000,Max=60.000000))
		SpinParticles=True
		SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
		UseSizeScale=True
		UseRegularSizeScale=False
		SizeScale(0)=(RelativeSize=0.200000)
		SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.200000)
		StartSizeRange=(X=(Min=25.000000,Max=40.000000))
		DrawStyle=PTDS_Brighten
		Texture=Texture'nathans.Skins.firegroup3'
		TextureUSubdivisions=1
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		LifetimeRange=(Min=0.500000,Max=0.600000)
		StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=200.000000,Max=330.000000))
		Name="SpriteEmitter20"
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter20'
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.FireEmitter'

	CollisionRadius=60
	CollisionHeight=60
}