// Valentines Vase Inventory
// Dummy inventory item for valentines day interaction
// Not an actual pickup! Do not place in levels!
class VasePickup extends P2PowerupPickup
	notplaceable;

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'ValentineMesh.Bolton.RosesBunch'
	bNoReorientHandOver=true
}