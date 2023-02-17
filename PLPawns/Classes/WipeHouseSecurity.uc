//=============================================================================
// Wipe House security guards
//
// Secret Service-like guys who take their job guarding toilet paper a bit
// too seriously.
//=============================================================================
class WipeHouseSecurity extends Bystander
	placeable;

state ConfusedByDanger
{
	function bool SayWhat()
	{
		return true;
	}
}

defaultproperties
{
	ActorID="WipeHouseSecurity"

	bIsTrained=True
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'Boltons_Package.Shades.Aviators_M',Skin=Shader'Boltons_Tex.Aviators_s',bAttachToHead=True)
	ChameleonSkins(0)="PLCharacterSkins.WipeHouseSecurity.MW__304__Avg_M_Jacket_Pants"
	ChameleonSkins(1)="PLCharacterSkins.WipeHouseSecurity.MB__305__Avg_M_Jacket_Pants"
	ChameleonSkins(2)="End"
	RandomizedBoltons(0)=None
	bCellUser=False
	Glaucoma=0.800000
	Psychic=0.150000
	Cajones=1.000000
	PainThreshold=1.000000
	Rebel=1.000000
	BaseEquipment(0)=(WeaponClass=Class'Inventory.PistolWeapon')
	ViolenceRankTolerance=1
	//bNoChamelBoltons=True // Broke dialog class assignments
	Gang="Lawmen"
	Mesh=SkeletalMesh'Characters.Avg_M_Jacket_Pants'
	Skins(0)=Texture'PLCharacterSkins.WipeHouseSecurity.XX__303__Avg_M_Jacket_Pants'
	AmbientGlow=30
}
