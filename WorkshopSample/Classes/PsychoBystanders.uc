///////////////////////////////////////////////////////////////////////////////
// Psycho Bystanders
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This mod creates a new cheat command that makes bystanders freak out.
///////////////////////////////////////////////////////////////////////////////
class PsychoBystanders extends P2GameMod;

///////////////////////////////////////////////////////////////////////////////
// Mutate
// Using this function you can create new console commands for the player to
// use to control your mod.
// The actual command typed by the player is "mutate (whatever)", and the Mutate
// function gives you the "(whatever)" part as a String, it is your job to parse
// this string to find your command and react to it accordingly.
// For a real-world example, see PsychoBystanders.uc
///////////////////////////////////////////////////////////////////////////////
function Mutate(string Params, PlayerController Sender)
{
	Super.Mutate(Params, Sender);
	
	// mutate freakout: causes bystanders to flip the fuck out!
	if (Params ~= "freakout")
	{
		FreakoutBystanders();
	}	
}

///////////////////////////////////////////////////////////////////////////////
// FreakoutBystanders
// Actual function that causes bystanders to flip the fuck out.
///////////////////////////////////////////////////////////////////////////////
function FreakoutBystanders()
{
	local LambController LC;
	local Controller C;
	local Pawn CheckP;
	
	const FREAK_AT_RADIUS = 1000.0;
	
	log(self@"mutate freakout");
	
	// Parse through all controllers in the map, and pluck out the ones we care
	// about (namely lambcontrollers, the base controller of most P2 entities)
	
	// Instead of a DynamicActors iterator, we use a for and loop through
	// the level's ControllerList. This is slightly faster.
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		log(C);
		// only care about lamb controllers
		if (LambController(C) != None)
		{
			LC = LambController(C);
			
			// Do nothing if the pawn is in stasis.
			if (!LC.Pawn.bStasis && !FPSPawn(LC.Pawn).bSliderStasis)
			{
				// What we do here is trigger the AI's "damage attitude" reaction without actually doing any damage.
				// This will cause them to run away from or attack the "scapegoat" pawn we find for them.
				// Also, set them to gun-crazy, so they'll be more likely to shoot things if they have a gun
				P2Pawn(LC.Pawn).bGunCrazy = true;
				ForEach VisibleCollidingActors(class'Pawn', CheckP, FREAK_AT_RADIUS, LC.Pawn.Location)
				{
					// Don't use the player as a patsy
					if (CheckP.Controller != None && !CheckP.Controller.bIsPlayer
						// and don't use dead pawns
						&& CheckP.Health > 0)
					{
						LC.DamageAttitudeTo(CheckP, 1);
						break;	// Only react to one marker
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Default properties required by all P2GameMods.
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	// GroupName - any Game Mods with the same GroupName will be considered incompatible, and only one will be allowed to run.
	// Use this if you make mods that are not designed to run alongside each other.
	GroupName=""
	// FriendlyName - the name of your Game Mod, displayed in the game mod menu.
	FriendlyName="Psycho Bystanders"
	// Description - optional short description of your Game Mod
	Description="Adds a new cheat code! To activate, type 'mutate freakout' in the console (press tilde key to bring up the console)."
}