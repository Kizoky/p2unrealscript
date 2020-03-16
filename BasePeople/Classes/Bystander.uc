//=============================================================================
// Bystander
// Copyright 2001 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for all bystander characters.
//
//=============================================================================
class Bystander extends AWPerson
	notplaceable
	Abstract;


defaultproperties
	{
	Conscience=0.2
	SafeRangeMin=1024
	HealthMax=55
	ControllerClass=class'BystanderController'
	bIsTrained=false
	}
