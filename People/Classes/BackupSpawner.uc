///////////////////////////////////////////////////////////////////////////////
// Spawner
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Spawns special people for backup situations.
//
///////////////////////////////////////////////////////////////////////////////

class BackupSpawner extends PawnSpawner;

var () array<class<Pawn> > ClassForDay;		// Class to be spawned for this day.

///////////////////////////////////////////////////////////////////////////////
// Get the class of backup guy to spawn for this particular day
///////////////////////////////////////////////////////////////////////////////
function class<Actor> GetSpawnClass()
{
	return ClassForDay[P2GameInfoSingle(Level.Game).TheGameState.CurrentDay];
}


defaultproperties
{
	ClassForDay[0]=class'CopBlue'
	ClassForDay[1]=class'CopBlack'
	ClassForDay[2]=class'CopBrown'
	ClassForDay[3]=class'Military'
	ClassForDay[4]=class'SWAT'
}

