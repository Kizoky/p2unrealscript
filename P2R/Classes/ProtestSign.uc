//=============================================================================
// ProtestSign 1rst Attactment. - MrD
//=============================================================================
class ProtestSign extends Actor;

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

     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Timb_mesh.picket_timb.picket_timb'
	 Skins(0)=Texture'Timb.picket.protest19'
     DrawScale=0.7
}
