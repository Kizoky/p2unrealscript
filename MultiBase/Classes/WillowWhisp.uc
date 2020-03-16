class WillowWhisp extends Emitter;

var		vector		WayPoints[17];
var		int			NumPoints;
var		int			Position;
var		float		Sleeptime;

function PostBeginPlay()
{
	local int i;
	local Controller C;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;
	Super.PostBeginPlay();

	C = Pawn(Owner).Controller;
	SetLocation(Owner.Location);

	WayPoints[0] = Owner.Location + 200 * vector(C.Rotation);
	HitActor = Trace(HitLocation, HitNormal,WayPoints[0], Owner.Location,false);
	if ( HitActor != None )
		WayPoints[0] = HitLocation;
	NumPoints++;
	for ( i=0; i<16; i++ )
	{
		if ( C.RouteCache[i] == None )
			break;
		else
		{
			WayPoints[NumPoints] = C.RouteCache[i].Location;
			NumPoints++;
		}
	}
	StartNextPath();
}

function bool StartNextPath()
{
	if ( Position == NumPoints )
		return false;

	Velocity = 1000 * Normal(WayPoints[Position] - Location);
	SetRotation(rotator(Velocity));
	SleepTime = VSize(WayPoints[Position] - Location)/1000;
	Position++;
	return true;
}

Auto State Pathing
{
Begin:
	Sleep(SleepTime);
	if ( StartNextPath() )
		Goto('Begin');
	Destroy();
}

defaultproperties
{
	bIgnoreOutOfWorld=true
	bCollideWorld=false
	physics=PHYS_Projectile
	bOnlyOwnerSee=true
	bNoDelete=false
	RemoteRole=ROLE_SimulatedProxy

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
		UseRotationFrom=PTRS_Actor
		AutomaticInitialSpawning=True
		InitialParticlesPerSecond=20
		ParticlesPersecond=20
		RespawnDeadParticles=true
		SecondsBeforeInactive=0
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.200000,Max=0.200000))
        FadeOutStartTime=1.000000
        FadeOut=True
        FadeInEndTime=0.00000
        FadeIn=True
        MaxParticles=50
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        DampRotation=True
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
        StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'S_Pawn'
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(Z=(Min=10.000000,Max=30.000000))
		StartLocationOffset=(X=0,Y=0,Z=0)
        Name="SpriteEmitter0"
    End Object
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
}