//=============================================================================
// UWindowWindow - the parent class for all Window objects
//=============================================================================
class UWindowWindow extends UWindowBase;

#exec TEXTURE IMPORT NAME=BlackTexture FILE=TEXTURES\Black.PCX
#exec TEXTURE IMPORT NAME=WhiteTexture FILE=TEXTURES\White.PCX

// Dimensions, offset relative to parent.
var float				WinLeft;
var float				WinTop;
var float				WinWidth;
var float				WinHeight;

// RWS CHANGE: Added saved values so we could do fun special effects
var float				SavedWinLeft;
var float				SavedWinTop;

// Relationships to other windows
var UWindowWindow		ParentWindow;			// Parent window
var UWindowWindow		FirstChildWindow;		// First child window - bottom window first
var UWindowWindow		LastChildWindow;		// Last child window - WinTop window first
var UWindowWindow		NextSiblingWindow;		// sibling window - next window above us
var UWindowWindow		PrevSiblingWindow;		// previous sibling window - next window below us
var UWindowWindow		ActiveWindow;			// The child of ours which is currently active
var UWindowRootWindow	Root;					// The root window
var UWindowWindow		OwnerWindow;			// Some arbitary owner window
var UWindowWindow		ModalWindow;			// Some window we've opened modally.

var bool				bWindowVisible;
var bool				bNoClip;				// Clipping disabled for this window?
var bool				bMouseDown;				// Pressed down in this window?
var bool				bRMouseDown;			// Pressed down in this window?
var bool				bMMouseDown;			// Pressed down in this window?
var bool				bAlwaysBehind;			// Window doesn't bring to front on click.
var bool				bAcceptsFocus;			// Accepts key messages
var bool				bAlwaysOnTop;			// Always on top
var bool				bLeaveOnscreen;			// Window is left onscreen when UWindow isn't active.
var bool				bUWindowActive;			// Is UWindow active?
var bool				bTransient;				// Never the active window. Used for combo dropdowns7
var bool				bAcceptsHotKeys;		// Does this window accept hotkeys?
var bool				bIgnoreLDoubleClick;
var bool				bIgnoreMDoubleClick;
var bool				bIgnoreRDoubleClick;

var float				ClickTime;
var float				MClickTime;
var float				RClickTime;
var float				ClickX;
var float				ClickY;
var float				MClickX;
var float				MClickY;
var float				RClickX;
var float				RClickY;

var UWindowLookAndFeel	LookAndFeel;

var Region	ClippingRegion;

// For repeating functionality on menu keys
var float				MenuRepeatStart;		// Time we started to hold down the button
var float				MenuRepeatLast;			// Last time we sent a repeat menu command
var globalconfig float	MenuRepeatTime;			// How long we have to hold down the button to start repeating
var globalconfig float	MenuRepeatDelay;		// How long to wait between repeats
var EInputKey			JoyRepeatKey;
var float				JoyRepeatStart;
var float				JoyRepeatLast;
var globalconfig float	JoyRepeatTime;
var globalconfig float	JoyRepeatDelay;

//var array<String> SavedMacros;

struct MouseCursor
{
	var Texture tex;
	var int HotX;
	var int HotY;
	var byte WindowsCursor;
};

var MouseCursor Cursor;

enum WinMessage
{
	WM_LMouseDown,
	WM_LMouseUp,
	WM_MMouseDown,
	WM_MMouseUp,
	WM_RMouseDown,
	WM_RMouseUp,
	WM_KeyUp,
	WM_KeyDown,
	WM_KeyType,
	WM_Paint	// Window needs painting
};

// Dialog messages
const DE_Created = 0;
const DE_Change	 = 1;
const DE_Click	 = 2;
const DE_Enter	 = 3;
const DE_Exit	 = 4;
const DE_MClick	 = 5;
const DE_RClick	 = 6;
const DE_EnterPressed = 7;
const DE_MouseMove = 8;
const DE_MouseLeave = 9;
const DE_LMouseDown = 10;
const DE_DoubleClick = 11;
const DE_MouseEnter = 12;
const DE_HelpChanged = 13;
const DE_WheelUpPressed = 14;
const DE_WheelDownPressed = 15;

const MENU_BUTTON = "MenuButton";
const CONFIRM_BUTTON = "ConfirmButton";
const BACK_BUTTON = "BackButton";
const MENU_UP_BUTTON = "MenuUpButton";
const MENU_DOWN_BUTTON = "MenuDownButton";
const MENU_LEFT_BUTTON = "MenuLeftButton";
const MENU_RIGHT_BUTTON = "MenuRightButton";

// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg)
	{
	case WM_Paint:
		Paint(C, X, Y);
		PaintClients(C, X, Y);
		break;
	case WM_LMouseDown:
		if(!Root.CheckCaptureMouseDown())
		{
			if(!MessageClients(Msg, C, X, Y, Key)) 
				LMouseDown(X, Y);
		}
		break;	
	case WM_LMouseUp:
		if(!Root.CheckCaptureMouseUp())
		{
			if(!MessageClients(Msg, C, X, Y, Key))
				LMouseUp(X, Y);
		}
		break;	
	case WM_RMouseDown:
		if(!MessageClients(Msg, C, X, Y, Key)) RMouseDown(X, Y);
		break;	
	case WM_RMouseUp:
		if(!MessageClients(Msg, C, X, Y, Key)) RMouseUp(X, Y);
		break;	
	case WM_MMouseDown:
		if(!MessageClients(Msg, C, X, Y, Key)) MMouseDown(X, Y);
		break;	
	case WM_MMouseUp:
		if(!MessageClients(Msg, C, X, Y, Key)) MMouseUp(X, Y);
		break;	
	case WM_KeyDown:
		if(!PropagateKey(Msg, C, X, Y, Key))
		{
			KeyDown(Key, X, Y);
		}
		break;	
	case WM_KeyUp:
		if(!PropagateKey(Msg, C, X, Y, Key))
		{
			KeyUp(Key, X, Y);
		}
		break;	
	case WM_KeyType:
		if(!PropagateKey(Msg, C, X, Y, Key))
			KeyPressed(Key, X, Y);
		break;	
	default:
		break;
	}
}

function SaveConfigs()
{

	// Implemented in a child class
}

final function PlayerController GetPlayerOwner()
{
	return Root.ViewportOwner.Actor;
}

final function LevelInfo GetLevel()
{
	return Root.ViewportOwner.Actor.Level;
}

final function LevelInfo GetEntryLevel()
{
	return Root.ViewportOwner.Actor.GetEntryLevel();
}

function Actor GetSoundActor()
	{
	local PlayerController player;

	// Always try to play sound via the player's pawn.  If there is no pawn then
	// use the controller, although that will not sound good if the controller
	// istn' near the viewport.
	player = Root.ViewportOwner.Actor;
	if (player != None && player.Pawn != None)
		return player.Pawn;
	return player;
	}

function Resized()
{
	// Implemented in a child class
}

function BeforePaint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function AfterPaint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function Paint(Canvas C, float X, float Y)
{
	// Implemented in a child class
}

function Click(float X, float Y)
{
	// Implemented in a child class
}


function MClick(float X, float Y)
{
	// Implemented in a child class
}

