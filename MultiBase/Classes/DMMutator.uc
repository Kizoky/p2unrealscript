//=============================================================================
// DMMutator.
//=============================================================================

class DMMutator extends Mutator;

var() globalconfig bool bMegaSpeed;
var() globalconfig float AirControl; 

function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function ModifyPlayer(Pawn Other)
{
	Other.AirControl = AirControl;

	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.

	bSuperRelevant = 1;
	if ( Pawn(Other) != None )
	{
		Pawn(Other).AirControl = AirControl;
		Pawn(Other).bAutoActivate = true;
		if ( bMegaSpeed )
		{
			Pawn(Other).GroundSpeed *= 1.4;
			Pawn(Other).WaterSpeed *= 1.4;
			Pawn(Other).AirSpeed *= 1.4;
			Pawn(Other).AccelRate *= 1.4;
		}
	}
	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
	 AirControl=+0.35
	 DefaultWeaponName="Inventory.PistolWeapon"
}