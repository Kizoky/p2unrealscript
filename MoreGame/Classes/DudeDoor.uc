///////////////////////////////////////////////////////////////////////////////
// Door Mover only useable by a dude.
///////////////////////////////////////////////////////////////////////////////
class DudeDoor extends DoorMover;

//-----------------------------------------------------------------------------
// External
var ()bool bOnlyDudeAsCop;	// Only allow the dude, and only when he's a cop
var ()bool bOnlyDudeInAnyDisguise;	// Only allow the dude, but it can be any disguise
var ()bool bAllowNPCs;		// Others CAN use it. defaults to false
// Internal.


///////////////////////////////////////////////////////////////////////////////
// Functions
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(MyMarker != None
		&& !bAllowNPCs)
		MyMarker.bBlocked=true;
}

///////////////////////////////////////////////////////////////////////////////
// Check if locked in the direction your coming
// If it's locked your way, you can't go through. 
// If it's unlocked your way, then unlock it both
// ways, unless it's supposed to stay locked.
// Return bool says if you can open it that way (thedot) or not
///////////////////////////////////////////////////////////////////////////////
function bool OperateLock(float thedot, Actor Other)
{
	local byte LockedThisSide;
	local bool ret;
	local P2Pawn OtherUser;
	local P2Player p2p;

	OtherUser = P2Pawn(Other);

	if(OtherUser != None)
	{
		p2p = P2Player(OtherUser.Controller);
		if(p2p != None)
		{
			// handle player cases
			if(bOnlyDudeAsCop)
			{
				return p2p.DudeIsCop();
			}
			// and in other disguises here!
			else
				return true;	// I can use it by default unless a disguise is specified.
		}
		else if(bAllowNPCs)	
			return Super.OperateLock(thedot, Other);
	}
	else if(bAllowNPCs)	
	{
		// normal people just don't get through this door, unless the bool says
		// then it's normal lock operations.
		return Super.OperateLock(thedot, Other);
	}

	return false;
}

defaultproperties
{
}