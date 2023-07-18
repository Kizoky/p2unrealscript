///////////////////////////////////////////////////////////////////////////////
// ShellMapListLoadButton.uc
// Copyright 2023 Running With Scissors Studios LLC.  All Rights Reserved.
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