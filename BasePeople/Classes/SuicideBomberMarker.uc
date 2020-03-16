// Suicide Bomber Marker
// Tell everyone we're here... except the oblivious bandmembers

class SuicideBomberMarker extends TimedMarker;

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
function NotifyControllers()
{
	local FPSPawn CheckP;
	local LambController lambc;
	local P2Player p2p;

	ForEach CollidingActors(class'FPSPawn', CheckP, CollisionRadius)
	{
		// call the appropriate controller
		lambc = LambController(CheckP.Controller);
		if(lambc != None && CheckP != CreatorPawn
			&& CheckP != OriginActor
			&& MarcherController(lambc) == None)
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

	ForEach UseLevel.CollidingActors(class'FPSPawn', CheckP, UseCollisionRadius, Loc)
	{
		// call the appropriate controller
		lambc = LambController(CheckP.Controller);
		if(lambc != None && CheckP != CheckCreatorPawn
			&& CheckP != CheckOriginActor
			&& MarcherController(lambc) == None)
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
}

defaultproperties
{
	CollisionRadius=2000
	CollisionHeight=2000
	Priority=3
}