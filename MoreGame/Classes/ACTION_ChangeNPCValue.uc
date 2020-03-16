///////////////////////////////////////////////////////////////////////////////
// ACTION_ChangeNPCValue.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Directly set some editable value on the fly. (Like make people
// go into riot mode, only after a movie plays, so before that, they're normal).
// Only change the value for the pawns with the tag given (and only ones that are alive).
// This can only change on value at a time.
//
///////////////////////////////////////////////////////////////////////////////
class ACTION_ChangeNPCValue extends P2ScriptedAction;

enum EValue
	{
	EV_bRiotMode,
	EV_bGunCrazy
	};

var(Action) EValue	ChangeValue;
var(Action) float	ChangeNumber;
var(Action) bool	ChangeBoolean;
var(Action) name	NPCTag;

function bool InitActionFor(ScriptedController C)
{
	local FPSPawn checkpawn;

	foreach C.AllActors(class'FPSPawn', checkpawn, NPCTag)
	{
		//log(" init action "$checkpawn);
		if(checkpawn.Health > 0)
		{
			switch(ChangeValue)
			{
				case EV_bRiotMode:
					checkpawn.bRiotMode=ChangeBoolean;
					break;
				case EV_bGunCrazy:
					if(AnimalPawn(checkpawn) != None)
						AnimalPawn(checkpawn).bGunCrazy=ChangeBoolean;
					else if(P2Pawn(checkpawn) != None)
						P2Pawn(checkpawn).bGunCrazy=ChangeBoolean;
					break;
			}
		}
	}
	return false;
}

defaultproperties
	{
	ActionString="ChangeNPCValue"
	}
