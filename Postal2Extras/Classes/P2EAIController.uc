/**
 * P2EAIController
 * Copyright 2014, Running With Scissors, Inc.
 *
 * Sometimes AIControllers don't need to be too advance or need to inherit
 * behaviors from existing controllers such as the BystanderController.
 *
 * As a result I decided that have a simple base controller that allows the
 * creation of custom behaviors with simple bits of code, or at least it is to
 * me. This means there's no subclassing of more complex controllers or
 * stubbing out a bunch of code that's not needed, just, write what you need.
 *
 * I keep the animation stuff here as opposed to the Pawn so the Controller can
 * keep track and control the animations from here. I might port them over
 * as abstract methods if more objects need the anim functions
 *
 * @author Gordon Cheng
 */
class P2EAIController extends AIController;

/** Different styles of interpolation */
enum EInterpStyle {
    /** Linear Interpolation; Constant velocity when moving to the new spot */
    INTERP_Linear,
    /** Ease in; Smoothly moves in using part of a sine curve */
    INTERP_SineEaseIn,
    /** Ease out; Smoothly departs using part of a sine curve */
    INTERP_SineEaseOut,
    /** Ease in; Smoothly eases into the destination value */
    INTERP_EaseIn,
    /** Ease out; Smoothly departs from the starting value */
    INTERP_EaseOut
};

/** Struct containing the name, rate, and default duration of an animation */
struct AnimInfo {
    /** Name of the animation */
    var name Anim;
    /** Rate that the animation should play at */
    var float Rate;
    /** Default duration of the animation at rate = 1.0f */
    var float AnimTime;
};

/** Struct containing pseudo timer information such as duration, time remaining
 * and the ID of the timer
 */
struct TimerInfo {
    /** Whether or not to pause updating this timer */
    var bool  bPause;
    /** Whether or not a specific timer loops */
    var bool  bLoops;
    /** Number of times the timer should loop. -1 = Loop infinitely */
    var int   LoopCount;
    /** Time in seconds since the timer was first started */
    var float ElapsedTime;
    /** Time in seconds the timer should last before its complete */
    var float FinishTime;
    /** Name to use as an ID for this specific timer */
    var name  TimerID;
};

/** Struct containing information on the attack such as duration and range */
struct AttackInfo {
    /** Time in seconds it will take to complete the attack */
    var float Duration;
    /** Distance away from the player in which the attack will hit */
    var float Range;
    /** Angle in front of our Pawn in which the attack will hit */
    var float Angle;
    /** Amount of damage the attack will deal */
    var float Damage;
    /** DamageType to deal for the attack */
    var class<DamageType> DamageType;
    /** Animation to play for the attack */
    var AnimInfo Anim;
};

/** Whether or not we should log debug information */
var bool bLogDebug;

/** Field of vision, or basically how wide is this character's vision */
var float VisionFOV;
/** Distance this character can see */
var float VisionRange;

/** Whether or not we're currently interpolating this Pawn's speed */
var bool bInterpSpeed;
/** Time in seconds since the interpolation has started */
var float InterpSpeedTime;
/** Time in seconds for the interpolation to complete */
var float InterpSpeedEndTime;
/** Used to adjust the EaseIn and EaseOut acceleration and deceleration */
var float InterpSpeedExponent;
/** GroundSpeed of the Pawn to start interpolating from */
var float InterpSpeedStart;
/** GroundSpeed for the Pawn to interpolate to */
var float InterpSpeedEnd;
/** Style of interpolation to use */
var EInterpStyle InterpSpeedStyle;

/** Whether or not we're currently interpolating this Pawn's location */
var bool bInterpLoc;
/** Time in seconds since the interpolation has started */
var float InterpLocTime;
/** Time in seconds for the interpolation to complete */
var float InterpLocEndTime;
/** Height above the apex of the interpolation the Pawn will be */
var float InterpLocHeight;
/** Used to adjust the EaseIn and EaseOut acceleration and deceleration */
var float InterpLocExponent;
/** Location in the world where to interpolate from */
var vector InterpLocStart;
/** Location in the world to interpolate to */
var vector InterpLocEnd;
/** Style of interpolation to use */
var EInterpStyle InterpLocStyle;

/** List of timers currently active */
var array<TimerInfo> TimerList;

