///////////////////////////////////////////////////////////////////////////////
// PickupTravelInv
// 
// Information-based inventory item--not to be 'used' by the player
//
// Keeps track of any type of pickups that has been picked up in a level--only
// for pickups originally placed in the level by the level designers.
///////////////////////////////////////////////////////////////////////////////
class PickupTravelInv extends TravelInv;

///////////////////////////////////////////////////////////////////////////////
// vars and consts
///////////////////////////////////////////////////////////////////////////////
// To just slightly limit the number of inventory items sent with this, each inventory of this
// type can actually count up a certain number of these pickups and record them in an array.
// This can't be too long though, because travel only supports a certain amount of data
// per variables (arrays included)
var travel array<FPSGameState.RecordedPickupInfo> info;

defaultproperties
{
}