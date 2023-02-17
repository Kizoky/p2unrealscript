class GaryDummy extends Actor
	placeable;
	
var BodyPart MyHead;
	
event PostBeginPlay()
{
	PlayAnim('g_idle_1');
	MyHead = spawn(class'PLGary'.Default.HeadClass,self,,Location,,class'PLGary'.Default.HeadSkin);
	MyHead.LinkMesh(class'PLGary'.Default.HeadMesh);
	MyHead.AmbientGlow = AmbientGlow;
	AttachToBone(myHead, 'MALE01 head');
	myHead.SetRelativeRotation(rot(0,-16384,16384));
	myHead.SetRelativeLocation(vect(-0.8,0,0));
}
	
defaultproperties
{
	ActorID="PLGary"

	Mesh=SkeletalMesh'PLCharacters.Mini_M_Jacket_Pants'
	Skins[0]=Texture'ChameleonSkins.Special.Gary'
	DrawType=DT_Mesh
	AmbientGlow=30
}