/** General function that returns whether a Pawn that is not under our control
 * may be facing another Actor using a given angle
 * @param Other - The Pawn we're gonna do a vision check on
 * @param TestActor - The Actor to see if it's in the viewing angle of the Pawn
 * @param Angle - Maximum angle in degrees away from the Pawn's rotation to be
 *                considered still in the facing angle
 * @return TRUE if the given Actor is in our facing angle of our Pawn
 */
function bool IsPawnFacingActor(Pawn Other, Actor TestActor, float Angle) {
    local float MinFOV;
    local vector TargetDir;

    TargetDir = Normal(TestActor.Location - Other.Location);
    MinFOV = 1.0f - Angle / 180.0f;

    return (TargetDir dot vector(Other.Rotation) >= MinFOV);
}

/** General function that returns whether or not a point in the world is in
 * the specified angle around the Pawn
 * @param Point - Location in the world to check for
 * @param Angle - Maximum angle in degrees away from the Pawn's rotation to be
 *                considered still in the facing angle
 * @return TRUE if the given Actor is in our facing angle of our Pawn
 */
function bool IsLocationInFacingAngle(vector Point, float Angle) {
    local float MinFOV;
    local vector TargetDir;

    TargetDir = Normal(Point - Pawn.Location);
    MinFOV = 1.0f - Angle / 180.0f;

    return (TargetDir dot vector(Pawn.Rotation) >= MinFOV);
}

/** General function that returns whether or not something is in a specified
 * angle around the Pawn
 * @param Other - Actor to perform the angle check on
 * @param Angle - Maximum angle in degrees away from the Pawn's rotation to be
 *                considered still in the facing angle
 * @return TRUE if the given Actor is in our facing angle of our Pawn
 */
function bool IsInFacingAngle(Actor Other, float Angle) {
    local float MinFOV;
    local vector TargetDir;

    TargetDir = Normal(Other.Location - Pawn.Location);
    MinFOV = 1.0f - Angle / 180.0f;

    return (TargetDir dot vector(Pawn.Rotation) >= MinFOV);
}

/** Returns whether or not the specified Actor is in our Pawn's FOV
 * @param Other - Actor to perform the angle check on
 * @return TRUE if the object is in our Pawn's FOV; FALSE otherwise
 */
function bool IsInFieldOfVision(Actor Other) {
    local float MinFOV;
    local vector TargetDir;

    TargetDir = Normal(Other.Location - Pawn.Location);
    MinFOV = 1.0f - VisionFOV / 180.0f;

    return (TargetDir dot vector(Pawn.Rotation) >= MinFOV);
}

/** Returns duration of an animation using the default duration and play rate
 * @param Anim - Struct containing the default duration and playback rate
 * @return Time in seconds that the animation will take to complete
 */
function float GetAnimDefaultDuration(AnimInfo Anim) {
    return Anim.AnimTime / Anim.Rate;
}

/** Returns duration of an animation being played at the given rate
 * @param Rate - Playback rate of the animation
 * @param Anim - Struct containing the default duration and playback rate
 * @return Time in seconds that the animation will take to complete
 */
function float GetAnimDurationFromRate(float Rate, AnimInfo Anim) {
    return Anim.AnimTime / Rate;
}

/** Returns the animation rate that an animation should play at to achieve the
 * specified desired duration
 * @param Duration - Time in seconds you want the animation to last
 * @param Anim - Struct containing the default duration
 * @return Rate the animation should play at to achieve the desired duration
 */
function float GetAnimRateFromDuration(float Duration, AnimInfo Anim) {
    return Anim.AnimTime / Duration;
}

/** Plays an animation on the pawn so it ends by the given duration
 * @param Anim - Struct containing the default animation information
 * @param Duration - Time in seconds the Animation should last
 * @param TweenTime - Time in seconds to blend one animation into the other
 * @param Channel - The channel thingy... yeah... I got nothing
 */
function PlayAnimByDuration(AnimInfo Anim, float Duration,
                            optional float TweenTime, optional int Channel) {
    Pawn.PlayAnim(Anim.Anim, GetAnimRateFromDuration(Duration, Anim),
                  TweenTime, Channel);
}

/** Loops an animation on the pawn so it ends by the given duration
 * @param Anim - Struct containing the default animation information
 * @param Duration - Time in seconds the Animation should last
 * @param TweenTime - Time in seconds to blend one animation into the other
 * @param Channel - The channel thingy... yeah... I got nothing
 */
