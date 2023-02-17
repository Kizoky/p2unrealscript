///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class Gary_Stilts extends Gary;

defaultproperties
{
	ActorID="PLGary"

	Skins[0]=Texture'shockingextra.aluminum'	
	Skins[1]=Texture'ChameleonSkins.Special.Gary'
	Skins[2]=Texture'shockingextra.stiltskin'
	Mesh=SkeletalMesh'PLshockingExtras.GaryStiltWar'
	BlockMeleeFreq=0.90
	Beg=0
	PainThreshold=0.95
	Cajones=0.95
	Rebel=0.9
	WillDodge=0.85
	WillKneel=0.55
	WillUseCover=0.85
	Stomach=0.8
	CharacterType=CHARACTER_avgdude
	CoreMeshAnim=MeshAnimation'Characters.animAvg'
	PeeBody=class'UrineBodyDrip'
	GasBody=class'GasBodyDrip'
	bNoDismemberment=true
    AW_SPMeshAnim=MeshAnimation'AWCharacters.animAvg_AW'
	ExtraAnims(0)=MeshAnimation'AW7Characters.animAvg_AW7'
	HEAD_RATIO_OF_FULL_HEIGHT=0.5
	TakesShotgunHeadShot=0.1
}
