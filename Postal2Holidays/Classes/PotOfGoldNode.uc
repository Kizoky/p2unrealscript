/**
 * PotOfGoldNode
 *
 * A PathNode placed preferably in a corner of the map is notifed by Leprechaun
 * Gary when he has seen the Postal Dude so that it'll spawn a Pot of Gold.
 */
class PotOfGoldNode extends PathNode;

/** Distance from the ground to move the pot of gold up */
var float PotOfGoldGroundOffset;

/** Spawns a pot of gold on the ground for Leprechaun Gary to jump into
 * @return PotOfGold object that the LeprechaunController can reference
 */
function PotOfGold SpawnPotOfGold() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;
    local PotOfGold PotOfGold;

    StartTrace = Location;
    EndTrace = StartTrace + vect(0,0,-1024);
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none) {
        HitLocation.Z += PotOfGoldGroundOffset;
        PotOfGold = Spawn(class'PotOfGold',,, HitLocation);
    }

    return PotOfGold;
}

defaultproperties
{
    PotOfGoldGroundOffset=0.0f

    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'StPatricksMesh.potofgold_state01'
}