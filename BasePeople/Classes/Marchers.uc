//=============================================================================
// Marchers
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all marching characters
//
//=============================================================================
class Marchers extends Bystander
	notplaceable
	Abstract;


defaultproperties
	{
	ControllerClass=class'MarcherController'
	bIsTrained=false
	Gang="Marchers"
	Talkative=0.0
	}
