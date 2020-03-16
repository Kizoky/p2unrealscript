/**
 * P2EMath
 * Copyright 2014, Running With Scissors, Inc.
 *
 * A math library created so we can have easy access to functions that all
 * objects can use without the need of inheritance
 *
 * @author Gordon Cheng
 */
class P2EMath extends Object
    abstract;

const PI_OVER_TWO = 1.5707963267949;
const THREE_PI_OVER_TWO = 4.7123889803847;

/** Returns a vector representing the offset using the given direction
 * @param Dir - rotation to base the offset calculation off of
 * @param Offset - offset values in the form of a vector
 * @return Location offset
 */
static function vector GetOffset(rotator Dir, vector Offset) {
    local vector X, Y, Z;

    GetAxes(Dir, X, Y, Z);

    return X*Offset.X + Y*Offset.Y + Z*Offset.Z;
}

/** Returns an ease in style interpolation percent using a sine curve
 * @param A - Current float value that's moving toward the final B value
 * @param B - Final float value A will be moving toward
 * @return Percentage to be used interpolation
 */
static function float SineEaseIn(float A, float B) {
    return sin((A / B) * PI_OVER_TWO);
}

/** Returns an ease out style interpolation percent using a sine curve
 * @param A - Current float value that's moving toward the final B value
 * @param B - Final float value A will be moving toward
 * @return Percentage to be used interpolation
 */
static function float SineEaseOut(float A, float B) {
    return sin(THREE_PI_OVER_TWO + (PI_OVER_TWO * (A / B))) + 1;
}

/** Interpolates with ease-in (smoothly approaches B)
 * @param A - Value to interpolate from
 * @param B - Value to interpolate to
 * @param Alpha - Interpolant
 * @param Exp - Exponent;  Higher values result in more rapid deceleration
 * @return Interpolated value
 */
static function float FInterpEaseIn(float A, float B, float Alpha, float Exp) {
	return Lerp(Alpha**Exp, A, B);
}

/** Interpolates with ease-out (smoothly departs A)
 * @param A - Value to interpolate from.
 * @param B - Value to interpolate to.
 * @param Alpha - Interpolant
 * @param Exp - Exponent;  Higher values result in more rapid acceleration
 * @return Interpolated value
 */
static function float FInterpEaseOut(float A, float B, float Alpha, float Exp) {
	return Lerp(Alpha**(1/Exp), A, B);
}

/** Returns whether or not you can hit a given target using the given projectile
 * speed. We also assume there is no gravity or resistance changes.
 *
 * Basically the following equation is found inside the angle calculation's
 * square root. If the following is negative, then the square root will yeild
 * an imaginary number, which would mean its impossible to hit the target with
 * the current projectile speed.
 *
 * Also, we don't take into consideration whether or not the projectiles could
 * possibly hit some world geometry
 *
 * @param ProjStart - Where the projectile will be spawned
 * @param ProjEnd - When the projectile should ultimately hit
 * @param ProjSpeed - Speed of the projectile, assumes it uses PHYS_Falling
 * @param Gravity - Gravity to use in trajectory calculations
 * @return TRUE if we can hit the target using the given projectile speed
 */
static function bool CanHitTarget(vector ProjStart, vector ProjEnd,
                                  float ProjSpeed, float Gravity) {
    local float g, dx, dy;
    local vector LatStart, LatEnd;

    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    g = Abs(Gravity);
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    return Square(Square(ProjSpeed)) - g * (g * Square(dx) +
        2 * dy * Square(ProjSpeed)) >= 0;
}

/** Returns either the higher trajectory angle to hit the target using more
 * time, or the lower more direct angle
 *
 * @param dx - Lateral distance between the the projectile start to end
 * @param dy - Elevation difference between the projectile start to end
 * @param ProjSpeed - Speed at which the projectile will be fired at
 * @param Gravity - Gravity to use in trajectory calculations
 * @return Rotation pitch to use to hit the target
 */
static function int GetTrajectoryPitch(float dx, float dy, float ProjSpeed,
                                       float Gravity,
                                       bool bCalcLowerTrajectory) {

    local float g, radian, ratio;

    g = Abs(Gravity);

    if (bCalcLowerTrajectory)
        radian = Atan((Square(ProjSpeed) - Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));
    else
        radian = Atan((Square(ProjSpeed) + Sqrt(Square(Square(ProjSpeed))
            - g * (g * Square(dx) + 2 * dy * Square(ProjSpeed)))) / (g * dx));

    ratio = radian / PI_OVER_TWO;

    return int(ratio * 16384.0);
}

