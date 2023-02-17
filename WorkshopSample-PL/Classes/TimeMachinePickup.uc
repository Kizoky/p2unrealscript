///////////////////////////////////////////////////////////////////////////////
// TimeMachinePickup
// 2015, Rick F.
//
// Technically we don't need a pickup because it's granted directly to the
// player and can't be dropped or stolen, but here it is anyway, Just In Case.
///////////////////////////////////////////////////////////////////////////////
class TimeMachinePickup extends OwnedPickup;

defaultproperties
{
     bAutoActivateOnce=false
     InventoryType=class'TimeMachineInv'
     PickupMessage="You picked up a Time Machine!"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'PL-InteriorMeshes.Props_Wall.Wallclock_01'
}
