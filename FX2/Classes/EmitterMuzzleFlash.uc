//////////////////////////////////////////////////////////////////////
// 12/2/13 MrD	- New MuzzleFlash to replace old staticmesh ones... //
//////////////////////////////////////////////////////////////////////
class EmitterMuzzleFlash extends MuzzleFlashAttachment;

var class<Emitter> ThirdPersonMuzzleFlashClass;


simulated function DrawEmitter()
{
	local vector StartTrace, FireDirection;
	local Actor TempEffect;


    StartTrace = GetBoneCoords('flash01').Origin;
    FireDirection = GetBoneCoords('flash01').XAxis; 

	if(ThirdPersonMuzzleFlashClass != None)
	{
		TempEffect = Spawn(ThirdPersonMuzzleFlashClass,,,StartTrace,Rotator(FireDirection));
		Emitter(TempEffect).AutoDestroy = true;
		AttachToBone(TempEffect,'flash01');
	}
}


simulated function Flash()
{
	DrawEmitter();
	//SpawnLight();
	GotoState('Visible');
}

simulated state Visible
{

	simulated event Tick(float Delta)
	{
		if(TickCount>2)
			gotoState('');
		TickCount++;
	}

	simulated function EndState()
	{
		//STUB
	}

	simulated function BeginState()
	{
		local Rotator R;
		TickCount=0;
		R = RelativeRotation;
		R.Roll = Rand(65535);
		SetRelativeRotation(R);
	}
}

defaultproperties
{
     ThirdPersonMuzzleFlashClass=Class'MuzzleFlash03'
     bHidden=False
	 Mesh=SkeletalMesh'AW_Heads.AW_Fraud'
     DrawScale=0.000001
     Skins(0)=Shader'Timb.Misc.invisible_mask'
}
