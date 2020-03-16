//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>	ServerActors,
					ServerPackages;

var bool			FramePresentPending;

// RWS CHANGE: Level loading progress bar
// WARNING: These are in a very particular order so that this class' script size matches it's C++ size!
var PlayerController	ProgressBarController;
var int					ProgressBarTotalSteps;
var int					ProgressBarSteps;
var int					ProgressBarPhase;
var int					ProgressBarEnabled;
var float				ProgressBarPercent;
var float				ProgressBarTimer;
var float				ProgressBarDummy;	// Timer is a double in C++ so we pad it out with this dummy
var String				ProgressBarMap;
var bool				DrawToAllFrameBuffers;
// RWS CHANGE: Level loading progress bar

defaultproperties
{
}
