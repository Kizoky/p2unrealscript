//=============================================================================
// SceneManager
//
// Manages a matinee scene.  Contains a list of action items that will
// be played out in order.
//=============================================================================
class SceneManager extends Info
	placeable
	native;

#exec Texture Import File=Textures\scenemanager.bmp  Name=S_SceneManager Mips=Off MASKED=1

// Graphics for UI
#exec Texture Import File=Textures\S_MatineeIP.pcx Name=S_MatineeIP Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeIPSel.pcx Name=S_MatineeIPSel Mips=Off MASKED=1
#exec Texture Import File=Textures\S_MatineeTimeMarker.pcx Name=S_MatineeTimeMarker Mips=Off MASKED=1
#exec Texture Import File=Textures\ActionCamMove.pcx  Name=S_ActionCamMove Mips=Off
#exec Texture Import File=Textures\ActionCamPause.pcx  Name=S_ActionCamPause Mips=Off
#exec texture Import File=Textures\PathLinear.pcx  Name=S_PathLinear Mips=Off MASKED=1
#exec Texture Import File=Textures\PathBezier.pcx  Name=S_PathBezier Mips=Off MASKED=1
#exec Texture Import File=Textures\S_BezierHandle.pcx  Name=S_BezierHandle Mips=Off MASKED=1
#exec Texture Import File=Textures\SubActionIndicator.pcx  Name=SubActionIndicator Mips=Off MASKED=1

struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
// RWS CHANGE: add support for looking at a tag (so we can look at spawned actors)
	var() Name LookAtTag;
// RWS CHANGE: add support for looking at a tag (so we can look at spawned actors)
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var int MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
};

struct Interpolator
{
	var() int bDone;
	var() float _value;
	var() float _remainingTime;
	var() float _totalTime;
	var() float _speed;
	var() float _acceleration;
};

// Exposed vars
var()	export	editinline	array<MatAction>	Actions;
var()	config	enum EAffect
{
	AFFECT_ViewportCamera,
	AFFECT_Actor,
} Affect;
var()	Actor	AffectedActor;			// The name of the actor which will follow the matinee path (if Affect==AFFECT_Actor)
var()	bool	bLooping;				// If this is TRUE, the path will looping endlessly
var()	bool	bCinematicView;			// Should the screen go into letterbox mode when playing this scene?
var()   name	PlayerScriptTag;		// Tag of sequence that player's pawn should use during sequence
var()	name	NextSceneTag;			// The tag of the next scenemanager to execute when this one finishes
// RWS CHANGE - add flag to determine whether player can skip this scene
var()	bool	bLetPlayerSkip;			// Determines whether player can skip the cutscene outright
var()	bool	bLetPlayerFastForward;	// If bLetPlayerSkip is false, player can fast-forward instead
var()	bool	bLetPlayerSkipIfSeen;	// Allows the player to skip this cutscene if it's already been seen at least once.
// RWS CHANGE - add this so we can avoid unwanted screen updates between two scenes
var()	Pawn	PrecedingScenesPawn;

// These vars are set by the SceneManager in it's Tick function.  Don't mess with them directly.
var		transient float PctSceneComplete;			// How much of the scene has finished running
var		transient mataction	CurrentAction;			// The currently executing action
var		transient float SceneSpeed;
var		transient float	TotalSceneTime;				// The total time the scene will take to run (in seconds)
var		transient Actor	Viewer;						// The actor viewing this scene (the one being affected by the actions)
var		transient Pawn OldPawn;						// The pawn we need to repossess when scene is over
var		transient bool bIsRunning;					// If TRUE, this scene is executing.
var		transient bool bIsSceneStarted;				// If TRUE, the scene has been initialized and is running
var		transient float CurrentTime;				// Keeps track of the current time using the DeltaTime passed to Tick
var		transient array<vector> SampleLocations;	// Sampled locations for camera movement
var		transient array<MatSubAction> SubActions;	// The list of sub actions which will execute during this scene
var		transient Orientation CamOrientation;		// The current camera orientation
var		transient Orientation PrevOrientation;		// The previous orientation that was set
var		transient Interpolator RotInterpolator;		// Interpolation helper for rotations
var		transient vector CameraShake;				// The SubActionCameraShake effect fills this var in each frame
var		transient vector DollyOffset;				// How far away we are from the actor we are locked to
var		transient float TimeDilation;

