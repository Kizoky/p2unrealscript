///////////////////////////////////////////////////////////////////////////////
// Our buffer class between their pickup class and our powerup/inventory pickups.
// This generates the inventory item set in InventoryType.
//
// PowerupInv are the version that is in the player's inventory and used as
// as powerup
// (poweruppickup is the pickup version)
//
//
// GroupOffsets for powerups arbitrarily start at 100 so we have some space from
// the weapons.
//
///////////////////////////////////////////////////////////////////////////////
class P2PowerupInv extends Powerups
	abstract;


// Internal variables
var bool			bDisplayAmount;		// Show on the HUD the amount of this you have
var bool			bDisplayAsFloat;	// Show the amount as a float (not default)
var travel float	Amount;				// How much of whatever we have
var int				MaxAmount;			// Max of this we can have
var	bool			bCanThrow;			// if true, player can toss this out
var	bool			bThrowIndividually;	// Throw each unit of Amount, so one at a time, if true
var travel int		Tainted;			// been pissed on or something.
var bool			bEdible;			// Food or medkit
var travel int		UseForErrands;		// needs this for an errand
var Name			ExamineAnimType;	// which animation to use for examining this item
var Sound			ExamineDialog;		// what to say when examining this item
var bool			bAllowHints;		// Whether or not to continue showing hints
var bool			bUseUpAutoActivate;	// Use up this item on auto activation
var localized string Hint1;				// Hints about this inventory item (3 lines)
var localized string Hint2;
var localized string Hint3;
var localized string HealingString;		// What gets said only when you quickhealth use an item. This
										// way you get an idea of what just happened, because it auto-
										// selects what to use.

var bool bAllowedToRespawn;				// Instead of having gameinfo decide across the board, dropped
										// pickups need to never respawn.
var bool bMustBeDropped;				// Must be dropped no matter what--even if they log out early
var float TossVel;						// How fast you get toss out

var float IconOffsetY;	// for gary head

var bool bCannotBeStolen;	// True if this item can't be stolen (hands, map, urethra etc)

var() localized string PowerupName;	// Name of this powerup to display in the inv selector.
										// Inventory.ItemName is not localized so we made this version just in case
var() localized string PowerupDesc;	// Description of this powerup to display in the inv selector.

// xPatch:
struct ClassicIconsReplaceStr
{
	var Material NewIcon;
	var Material OldIcon;
};
var array<ClassicIconsReplaceStr> ClassicIcons;
// End

///////////////////////////////////////////////////////////////////////////////
// Replication
///////////////////////////////////////////////////////////////////////////////
replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) && bNetOwner )
		Amount;
}

