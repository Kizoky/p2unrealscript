class PL_DildoAttachment extends P2WeaponAttachment;

var PL_Dildo_JellyAttachment Jelly;

function PostBeginPlay()
{
	Jelly = Spawn(Class'PL_Dildo_JellyAttachment');
	Instigator.AttachToBone(Jelly, 'MALE01 L Hand');

	Super.PostBeginPlay();
}

event Destroyed()
{
	if( Jelly != None )
	{
		Instigator.DetachFromBone(Jelly);
		Jelly.Destroy();
		Jelly = None;
	}
	
	Super.Destroyed();
}

defaultproperties
{
     WeapClass=Class'PL_DildoWeapon'
     FiringMode="BATON1"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MrD_PL_Mesh.Weapons.GimpsDildo'
}
