//=============================================================================
// MrDTNade.
//=============================================================================
class MrDKNade extends Actor
    placeable;
 
var() enum ActionType
{
	AT_None,
	AT_OnBed,
	AT_Stand,
	AT_Dance
} MyAction;

const BLEND_TIME = 0.4;

var Sound CheerSound;
var MeshAnimation MyAnims;
var bool bInitialized;

simulated function PlayCheer()
{
	PlayAnim(GetAnimCheer(), 1.0, BLEND_TIME);

	// Make some body-grinding, moaning noises
	if(Level.NetMode != NM_DedicatedServer)
	{
									// pitch them slightly around
		PlaySound(CheerSound,,1.0,,,0.8+Frand()*0.4,true);
	}
}

simulated function name GetAnimCheer()
{
	local int rnd;

	rnd = Rand(3);
	switch(rnd)
	{
	case 0:
		return 's_base1';
		break;
	case 1:
		return 's_base1';
		break;
	case 2:
		return 's_base1';
		break;
	}
}


simulated event AnimEnd(int Channel)
{
	//log(Self@"AnimEnd");
	if (MyAction == AT_OnBed)
	{
		//log(Self@"PlayAnim 's_base1'");
		if (FRand() < 0.8)
			PlayAnim('s_base1');
		else
			PlayAnim('s_base1');
	}
	if (MyAction == AT_Dance)
	{
		//log(Self@"cheer");
		PlayCheer();
	}
}

simulated function Initialize()
{
	//log(Self@"Initialize()");
	LinkSkelAnim(MyAnims);
	if (MyAction == AT_OnBed)
	{
		//log(Self@"PlayAnim 's_base1'");
		PlayAnim('s_base1');
	}
	if (MyAction == AT_Stand)
	{
		//log(Self@"LoopAnim 'dropped'");
		loopanim('dropped');
		SimAnim.bAnimLoop = True;
	}
	if (MyAction == AT_Dance)
	{
		//log(Self@"PlayCheer");
		PlayCheer();
	}
	bInitialized=True;
}

simulated event Tick(float Delta)
{
	//log(Self@"Tick("$Delta$")");
	if (bInitialized)
		Disable('Tick');
	else
		Initialize();
}

defaultproperties
{
	// Change by NickP: MP fix
	RemoteRole=ROLE_None
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockKarma=false
	bBlockPlayers=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bProjTarget=false
	// End

     MyAction=AT_OnBed
     MyAnims=MeshAnimation'P2R_Anims_D.Weapons.animKrotchy'
     bClientAnim=True
     //RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'P2R_Anims_D.Weapons.Krotchy'
     DrawScale=0.155
}
