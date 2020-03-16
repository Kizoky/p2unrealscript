///////////////////////////////////////////////////////////////////////////////
// Asset Replacer
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it as a basis for your own game mods.
//
// This is a mod that reads in a list of textures and sounds in the default
// properties, and attempts to replace them in-game wherever possible.
//
// Limitations:
// * BSP surfaces can't be messed with. If you want to change the texture on
//   a wall, rebuild the map and include it with your mod.
// * Dialog won't be replaced. Script a new dialog class and assign it to
//   the desired pawns.
// * Some classes change materials or sounds on the fly; this mod won't change
//   those.
// * Certain specific sounds or skins won't be replaced, you'll have to change
//   them manually.
///////////////////////////////////////////////////////////////////////////////
class AssetReplacer extends P2GameMod;

struct MaterialReplaceStruct {
	var() Material OldMaterial, NewMaterial;
};

struct SoundReplaceStruct {
	var() Sound OldSound, NewSound;
};

var() array<MaterialReplaceStruct> MaterialReplace;
var() array<SoundReplaceStruct> SoundReplace;

///////////////////////////////////////////////////////////////////////////////
// ReplaceMaterial
// Attempts to replace passed-in material
///////////////////////////////////////////////////////////////////////////////
function Material ReplaceMaterial(Material ReplaceMe)
{
	local int i;
	
	for (i = 0; i < MaterialReplace.Length; i++)
	{
		if (ReplaceMe == MaterialReplace[i].OldMaterial)
			return MaterialReplace[i].NewMaterial;
	}
	
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// ReplaceSound
// Attempts to replace passed-in sound
///////////////////////////////////////////////////////////////////////////////
function Sound ReplaceSound(Sound ReplaceMe)
{
	local int i;
	
	for (i = 0; i < SoundReplace.Length; i++)
	{
		if (ReplaceMe == SoundReplace[i].OldSound)
			return SoundReplace[i].NewSound;
	}
	
	return None;
}

///////////////////////////////////////////////////////////////////////////////
// ParseActor
// Looks to replace any textures, sounds on new actor
///////////////////////////////////////////////////////////////////////////////
function ParseActor(Actor Other)
{
	local int i, j;
	local Material NewMaterial;
	local Sound NewSound;
	local Name NewName;
	
	if (Other == None)
		return;
	
	// Try Actor skins and sounds
	for (i = 0; i < Other.Skins.Length; i++)
	{
		NewMaterial = ReplaceMaterial(Other.Skins[i]);
		if (NewMaterial != None)
			Other.Skins[i] = NewMaterial;
	}
	NewMaterial = ReplaceMaterial(Other.Texture);
	if (NewMaterial != None)
		Other.Texture = NewMaterial;
	NewSound = ReplaceSound(Other.AmbientSound);
	if (NewSound != None)
		Other.AmbientSound = NewSound;
		
	// Emitters.
	if (Emitter(Other) != None)
	{
		for (i = 0; i < Emitter(Other).Emitters.Length; i++)
		{
			NewMaterial = ReplaceMaterial(Emitter(Other).Emitters[i].Texture);
			if (Texture(NewMaterial) != None)
				Emitter(Other).Emitters[i].Texture = Texture(NewMaterial);
		}
	}
	
	// Sound Things
	if (SoundThing(Other) != None)
	{
		for (i = 0; i < SoundThing(Other).Settings.Sounds.Length; i++)
		{
			NewSound = ReplaceSound(SoundThing(Other).Settings.Sounds[i]);
			if (NewSound != None)
				SoundThing(Other).Settings.Sounds[i] = NewSound;
		}
	}
	
	// Pistol.
	if (PistolWeapon(Other) != None)
	{
		NewSound = ReplaceSound(PistolWeapon(Other).FireSound);
		if (NewSound != None)
			PistolWeapon(Other).FireSound = NewSound;
	}
}

///////////////////////////////////////////////////////////////////////////////
// CheckReplacement
// This function is called for any actor spawned into the world.
// You can use this function to change any default properties of that actor,
// or replace it entirely with something else using ReplaceWith.
// Return FALSE if you replace the actor or just want it to be destroyed.
// Return TRUE if you want to keep the actor and don't want to replace it.
// Unlike other functions you do NOT need to call Super here.
///////////////////////////////////////////////////////////////////////////////
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	ParseActor(Other);
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// ModifyNPC
// Called by PersonController/AnimalController after adding default inventory.
// Use this function to alter any aspect of the NPC you like.
// At this point the pawn's head and body are set, so we can change their skins
// now!
///////////////////////////////////////////////////////////////////////////////
function ModifyNPC(Pawn Other)
{
	local int i;
	Super.ModifyNPC(Other);
	
	// Do both the body and head separately.
	ParseActor(Other);
	if (P2MocapPawn(Other) != None)
	{
		ParseActor(P2MocapPawn(Other).MyHead);
		// And while we're at it get the boltons too
		for (i = 0; i < P2MocapPawn(Other).MAX_BOLTONS; i++)
			ParseActor(P2MocapPawn(Other).Boltons[i].part);
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
	FriendlyName="Asset Replacer"
	// Description - optional short description of your Game Mod
	Description="Replaces textures and sounds in-game."
	
	MaterialReplace[0]=(OldMaterial=Texture'AnimalSkins.Dog',NewMaterial=Texture'Engine.DefaultTexture')
	MaterialReplace[1]=(OldMaterial=Texture'ChameleonSkins.MB__033__Avg_M_SS_Pants',NewMaterial=Texture'Engine.DefaultTexture')
	SoundReplace[0]=(OldSound=Sound'AnimalSounds.insects.katydid1',NewSound=Sound'AmbientSounds.fart4')
}