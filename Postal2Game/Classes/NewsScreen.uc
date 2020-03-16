///////////////////////////////////////////////////////////////////////////////
// NewsScreen.uc
// Copyright 2002 Running With Scissors, Inc.  All Rights Reserved.
//
// The newspaper screen.
//
//	History:
//		07/12/02 MJR	Started.
//
///////////////////////////////////////////////////////////////////////////////
class NewsScreen extends P2Screen;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////

var() StaticMesh	PaperMesh;
var RawActor		Paper;

var() float			StartX;
var() float			StartY;
var() float			ScaleStart;
var() float			ScaleEnd;
var() float			NumberOfSpins;
var() float			TotalTime;
var float			ElapsedTime;
var float			Percent;
var bool			bMustWait;	// Set to true, if you want them watch the entire newspaper
								// sequence complete with dude comments
var float			BufferCommentTime; // How much extra time after the dude finishes
								// talking do we need to wait before we show a message about continuing


///////////////////////////////////////////////////////////////////////////////
// Call this to bring up the screen
///////////////////////////////////////////////////////////////////////////////
function Show(bool bForceWait)
	{
	local vector scale;

	// Get texture for this day
	BackgroundTex = GetGameSingle().GetNewsTexture();

	// Create actor for spinning newspaper (this is destroyed and
	// then recreated whenever the player travels to a new level)
	if (Paper == None)
		{
		Paper = ViewportOwner.Actor.Spawn(class'RawActor', ViewportOwner.Actor);
		Paper.SetStaticMesh(PaperMesh);
		Paper.SetDrawType(DT_StaticMesh);
		Paper.bUnlit = true;
		// temp - change to look like newspaper until we get new staticmesh
		Paper.Skins.insert(0, 1);
		scale.X = 0.25;		// depth
		scale.Y = 1.0;		// width
		scale.Z = 0.45;		// height
		Paper.SetDrawScale3D(scale);
		}

	// Always put the new background texture in the paper, each time (in case
	// were in the same level with two different papers, like on the Apocalypse/day 5)
	if(Paper.Skins.Length > 0)
		Paper.Skins[0] = BackgroundTex;

	// Set if we will let the person skip this newspaper until the end
	bMustWait = bForceWait;
	// If we're forcing them to wait, then make the buffer time even longer
	if(bMustWait)
		BufferCommentTime = 2*default.BufferCommentTime;

	// Set our first state and start it up
	AfterFadeInScreen = 'Spinning';
	Super.Start();
	}

///////////////////////////////////////////////////////////////////////////////
// Called before player travels to a new level
///////////////////////////////////////////////////////////////////////////////
function PreTravel()
	{
	Super.PreTravel();

	// Get rid of all actors because they'll be invalid in the new level (not
	// doing this will lead to intermittent crashes!)
	Paper = None;
	}

///////////////////////////////////////////////////////////////////////////////
// Default tick function.
///////////////////////////////////////////////////////////////////////////////
function Tick(float DeltaTime)
	{
	Super.Tick(DeltaTime);

	if (bPlayerWantsToEnd
		&& !bMustWait)
		{
		// Clear flag (it may get set again)
		bPlayerWantsToEnd = false;
		ChangeExistingDelay(0.1);
		End();
		}
	}

///////////////////////////////////////////////////////////////////////////////
// This is called by the HUD to see if it should draw itself
///////////////////////////////////////////////////////////////////////////////
function bool ShouldDrawHUD()
	{
	// This screen doesn't fade the game in and out so we need to override
	// the super version of this.  We simply hide the HUD once the newspaper
	// gets to be larger than a certain amount.  This helps make it less
	// noticeable when the HUD blinks out.
	if (Percent < 0.50)
		return true;
	return false;
	}

