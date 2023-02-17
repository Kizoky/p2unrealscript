/**
 * LabMonkeyReleaseVolume
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Decided the use a volume instead of a trigger as we use Triggers to
 * individually activating each monkey. Second a monkey touches this, they're
 * all will be set free
 *
 * @author Gordon Cheng
 */
class LabMonkeyReleaseVolume extends Volume;

/** Tag of the PathNode monkeys should run to in order to delete themselves */
var(ReleaseVolume) name ExitPathNodeTag;

/** PathNode object in the world for the monkeys to move to */
var PathNode ExitPathNode;

var bool bNotifiedMonkeys;

/** Overriden so we can find the ExitPathNode for all the monkeys */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    if (ExitPathNodeTag != '' && ExitPathNodeTag != 'None')
        foreach AllActors(class'PathNode', ExitPathNode, ExitPathNodeTag)
            if (ExitPathNode != none)
                break;
}

/** Overriden so we can implement the monkey's release when they touch this */
event Touch(Actor Other) {
    local LabMonkeyController LabMonkeyC;

    if (bNotifiedMonkeys)
        return;

    if (LabMonkey(Other) != none) {
        foreach DynamicActors(class'LabMonkeyController', LabMonkeyC)
            if (LabMonkeyC != none)
                LabMonkeyC.NotifyReleaseFromPostalDude(ExitPathNode);

        bNotifiedMonkeys = true;
    }
}

defaultproperties
{
}