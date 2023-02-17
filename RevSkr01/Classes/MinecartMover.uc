//=============================================================================
// Erik Rossik.
// Revival Games 2014.
// MinecartMover.
//=============================================================================
class MinecartMover extends PLMover;

var () bool fixPhys;

function Tick(float DeltaTime) {
    local int i, BindOffset;
    local vector BindLocation;

    for (i=0;i<Riders.length;i++) {

        BindOffset = Clamp(i, 0, RiderBindOffsets.length-1);

        BindLocation = Location + class'P2EMath'.static.GetOffset(Rotation,
            RiderBindOffsets[BindOffset]);

        Riders[i].SetLocation(BindLocation);
        Riders[i].setbase(self);
       If(fixPhys) Riders[i].setPhysics(Phys_none);
        //Riders[i].Velocity.Z = 0;
    }
}

defaultproperties
{
     StaticMesh=StaticMesh'GCCMOD.minecart'
     bShadowCast=False
}
