///////////////////////////////////////////////////////////////////////////////
// This marks that there is something important in this area. People can search
// for these to determine if they should react. Pawns/weapons
// can search for these to see if they need to make more of these.
///////////////////////////////////////////////////////////////////////////////
class TimedMarker extends Keypoint;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////

var int		Priority;			// How important you are
var bool	bCreatorIsAttacker;	// The creator actually did something violent if this is set
var FPSPawn	CreatorPawn;	// Pawn that made this thing
var Actor	OriginActor;	// Actor that sound was initiated around (not necessarily
							// the one who made the sound) like if someone was shot
							// then he is the origin and the shooter is the creator.

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
function NotifyControllers()
{
	local FPSPawn CheckP;
	local LambController lambc;
	local P2Player p2p;
	
	local ShortCircuitScanner ShortCircuit;

	ForEach CollidingActors(class'FPSPawn', CheckP, CollisionRadius)
	{
		// call the appropriate controller
		lambc = LambController(CheckP.Controller);
		if(lambc != None && CheckP != CreatorPawn
			&& CheckP != OriginActor)
			lambc.MarkerIsHere(class, CreatorPawn, OriginActor, Location);
		else
		{
			p2p = P2Player(CheckP.Controller);
			if(p2p != None)
			{
				p2p.MarkerIsHere(class, CreatorPawn, OriginActor, Location);
			}
		}
	}
	
	foreach RadiusActors(class'ShortCircuitScanner', ShortCircuit, CollisionRadius)
	    if (ShortCircuit != none)
		    ShortCircuit.NotifyMarker(self);
}

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
static function NotifyControllersStatic(LevelInfo UseLevel,
										class<TimedMarker> UseClass,
										FPSPawn CheckCreatorPawn,
										Actor CheckOriginActor,
										float UseCollisionRadius,
										vector Loc)
{
	local FPSPawn CheckP;
	local LambController lambc;
	local P2Player p2p;
	
	local ShortCircuitScanner ShortCircuit;

	ForEach UseLevel.CollidingActors(class'FPSPawn', CheckP, UseCollisionRadius, Loc)
	{
		// call the appropriate controller
		lambc = LambController(CheckP.Controller);
		if(lambc != None && CheckP != CheckCreatorPawn
			&& CheckP != CheckOriginActor)
		{
			lambc.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
		}
		else
		{
			p2p = P2Player(CheckP.Controller);
			if(p2p != None)
			{
				p2p.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
			}
		}
	}
	
	foreach UseLevel.RadiusActors(class'ShortCircuitScanner', ShortCircuit, UseCollisionRadius, Loc)
	    if (ShortCircuit != none)
		    ShortCircuit.NotifyMarkerClass(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
}

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
function NotifyAndDie()
{
	NotifyControllers();
	// get rid of me now
	Destroy();
}

defaultproperties
{
	 bStatic=False
     bCollideActors=True
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
	 bBlockNonZeroExtentTraces=False
	 bBlockZeroExtentTraces=False
}
