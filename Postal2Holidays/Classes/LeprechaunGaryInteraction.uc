/**
 * LeprechaunGaryInteraction
 *
 * Wishing menu that the player will be able to use to wish for all sorts of
 * rediculous things, such having an elephant sized penis!
 */
// Steven: Changed all vector2d to vector (see P2EInteraction.uc).
class LeprechaunGaryInteraction extends P2EInteraction;

/** Index of the button from the Buttons array that is currently highlighted */
var int HighlightedButton;
/** Font to use for the wish button */
var Font WishButtonFont;

/** Leprechaun Gary inventory to perform the wish granting */
var LeprechaunGaryInv LeprechaunInv;

/** Initializes the wish granting menu */
event Initialized() {
	Super.Initialized();
    PauseGame();
}

/** Overriden to implement button checking and execution */
function LeftClick() {
    switch (HighlightedButton) {
        case 0:
            LeprechaunInv.ElephantSizedDickWish();
            break;
        case 1:
            LeprechaunInv.HottestPersonWish();
            break;
        case 2:
            LeprechaunInv.HotBitchesWish();
            break;
        case 3:
            LeprechaunInv.InfiniteWishesWish();
            break;
    }

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

    local vector CanvasDimensions, TopLeft;
    local vector WishButtonPos, WishButtonTextPos;

    if (WishButtonFont == none || ButtonTexture == none)
        return;

    /** Half assed fix for preventing the menu from persisting during Pausing
     * and then quitting back to the main menu
     */
    if (AreAnyRootWindowsRunning())
        CloseMenu();

    /** Setup initial rendering stuff like the style and font */
    Canvas.Style = 1;
    Canvas.Font = WishButtonFont;
    Canvas.SetDrawColor(255, 255, 255, 255);

    /** Find our draw scale, left bound, and record original font scale */
    CanvasScale = Canvas.ClipY / 768.0f;

    TopLeft.X = GetLeftBound(Canvas);

    /** We want to ignore the extra X space as a result from widescreen resolutions */
    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;

    for (i=0;i<Buttons.length;i++) {
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
            Canvas.SetDrawColor(255, 0, 0, 255);
        }

        Canvas.SetPos(WishButtonTextPos.X, WishButtonTextPos.Y);
        SetCanvasFontScale(Canvas, Buttons[i].TextScale);
        Canvas.DrawText(Buttons[i].Text);

        Canvas.SetDrawColor(255, 255, 255, 255);
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

defaultproperties
{
    WishButtonFont=Font'P2Fonts.Fancy48'

    ButtonTexture=texture'P2ETextures.VendingMachine.button_bg'
    Buttons(0)=(Pos=(X=0.025f,Y=0.025),Scale=(X=2.2f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="I wish I had an elephant sized dick")
    Buttons(1)=(Pos=(X=0.225f,Y=0.125),Scale=(X=2.2f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="I wish to be the hottest guy in town")
    Buttons(2)=(Pos=(X=0.125f,Y=0.225),Scale=(X=2.4f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="I wish for hot bitches to work my balls")
    Buttons(3)=(Pos=(X=0.075f,Y=0.325),Scale=(X=1.75f,Y=1.0f),TextOffset=(X=0.025f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="I wish for infinite wishes")
    Buttons(4)=(Pos=(X=0.5f,Y=0.9f),Scale=(X=1.8f,Y=1.0f),TextOffset=(X=0.035f,Y=0.0175f),TextScale=(X=0.75f,Y=0.75f),Text="Eh... I'll decide later")
}