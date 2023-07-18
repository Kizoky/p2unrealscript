//=====================================================================================
// MuzzleFlash_Minigun
// Created by Man Chrzan for xPatch 2.0
//
// Muzzle Flash for Paradise Lost's Munted Minigun with dynamic lighting support
//=====================================================================================
class MuzzleFlash_Minigun extends xMuzzleFlashEmitter;

/////////////////////////////////////////////////////////////////
// Setup Dynamic Light
/////////////////////////////////////////////////////////////////
simulated function SetDynamicLight()
{
	GotoState('DynamicLight');
}

simulated state DynamicLight
{
	simulated event Tick(float Delta)
	{
		if (TickCount>MaxTickCount)
		{
			if(LightBrightness > 0)
				LightBrightness -= 50;
			else
				GotoState('');
		}
	
		TickCount++;
	}

	simulated function EndState()
	{
		LightType=LT_None;
		//P2Weapon(Instigator.Weapon).SetupWeaponGlow(0);
	}

	simulated function BeginState()
	{
		TickCount=0;
		LightBrightness = RandRange(100,200);
		LightRadius = RandRange(10,20);
		LightType = FlashLightType;
		//P2Weapon(Instigator.Weapon).SetupWeaponGlow(FlashAmbientGlow);
	}
}

/////////////////////////////////////////////////////////////////
// Default properties
/////////////////////////////////////////////////////////////////
defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterMG
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         UseSizeScale=True
         UseRegularSizeScale=False
         SizeScale(0)=(RelativeSize=1.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         Texture=Texture'xPatchTex.FX.MuzzleMinigun'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         BlendBetweenSubdivisions=True
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.025000,Max=0.075000)
         VelocityLossRange=(Z=(Min=5.000000,Max=5.000000))
         Name="SpriteEmitterMG"
     End Object
	 Emitters(0)=SpriteEmitter'FX2.SpriteEmitterMG'
     AutoDestroy=True
}
