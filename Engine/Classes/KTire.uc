class KTire extends KActor
    native
    abstract;

var KCarWheelJoint  WheelJoint;         // joint holding this wheel to chassis etc.

// TYRE MODEL

// FRICTION
var float           RollFriction;       // friction coeff. in tyre direction
var float           LateralFriction;    // friction coeff. in sideways direction

// SLIP
// slip = min(maxSlip, minSlip + (slipRate * angular vel))
var float           RollSlip;           // max first-order (force ~ vel) slip in tyre direction
var float           LateralSlip;        // max first-order (force ~ vel) slip in sideways direction
var float           MinSlip;            // minimum slip (both directions)
var float           SlipRate;           // amount of extra slip per unit velocity

// NORMAL
var float           Softness;           // 'softness' in the normal dir
var float           Adhesion;           // 'stickyness' in the normal dir
var float           Restitution;        // 'bouncyness' in the normal dir

// Other Output information
var const float     GroundSlipVel;      // relative tangential velocity of wheel against ground (0 for static, >0 for slipping)
                                        // could use this to trigger squeeling noises/smoke
var const vector	GroundSlipVec;		// full vector version of above (ie GroundSlipVel is magnitude of this vector).

var const float     SpinSpeed;          // current speed (65535 = 1 rev/sec) of this wheel spinning about its axis

defaultproperties
{
    RollFriction=0.3
    LateralFriction=0.3

    RollSlip=0.085
    LateralSlip=0.06
    MinSlip=0.001
    SlipRate=0.0005

    Softness=0.0002
    Restitution=0.1
    Adhesion=0

	bDisturbFluidSurface=true
}