function RClick(float X, float Y)
{
	// Implemented in a child class
}

function DoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function MDoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function RDoubleClick(float X, float Y)
{
	// Implemented in a child class
}

function BeginPlay()
{
	// Implemented in a child class
}

function BeforeCreate()
{
	// Implemented in a child class
}

function Created()
{
	// Implemented in a child class
}

function AfterCreate()
{
	// Implemented in a child class
}

function MouseEnter()
{
	// Implemented in a child class
}

function Activated()
{
	// Implemented in a child class
}

function Deactivated()
{
	// Implemented in a child class
}

function MouseLeave()
{
	bMouseDown = False;
	bMMouseDown = False;
	bRMouseDown = False;
}

function MouseMove(float X, float Y)
{
}

function KeyUp(int Key, float X, float Y)
{
	// Implemented in child class
}

function KeyDown(int Key, float X, float Y)
{
	// Implemented in child class
}

function bool HotKeyDown(int Key, float X, float Y)
{
	// Implemented in child class
	//Log("UWindowWindow: Checking HotKeyDown for "$Self);
	return False;
}

function bool HotKeyUp(int Key, float X, float Y)
{
	// Implemented in child class
	//Log("UWindowWindow: Checking HotKeyUp for "$Self);
	return False;
}

function KeyPressed(int Key, float X, float Y)
{
	// Implemented in child class
}

function ProcessMenuKey(int Key, string KeyName)
{
	// Implemented in child class
}

function KeyFocusEnter()
{
	// Implemented in child class
}

function KeyFocusExit()
{
	// Implemented in child class
}


function RMouseDown(float X, float Y) 
{
	ActivateWindow(0, False);
	bRMouseDown = True;
}

function RMouseUp(float X, float Y) 
{
	if(bRMouseDown)
	{
		if(!bIgnoreRDoubleClick && Abs(X-RClickX) <= 1 && Abs(Y-RClickY) <= 1 && GetLevel().TimeSeconds < RClickTime + 0.600)
		{
			RDoubleClick(X, Y);
			RClickTime = 0;
		}
		else
		{
			RClickTime = GetLevel().TimeSeconds;
			RClickX = X;
			RClickY = Y;
			RClick(X, Y);
		}
	}
	bRMouseDown = False;

}

function MMouseDown(float X, float Y) 
{
	ActivateWindow(0, False);
	/* DEBUG
	HideWindow();
	*/
	bMMouseDown = True;
}

function MMouseUp(float X, float Y) 
{
	if(bMMouseDown)
	{
		if(!bIgnoreMDoubleClick && Abs(X-MClickX) <= 1 && (Y-MClickY)<=1 && GetLevel().TimeSeconds < MClickTime + 0.600)
		{
			MDoubleClick(X, Y);
			MClickTime = 0;
		}
		else
		{
			MClickTime = GetLevel().TimeSeconds;
			MClickX = X;
			MClickY = Y;
			MClick(X, Y);
		}
	}
	bMMouseDown = False;
}


function LMouseDown(float X, float Y)
{
	ActivateWindow(0, False);
	bMouseDown = True;
}

function LMouseUp(float X, float Y)
{
	if(bMouseDown)
	{
		if(!bIgnoreLDoubleClick && Abs(X-ClickX) <= 1 && (Y-ClickY) <= 1 && GetLevel().TimeSeconds < ClickTime + 0.600)
		{
			DoubleClick(X, Y);
			ClickTime = 0;
		}
		else
		{
			ClickTime = GetLevel().TimeSeconds;
			ClickX = X;
			ClickY = Y;
			Click(X, Y);
		}
	}
	bMouseDown = False;
}

function FocusWindow()
{
	if(Root.FocusedWindow != None && Root.FocusedWindow != Self)
		Root.FocusedWindow.FocusOtherWindow(Self);

	Root.FocusedWindow = Self;
}

function FocusOtherWindow(UWindowWindow W)
{
}

function EscClose()
{
	Close();
}

function Close(optional bool bByParent)
{
	local UWindowWindow Prev, Child;

	for(Child = LastChildWindow;Child != None;Child = Prev)
	{
		Prev = Child.PrevSiblingWindow;
		Child.Close(True);
	}
	SaveConfigs();
	if(!bByParent)
		HideWindow();
}

final function SetSize(float W, float H)
{
	if(WinWidth != W || WinHeight != H)
	{
		WinWidth = W;
		WinHeight = H;
		Resized();
	}
}

function Tick(float Delta)
{
	local EInputAction Action;
	
	if (JoyRepeatKey != IK_None)
	{
		if (JoyRepeatStart > 0)
			JoyRepeatStart -= Delta;
		else if (JoyRepeatLast > 0)
			JoyRepeatLast -= Delta;
		else
		{
			JoyRepeatDelay -= 0.01;
			if (JoyRepeatDelay < 0.05)
				JoyRepeatDelay = 0.05;
			JoyRepeatLast = JoyRepeatDelay;				
			Action = IST_Press;
			//log(self@"REPEATING JOYSTICK INPUT"@JoyRepeatKey@Action@Delta);
			HandleJoystick(JoyRepeatKey, Action, Delta);
		}
	}
}

final function DoTick(float Delta)
{
	local UWindowWindow Child;
	
	Tick(Delta);

	Child = FirstChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			Child.DoTick(Delta);
		}

		Child = Child.NextSiblingWindow;
	}	
}

// RWS CHANGE: Extended classes can override this
function BeforeChildPaint(Canvas C)
{
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
	C.SetDrawColor(255,255,255);
}

final function PaintClients(Canvas C, float X, float Y)
{
	local float   OrgX, OrgY;   
	local float   ClipX, ClipY; 
	local UWindowWindow Child;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	Child = FirstChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		BeforeChildPaint(C);
		C.SetPos(0,0);
		C.SpaceX = 0;
		C.SpaceY = 0;

		Child.BeforePaint(C, X - Child.WinLeft, Y - Child.WinTop);

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{

			C.OrgX = C.OrgX + Child.WinLeft*Root.GUIScale;
			C.OrgY = C.OrgY + Child.WinTop*Root.GUIScale;

			if(!Child.bNoClip)
			{
				C.ClipX = FMin(WinWidth - Child.WinLeft, Child.WinWidth)*Root.GUIScale;
				C.ClipY = FMin(WinHeight - Child.WinTop, Child.WinHeight)*Root.GUIScale;


				// Translate to child's co-ordinate system
				Child.ClippingRegion.X = ClippingRegion.X - Child.WinLeft;
				Child.ClippingRegion.Y = ClippingRegion.Y - Child.WinTop;
				Child.ClippingRegion.W = ClippingRegion.W;
				Child.ClippingRegion.H = ClippingRegion.H;

				if(Child.ClippingRegion.X < 0)
				{
					Child.ClippingRegion.W += Child.ClippingRegion.X;
					Child.ClippingRegion.X = 0;
				}

				if(Child.ClippingRegion.Y < 0)
				{
					Child.ClippingRegion.H += Child.ClippingRegion.Y;
					Child.ClippingRegion.Y = 0;
				}

				if(Child.ClippingRegion.W > Child.WinWidth - Child.ClippingRegion.X)
				{
					Child.ClippingRegion.W = Child.WinWidth - Child.ClippingRegion.X;
				}

				if(Child.ClippingRegion.H > Child.WinHeight - Child.ClippingRegion.Y)
				{
					Child.ClippingRegion.H = Child.WinHeight - Child.ClippingRegion.Y;
				}
			}

			if(Child.ClippingRegion.W > 0 && Child.ClippingRegion.H > 0) 
			{		
				Child.WindowEvent(WM_Paint, C, X - Child.WinLeft, Y - Child.WinTop, 0);
				Child.AfterPaint(C, X - Child.WinLeft, Y - Child.WinTop);
			}
	
			C.OrgX = OrgX;
			C.OrgY = OrgY;
		}

		Child = Child.NextSiblingWindow;
	}

	C.ClipX = ClipX;
	C.ClipY = ClipY;
}

