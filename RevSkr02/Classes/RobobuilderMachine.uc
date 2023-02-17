//=============================================================================
// RobobuilderMachine.
//=============================================================================
class RobobuilderMachine extends Actor
	placeable;

var FactoryGarbage CorpActor;
Var () float BuildTime;
var () Vector ResultLocation;
var () int BuildMode;
var () StaticMesh SM1;

function Trigger( actor Other, pawn EventInstigator )
{
 If(FactoryGarbage(Other) != none)
 {
  CorpActor = FactoryGarbage(Other);
  If(CorpActor.AttachmentH != none) CorpActor.AttachmentH.Destroy();
  AttachToBone( CorpActor, CorpActor.AttachAliasH );
  if(BuildMode == 0)
  {
   PlayAnim('HandsAdd');
  }
  else if(BuildMode == 1)
  {
   PlayAnim('HeadAdd');
  }
  else if(BuildMode == 2)
  {
   PlayAnim('WhellAdd');
  }
  SetTimer(BuildTime,false);
 }
}

function Timer()
{
 If(CorpActor != none)
 {
  if(BuildMode == 0)
  {
   PlayAnim('HandsAdd');
  }
  else if(BuildMode == 1)
  {
   PlayAnim('HeadAdd');
  }
  else if(BuildMode == 2)
  {
   PlayAnim('WhellAdd');
  }
  StopAnimating();
  DetachFromBone(CorpActor);
  CorpActor.SetLocation(Location+ResultLocation);
  CorpActor.AttachmentH = Spawn(class 'Prop',,,CorpActor.location,CorpActor.Rotation);
  CorpActor.AttachmentH.SetCollision(false,False,False);
  CorpActor.AttachmentH.SetDrawType(DT_StaticMesh);

  if(BuildMode == 0)
  {
  CorpActor.AttachmentH.SetStaticMesh(SM1);
  CorpActor.AttachmentH.SetBase(CorpActor);
  }
  else if(BuildMode == 1)
  {
 // CorpActor.AttachmentH.SetStaticMesh(StaticMesh'RevRobofactMOD.RoboM');
 // CorpActor.AttachmentH.SetBase(CorpActor);
  }
  else if(BuildMode == 2)
  {
 // CorpActor.AttachmentH.SetStaticMesh(StaticMesh'RevRobofactMOD.RoboS');
 // CorpActor.AttachmentH.SetBase(CorpActor);
  }


  CorpActor = none;
 }
}

defaultproperties
{
     BuildTime=11.000000
     ResultLocation=(X=-26.449162,Y=160.000000,Z=39.815117)
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'RevRobofactoryAnims.Robobuilder'
     bEdShouldSnap=True
	 SM1=StaticMesh'RevRobofactMOD.RoboH'
}
