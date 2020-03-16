//=============================================================================
// FireLimbEmitter.
// Don't catch things on fire here--have the limb do it on touch/bumps
//=============================================================================
class FireLimbEmitter extends FireHeadEmitter;

///////////////////////////////////////////////////////////////////////////////
// update location
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
{
	if (MyHead == None || MyHead.bDeleteMe)
		Destroy();
	else
		SetLocation(MyHead.Location + MyHead.Velocity/12);
}

///////////////////////////////////////////////////////////////////////////////
// Turn into napalm fire or not
///////////////////////////////////////////////////////////////////////////////
function SetFireType(bool bNapalm)
{
	local int i, count;

	bIsNapalm = bNapalm;

	if(Emitters.Length > 0)
	{
		// Decrease fire detail 
		count = Emitters[0].MaxParticles;
		count = P2GameInfo(Level.Game).ModifyByFireDetail(count);
		SuperSpriteEmitter(Emitters[0]).SetMaxParticles(count);
		// we have no smoke
		// Decrease smoke detail 
		//count = Emitters[1].MaxParticles;
		//count = P2GameInfo(Level.Game).ModifyBySmokeDetail(count);
		//if(count != 0)
		//	SuperSpriteEmitter(Emitters[1]).SetMaxParticles(count);
		//else
		//	Emitters[1].Disabled=true;
	}

	// changes texture, speeds it up some
	if(bIsNapalm)
	{
		// modify fire look
		if(Emitters.Length > 0)
		{
			// increase speed
			Emitters[0].StartVelocityRange.X.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.X.Min *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Y.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Y.Min *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Z.Max *= NapalmSpeedRatio;
			Emitters[0].StartVelocityRange.Z.Min *= NapalmSpeedRatio;
			// change texture
			Emitters[0].Texture=NapalmTexture;
		}
		// change the type of damage we deal
		MyDamageType = class'NapalmDamage';
	}


}

defaultproperties
{
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter31
         FadeOutStartTime=0.400000
         FadeOut=True
         MaxParticles=15
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=30.000000))
         ParticlesPerSecond=15.000000
         InitialParticlesPerSecond=15.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'nathans.Skins.firegroup3'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.700000)
         StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=270.000000,Max=380.000000))
         Name="SuperSpriteEmitter31"
     End Object
     Emitters(0)=SuperSpriteEmitter'SuperSpriteEmitter31'
     Begin Object Class=SuperSpriteEmitter Name=SuperSpriteEmitter22
         MaxParticles=10
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=100.000000))
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.300000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=35.000000,Max=60.000000))
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=2.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.smoke5'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=2.500000)
         StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
         Name="SuperSpriteEmitter22"
     End Object
     Emitters(1)=SuperSpriteEmitter'SuperSpriteEmitter22'
}
