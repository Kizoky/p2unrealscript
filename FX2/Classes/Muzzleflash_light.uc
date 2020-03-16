//////////////////////////////////////////////////////////////////////
// 12/2/13 MrD	- New MuzzleFlash to replace old staticmesh ones... //
//////////////////////////////////////////////////////////////////////
class Muzzleflash_light extends Light;


function tick(float deltatime){



  
  self.LightBrightness -= 20.0;
  if (self.LightBrightness <= 0)
     self.Destroy();

}

defaultproperties
{
     bStatic=False
     bNoDelete=False
     bDynamicLight=True
     RemoteRole=ROLE_SimulatedProxy
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     LightBrightness=128.000000
     LightHue=42
     LightSaturation=127
     LightRadius=25.000000
     LightPeriod=100
     bDirectional=True
}