function LoopAnimByDuration(AnimInfo Anim, float Duration,
                            optional float TweenTime, optional int Channel) {
    Pawn.LoopAnim(Anim.Anim, GetAnimRateFromDuration(Duration, Anim),
                  TweenTime, Channel);
}

/** Simply plays the AnimInfo at it's given rate, nothing fancy
 * @param Anim - Struct containing the name of the animation and rate to play at
 * @param TweenTime - Time in seconds to blend one animation into the other
 */
function PlayAnimInfo(AnimInfo Anim, optional float TweenTime) {
    Pawn.PlayAnim(Anim.Anim, Anim.Rate, TweenTime);
}

/** Simply loops the AnimInfo at it's given rate, nothing fancy
 * @param Anim - Struct containing the name of the animation and rate to play at
 * @param TweenTime - Time in seconds to blend one animation into the other
 */
function LoopAnimInfo(AnimInfo Anim, optional float TweenTime) {
    Pawn.LoopAnim(Anim.Anim, Anim.Rate, TweenTime);
}

/** Returns whether or not the specified Timer ID is already in use
 * @param ID - Name of the Timer to check if its already in use
 * @return TRUE if the Timer ID already exists; FALSE otherwise
 */
function bool IsExistingTimer(name ID) {
    local int i;

    for (i=0;i<TimerList.length;i++)
        if (TimerList[i].TimerID == ID)
            return true;

    return false;
}

/** Adds a Timer struct to the current list of them. The ID doesn't necessarily
 * need to be unique allowing users to fire off. If we're adding an existing
 * Timer, then we'll instead reset it and update it's duration
 * @param bLoops - Whether or not this timer loops
 * @param LoopCnt - How many time this Timer should loop; -1 = loops infinitely
 * @param Duration - Time in seconds before the Timer should fire
 * @param ID - Name given to the Timer to identify it
 */
function AddTimer(float Duration, name ID, bool bLoops, optional int LoopCnt) {
    local TimerInfo NewTimer;

    if (IsExistingTimer(ID)) {
        ResetTimer(ID, Duration);
        return;
    }

    //LogDebug("Adding Timer: " $ ID $ " (" $ Duration $ ")");

    NewTimer.bPause = false;
    NewTimer.bLoops = bLoops;
    NewTimer.LoopCount = Max(-1, LoopCnt);
    NewTimer.FinishTime = FMax(0.01f, Duration);
    NewTimer.TimerID = ID;

    TimerList.Insert(TimerList.length, 1);
    TimerList[TimerList.length - 1] = NewTimer;
}

/** Pauses a Timer using a given index of the TimerList
 * @param Idx - Index of the TimerInfo we should pause
 * @param bNewPause - Whether or not the timer should be paused
 */
function SetTimerPause(int Idx, bool bNewPause) {
    TimerList[Idx].bPause = bNewPause;
}

/** Pauses a timer by preventing it's elapsed time from updating
 * @param ID - Name of the Timer to pause
 * @param bNewPause - Whether or not the timer should be paused
 */
function SetTimerPauseByID(name ID, bool bNewPause) {
    local int i;

    for (i=0;i<TimerList.length;i++)
        if (TimerList[i].TimerID == ID)
            TimerList[i].bPause = bNewPause;
}

/** Resets an existing timer and optionally change it's finish time
 * @param ID - Name of the Timer to reset
 * @param Duration - Time in seconds before the Timer should fire
 */
function ResetTimer(name ID, optional float Duration) {
    local int i;

    for (i=0;i<TimerList.length;i++) {
        if (TimerList[i].TimerID == ID) {
            TimerList[i].ElapsedTime = 0;

            if (Duration > 0)
                TimerList[i].FinishTime = Duration;
        }
    }
}

/** Removes a Timer from the TimerList using the specified index
 * @param Idx - Index of the TimerInfo we should remove from the list
 */
function RemoveTimer(int Idx) {
    if (TimerList.length == 0 || Idx >= TimerList.length) return;

    //LogDebug("Removing Timer (Index): " $ TimerList[Idx].TimerID);

    TimerList.Remove(Idx, 1);
}

/** Removes all Timers with the given ID
 * @param ID - Name of the Timer to remove
 */
function RemoveTimerByID(name ID) {
    local int i;

    if (TimerList.length == 0) return;

    //LogDebug("Removing Timer (ID): " $ ID);

    for (i=0;i<TimerList.length;i++)
        if (TimerList[i].TimerID == ID)
            TimerList.Remove(i, 1);
}

