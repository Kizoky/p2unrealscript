/**
 * ACTION_ShortCircuitScanner
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Does the same thing as ACTION_ShortCircuitSetup does but also creates
 *
 * @author Gordon Cheng
 */
class ACTION_ShortCircuitScanner extends ScriptedAction;

var(Action) int MinimumViolenceRank;
var(Action) float ThreatCheckRadius, ThreatCheckAngle;

/** Overriden so we can create a scanner that checks our surroundings for
 * stuff that could possibly break
 */
function bool InitActionFor(ScriptedController C) {
    local ShortCircuitScanner Scanner;

    Scanner = C.Spawn(class'ShortCircuitScanner',,, C.Pawn.Location);

    if (Scanner != none) {
        Scanner.MinViolenceRank = MinimumViolenceRank;

        Scanner.CheckRadius = ThreatCheckRadius;
        Scanner.CheckAngle = ThreatCheckAngle;

        Scanner.Pawn = C.Pawn;
        Scanner.ScriptedController = C;
        Scanner.PendingController = C.PendingController;
    }

    return false;
}

defaultproperties
{
    MinimumViolenceRank=1

    ThreatCheckRadius=1000
    ThreatCheckAngle=360
}