final function UWindowWindow FindWindowUnder(float X, float Y)
{
	local UWindowWindow Child;

	// go from Topmost downwards
	Child = LastChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		// RWS CHANGE: 01/26/03 JMI Observe modality.
		if ( (bUWindowActive || Child.bLeaveOnscreen) && (WaitModal() == false || Child == ModalWindow) )
		{
			if((X >= Child.WinLeft) && (X <= Child.WinLeft+Child.WinWidth) &&
			   (Y >= Child.WinTop) && (Y <= Child.WinTop+Child.WinHeight) &&
			   (!Child.CheckMousePassThrough(X-Child.WinLeft, Y-Child.WinTop)))
			{
				return Child.FindWindowUnder(X - Child.WinLeft, Y - Child.WinTop);
			}
		}
	
		Child = Child.PrevSiblingWindow;
	}

	// Doesn't correspond to any children - it's us.
	return Self;
}

final function bool PropagateKey(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// Check from WinTopmost for windows which accept focus
	Child = LastChildWindow;

	// HACK for always on top windows...need a better solution
	if(ActiveWindow != None && Child != ActiveWindow && !Child.bTransient)
		Child = ActiveWindow;
	
	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if((bUWindowActive || Child.bLeaveOnscreen) && Child.bAcceptsFocus)
		{
//			Log("Sending keystrokes from: "$self$" to:  "$Child$" in state "$Child.GetStateName()$" from state "$GetStateName());
			Child.WindowEvent(Msg, C, X - Child.WinLeft, Y - Child.WinTop, Key);
//			log("Returned from "$Child);
			return True;		
		}
		//else
			//Log("Ignoring child:  "$Child);
		Child = Child.PrevSiblingWindow;
	}
	return False;
}

final function bool PropagateMessage( coerce string Msg, float MsgLife)
{
	local UWindowWindow Child;

	Child = LastChildWindow;

	if(ActiveWindow != None && Child != ActiveWindow && !Child.bTransient)
		Child = ActiveWindow;
	
	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if((bUWindowActive || Child.bLeaveOnscreen) && Child.bAcceptsFocus)
		{
			Child.Message(Msg,MsgLife);		
			Child.PropagateMessage(Msg, MsgLife);
			return True;		
		}
		Child = Child.PrevSiblingWindow;
	}

	return False;
}


final function UWindowWindow CheckKeyFocusWindow()
{
	local UWindowWindow Child;

	// Check from WinTopmost for windows which accept key focus
	Child = LastChildWindow;

	if(ActiveWindow != None && Child != ActiveWindow && !Child.bTransient)
		Child = ActiveWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		if(bUWindowActive || Child.bLeaveOnscreen)
		{
			if(Child.bAcceptsFocus)
			{
				return Child.CheckKeyFocusWindow();
			}
		}
		Child = Child.PrevSiblingWindow;
	}

	return Self;
}

final function bool MessageClients(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	local UWindowWindow Child;

	// go from topmost downwards
	Child = LastChildWindow;

	while(Child != None)
	{
		Child.bUWindowActive = bUWindowActive;

		if(bLeaveOnScreen)
			Child.bLeaveOnscreen = True;

		// RWS CHANGE: 01/26/03 JMI Observe modality.
		if ((bUWindowActive || Child.bLeaveOnscreen) && (WaitModal() == false || Child == ModalWindow) )
		{
			if((X >= Child.WinLeft) && (X <= Child.WinLeft+Child.WinWidth) &&
			   (Y >= Child.WinTop) && (Y <= Child.WinTop+Child.WinHeight)  &&
			   (!Child.CheckMousePassThrough(X-Child.WinLeft, Y-Child.WinTop))) 
			{
				Child.WindowEvent(Msg, C, X - Child.WinLeft, Y - Child.WinTop, Key);
				return True;
			}
		}
	
		Child = Child.PrevSiblingWindow;
	}

	return False;
}

final function ActivateWindow(int Depth, bool bTransientNoDeactivate)
{
	if(Self == Root)
	{
		if(Depth == 0)
			FocusWindow();
		return;
	}

	if(WaitModal()) return;

	if(!bAlwaysBehind)
	{
		ParentWindow.HideChildWindow(Self);
		ParentWindow.ShowChildWindow(Self);
	}
	
	//Log("Activating Window "$Self);
	
	if(!(bTransient || bTransientNoDeactivate))
	{
		if(ParentWindow.ActiveWindow != None && ParentWindow.ActiveWindow != Self)
		{
			ParentWindow.ActiveWindow.Deactivated();
		}

		ParentWindow.ActiveWindow = Self;
		ParentWindow.ActivateWindow(Depth + 1, False);

		Activated();
	}
	else
	{
		ParentWindow.ActivateWindow(Depth + 1, True);
	}

	if(Depth == 0)
		FocusWindow();
}

final function BringToFront()
{
	if(Self == Root)
		return;

	if(!bAlwaysBehind && !WaitModal())
	{
		ParentWindow.HideChildWindow(Self);
		ParentWindow.ShowChildWindow(Self);
	}
	ParentWindow.BringToFront();
}

final function SendToBack()
{
	ParentWindow.HideChildWindow(Self);
	ParentWindow.ShowChildWindow(Self, True);
}

final function HideChildWindow(UWindowWindow Child)
{
	local UWindowWindow Window;

	if(!Child.bWindowVisible) return;
	Child.bWindowVisible = False;

	if(Child.bAcceptsHotKeys)
		Root.RemoveHotkeyWindow(Child);

	// Check WinTopmost
	if(LastChildWindow == Child) 
	{
		LastChildWindow = Child.PrevSiblingWindow;
		if(LastChildWindow != None)
		{
			LastChildWindow.NextSiblingWindow = None;
		}
		else
		{
			FirstChildWindow = None;
		}
	} 
	else if(FirstChildWindow == Child) // Check bottommost
	{ 
		FirstChildWindow = Child.NextSiblingWindow;
		if(FirstChildWindow != None)
		{
			FirstChildWindow.PrevSiblingWindow = None;
		}
		else
		{
			LastChildWindow = None;
		}
	} 
	else 
	{
		// you mean I have to go looking for it???
		Window = FirstChildWindow;
		while(Window != None)
		{
			if(Window.NextSiblingWindow == Child)
			{
				Window.NextSiblingWindow = Child.NextSiblingWindow;
				Window.NextSiblingWindow.PrevSiblingWindow = Window;
				break;
			}
			Window = Window.NextSiblingWindow;
		}
	}

	// Set the active window
	ActiveWindow = None;
	Window = LastChildWindow;
	while(Window != None)
	{
		if(!Window.bAlwaysOnTop)
		{
			ActiveWindow = Window;
			break;
		}
		Window = Window.PrevSiblingWindow;
	}
	if(ActiveWindow == None) ActiveWindow = LastChildWindow;
}

