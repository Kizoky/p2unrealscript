class Vehicle extends Pawn
	abstract
	native;

var class<VehiclePart> PartClass[16];
var VehiclePart VehicleParts[16];
var vector PartOffset[16];
var int NumParts;

var bool bActivated;
var bool bUpdating;		// true if any parts are updating

function PostBeginPlay()
{
	local int i;
	local vector RotX, RotY, RotZ;

	Super.PostBeginPlay();

	GetAxes(Rotation,RotX,RotY,RotZ);

	for ( i=0; i<16; i++ )
	{
		if ( PartClass[i] != None )
		{
			VehicleParts[i] = spawn(PartClass[i],self,,Location+PartOffset[i].X * RotX + PartOffset[i].Y * RotY + PartOffset[i].Z * RotZ);
			if ( VehicleParts[i] == None )
				log("WARNING - "$PartClass[i]$" failed to spawn for "$self);
			VehicleParts[i].SetRotation(Rotation);
			VehicleParts[i].SetBase(self);
			NumParts++;
		}
		else
			break;
	}
}

/* PointOfView()
called by controller when possessing this vehicle
true (3rd person) for vehicles by default
*/
simulated function bool PointOfView()
{
	return true;
}

function Tick(Float DeltaTime)
{
	local int i;
	
	bUpdating = false;
	for ( i=0; i<NumParts; i++ )
		if ( (VehicleParts[i] != None) && VehicleParts[i].bUpdating )
		{
			VehicleParts[i].Update(DeltaTime);
			bUpdating = true;
		}

	if ( bUpdating )
	{
		if ( Physics == PHYS_None )
			SetPhysics(PHYS_Rotating);
	}
//	else if ( Physics == PHYS_Rotating )
//		SetPhysics(PHYS_None);
}

Auto State Startup
{
	function Tick(Float DeltaTime)
	{
		local int i;
		
		bUpdating = false;
		for ( i=0; i<NumParts; i++ )
			if ( (VehicleParts[i] != None) && VehicleParts[i].bUpdating )
			{
				VehicleParts[i].Update(DeltaTime);
				bUpdating = true;
			}
	}

Begin:
	GotoState('');
}

defaultproperties
{
	physics=PHYS_Flying
	bOwnerNoSee=false
	ControllerClass=None
}