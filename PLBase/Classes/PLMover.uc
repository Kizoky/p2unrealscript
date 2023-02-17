/**
 * PLMover
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * A special Mover which was designed to ferry the Dude or other pawns
 * through complicated movement. We do this by fully binding them onto this
 * PLMover as opposed to hoping the player doesn't do anything stupid.
 *
 * @author Gordon Cheng
 */
class PLMover extends Mover
    placeable;

var() array<vector> RiderBindOffsets;
var array<Pawn> Riders;

/**
 * Returns the Pawn that the player is currently controlling
 *
 * @param return - Pawn object that the player is currently controlling
 */
function Pawn GetPlayer() {
    local Pawn Player;

    foreach DynamicActors(class'Pawn', Player)
        if (Player.Controller != none && Player.Controller.bIsPlayer)
            return Player;

    return none;
}

/**
 * Returns whether or not a given Pawn object is already a rider on this mover
 *
 * @param Rider - Pawn object to check if he or she is currently a rider
 * @return TRUE if the given Pawn object is currently a rider; FALSE otherwise
 */
function bool IsRider(Pawn Rider) {
    local int i;

    if (Rider == none)
        return false;

    for (i=0;i<Riders.length;i++)
        if (Riders[i] == Rider)
            return true;

    return false;
}

/**
 * Adds a Pawn as a rider on this PLMover
 *
 * @param Rider - Pawn object in the world to teleport and bind to this mover
 */
function AddRider(Pawn Rider) {
    local int BindOffset;
    local vector BindLocation;

    if (Rider == none)
        return;

    Riders.Insert(Riders.length, 1);
    Riders[Riders.length-1] = Rider;

    BindOffset = Riders.length - 1;
    BindOffset = Clamp(BindOffset, 0, RiderBindOffsets.length-1);

    BindLocation = Location + class'P2EMath'.static.GetOffset(Rotation,
        RiderBindOffsets[BindOffset]);

    //Rider.SetPhysics(PHYS_None);
}

/**
 * Removes a Pawn as a rider on this PLMover
 *
 * @param Rider - Pawn object in the world to restore the movement physics of
 */
function RemoveRider(Pawn Rider) {
    local int i;

    if (Rider == none)
        return;

    for (i=0;i<Riders.length;i++)
        if (Riders[i] == Rider)
            Riders.Remove(i, 1);
}

/** Overriding the default Trigger definition in no state to bind the player */
function Trigger(Actor Other, Pawn EventInstigator) {
    local Pawn Player;

    Player = GetPlayer();

    if (!IsRider(Player))
        AddRider(Player);
    else
        RemoveRider(Player);
}

function Tick(float DeltaTime) {
    local int i, BindOffset;
    local vector BindLocation;

    for (i=0;i<Riders.length;i++) {

        BindOffset = Clamp(i, 0, RiderBindOffsets.length-1);

        BindLocation = Location + class'P2EMath'.static.GetOffset(Rotation,
            RiderBindOffsets[BindOffset]);

        Riders[i].SetLocation(BindLocation);
        //Riders[i].Velocity.Z = 0;
    }
}

defaultproperties
{
    MoverEncroachType=ME_IgnoreWhenEncroach
    InitialState=None
}