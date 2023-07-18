///////////////////////////////////////////////////////////////////////////////
// MenuAdminKickBan.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// The Admin menu for kicking or banning a player.
//
// History:
//	10/17/03 CRK	Started it.
//
///////////////////////////////////////////////////////////////////////////////
class MenuAdminKickBan extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var localized string KickTitle;

var UWindowComboControl PlayerCombo;
var localized string	PlayerText;
var localized string	PlayerHelp;

var ShellMenuChoice		KickChoice;
var localized string	KickText;
var localized string	KickHelp;

var ShellMenuChoice		BanChoice;
var localized string	BanText;
var localized string	BanHelp;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(KickTitle, TitleFont, TitleAlign);

	PlayerCombo			= AddComboBox(PlayerText,	PlayerHelp, ItemFont);
	KickChoice			= AddChoice(KickText,		KickHelp,	ItemFont, ItemAlign);
	BanChoice			= AddChoice(BanText,		BanHelp,	ItemFont, ItemAlign);

	BackChoice			= AddChoice(BackText,		"", ItemFont, ItemAlign, true);

	LoadValues();
	}

function LoadValues()
{
	local array<PlayerReplicationInfo> PRIArray;
	local MpPlayerReplicationInfo PRI;
	local int i;

	PlayerCombo.Clear();
	PlayerCombo.SetButtons(true);
	PlayerCombo.EditBoxWidth += 100;

	// load the player list from game rep info
	PRIArray = GetPlayerOwner().GameReplicationInfo.PRIArray;

	for (i = 0; i < PRIArray.Length; i++)
    {
		PRI = MpPlayerReplicationInfo(PRIArray[i]);
		if (PRI != None && !PRI.bBot)
			PlayerCombo.AddItem(PRI.PlayerName);
	}

	PlayerCombo.SetSelectedIndex(0);
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
	{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case KickChoice:
						GetPlayerOwner().ConsoleCommand("admin" @ "kick" @ PlayerCombo.GetValue());
						HideMenu();
						break;
					case BanChoice:
						GetPlayerOwner().ConsoleCommand("admin" @ "kickban" @ PlayerCombo.GetValue());
						HideMenu();
						break;
					case BackChoice:
						GoBack();
						break;
					}
			break;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MenuWidth	= 350
	KickTitle	= "Kick/Ban Menu"
	PlayerText	= "Player"
	PlayerHelp	= "Select the player you want to remove from the game"
	KickText	= "Kick"
	KickHelp	= "Force the selected player to leave the game"
	BanText		= "Ban"
	BanHelp		= "Kick the selected player and do not allow them to enter this game again" 
}
