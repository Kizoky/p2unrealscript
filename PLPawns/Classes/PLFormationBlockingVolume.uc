/**
 * PLFormationBlockingVolume
 * Copyright 2014, Running With Scissors, Inc.
 *
 * These volumes help dictate some space in the world where PLFormationManagers
 * should treat as a solid wall. Examples of where this volume could be used
 * can include walkways where Pawns could safely jump off, but shouldn't and
 * shelves that are at waist level
 *
 * @author Gordon Cheng
 */
class PLFormationBlockingVolume extends Volume;

/**
 * Sets the bBlockZeroExtentTraces flag so that this volume may block formation
 * traces when the PLFormationManager needs to update they're positions
 *
 * @param bNewBlock - The new bBlockZeroExtentTraces value
 */
function SetBlocksTraces(bool bNewBlock) {
    SetCollision(bNewBlock);
    bBlockZeroExtentTraces = bNewBlock;
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=false
	bProjTarget=false
	bBlockZeroExtentTraces=true
    bBlockNonZeroExtentTraces=false
	bWorldGeometry=true
	bPathColliding=true

	BrushColor=(A=255,B=0,G=0,R=150)
}