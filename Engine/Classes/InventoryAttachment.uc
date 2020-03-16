class InventoryAttachment extends Actor
	native
	nativereplication;

function InitFor(Inventory I)
{
	SetDrawScale(I.ThirdPersonScale);
	if ( I.ThirdPersonMesh != None )
		LinkMesh(I.ThirdPersonMesh);
	else if ( I.ThirdPersonStaticMesh != None )
	{
		SetStaticMesh(I.ThirdPersonStaticMesh);
		SetDrawType(DT_StaticMesh);
		SetDrawScale(DrawScale);
	}
	Instigator = I.Instigator;
}
		
defaultproperties
{
	DrawType=DT_Mesh
	RemoteRole=ROLE_SimulatedProxy
	bAcceptsProjectors=True
	bUseLightingFromBase=True
	CullDistance=5000.0
}