/** Removes a Timer from the TimerList using a specified index and has an
 * additional check to ensure only finished Timers can be removed
 * @param Idx - Index of the TimerInfo we should remove from the list
 */
function RemoveFinishedTimer(int Idx) {
    if (TimerList.length == 0 || Idx >= TimerList.length) return;

    if (TimerList[Idx].ElapsedTime < TimerList[Idx].FinishTime) return;

    //LogDebug("Removing Finished Timer (Index): " $ TimerList[Idx].TimerID);

    TimerList.Remove(Idx, 1);
}

/** Function gets called whenever a Timer fires. This function should be
 * overriden by the programmer to implement functionality using the ID param
 * @param ID - Name of the Timer that just fired
 */
function TimerFinished(name ID) {
    // STUB
}

/** Returns a PathNode that's closest to the specified Actor
 * @param Other - Actor object to check to see which PathNode is closest to
 * @return PathNode that's closest to the specified Actor
 */
function PathNode GetClosestPathnode(Actor Other, bool bAllowHomeNodes) {
    local int i, Closest;
    local float Distance, ClosestDistance;
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode) {
        if (!bAllowHomeNodes && HomeNode(PathNode) != none)
            continue;

        PathNodeList.Insert(PathNodeList.length, 1);
        PathNodeList[PathNodeList.length - 1] = PathNode;
    }

    Closest = -1;
    ClosestDistance = 3.4028e38;

    for (i=0;i<PathNodeList.length;i++) {

        Distance = VSize(PathNodeList[i].Location - Other.Location);

        if (Distance < ClosestDistance) {

            ClosestDistance = Distance;
            Closest = i;
        }
    }

    if (Closest == -1)
        return none;
    else
        return PathNodeList[Closest];
}

/** Returns a random PathNode in the map for either starting or wandering to
 * TODO: Might result in array out of bounds if list is empty, might fix later
 * @param bAllowHomeNodes - Whether or not we're gonna consider HomeNodes
 * @return A random PathNode in the level
 */
function PathNode GetRandomPathNode(bool bAllowHomeNodes) {
    local PathNode PathNode;
    local array<PathNode> PathNodeList;

    foreach AllActors(class'PathNode', PathNode) {
        if (!bAllowHomeNodes && HomeNode(PathNode) != none)
            continue;

        PathNodeList.Insert(PathNodeList.length, 1);
        PathNodeList[PathNodeList.length - 1] = PathNode;
    }

    return PathNodeList[Rand(PathNodeList.length)];
}

/** Performs a visible colliding Actors check using our VisionRange and
 * VisionFOV to find Pawns we may be concerned about
 */
function CheckSurroundingPawns() {
    local Pawn Seen;

    foreach VisibleCollidingActors(class'Pawn', Seen, VisionRange,
        Pawn.Location + Pawn.EyePosition())
        if (IsInFieldOfVision(Seen))
            PawnSeen(Seen);
}

/** Pawns that are seen using my own system is reported to this function. This
 * method should be overriden by programmers to implement functionality
 * @param Other - Pawn object that was seen by our Pawn
 */
function PawnSeen(Pawn Other) {
    // STUB
}

/** Interpolates a Pawn's GroundSpeed based on the given time
 * @param Time - Time in seconds the interpolation will take to complete
 * @param Dest - Final GroundSpeed to interpolate to
 * @param Style - Style of interpolation to use to transition values
 * @param Exp - Adjusts the acceleration or deceleration of non-linear interps
 */
function InterpolateSpeed(float Time, float Dest, EInterpStyle Style,
                          optional float Exp) {
    bInterpSpeed = true;
    InterpSpeedTime = 0;
    InterpSpeedEndTime = FMax(0.01, Time);
    InterpSpeedStart = Pawn.GroundSpeed;
    InterpSpeedEnd = Dest;
    InterpSpeedStyle = Style;

    if (Exp == 0)
        InterpSpeedExponent = 2;
    else
        InterpSpeedExponent = Exp;
}

/** Interpolates a pawn from one location to another based on speed
 * @param Speed - Interpolating speed to move toward the destination
 * @param Dest - Location in the world to interpolate to
 * @param Style - Style of interpolation to use to transition values
 * @param Exp - Adjusts the acceleration or deceleration of non-linear interps
 */
