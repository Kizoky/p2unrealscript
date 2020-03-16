///////////////////////////////////////////////////////////////////////////////
// SubActionTitle.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// This matinee sub-action basically fades a title in, holds it, and then
// fades it out again.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class SubActionTitle extends MatSubAction
	native;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var(Title) editinline CameraEffect	CameraEffect;
var(Title) float					MinAlpha;
var(Title) float					MaxAlpha;
var(Title) float					FadeInTimePercent;	// percent of total duration to spend fading in
var(Title) float					FadeOutTimePercent;	// precent of total duration to spend fading out


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	Icon=SubActionFade
	Desc="Title"
	MinAlpha=0.0
	MaxAlpha=1.0
	FadeInTimePercent=0.2
	FadeOutTimePercent=0.2
	}