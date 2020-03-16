class Strippers extends Actor
	placeable
	hidecategories(Force,Karma,LightColor,Lighting,Shadow);

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
		return 's_cheer1';
		break;
	case 1:
		return 's_cheer2';
		break;
	case 2:
		return 's_cheer3';
		break;
	}
}

simulated event AnimEnd(int Channel)
{
	//log(Self@"AnimEnd");
	if (MyAction == AT_OnBed)
	{
		//log(Self@"PlayAnim 'home'");
		if (FRand() < 0.8)
			PlayAnim('home');
		else
			PlayAnim('home2');
	}
	if (MyAction == AT_Dance)
	{
		//log(Self@"PlayCheer");
		PlayCheer();
	}
}

simulated function Initialize()
{
	//log(Self@"Initialize()");
	LinkSkelAnim(MyAnims);
	if (MyAction == AT_OnBed)
	{
		//log(Self@"PlayAnim 'home'");
		PlayAnim('home');
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
	bStatic=False
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'MP_Strippers.MP_PostalBabe_Jeans'
	bClientAnim=True
	MyAction=AT_OnBed
	RemoteRole=ROLE_SimulatedProxy
	CheerSound=Sound'AmbientSounds.phoneSex'
	MyAnims=MeshAnimation'MP_Strippers.anim_StripperMP'
}
