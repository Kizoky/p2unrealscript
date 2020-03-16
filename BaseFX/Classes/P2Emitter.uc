///////////////////////////////////////////////////////////////////////////////
// Buffer emitter class for Postal 2 stuff
//
// Different because set bNoDelete here so we can spawn our effects dynamically
///////////////////////////////////////////////////////////////////////////////
class P2Emitter extends Emitter
	native;

native singular function FireHurtRadius(
	float DamageAmount,
	float DamageRadius,
	class<DamageType> DamageType,
	vector LineStart,
	vector LineEnd,
	float DefColRadius,
	float DefColHeight);

native function bool ThickLineCylinderCollide(vector startpt, vector endpt, 
									   float lineradius, float lineheight, 
									   vector ActorLoc, float ActorRad, float ActorHeight);
	
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
simulated function Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;

	log(self$" trigger ");

	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].Disabled = !Emitters[i].Disabled;
	}

}

///////////////////////////////////////////////////////////////////////////
// Make it go in a certain direction and stretch a certain distance
///////////////////////////////////////////////////////////////////////////
simulated function SetDirection(vector Dir, float Dist)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// This is happening on a client, or the guy's machine who is running
// the listen server (no dedicated server)
///////////////////////////////////////////////////////////////////////////////
simulated function bool NotDedOnServer()
{
	local Pawn checkpawn;
	//log(self$" net mode "$Level.NetMode$" role "$Role$" viewport "$ViewPort(PlayerController(Instigator.Controller).Player));

	checkpawn = Pawn(Owner);

	return (Level.NetMode == NM_Client
			|| Level.NetMode == NM_Standalone
			|| (Level.NetMode == NM_ListenServer
				&& Role == ROLE_Authority
				&& checkpawn != None
				&& ViewPort(PlayerController(checkpawn.Controller).Player) != None));
}

///////////////////////////////////////////////////////////////////////////////
// Stops only this emitter
///////////////////////////////////////////////////////////////////////////////
simulated function SelfDestroyOne(int StopI, optional bool bDisable)
{
	if(StopI < Emitters.Length)
	{
		Emitters[StopI].RespawnDeadParticles=False;
		Emitters[StopI].ParticlesPerSecond=0;
		if(bDisable)
			Emitters[StopI].Disabled=true;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Stops emitted, but let's the last particles still out there to finish up
// then it dies
///////////////////////////////////////////////////////////////////////////////
simulated function SelfDestroy(optional bool bDisable)
{
	local int i;

	AutoDestroy=true;
	for(i=0; i<Emitters.length; i++)
	{
		Emitters[i].RespawnDeadParticles=False;
		Emitters[i].AutomaticInitialSpawning=false;
		if(bDisable)
			Emitters[i].Disabled=true;
		//Emitters[i].ParticlesPerSecond=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Just a little randomness for the pitch, around 1.0
///////////////////////////////////////////////////////////////////////////////
simulated function float GetRandPitch()
{
	return (0.96 + FRand()*0.08);
}

defaultproperties
{
	bNoDelete=false
	bReplicateMovement=false
	Mass=0
}
