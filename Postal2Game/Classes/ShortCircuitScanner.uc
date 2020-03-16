/**
 * ShortCircuitScanner
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * An Actor that simply scans out surroundings for stuff that Pawns may be
 * concerned about
 *
 * @author Gordon Cheng
 */
class ShortCircuitScanner extends Actor
    notplaceable;

/** Misc objects and values */
var Pawn ThreatPawn;

var TimedMarker Marker;
var class<TimedMarker> MarkerClass;
var FPSPawn MarkerCreatorPawn;
var Actor MarkerOriginActor;
var vector MarkerLocation;

var int MinViolenceRank;
var float CheckRadius, CheckAngle;

var Pawn Pawn;
var ScriptedController ScriptedController;
var Controller PendingController;

/** Returns whether or not something is in the field of vision of our Pawn
 * @param Other - Actor object to check whether or not is in the field of vision
 * @return TRUE if the Actor is in our Pawn's FOV; FALSE otherwise
 */
function bool IsInFieldOfVision(Actor Other) {
    local float MinFOV;
    local vector TargetDir;

    TargetDir = Normal(Other.Location - Pawn.Location);
    MinFOV = 1.0f - CheckAngle / 180.0f;

    return (TargetDir dot vector(Pawn.Rotation) >= MinFOV);
}

/** Returns whether or not a Pawn is a threat
 * @param Other - Pawn object to check for dangerous weapons
 * @return TRUE if the Pawn is armed and dangerous; FALSE otherwise
 */
function bool IsPawnAThreat(Pawn Other) {
    return Other.Weapon != none && P2Weapon(Other.Weapon) != none && P2Weapon(Other.Weapon).ViolenceRank >= MinViolenceRank;
}

/** Returns whether or not there is a threat around
 * @return TRUE if there's a threat; FALSE otherwise
 */
function bool IsThereAThreat() {
    local Actor A;

    foreach CollidingActors(class'Actor', A, CheckRadius, Pawn.Location) {
        if (Pawn(A) != none && IsInFieldOfVision(A) && IsPawnAThreat(Pawn(A))) {
            ThreatPawn = Pawn(A);
            return true;
        }
    }

    return false;
}

/** Called whenever a threat has been detected */
function ThreatDetected() {
    if (Pawn != none)
        Pawn.UnPossessed();

    if (ScriptedController != none)
        ScriptedController.GotoState('DestroySoon');

    GotoState('AgitatePawn');
}

/** Notification from a marker */
function NotifyMarker(TimedMarker newMarker) {
    ThreatDetected();

    Marker = newMarker;

    GotoState('AgitatePawn');
}

/** Notification from a marker but done only through code */
function NotifyMarkerClass(class<TimedMarker> newMarkerClass, FPSPawn CheckCreatorPawn, Actor CheckOriginActor, vector Loc) {
    ThreatDetected();

    MarkerClass = newMarkerClass;
    MarkerCreatorPawn = CheckCreatorPawn;
    MarkerOriginActor = CheckOriginActor;
    MarkerLocation = Loc;

    GotoState('AgitatePawn');
}

/** Constantly scan our surroundings for possible threats */
auto state Scan
{
Begin:
    while(true) {
        Sleep(0.1);

        if (Pawn == none || Pawn.Health <= 0)
            Destroy();

        if (IsThereAThreat())
            ThreatDetected();
    }
}

state AgitatePawn
{
Begin:
    while(true) {
        if (Pawn == none || Pawn.Health <= 0)
            Destroy();

        if (PendingController != none && Pawn.Health > 0) {
            PendingController.bStasis = false;
            PendingController.Possess(Pawn);
            PendingController.Focus = ThreatPawn;
        }

        Sleep(0.1);

        if (LambController(Pawn.Controller) != none) {
            if (Marker != none)
                LambController(Pawn.Controller).MarkerIsHere(Marker.class, Marker.CreatorPawn, Marker.OriginActor, Marker.Location);
            else if (MarkerClass != none)
                LambController(Pawn.Controller).MarkerIsHere(MarkerClass, MarkerCreatorPawn, MarkerOriginActor, MarkerLocation);

            Destroy();
        }
    }
}

defaultproperties
{
    MinViolenceRank=1

    bHidden=true

	bCollideActors=false
	bCollideWorld=false

	bBlockActors=false
	bBlockPlayers=false

	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
}