function InterpolateBySpeed(float Speed, vector Dest, EInterpStyle Style,
                            optional float Exp) {
    bInterpLoc = true;
    InterpLocTime = 0;
    InterpLocEndTime = FMax(0.01, VSize(Pawn.Location - Dest) / Speed);
    InterpLocHeight = 0;
    InterpLocStart = Pawn.Location;
    InterpLocEnd = Dest;
    InterpLocStyle = Style;

    if (Exp == 0)
        InterpLocExponent = 2;
    else
        InterpLocExponent = Exp;
}

/** Interpolates a pawn from one location to another based on duration
 * @param Time - Time in seconds the interpolation will take to complete
 * @param Dest - Location in the world to interpolate to
 * @param Style - Style of interpolation to use to transition values
 * @param Exp - Adjusts the acceleration or deceleration of non-linear interps
 */
function InterpolateByDuration(float Time, vector Dest, EInterpStyle Style,
                               optional float Exp) {
    bInterpLoc = true;
    InterpLocTime = 0;
    InterpLocEndTime = FMax(0.01, Time);
    InterpLocHeight = 0;
    InterpLocStart = Pawn.Location;
    InterpLocEnd = Dest;
    InterpLocStyle = Style;

    if (Exp == 0)
        InterpLocExponent = 2;
    else
        InterpLocExponent = Exp;
}

/** Performs an interpolated jump using the given speed and height apex
 * @param Speed - Interpolating speed to move toward the destination
 * @param Height - Height above the interpolation line during the apex
 * @param Dest - Location in the world to interpolate to
 * @param Style - Style of interpolation to use to transition values
 * @param Exp - Adjusts the acceleration or deceleration of non-linear interps
 */
function JumpInterpolateBySpeed(float Speed, float Height, vector Dest,
                                EInterpStyle Style, optional float Exp) {
    bInterpLoc = true;
    InterpLocTime = 0;
    InterpLocEndTime = FMin(0.01, VSize(Pawn.Location - Dest) / Speed);
    InterpLocHeight = Height;
    InterpLocStart = Pawn.Location;
    InterpLocEnd = Dest;
    InterpLocStyle = Style;

    if (Exp == 0)
        InterpLocExponent = 2;
    else
        InterpLocExponent = Exp;
}

/** Performs an interpolated jump using the given speed and height apex
 * @param Time - Time in seconds the interpolation will take to complete
 * @param Height - Height above the interpolation line during the apex
 * @param Dest - Location in the world to interpolate to
 * @param Style - Style of interpolation to use to transition values
 * @param Exp - Adjusts the acceleration or deceleration of non-linear interps
 */
function JumpInterpolateByDuration(float Time, float Height, vector Dest,
                                   EInterpStyle Style, optional float Exp) {
    bInterpLoc = true;
    InterpLocTime = 0;
    InterpLocEndTime = FMin(0.01, Time);
    InterpLocHeight = Height;
    InterpLocStart = Pawn.Location;
    InterpLocEnd = Dest;
    InterpLocStyle = Style;

    if (Exp == 0)
        InterpLocExponent = 2;
    else
        InterpLocExponent = Exp;
}

/** Method is automatically called by the script when we've finished our
 * speed interpolation. Should be overriden to implement functionality
 */
function SpeedInterpolationFinished() {
    // STUB
}

/** Method is automatically called by the script when we've finished our
 * location interpolation. Should be overriden to implement functionality
 */
function LocationInterpolationFinished() {
    // STUB
}

/** Using the given delta time updates all the current timers
 * @param DeltaTime - Time in seconds since the last Tick call
 */
function UpdateTimerList(float DeltaTime) {
    local int i;

    // First we update all the Timers before modifying the array by adding
    // new timers or removed finished ones
    for (i=0;i<TimerList.length;i++) {
        if (!TimerList[i].bPause)
            TimerList[i].ElapsedTime = TimerList[i].ElapsedTime + DeltaTime;
    }

    // Next go through the list to handle finished Timers
    for (i=0;i<TimerList.length;i++) {
        if (TimerList[i].ElapsedTime >= TimerList[i].FinishTime) {
            TimerFinished(TimerList[i].TimerID);
            TimerList[i].LoopCount = Max(-1, TimerList[i].LoopCount - 1);

            // Only remove Timers when they're done and return since deleting
            // modifies the array size, doesn't modify iterator i
            if (!TimerList[i].bLoops || TimerList[i].LoopCount == 0) {
                RemoveFinishedTimer(i);
                return;
            }
            else // If we loop, reset the elapsed time
                TimerList[i].ElapsedTime -= TimerList[i].FinishTime;
        }
    }
}

