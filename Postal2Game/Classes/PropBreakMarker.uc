///////////////////////////////////////////////////////////////////////////////
// Someone (probably the dude) has broken something like a window
// and we want to tell people about it. Don't generate these
// for every stinkin broken prop.. well.. maybe.
///////////////////////////////////////////////////////////////////////////////
class PropBreakMarker extends TimedMarker;

defaultproperties
{
	CollisionRadius=1700
	CollisionHeight=1700
	Priority=3
}