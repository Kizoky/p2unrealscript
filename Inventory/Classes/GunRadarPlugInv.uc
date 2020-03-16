///////////////////////////////////////////////////////////////////////////////
// GunRadarPlugInv
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Plug-in for the radar. Show's 'fish' that have weapons (concealed or
// otherwise).
// 
// Toggle it on and off by using it.
//
///////////////////////////////////////////////////////////////////////////////

class GunRadarPlugInv extends OwnedInv;

///////////////////////////////////////////////////////////////////////////////
// vars
///////////////////////////////////////////////////////////////////////////////
var localized string Hint4;

///////////////////////////////////////////////////////////////////////////////
// Toggle Activation of selected Item.
///////////////////////////////////////////////////////////////////////////////
function Activate()
{
	// Don't do it if the player controller isn't valid
	if(P2Pawn(Owner) == None
		|| P2Player(P2Pawn(Owner).Controller) == None)
		return;

	Owner.PlaySound(ActivateSound);
	Super.Activate();
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
	}
	else
	{
		if(!bActive) // How to turn on
		{
			str1 = Hint4;
			InfiniteHintTime=1;
		}
		else // How to turn off
		{
			str1 = Hint3;
			InfiniteHintTime=1;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Only code that should change with each plug-in
///////////////////////////////////////////////////////////////////////////////
function SetPlayerVar(bool bSet)
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);

	if(P2Player(CheckPawn.Controller) != None)
		P2Player(CheckPawn.Controller).SetRadarShowGuns(bActive);
}

///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
auto state StartUp
{
Begin:
	Sleep(0.3);
	if(P2Player(P2Pawn(Owner).Controller) != None)
		P2Player(P2Pawn(Owner).Controller).UpdateHudInvHints();
}

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	///////////////////////////////////////////////////////////////////////////////
	// Turn it back off
	///////////////////////////////////////////////////////////////////////////////
	function Activate()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		if(P2Player(CheckPawn.Controller) != None)
		{
			Owner.PlaySound(DeactivateSound);
			bActive=false;
			P2Player(P2Pawn(Owner).Controller).UpdateHudInvHints();
			SetPlayerVar(bActive);
			GotoState('');
		}
	}

	///////////////////////////////////////////////////////////////////////////////
	// Turn it on
	///////////////////////////////////////////////////////////////////////////////
	function PlugIn()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		if(P2Player(CheckPawn.Controller) != None)
		{
			SetPlayerVar(bActive);
			TurnOffHints();
		}
		else
			GotoState('');
	}

Begin:
	Sleep(0.3);
	if(P2Player(P2Pawn(Owner).Controller) != None)
		P2Player(P2Pawn(Owner).Controller).UpdateHudInvHints();
	PlugIn();
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	PickupClass=class'GunRadarPlugPickup'
	Icon=Texture'Hudpack.icons.icon_inv_Piranah'
	InventoryGroup=101
	GroupOffset=7
	PowerupName="'Piranha' Plug-In"
	PowerupDesc="Shows potentially dangerous fish on your Bass Sniffer Radar."
	ExamineAnimType="Letter"
	ExamineDialog=Sound'DudeDialog.dude_ithinkineedthat'
	Hint1="Press %KEY_InventoryActivate% when your Radar is active"
	Hint2="to see potentially dangerous fish."
	Hint3="'Piranha' Plug-in is On."
	Hint4="'Piranha' Plug-in is Off."
	ActivateSound = Sound'MiscSounds.Radar.PluginActivate'
	DeactivateSound = Sound'MiscSounds.Radar.PluginDeactivate'
	}
