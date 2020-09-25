///////////////////////////////////////////////////////////////////////////////
// FontInfo
// Copyright 2002 Running With Scissors.  All Rights Reserved.
//
// Centralized font info intended to be used by everything in the game that
// needs to use fonts.
//
///////////////////////////////////////////////////////////////////////////////
//
// Notes to self in future
//
// One of the primary goals of this class is to allow text to be drawn at a
// consistent size for any screen resolution.  The engine does not support
// font scaling (to be fair, scaled fonts don't tend to look very good).
// Instead, this class automatically uses smaller fonts at lower resolutions
// and larger fonts at higher resolutions.
//
// By carefully choosing the font sizes this class will use, it is possible
// to keep text very consistent across all resolutions.
//
// These are the standard display resolutions:
//
//							Aspect Ratio	% increase from previous resolution
//		320x240					1.33				
//		400x300					1.33				125%
//		512x384					1.33				128%
//		640x480					1.33				125%
//		800x600					1.33				125%
//		1024x768				1.33				128%
//		1280x960 & 1280x1024	1.33/1.25			125%
//		1600x1200				1.33				125%
//
// Note that the percentage increase is very similar for each step up in
// resolution.  We can average this out to 125.86%.
//
// Imagine we only wanted a single font size for all the text in the game
// and we were working at 320x240.  To keep text the same size at the other
// resolutions we'd need one additional font per resolution, each 125.86%
// larger than the previous font.  When the app wants to draw text, we would
// simply look up the font associated with the current resolution.
//
// That's basically how we do it, except we allow multiple font sizes per
// resolution, which is almost free because we already have a range of font
// sizes (one per resolution).  So for each additional size we want to support,
// we only need to add one additional font.
//
// We decided on 1024x768 as our "standard" resolution, which merely means that
// we do everything relative to that resolution.
//
// NOTE: 400x300 is not supported by the engine but is included to fill in
// the "gap" between 320x240 and 512x384, which helps simplify the code.
//
// NOTE: 1280x1024 has a unique aspect ratio.  We simply treat it like 1280x960
// which means text will appear slightly shorter compared to other resolutions.
//
// NOTE: An Excel spreadsheet exists to help calculate all the required
// font sizes.  See \Postal2\Docs\FontSizes.xls.
//
//
// Font styles
//
// Try to choose a plain font that is similar in spacing to the fancy font.
// The fancy font will presumably be used more often and the plain font will
// be used as a fallback.  If that's the case, then the plain font should
// be somewhat narrower (and never wider) than the fancy font.
//
///////////////////////////////////////////////////////////////////////////////
class FontInfo extends Info;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

const RESOLUTIONS			= 8;					// Number of resolutions (see explanation above)
const FONT_SIZES			= 4;					// Number of sizes (smallest=0, largest=FONT_SIZES-1)
const FONT_TYPES			= 2;					// Number of styles (plain and fancy)

const FONT_INCREMENTS		= 11;					// RESOLUTIONS + FONT_SIZES - 1
const TOTAL_FONTS			= 22;					// FONT_INCREMENTS * FONT_TYPES


enum EJustify
	{
	EJ_Left,		// Text is drawn to the right of the specified x position
	EJ_Right,		// Text is drawn to the left of the specified x position
	EJ_Center,		// Text is drawn centered around the specified x position
	};

var Color					TextColor;				
var Color					ShadowColor;

var name					FontNames[TOTAL_FONTS];
var vector					ShadowOffsets[TOTAL_FONTS];
var Font					CachedFonts[TOTAL_FONTS];

var private float			ResWidth;
var private float			ResAdjustment;
var private int				LatestFontIndex;

var FPSHud					MyHUD;

// Temp variables to hold data for button icons
var array<String> ButtonPos;
var array<Vector> ButtonVec;
var array<Texture> ButtonTex;

const ICON_PLACEHOLDER = "    ";
const KEY_SPECIAL_MOVEMENT = "SPECIAL_MOVEMENT";
const KEY_SPECIAL_LOOK = "SPECIAL_LOOK";