final function SetAcceptsFocus()
{
	if(bAcceptsFocus) return;
	bAcceptsFocus = True;

	if(Self != Root)
		ParentWindow.SetAcceptsFocus();
}

final function CancelAcceptsFocus()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow; Child != None; Child = Child.PrevSiblingWindow)
		Child.CancelAcceptsFocus();

	bAcceptsFocus = False;
}

final function GetMouseXY(out float X, out float Y)
{
	local UWindowWindow P;

	X = Int(Root.MouseX);
	Y = Int(Root.MouseY);
	
	P = Self;
	while(P != Root)
	{		
		X = X - P.WinLeft;
		Y = Y - P.WinTop;
		P = P.ParentWindow;
	}
}

final function GlobalToWindow(float GlobalX, float GlobalY, out float WinX, out float WinY)
{
	local UWindowWindow P;

	WinX = GlobalX;
	WinY = GlobalY;

	P = Self;
	while(P != Root)
	{		
		WinX -= P.WinLeft;
		WinY -= P.WinTop;
		P = P.ParentWindow;
	}
}

final function WindowToGlobal(float WinX, float WinY, out float GlobalX, out float GlobalY)
{
	local UWindowWindow P;

	GlobalX = WinX;
	GlobalY = WinY;

	P = Self;
	while(P != Root)
	{		
		GlobalX += P.WinLeft;
		GlobalY += P.WinTop;
		P = P.ParentWindow;
	}
}

final function ShowChildWindow(UWindowWindow Child, optional bool bAtBack)
{
	local UWindowWindow W;
	
	if(!Child.bTransient) ActiveWindow = Child;

	if(Child.bWindowVisible) return;
	Child.bWindowVisible = True;

	if(Child.bAcceptsHotKeys)
		Root.AddHotkeyWindow(Child);

	if(bAtBack)
	{
		if(FirstChildWindow == None)
		{
			Child.NextSiblingWindow = None;
			Child.PrevSiblingWindow = None;
			LastChildWindow = Child;
			FirstChildWindow = Child;
		}
		else
		{
			FirstChildWindow.PrevSiblingWindow = Child;
			Child.NextSiblingWindow = FirstChildWindow;
			Child.PrevSiblingWindow = None;
			FirstChildWindow = Child;
		}
	}
	else
	{
		W = LastChildWindow;
		while(True) 
		{
			if((Child.bAlwaysOnTop) || (W == None) || (!W.bAlwaysOnTop))
			{
				if(W == None)
				{	
					if(LastChildWindow == None)
					{
						// We're the only window
						Child.NextSiblingWindow = None;
						Child.PrevSiblingWindow = None;
						LastChildWindow = Child;
						FirstChildWindow = Child;
					}
					else
					{
						// We feel off the end of the list, we're the bottom (first) child window.
						Child.NextSiblingWindow = FirstChildWindow;
						Child.PrevSiblingWindow = None;
						FirstChildWindow.PrevSiblingWindow = Child;
						FirstChildWindow = Child;
					}
				}
				else
				{
					// We're either the new topmost (last) or we need to be inserted in the list.

					Child.NextSiblingWindow = W.NextSiblingWindow;
					Child.PrevSiblingWindow = W;
					if(W.NextSiblingWindow != None)
					{
						W.NextSiblingWindow.PrevSiblingWindow = Child;
					}
					else
					{
						LastChildWindow = Child;
					}
					W.NextSiblingWindow = Child;
				}
				
				// We're done.
				break;
			}
			
			W = W.PrevSiblingWindow;
		}
	}
}

function ShowWindow()
{
	ParentWindow.ShowChildWindow(Self);
	WindowShown();
}

function HideWindow()
{
	WindowHidden();
	ParentWindow.HideChildWindow(Self);
}

final function UWindowWindow CreateWindow(class<UWindowWindow> WndClass, float X, float Y, float W, float H, optional UWindowWindow OwnerW, optional bool bUnique, optional name ObjectName)
{
	local UWindowWindow Child;

	if(bUnique)
	{
		Child = Root.FindChildWindow(WndClass, True);

		if(Child != None)
		{
			Child.ShowWindow();
			Child.BringToFront();
			return Child;
		}
	}

	if(ObjectName != '')
		Child = New(None, string(ObjectName)) WndClass;
	else
		Child = New(None) WndClass;

		
	Child.BeginPlay();
	Child.WinTop = Y;
	Child.WinLeft = X;
	Child.WinWidth = W;
	Child.WinHeight = H;
	Child.Root = Root;
	Child.ParentWindow = Self;
	Child.OwnerWindow = OwnerW;
	if(Child.OwnerWindow == None)
		Child.OwnerWindow = Self;
		
	Child.Cursor = Cursor;
	Child.bAlwaysBehind = False;
	Child.LookAndFeel = LookAndFeel;
	Child.BeforeCreate();
	Child.Created();

	
	
	// Now add it at the WinTop of the Z-Order and then adjust child list.
	ShowChildWindow(Child);

	Child.AfterCreate();

	return Child;
}

final function Tile(Canvas C, Texture T)
{
	local int X, Y;

	X = 0;
	Y = 0;

	While(X < WinWidth)
	{
		While(Y < WinHeight)
		{
			DrawClippedTexture( C, X, Y, T );
			Y += T.VSize;
		}
		X += T.USize;
		Y = 0;
	}
}

final function DrawHorizTiledPieces( Canvas C, float DestX, float DestY, float DestW, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float Scale )
{
	local TexRegion Pieces[5], R;
	local int PieceCount;
	local int j;
	local float X, L;

	Pieces[0] = T1; if(T1.T != None) PieceCount = 1;
	Pieces[1] = T2; if(T2.T != None) PieceCount = 2;
	Pieces[2] = T3; if(T3.T != None) PieceCount = 3;
	Pieces[3] = T4; if(T4.T != None) PieceCount = 4;
	Pieces[4] = T5; if(T5.T != None) PieceCount = 5;

	j = 0;
	X = DestX;
	while( X < DestX + DestW )
	{
		L = DestW - (X - DestX);
		R = Pieces[j];
		DrawStretchedTextureSegment( C, X, DestY, FMin(R.W*Scale, L), R.H*Scale, R.X, R.Y, FMin(R.W, L/Scale), R.H, R.T );
		X += FMin(R.W*Scale, L);
		j = (j+1)%PieceCount;
	}
}

