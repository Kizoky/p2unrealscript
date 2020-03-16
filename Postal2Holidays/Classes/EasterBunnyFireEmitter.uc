/**
 * EasterBunnyFireEmitter
 *
 * A Fire Emitter left behind by the Easter Bunny when he performs a super
 * dash attack
 */
class EasterBunnyFireEmitter extends FireEmitter;

/** Stubbed out so the fire cannot be peed out, not like you have the time to
 * do so anyways with the Easter Bunny on your tail.
 */
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType);

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
		FadeOut=true
		MaxParticles=25
		StartLocationRange=(X=(Min=-20,Max=20),Y=(Min=-60,Max=60))
		SpinParticles=true
		SpinsPerSecondRange=(X=(Min=0.2,Max=0.4))
		UseSizeScale=true
		UseRegularSizeScale=false
		SizeScale(0)=(RelativeSize=0.2)
		SizeScale(1)=(RelativeTime=0.2,RelativeSize=1)
		SizeScale(2)=(RelativeTime=1,RelativeSize=0.2)
		StartSizeRange=(X=(Min=25,Max=40))
		DrawStyle=PTDS_Brighten
		Texture=Texture'nathans.Skins.firegroup3'
		TextureUSubdivisions=1
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=true
		LifetimeRange=(Min=0.5,Max=0.6)
		StartVelocityRange=(X=(Min=-10,Max=10),Y=(Min=-10,Max=10),Z=(Min=200,Max=330))
		Name="SpriteEmitter0"
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter0'

	Damage=200

	CollisionRadius=64
}