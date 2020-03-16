///////////////////////////////////////////////////////////////////////////////
// FootFireBurn
// visual and burning
///////////////////////////////////////////////////////////////////////////////
class FootFireBurn extends P2Emitter;

var float BurnTime;
var float Dam;
var class<P2Damage> mydam;
var bool bDestroying;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Touch(Actor Other)
{
	if(Other != Owner
		&& !bDestroying)
	{
		Other.TakeDamage(Dam, Pawn(Owner), Other.Location, vect(0,0,1), mydam);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Burning
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Burning
{
Begin:
	Sleep(BurnTime);
	bDestroying=true;
	SelfDestroy();
}

defaultproperties
{
     BurnTime=10.000000
     Dam=10.000000
     mydam=Class'BaseFX.BurnedDamage'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter32
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=15
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-15.000000))
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
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=200.000000,Max=300.000000))
         Name="SuperSpriteEmitter32"
     End Object
     Emitters(0)=SuperSpriteEmitter'AWEffects.SuperSpriteEmitter32'
     AutoDestroy=True
     AmbientSound=Sound'WeaponSounds.fire_large'
     SoundRadius=40.000000
     SoundVolume=255
     TransientSoundVolume=255.000000
     TransientSoundRadius=40.000000
     CollisionRadius=80.000000
     CollisionHeight=60.000000
     bCollideActors=True
}
