///////////////////////////////////////////////////////////////////////////////
// PLBaseGameInfo
// Copyright 2014 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for Paradise Lost game info.
///////////////////////////////////////////////////////////////////////////////
class PLBaseGameInfo extends P2GameInfoSingle;

const MONKEYS_FOR_ACHIEVEMENT = 6;

///////////////////////////////////////////////////////////////////////////////
// In nightmare mode, give the dude a fish radar
///////////////////////////////////////////////////////////////////////////////
event PostTravel(P2Pawn PlayerPawn)
{
	local Inventory InvAdd;
	local P2PowerupInv ppinv;
	local ClothesPickup clothes;

	const NIGHTMARE_RADAR_MIN = 2000;
	
	Super.PostTravel(PlayerPawn);

	// In nightmare mode, give him a radar with a long battery life
	if (InNightmareMode())
	{
		invadd = PlayerPawn.CreateInventoryByClass(class'RadarInv');
		//log(Self$" invadd "$invadd);
		// Make sure they have enough--if you have more than this, that's fine.
		ppinv = P2PowerupInv(invadd);
		if(ppinv != None
			&& ppinv.Amount < NIGHTMARE_RADAR_MIN)
			ppinv.SetAmount(NIGHTMARE_RADAR_MIN);
			
		// Force it to activate immediately if not already active.
		if (ppinv != None
			&& !ppinv.IsInState('Operating'))
			ppinv.Activate();

		// Delete clothes pickups the dude could use to sneak around town.
		foreach DynamicActors(class'ClothesPickup', clothes)
		{
			if (!clothes.bUseForErrands
				&& DudeClothesPickup(Clothes) == None
				&& GimpClothesPickupErrand(Clothes) == None)
				clothes.Destroy();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// The player has watched the last movie in the game and successfully beaten
// the game! Put up the stats screen as we load the main menu.
///////////////////////////////////////////////////////////////////////////////
function EndOfGame(P2Player player)
{
	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();

	// Set that you want the stats
	bShowStatsDuringLoad=true;

	// Send player to main menu
	SendPlayerTo(player, MainMenuURL);
}

///////////////////////////////////////////////////////////////////////////////
// Reach into entry and put a new reference to every chameleon texture/meshes in this
// level.
///////////////////////////////////////////////////////////////////////////////
function StoreChams()
{
	local LevelInfo lev;
	local TextureLoader texl;
	local MeshLoader mesher;
	local Actor checkme;
	local PersonPawn checkpawn;

	lev = GetPlayer().GetEntryLevel();

	//log(self$" StoreChams "$lev);

	foreach lev.AllActors(class'Actor', checkme)
	{
		if(TextureLoader(checkme) != None)
			texl = TextureLoader(checkme);
		else if(MeshLoader(checkme) != None)
			mesher = MeshLoader(checkme);
	}

	//log(self$" checking texture loader "$mesher$" mesh loader "$mesher);
	if(texl != None
		&& mesher != None)
	{
		// Clear the lists
		texl.ClearArray();
		mesher.ClearArray();
		// Now go through each pawn and put their textures/meshes into the list
		foreach DynamicActors(class'PersonPawn', checkpawn)
		{
			texl.AddTexture(checkpawn.Skins[0]);
			mesher.AddMesh(checkpawn.Mesh);
			if(checkpawn.MyHead != None)
			{
				texl.AddTexture(checkpawn.MyHead.Skins[0]);
				mesher.AddMesh(checkpawn.MyHead.Mesh);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function MonkeySurvived(Pawn Monkey)
{
	local P2Player Achiever;
	PLBaseGameState(TheGameState).MonkeysSurvived++;
	if (PLBaseGameState(TheGameState).MonkeysSurvived >= MONKEYS_FOR_ACHIEVEMENT)
	{
		Achiever = GetPlayer();
		if(Level.NetMode != NM_DedicatedServer ) Achiever.GetEntryLevel().EvaluateAchievement(Achiever,'PLMonkeysSurvived');
	}
}
function MonkeyDied(Pawn Monkey)
{
	PLBaseGameState(TheGameState).MonkeysLost++;
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	GameSpeed=1.000000
	MaxSpectators=2
	KissEmitterClass=class'FX2.KissEmitter'
}