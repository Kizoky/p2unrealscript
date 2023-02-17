///////////////////////////////////////////////////////////////////////////////
// KaraokeMenu
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// Menu called by ACTION_CustomMenu. Was designed as a karaoke menu (thus
// the references to songs and shit) but can be used for any custom menu.
///////////////////////////////////////////////////////////////////////////////
class KaraokeMenu extends P2EInteraction;

///////////////////////////////////////////////////////////////////////////////
// Vars, const, enums, etc
///////////////////////////////////////////////////////////////////////////////
struct SongInfo
{
	var() Name EventName;			// Names of events to trigger
	var() bool SongDisabled;		// If true, song has already been played and cannot be selected
};

var() Font SongFont;				// Font to use
var() array<SongInfo> SongInfos;	// Info on each song in the list
var() array<string> DisabledSound;	// Sound to play if picking a disabled option

/** Index of the button from the Buttons array that is currently highlighted */
var int HighlightedButton;

var vector CanvasDimensions;	// Current dimensions of canvas
var vector CanvasClip;
var float CanvasLeftBound;		// Canvas left bound

/** Initializes the wish granting menu */
event Initialized() {
	Super.Initialized();
    PauseGame();
}

/** Overriden to implement button checking and execution */
function LeftClick() {
	// If it's disabled, say something snarky
	if (HighlightedButton < SongInfos.Length && SongInfos[HighlightedButton].SongDisabled)
	{
		PlayerOwner.ClientPlaySound(Sound(DynamicLoadObject(DisabledSound[Rand(DisabledSound.Length)],class'Sound')));
		return;
	}
		
	if (HighlightedButton < SongInfos.Length)
		PlayerOwner.TriggerEvent(SongInfos[HighlightedButton].EventName, PlayerOwner.Pawn, PlayerOwner.Pawn);

    // Close the menu only when clicking a valid button or the exit one
    if (HighlightedButton != -1 || HighlightedButton == Buttons.length - 1) {
        ResumeGame();
        CloseMenu();
    }
}

/** Overriden to implement the various wish bubbles the Dude may have */
function PostRender(Canvas Canvas) {
    local bool bFoundButton;
    local int i;
    local float CanvasScale;

    local vector TopLeft;
    local vector WishButtonPos, WishButtonTextPos;

    if (SongFont == none || ButtonTexture == none)
        return;

    /** Half assed fix for preventing the menu from persisting during Pausing
     * and then quitting back to the main menu
     */
    if (AreAnyRootWindowsRunning())
        CloseMenu();

    /** Setup initial rendering stuff like the style and font */
    Canvas.Style = 1;
    Canvas.Font = SongFont;

    /** Find our draw scale, left bound, and record original font scale */
    CanvasScale = Canvas.ClipY / 768.0f;

    TopLeft.X = GetLeftBound(Canvas);
	CanvasLeftBound = TopLeft.X;
	
	CanvasClip.X = Canvas.ClipX;
	CanvasClip.Y = Canvas.ClipY;

    /** We want to ignore the extra X space as a result from widescreen resolutions */
    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;

    for (i=0;i<Buttons.length;i++) {
		// Set draw color to white if enabled, or grey if disabled.
		if (i < SongInfos.Length && SongInfos[i].SongDisabled)
		{
			Canvas.SetDrawColor(128, 128, 128, 255);
		}
		else
			Canvas.SetDrawColor(255, 255, 255, 255);
		
        /** Draw the item info box */
        WishButtonPos.X = TopLeft.X * Canvas.ClipX + Buttons[i].Pos.X * CanvasDimensions.X;
        WishButtonPos.Y = TopLeft.Y * Canvas.ClipY + Buttons[i].Pos.Y * CanvasDimensions.Y;

        Canvas.SetPos(WishButtonPos.X, WishButtonPos.Y);
        DrawTexture(Canvas, ButtonTexture, Buttons[i].Scale, CanvasScale);

        WishButtonTextPos.X = WishButtonPos.X + Buttons[i].TextOffset.X * CanvasDimensions.X;
        WishButtonTextPos.Y = WishButtonPos.Y + Buttons[i].TextOffset.Y * CanvasDimensions.Y;

        /** Do the IsHighlightedButton calculation here since we have rendering
         * information here
         */
        if (IsHighlightedButton(i, CanvasScale, WishButtonPos)) {
            bFoundButton = true;
            HighlightedButton = i;
			if (i < SongInfos.Length && SongInfos[i].SongDisabled)
				Canvas.SetDrawColor(128, 0, 0, 255);
			else
				Canvas.SetDrawColor(255, 0, 0, 255);
        }

        Canvas.SetPos(WishButtonTextPos.X, WishButtonTextPos.Y);
        SetCanvasFontScale(Canvas, Buttons[i].TextScale);
        Canvas.DrawText(Buttons[i].Text);
    }

    if (!bFoundButton) HighlightedButton = -1;

    /** Draw the player's cursor last so it goes over everything */
    if (CursorTexture != none) {
        Canvas.SetPos(ViewportOwner.WindowsMouseX, ViewportOwner.WindowsMouseY);
        DrawTexture(Canvas, CursorTexture, CursorDrawScale, CanvasScale);
    }

    ResetCanvasFontScale(Canvas);
}