// Look for "%KEY_xxx%" macros and replace them
// Need Canvas here to get a reference to the playercontroller.
function string ParseForKeys(string S, Canvas Canvas)
{
	local string OutStr,LeftHalf,RightHalf,Macro,Key,TestKey;
	local int pos,pos2,iIter,numKeys,i;
	local bool bJoyUser;
	local Texture UseTex;

	// Don't bother unless we have an actual hud set up
	if (MyHud == None)
		return S;
		
	//ErikFOV Change: For Nick's coop
	if( MyHUD.MyButtons == None 
		|| Canvas.Viewport.Actor == None )
		return S;
	//End
	
	OutStr = S;
	
	//ErikFOV Change: For Nick's coop
	if( MyHud.PlayerOwner != None && MyHud.PlayerOwner.Player != None )
		bJoyUser = FPSPlayer(MyHud.PlayerOwner).InputTracker.bUsingJoystick || (MyHud.PlayerOwner.Player.InteractionMaster.BaseMenu.IsInState('MenuShowing') && UWindowRootWindow(MyHud.PlayerOwner.Player.InteractionMaster.BaseMenu).bUsingJoystick);
		//bJoyUser = FPSPlayer(MyHud.PlayerOwner).InputTracker.bUsingJoystick || (MyHud.PlayerOwner.Player.InteractionMaster.BaseMenu.IsInState('MenuShowing') && UWindowRootWindow(MyHud.PlayerOwner.Player.InteractionMaster.BaseMenu).bUsingJoystick);
	//End	
	
	//bJoyUser = FPSPlayer(MyHud.PlayerOwner).InputTracker.bUsingJoystick || UWindowRootWindow(MyHud.PlayerOwner.Player.InteractionMaster.BaseMenu).bUsingJoystick;
	
	while (InStr(OutStr,"%KEY_") > -1)
	{
		pos = InStr(OutStr,"%KEY_");
		LeftHalf = Left(OutStr, pos);
		// LeftHalf now contains everything up to but not including the macro		
		Macro = Right(OutStr, len(OutStr) - pos - 5);
		// Macro now contains everything after the first "%KEY_"
		pos2 = InStr(Macro, "%");
		RightHalf = Right(Macro, len(Macro) - pos2 - 1);
		// RightHalf now contains everything after the macro end
		Macro = Left(Macro, pos2);
		// Macro now contains the alias we need to find
		
		// Handle special macros
		if (Macro ~= KEY_SPECIAL_MOVEMENT)
		{
			Key = "";
			iIter = 0;
			numKeys = 0;
			TestKey = Canvas.Viewport.Actor.ConsoleCommand("MOVEBIND"@iIter);
			while (TestKey != "")
			{
				// If the player is using joystick input, discard keyboard bindings, and vice versa
				if (bJoyUser && Left(TestKey, 3) != "Joy")
					TestKey = "";
				else if (!bJoyUser && Left(TestKey, 3) == "Joy")
					TestKey = "";
				if (TestKey != "")
				{
					// Add to button icons -- but only if it's not a repeat!
					UseTex = MyHUD.MyButtons.GetIcon(Int(Canvas.Viewport.Actor.ConsoleCommand("KEYNO"@TestKey)));
					for (i = 0; i < ButtonTex.Length; i++)
					{						
						if (ButtonTex[i] == UseTex)
						{
							// Repeat - null and void.
							UseTex = None;
							break;
						}
					}
					if (UseTex != None)
					{
						if (numKeys > 0)
							Key = Key $ "/";					
						// add to button icons
						ButtonPos.Insert(0, 1);
						ButtonPos[0] = LeftHalf $ Key;
						ButtonTex.Insert(0, 1);
						ButtonTex[0] = UseTex;
						ButtonVec.Insert(0, 1);
						ButtonVec[0].X = Canvas.CurX;
						ButtonVec[0].Y = Canvas.CurY;
						if (ButtonTex[0] != None)
						{
							Key = Key $ ICON_PLACEHOLDER;
							//log("replaced"@TestKey@"with"@ButtonTex[0]);
						}
						else
							Key = Key $ "[" $ TestKey $ "]";
						numKeys++;
					}
				}
				iIter++;
				TestKey = Canvas.Viewport.Actor.ConsoleCommand("MOVEBIND"@iIter);
			}
		}
		else if (Macro ~= KEY_SPECIAL_LOOK)
		{
			Key = "";
			iIter = 0;
			numKeys = 0;
			TestKey = Canvas.Viewport.Actor.ConsoleCommand("LOOKBIND"@iIter);
			while (TestKey != "")
			{
				// If the player is using joystick input, discard keyboard bindings, and vice versa
				if (bJoyUser && Left(TestKey, 3) != "Joy")
					TestKey = "";
				else if (!bJoyUser && Left(TestKey, 3) == "Joy")
					TestKey = "";
				if (TestKey != "")
				{
					// Add to button icons -- but only if it's not a repeat!
					UseTex = MyHUD.MyButtons.GetIcon(Int(Canvas.Viewport.Actor.ConsoleCommand("KEYNO"@TestKey)));
					for (i = 0; i < ButtonTex.Length; i++)
					{						
						if (ButtonTex[i] == UseTex)
						{
							// Repeat - null and void.
							UseTex = None;
							break;
						}
					}
					if (UseTex != None)
					{
						if (numKeys > 0)
							Key = Key $ "/";					
						// add to button icons
						ButtonPos.Insert(0, 1);
						ButtonPos[0] = LeftHalf $ Key;
						ButtonTex.Insert(0, 1);
						ButtonTex[0] = UseTex;
						ButtonVec.Insert(0, 1);
						ButtonVec[0].X = Canvas.CurX;
						ButtonVec[0].Y = Canvas.CurY;
						if (ButtonTex[0] != None)
						{
							Key = Key $ ICON_PLACEHOLDER;
							//log("replaced"@TestKey@"with"@ButtonTex[0]);
						}
						else
							Key = Key $ "[" $ TestKey $ "]";
						numKeys++;
					}
				}
				iIter++;
				TestKey = Canvas.Viewport.Actor.ConsoleCommand("LOOKBIND"@iIter);
			}
		}
		else if (int(Macro) > 0)
		{
			// KEY_### returns a specific key number, not a binding
			TestKey = Macro;
			// add to button icons
			ButtonPos.Insert(0, 1);
			ButtonPos[0] = LeftHalf $ Key;
			ButtonTex.Insert(0, 1);
			ButtonTex[0] = MyHUD.MyButtons.GetIcon(Int(TestKey));
			ButtonVec.Insert(0, 1);
			ButtonVec[0].X = Canvas.CurX;
			ButtonVec[0].Y = Canvas.CurY;
			if (ButtonTex[0] != None)
			{
				Key = Key $ ICON_PLACEHOLDER;
				//log("replaced"@TestKey@"with"@ButtonTex[0]);
			}
			else
				Key = Key $ "[" $ TestKey $ "]";
		}
		else
		{		
			Key = "";
			// Parse through bindings and find all results
			iIter = 0;
			numKeys = 0;
			TestKey = Canvas.Viewport.Actor.ConsoleCommand("BINDING2KEYSTR \""$Macro$"\""@iIter);		
			
			while (TestKey != "")
			{
				// If the player is using joystick input, discard keyboard bindings, and vice versa
				if (bJoyUser && Left(TestKey, 3) != "Joy")
					TestKey = "";
				else if (!bJoyUser && Left(TestKey, 3) == "Joy")
					TestKey = "";
				if (TestKey != "")
				{
					if (numKeys > 0)
						Key = Key $ "/";					
					// add to button icons
					ButtonPos.Insert(0, 1);
					ButtonPos[0] = LeftHalf $ Key;
					ButtonTex.Insert(0, 1);
					ButtonTex[0] = MyHUD.MyButtons.GetIcon(Int(Canvas.Viewport.Actor.ConsoleCommand("KEYNO"@TestKey)));
					ButtonVec.Insert(0, 1);
					ButtonVec[0].X = Canvas.CurX;
					ButtonVec[0].Y = Canvas.CurY;
					if (ButtonTex[0] != None)
					{
						Key = Key $ ICON_PLACEHOLDER;
						//log("replaced"@TestKey@"with"@ButtonTex[0]);
					}
					else
						Key = Key $ "[" $ TestKey $ "]";
					numKeys++;
				}
				iIter++;
				TestKey = Canvas.Viewport.Actor.ConsoleCommand("BINDING2KEYSTR \""$Macro$"\""@iIter);
			}
		}
		// If no binding exists, spit it out as "undefined"
		if (Key == "")
			Key = "[UNDEFINED]";
		else
			Key = Key $ "";
			
		// Now insert the keybindig into the string and search for more keybindings to replace
		OutStr = LeftHalf $ Key $ RightHalf;
		//log(outstr);
	}

	return OutStr;
}

