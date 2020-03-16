class ACTION_RemoveNonMoviePawns extends ScriptedAction;

// This uses the CenterTag actor as the epicenter for sphere inside which all
// fpspawns will be put into sliderstasis. The player won't go and most special
// pawns won't. This is used to get rid of any unwanted pawns around an important movie.

// Scratch that!! Pawns just get killed--they don't get put into slider stasis
// but I left the comments and code in, if you want them to do that instead.

var(Action) name   CenterTag;			// Tag of thing you want to use as the location and radius
										// around which you'll remove pawns in this level.
var(Action) float	RemoveAmount;		// 0 to 1.0 of how many to remove. eg: 0.2 will remove 20 percent of them.

function bool InitActionFor(ScriptedController C)
{
	local Actor CenterActor;
	local FPSPawn checkpawn;

	if(CenterTag != 'None')
	{
		ForEach C.AllActors(class'Actor', CenterActor, CenterTag)
			break;

		if(CenterActor != None)
		{
			foreach CenterActor.RadiusActors(class'FPSPawn', checkpawn, CenterActor.CollisionRadius, CenterActor.Location)
			{
				if(!checkpawn.bKeepForMovie)
				{
					// Just kill them! We used to put them into slider stasis but that
					// caused problems when the popped back in during the movie.
					if(FPSController(checkpawn.Controller) != None
						&& FRand() < RemoveAmount)
						checkpawn.Destroy();

					/*
					// This tries to put them in slider stasis
					if(FPSController(checkpawn.Controller) != None)
						FPSController(checkpawn.Controller).GoIntoSliderStasis();
					// otherwise, it leaves dead bodies alone
					*/
				}
			}
		}
	}

	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Remove Non Movie Pawns"
	RemoveAmount=1.0
}