/** Close the menu by unpausing the game and then removing */
function CloseMenu() {
    Master.RemoveInteraction(self);
}

///////////////////////////////////////////////////////////////////////////////
// Controller inputs.
///////////////////////////////////////////////////////////////////////////////
function execMenuButton()
{
	ResumeGame();
	CloseMenu();
}
function execConfirmButton()
{
	LeftClick();
}
function execBackButton()
{
	ResumeGame();
	CloseMenu();
}
function execMenuUpButton()
{
	NextMenuItem(-1);
}
function execMenuDownButton()
{
	NextMenuItem(1);
}
function execMenuLeftButton()
{
	NextMenuItem(-1);
}
function execMenuRightButton()
{
	NextMenuItem(1);
}
function NextMenuItem(int Offset)
{
	local int NextButton, IntMouseX, IntMouseY;
	local float MouseX, MouseY;
	
	NextButton = -1;
	
	// If nothing is highlighted, pick the first (if going down) or last (if going up)
	if (HighlightedButton == -1)
	{
		if (Offset < 0)
			NextButton = Buttons.Length - 1;
		else
			NextButton = 0;
	}
	else // cycle through items
	{
		NextButton = HighlightedButton + Offset;
		if (NextButton < 0)
			NextButton = Buttons.Length - 1;
		else if (NextButton >= Buttons.Length)
			NextButton = 0;
	}
	
	// Sanity check
	if (NextButton != -1)
	{
		MouseX = CanvasLeftBound * CanvasClip.X + Buttons[NextButton].Pos.X * CanvasDimensions.X + Buttons[NextButton].Scale.X * 0.5 * ButtonTexture.USize;
		MouseY = Buttons[NextButton].Pos.Y * CanvasDimensions.Y + Buttons[NextButton].Scale.Y * 0.5 * ButtonTexture.VSize;
		log("canvasclip"@CanvasClip.X@CanvasClip.Y@"leftbound"@CanvasLeftBound@"mousexy"@MouseX@MouseY);
		
		// Position mouse
		IntMouseX = MouseX;
		IntMouseY = MouseY;
		UWindowRootWindow(Master.BaseMenu).MoveMouse(MouseX,MouseY);
		if (PlatformIsWindows())	// not needed in SDL
			ViewportOwner.Actor.ConsoleCommand("SETMOUSE"@IntMouseX@IntMouseY);
	}
}

defaultproperties
{
    SongFont=Font'P2Fonts.Fancy48'

    ButtonTexture=texture'P2ETextures.VendingMachine.button_bg'
}