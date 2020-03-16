//=============================================================================
// AWGaryHead
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWGaryHead extends AWHead
	placeable;

var float spinheadtime;
var float spinspeed;
var float toolheadtime;
var float activetime;
var float activerand;
var rotator StartRotation;	// starting relative rotation

///////////////////////////////////////////////////////////////////////////////
// Rotate around slowly
///////////////////////////////////////////////////////////////////////////////
state SpinHead
{
	function Tick(float DeltaTime)
	{
		local rotator userot;
		userot = RelativeRotation;
		userot.Pitch = userot.Pitch + spinspeed*DeltaTime;

		SetRelativeRotation(userot);
	}
Begin:
	Sleep(spinheadtime);
	GotoState('Active');
}

///////////////////////////////////////////////////////////////////////////////
// pick random rotations for head to go to 
///////////////////////////////////////////////////////////////////////////////
state ToolHead
{
	function Tick(float DeltaTime)
	{
		local rotator userot;
		userot = RelativeRotation;
		userot.Pitch = FRand()*65535;

		SetRelativeRotation(userot);
	}
Begin:
	Sleep(toolheadtime);
	GotoState('Active');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Active
{
	function BeginState()
	{
		SetRelativeRotation(StartRotation);
	}
Begin:
	Sleep(activetime + FRand()*activerand);
	if(FRand() < 0.5)
		GotoState('SpinHead');
	else
		GotoState('ToolHead');
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     spinheadtime=6.500000
     SpinSpeed=10000.000000
     toolheadtime=1.500000
     activetime=5.000000
     activerand=5.000000
     StartRotation=(Yaw=-16384,Roll=16384)
     HeadBounce(0)=Sound'MiscSounds.People.head_bounce'
     HeadBounce(1)=Sound'MiscSounds.People.head_bounce2'
}
