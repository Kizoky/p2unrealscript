// Kickable Actor
// KActor with some useful defaults set for new LD's.
class KickableActor extends KActor;

defaultproperties
{
	StaticMesh=StaticMesh'Timb_mesh.home.dinner_chair2_timb'
    ImpactSounds(0)=Sound'MiscSounds.Props.woodhitsground1'
    ImpactSounds(1)=Sound'MiscSounds.Props.woodhitsground2'
    Begin Object Class=KarmaParams Name=KarmaParamsDefault
        KMass=1.5
        bKAllowRotate=True
        KFriction=1.000000
        Name="KarmaParamsDefault"
    End Object
    KParams=KarmaParams'KarmaParamsDefault'
}