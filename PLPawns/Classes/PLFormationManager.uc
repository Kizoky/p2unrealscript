/**
 * PLFormationManager
 * Copyright 2014, Running With Scissors, Inc.
 *
 * This object is repsonsibly for keeping track of various positions in the
 * world where pawns who follow sort of a mob mentality, such as the
 *
 * @author Gordon Cheng
 */
class PLFormationManager extends Actor;

/** Defines various settings for generating formation positions  */
var int GeometryCheckTraces;
var int PreCalFormationOffsets, PreCalRadials;
var float MinFormationRadius, MinNPCFormationRadius, FormationRadius;
var float FormationGroundOffset, FormationUpdateInterval;
var float FormationDirOffset, FormationDropHeight;

/** Precalculated formation positions, anchors, and blocking volumes */
var array<vector> FormationOffsets;
var array<PLFormationAnchor> FormationAnchors;
var array<PLFormationBlockingVolume> FormationBlockingVolumes;

const MAX_FLOAT = 3.4028e38;

/** Perform some initial setups */
simulated function PostBeginPlay() {
    super.PostBeginPlay();

    CalculateFormationOffsets();

    PopulateBlockingVolumes();

    SetTimer(FormationUpdateInterval, true);
}

/**
 * Performs updates on all the formation anchors to ensure they're all the best
 * position they can be
 */
function Timer() {
    UpdateAnchors();
}

/**
 * Returns whether or not a given position is near anoher formation position.
 * This helps ensures that each formation position is spaced out enough so they
 * don't "collide." Mostly used during the formation offset building process.
 *
 * @param Position - A formation position candidate to test
 * @return TRUE if the given position "collides" with another; FALSE otherwise
 */
function bool IsNearAnotherPosition(vector Position) {
    local int i;

    for (i=0;i<FormationOffsets.length;i++)
        if (VSize(Position - FormationOffsets[i]) < (FormationRadius * 2))
            return true;

    return false;
}

/**
 * Returns whether or not the given location in the world is near anchor. This
 * is used to check if a formation position has been taken or not.
 *
 * @param Position - Location in the world to check for anchors
 * @param IgnoreAnchor - Anchor to ignore when checking for nearby anchors
 * @return TRUE if there is an anchor nearby; FALSE otherwise
 */
function bool IsNearAnotherAnchor(vector Position,
                                  PLFormationAnchor IgnoreAnchor) {
    local int i;

    for (i=0;i<FormationAnchors.length;i++)
        if (FormationAnchors[i] != IgnoreAnchor &&
            VSize(FormationAnchors[i].Location - Position) < FormationRadius)
            return true;

    return false;
}

/**
 * Returns whether or not this anchor is clear of geometry.
 *
 * @param Position - Location in the world to check for geometry
 * @return TRUE if there's enough room; FALSE otherwise
 */
function bool IsClearOfGeometry(vector Position) {
    local int i;
    local rotator TraceRot;
    local vector EndTrace;

    for (i=0;i<GeometryCheckTraces;i++) {
         TraceRot.Yaw = int(65536.0 * (float(i) / float(GeometryCheckTraces)));

         EndTrace = Position + vector(TraceRot) * FormationRadius;

         if (!FastTrace(EndTrace, Position))
             return false;
    }

    return true;
}

/**
 * Returns whether or not the chosen position has a line of sight to the Pawn
 * that we're tracking. This is essential for choosing a good position to
 * shoot the target or to ensure followers can see the Pawn they're protecting
 * as well as possible threats. This also helps prevent choosing of positions
 * that are located through walls
 *
 * @param Position - Location in the world to check if it has a line of sight
 * @return TRUE if the location has a clear line of sight; FALSE otherwise
 */
function bool HasLineOfSightToTarget(vector Position, PLFormationAnchor Anchor) {
	if (Anchor.FormationTarget != None)
		return FastTrace(Anchor.FormationTarget.Location, Position);
	else
		return false;

    /*local vector HitLocation, HitNormal, EndTrace, StartTrace;

    StartTrace = Anchor.FormationTarget.Location;
    EndTrace = Position;

    return (Trace(HitLocation, HitNormal, EndTrace, StartTrace, false) == none);*/
}

/**
 * Returns the best offset that an anchor can use for it's tracking target
 * that's close to the target, and does not interferre with other anchors
 *
 * @param Anchor - PLFormationAnchor object we want to get the offset for
 * @return Offset from the target's location to be used for tracking
 */
