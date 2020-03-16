class RotatingAttachment extends Prop;

simulated event Tick(float Delta)
{
	SetRotation(Rotation + RotationRate);
}

defaultproperties
{
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Editor.TexPropCube'
	RotationRate=(Yaw=3000)
}
