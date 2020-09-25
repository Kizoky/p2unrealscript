///////////////////////////////////////////////////////////////////////////////
// FluidPourFeederMP.uc
// Copyright 2019 Running With Scissors.  All Rights Reserved.
// by NickP, nickp@gopostal.com
//
// Replicated FluidPourFeeder actor.
//
///////////////////////////////////////////////////////////////////////////////
class FluidPourFeederMP extends FluidPourFeeder;

simulated function bool IsListenViewport()
{
	local Pawn checkpawn;

	checkpawn = Pawn(Owner);

	return (Level.NetMode == NM_ListenServer
		&& Role == ROLE_Authority
		&& checkpawn != None
		&& (ViewPort(PlayerController(checkpawn.Controller).Player) != None
			|| PersonController(checkpawn.Controller) != None));
}

simulated function PostBeginPlay()
{
	local int i;
	if(Level.NetMode != NM_Standalone && Role == ROLE_Authority && !IsListenViewport())
	{
		for(i = 0; i < Emitters.Length; i++)
		{
			Emitters[i].Disabled = true;
		}
	}
	Super.PostBeginPlay();
}

simulated state Pouring
{
	simulated function Tick(float DeltaTime)
	{
		local vector Dir;
		local Rotator UseRot;
		local float OwnerPitch;

		if(Level.NetMode != NM_Standalone)
		{
			// Exclusively for napalm projectiles/etc
			if(Base != None && Pawn(Base) == None)
			{
				UseRot = Base.Rotation;
				Dir = vector(UseRot);
				SetDir(Location, Dir);
			}
			// The rest of pour feeders use pawn as base
			else if(Pawn(Owner) != None && !Pawn(Owner).bDeleteMe)
			{
				OwnerPitch = Pawn(Owner).ViewPitch * 256;     
				if (OwnerPitch > 32768) 
					OwnerPitch -= 65536;

				UseRot = Owner.Rotation;
				UseRot.Pitch = OwnerPitch;
				Dir = vector(UseRot);

				SetDir(Location, Dir);
				SetBase(Owner);
			}
		}
		Global.Tick(DeltaTime);
	}
}

defaultproperties
{
	bUpdateSimulatedPosition=true
	bReplicateMovement=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}
