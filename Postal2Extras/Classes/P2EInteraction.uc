/**
 * P2EInteraction
 *
 * A simplified base for Interactions that also provides several structs
 * for easy data access which streamlines the code a bit more
 *
 * NOTE: Make a get draw position function that takes the CanvasScale into consideration
 */
class P2EInteraction extends Interaction
    abstract;

/** A simple two dimensional vector, mostly used for Canvas drawing */
// Steven: Use normal vector instead so we can use all the vector operators when needed.
/*
struct vector2d {
    var float X, Y;
};
*/
/** Struct containing basic rendering information, mostly used for drawing text */
struct DrawInfo {
    /** Drawing position on the HUD in terms of percentage */
    var vector Pos;
    /** X and Y drawing scale for rendering both textures and text */
    var vector Scale;
};

/** Struct containing information on */
struct ButtonInfo {
    /** Drawing position on the HUD in terms of percentage */
    var() vector Pos;
    /** X and Y drawing scale for rendering both textures and text */
    var() vector Scale;
    /** Offset from the button's location to start drawing the text */
    var() vector TextOffset;
    /** Scale of the text inside the button */
    var() vector TextScale;
    /** Text to draw on the button */
    var() string Text;
};

// Steven:	Modder option to auto remove this interaction after a
//		level change. Needed by some such as 1409XLGame.ZPHUD
var bool	bAutoRemoveAfterLevelChange;
	
/** Integer reference to the current song playing in this Interaction */
var transient int SongHandle;

/** Button texture to use */
var texture ButtonTexture;
/** List of buttons */
var array<ButtonInfo> Buttons;

/** Cursor texture to draw for the player to use to select stuff */
var texture CursorTexture;
/** Draw scale for the player's cursor on the screen */
var vector CursorDrawScale;

// Quick reference to the P2 version of PlayerController.
var P2Player 	PlayerOwner;

// Steven: Needed for detecting level changes and resolution changes.
var private string CurrentURL;
var private vector CurrentResolution;

// Steven: Quick access to P2EUtils. Use GetP2EUtils() in case the reference to
// P2EUtils ever gets broken in some way.
var private P2EUtils	_P2EUtils;

// Kamek - controller support
const MENU_BUTTON = "MenuButton";
const CONFIRM_BUTTON = "ConfirmButton";
const BACK_BUTTON = "BackButton";
const MENU_UP_BUTTON = "MenuUpButton";
const MENU_DOWN_BUTTON = "MenuDownButton";
const MENU_LEFT_BUTTON = "MenuLeftButton";
const MENU_RIGHT_BUTTON = "MenuRightButton";

// Steven: Allow other classes to access P2EUtils if they are closely related to
// P2EInteraction.
final function P2EUtils GetP2EUtils()
{
	//assert(_P2EUtils != None);
	if (_P2EUtils == None)
	{
		// Create P2EUtils reference.
		_P2EUtils = new(None) class'P2EUtils';
	}
	return _P2EUtils;
}

/** Copied and pasted from... somewhere... returns whether or not a root window
 * such as the Pause Menu is open
 * @return TRUE if a root window is currently open; FALSE otherwise
 */
function bool AreAnyRootWindowsRunning() {
	local P2RootWindow root;

	root = P2RootWindow(Master.BaseMenu);

    if (root != none)
		return root.IsMenuShowing();

	return false;
}

/** Returns whether or not the button at the given index of the Buttons array
 * is currently highlighted by the mouse, given it's draw position. The reason
 * we require a Draw position is because sometimes we ignore some screen space
 * to support widescreen, and sometimes we don't, depends on the situation
 * @param Idx - Index of the button from Buttons you want to check
 * @param CanvasScale - Scaling of the canvas to determine the draw length
 * @param Pos - Screen coordinates, not percentage where the button is drawn
 * @return TRUE if the mouse is hovering over the button; FALSE otherwise
 */
function bool IsHighlightedButton(int Idx, float CanvasScale, vector Pos) {
    return (ViewportOwner.WindowsMouseX > Pos.X &&
            ViewportOwner.WindowsMouseY > Pos.Y &&
            ViewportOwner.WindowsMouseX < Pos.X + (ButtonTexture.USize * Buttons[Idx].Scale.X * CanvasScale) &&
            ViewportOwner.WindowsMouseY < Pos.Y + (ButtonTexture.VSize * Buttons[Idx].Scale.Y * CanvasScale));
}

/**
 * Interpolates with ease-in (smoothly approaches B). Copied from the UDK
 * @param A	- Value to interpolate from
 * @param B	- Value to interpolate to
 * @param Alpha - Interpolant
 * @param Exp - Higher values result in more rapid deceleration.
 * @return Interpolated value
 */
function float FInterpEaseIn(float A, float B, float Alpha, float Exp) {
	return Lerp(Alpha**Exp, A, B);
}