function vector GetBestAnchorOffset(PLFormationAnchor Anchor) {
    local int i;
    local float Distance, ClosestDistance;
    local vector FormationPosition, FinalFormationOffset;

    local rotator FormationDir;
    local vector PlayerDirectedLocation;
    local Pawn AnchorTarget, AnchorUser;

    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    ClosestDistance = MAX_FLOAT;

    for (i=0;i<FormationOffsets.length;i++) {

        AnchorUser = Anchor.FormationUser;
        AnchorTarget = Anchor.FormationTarget;
		
		if (AnchorUser == None || AnchorTarget == None)
			continue;

        // First calculate the direction laterally
        if (PlayerController(AnchorTarget.Controller) != none) {

            FormationDir = AnchorTarget.GetViewRotation();
            FormationDir.Pitch = 0;

            StartTrace = AnchorTarget.Location + AnchorTarget.EyePosition();
            EndTrace = StartTrace + vector(FormationDir) * FormationDirOffset;

            Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

            if (Other != none)
                PlayerDirectedLocation = HitLocation;
            else
                PlayerDirectedLocation = EndTrace;

            StartTrace = PlayerDirectedLocation + FormationOffsets[i];
        }
        else if (VSize(FormationOffsets[i]) > MinNPCFormationRadius)
            StartTrace = AnchorTarget.Location + FormationOffsets[i];
        else // Enforce the minimum radius from the NPC
            continue;

        // Next we move down laterally if we didn't hit anything
        if (HasLineOfSightToTarget(StartTrace, Anchor)) {

            EndTrace = StartTrace;
            EndTrace.Z -= FormationDropHeight;

            Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

            // If there's some solid ground underneath that lateral position
            if (Other != none) {
                FormationPosition = HitLocation;
                FormationPosition.Z += FormationGroundOffset;
            }
            else // If not, continue on, walking off a cliff is bad mkay
                continue;
        }
        else // If we don't have a line of sight laterally, just move on
            continue;

        // Now we take not of the distance of the potential formation offset
        if (PlayerController(AnchorTarget.Controller) != none)
            Distance = VSize(FormationPosition - PlayerDirectedLocation);
        else
            Distance = VSize(FormationPosition - AnchorTarget.Location) +
                VSize(FormationPosition - AnchorUser.Location);

        // Finally, we do distance, room, line of sight, and anchor checks
        if (Distance < ClosestDistance &&
            IsClearOfGeometry(FormationPosition) &&
            HasLineOfSightToTarget(FormationPosition, Anchor) &&
            !IsNearAnotherAnchor(FormationPosition, Anchor)) {

            ClosestDistance = Distance;

            FinalFormationOffset = FormationPosition - AnchorTarget.Location;
        }
    }

    return FinalFormationOffset;
}

/**
 * Returns a PLFormationAnchor object that can be used by a AI Controller as
 * a movement goal to follow a target, but not get in the way of other
 * Pawns also following the same target
 *
 * @param User - Pawn that's going to use this anchor
 * @param Target - Pawn that this anchor is going to track
 * @return PLFormationAnchor object
 */
function PLFormationAnchor GetFormationAnchor(Pawn User, Pawn Target) {
    local PLFormationAnchor Anchor;

    Anchor = Spawn(class'PLFormationAnchor');

    if (Anchor != none) {
        Anchor.InitializeAnchor(FormationGroundOffset, User, Target);
        Anchor.SetFormationOffset(GetBestAnchorOffset(Anchor));

        Anchor.UpdateLocation();

        AddAnchor(Anchor);

        return Anchor;
    }

    return none;
}

/** Calculates positions that a Pawn can use as a formation position */
function CalculateFormationOffsets() {
    local int i, Row;
    local vector FormationOffset;
    local rotator TraceRot;

    if (PreCalFormationOffsets <= 0) {
        log("ERROR: Cannot calculate 0 or negative formation positions");
        return;
    }

    while (FormationOffsets.length < PreCalFormationOffsets) {
        for (i=0;i<PreCalRadials;i++) {
            TraceRot.Yaw = int(65536.0 * (float(i) / float(PreCalRadials)));

            FormationOffset = vector(TraceRot) * (MinFormationRadius +
                FormationRadius * Row);

            if (!IsNearAnotherPosition(FormationOffset))
                AddFormationOffset(FormationOffset);
        }

        Row++;
    }
}

/**
 * Populates our FormationBlockingVolumes list with all the volumes currently
 * in the map
 */
function PopulateBlockingVolumes() {
    local PLFormationBlockingVolume FormationBlockingVolume;

    foreach AllActors(class'PLFormationBlockingVolume',
        FormationBlockingVolume) {

        FormationBlockingVolumes.Insert(FormationBlockingVolumes.length, 1);
        FormationBlockingVolumes[FormationBlockingVolumes.length-1] = FormationBlockingVolume;
    }
}

/**
 * Sets all the PLFormationBlockingVolume we have in our list to the specified
 * collision status, ie. either they're blocking collisions or not
 */
function SetBlockingVolumeCollision(bool bNewBlock) {
    local int i;

    for (i=0;i<FormationBlockingVolumes.length;i++)
        FormationBlockingVolumes[i].SetBlocksTraces(bNewBlock);
}

/**
 * Adds a new formation position using the given offset
 *
 * @param FormationOffset - Formation offset to add to our list. We also assume
 *                          that it is a valid in context
 */
function AddFormationOffset(vector FormationOffset) {
    local vector NewFormationOffset;

    NewFormationOffset = FormationOffset;

    FormationOffsets.Insert(FormationOffsets.length, 1);
    FormationOffsets[FormationOffsets.length-1] = NewFormationOffset;
}

/**
 * Adds a new Anchor into our FormationAnchors list
 *
 * @param NewAnchor - Anchor object to add to our list
 */
function AddAnchor(PLFormationAnchor NewAnchor) {
    FormationAnchors.Insert(FormationAnchors.length, 1);
    FormationAnchors[FormationAnchors.length-1] = NewAnchor;
}

/**
 * Removes the given anchor from our list of anchors
 *
 * @param Anchor - Anchor object to remove from our list
 */
function RemoveAnchor(PLFormationAnchor Anchor) {
    local int i;

    for (i=0;i<FormationAnchors.length;i++)
        if (FormationAnchors[i] == Anchor)
            FormationAnchors.Remove(i, 1);

    Anchor.Destroy();
}

/**
 * Updates all the anchors and ensures they're always in the best position
 */
function UpdateAnchors() {
    local int i;
    local PLFormationAnchor Anchor;

    SetBlockingVolumeCollision(true);

    for (i=0;i<FormationAnchors.length;i++) {

        Anchor = FormationAnchors[i];

        Anchor.SetFormationOffset(GetBestAnchorOffset(Anchor));

        Anchor.UpdateLocation();
    }

    SetBlockingVolumeCollision(false);
}

defaultproperties
{
    bHidden=true
}