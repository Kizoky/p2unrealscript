/**
 * MountedWeaponMuzzleFlashEmitter
 *
 * A Muzzle Flash Emitter to be used with a mounted weapon. Performance wise
 * it's better since we only use one Emitter and pretty efficient code wise as
 * we only need to tell the Particle to spawn a particle, rather than an object
 */
class MountedWeaponMuzzleFlashEmitter extends PLPersistantEmitter;

defaultproperties
{
    Begin Object class=MeshEmitter name=MeshEmitter0
        CoordinateSystem=PTCS_Relative
        UseRotationFrom=PTRS_Actor
        StaticMesh=StaticMesh'Timb_mesh.muzzle_flashes.mf_shotgun'
        DampingFactorRange=(X=(Min=0.5,Max=0.5),Y=(Min=0.5,Max=0.5),Z=(Min=0.5,Max=0.5))
        MaxParticles=1000
        RespawnDeadParticles=false
        SpinParticles=true
        StartSpinRange=(Z=(Max=1))
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=2)
        SizeScale(1)=(RelativeTime=1,RelativeSize=4)
        InitialParticlesPerSecond=0
        AutomaticInitialSpawning=false
        DrawStyle=PTDS_Regular
        SecondsBeforeInactive=0
        LifetimeRange=(Min=0.1,Max=0.1)
        Name="MeshEmitter0"
    End Object
    Emitters(0)=MeshEmitter'PLFX.MeshEmitter0'

    AmbientGlow=254
}