/**
 * Interpolates with ease-out (smoothly departs A). Copied from the UDK
 * @param A	- Value to interpolate from
 * @param B	- Value to interpolate to
 * @param Alpha	- Interpolant
 * @param Exp - Higher values result in more rapid acceleration
 * @return - Interpolated value
 */
function float FInterpEaseOut(float A, float B, float Alpha, float Exp) {
	return Lerp(Alpha**(1/Exp), A, B);
}

/** Returns the X screen percentage representing the left boundry,
 * used for widescreen rendering where we exclude the extra X space
 * @param Canvas - Canvas object we're gonna fetch the left boundry
 * @return Screen percentage from 0.0f to 1.0f for the X axis
 */
function float GetLeftBound(Canvas Canvas) {
    local float StandardWidth, ScreenRemainder;

    StandardWidth = (4.0f / 3.0f) * Canvas.ClipY;
    ScreenRemainder = (Canvas.ClipX - StandardWidth) / 2;

    return ScreenRemainder / Canvas.ClipX;
}

/** Returns the X screen percentage representing the right boundry,
 * used for widescreen rendering where we exclude the extra X space
 * @param Canvas - Canvas object we're gonna fetch the right boundry
 * @return Screen percentage from 0.0f to 1.0f for the X axis
 */
function float GetRightBound(Canvas Canvas) {
    return 1.0f - GetLeftBound(Canvas);
}

/** Copied and pasted from P2Screen, returns an Actor object to play a sound
 * @return Actor object to use to play a sound
 */
function Actor GetSoundActor() {
	local P2Player p2p;

	p2p = P2Player(ViewportOwner.Actor);

	if (p2p != none && p2p.MyPawn != none)
		return p2p.MyPawn;
	else
	    return ViewportOwner.Actor;
}

/** Copied and pasted from P2Screen, returns GameInfo for the current level
 * @return Global GameInfo object
 */
function P2GameInfoSingle GetGameSingle() {
	return P2GameInfoSingle(ViewportOwner.Actor.Level.Game);
}

/** Sets the given Canvas object's font scale
 * @param Canvas - Canvas object to set the font scale for
 * @param FontScale - X and Y scales
 */
function SetCanvasFontScale(Canvas Canvas, vector FontScale) {
    local float CanvasScale;
	local vector V;

	// Don't use Canvas in case we're doing this inside
	// a clipping region.
	GetP2EUtils().GetClientResolution(PlayerOwner, V);
	CanvasScale = V.Y / 1024.0f;
//    CanvasScale = Canvas.ClipY / 1024.0f;
    Canvas.FontScaleX = FontScale.X * CanvasScale;
    Canvas.FontScaleY = FontScale.Y * CanvasScale;
}

/** Resets the given Canvas object's font scale
 * @param Canvas - Canvas object to reset the font scale of
 */
function ResetCanvasFontScale(Canvas Canvas) {
    Canvas.FontScaleX = 1.0f;
    Canvas.FontScaleY = 1.0f;
}

/** Called whenever the player left clicks on a menu. Should be subclassed */
function LeftClick() {
    // STUB
}

/** Called whenever the player left clicks on a menu. Should be subclassed */
function RightClick() {
    // STUB
}

/** Overriden to implement menu functionality */
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta) {
    if (Key == IK_LeftMouse && Action == IST_Release)
        LeftClick();

    if (Key == IK_RightMouse && Action == IST_Release)
        RightClick();

	HandleJoystick(Key, Action, Delta);

    return true;
}

/** Simple method that pauses the game */
function PauseGame() {
    ViewportOwner.bShowWindowsMouse = true;
    ViewportOwner.bSuspendPrecaching = true;

    if (ViewportOwner.Actor != none && ViewportOwner.Actor.myHUD != none)
        ViewportOwner.Actor.myHUD.PausedMessage = "";

    if (ViewportOwner.Actor.Level.NetMode == NM_Standalone)
        ViewportOwner.Actor.SetPause(true);
}

/** Simple method that unpauses the game and resumes */
function ResumeGame() {
    ViewportOwner.bShowWindowsMouse = false;
    ViewportOwner.bSuspendPrecaching = false;

    if (ViewportOwner.Actor != none && ViewportOwner.Actor.myHUD != none)
        ViewportOwner.Actor.myHUD.PausedMessage =
        ViewportOwner.Actor.myHUD.default.PausedMessage;

    if (ViewportOwner.Actor.Level.NetMode == NM_Standalone)
        ViewportOwner.Actor.SetPause(false);
}

/** Plays the given song if there is one
 * @param SongName - String of the file name in your Music folder eg. "map_muzak.ogg"
 * @param FadeInTime - Time in seconds for the song to fully fade in
 */
