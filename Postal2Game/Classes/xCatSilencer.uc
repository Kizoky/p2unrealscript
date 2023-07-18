//=============================================================================
// Man Chrzan: xPatch
// Cat Silencer that we can attach to the CatableWeapon and P2WeaponAttachment.
//=============================================================================
class xCatSilencer extends Actor
    placeable;
 
var MeshAnimation MyAnims;
var bool bInitialized;
var() bool bStateControl;
var() Name IdleAnim;

simulated event Tick(float Delta)
{
	//log(Self@"Tick("$Delta$")");
	if (bInitialized)
		Disable('Tick');
	else
		Initialize();
}

simulated function Initialize()
{
	//log(Self@"Initialize()");
	LinkSkelAnim(MyAnims);
	PlayIdleAnim();
	bInitialized=True;
}

function PlayIdleAnim()
{
	LoopAnim(IdleAnim);
}

event AnimEnd(int Channel)
{
	Super.AnimEnd(Channel);
	if( !bStateControl )
		PlayIdleAnim();
}

defaultproperties
{
	RemoteRole=ROLE_None
	bCollideActors=false
	bCollideWorld=false
	bBlockActors=false
	bBlockKarma=false
	bBlockPlayers=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bProjTarget=false
	
	IdleAnim="idle_mg"
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'Nicks_CatSilencer.Nicks_CatSilencer'
    MyAnims=MeshAnimation'Nicks_CatSilencer.nicks_cat_silencer_anim'
    DrawScale=1.0 
}