final function DrawVertTiledPieces( Canvas C, float DestX, float DestY, float DestW, float DestH, TexRegion T1, TexRegion T2, TexRegion T3, TexRegion T4, TexRegion T5, float Scale )
{
	local TexRegion Pieces[5], R;
	local int PieceCount;
	local int j;
	local float Y, L;

	Pieces[0] = T1; if(T1.T != None) PieceCount = 1;
	Pieces[1] = T2; if(T2.T != None) PieceCount = 2;
	Pieces[2] = T3; if(T3.T != None) PieceCount = 3;
	Pieces[3] = T4; if(T4.T != None) PieceCount = 4;
	Pieces[4] = T5; if(T5.T != None) PieceCount = 5;

	j = 0;
	Y = DestY;
	while( Y < DestY + DestH )
	{
		L = DestH - (Y - DestY);
		R = Pieces[j];
		DrawStretchedTextureSegment( C, DestX, Y, R.W*Scale, FMin(R.H*Scale, L), R.X, R.Y, R.W, FMin(R.H, L/Scale), R.T );
		Y += FMin(R.H*Scale, L);
		j = (j+1)%PieceCount;
	}
}


final function DrawClippedTexture( Canvas C, float X, float Y, texture Tex )
{
	DrawStretchedTextureSegment( C, X, Y, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, Tex);
}

final function DrawStretchedTexture( Canvas C, float X, float Y, float W, float H, texture Tex )
{
	DrawStretchedTextureSegment( C, X, Y, W, H, 0, 0, Tex.USize, Tex.VSize, Tex);
}

final function DrawStretchedTextureSegment( Canvas C, float X, float Y, float W, float H, 
									  float tX, float tY, float tW, float tH, texture Tex ) 
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin(OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y*Root.GUIScale);
	C.SetClip(ClippingRegion.W*Root.GUIScale, ClippingRegion.H*Root.GUIScale);

	C.SetPos((X - ClippingRegion.X)*Root.GUIScale, (Y - ClippingRegion.Y)*Root.GUIScale);

	C.DrawTileClipped( Tex, W*Root.GUIScale, H*Root.GUIScale, tX, tY, tW, tH);
	
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}

// Yanks any %KEY_ macros out of the string, replace with blank space for fit
final function string StripMacro(coerce string S)
{
	local string OutStr,LeftHalf,RightHalf,Macro,Key,TestKey;
	local int pos,pos2,iIter,numKeys,i;
	local bool bJoyUser;
	local Texture UseTex;
	local int Count;

	OutStr = S;
	
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
		//SavedMacros.Insert(0,1);
		//SavedMacros[0] = Macro;
		
		OutStr = LeftHalf $ "   " $ RightHalf;
		Count++;
	}
	
	//if (Count > 0)
		//log("STRIP MACRO: '"$S$"' --> '"$OutStr$"' (Macro count: "$SavedMacros.Length$")");
	
	return OutStr;
}
// Replaces %KEY_ macros back into the string
/*
final function string ReplaceMacro(coerce string S)
{
	local string OutStr,LeftHalf,RightHalf,Macro,Key,TestKey;
	local int pos,pos2,iIter,numKeys,i;
	local bool bJoyUser;
	local Texture UseTex;
	local int Count;

	OutStr = S;
	
	while (InStr(OutStr,"\%") > -1)
	{
		pos = InStr(OutStr,"\%");
		LeftHalf = Left(OutStr, pos);
		// LeftHalf now contains everything up to but not including the macro		
		Macro = Right(OutStr, len(OutStr) - pos - 5);
		// Macro now contains everything after the first "%KEY_"
		pos2 = pos + 2;
		RightHalf = Right(Macro, len(Macro) - pos2 - 1);
		// RightHalf now contains everything after the macro end
		Macro = Left(Macro, pos2);
		// Macro now contains the alias we need to find
		Macro = SavedMacros[SavedMacros.Length - 1];		
		SavedMacros.Remove(SavedMacros.Length - 1, 1);
		
		OutStr = LeftHalf $ Macro $ RightHalf;
		Count++;
	}
	
	if (Count > 0)
		log("REPLACE MACRO: '"$S$"' --> '"$OutStr$"' (Macro count: "$SavedMacros.Length$")");

	return OutStr;
}
*/

final function ClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotkey)
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin(OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y*Root.GUIScale);
	C.SetClip(ClippingRegion.W*Root.GUIScale, ClippingRegion.H*Root.GUIScale);

	C.SetPos((X - ClippingRegion.X)*Root.GUIScale, (Y - ClippingRegion.Y)*Root.GUIScale);
	//C.DrawTextClipped(S, bCheckHotKey);

	// Change by NickP: MP fix
	//Root.ViewportOwner.Actor.MyHud.ClipText(C, S, bCheckHotkey);
	C.DrawTextClipped(Root.ViewportOwner.Actor.MyHud.GetButtonParsedText(C, S), bCheckHotkey);
	// End

	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}

final function int WrapClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotkey, optional int Length, optional int PaddingLength, optional bool bNoDraw)
{
	local float W, H;
	local int SpacePos, CRPos, WordPos, TotalPos;
	local string Out, Temp, Padding;
	local bool bCR, bSentry;
	local int i;
	local int NumLines;
	local float pW, pH;
	
	//S = StripMacro(S);

	// replace \\n's with Chr(13)'s
	i = InStr(S, "\\n");
	while(i != -1)
	{
		S = Left(S, i) $ Chr(13) $ Mid(S, i + 2);
		i = InStr(S, "\\n");
	}

	i = 0;
	bSentry = True;
	Out = "";
	NumLines = 1;
	while( bSentry && Y < WinHeight )
	{
		// Get the line to be drawn.
		if(Out == "")
		{
			i++;
			if (Length > 0)
				Out = Left(S, Length);
			else
				Out = S;
		}

		// Find the word boundary.
		SpacePos = InStr(Out, " ");
		CRPos = InStr(Out, Chr(13));
		
		bCR = False;
		if(CRPos != -1 && (CRPos < SpacePos || SpacePos == -1))
		{
			WordPos = CRPos;
			bCR = True;
		}
		else
		{
			WordPos = SpacePos;
		}
		
		// Get the current word.
		C.SetPos(0, 0);
		if(WordPos == -1)
			Temp = Out;
		else
			Temp = Left(Out, WordPos)$" ";
		TotalPos += WordPos;

		TextSize(C, Temp, W, H);

		// Calculate draw offset.
		if ( (Mid(Out, Len(Temp)) == "") && (PaddingLength > 0) )
		{
			Padding = Mid(S, Length, PaddingLength);
			TextSize(C, Padding, pW, pH);
			if(W + X + pW > WinWidth && X > 0)
			{
				X = 0;
				Y += H;
				NumLines++;
			}
		}
		else
		{
			if(W + X > WinWidth && X > 0)
			{
				X = 0;
				Y += H;
				NumLines++;
			}
		}

		// Draw the line.
		if(!bNoDraw)
			ClipText(C, X, Y, Temp, bCheckHotKey);

		// Increment the draw offset.
		X += W;
		if(bCR)
		{
			X =0;
			Y += H;
			NumLines++;
		}
		Out = Mid(Out, Len(Temp));
		if ((Out == "") && (i > 0))
			bSentry = False;
	}
	return NumLines;
}

