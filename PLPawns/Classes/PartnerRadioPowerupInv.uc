///////////////////////////////////////////////////////////////////////////////
// PartnerRadioPowerInv
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
//
// Powerup version of the partner radio, for directing Uncle Dave.
// Has two "states": follow the Dude, and hold position.
///////////////////////////////////////////////////////////////////////////////
class PartnerRadioPowerupInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
enum EPartnerState
{
	PS_None,			// Do nothing
	PS_FollowPlayer,	// Follow player
	PS_HoldPosition,	// Hold position
};

var EPartnerState PartnerState;			// Current state of our partner
var PartnerPawn OurPartner;				// Current partner
var PartnerController OurController;	// Current partner's controller
var P2Pawn MyPawn;						// Owner (Dude)'s pawn

const COMMAND_RADIUS = 512;				// Max radius for PS_HoldPosition
const CLEAR_AREA_RADIUS = 128;			// Make sure the area is clear
const WAIT_TIME = 1.0;					// Amount of time to wait between commands

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function HookPartner()
{
	// Find our partner
	foreach DynamicActors(class'PartnerPawn', OurPartner)
		break;			
		
	if (OurPartner == None)
		return;
		
	if (PartnerController(OurPartner.Controller) == None)
		return;
		
	OurController = PartnerController(OurPartner.Controller);

	// We have a partner, now initialize it
	OurController.Player = Pawn(Owner);
	OurController.PlayerController = Pawn(Owner).Controller;
	OurPartner.CreateInventoryByClass(class'ShotgunWeapon');
	OurPartner.SetPhysics(PHYS_Falling);
	
	MakeCommand(CM_UseAnyWeapon);		// Use whatever weapon is available
	MakeCommand(CM_EquipWeapon);		// Equip whatever weapon we have
	MakeCommand(CM_HostileTerritory);	// Assume we are in hostile territory
	MakeCommand(CM_Follow);				// And follow the player
	PartnerState = PS_FollowPlayer;		// Update our PartnerState accordingly
	
	P2Player(Instigator.Controller).UpdateHudInvHints();
	GotoState('');	// Stop trying to find a partner	
}

///////////////////////////////////////////////////////////////////////////////
// MakeCommand
// Simplified version of the one from PartnerRadioWeapon
///////////////////////////////////////////////////////////////////////////////
function MakeCommand(PartnerController.ECommand NewCommand)
{
	local NavigationPoint N;
	local Actor A;
	
    if (OurController != none)
	{
		// Find a spot generally nearby to issue the command
		// Skip if not CM_HoldPosition to save time
		if (NewCommand == CM_HoldPosition)
		{
			foreach CollidingActors(class'NavigationPoint', N, COMMAND_RADIUS, Owner.Location)
			{
				// Make sure the area is generally clear
				A = None;
				foreach CollidingActors(class'Actor', A, CLEAR_AREA_RADIUS, N.Location)
					break;
					
				if (A == None)
					break;
			}
		}
		
		if (N != None)
			OurController.ReceiveCommand(NewCommand, None, N.Location);
		else // Use owner location
			OurController.ReceiveCommand(NewCommand, None, Owner.Location);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Find our partner and hook them
///////////////////////////////////////////////////////////////////////////////
function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);
	GotoState('FindingPartner');
}

///////////////////////////////////////////////////////////////////////////////
// Decide which hint to display
///////////////////////////////////////////////////////////////////////////////
function GetHints(P2Pawn PawnOwner, out String str1, out String str2, out String str3,
				out byte InfiniteHintTime)
{
	if(bAllowHints)
	{
		if (PartnerState == PS_FollowPlayer)
			str1 = Hint1;
		else if (PartnerState == PS_HoldPosition)
			str1 = Hint2;
		else
			str1 = Hint3;
			
		InfiniteHintTime = 1;	// This is a new mechanic, so let's keep the hint up
	}
}

///////////////////////////////////////////////////////////////////////////////
// Dude makes comments
///////////////////////////////////////////////////////////////////////////////
function DudeComment_Received()
{
	if (MyPawn != None)
		MyPawn.Say(MyPawn.MyDialog.lDude_UncleDaveRadio_Received, true);
}
function DudeComment_AllClear()
{
	if (MyPawn != None)
		MyPawn.Say(MyPawn.MyDialog.lDude_UncleDaveRadio_AllClear, true);
}
function DudeComment_FollowMe()
{
	if (MyPawn != None)
		MyPawn.Say(MyPawn.MyDialog.lDude_UncleDaveRadio_FollowMe, true);
}
function DudeComment_StayHere()
{
	if (MyPawn != None)
		MyPawn.Say(MyPawn.MyDialog.lDude_UncleDaveRadio_StayHere, true);
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// FindingPartner
// Continually look for a partner until we find one.
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FindingPartner
{
	// We're not communicating yet, so just say everything is clear
	function Activate()
	{
		DudeComment_AllClear();
	}
	event BeginState()
	{
		Super.BeginState();
		MyPawn = P2Pawn(Owner);
		DudeComment_Received();
	}
	
Begin:
	HookPartner();
	Sleep(1.0);
	Goto('Begin');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	ignores Activate;
	
	function ToggleCommand()
	{
		if (PartnerState == PS_FollowPlayer)
		{
			MakeCommand(CM_HoldPosition);
			PartnerState = PS_HoldPosition;
		}
		else if (PartnerState == PS_HoldPosition)
		{
			MakeCommand(CM_Follow);
			PartnerState = PS_FollowPlayer;
		}
	}
	
	function CommentOnIt()
	{
		if (PartnerState == PS_FollowPlayer)
			DudeComment_FollowMe();
		else if (PartnerState == PS_HoldPosition)
			DudeComment_StayHere();
	}
	
Begin:
	ToggleCommand();
	CommentOnIt();
	Sleep(WAIT_TIME);
	P2Player(Instigator.Controller).UpdateHudInvHints();
	GotoState('');
}

defaultproperties
{
	Icon=Texture'AW7Tex.Icons.hud_copradio'
	Hint1="Press %KEY_InventoryActivate% to order Dave to hold position."
	Hint2="Press %KEY_InventoryActivate% to order Dave to follow you."
	Hint3="Communicating..."
	bAllowHints=true
	InventoryGroup=102
	GroupOffset=23
	PowerupName="Uncle Dave Radio"
	PowerupDesc="Use this to call out to Uncle Dave and have him either hold position or cover you."
}