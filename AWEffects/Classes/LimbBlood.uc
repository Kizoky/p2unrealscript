class LimbBlood extends P2Emitter;

// Change by NickP: MP fix
auto simulated state AutoStart
{
	simulated function BeginState()
	{
		Super.BeginState();
		if (Role < ROLE_Authority)
		{
			SelfDestroy(true);
			LifeSpan = 0.1;
		}
	}
}
// End

// Kamek edit
event Tick(float Delta)
{
//	log(self@"tick super");
	Super.Tick(Delta);
//	log(self@"tick; base is"@base@"owner is"@owner);
	if (Base == None || Owner == None)
	{
//		log(self@"destroying");
		SelfDestroy();
		Destroy();
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter126
         Acceleration=(Z=-300.000000)
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=4.000000,Max=7.000000))
         InitialParticlesPerSecond=60.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'nathans.Skins.bloodchunks1'
         TextureUSubdivisions=1
         TextureVSubdivisions=4
         UseRandomSubdivision=True
         LifetimeRange=(Min=0.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         Name="SpriteEmitter126"
     End Object
     Emitters(0)=SpriteEmitter'AWEffects.SpriteEmitter126'
     AutoDestroy=True
     Mass=-25.000000
}
