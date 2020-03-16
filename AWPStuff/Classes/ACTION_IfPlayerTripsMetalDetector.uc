// ACTION_IfPlayerTripsMetalDetector
// This is a custom scripted action for the metal detector at the school.
// In AW, the metal detector beeps even if you're empty-handed -- I want to avoid that here, because
// there's a chance the dude might not have any metal weapons, and cannot trigger the metal detector.
class ACTION_IfPlayerTripsMetalDetector extends P2ScriptedAction;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var(Action) bool Is;	// True means we want to trigger if the player is carrying metal

///////////////////////////////////////////////////////////////////////////////
// IsMetal
// Compares Inv with known metal inventory items -- mainly weapons
///////////////////////////////////////////////////////////////////////////////
function bool IsMetal(Inventory Inv)
{
	if (Inv.IsA('AlternatorInv') // Make an exception for the alternator, since it's fricking huge
		|| Inv.IsA('MacheteWeapon')
		|| Inv.IsA('MaDBloodWeapon')
		|| Inv.IsA('CatableWeapon')
		|| Inv.IsA('GrenadeWeapon')
		|| Inv.IsA('MaDColtWeapon')
		|| Inv.IsA('MaDShurikenWeapon')
		|| Inv.IsA('MaDSPistolWeapon')
		|| Inv.IsA('MaDSSniperWeapon')
		|| Inv.IsA('NapalmWeapon')
		|| Inv.IsA('ChainsawWeapon')
		|| Inv.IsA('PistolWeapon')
		|| Inv.IsA('RifleWeapon')
		|| Inv.IsA('SawnOffWeapon')
		|| Inv.Class == class'ShovelWeapon' // Baton and foot are subclasses of shovel, so don't detect it with IsA
		|| Inv.Class == class'ShovelWeaponSS'
		|| Inv.IsA('BaseballBatWeapon')
		|| Inv.IsA('SMEGWeapon'))
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProceedToNextAction(ScriptedController C)
{
	local bool bResult;
	local P2GameInfoSingle UseGame;
	local Pawn P;
	local P2Player PlayerC;
	local Inventory Inv;

	UseGame = P2GameInfoSingle(C.Level.Game);
	if(UseGame != None)
	{
		PlayerC = UseGame.GetPlayer();
		if (PlayerC != None)
			P = PlayerC.Pawn;
		if (PlayerC != None && P != None)
		{
			Inv = P.Inventory;
			// Keep looping until we're at the end of the inventory list or we find a metal weapon
			while (Inv != None && !IsMetal(Inv))
				Inv = Inv.Inventory;
			if (Inv == None) // Inv == None means there was no metal weapon detected
				bResult = !Is;
			else
				bResult = Is;
		}
		else
		{
			warn("PlayerController or player pawn not valid!");
		}
	}
	else
		warn("GameInfo not valid!");

	C.ActionNum += 1;
	if (!bResult)
		ProceedToSectionEnd(C);
}

function bool StartsSection()
{
	return true;
}

function string GetActionString()
{
		return ActionString@"is"@Is;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	Is=true
	ActionString="If dude trips metal detector"
	bRequiresValidGameInfo=true
}