///////////////////////////////////////////////////////////////////////////////
// Draws button icons after text.
///////////////////////////////////////////////////////////////////////////////
function DrawIconsOverText(Canvas Canvas, optional float UseX, optional float UseY, optional EJustify Justify, optional bool bClipped)
{
	local int i, pos;
	local float X, Y, XL, YL, SaveX, SaveY, UseScale, XL2, YL2;
	local color SaveColor;
	
	const ICON_SCALE = 1.5;
	
	SaveX = Canvas.CurX;
	SaveY = Canvas.CurY;
	SaveColor = Canvas.DrawColor;
	Canvas.SetDrawColor(255, 255, 255, 255);
	for (i = 0; i < ButtonPos.Length; i++)
	{
		if (UseX != 0 && UseY != 0)
		{
			X = UseX;
			Y = UseY;
		}
		else
		{
			X = ButtonVec[i].X;
			Y = ButtonVec[i].Y;
		}
		// Handle icons at start of strings
		if (ButtonPos[i] == "")
		{
			Canvas.StrLen(" ", XL, YL);
			XL = 0;
		}
		else
			Canvas.StrLen(ButtonPos[i], XL, YL);
		X += XL;
		Y -= YL / 4.0;

		// Scale up the icons a bit so they're easier to read
		UseScale = YL / ButtonTex[i].VSize;
		UseScale *= ICON_SCALE;
		
		// reposition a bit better along X
		Canvas.StrLen(ICON_PLACEHOLDER, XL2, YL2);
		X += (XL2 / 2.0) - (UseScale * ButtonTex[i].USize / 2.0);

		Canvas.SetPos(X, Y);
		if (bClipped)
			Canvas.DrawTileClipped(ButtonTex[i], ButtonTex[i].USize * UseScale, ButtonTex[i].VSize * UseScale, 0, 0, ButtonTex[i].USize, ButtonTex[i].VSize);
		else
			Canvas.DrawIcon(ButtonTex[i], UseScale);
		//log("drawicon ("$X$","$Y$")"@ButtonTex[i]@UseScale);
	}
	Canvas.SetPos(SaveX, SaveY);
	Canvas.DrawColor = SaveColor;

	// Zero out button icons
	ButtonPos.Length = 0;
	ButtonTex.Length = 0;
}


