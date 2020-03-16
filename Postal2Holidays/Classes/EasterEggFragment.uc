/**
 * EasterEggFragment
 *
 * Unfortunately it turns out that setting a skin for a particle in MeshEmitter
 * doesn't quite work, as a result, I had to go the more expensive route and
 * just make the two fragments an Actor
 */
class EasterEggFragment extends Actor;

var float BreakVelocity;
var float FragmentLifespan;

function InitializeFragment(StaticMesh FragmentMesh, Material FragmentSkin) {
    SetStaticMesh(FragmentMesh);
    Skins[0] = FragmentSkin;

    SetPhysics(PHYS_Falling);

    Velocity.X = FRand() * BreakVelocity - FRand() * BreakVelocity;
    Velocity.Y = FRand() * BreakVelocity - FRand() * BreakVelocity;
    Velocity.Z = BreakVelocity;

    Lifespan = FragmentLifespan;
}

defaultproperties
{
    BreakVelocity=400
    FragmentLifespan=2

    DrawType=DT_StaticMesh

    Skins[0]=none;

    bFixedRotationDir=true
    RotationRate=(Pitch=65535,Yaw=65535,Roll=65535)
}