// RWS CHANGE: 01/29/03 JMI Added centered clipped text drawing function.
final function int WrapCenterClipText(Canvas C, Region R, coerce string str, optional bool bCheckHotkey, optional bool bNoDraw)
{
	local float Y, W, H;
	local float fLineW;
	local int SpacePos, CRPos, WordPos;
	local string strLine, strWord;
	local bool bCR, bGotLine;
	local int i;
	local int iNumLines;
	
	//StripMacro(Str);

	// replace \\n's with Chr(13)'s
	i = InStr(str, "\\n");
	while(i != -1)
	{
		str = Left(str, i) $ Chr(13) $ Mid(str, i + 2);
		i = InStr(str, "\\n");
	}

	Y = 0;
	iNumLines = 0;
	while (str != "" && Y < R.H)
	{
		fLineW		= 0;
		bGotLine	= false;
		strLine		= "";
		iNumLines	= iNumLines + 1;
		// Get the line to be drawn.
		while (!bGotLine && str != "")
		{
			// Find the next word boundary.
			SpacePos = InStr(str, " ");
			CRPos = InStr(str, Chr(13) );

			// Determine which was first, space or CR or if there was neither.
			if (CRPos >= 0 && (CRPos < SpacePos || SpacePos < 0) )
			{
				WordPos = CRPos + 1;	// + 1 to get the CR.
				// Get the word.
				strWord = Left(str, CRPos);	// Don't include the CR in the word.
				bCR = True;
			}
			else if (SpacePos >= 0)
			{
				WordPos = SpacePos + 1;	// + 1 to get the space.
				// Get the word.
				strWord = Left(str, WordPos);
				bCR = False;
			}
			else
			{
				// If neither delimiter, use rest of string.
				WordPos = Len(str);
				// Get the word.
				strWord = str;
				bCR = False;
			}

			// See if it will fit.
			C.SetPos(0, 0);
			TextSize(C, strWord, W, H);
			// 02/11/03 JMI If the word has no height, it's probably a lone CR so fake the height.
			if (H == 0)
				TextSize(C, "CR", W, H);

			// Check if this word would put us over; however, if there's nothing yet on this
			// line, we should accept it (if we want to write something truly useful we would
			// then figure out the maximum portion of that word that would fit and divide it
			// there but that's an exercise left to the reader).
			if (fLineW + W > R.W && Len(strLine) > 0)
				// This word won't fit, what we already have constitutes a line.
				bGotLine = true;
			else
			{
				// Add it into our line.
				strLine = strLine $ strWord;
				// Subtract it from the main string.
				str = Mid(str, WordPos);
				// Accumulate the position.
				fLineW = fLineW + W;
				// // 02/11/03 JMI If this was a CR after this word, we're done with this line.
				bGotLine = bCR;
			}
		}

		// We have a line.  Center it and draw it.
		if (!bNoDraw)
			ClipText(C, R.X + (R.W - fLineW) / 2, R.Y + Y, strLine, bCheckHotKey);

		// Next line.
		Y += H;
	}

	return iNumLines;
}

final function ClipTextWidth(Canvas C, float X, float Y, coerce string S, float W)
{
	ClipText(C, X, Y, S);
}

final function DrawClippedActor( Canvas C, float X, float Y, Actor A, bool WireFrame, rotator RotOffset, vector LocOffset )
{
	local vector MeshLoc;
	local float FOV;

	FOV = GetPlayerOwner().FOVAngle * Pi / 180;
	
	MeshLoc.X = 4 / tan(FOV/2);
	MeshLoc.Y = 0;
	MeshLoc.Z = 0;

	A.SetRotation(RotOffset);
	A.SetLocation(MeshLoc + LocOffset);

	// C.DrawClippedActor(A, WireFrame, ClippingRegion.W * Root.GUIScale, ClippingRegion.H * Root.GUIScale, C.OrgX + ClippingRegion.X * Root.GUIScale, C.OrgY + ClippingRegion.Y * Root.GUIScale, True);
}