///////////////////////////////////////////////////////////////////////////////
// Draw text using all the specified atributes.
///////////////////////////////////////////////////////////////////////////////
function DrawTextEx(Canvas Canvas, float CanvasWidth, float x, float y, String str, int FontSize, optional bool bPlainFont, optional EJustify justify)
	{
	local float XL, YL;

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.Font = GetFont(FontSize, bPlainFont, CanvasWidth);

	str = ParseForKeys(str, Canvas);

	if (justify == EJ_Right)
		{
		Canvas.StrLen(str, XL, YL);
		x -= XL;
		}
	else if (justify == EJ_Center)
		{
		Canvas.StrLen(str, XL, YL);
		x -= (XL / 2);
		}

	Canvas.bCenter = false;
	Canvas.SetPos(x, y);
	Canvas.DrawColor = TextColor;
	DrawText(Canvas, str, 1.0, true);
	DrawIconsOverText(Canvas, x, y, justify);
	}

//ErikFOV Change: For Nick's coop
function bool FindMyHudFIX(Canvas C)
{
	if( MyHud == None 
		&& C.Viewport.Actor != None 
		&& C.Viewport.Actor.MyHud != None )
	{
		MyHud = FPSHud(C.Viewport.Actor.MyHud);
		return true;
	}
	return false;
}
//end

