///////////////////////////////////////////////////////////////////////////////
// Tells everyone about the dead body here
///////////////////////////////////////////////////////////////////////////////
class DeadBodyMarker extends BlipMarker;

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made
///////////////////////////////////////////////////////////////////////////////
function NotifyControllers()
{
	local FPSPawn CheckP;
	local LambController lambc;
	local P2Player p2p;
	local bool bPlayerNear;

	// If our pawn died, kill ourselves
	if(FPSPawn(OriginActor) == None)
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

		// If the player isn't around and the settings let bodies disappear
		// then consider removing yourself from the world
		// If the pawn is persistent, we can't let the body disappear--gamestate
		// needs to record it being dead on a level transfer.
		if(FPSPawn(OriginActor) != None
			&& P2GameInfo(Level.Game) != None
			&& P2GameInfo(Level.Game).CanRemoveThisBody(FPSPawn(OriginActor))
			&& FPSPawn(OriginActor).bBodyDisappears
			&& !FPSPawn(OriginActor).bPersistent
			&& !FPSPawn(OriginActor).bPlayer
			&& !bPlayerNear)
		{
				FPSPawn(OriginActor).TryToRemoveDeadBody();
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

	// If the player isn't around and the settings let bodies disappear
	// then consider removing yourself from the world
	// If the pawn is persistent, we can't let the body disappear--gamestate
	// needs to record it being dead on a level transfer.
	if(P2GameInfo(UseLevel.Game) != None
		&& P2GameInfo(UseLevel.Game).CanRemoveThisBody(FPSPawn(CheckOriginActor))
		&& FPSPawn(CheckOriginActor) != None
		&& FPSPawn(CheckOriginActor).bBodyDisappears
		&& !FPSPawn(CheckOriginActor).bPersistent
		&& !FPSPawn(CheckOriginActor).bPlayer
		&& !bPlayerNear)
	{
		FPSPawn(CheckOriginActor).TryToRemoveDeadBody();
	}
}

defaultproperties
{
	CollisionRadius=900
	CollisionHeight=350
	NotifyTime=5.0
	LifeSpan=0
}