final function DrawUpBevel( Canvas C, float X, float Y, float W, float H, Texture T)
{
	local Region R;

	R = LookAndFeel.BevelUpTL;
	DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.BevelUpT;
	DrawStretchedTextureSegment( C, X+LookAndFeel.BevelUpTL.W, Y, 
									W - LookAndFeel.BevelUpTL.W
									- LookAndFeel.BevelUpTR.W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.BevelUpTR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );
	
	R = LookAndFeel.BevelUpL;
	DrawStretchedTextureSegment( C, X, Y + LookAndFeel.BevelUpTL.H,
									R.W,  
									H - LookAndFeel.BevelUpTL.H
									- LookAndFeel.BevelUpBL.H,
									R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.BevelUpR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y + LookAndFeel.BevelUpTL.H,
									R.W,  
									H - LookAndFeel.BevelUpTL.H
									- LookAndFeel.BevelUpBL.H,
									R.X, R.Y, R.W, R.H, T );

	
	R = LookAndFeel.BevelUpBL;
	DrawStretchedTextureSegment( C, X, Y + H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.BevelUpB;
	DrawStretchedTextureSegment( C, X + LookAndFeel.BevelUpBL.W, Y + H - R.H, 
									W - LookAndFeel.BevelUpBL.W
									- LookAndFeel.BevelUpBR.W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.BevelUpBR;
	DrawStretchedTextureSegment( C, X + W - R.W, Y + H - R.H, R.W, R.H, R.X, R.Y, 
									R.W, R.H, T );

	R = LookAndFeel.BevelUpArea;
	DrawStretchedTextureSegment( C, X + LookAndFeel.BevelUpTL.W,
	                                Y + LookAndFeel.BevelUpTL.H,
									W - LookAndFeel.BevelUpBL.W
									- LookAndFeel.BevelUpBR.W,
									H - LookAndFeel.BevelUpTL.H
									- LookAndFeel.BevelUpBL.H,
									R.X, R.Y, R.W, R.H, T );
	
}

final function DrawMiscBevel( Canvas C, float X, float Y, float W, float H, Texture T, int BevelType)
{
	local Region R;

	R = LookAndFeel.MiscBevelTL[BevelType];
	DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.MiscBevelT[BevelType];
	DrawStretchedTextureSegment( C, X+LookAndFeel.MiscBevelTL[BevelType].W, Y, 
									W - LookAndFeel.MiscBevelTL[BevelType].W
									- LookAndFeel.MiscBevelTR[BevelType].W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.MiscBevelTR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, T );
	
	R = LookAndFeel.MiscBevelL[BevelType];
	DrawStretchedTextureSegment( C, X, Y + LookAndFeel.MiscBevelTL[BevelType].H,
									R.W,  
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.MiscBevelR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y + LookAndFeel.MiscBevelTL[BevelType].H,
									R.W,  
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, T );

	
	R = LookAndFeel.MiscBevelBL[BevelType];
	DrawStretchedTextureSegment( C, X, Y + H - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.MiscBevelB[BevelType];
	DrawStretchedTextureSegment( C, X + LookAndFeel.MiscBevelBL[BevelType].W, Y + H - R.H, 
									W - LookAndFeel.MiscBevelBL[BevelType].W
									- LookAndFeel.MiscBevelBR[BevelType].W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = LookAndFeel.MiscBevelBR[BevelType];
	DrawStretchedTextureSegment( C, X + W - R.W, Y + H - R.H, R.W, R.H, R.X, R.Y, 
									R.W, R.H, T );

	R = LookAndFeel.MiscBevelArea[BevelType];
	DrawStretchedTextureSegment( C, X + LookAndFeel.MiscBevelTL[BevelType].W,
	                                Y + LookAndFeel.MiscBevelTL[BevelType].H,
									W - LookAndFeel.MiscBevelBL[BevelType].W
									- LookAndFeel.MiscBevelBR[BevelType].W,
									H - LookAndFeel.MiscBevelTL[BevelType].H
									- LookAndFeel.MiscBevelBL[BevelType].H,
									R.X, R.Y, R.W, R.H, T );
}

final function string RemoveAmpersand(string S)
{
	local string Result;
	local string Underline;

	ParseAmpersand(S, Result, Underline, False);

	return Result;
}

final function byte ParseAmpersand(string S, out string Result, out string Underline, bool bCalcUnderline)
{
	local string Temp;
	local int Pos, NewPos;
	local int i;
	local byte HotKey;
	
	HotKey = 0;
	Pos = 0;
	Result = "";
	Underline = "";

	while(True)
	{
		Temp = Mid(S, Pos);

		NewPos = InStr(Temp, "&");
		
		if(NewPos == -1) break;
		Pos += NewPos;

		if(Mid(Temp, NewPos + 1, 1) == "&")
		{
			// It's a double &, lets add one to the output.
			Result = Result $ Left(Temp, NewPos) $ "&";
			
			if(bCalcUnderline) 
				Underline = Underline $ " ";

			Pos++;
		}
		else
		{
			if(HotKey == 0)
				HotKey = Asc(Caps(Mid(Temp, NewPos + 1, 1)));

			Result = Result $ Left(Temp, NewPos);
			
			if(bCalcUnderline)
			{
				for(i=0;i<NewPos - 1;i++) 
					Underline = Underline $ " ";
				Underline = Underline $ "_";
			}
		}

		Pos++;
	}
	Result = Result $ Temp;

	return HotKey;
}

final function bool MouseIsOver()
{
	return (Root.MouseWindow == Self);
}

function ToolTip(string strTip) 
{
	if(ParentWindow != Root) ParentWindow.ToolTip(strTip);
}

// Sets mouse window for mouse capture.
final function SetMouseWindow()
{
	Root.MouseWindow = Self;
}

function Texture GetLookAndFeelTexture()
{
	return ParentWindow.GetLookAndFeelTexture();
}

function bool IsActive()
{
	return ParentWindow.IsActive();
}

function SetAcceptsHotKeys(bool bNewAccpetsHotKeys)
{
	if(bNewAccpetsHotKeys && !bAcceptsHotKeys && bWindowVisible)
		Root.AddHotkeyWindow(Self);
	
	if(!bNewAccpetsHotKeys && bAcceptsHotKeys && bWindowVisible)
		Root.RemoveHotkeyWindow(Self);

	bAcceptsHotKeys = bNewAccpetsHotKeys;
}

final function UWindowWindow GetParent(class<UWindowWindow> ParentClass, optional bool bExactClass)
{
	local UWindowWindow P;

	P = ParentWindow;
	while(P != Root)
	{
		if(bExactClass)
		{
			if(P.Class == ParentClass)
				return P;
		}
		else
		{
			if(ClassIsChildOf(P.Class, ParentClass))
				return P;
		}
		P = P.ParentWindow;
	}

	return None;
}

final function UWindowWindow FindChildWindow(class<UWindowWindow> ChildClass, optional bool bExactClass)
{
	local UWindowWindow Child, Found;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		if(bExactClass)
		{
			if(Child.Class == ChildClass) return Child;
		}
		else
		{
			if(ClassIsChildOf(Child.Class, ChildClass)) return Child;
		}

		Found = Child.FindChildWindow(ChildClass);
		if(Found != None) return Found;
	}

	return None;
}

function GetDesiredDimensions(out float W, out float H)
{
	local float MaxW, MaxH, TW, TH;
	local UWindowWindow Child;
	
	MaxW = 0;
	MaxH = 0;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		Child.GetDesiredDimensions(TW, TH);
		//Log("Calling: "$GetPlayerOwner().GetItemName(string(Child)));
		

		if(TW > MaxW) MaxW = TW;
		if(TH > MaxH) MaxH = TH;
	}
	W = MaxW;
	H = MaxH;
	//Log(GetPlayerOwner().GetItemName(string(Self))$": DesiredHeight: "$H);
}

final function TextSize(Canvas C, string Text, out float W, out float H)
{
	C.SetPos(0, 0);
	C.TextSize(Text, W, H);
	W = W / Root.GUIScale;
	H = H / Root.GUIScale;
}

function ResolutionChanged(float W, float H)
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
	{
		Child.ResolutionChanged(W, H);
	}
}

function ShowModal(UWindowWindow W)
{
	ModalWindow = W;
	W.ShowWindow();
	W.BringToFront();		
}

function bool WaitModal()
{
	if(ModalWindow != None && ModalWindow.bWindowVisible)
		return True;

	ModalWindow = None;

	return False;
}

function WindowHidden()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.WindowHidden();
}

function WindowShown()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.WindowShown();
}

// Should mouse events at these co-ordinates be passed through to underlying windows?
function bool CheckMousePassThrough(float X, float Y)
{
	return False;
}

final function bool WindowIsVisible()
{
	if(Self == Root)
		return True;

	if(!bWindowVisible)
		return False;
	return ParentWindow.WindowIsVisible();
}

function SetParent(UWindowWindow NewParent)
{
	HideWindow();
	ParentWindow = NewParent;
	ShowWindow();
}

function UWindowMessageBox MessageBox(string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult ESCResult, optional MessageBoxResult EnterResult, optional int TimeOut)
{
	local UWindowMessageBox W;
	local UWindowFramedWindow F;
	
	W = UWindowMessageBox(Root.CreateWindow(class'UWindowMessageBox', 100, 100, 100, 100, Self));
	W.SetupMessageBox(Title, Message, Buttons, ESCResult, EnterResult, TimeOut);
	F = UWindowFramedWindow(GetParent(class'UWindowFramedWindow'));

	if(F!= None)
		F.ShowModal(W);
	else
		Root.ShowModal(W);

	return W;
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
}

function NotifyQuitUnreal()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyBeforeLevelChange();
}

function SetCursor(MouseCursor C)
{
	local UWindowWindow Child;

	Cursor = C;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.SetCursor(C);
}

function NotifyAfterLevelChange()
{
	local UWindowWindow Child;

	for(Child = LastChildWindow;Child != None;Child = Child.PrevSiblingWindow)
		Child.NotifyAfterLevelChange();
}

