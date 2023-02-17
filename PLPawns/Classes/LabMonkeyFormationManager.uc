/**
 * LabMonkeyFormationManager
 * Copyright 2014, Running With Scissors, Inc.
 *
 * Guess there's really no reason for this other than creating a seperate
 * entry in the configuration file for development. After development, those
 * values will then go into the default properties
 *
 * @author Gordon Cheng
 */
class LabMonkeyFormationManager extends PLFormationManager;

defaultproperties
{
    GeometryCheckTraces=4

    PreCalFormationOffsets=50
    PreCalRadials=64

    MinFormationRadius=0

    FormationRadius=48
    FormationGroundOffset=32
    FormationDirOffset=512
    FormationDropHeight=256

    FormationUpdateInterval=0.1

    MinNPCFormationRadius=256
}