/** Using the given delta time, updates the current interpolation speed
 * @param DeltaTime - Tick in seconds since the last Tick call
 */
function UpdateSpeedInterpolation(float DeltaTime) {
    local float InterpPct;

    InterpSpeedTime = FMin(InterpSpeedTime + DeltaTime, InterpSpeedEndTime);

    switch (InterpSpeedStyle) {
        case INTERP_Linear:
            InterpPct = InterpSpeedTime / InterpSpeedEndTime;
            break;
        case INTERP_SineEaseIn:
            InterpPct = class'P2EMath'.static.SineEaseIn(InterpSpeedTime,
                InterpSpeedEndTime);
            break;
        case INTERP_SineEaseOut:
            InterpPct = class'P2EMath'.static.SineEaseOut(InterpSpeedTime,
                InterpSpeedEndTime);
            break;
        case INTERP_EaseIn:
            InterpPct = class'P2EMath'.static.FInterpEaseIn(0, 1,
                InterpSpeedTime / InterpSpeedEndTime, InterpSpeedExponent);
            break;
        case INTERP_EaseOut:
            InterpPct = class'P2EMath'.static.FInterpEaseOut(0, 1,
                InterpSpeedTime / InterpSpeedEndTime, InterpSpeedExponent);
            break;
    }

    Pawn.GroundSpeed = InterpSpeedStart +
        ((InterpSpeedEnd - InterpSpeedStart) * InterpPct);
    Pawn.AirSpeed = InterpSpeedStart + ((InterpSpeedEnd - InterpSpeedStart) *
        InterpPct);

    if (InterpSpeedTime == InterpSpeedEndTime) {
        bInterpSpeed = false;
        SpeedInterpolationFinished();
    }
}

/** Using the given delta time, updates the current interpolation path
 * @param DeltaTime - Tick in seconds since the last Tick call
 */
function UpdateLocationInterpolation(float DeltaTime) {
    local float InterpPct;
    local vector InterpLoc;

    InterpLocTime = FMin(InterpLocTime + DeltaTime, InterpLocEndTime);

    switch (InterpLocStyle) {
        case INTERP_Linear:
            InterpPct = InterpLocTime / InterpLocEndTime;
            break;
        case INTERP_SineEaseIn:
            Interppct = class'P2EMath'.static.SineEaseIn(InterpLocTime,
                InterpLocEndTime);
            break;
        case INTERP_SineEaseOut:
            InterpPct = class'P2EMath'.static.SineEaseOut(InterpLocTime,
                InterpLocEndTime);
            break;
        case INTERP_EaseIn:
            InterpPct = class'P2EMath'.static.FInterpEaseIn(0, 1,
                InterpLocTime / InterpLocEndTime, InterpLocExponent);
            break;
        case INTERP_EaseOut:
            InterpPct = class'P2EMath'.static.FInterpEaseOut(0, 1,
                InterpLocTime / InterpLocEndTime, InterpLocExponent);
            break;
    }

    InterpLoc = InterpLocStart + ((InterpLocEnd - InterpLocStart) * InterpPct);
    InterpLoc.Z += sin(InterpPct * Pi) * InterpLocHeight;

    Pawn.SetLocation(InterpLoc);

    if (InterpLocTime == InterpLocEndTime) {
        bInterpLoc = false;
        LocationInterpolationFinished();
    }
}

/** Subclassed the Tick event to provide a pseudo multi timer support */
event Tick(float DeltaTime) {
    if (TimerList.length > 0)
        UpdateTimerList(DeltaTime);

    if (bInterpSpeed)
        UpdateSpeedInterpolation(DeltaTime);

    if (bInterpLoc)
        UpdateLocationInterpolation(DeltaTime);
}

/** Causes the Pawn to stop moving */
function StopMoving() {
    Pawn.Acceleration = vect(0,0,0);
    Pawn.Velocity = vect(0,0,0);
}

/** Face forward */
function FaceForward() {
    Focus = none;
    FocalPoint = Pawn.Location + vector(Pawn.Rotation) * 32768;
}

/** Takes the given text, and if we're currently logging info, log it!
 * @param Text - Debug text to log into a file and output to the console
 */
function LogDebug(String Text) {
    if (bLogDebug) log(name $ ": " $ Text);
}

defaultproperties
{
    bLogDebug=false
}