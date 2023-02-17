///////////////////////////////////////////////////////////////////////////////
// PawnDildoedMarker
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Pawn got dildoed here... no not in that way you sick fuck >:O
// But anyway the regular PawnBeatenMarker wasn't making enough "noise" for
// Habib to react to it.
///////////////////////////////////////////////////////////////////////////////
class PawnDildoedMarker extends TimedMarker;

///////////////////////////////////////////////////////////////////////////////
// Tell the controllers i've been made, but only if they can see me
///////////////////////////////////////////////////////////////////////////////
function NotifyControllers()
{
	local FPSPawn CheckP;
	local PersonController personc;
	local AnimalController animalc;
	local P2Player p2p;

	ForEach CollidingActors(class'FPSPawn', CheckP, CollisionRadius)
	{
		// People have to see the attack to notice it.
		personc = PersonController(CheckP.Controller);
		if(personc != None 
			&& CheckP != CreatorPawn
			&& CheckP != OriginActor)
			personc.MarkerIsHere(class, CreatorPawn, OriginActor, Location);
		else
		{
			// Animals psychically know beating attacks even if they can't see them
			animalc = AnimalController(CheckP.Controller);
			if(animalc != None 
				&& CheckP != CreatorPawn
				&& CheckP != OriginActor)
				animalc.MarkerIsHere(class, CreatorPawn, OriginActor, Location);
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
	local PersonController personc;
	local AnimalController animalc;
	local P2Player p2p;

	ForEach UseLevel.CollidingActors(class'FPSPawn', CheckP, UseCollisionRadius, Loc)
	{
		// People have to see the attack to notice it.
		personc = PersonController(CheckP.Controller);
		if(personc != None 
			&& CheckP != CheckCreatorPawn
			&& CheckP != CheckOriginActor)
			personc.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
		else
		{
			// Animals psychically know beating attacks even if they can't see them
			animalc = AnimalController(CheckP.Controller);
			if(animalc != None 
				&& CheckP != CheckCreatorPawn
				&& CheckP != CheckOriginActor)
				animalc.MarkerIsHere(UseClass, CheckCreatorPawn, CheckOriginActor, Loc);
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
}

defaultproperties
{
	CollisionRadius=768
	CollisionHeight=512
//	UseLifeMax=3.0
	Priority=5
	bCreatorIsAttacker=true
}