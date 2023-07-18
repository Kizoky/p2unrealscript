///////////////////////////////////////////////////////////////////////////////
// DayBase
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Describes a day and the errands you need to do on it.
//
// History:
//	07/11/02 MJR	Minor cleanup.
//
///////////////////////////////////////////////////////////////////////////////
class DayBase extends Object
	editinlinenew;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

enum GuyTypeEnum
	{
	GTE_BOTH,										// Okay for good and evil dude
	GTE_EVIL,										// Okay for evil dude
	GTE_GOOD										// Okay for good dude
	};

struct DayInventoryStruct
	{
	var() const Name			InvClassName;		// Class of inventory to remove/give
	var() const int				NeededAmount;		// Make sure the player has at least this much of the item (default of 0 is ok)
	var() const GuyTypeEnum		GuyType;			// Defaults to both dudes get this thing. 
	var() const bool			bEnhancedOnly;		// Only get it in enhanced mode
	};

var() const localized String	Description;		// Name of day (ex: 'Monday')
var() const String				UniqueName;			// A unique day name so code can refer to specific days.
													// This is used by the P2GameInfoSingle to determine if things
													// are needed for this day. This name is put into the Groups
													// for an actor to specify if it needs to *only* be on this day.

var() const array<string>		ExcludeDays;		// This is a list of other group names that also need to be
													// excluded by this day. A common example is having demo objects
													// in the normal game. You don't want some demo specific things
													// in the level and you don't want demo specific pats in the nomral game.

var() const name				MapTex;				// Map texture for this day
var() const name				NewsTex;			// Newspaper texture for this day
var() const name				DudeNewsComment;	// Dude comment about newspaper
var() const name				LoadTex;			// Loading texture for this day
var() const name				DudeStartComment;	// Dude comment about starting errands
var() const export editinline array<ErrandBase> Errands;	// Errands to do this day
var() const String				EndOfDayComment;	// Specialized end-of-day comment on map screen

var() const export editinline array<DayInventoryStruct> PlayerInvList;		// Things given to player when day starts
var() const export editinline array<DayInventoryStruct> TakeFromPlayerList;	// Things taken from player when day starts

var() const String				StartDayURL;		// URL of starting map for this day. Gameinfo prefers this over
													// the gameinfo's version, if it's defined.
													// Exception: First day's start URL must be defined in the GameInfo.
var() const String				FinishedDayURL;		// URL of ending map for this day. Gameinfo prefers this if defined	
var() const String				JailURL;			// URL of jail map for this day. Gameinfo prefers this if defined												

var int							ActiveErrands;		// Cached number of active errands (to make it faster)

// xPatch 2.0
// Classic Loading Screens
//var globalconfig bool bClassicLoad;
var array<Texture> SteamLoadTex;
var array<Texture> ClassicLoadTex;

///////////////////////////////////////////////////////////////////////////////
// After traveling this is called to reset this object to it's "normal" state.
// This is necessary because this object is NOT destroyed by traveling.
///////////////////////////////////////////////////////////////////////////////
function PostTravelReset()
	{
	ActiveErrands = -1;
	}