///////////////////////////////////////////////////////////////////////////////
// Render this screen
///////////////////////////////////////////////////////////////////////////////
function RenderScreen(Canvas canvas)
	{
	local float Curve;
	local float X1, Y1, X2, Y2;

	// Calculate percentage (0 to 1) and convert to sin which also goes 0 to 1
	// but it changes quickly at first and then slows down as it approaches 1.
	Percent = FClamp(ElapsedTime / TotalTime, 0.0, 1.0);
	Curve = sin(Percent * 1.5707);

	// Paper moves from specified start position to center of screen
	X1 = StartX * Canvas.ClipX;
	Y1 = StartY * Canvas.ClipY;
	X2 = Canvas.ClipX / 2;
	Y2 = Canvas.ClipY / 2;

	// Draw the paper with the location, scaling, and spining all based on the curve
	DrawPaper(
		Canvas,
		X1 + ((X2 - X1) * Curve),
		Y1 + ((Y2 - Y1) * Curve),
		ScaleStart + ((ScaleEnd - ScaleStart) * Curve),
		65535 * NumberOfSpins * Curve);
	}

///////////////////////////////////////////////////////////////////////////////
// Draw newspaper
///////////////////////////////////////////////////////////////////////////////
function DrawPaper(Canvas canvas, float X, float Y, float Size, float Spin)
	{
	local vector screen;
	local vector world;
	local vector scale;
	local vector CameraLocation;
	local rotator CameraRotation;
	local actor viewtarget;

	Canvas.Style = 1; //ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255, 255, 255);

	// Convert from 2D to 3D world vector.  Vector comes back extremely close to
	// the near clipping plane, so we push it back to avoid actor clipping problems.
	screen.X = X;
	screen.Y = Y;
	screen.Z = 0;
	world = ScreenToWorld(screen); 
	world *= 2.0;

	Paper.SetDrawScale(Size);

	// Use player's camera's location and rotation to position actor relative to
	// camera and keep it rotated so we always see it from the same side.
	ViewportOwner.Actor.PlayerCalcView(ViewTarget, CameraLocation, CameraRotation);
	Paper.SetLocation(CameraLocation + world);
	CameraRotation.Roll = Spin;
	Paper.SetRotation(CameraRotation);
	Canvas.DrawActor(Paper, false);
	}

///////////////////////////////////////////////////////////////////////////////
// Newspaper spins and grows
///////////////////////////////////////////////////////////////////////////////
state Spinning extends ShowScreen
	{
	function BeginState()
		{
		ElapsedTime = 0.0;
		}

	function Tick(float DeltaTime)
		{
		Super.Tick(DeltaTime);

		ElapsedTime += DeltaTime;

		if (ElapsedTime >= TotalTime)
			GotoState('DoneSpinning');
		}
	}

state DoneSpinning extends ShowScreen
	{
	function BeginState()
		{
		// Short delay to give player a moment to focus before dude comment
		DelayedGotoState(1.0, 'DoneSpinning2');
		}
	}

state DoneSpinning2 extends ShowScreen
	{
	function BeginState()
		{
		local float duration;
		local Sound DudeComment;

		DudeComment = GetGameSingle().GetDudeNewsComment();
		GetSoundActor().PlaySound(DudeComment, SLOT_Talk, 1.0);
		duration = GetSoundDuration(DudeComment) + BufferCommentTime;

		DelayedGotoState(duration, 'HoldScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// View screen until player decides to stop
///////////////////////////////////////////////////////////////////////////////
state HoldScreen extends ShowScreen
	{
	function BeginState()
		{
		// Say we're ready to let him continue
		bMustWait=false;

		ShowMsg();

		WaitForEndThenGotoState('FadeOutScreen');
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     PaperMesh=StaticMesh'stuff.stuff1.NewspaperBox'
     StartX=0.950000
     StartY=0.150000
     ScaleStart=0.030000
     ScaleEnd=1.030000
     NumberOfSpins=4.000000
     TotalTime=1.500000
     BufferCommentTime=1.500000
     bFadeGameInOut=False
     FadeInGameTime=0.000000
     FadeOutGameTime=0.000000
     bFadeScreenInOut=False
     FadeInScreenTime=0.000000
     FadeOutScreenTime=0.000000
	 
	 //ErikFOV Change: Subtitle system
	 bShowSubtitles=True
	 //end
}