/** Returns the a rotation for a Projectile to be launched so that its arc will
 * hit a target. We also support multiple firing options such as using a
 * lower faster hitting arc, or higher slower arc, whether or not we can only
 * shoot upwards, and whether or not we should lead the target or not
 *
 * @param ProjStart - Where the projectile will be spawned
 * @param ProjEnd - Location in the world where the projectile should hit
 * @param ProjSpeed - Speed of the projectile
 * @param TargetVelocity - Velocity the target is moving, used for lead time
 * @param Spread - Additional noise to add to the pitch and yaw
 * @param Gravity - Gravity to use in trajectory calculations
 * @param bLeadTarget - If TRUE, we will perform lead time calculations
 * @param bUseHigherArc - If TRUE, we will use the slower, higher, arc
 * @param bUseUpwardArc - If TRUE, we will fire upwards only if the lower arc
 *                        fires downward
 * @return Rotation the projectile should be fired at to hit the Target
 */
static function rotator GetProjectileTrajectory(vector ProjStart,
                                                vector ProjEnd,
                                                float ProjSpeed,
                                                vector TargetVelocity,
                                                int Spread,
                                                float Gravity,
                                                optional bool bLeadTarget,
                                                optional bool bUseHigherArc,
                                                optional bool bUseUpwardArc) {

    local float dx, dy;
    local float LowerTrajectoryPitch, HigherTrajectoryPitch;
    local vector LatStart, LatEnd;
    local rotator ReturnTrajectory;

    local float LowerLatSpeed, HigherLatSpeed;
    local vector LeadTargetLocation;

    // If we can't hit our target simply fire as far as you can
    if (!CanHitTarget(ProjStart, ProjEnd, ProjSpeed, Gravity)) {

        ReturnTrajectory = rotator(ProjEnd - ProjStart);
        ReturnTrajectory.Pitch = 8192;

        return ReturnTrajectory;
    }

    // First perform calculations for the default position
    LatStart = ProjStart;
    LatStart.Z = 0;

    LatEnd = ProjEnd;
    LatEnd.Z = 0;

    // Calculate the dx and dy first so we can use these default values to
    // do lead time predictions
    dx = VSize(LatEnd - LatStart);
    dy = ProjEnd.Z - ProjStart.Z;

    // Perform lead time prediction with the default values if we choose to
    if (bLeadTarget) {

        LowerLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, true)) / 16384.0) * ProjSpeed;

        HigherLatSpeed = cos(float(GetTrajectoryPitch(dx, dy, ProjSpeed,
            Gravity, false)) / 16384.0) * ProjSpeed;

        if (bUseHigherArc)
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / HigherLatSpeed);
        else
            LeadTargetLocation = ProjEnd + TargetVelocity *
                (VSize(ProjEnd - ProjStart) / LowerLatSpeed);

        // If we can't hit our lead location simply fire straight at the
        // lead target location
        if (!CanHitTarget(ProjStart, LeadTargetLocation, ProjSpeed, Gravity)) {

            ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
            ReturnTrajectory.Pitch = 8192;

            return ReturnTrajectory;
        }

        LatEnd = LeadTargetLocation;
        LatEnd.Z = 0;

        dx = VSize(LatEnd - LatStart);
        dy = LeadTargetLocation.Z - ProjStart.Z;

        ReturnTrajectory = rotator(LeadTargetLocation - ProjStart);
    }
    else
        ReturnTrajectory = rotator(ProjEnd - ProjStart);

    // Calculate both angles which we can use to hit the target
    LowerTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, true);
    HigherTrajectoryPitch = GetTrajectoryPitch(dx, dy, ProjSpeed, Gravity, false);

    if (bUseHigherArc)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;
    else
        ReturnTrajectory.Pitch = LowerTrajectoryPitch;

    if (bUseUpwardArc && LowerTrajectoryPitch < 0)
        ReturnTrajectory.Pitch = HigherTrajectoryPitch;

    ReturnTrajectory.Pitch += int(FRand() * float(Spread));
    ReturnTrajectory.Pitch -= int(FRand() * float(Spread));

    ReturnTrajectory.Yaw += int(FRand() * float(Spread));
    ReturnTrajectory.Yaw -= int(FRand() * float(Spread));


    return ReturnTrajectory;
}

/** Returns the maximum height that a projectile can fly up to using the given
 * initial upward velocity and the gravity its under
 *
 * @param Pitch - The pitch of the projectile trajectory
 * @param ProjSpeed - Speed of the projectile
 * @param Gravity - Downward acceleration that will affect the projectile
 * @return Maximum height that the projectile will be able to reach
 */
static function float GetMaxProjectileHeight(int Pitch, float ProjSpeed,
                                             float Gravity) {
    local float rad, vi, g, t, yf;

    if (Pitch <= 0)
        return 0;

    rad = (float(Pitch) / 16384.0) * PI_OVER_TWO;
    vi = sin(rad) * ProjSpeed;
    g = Abs(Gravity);
    t = vi / g;

    return vi * t + 0.5 * -g * t;
}