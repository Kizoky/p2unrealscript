///////////////////////////////////////////////////////////////////////////////
// CameraText.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Camera effect that displays text at a specified size and position.
// Like all camera effects, it also supports alpha.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class CameraText extends CameraEffect
	native
//	noexport
	editinlinenew
	collapsecategories;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() color		OverlayColor;
var() float		OverlaySizeFactor;	// size relative to screen width (1.0=full width, 0.5=half, etc.)
var() float		OverlayXPos;		// center of object as % of width (0.0=left, 1.0=right)
var() float		OverlayYPos;		// center of object as % of height (0.0=top, 1.0=bottom)

var() String	OverlayText;		// text to display
var() Font		OverlayFont;		// font for text
var() bool		OverlayShadow;		// whether to draw drop shadow
var() Color		OverlayShadowColor;	// shadow color
var() float		OverlayShadowX;		// x offset for shadow
var() float		OverlayShadowY;		// y offset for shadow


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	FinalEffect=False
	OverlayColor=(R=255,G=255,B=255,A=255)
	OverlaySizeFactor=0.5
	OverlayXPos=0.5
	OverlayYPos=0.5
//	OverlayFont=Font'P2Fonts.Smash32'
	OverlayShadow=true
	OverlayShadowColor=(R=70,G=10,B=10,A=255)
	OverlayShadowX=.005
	OverlayShadowY=.005
	}
