//=============================================================================
// Erik Rossik.
// Revival Games 2015.
// DrillMachine.
//=============================================================================
class DrillMachine extends PLMover;

var () bool Drilling;
var () float Drate, DMaxRate, DlastTime;


function Tick(float DeltaTime) {

    local Actor A;
  Super.Tick(DeltaTime);


  If(Drilling && Drate < DMaxRate && Level.Timeseconds > DlastTime + 0.1)
  {
   Drate += 0.05;
   LoopAnim('Drilling', Drate);
   DlastTime = Level.Timeseconds;
  }

If(Drilling)
{
ForEach radiusActors(class'Actor', A, collisionRadius)
{
 If(A != None && Pawn(A) != None)
 {
  A.TakeDamage( 10, Instigator, A.Location, vect(0,0,0), class'Crushed' );
 } 
}
}
}

function Trigger( actor Other, pawn EventInstigator )
{
 Drilling = True;
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'RevAnim.DrillMachine'
}
