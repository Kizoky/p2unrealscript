///////////////////////////////////////////////////////////////////////////////
// CameraTitle.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// Camera effect that displays a material at a specified size and position.
// Like all camera effects, it also supports alpha.
//
//	History:
//		05/14/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class CameraTitle extends CameraEffect
	native
//	noexport
	editinlinenew
	collapsecategories;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() color		OverlayColor;
var() Material	OverlayMaterial;	// what to display
var() float		OverlaySizeFactor;	// size relative to screen width (1.0=full width, 0.5=half, etc.)
var() float		OverlayXPos;		// center of object as % of width (0.0=left, 1.0=right)
var() float		OverlayYPos;		// center of object as % of height (0.0=top, 1.0=bottom)
var() Actor.ERenderStyle OverlayStyle;	// style to use when drawing material


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
	OverlayStyle=5	// STY_Alpha (no enums in defaultproperties)
	}