function PlaySong(string SongName, optional float FadeInTime, optional float Volume) {
    if (SongName != "")
	{
        SongHandle = GetGameSingle().PlayMusicExt(SongName, FadeInTime, Volume);
		//SongHandle = GetGameSingle().PlayMusicAttenuateExt(ViewportOwner.Actor, SongName, FadeInTime, Volume, 99999);
	}
}

/** Stops the current song playing if there is one
 * @param FadeOutTime - Time in seconds for the song to fade out
 */
function StopSong(optional float FadeOutTime) {
    if (SongHandle != 0) {
        GetGameSingle().StopMusicExt(SongHandle, FadeOutTime);
        SongHandle = 0;
    }
}

/** Given a texture, x, y, and canvas scale, this will draw the texture on screen
 * @param Canvas - Canvas object to draw to
 * @param Tex - Texture to draw on the Canvas
 * @param Scale - Two dimensional vector containing the x and y scale
 * @param CanvasScale - Scale of the Canvas based off the Y scale
 */
function DrawTexture(Canvas Canvas, Texture Tex, vector Scale, float CanvasScale) {
    if (Tex != none)
        Canvas.DrawTile(Tex, Tex.USize*Scale.X*CanvasScale,
                        Tex.VSize*Scale.Y*CanvasScale, 0, 0, Tex.USize,
                        Tex.VSize);
}

// Steven: Added clipped version of DrawTexture(). Takes same arguments as the latter.
function DrawTextureClipped(Canvas Canvas, Texture Tex, vector Scale, float CanvasScale) {
    if (Tex != none)
        Canvas.DrawTileClipped(Tex, Tex.USize*Scale.X*CanvasScale,
                        Tex.VSize*Scale.Y*CanvasScale, 0, 0, Tex.USize,
                        Tex.VSize);
}

// Steven: New notify functions.
event NotifyLevelChanged(string OldL, string NewL);
event NotifyResolutionChanged(vector OldRes, vector NewRes);

// IMPORTANT: All classes overriding this function MUST call Super!!!
event Initialized()
{
	Super.Initialized();

	// Create P2EUtils reference.
	_P2EUtils = new(None) class'P2EUtils';

	PlayerOwner = P2Player(ViewportOwner.Actor);
}

// Steven: Added Tick() to detect level changes.
event Tick(float Delta)
{
	local string S;
	local vector NewRes;

	Super.Tick(Delta);

	PlayerOwner = P2Player(ViewportOwner.Actor);

	if(PlayerOwner == None)
		return;

	S = GetP2EUtils().GetCurrentMapFilename(PlayerOwner);

	if(CurrentURL == "")
		CurrentURL = S;

	else if(CurrentURL != S)
	{
		NotifyLevelChanged(CurrentURL, S);
		CurrentURL = S;

		if(bAutoRemoveAfterLevelChange)
			Master.RemoveInteraction(self);
	}

	// Detect resolution changes.
	GetP2EUtils().GetClientResolution(PlayerOwner, NewRes);

	if(NewRes != CurrentResolution)
	{
		NotifyResolutionChanged(CurrentResolution, NewRes);
		CurrentResolution = NewRes;
	}
}

// Kamek - controller support
function bool HandleJoystick(out EInputKey Key, out EInputAction Action, FLOAT Delta)
{
	local string KeyName, KeyBind;
	local int i;
	local UWindowRootWindow Root;
	
	Root = UWindowRootWindow(Master.BaseMenu);
	
	if (Action == IST_Axis && (Key == IK_JoyX || Key == IK_JoyY))
		class'JoyMouseInteraction'.static.StaticMoveMouse(Root.ViewportOwner.Actor, Key, Action, Delta);
	
	// Turn joystick buttons into menu events
	if (Action == IST_Press)
	{
		// ask input what this button means
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_BUTTON) == "1")
			execMenuButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@CONFIRM_BUTTON) == "1")
			execConfirmButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@BACK_BUTTON) == "1")
			execBackButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
			execMenuUpButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
			execMenuDownButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_LEFT_BUTTON) == "1")
			execMenuLeftButton();
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_RIGHT_BUTTON) == "1")
			execMenuRightButton();		
	}
	return false;
}

// Kamek - get FontInfo, for drawing button icons on screen.
function FontInfo GetFontInfo()
{
	if (PlayerOwner != None
		&& PlayerOwner.MyHud != None
		&& FPSHud(PlayerOwner.MyHud) != None
		&& FPSHud(PlayerOwner.MyHud).MyFont != None)
		return FPSHud(PlayerOwner.MyHud).MyFont;
}

// Defined in child classes
function execMenuButton();
function execConfirmButton();
function execBackButton();
function execMenuUpButton();
function execMenuDownButton();
function execMenuLeftButton();
function execMenuRightButton();

defaultproperties
{
    CursorTexture=texture'UWindow.Icons.MouseCursor'
    CursorDrawScale=(X=1.0f,Y=1.0f)

    bActive=true
    bVisible=true
    bRequiresTick=true
}
