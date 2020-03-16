///////////////////////////////////////////////////////////////////////////////
// Baton attachment for 3rd person
///////////////////////////////////////////////////////////////////////////////
class DustersAttachment extends FistsAttachment;

var DustersSecondAttachment TwinDusters;

function PostBeginPlay()
{
	TwinDusters = Spawn(Class'DustersSecondAttachment');
	Instigator.AttachToBone(TwinDusters, 'MALE01 L Hand');

	Super.PostBeginPlay();
}

event Destroyed()
{
	if( TwinDusters != None )
	{
		Instigator.DetachFromBone(TwinDusters);
		TwinDusters.Destroy();
		TwinDusters = None;
	}
	
	Super.Destroyed();
}

defaultproperties
{
//	DrawType=DT_StaticMesh
//	StaticMesh=StaticMesh'ED_Weapons.Dusters3rdMesh'
	DrawType=DT_Mesh
	Mesh=Mesh'ED_Weapons.Dusters3rdMesh'
	DrawScale=0.95
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	FiringMode="FISTS"
	WeapClass=class'DustersWeapon'
}
