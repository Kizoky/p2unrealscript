///////////////////////////////////////////////////////////////////////////////
// DoorTravelInv
// 
// Information-based inventory item--not to be 'used' by the player
//
// Keeps track of dead pawns that are to be persistantly dead in the game (once
// they die)
///////////////////////////////////////////////////////////////////////////////
class DoorTravelInv extends TravelInv;

///////////////////////////////////////////////////////////////////////////////
// vars and consts
///////////////////////////////////////////////////////////////////////////////
var travel array<GameState.PersistentDoorInfo> info;

defaultproperties
{
}