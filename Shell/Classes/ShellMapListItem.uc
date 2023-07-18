///////////////////////////////////////////////////////////////////////////////
// ShellMapListItem.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
//
// An item that's displayed in the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMapListItem extends UWindowListBoxItem;

var string MapName;
var string DisplayName;

function int Compare(UWindowList T, UWindowList B)
	{
	if(Caps(ShellMapListItem(T).MapName) < Caps(ShellMapListItem(B).MapName))
		return -1;

	return 1;
	}

// Call only on sentinel
function ShellMapListItem FindMap(string FindMapName)
	{
	local ShellMapListItem I;

	for(I = ShellMapListItem(Next); I != None; I = ShellMapListItem(I.Next))
		if(I.MapName ~= FindMapName)
			return I;

	return None;
	}

defaultproperties
	{
	}
