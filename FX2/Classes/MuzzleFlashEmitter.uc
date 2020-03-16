//////////////////////////////////////////////////////////////////////
// 12/2/13 MrD	- New MuzzleFlash to replace old staticmesh ones... //
//////////////////////////////////////////////////////////////////////
class MuzzleFlashEmitter extends P2Emitter abstract;

/*var int TickCounter;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	bDynamicLight = true;
	LightBrightness = 150;
	LightSaturation = 180;
	LightHue = 12 + FRand() * 15;
	LightRadius = 16 + FRand() * 16;
	LightType = LT_Steady;
	LightEffect = LE_NonIncidence;
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if(TickCounter > 4)
	{
		if(LightBrightness > 0)
			LightBrightness -= 50;
	}
	else
		TickCounter++;
}*/

defaultproperties
{
	//ErikFOV Change: For Nick's coop replication
	RemoteRole=ROLE_None
	//End
}