///////////////////////////////////////////////////////////////////////////////
// Draw text with a shadow behind it.
//
// This is intended as a simple substitute for Canvas.DrawText().  It assumes
// the position, font, color and style have all been set already and it returns
// with all those values unchanged.
//
// The shadow offsets are calculated based on the most recent call to GetFont().
//
// ShadowAlpha ranges from 255 (full) to 0 (none).  We take advantage of a
// brilliant Epic design feature whereby an alpha of 0 is interpreted as 255,
// so if the ShadowAlpha is not specified, the shadow will be drawn at 255.
///////////////////////////////////////////////////////////////////////////////
function DrawText(Canvas canvas, coerce String str,  optional float Fade, optional bool bNoIcons)
	{
	local float SaveX, SaveY;
	local Color SaveColor;
	local float x, y, x2, y2;
	local byte SaveStyle;
	
	//ErikFOV Change: For Nick's coop
	if( MyHUD == None )
		FindMyHudFIX(Canvas);
	//end
	
	// If we don't have a HUD, find it!
	if (MyHUD == None)
		foreach DynamicActors(class'FPSHud', MyHud)
			break;
	
	if (!bNoIcons)
		str = ParseForKeys(str, Canvas);

	if (Canvas.Font != None)
		{
		SaveX = Canvas.CurX;
		SaveY = Canvas.CurY;

		// Canvas.DrawText() truncates x and y prior to drawing.  So in order for shadows
		// to be consistently offset from the text, we need to truncate x and y.  That will
		// tell us the actual position at which the text will be drawn, and then we can
		// calculate the actual position for the shadows.
		x = int(SaveX);
		y = int(SaveY);
		x2 = x + ShadowOffsets[LatestFontIndex].X;
		y2 = y + ShadowOffsets[LatestFontIndex].Y;
		if (x2 != x || y2 != y)
			{
			SaveColor = Canvas.DrawColor;
			SaveStyle = Canvas.Style;
			Canvas.SetPos(x2, y2);
			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.DrawColor = ShadowColor;
			if (Fade == 0.0)
				Fade = 255.0;
			Canvas.DrawColor.A = float(ShadowColor.A) * Fade;
			Canvas.DrawText(str);
			Canvas.DrawColor = SaveColor;
			Canvas.SetPos(SaveX, SaveY);
			Canvas.Style = SaveStyle;
			}

		Canvas.DrawText(str);
		if (!bNoIcons)
			DrawIconsOverText(Canvas);
		}
	}
	
// Static version of above function, for drawing onto UWindow message boxes.
//!! HACK
function ClipText(Canvas Canvas, coerce string Str, optional bool bCheckHotkey)
{
	local float SaveX, SaveY;
	
	//ErikFOV Change: For Nick's coop
	if( MyHUD == None )
		FindMyHudFIX(Canvas);
	//end
	
	// If we don't have a HUD, find it!
	if (MyHUD == None)
		foreach DynamicActors(class'FPSHud', MyHud)
			break;	

	if (Canvas.Font != None)
	{
		SaveX = Canvas.CurX;
		SaveY = Canvas.CurY;
		str = ParseForKeys(str, Canvas);
		Canvas.DrawTextClipped(str, bCheckHotkey);
		Canvas.SetPos(SaveX, SaveY);
		DrawIconsOverText(Canvas,,,,true);
	}
}

function string GetButtonParsedText(Canvas Canvas, coerce string Str)
{
	if( MyHUD == None )
		FindMyHudFIX(Canvas);

	// If we don't have a HUD, find it!
	if (MyHUD == None)
		foreach DynamicActors(class'FPSHud', MyHud)
			break;	

	str = ParseForKeys(str, Canvas);
	DrawIconsOverText(Canvas,,,,true);

	return str;
}

///////////////////////////////////////////////////////////////////////////////
// Get font of specified size and style
///////////////////////////////////////////////////////////////////////////////
function Font GetFont(int FontSize, bool bPlainFont, float CanvasWidth)
	{
	local int FontIndex;

	if (ResWidth != CanvasWidth)
		UpdateRes(CanvasWidth);

	FontIndex = FontSize + ResAdjustment;
	if (bPlainFont)
		FontIndex += FONT_INCREMENTS;

	LatestFontIndex = FontIndex;
	return CachedFonts[FontIndex];
	}