///////////////////////////////////////////////////////////////////////////////
// xPatch: Optional classic icons
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	SwapIcons();
	Super.PostBeginPlay();
}
function SwapIcons()
{
	local int i;

	if(P2GameInfoSingle(Level.Game) != None 
		&& P2GameInfoSingle(Level.Game).GetClassicIcons()
		&& Icon != None)
	{
		for(i=0; i<ClassicIcons.Length; i++)
		{
			if(Icon == ClassicIcons[i].NewIcon 
			&& ClassicIcons[i].OldIcon != None)
				Icon = ClassicIcons[i].OldIcon;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Activate
// We can sell items now, so before we do anything, attempt to hand it over
///////////////////////////////////////////////////////////////////////////////
function Activate()
{
	local P2Pawn thispawn;
	local P2Player checkp;
	local PersonController Personc;
	local float AmountTaken;
	local bool bSold;

	// FIXME this breaks certain cashier interactions in P2!
	thispawn = P2Pawn(Owner);
	checkp = P2Player(thispawn.Controller);
	if(checkp.InterestPawn != None)
	{
		Personc = PersonController(checkp.InterestPawn.Controller);

		if(Personc != None)
		{
			if(Personc.AcceptItem(thispawn, self, AmountTaken, Amount))
			{
				ReduceAmount(AmountTaken);
				bSold = true;
			}
		}
	}
	
	// If we sold the items, don't activate them
	if (!bSold && bActivatable)
		GotoState('Activated');
}

///////////////////////////////////////////////////////////////////////////////
// Override UsedUp.
// Epic assumed what we used up would be selected. That's not always true for us.
///////////////////////////////////////////////////////////////////////////////
function UsedUp()
{
	local P2Player p2p;
	local P2GameInfoSingle checkg;
	
	//log(self$" used up selected, "$Pawn(Owner).SelectedItem);
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;

		if (Pawn(Owner).SelectedItem == Self) 
		{
			Pawn(Owner).NextItem();
			if (Pawn(Owner).SelectedItem == Self) 
			{
				//log(self$" switching");
				Pawn(Owner).NextItem();	
				if (Pawn(Owner).SelectedItem == Self) 
					Pawn(Owner).SelectedItem=None;
			}
		}

// RWS CHANGE: No longer logged
//		if (Level.Game.StatLog != None)
//			Level.Game.StatLog.LogItemDeactivate(Self, Pawn(Owner));

		if(Instigator != None)
			Instigator.ReceiveLocalizedMessage( MessageClass, 0, None, None, Self.Class );

		Owner.PlaySound(DeactivateSound);
		
		// Check if the inventory item we just got satisfies an errand
		if(UseForErrands == 1)
		{
			p2p = P2Player(Pawn(Owner).Controller);
			if(p2p != None)
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(checkg != None)
				{
					checkg.CheckForErrandCompletion(self, None, Pawn(Owner), p2p, false);
				}
			}
		}			
	}
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// The first time this is added, this should be called, to do any extra
// setup
///////////////////////////////////////////////////////////////////////////////
function AddedToPawnInv(Pawn UsePawn, Controller UseCont)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// When you're sent to jail most weapons are taken. The Radar things aren't. Perhaps
// they want to do something now.
///////////////////////////////////////////////////////////////////////////////
function AfterItsTaken(P2Pawn CheckPawn)
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// Just return the inventory group.
///////////////////////////////////////////////////////////////////////////////
simulated function int GetRank()
{
	return InventoryGroup;
}

///////////////////////////////////////////////////////////////////////////////
// Generally used by QuickHealth player key to determine which powerup he
// should use next when healing himself.
///////////////////////////////////////////////////////////////////////////////
simulated function float RateHealingPower()
{
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// match this tag to its actor
///////////////////////////////////////////////////////////////////////////////
function UseTagToNearestActor(Name UseTag, out Actor UseActor, float randval, 
							  optional bool bDoRand, optional bool bSearchPawns)
{
	local Actor CheckA, LastValid;
	local float dist, keepdist;
	local class<Actor> useclass;

	if(UseTag != 'None')
	{
		dist = 65535;
		keepdist = dist;
		UseActor = None;
		
		if(bSearchPawns)
			useclass = class'FPSPawn';
		else
			useclass = class'Actor';

		ForEach AllActors(useclass, CheckA, UseTag)
		{
			// don't allow it to pick you, even if your tag is valid
			if(CheckA != self
				&& !CheckA.bDeleteMe)
			{
				LastValid = CheckA;
				dist = VSize(CheckA.Location - Location);
				if(dist < keepdist
					&& (!bDoRand ||	FRand() <= randval))
				{
					keepdist = dist;
					UseActor = CheckA;
				}
			}
		}

		if(UseActor == None)
			UseActor = LastValid;

		// These things are almost never used in MP, so only display errors in SP
		// Also, the real objects are in the main menu, so don't complain there
		if(UseActor == None
			&& P2GameInfo(Level.Game) != None
			&& Level.Game.bIsSinglePlayer
			&& !P2GameInfo(Level.Game).IsMainMenuMap())
			log("ERROR: could not match with tag "$UseTag);
	}
	else
		UseActor = None;	// just to make sure
}


///////////////////////////////////////////////////////////////////////////////
// copy your important things over from your maker
///////////////////////////////////////////////////////////////////////////////
function TransferState(P2PowerupPickup maker)
{
	//log(self$" transfer "$maker.Tainted);
	if(maker.Tainted == 1)
		Tainted = 1;
}

///////////////////////////////////////////////////////////////////////////////
// Always set the most recent thing you picked up to this item
///////////////////////////////////////////////////////////////////////////////
function PickupFunction(Pawn Other)
{
	local P2GameInfoSingle checkg;
	local P2Player p2p;
	local Powerups LastSelected;
	local bool bAllDone;

	// Use it as you get it. (Could be sold to you and put directly into your
	// inventory, otherwise, pickups will activate it for you)
	if(bAutoActivate)
	{
		// If our pawn is dead but he just got something, then don't
		// let him use it up, so he'll throw it out
		// otherwise, use up auto-activated inventory items, on the spot.
		if(Other.Health > 0)
		{
			if(self != Other.SelectedItem)
				LastSelected = Other.SelectedItem;
			
			Activate();

			// Kevlar gets always used up no matter what,
			// newspaper does not.
			if(bUseUpAutoActivate)
			{
				bAllDone=true;
				if(LastSelected != None)
					Other.SelectedItem = LastSelected;
				UsedUp(); // destroyed here
				return;
			}
		}
	}

	if(!bAllDone)
	{
		//log(self$" pickup called by"$Other$" amount is "$Amount);
		Super.PickupFunction(Other);

		// Switch your inventory view to what you just picked up
		if (Other.SelectedItem == None || PlayerController(Other.Controller) == None || !PlayerController(Other.Controller).bNeverSwitchItemOnPickup)
		{
			Other.SelectedItem=self;
			if(Pawn(Owner) != None
				&& P2Player(Pawn(Owner).Controller) != None)
				P2Player(Pawn(Owner).Controller).InvChanged();
		}

		//  Check if your hints should be active
		if(P2GameInfoSingle(Level.Game) != None
			&& P2GameInfoSingle(Level.Game).TheGameState != None
			&& P2GameInfoSingle(Level.Game).TheGameState.FoundInvHintInactive(GetRank()))
			bAllowHints=false;

		// Check if the inventory item we just got satisfies an errand
		if(UseForErrands == 1)
		{
			p2p = P2Player(Instigator.Controller);
			if(p2p != None)
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(checkg != None)
				{
					checkg.CheckForErrandCompletion(self, None, None, p2p, false);
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Add this in
// We can send in the skin of the new types being added.
///////////////////////////////////////////////////////////////////////////////
function AddAmount(int AddThis, 
				   optional Texture NewSkin, 
				   optional StaticMesh NewMesh,
				   optional int IsTainted)
{
	Amount += AddThis;
	//log(self$" addamount is "$Amount);
	if(Amount > MaxAmount
		&& MaxAmount > 0)
		Amount=MaxAmount;
}

///////////////////////////////////////////////////////////////////////////////
// Make the amount this much
///////////////////////////////////////////////////////////////////////////////
function SetAmount(int SetThis)
{
	Amount = SetThis;
	//log(self$" Setamount is "$Amount);
	if(Amount > MaxAmount
		&& MaxAmount > 0)
		Amount=MaxAmount;
}

///////////////////////////////////////////////////////////////////////////////
// Add this in
///////////////////////////////////////////////////////////////////////////////
function ReduceAmount(int UseAmount, 
					  optional out Texture NewSkin, 
					  optional out StaticMesh NewMesh,
					  optional out int IsTainted,
					  optional bool bNoUsedUp)
{
	Amount -= UseAmount;
	if(Amount <= 0
		&& !bNoUsedUp)
		UsedUp();
}

///////////////////////////////////////////////////////////////////////////////
// If some little but important bool is different, say so
///////////////////////////////////////////////////////////////////////////////
function bool SameAsMe(pickup Item)
{
	return true;
}

///////////////////////////////////////////////////////////////////////////////
//
// Advanced function which lets existing items in a pawn's inventory
// prevent the pawn from picking something up. Return true to abort pickup
// or if item handles the pickup
//
///////////////////////////////////////////////////////////////////////////////
function bool HandlePickupQuery( pickup Item )
{
	local P2GameInfoSingle checkg;
	local P2PowerupPickup ppick;
	local Texture pickupskin;	
	local class<Inventory> CheckType;
	
	// Check against nightmare inventory type in nightmare mode
	CheckType = Item.InventoryType;
	if (P2GameInfo(Level.Game).InNightmareMode()
		&& P2PowerupPickup(Item) != None
		&& P2PowerupPickup(item).NightmareInventoryType != None)
		CheckType = P2PowerupPickup(item).NightmareInventoryType;

	if ( class == CheckType ) 
	{
		//log(self$" got "$Item);
		// Transfer important things over to the new thing
		TransferState(P2PowerupPickup(Item));

//		if (Amount==MaxAmount) 
//			return true;

		// And set the selected item to the thing you
		// just picked up		
		if(Pawn(Owner) != None)
		{
			if (Pawn(Owner).SelectedItem == None || PlayerController(Pawn(Owner).Controller) == None || !PlayerController(Pawn(Owner).Controller).bNeverSwitchItemOnPickup)
			{
				Pawn(Owner).SelectedItem = self;
				if(P2Player(Pawn(Owner).Controller) != None)
					P2Player(Pawn(Owner).Controller).InvChanged();
			}
		}

		if(SameAsMe(item))
		{
			// Check if this fulfills some errand requirement
			checkg = P2GameInfoSingle(Level.Game);
			ppick = P2PowerupPickup(Item);
			if(checkg != None
				&& ppick != None
				&& ppick.bUseForErrands)
			{
				checkg.CheckForErrandCompletion(ppick, None, Instigator, P2Player(Instigator.Controller), false);
			}

			if(Item.Skins.Length > 0)
				pickupskin = Texture(Item.Skins[0]);

			AddAmount(P2PowerupPickup(item).AmountToAdd, pickupskin, Item.StaticMesh, P2PowerupPickup(Item).Tainted);

			// announce and add it in
			item.AnnouncePickup(Pawn(Owner));

			return true;				
		}
		else	// it's different, so add an extra one of these
			return false;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

///////////////////////////////////////////////////////////////////////////////
// Do what you want if the drop failed--most things don't care that much
///////////////////////////////////////////////////////////////////////////////
function DropFailed()
{
	// STUB
}

///////////////////////////////////////////////////////////////////////////////
// How fast to toss out a powerup
///////////////////////////////////////////////////////////////////////////////
function float GetTossMag()
{
	return TossVel;
}

///////////////////////////////////////////////////////////////////////////////
// Toss this item out.
///////////////////////////////////////////////////////////////////////////////
function DropFrom(vector StartLocation)
{
	local Pickup P;

	// 11/18 - don't drop weapons for a dead dude
	if ((Instigator.IsA('Dude') || Instigator.IsA('AWDude'))
		&& Instigator.Health <= 0
		// But do drop our money so someone will run in and grab it.
		&& !Self.IsA('MoneyInv')
		// Also drop our cats, because it's funny
		&& !Self.IsA('CatInv'))
		return;

		P = spawn(PickupClass,Instigator,,StartLocation);
	// if it's not spawned, try spawning it at the instigator
	if(P == None)
	{
		P = spawn(PickupClass,Instigator,,Instigator.Location);
	}

	if(P != None)
	{
		P.Instigator = Instigator;

		if(UseForErrands == 1
			&& Instigator != None
			&& P2Pawn(Instigator).Health > 0
			&& P2Player(Instigator.Controller) != None)
		{
			// Player says something about important item being dropped
			P2Player(Instigator.Controller).NeedThatForAnErrand();
		}

		// If throw each one and you have more than one, then only spawn a copy
		if(bThrowIndividually && Amount > 1)
		{
			// Throw out one
			if ( P == None )
			{
				return;
			}
			P.InitDroppedPickupFor(self);
			P.Velocity = Velocity;
			Velocity = vect(0,0,0);
		}
		else
		{
			///////////////////////////////////////////////////////////////////////////////
			// Similar to DropFrom in Inventory.uc, but we pass the instigator along to
			// the spawned pickup as its owner, because we want to know who most recently
			// dropped this for errands
			///////////////////////////////////////////////////////////////////////////////
			if ( Instigator != None )
			{
				DetachFromPawn(Instigator);	
				Instigator.DeleteInventory(self);
			}	
			SetDefaultDisplayProperties();
			Inventory = None;
			Instigator = None;
			StopAnimating();
			// moved spawn line from here to top of function
			if ( P == None )
			{
				return;
			}
			P.InitDroppedPickupFor(self);
			P.Velocity = Velocity;
			Velocity = vect(0,0,0);
			// End of inventory.uc code
			ReduceAmount(Amount);
		}
	}
	// If it still failed, ask the inventory what he wants to do
	else
	{
		DropFailed();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Allow hints again
///////////////////////////////////////////////////////////////////////////////
function RefreshHints()
{
	bAllowHints=true;
}

///////////////////////////////////////////////////////////////////////////////
// Don't allow hints for this item any more
///////////////////////////////////////////////////////////////////////////////
function TurnOffHints()
{
	if(bAllowHints)
	{
		bAllowHints=false;

		if(P2GameInfoSingle(Level.Game) != None
			&& P2GameInfoSingle(Level.Game).TheGameState != None)
			// Tell the gamestate to save that this is turned off
			P2GameInfoSingle(Level.Game).TheGameState.RegisterInventoryHint(GetRank());

		if(Instigator != None
			&& P2Player(Instigator.Controller) != None
			&& self == Instigator.SelectedItem)
			P2Player(Instigator.Controller).UpdateHudInvHints();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Give hints about this item
///////////////////////////////////////////////////////////////////////////////
function GetHints(P2Pawn PawnOwner, out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		str1 = Hint1;
		str2 = Hint2;
		str3 = Hint3;
	}
}

defaultproperties
{
	bDisplayAmount=true
	bActivatable=true
	bCanThrow=true
	bThrowIndividually=true
	ExamineAnimType="None"
	bAllowHints=true
	bAllowedToRespawn=true
	TossVel=800
	
	// xPatch: Classic Icons
	ClassicIcons(0)=(NewIcon=Texture'HUDPack.Icon_Inv_Map',OldIcon=Texture'HUDPack.Icons.Icon_Inv_Map_Alt')
	ClassicIcons(1)=(NewIcon=Texture'HUDPack.Icon_Inv_Cat',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Cat')
	ClassicIcons(2)=(NewIcon=Texture'HUDPack.Icon_Inv_Crack',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Crack')
	ClassicIcons(3)=(NewIcon=Texture'Hudpack.icons.icon_inv_doughnut',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Donut')
	ClassicIcons(4)=(NewIcon=Texture'Hudpack.icons.icon_inv_food',OldIcon=Texture'ClassicIcons.Inventory.icon_inv_food')
	ClassicIcons(5)=(NewIcon=Texture'hudpack.icons.Icon_Inv_GimpUniform',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_GimpUniform')
	ClassicIcons(6)=(NewIcon=Texture'HUDPack.Icons.Icon_Inv_Newspaper',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Newspaper')
	ClassicIcons(7)=(NewIcon=Texture'Hudpack.icons.icon_inv_pizza',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Pizza')
	ClassicIcons(8)=(NewIcon=Texture'HUDPack.Icon_Inv_Paycheck',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Paycheck')
	ClassicIcons(9)=(NewIcon=Texture'nathans.Inventory.MilkInv',OldIcon=Texture'ClassicIcons.Inventory.MilkInv')
	ClassicIcons(10)=(NewIcon=Texture'HUDpack.icons.Icon_Inv_Penicillin',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_Penicillin')
	ClassicIcons(11)=(NewIcon=Texture'nathans.Inventory.MoneyInv',OldIcon=Texture'ClassicIcons.Inventory.MoneyInv')
	ClassicIcons(12)=(NewIcon=Texture'HUDPack.Icons.Icon_Inv_CopUniform',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_CopUniform')
	ClassicIcons(13)=(NewIcon=Texture'HUDPack.Icons.Icon_Inv_DudeUniform',OldIcon=Texture'ClassicIcons.Inventory.Icon_Inv_DudeUniform')
}
