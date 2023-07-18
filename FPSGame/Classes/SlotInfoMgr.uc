///////////////////////////////////////////////////////////////////////////////
// SlotInfoMgr.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// Simple class for keeping track of slot information.  The only reason this
// is in a separate class is because we want this info to be in a separate
// ini file so that the info isn't lost when the other ini files are deleted.
//
///////////////////////////////////////////////////////////////////////////////
class SlotInfoMgr extends Info
	config(SavedGameInfo);


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

struct SlotInfo
{
	var string	Name;		// Name assigned by user.
	var int		Day;		// Current day when game was saved
	var string	Time;		// Time of last save.
	var	int		lTime;		// C Time used as sort key.
	var string	LoadScreen;	// Texture of loading screen to use when loading this slot.
};

var globalconfig array<SlotInfo> Slots;

// If we spawn with the pre-Steam 10 slots then update our slots
event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Slots.Length < 22)
	{
		Slots.Length = 22;
		SaveConfig();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Fill in the info
///////////////////////////////////////////////////////////////////////////////
function SetInfo(int Slot, string Name, int Day, string Time, int lTime, string LoadScreen)
	{
	Slots[Slot].Name  = Name;
	Slots[Slot].Day = Day;
	Slots[Slot].Time  = Time;
	Slots[Slot].lTime = lTime;
	Slots[Slot].LoadScreen = LoadScreen;
	SaveConfig();
	}

function SlotInfo GetInfo(int Slot)
	{
	return Slots[Slot];
	}

function int NumSlots()
	{
	return Slots.length;
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Slots(0)=(Name="",Day=0,Time="",lTime=0)
	Slots(1)=(Name="",Day=0,Time="",lTime=0)
	Slots(2)=(Name="",Day=0,Time="",lTime=0)
	Slots(3)=(Name="",Day=0,Time="",lTime=0)
	Slots(4)=(Name="",Day=0,Time="",lTime=0)
	Slots(5)=(Name="",Day=0,Time="",lTime=0)
	Slots(6)=(Name="",Day=0,Time="",lTime=0)
	Slots(7)=(Name="",Day=0,Time="",lTime=0)
	Slots(8)=(Name="",Day=0,Time="",lTime=0)
	Slots(9)=(Name="",Day=0,Time="",lTime=0)
	Slots(11)=(Name="",Day=0,Time="",lTime=0)
	Slots(12)=(Name="",Day=0,Time="",lTime=0)
	Slots(13)=(Name="",Day=0,Time="",lTime=0)
	Slots(14)=(Name="",Day=0,Time="",lTime=0)
	Slots(15)=(Name="",Day=0,Time="",lTime=0)
	Slots(16)=(Name="",Day=0,Time="",lTime=0)
	Slots(17)=(Name="",Day=0,Time="",lTime=0)
	Slots(18)=(Name="",Day=0,Time="",lTime=0)
	Slots(19)=(Name="",Day=0,Time="",lTime=0)
	Slots(20)=(Name="",Day=0,Time="",lTime=0)
	Slots(21)=(Name="",Day=0,Time="",lTime=0)
	}