///////////////////////////////////////////////////////////////////////////////
// Take the player pawn and add these things in
///////////////////////////////////////////////////////////////////////////////
function AddInStartingInventory(P2Pawn PlayerPawn)
{
	local int i;
	local Inventory invadd;
	local P2PowerupInv ppinv;
	local P2GameInfoSingle checkg;
	local bool bverified;
	
	//log(self$" adding in starting inventory, length "$PlayerInvList.Length);
	checkg = P2GameInfoSingle(PlayerPawn.Level.Game);
	bverified=checkg.VerifySeqTime();

	for(i=0; i<PlayerInvList.Length; i++)
	{
		//log(" checking inv class: "$PlayerInvList[i].InvClassName$"... extra amount "$PlayerInvList[i].NeededAmount$" guy type "$PlayerInvList[i].GuyType$" enhanced "$PlayerInvList[i].bEnhancedOnly);
		// check if it's for the good dude, the evil dude or both
		if((PlayerInvList[i].GuyType == GTE_BOTH
				|| (checkg.TheGameState.bNiceDude
					&& PlayerInvList[i].GuyType == GTE_GOOD)
				|| (!checkg.TheGameState.bNiceDude
					&& PlayerInvList[i].GuyType == GTE_EVIL))
			&& (!PlayerInvList[i].bEnhancedOnly
				|| bverified))
		{
			if (PlayerInvList[i].InvClassName != '')
			{
				invadd = PlayerPawn.CreateInventoryByClass(class<Inventory>(DynamicLoadObject(String(PlayerInvList[i].InvClassName), class'class')));
				//log(Self$" invadd "$invadd);
				// Make sure they have enough--if you have more than this, that's fine.
				ppinv = P2PowerupInv(invadd);
				if(ppinv != None
					&& ppinv.Amount < PlayerInvList[i].NeededAmount)
					ppinv.SetAmount(PlayerInvList[i].NeededAmount);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Take the things listed from the player's inventory--ie, remove them from his inventory
// and destroy them if necessary.
///////////////////////////////////////////////////////////////////////////////
function TakeInventoryFromPlayer(P2Pawn PlayerPawn)
{
	local int i;
	local Inventory checkinv;
	local P2PowerupInv ppinv;
	local P2GameInfoSingle checkg;
	
	//log(self$" taking things from inventory, length "$TakeFromPlayerList.Length);
	checkg = P2GameInfoSingle(PlayerPawn.Level.Game);
	
	for(i=0; i<TakeFromPlayerList.Length; i++)
	{
		//log(" take inv class "$TakeFromPlayerList[i].InvClassName$" extra amount "$TakeFromPlayerList[i].NeededAmount$" guy type "$TakeFromPlayerList[i].GuyType);
		
		// check if it's for the good dude, the evil dude or both
		if(TakeFromPlayerList[i].GuyType == GTE_BOTH
			|| 
			(checkg.TheGameState.bNiceDude
			&& TakeFromPlayerList[i].GuyType == GTE_GOOD)
			|| (!checkg.TheGameState.bNiceDude
			&& TakeFromPlayerList[i].GuyType == GTE_EVIL))
		{
			if (TakeFromPlayerList[i].InvClassName != '')
			{
				checkinv = PlayerPawn.FindInventoryType(class<Inventory>(DynamicLoadObject(String(TakeFromPlayerList[i].InvClassName), class'class')));
				if(checkinv != None)
				{
					// Got the inventory to remove, check to see how much to take
					// now remove it completely from your inventory.
					if ( checkinv.Instigator != None )
					{
						checkinv.DetachFromPawn(checkinv.Instigator);	
						checkinv.Instigator.DeleteInventory(checkinv);
					}
					checkinv.Destroy();
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Assorted queries about this day
///////////////////////////////////////////////////////////////////////////////
function Texture GetMapTexture()
	{
	return Texture(DynamicLoadObject(String(MapTex), class'Texture'));
	}

function Texture GetNewsTexture()
	{
	return Texture(DynamicLoadObject(String(NewsTex), class'Texture'));
	}

function Sound GetDudeNewsComment()
	{
	if (DudeNewsComment != '')
		return Sound(DynamicLoadObject(String(DudeNewsComment), class'Sound'));
	return None;
	}

function Texture GetLoadTexture()
	{
	// Man Chrzan: xPatch	
		local Texture NewLoadTex;
		local int i;
		
		if(class'P2GameInfoSingle'.static.InClassicModeStatic() 
			|| class'xPatchManager'.static.GetClassicLoading())
		{
			NewLoadTex = Texture(DynamicLoadObject(String(LoadTex), class'Texture'));
			
			for(i=0; i<SteamLoadTex.Length; i++)
			{
				if( NewLoadTex == SteamLoadTex[i] )
				{
					NewLoadTex = ClassicLoadTex[i];
				}
			}
			
			return NewLoadTex;
		}
	// Man Chrzan: End
	return Texture(DynamicLoadObject(String(LoadTex), class'Texture'));
	}

function Sound GetDudeStartComment()
	{
	if (DudeStartComment != '')
		return Sound(DynamicLoadObject(String(DudeStartComment), class'Sound'));
	return None;
	}

///////////////////////////////////////////////////////////////////////////////
// Check to make sure at least every errand has one goal
// Only to be called in an init.
///////////////////////////////////////////////////////////////////////////////
function CheckForValidErrandGoals()
	{
	local int i;
	
	if (Errands.Length == 0)
		Warn("ERROR: this day has no errrands");
	// Go through the errands and ask if any of them have been satisfied
	for(i=0; i<Errands.Length; i++)
		{
		if(!Errands[i].CheckForValidErrandGoals())
			Warn("ERROR: this day has errands with missing goals ");
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Check for errand completion.  This is called when various things occur
// that could possibly complete an errand.  This is not a mere test -- it
// actually tries to complete an errand using the specified info.
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandCompletion(
	Actor Other,
	Actor Another,
	Pawn ActionPawn,
	bool bPremature,
	GameState CurGameState,
	out int ErrandIndex,			// OUT: which errand was completed
	out name CompletionTrigger,		// OUT: name of trigger that must occur
	out string SendPlayerTo			// OUT: URL to send player to
	)
	{
	local int i;
	
	// Go through the errands and ask if any of them have been satisfied
	for(i=0; i<Errands.Length; i++)
		{
		if(Errands[i].CheckForCompletion(Other, Another, ActionPawn, CurGameState, CompletionTrigger, SendPlayerTo))
			{
			// Say it's complete
			Errands[i].SetComplete(bPremature);
			// Return index of errand that was completed
			ErrandIndex = i;
			return true;
			}
		}
	
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Just add the haters for this errand
///////////////////////////////////////////////////////////////////////////////
function AddMyHaters(GameState CurGameState, P2Player CurPlayer)
	{
	local int i;
	
	for(i=0; i<Errands.Length; i++)
		{
		Errands[i].AddMyHaters(CurGameState, CurPlayer);
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Check to ignore this thing by tag--check all the errands in this day
///////////////////////////////////////////////////////////////////////////////
function bool IgnoreThisTag(Actor Other)
	{
	local int i;
	
	for(i=0; i<Errands.Length; i++)
		{
		if(Errands[i].IgnoreThisTag(Other))
			return true;
		}
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Check if Other is used by an errand
///////////////////////////////////////////////////////////////////////////////
function bool CheckForErrandUse(Actor Other)
	{
	local int i;
	local bool bUse;
	
	// Go through the errands and ask if any of them have been satisfied
	for(i=0; i<Errands.Length; i++)
		{
		if(Errands[i].CheckForErrandUse(Other))
			bUse=true;
		}
	
	return bUse;
	}

///////////////////////////////////////////////////////////////////////////////
// Look for specified errand and return its index if found.
///////////////////////////////////////////////////////////////////////////////
function int FindErrand(String UniqueName)
	{
	local int i;

	for(i = 0; i < Errands.Length; i++)
		{
		if (Errands[i].UniqueName ~= UniqueName)
			return i;
		}
	return -1;
	}

///////////////////////////////////////////////////////////////////////////////
// Get total number of errands (active or not).  Never changes during a day.
///////////////////////////////////////////////////////////////////////////////
function int NumErrands()
	{
	return Errands.Length;
	}

///////////////////////////////////////////////////////////////////////////////
// Get current number of active errands.  Can change during course of day.
///////////////////////////////////////////////////////////////////////////////
function int NumActiveErrands()
	{
	local int i;

	if (ActiveErrands == -1)
		{
		ActiveErrands = 0;
		for (i = 0; i < Errands.Length; i++)
			{
			if (Errands[i].IsActive())
				ActiveErrands++;
			}
		}
	return ActiveErrands;
	}

///////////////////////////////////////////////////////////////////////////////
// Activate specified errand
///////////////////////////////////////////////////////////////////////////////
function ActivateErrand(int Errand)
	{
	if (!Errands[Errand].IsActive())
		{
		Errands[Errand].Activate();
		
		if (ActiveErrands == -1)
			NumActiveErrands();
		else
			ActiveErrands++;
		}
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate specified errand
///////////////////////////////////////////////////////////////////////////////
function DeActivateErrand(int Errand)
	{
	if (Errands[Errand].IsActive())
		{
		Errands[Errand].DeActivate();
		
		if (ActiveErrands == -1)
			NumActiveErrands();
		else
			ActiveErrands--;
		}
	}
///////////////////////////////////////////////////////////////////////////////
// Activate specified errand
///////////////////////////////////////////////////////////////////////////////
function ActivateLocationTex(int Errand)
	{
	if (!Errands[Errand].IsLocationTexActive())
		{
		Errands[Errand].ActivateLocationTex();
		}
	}
///////////////////////////////////////////////////////////////////////////////
// DEActivate specified errand
///////////////////////////////////////////////////////////////////////////////
function DeActivateLocationTex(int Errand)
	{
	if (Errands[Errand].IsLocationTexActive())
		{
		Errands[Errand].DeActivateLocationTex();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Assorted queries about the specified errand
///////////////////////////////////////////////////////////////////////////////
function bool IsErrandComplete(int ErrandIndex)
	{
	return Errands[ErrandIndex].IsComplete();
	}

function bool IsErrandActive(int ErrandIndex)
	{
	return Errands[ErrandIndex].IsActive();
	}

function bool IsLocationTexActive(int ErrandIndex)
	{
	return Errands[ErrandIndex].IsLocationTexActive();
	}

function Sound GetErrandStartComment(int ErrandIndex)
	{
	return Sound(DynamicLoadObject(String(Errands[ErrandIndex].DudeStartComment), class'Sound'));
	}

function Sound GetErrandCompletedComment(int ErrandIndex)
	{
	return Sound(DynamicLoadObject(String(Errands[ErrandIndex].DudeCompletedComment), class'Sound'));
	}

function Sound GetErrandWhereComment(int ErrandIndex)
	{
	if (Errands[ErrandIndex].DudeWhereComment != '')
		return Sound(DynamicLoadObject(String(Errands[ErrandIndex].DudeWhereComment), class'Sound'));
	return None;
	}

function Sound GetErrandFoundComment(int ErrandIndex)
	{
	if (Errands[ErrandIndex].DudeFoundComment != '')
		return Sound(DynamicLoadObject(String(Errands[ErrandIndex].DudeFoundComment), class'Sound'));
	return None;
	}

function Texture GetErrandName(int ErrandIndex)
	{
	return Texture(DynamicLoadObject(String(Errands[ErrandIndex].NameTex), class'Texture'));
	}

function Texture GetErrandLocation(int ErrandIndex, out float x, out float y)
	{
	x = Errands[ErrandIndex].LocationX;
	y = Errands[ErrandIndex].LocationY;
	if (Errands[ErrandIndex].LocationTex != '')
		return Texture(DynamicLoadObject(String(Errands[ErrandIndex].LocationTex), class'Texture'));
	return None;
	}

function Texture GetErrandLocationCrossout(int ErrandIndex, out float x, out float y)
	{
	x = Errands[ErrandIndex].LocationCrossX;
	y = Errands[ErrandIndex].LocationCrossY;
	if (Errands[ErrandIndex].LocationCrossTex != '')
		return Texture(DynamicLoadObject(String(Errands[ErrandIndex].LocationCrossTex), class'Texture'));
	return None;
	}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	ActiveErrands=-1
	
	SteamLoadTex[0]=Texture'p2misc_full.loading1'
	SteamLoadTex[1]=Texture'p2misc_full.loading2'
	SteamLoadTex[2]=Texture'p2misc_full.loading3'
	SteamLoadTex[3]=Texture'p2misc_full.loading4'
	SteamLoadTex[4]=Texture'p2misc_full.loading5'
	SteamLoadTex[5]=Texture'aw_textures.loading_sat'
	SteamLoadTex[6]=Texture'aw_textures.loading_sun'
	
	ClassicLoadTex[0]=Texture'xPatchTex.Loading.loading1'  
	ClassicLoadTex[1]=Texture'xPatchTex.Loading.loading2'
	ClassicLoadTex[2]=Texture'xPatchTex.Loading.loading3'
	ClassicLoadTex[3]=Texture'xPatchTex.Loading.loading4'
	ClassicLoadTex[4]=Texture'xPatchTex.Loading.loading5'
	ClassicLoadTex[5]=Texture'xPatchTex.Loading.loading_sat'
	ClassicLoadTex[6]=Texture'xPatchTex.Loading.loading_sun'
	}
