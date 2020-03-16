//=============================================================================
// FirePuddleMolotov.
//=============================================================================
class FirePuddleMolotov extends FirePuddle;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	if(Emitters.Length > 0)
		Emitters[0].StartLocationRange.X.Max = 0;

	Super.PostBeginPlay();
}


defaultproperties
{
}