///////////////////////////////////////////////////////////////////////////////
// Update cached font info using specified resolution
///////////////////////////////////////////////////////////////////////////////
private function UpdateRes(float CanvasWidth)
	{
	local int FontSize;
	local int FontIndex;

	// Specified resolution determines how much to increase or reduce font size
	if (CanvasWidth <= 320)
		ResAdjustment = 0;
//	else if (CanvasWidth <= 400)	// unsupported resolution
//		ResAdjustment = 1;
	else if (CanvasWidth <= 512)
		ResAdjustment = 2;
	else if (CanvasWidth <= 640)
		ResAdjustment = 3;
	else if (CanvasWidth <= 800)
		ResAdjustment = 4;
	else if (CanvasWidth <= 1024)
		ResAdjustment = 5;
	else if (CanvasWidth >= 1280)
		ResAdjustment = 6;
	else if (CanvasWidth >= 1600)
		ResAdjustment = 7;

	// Cache all the font sizes for this resolution
	for (FontSize = 0; FontSize < FONT_SIZES; FontSize++)
		{
		FontIndex = FontSize + ResAdjustment;

		if (CachedFonts[FontIndex] == None)
			CachedFonts[FontIndex] = Font(DynamicLoadObject(String(FontNames[FontIndex]), class'Font'));
		FontIndex += FONT_INCREMENTS;
		if (CachedFonts[FontIndex] == None)
			CachedFonts[FontIndex] = Font(DynamicLoadObject(String(FontNames[FontIndex]), class'Font'));
		}

	if (CanvasWidth < 320)
		Warn("Stupid canvas width specified:"$CanvasWidth);

	ResWidth = CanvasWidth;
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////
defaultproperties
	{
	// Fancy fonts
	FontNames[0]  = "P2Fonts.Plain5"
	FontNames[1]  = "P2Fonts.Plain6"
	FontNames[2]  = "P2Fonts.Plain8"
	FontNames[3]  = "P2Fonts.Plain10"
	FontNames[4]  = "P2Fonts.Fancy12"
	FontNames[5]  = "P2Fonts.Fancy15"
	FontNames[6]  = "P2Fonts.Fancy19"
	FontNames[7]  = "P2Fonts.Fancy24"
	FontNames[8]  = "P2Fonts.Fancy30"
	FontNames[9]  = "P2Fonts.Fancy38"
	FontNames[10] = "P2Fonts.Fancy48"
	// Plain fonts
	FontNames[11] = "P2Fonts.Plain5"
	FontNames[12] = "P2Fonts.Plain6"
	FontNames[13] = "P2Fonts.Plain8"
	FontNames[14] = "P2Fonts.Plain10"
	FontNames[15] = "P2Fonts.Plain12"
	FontNames[16] = "P2Fonts.Plain15"
	FontNames[17] = "P2Fonts.Plain19"
	FontNames[18] = "P2Fonts.Plain24"
	FontNames[19] = "P2Fonts.Plain30"
	FontNames[20] = "P2Fonts.Plain38"
	FontNames[21] = "P2Fonts.Plain48"

	// Fancy shadows
	ShadowOffsets[0]  = (X=0,Y=0)
	ShadowOffsets[1]  = (X=0,Y=0)
	ShadowOffsets[2]  = (X=0,Y=0)
	ShadowOffsets[3]  = (X=1,Y=0)
	ShadowOffsets[4]  = (X=1,Y=1)
	ShadowOffsets[5]  = (X=1,Y=1)
	ShadowOffsets[6]  = (X=1,Y=1)
	ShadowOffsets[7]  = (X=1,Y=1)
	ShadowOffsets[8]  = (X=2,Y=2)
	ShadowOffsets[9]  = (X=2,Y=2)
	ShadowOffsets[10] = (X=2,Y=2)
	// Plain shadows
	ShadowOffsets[11] = (X=0,Y=0)
	ShadowOffsets[12] = (X=0,Y=0)
	ShadowOffsets[13] = (X=0,Y=0)
	ShadowOffsets[14] = (X=1,Y=0)
	ShadowOffsets[15] = (X=1,Y=1)
	ShadowOffsets[16] = (X=1,Y=1)
	ShadowOffsets[17] = (X=1,Y=1)
	ShadowOffsets[18] = (X=1,Y=1)
	ShadowOffsets[19] = (X=2,Y=2)
	ShadowOffsets[20] = (X=2,Y=2)
	ShadowOffsets[21] = (X=2,Y=2)

	TextColor=(R=180,G=10,B=10,A=255)
	ShadowColor=(R=25,G=25,B=25,A=180)
	}