// Kamek change - allows SceneManagers to disable pausing/menu
var()	bool	bForbidPausing;

// Added "can't skip" messages
var() array<String> CantSkipMessage;	// Message to be displayed when player attempts to skip

// Native functions
native function float GetTotalSceneTime();

simulated function BeginPlay()
{
	Super.BeginPlay();

	if( Affect == AFFECT_Actor && AffectedActor == None )
		log(self @ "BeginPlayer(): Affected actor is NULL!" );

	//
	// Misc set up
	//

	TotalSceneTime = GetTotalSceneTime();
	bIsRunning = false;
	bIsSceneStarted = false;
}

event PostLoadGame()
{
	Super.PostLoadGame();
	// Get things back to where they'd be after a normal level start
	BeginPlay();
}


function Trigger( actor Other, Pawn EventInstigator )
{
	local PlayerController PC;
	
	// RWS 5/15/15: Prevent these from starting with a dead player
	if (Affect == AFFECT_ViewportCamera)
	{
		// If the pawn does not exist (chunked up) or is dead, don't let the scene start here.
		// Exception: if a scene is already running (the player won't have a pawn)
		foreach DynamicActors(class'PlayerController', PC)
			if (PC.GetCurrentSceneManager() == None && (PC.Pawn == None || PC.Pawn.Health <= 0))
				return;
	}	
	
	bIsRunning = true;
	bIsSceneStarted = false;
	Disable( 'Trigger' );
}

// Events
event SceneStarted()	// Called from C++ when the scene starts.
{
	local Controller P;
	local AIScript S;

	// Helpful log message
	Log(self @ "SceneStarted(): Tag='"$Tag$"' PlayerScriptTag='"$PlayerScriptTag$"' PrecedingScenesPawn="$PrecedingScenesPawn);
	
	// Turn off fast forward if the gameinfo forbids it
	if (!Level.Game.bAllowMatineeFastForward)
		bLetPlayerFastForward=false;

	// Figure out who our viewer is.
	Viewer = None;
	if( Affect==AFFECT_Actor )
		Viewer = AffectedActor;
	else
	{
		for( P = Level.ControllerList ; P != None ; P = P.nextController )
			if( P.IsA('PlayerController') )
			{
				Viewer = P;
				// RWS CHANGE: If there was a preceding scene then use it's pawn
				if ( PrecedingScenesPawn != None)
					OldPawn = PrecedingScenesPawn;
				else
					OldPawn = PlayerController(Viewer).Pawn;
				if ( OldPawn != None )
				{
					OldPawn.Velocity = vect(0,0,0);
					OldPawn.Acceleration = vect(0,0,0);

					// RWS CHANGE: Reset the player's spine to stand up straight
					OldPawn.SetTwistLook(0,0);
					OldPawn.bDoTorsoTwist=false;

					// RWS CHANGE: If there was no preceeding scene then do normal startup
					if (PrecedingScenesPawn == None)
						PlayerController(Viewer).UnPossess();
					if ( PlayerScriptTag != 'None' )
					{
						ForEach DynamicActors( class'AIScript', S, PlayerScriptTag )
							break;
						if ( S != None )
							S.TakeOver(OldPawn);
					}
				}
				
				
				
				// RWS CHANGE: If there was no preceeding scene then do normal startup
				if (PrecedingScenesPawn == None)
					PlayerController(Viewer).StartInterpolation();
				PlayerController(Viewer).MyHud.bHideHUD = true;

				// JWB: Moved cinematic view from c++
				PlayerController(Viewer).myHUD.bCinematicView = bCinematicView;
				
				// RWS CHANGE: Always clear to prepare for next time
				PrecedingScenesPawn = None;
				break;
			}
	}
	Viewer.StartCutscene();
	Viewer.StartInterpolation();
}

