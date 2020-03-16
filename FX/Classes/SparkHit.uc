//=============================================================================
// SparkHit
// Generic base for spark hits that require a reorientation of a wall
//=============================================================================
class SparkHit extends P2Emitter;

var float velmax;			// how fast to move away

/*
replication
{
	// server sends this to client if enough bandwidth available
	unreliable if(Role==ROLE_Authority)
		FitToNormal;
}
*/

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	FitToNormal(vector(Rotation));

	// Wipe the owner so that in single player, slow motion will work properly.
	// Anything who's owner is player still goes at normal speed, but if not
	// it goes in slow motion. 
	// But we definitely want the owner transferred correctly in MP for network relevance
	if(Level.Game != None
		&& Level.Game.bIsSinglePlayer)
		SetOwner(None);
}

simulated function FitToNormal(vector HNormal)
{
	Emitters[0].StartVelocityRange.X.Max+=HNormal.x*velmax;
	Emitters[0].StartVelocityRange.Y.Max+=HNormal.y*velmax;
	Emitters[0].StartVelocityRange.Z.Max+=HNormal.z*velmax;
	Emitters[0].StartVelocityRange.X.Min+=HNormal.x*velmax;
	Emitters[0].StartVelocityRange.Y.Min+=HNormal.y*velmax;
	Emitters[0].StartVelocityRange.Z.Min+=HNormal.z*velmax;
}

defaultproperties
{
	TransientSoundRadius=120
	bNetOptional=true
	RemoteRole=ROLE_None
}
