///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Checkpoint.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class Checkpoint extends Keypoint;

event Touch (Actor Other)
{
	// When the Dude runs over us, call the gameinfo and save.
	if (Pawn(Other) != None
		&& P2Player(Pawn(Other).Controller) != None
		&& P2GameInfoSingle(Level.Game) != None
		&& P2Player(Pawn(Other).Controller).IsSaveAllowed())
	{		
		// Do an auto-save
		P2GameInfoSingle(Level.Game).bDoAutoSave = True;
		P2GameInfoSingle(Level.Game).ReadyForSave(P2Player(Pawn(Other).Controller));
		// Disable future touch events once the checkpoint has been reached.
		Disable('Touch');
	}	
}

defaultproperties
{
	CollisionRadius=300
	CollisionHeight=300	
	bCollideActors=True
	bUseCylinderCollision=True
}
