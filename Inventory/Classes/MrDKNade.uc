//=============================================================================
// MrDTNade.
// xPatch Edit: Removed unnecessary stuff
//=============================================================================
class MrDKNade extends Actor
    placeable;
 
var MeshAnimation MyAnims;
var bool bInitialized;
var float FreezeFrame;

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
	// You know what... let's freeze it 
	// Krotchy doll being "alive" looks freaky as heck.
	// Plus it clips through the pin... bleh.
//	LoopAnim('s_base1');
	PlayAnim('s_base1');
	FreezeAnimAt(FreezeFrame);
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

     //MyAction=AT_OnBed
     MyAnims=MeshAnimation'P2R_Anims_D.Weapons.animKrotchy'
     bClientAnim=True
     //RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'P2R_Anims_D.Weapons.Krotchy'
     DrawScale=0.155
	 
	 FreezeFrame=7
}
