/**
 * PotOfGoldBeacon
 *
 * The end of the rainbow that will show the player where the Pot of Gold is
 * and where Leprechaun Gary will be running toward
 */
class PotOfGoldBeacon extends Actor;

/** Whether or not the rainbow is gorwing */
var bool bInitializeRainbow;

/** Time in seconds since the rainbow has been initialized */
var float RainbowInitElapsedTime;
/** Time in seconds for the rainbow to extend vertically to it's height */
var float RainbowInitTime;

/** Rotation offset to add to the player direction */
var int RainbowRotationOffset;
/** Distance away from the rainbow will scale larger so the player can see */
var float RainbowGrowRadius;
/** Scale increase for every Unreal Unit the player is away from the beacon */
var float RainbowGrowRatio;

/** Pawn the player is currently using */
var Pawn Player;

/** Overriden to find the player */
simulated function PostBeginPlay() {
    local vector RainbowScale;

    super.PostBeginPlay();

    foreach DynamicActors(class'Pawn', Player)
        if (PlayerController(Player.Controller) != none)
            break;

    bInitializeRainbow = true;

    RainbowScale = DrawScale3D;
    RainbowScale.Z = 0.0f;

    SetDrawScale3D(RainbowScale);
}

/** Overriden to make the Pot of Gold Beacon always face the player */
event Tick(float DeltaTime) {
    local float DistToPlayer, RainbowScale;
    local vector RainbowScale3D;
    local rotator RainbowRotation;

    super.Tick(DeltaTime);

    if (Player != none) {
        RainbowRotation = rotator(Player.Location - Location);

        RainbowRotation.Pitch = 0;
        RainbowRotation.Yaw += RainbowRotationOffset;

        DistToPlayer = VSize(Player.Location - Location);
        RainbowScale = FMax(RainbowGrowRadius, DistToPlayer) / RainbowGrowRatio;

        SetRotation(RainbowRotation);
        SetDrawScale(RainbowScale);
    }

    if (bInitializeRainbow) {
        RainbowScale3D = default.DrawScale3D;
        RainbowInitElapsedTime = FMin(RainbowInitElapsedTime + DeltaTime,
                                      RainbowInitTime);

        RainbowScale3D.Z = default.DrawScale3D.Z *
                        (RainbowInitElapsedTime / RainbowInitTime);

        SetDrawScale3D(RainbowScale3D);

        if (RainbowInitElapsedTime == RainbowInitTime)
            bInitializeRainbow = false;
    }
}

defaultproperties
{
    RainbowInitTime=2.0f

    RainbowRotationOffset=16384
    RainbowGrowRadius=1024.0f
    RainbowGrowRatio=1024.0f

    bUnlit=true

    DrawType=DT_StaticMesh
    DrawScale3D=(Z=4.0f)
    StaticMesh=StaticMesh'StPatricksMesh.rainbow_beacon'

    Physics=PHYS_Rotating
    RotationRate=(Yaw=16384)
}