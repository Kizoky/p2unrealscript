// Generic 'Karma Vehicle' base class that can be controlled by a Pawn.

class KVehicle extends Pawn
    native
    abstract;

// generic controls (set by controller, used by concrete derived classes)
var (KVehicle) float    Steering; // between -1 and 1
var (KVehicle) float    Throttle; // between -1 and 1


var (KVehicle) int      CamPosIndex;  // Current viewpoint in this vehicle (see arrays below).
                                      // Can't use bBehindView because we always want to render the vehicle.

var (KVehicle) const    plane    CamPos[4];    // set of viewpoints around the car. 
                                      // (x,y,z) represesnts camera position in vehicle space.
                                      // w represents distance to orbit about that point.

var			   Pawn     Driver;

var (KVehicle) vector	ExitPos;		// Position (rel to vehicle) to put player on exiting.
var (KVehicle) rotator	ExitRot;		// Rotation (rel to vehicle) to put player on exiting.

var (KVehicle) vector	DrivePos;		// Position (rel to vehicle) to put player while driving.
var (KVehicle) rotator	DriveRot;		// Rotation (rel to vehicle) to put driver while driving.

// Simple 'driving-in-rings' logic.
var (KVehicle) bool		bAutoDrive;

var (KVechile) bool		bLookSteer;		// Indicates how if vehicle should steer towards where you are looking,
										// or whether strafe keys steer vehicle, and looking is free.
var (KVehicle) float	LookSteerSens;	// Sensitivity of steering as you look left around

// Useful function for plotting data to real-time graph on screen.
native final function GraphData(string DataName, float DataValue);

// As with KActor, shooting a vehicle applies an impulse
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
    KAddImpulse(momentum, hitlocation);
}

// Vehicles dont get telefragged.
event EncroachedBy( actor Other )
{
	Log("KVehicle("$self$") Encroached By: "$Other$".");
}

// Called when a parameter of the overall articulated actor has changed (like PostEditChange)
// The script must then call KUpdateConstraintParams or Actor Karma mutators as appropriate.
event KVehicleUpdateParams();

// The pawn Driver has tried to take control of this vehicle
function TryToDrive(Pawn p)
{
	local Controller C;
	C = p.Controller;

    if ( (Driver == None) && (C != None) && C.bIsPlayer && !C.IsInState('PlayerDriving') && p.IsHumanControlled() )
	{        
		KDriverEnter(p);
    }
}

// Events called on driver entering/leaving vehicle

event KDriverEnter(Pawn p)
{
	local PlayerController pc;

    log("Entering Vehicle");

	// Set pawns current controller to control the vehicle pawn instead
	Driver = p;

	pc = PlayerController(p.Controller);
	pc.Unpossess();
	pc.Possess(self);

	// Change controller state to driver
    pc.GotoState('PlayerDriving');

	// Move the driver into position, and attach to car.
	Driver.SetCollision(false, false, false);
	Driver.bCollideWorld = false;
	//Driver.SetLocation(Location + (DrivePos >> Rotation));
	//Driver.SetRotation(Rotation + DriveRot);
	Driver.bPhysicsAnimUpdate = false;
	Driver.Velocity = vect(0,0,0);
	Driver.SetPhysics(PHYS_None);
	Driver.SetBase(self);
}

// Called from the PlayerController when player wants to get out.
event KDriverLeave()
{
	local PlayerController pc;

    log("Leaving Vehicle");

	// Do nothing if we're not being driven
	if(Driver == None)
		return;

	// Set the vehicle controller to now control the player
	pc = PlayerController(Controller);
	pc.Unpossess();
	pc.Possess(Driver);

	// Place the driver outside the car
	Driver.PlayWaiting();
	Driver.bPhysicsAnimUpdate = Driver.Default.bPhysicsAnimUpdate;

    Driver.Acceleration = vect(0, 0, 24000);
	Driver.SetPhysics(PHYS_Falling);
	Driver.SetBase(None);
	Driver.bCollideWorld = true;
	Driver.SetCollision(true, true, true);
	Driver.SetLocation(Location + (ExitPos >> Rotation));


//	Driver.SetRotation(Rotation + ExitRot);

	// Car now has no driver
	Driver = None;

	// Put brakes on before you get out :)
    Throttle=0;
    Steering=0;
}

// Includes properties from KActor
defaultproperties
{
    Steering=0
    Throttle=0

	ExitPos=(X=0,Y=0,Z=0)
	ExitRot=()

	DrivePos=(X=0,Y=0,Z=0)
	DriveRot=()

	CamPosIndex=2

	bLookSteer = true
	LookSteerSens = 0.0001

    Physics=PHYS_Karma
	bEdShouldSnap=True
	bStatic=False
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=False
    bProjTarget=True
	bBlockActors=True
	bBlockNonZeroExtentTraces=True
	bBlockZeroExtentTraces=True
	bBlockPlayers=True
	bWorldGeometry=False
	bBlockKarma=True
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bAcceptsProjectors=True
	bCanBeBaseForPawns=True
}