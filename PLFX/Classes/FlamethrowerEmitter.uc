/**
 * FlamethrowerEmitter
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Base for flamethrower Emitters. Here we implement basic variables for a
 * flamethrower such as the range, angle, and damage rate.
 *
 * @author Gordon Cheng
 */
class FlamethrowerEmitter extends P2Emitter;

var float Range, Angle, DamageRate;
var float FireRingInterval, FireRingMinDistance, FireRingFlatGround;

var class<DamageType> ContinuousDamageType;
var class<DamageType> FireDamageType;
var class<FireStarterRing> FireRingClass;

var float DamageStack;
var array<vector> FireRingLocations;

/** Overriden so we can check periodically for a location to create a fire ring */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    SetTimer(FireRingInterval, true);
}

/** Returns whether or not the given fire ring location is far enough away
 * from other fire rings
 * @param FireRingLocation - Possible new location for a fire ring
 * @return TRUE if the new fire ring location is far enough away from others
 *         FALSE otherwise
 */
function bool IsValidFireRingLocation(vector FireRingLocation) {
    local int i;

    for (i=0;i<FireRingLocations.length;i++)
        if (VSize(FireRingLocation - FireRingLocations[i]) <= FireRingMinDistance)
            return false;

    return true;
}

/** Returns whether or not the given normal is flat enough for a fire ring to spawn
 * @param Normal - Normal vector of the ground
 * @return TRUE if the normal vector is pointing up enough; FALSE otherwise
 */
function bool IsFlatGround(vector Normal) {
    return (Normal.Z >= FireRingFlatGround);
}

/** Adds a vector location into our list of fire ring locations
 * @param FireRingLocation - Location in the world where a fire ring spawned at
 */
function AddFireRingLocation(vector FireRingLocation) {
    FireRingLocations.Insert(FireRingLocations.length, 1);
    FireRingLocations[FireRingLocations.length-1] = FireRingLocation;
}

/** Empties the Flamethrower fire ring locations list */
function EmptyFireRingList() {
    while (FireRingLocations.length > 0)
        FireRingLocations.Remove(0, 1);
}

/** Overriden so we can implement a periodic fire ring check */
function Timer() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    local vector FireRingLocation;
    local FireStarterRing FireRing;

    StartTrace = Location;
    EndTrace = StartTrace + vector(Rotation) * Range;
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

    if (Other != none && FireRingClass != none && IsFlatGround(HitNormal)) {
        FireRingLocation = HitLocation + HitNormal * 2;

        if (IsValidFireRingLocation(FireRingLocation))
            FireRing = Spawn(FireRingClass, Owner,, FireRingLocation);

        if (FireRing != none)
            AddFireRingLocation(FireRingLocation);
    }
}

/** Overriden so we can implement the flamethrower's angle of damage */
event Tick(float DeltaTime) {
    local float MinAngle;
    local vector TargetDir;

    local Actor Other;

    DamageStack += DeltaTime * DamageRate;

	if (DamageStack >= 1.0)
	{
		foreach VisibleCollidingActors(class'Actor', Other, Range) {
			TargetDir = Normal(Other.Location - Location);
			MinAngle = 1 - Angle / 180;

			// NOTE: TakeDamage takes an integer, unless a player's computer is
			// insanely slow, our DeltaTime * DamageRate will usually be casted
			// into a 0 int. So we use a damage accumulator instead to deal
			// a minimum of 1 damage
			if (TargetDir dot vector(Rotation) >= MinAngle) {
				if (FPSPawn(Other) != none && FPSPawn(Other).MyBodyFire == none)
					Other.TakeDamage(int(DamageStack), Pawn(Owner), Other.Location, vect(0,0,0), FireDamageType);
				else
					Other.TakeDamage(int(DamageStack), Pawn(Owner), Other.Location, vect(0,0,0), ContinuousDamageType);
			}
		}
	}

    if (DamageStack > 1.0)
        DamageStack = DamageStack % 1;
}

state DieOut
{
	event BeginState()
	{
		local int i;
		
		for (i = 0; i < Emitters.Length; i++)
			Emitters[i].ParticlesPerSecond=0;
			
		AutoDestroy=true;
		FireRingInterval=0;
		DamageRate=0;
	}
}

defaultproperties
{
    Begin Object class=SpriteEmitter name=SpriteEmitter0
        Acceleration=(Z=100)
        UseColorScale=true
        ColorScale(0)=(color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.5,color=(G=255,R=255))
        ColorScale(2)=(RelativeTime=0.7,color=(G=128,R=255))
        FadeOutStartTime=0.8
        FadeOut=true
        MaxParticles=500
        RespawnDeadParticles=false
        UseRotationFrom=PTRS_Actor
        SpinParticles=true
        UseSizeScale=true
        UseRegularSizeScale=false
        SizeScale(0)=(RelativeSize=0.1)
        SizeScale(1)=(RelativeTime=1,RelativeSize=1.5)
        StartSizeRange=(X=(Min=25,Max=60),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
        ParticlesPerSecond=200
        InitialParticlesPerSecond=200
        AutomaticInitialSpawning=false
        Texture=Texture'nathans.Skins.firegroup2'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=true
        SecondsBeforeInactive=0
        LifetimeRange=(Min=1.5,Max=2)
        StartVelocityRange=(X=(Min=500,Max=750),Y=(Min=-75,Max=75),Z=(Min=-75,Max=75))
        Name="SpriteEmitter0"
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    FireDamageType=class'BurnedDamage'
    ContinuousDamageType=class'P2Damage'
    FireRingClass=class'DynamicFireStarterRing'

    AutoDestroy=true
}