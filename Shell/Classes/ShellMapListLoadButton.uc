///////////////////////////////////////////////////////////////////////////////
// ShellMapListLoadButton.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Load button for the map list box.
//
///////////////////////////////////////////////////////////////////////////////
class ShellMapListLoadButton extends UWindowSmallOKButton;


function Created()
	{
	Super.Created();
	SetText("Load");
	}

function Click(float X, float Y)
	{
	ShellMapListCW(ParentWindow).LoadButtonClicked();
	Super.Click(x,y);
	}

defaultproperties
	{
	}