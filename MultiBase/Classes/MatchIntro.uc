///////////////////////////////////////////////////////////////////////////////
// MatchIntro.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// Base class for match intro sequences.
//
///////////////////////////////////////////////////////////////////////////////
class MatchIntro extends Info
	abstract;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var bool						bRunning;

var float						TotalDuration;
var float						RealStartTime;
var float						StartTime;
var float						MaxReadyWaitTime;

var float						Percent;
var float						PrevPercent;
var float						ElapsedTime;

var bool						bStableFrameRate;
var int							ConsecGoodFrames;
var float						FirstFrameTime;
var float						LastFrameTime;
var const float					MaxGoodFrameTime;
var const int					MinGoodFrames;
var const float					MaxStableWaitTime;

var private bool				bJumpToEnd;
			
var color						WhiteColor;


///////////////////////////////////////////////////////////////////////////////
// Start the intro sequence.
///////////////////////////////////////////////////////////////////////////////
function Start()
{
	RealStartTime = Level.TimeSeconds;
	Percent = 0.0;
	PrevPercent = 0.0;

	bStableFrameRate = false;
	ConsecGoodFrames = 0;
	FirstFrameTime = -1.0;

	bRunning = true;
}

///////////////////////////////////////////////////////////////////////////////
// End the intro sequence.  It can be ended at any time, though the idea is
// to wait until CanEnd() returns true, which indicates that the intro has
// reached a point where it's okay for the user to end it.
///////////////////////////////////////////////////////////////////////////////
function End()
{
	bRunning = false;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if intro can be ended now.
///////////////////////////////////////////////////////////////////////////////
function bool CanEnd()
{
	if (bRunning)
		return Percent == 1.0 && PrevPercent == 1.0;
	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if intro is running.
///////////////////////////////////////////////////////////////////////////////
function bool IsRunning()
{
	return bRunning;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if intro is ready for calls to Run()
///////////////////////////////////////////////////////////////////////////////
function bool IsReadyForRun();

///////////////////////////////////////////////////////////////////////////////
// Update the intro sequence.
///////////////////////////////////////////////////////////////////////////////
function Update(Canvas Canvas)
{
	local float CurrentTime;
	
	CurrentTime = Level.TimeSeconds;
//	Log(self @ "Update(): time="$CurrentTime$" real elapsed="$CurrentTime - RealStartTime$" elapsed="$CurrentTime - StartTime$" StarTime="$StartTime$" Percent="$Percent$" PrevPercent="$PrevPercent$" IsReadyForRun()="$IsReadyForRun()$" bRunning="$bRunning);

	if (bRunning)
	{
		// The frame rate is often VERY sporadic when we just joined a match so
		// we wait for the frame rate to stabalize before starting the intro.
		if (!bStableFrameRate)
		{
			if (FirstFrameTime == -1)
				FirstFrameTime = CurrentTime;
			else if (CurrentTime - LastFrameTime <= MaxGoodFrameTime)
				ConsecGoodFrames++;
			else
				ConsecGoodFrames = 0;
			LastFrameTime = CurrentTime;

			if ((ConsecGoodFrames == MinGoodFrames) || (CurrentTime - FirstFrameTime > MaxStableWaitTime))
				bStableFrameRate = true;
		}
		else
		{
			// If we've already updated or if we're ready to update for the first time...
			if (Percent > 0.0 || IsReadyForRun())
			{
				// On our first update, reset the start time because we're starting NOW
				if (Percent == 0.0)
					StartTime = CurrentTime;

				// Calculate how far into the sequence we are as a percentage
				if (bJumpToEnd)
					Percent = 1.0;
				else
					Percent = (CurrentTime - StartTime) / TotalDuration;

				if (Percent == 0.0)
					Percent = 0.0001;	// Anything but 0.0 so we can tell we started
				if (Percent > 1.0)
					Percent = 1.0;

				ElapsedTime = Percent * TotalDuration;
				Run(Canvas);
				
				PrevPercent = Percent;
			}
			else
			{
				if (CurrentTime - RealStartTime > MaxReadyWaitTime)
					bRunning = false;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// This is where all everything happens
///////////////////////////////////////////////////////////////////////////////
function Run(Canvas Canvas)
{
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function JumpToEnd()
{
	bJumpToEnd = true;
}

///////////////////////////////////////////////////////////////////////////////
// Return true if the current percentage has reached the specified point.
///////////////////////////////////////////////////////////////////////////////
function bool IsAt(float Perc)
{
	return (PrevPercent <= Perc && Percent >= Perc);
}

function bool IsAtTime(float Time)
{
	if (Time > TotalDuration)
		Time = TotalDuration;
	return IsAt(Time / TotalDuration);
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if current percentage is in the specified range.
// SubPercent ranges from 0.0 to 1.0 and indicates where current percentage
// falls within the specified range.  SubPercent is updated regardless of the
// return value.
///////////////////////////////////////////////////////////////////////////////
function bool InRange(float Percent1, float Percent2, out float SubPercent)
{
	if (Percent >= Percent1 && Percent <= Percent2)
	{
		SubPercent = (Percent - Percent1) / (Percent2 - Percent1);
		if (SubPercent < 0.0)
			SubPercent = 0.0;
		if (SubPercent > 1.0)
			SubPercent = 1.0;
		return true;
	}

	if (Percent < Percent1)
		SubPercent = 0.0;
	if (Percent > Percent2)
		SubPercent = 1.0;
	return false;
}

function bool InRangeTime(float Time1, float Time2, out float SubPercent)
{
	if (Time1 > TotalDuration)
		Time1 = TotalDuration;
	if (Time2 > TotalDuration)
		Time2 = TotalDuration;

	return InRange(Time1 / TotalDuration, Time2 / TotalDuration, SubPercent);
}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	MaxReadyWaitTime=15.0
	MaxGoodFrameTime=0.5	// hugely conservative
	MinGoodFrames=5
	MaxStableWaitTime=3.0
	TotalDuration=1.0
	WhiteColor=(R=255,G=255,B=255,A=255)
}