final function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;
		
	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{	
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

function StripCRLF(out string Text)
{
	ReplaceText(Text, Chr(13)$Chr(10), "");
	ReplaceText(Text, Chr(13), "");
	ReplaceText(Text, Chr(10), "");
}

function bool HandleJoystick(out EInputKey Key, out EInputAction Action, FLOAT Delta)
{
	local string KeyName, KeyBind;
	local int i;
	local bool bHoldMenuButton;
	local float HoldTime;
	local bool bShouldRepeat;
	
	if (Action == IST_Axis && (Key == IK_JoyX || Key == IK_JoyY))
		class'JoyMouseInteraction'.static.StaticMoveMouse(Root.ViewportOwner.Actor, Key, Action, Delta);
	else if (Key >= IK_Joy1 && Key <= IK_Joy16 && Action == IST_Press && JoyRepeatKey != Key)
	{
		bShouldRepeat = true;
	}
	
	// Turn joystick buttons into menu events
	if (Action == IST_Press)
	{
		// ask input what this button means
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_BUTTON) == "1")
		{
			Root.bUsingJoystick = true;
			execMenuButton();
		}
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@CONFIRM_BUTTON) == "1")
		{
			if (GetLevel().TimeSecondsAlways - Root.LastConfirmTime > 0.1)
			{
				Root.bUsingJoystick = true;
				Root.LastConfirmTime = GetLevel().TimeSecondsAlways;
				execConfirmButton();
			}
		}
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@BACK_BUTTON) == "1")
		{
			if (GetLevel().TimeSecondsAlways - Root.LastBackTime > 0.1)
			{
				Root.bUsingJoystick = true;
				Root.LastBackTime = GetLevel().TimeSecondsAlways;
				execBackButton();
			}
		}
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
		{
			Root.bUsingJoystick = true;
			execMenuUpButton();
			bHoldMenuButton = true;
		}		
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
		{
			Root.bUsingJoystick = true;
			execMenuDownButton();
			bHoldMenuButton = true;
		}
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_LEFT_BUTTON) == "1")
		{
			Root.bUsingJoystick = true;
			execMenuLeftButton();
			bHoldMenuButton = true;
		}
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_RIGHT_BUTTON) == "1")
		{
			Root.bUsingJoystick = true;
			execMenuRightButton();
			bHoldMenuButton = true;
		}
		
		if (bHoldMenuButton)
		{
			MenuRepeatStart = GetLevel().TimeSecondsAlways;
			JoyRepeatKey = Key;
			JoyRepeatStart = Default.JoyRepeatTime;
			JoyRepeatLast = Default.JoyRepeatDelay;
			JoyRepeatDelay = Default.JoyRepeatDelay;
		}
		
		/*
		KeyName = Root.GetPlayerOwner().ConsoleCommand("KEYNAME"@Key);
		KeyBind = "dummy";
		for (i = 0; KeyBind != ""; i++)
		{
			KeyBind = Root.GetPlayerOwner().ConsoleCommand("BINDING2KEYSTR"@MENU_BUTTON@i);
			if (KeyBind ~= KeyName)
				execMenuButton();
		}		
		KeyBind = "dummy";
		for (i = 0; KeyBind != ""; i++)
		{
			KeyBind = Root.GetPlayerOwner().ConsoleCommand("BINDING2KEYSTR"@CONFIRM_BUTTON@i);
			if (KeyBind ~= KeyName)
				execConfirmButton();
		}		
		KeyBind = "dummy";
		for (i = 0; KeyBind != ""; i++)
		{
			KeyBind = Root.GetPlayerOwner().ConsoleCommand("BINDING2KEYSTR"@BACK_BUTTON@i);
			if (KeyBind ~= KeyName)
				execBackButton();
		}		
		KeyBind = "dummy";
		for (i = 0; KeyBind != ""; i++)
		{
			KeyBind = Root.GetPlayerOwner().ConsoleCommand("BINDING2KEYSTR"@MENU_UP_BUTTON@i);
			if (KeyBind ~= KeyName)
				execMenuUpButton();
		}		
		KeyBind = "dummy";
		for (i = 0; KeyBind != ""; i++)
		{
			KeyBind = Root.GetPlayerOwner().ConsoleCommand("BINDING2KEYSTR"@MENU_DOWN_BUTTON@i);
			if (KeyBind ~= KeyName)
				execMenuDownButton();
		}		
		*/
		/*
		if (Key == IK_Joy6)	// Back button
		{
			// Goes back/closes menu.
			Key = IK_Escape;
			Action = IST_Release;
			log(self@"hitting escape");
			//return 
			KeyEvent(Key, Action, Delta);
		}
		if (Key == IK_Joy5)	// Start button
		{
			// Clicks on menu item
			log(self@"clicking on"@Root.MouseWindow@"at"@Root.MouseX@Root.MouseY);
			Root.MouseWindow.Click(Root.MouseX, Root.MouseY);
			//return true;
		}
		// FIXME See if the controls want to do anything
		//return Root.MouseWindow.KeyEvent(Key, Action, Delta);
		*/
	}

	if (Action == IST_Release)
	{
		JoyRepeatKey = IK_None;
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
			bHoldMenuButton = true;
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
			bHoldMenuButton = true;
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_LEFT_BUTTON) == "1")
			bHoldMenuButton = true;
		else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_RIGHT_BUTTON) == "1")
			bHoldMenuButton = true;
		
		if (bHoldMenuButton)
			MenuRepeatStart = 0;
	}

	// Turn joystick buttons into menu events
	if (MenuRepeatStart != 0 && Action == IST_Hold && GetLevel().TimeSecondsAlways - MenuRepeatStart >= MenuRepeatTime)
	{
		if (GetLevel().TimeSecondsAlways - MenuRepeatLast >= MenuRepeatDelay)
		{
			if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
			{
				Root.bUsingJoystick = true;
				execMenuUpButton();
				bHoldMenuButton = true;
			}		
			else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
			{
				Root.bUsingJoystick = true;
				execMenuDownButton();
				bHoldMenuButton = true;
			}
			else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_LEFT_BUTTON) == "1")
			{
				Root.bUsingJoystick = true;
				execMenuLeftButton();
				bHoldMenuButton = true;
			}
			else if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_RIGHT_BUTTON) == "1")
			{
				Root.bUsingJoystick = true;
				execMenuRightButton();
				bHoldMenuButton = true;
			}
			if (bHoldMenuButton)
				MenuRepeatLast = GetLevel().TimeSecondsAlways;
		}
	}
	return false;
}

// Defined in child classes
function execMenuButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC MENU BUTTON!");
	//log(self@"Menu Button");
}
function execConfirmButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC CONFIRM BUTTON!");
	//log(self@"Confirm Button");
}
function execBackButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC BACK BUTTON!");
	//log(self@"Back Button");
}
function execMenuUpButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC MENU UP BUTTON!");
	//log(self@"Menu Up Button");
}
function execMenuDownButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC MENU DOWN BUTTON!");
	//log(self@"Menu Down Button");
}
function execMenuLeftButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC MENU LEFT BUTTON!");
	//log(self@"Menu Left Button");
}
function execMenuRightButton()
{
	//if (!self.IsA('UDebugRootWindow'))
		//warn(self@"USED DEFAULT EXEC MENU RIGHT BUTTON!");
	//log(self@"Menu Right Button");
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (HandleJoystick(Key, Action, Delta))
		return true;
	return false;
}

defaultproperties
{
	MenuRepeatTime=0.5
	MenuRepeatDelay=0.2
	JoyRepeatTime=0.5
	JoyRepeatDelay=0.2
}