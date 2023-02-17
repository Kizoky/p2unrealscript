/**
 * PLFormationAnchor
 * Copyright 2014, Running With Scissors, Inc.
 *
 * An Actor in the world that represents where a Pawn should move to in order
 * to stay in formation.
 *
 * @author Gordon Cheng
 */
class PLFormationAnchor extends Actor;

/** Whether or not this should be hidden, mostly for debugging purposes */
var bool bVisibleInGame;

/** Offset from and the Pawn that we're forming around */
var float FormationGroundOffset;
var vector FormationOffset;
var Pawn FormationUser, FormationTarget;

/**
 * Initializes this anchor using the given geometry check radiuses and the
 * absolute direction relative to the
 */
function InitializeAnchor(float GroundOffset, Pawn User, Pawn Target) {

    FormationGroundOffset = GroundOffset;

    FormationUser = User;
    FormationTarget = Target;

    bHidden = !bVisibleInGame;
}

/**
 * Sets the FormationTarget value using the new Pawn object
 *
 * @param NewTarget - Pawn object to track
 */
function SetTarget(Pawn NewTarget) {

    if (NewTarget != none && NewTarget != FormationTarget)
        FormationTarget = NewTarget;
}

/**
 * Sets the FormationOffset variable using the new vector offset
 *
 * @param NewOffset - New offset from our FormationTarget
 */
function SetFormationOffset(vector NewOffset) {

    if (NewOffset != vect(0,0,0) && NewOffset != FormationOffset)
        FormationOffset = NewOffset;
}

/**
 * Updates this achor's location relative location and it's height above the
 * ground
 */
function UpdateLocation() {

    if (FormationTarget != none)
        SetLocation(FormationTarget.Location + FormationOffset);
}

defaultproperties
{
    bHidden=false
	bVisibleInGame=false

    Texture=S_PathNode
    DrawScale=0.125
}