event SceneEnded()		// Called from C++ when the scene ends.
{
	local SceneManager NextScene;

	bIsSceneStarted = false;

	// RWS CHANGE
	// Implemented a workaround for the glitches that occurred when going directly
	// from one scene into another scene or when looping the same scene.  At the
	// end of the fist scene the PlayerController would Possess the old pawn and
	// at the start of the next scene it would UnPossess it.  During that brief
	// time when the PlayerController had control of the pawn, the screen would
	// (somtimes) be updated with the player's first-person-view, resulting in an
	// ugly glitch.  To get around this, we check if another scene follows this one,
	// and if so we save the pawn in the next scene's PrecedingScenesPawn and then
	// we don't let the PlayerController possess the pawn, nor do we unhide the HUD,
	// nor finish interpolation.
	if ( Affect == AFFECT_ViewportCamera )
	{
		if (bLooping)
			NextScene = self;
		else if ( NextSceneTag != '' && NextSceneTag != 'None' )
		{
			ForEach DynamicActors( class 'SceneManager', NextScene, NextSceneTag )
				break;
		}
	}

	// RWS CHANGE
	// If there is a scene immediately following this one, pass the pawn to it and
	// skip the normal end-of-scene stuff.
	if (NextScene != None)
	{
		NextScene.PrecedingScenesPawn = OldPawn;
	}
	else
	{
		// RWS CHANGE
		// Moved cleanup into separate function.  See function for details.
		Cleanup();
	}
	Enable( 'Trigger' );

	// Helpful log message
	Log(self @ "SceneEnded(): Tag='"$Tag$"' NextSceneTag='"$NextSceneTag$"'");
}

// RWS CHANGE
// Call this function for each SceneManger before player travels to new level
function PreTravel()
{
	if (bIsRunning)
		Cleanup();
}

// RWS CHANGE
// Moved cleanup stuff into this function so that it can be called before the
// player travels to a new level.  Without doing this cleanup, the engine
// will crash because the player controller has no pawn.
function Cleanup()
{
	local int SanityCheck;

	Log(self @ "Cleanup()");
	if( Affect==AFFECT_ViewportCamera )
	{
		if ( PlayerController(Viewer) != None )
		{
			if ( OldPawn != None )
			{
				// RWS CHANGE
				// Tell the scripted controller to stop scripting.  This is
				// done as a loop because a scripted controller may give control
				// to whatever controller had control before it did.  That happens
				// when one scene goes right into another, in which case nobody
				// ever told all those controllers to stop scripting, so they
				// just piled up.  It's all one great big ugly hack, but hey, it
				// seems to work.  If we don't do this, then the scripted controller(s)
				// will keep trying to perform more actions, which leads to very bad things.
				while ( AIController(OldPawn.Controller) != None && SanityCheck < 10)
					{
					AIController(OldPawn.Controller).LeaveScripting();
					SanityCheck++;
					}

				// RWS CHANGE: Turn the torso twist back on
				OldPawn.bDoTorsoTwist=true;

				PlayerController(Viewer).Possess( OldPawn );
				OldPawn = None;
				}
			PlayerController(Viewer).MyHud.bHideHUD = false;
			PlayerController(Viewer).myHUD.bCinematicView = false;
		}
	}
	Viewer.FinishedInterpolation();
}

defaultproperties
{
	Style=STY_Sprite
	Texture=S_SceneManager
	Affect=AFFECT_ViewportCamera
	SceneSpeed=1
	bLooping=False
	DrawScale=0.25
	bLetPlayerFastForward=true
}
