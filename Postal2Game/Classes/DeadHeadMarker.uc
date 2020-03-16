///////////////////////////////////////////////////////////////////////////////
// Tells everyone about the disembodied head lying here
// Uses same code to know when to go away as dead bodies. 
// The game info's body-disappearing code controls this head also.
///////////////////////////////////////////////////////////////////////////////
class DeadHeadMarker extends DeadBodyMarker;

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
function NotifyControllers()
{
	local FPSPawn CheckP;
	local LambController lambc;
	local P2Player p2p;
	local bool bPlayerNear;

	// If our head is gone, kill ourselves
	if(OriginActor == None)
		Destroy();
	else
	{
		ForEach CollidingActors(class'FPSPawn', CheckP, CollisionRadius, OriginActor.Location)
		{
			// call the appropriate controller
			lambc = LambController(CheckP.Controller);
			if(lambc != None 
				&& CheckP != CreatorPawn
				&& CheckP != OriginActor)
				lambc.MarkerIsHere(class, CreatorPawn, OriginActor, OriginActor.Location);
			else
			{
				if(CheckP.bPlayer)
					bPlayerNear=true;

				p2p = P2Player(CheckP.Controller);
				if(p2p != None)
				{
					p2p.MarkerIsHere(class, CreatorPawn, OriginActor, OriginActor.Location);
				}
			}
		}

		// If the player isn't around and the settings let *bodies* disappear
		// then consider removing yourself from the world (even though we're a head)
		if(P2GameInfo(Level.Game).GetBodiesMax() == 0
			&& !bPlayerNear)
		{
			if ( !OriginActor.PlayerCanSeeMe() )
				OriginActor.Destroy();
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
	local bool bPlayerNear;

	ForEach UseLevel.CollidingActors(class'FPSPawn', CheckP, UseCollisionRadius, Loc)
	{
		// call the appropriate controller
		lambc = LambController(CheckP.Controller);
		if(lambc != None 
			&& CheckP != CheckCreatorPawn
			&& CheckP != CheckOriginActor)
		{
			lambc.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
		}
		else
		{
			p2p = P2Player(CheckP.Controller);
			if(p2p != None)
			{
				bPlayerNear=true;
				p2p.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
			}
		}
	}

		// If the player isn't around and the settings let *bodies* disappear
		// then consider removing yourself from the world (even though we're a head)
		if(P2GameInfo(UseLevel.Game).GetBodiesMax() == 0
			&& !bPlayerNear)
		{
			if ( !CheckOriginActor.PlayerCanSeeMe() )
				CheckOriginActor.Destroy();
		}
}

defaultproperties
{
	CollisionRadius=700
	CollisionHeight=350
	NotifyTime=5.0
	LifeSpan=0
}
