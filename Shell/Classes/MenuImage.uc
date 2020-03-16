///////////////////////////////////////////////////////////////////////////////
// MenuImage.uc
// Copyright 2003 Running With Scissors, Inc.  All Rights Reserved.
//
// The base for image menus.
//
///////////////////////////////////////////////////////////////////////////////
// This class describes a basic image menu.  Extend it to provide an image,
// title, and options.
//
// Future enhancements:
//
///////////////////////////////////////////////////////////////////////////////
class MenuImage extends ShellMenuCW;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var int ImageTopEdge  ;
var int ImageBotEdge  ;
var int ImageLeftEdge ;
var int ImageRightEdge;

var string strTitle;		// Simply initialize this in your extended menu's defaultproperties.

var ShellBitmap	ImageArea;
var name			TextureImageName;
var Texture			texImage;
var texture         TileTex;

var array<Region>	aregButtons;	// Set to array of button locations to overide default menu
									// button locations.  These are percentages of the menu
									// for consistency across resolutions.

const c_fLocationDivisorX	= 640.0;
const c_fLocationDivisorY	= 480.0;
const FOUR_BY_THREE_ASPECT_RATIO  = 1.33333333333;

///////////////////////////////////////////////////////////////////////////////
// Create menu contents
///////////////////////////////////////////////////////////////////////////////
function CreateMenuContents()
	{
	Super.CreateMenuContents();

	AddTitle(strTitle, TitleFont, TitleAlign);
	}

///////////////////////////////////////////////////////////////////////////////
// Appears to be a post-creation event for adding children and stuff.
///////////////////////////////////////////////////////////////////////////////
function Created()
	{
	// Root size will not be valid if another menu hasn't been shown prior
	// to this menu.  This menu is particularly sensitive to screen size
	// because the image is usually stretched out to the full screen, which
	// is why normal menus don't have to do this extra work.  If the size
	// isn't valid here, we'll get a ResolutionChanged() event and adjust
	// everything at that time.
	if (Root.WinWidth > default.MenuWidth && Root.WinHeight > default.MenuHeight)
		{
		MenuWidth = Root.WinWidth;
		MenuHeight = Root.WinHeight;
		}

	// CreateMenuContents is called by the super's Created() so all menu items
	// should be setup after this.
	super.Created();

	// Load texture
	if (TextureImageName != 'None')
		texImage = Texture(DynamicLoadObject(String(TextureImageName), class'Texture'));

	// Add a child window for the message.
	if (texImage != None)
		{
		ImageArea = ShellBitmap(CreateWindow(
			class'ShellBitmap',
			ImageLeftEdge,
			ImageTopEdge,
			WinWidth - (ImageLeftEdge + ImageRightEdge),
			WinHeight - (ImageTopEdge + ImageBotEdge) ) );
		ImageArea.MyMenu = self;
		ImageArea.bStretch = false;	// This value can be overridden by the extender.
		ImageArea.bAlpha   = false;	// This value can be overridden by the extender.
		ImageArea.bFit	   = false;	// This value can be overridden by the extender.
		ImageArea.bCenter  = false;	// This value can be overridden by the extender.
		ImageArea.bModernNoStretch = true;
		ImageArea.T = texImage;
		ImageArea.TileTex = TileTex;
		ImageArea.R.X = 0;
		ImageArea.R.Y = 0;
		ImageArea.R.W = ImageArea.T.USize;
		ImageArea.R.H = ImageArea.T.VSize;
		ImageArea.SendToBack();	// Make sure this is behind the buttons.
		ImageArea.bAlwaysBehind = true;
		}

	SetButtonLocations(WinWidth, WinHeight, ImageArea.bModernNoStretch);
	}

///////////////////////////////////////////////////////////////////////////////
// Called when user clicks on the image
///////////////////////////////////////////////////////////////////////////////
function ImageClick(float X, float Y);

///////////////////////////////////////////////////////////////////////////////
// Set button locations, which are expressed as percentages of the full-screen
// size of the image.
///////////////////////////////////////////////////////////////////////////////
function SetButtonLocations(float W, float H, optional bool bModernNoStretch)
	{
	local int iIter;
	local float NearestFourByThree, OffsetX;



	if(!bModernNoStretch)
	{
	for (iIter = 0; iIter < MenuItems.Length && iIter < aregButtons.Length; iIter++)
		{
		MenuItems[iIter].Window.BringToFront();
		MenuItems[iIter].Window.WinLeft	= W	* aregButtons[iIter].X / c_fLocationDivisorX;
		MenuItems[iIter].Window.WinTop  = H * aregButtons[iIter].Y / c_fLocationDivisorY;
		MenuItems[iIter].Window.SetSize(  W * aregButtons[iIter].W / c_fLocationDivisorX,
										  H * aregButtons[iIter].H / c_fLocationDivisorY);
		}
		}
	else
	{
	if(W/H != FOUR_BY_THREE_ASPECT_RATIO)
        NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(H * 1);
    else
        NearestFourByThree = W;

    OffsetX = (W / 2) - (NearestFourByThree / 2);//((WinHeight - NearestFourByThree) /2);


	for (iIter = 0; iIter < MenuItems.Length && iIter < aregButtons.Length; iIter++)
		{
		MenuItems[iIter].Window.BringToFront();
		MenuItems[iIter].Window.WinLeft	= OffsetX + (NearestFourByThree * aregButtons[iIter].X / c_fLocationDivisorX);
		MenuItems[iIter].Window.WinTop  = H * aregButtons[iIter].Y / c_fLocationDivisorY;
		MenuItems[iIter].Window.SetSize(  W * aregButtons[iIter].W / c_fLocationDivisorX,
										  H * aregButtons[iIter].H / c_fLocationDivisorY);
		}
	}
	}

///////////////////////////////////////////////////////////////////////////////
// Resolution changed.
// We need to handle this because we want the image to be full-screen size
// regardless of how big the menu is.
///////////////////////////////////////////////////////////////////////////////
function ResolutionChanged(float W, float H)
	{
	Super.ResolutionChanged(W, H);

	// Maximize menu
	WinLeft = 0;
	WinTop = 0;
	WinWidth = W;
	WinHeight = H;
	MenuWidth = WinWidth;
	MenuHeight = WinHeight;

	// Maximize image (this shouldn't really be done here, but the class it
	// uses doesn't handle this functionality, hence this hack)
	ImageArea.WinLeft = 0;
	ImageArea.WinTop = 0;
	ImageArea.WinWidth = W;
	ImageArea.WinHeight = H;

	SetButtonLocations(W, H);
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	MenuWidth  = 640
	MenuHeight = 480
    TileTex = Texture'nathans.Inventory.blackbox64';
	ImageTopEdge   = 0;
	ImageBotEdge   = 0;
	ImageLeftEdge  = 0;
	ImageRightEdge = 0;
	}
