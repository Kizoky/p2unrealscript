///////////////////////////////////////////////////////////////////////////////
// ProtestorInfo
//
// Handles path for protestors and who is using it and protesting
//
// This stores a list of all the non-unique tags of the pawns using it
// but also stores a list of *unique* pawns actually using it.
// 
// It then uses this list to keep track of the sound to be played, and tries
// to play it on the middle guy in the list. 
//
///////////////////////////////////////////////////////////////////////////////
class ProtestorInfo extends Info
		placeable;

///////////////////////////////////////////////////////////////////////////////
// VARS
///////////////////////////////////////////////////////////////////////////////
var ()export editinline array<Name> PawnTagList;	// List of tags of protestors who use this
var ()Name	FirstLoopPointTag;		// Tag of first loop point in path
var ()float MoveReductionPct;		// How much to reduce the movement by to make inner loops slow enough
									// to match outer loops
struct SoundStruct
{
	var () Sound ThisSong;			// use this to play sounds
};
var ()export editinline array<SoundStruct> Songs;	// different chants
var ()bool	bRandomizeSongOrder;	// Randomize the order in which you play your songs (default)
var ()int	TimesToLoopEachSong;	// Number of times to loop a song before you play another
var int CurrentSongIndex;			// index in Songs, the one we're currently playing
var int LoopNum;					// how many times we've played this song
var int SongPlayTime;				// how long the song will last

var () String Music;				// use this to play music
var () float MusicFadeInTime;		// time (in seconds) to fade in music
var () float MusicFadeOutTime;		// time (in seconds) to fade out music
var () float MusicVolume;			// volume for music
var () float MusicRadius;			// radius for music
var int MusicHandle;				// Handle to currently playing music

var () bool	bMusicStartsOff;		// Set to true, to have the music off, then trigger it on (just for
									// marcher info)

var LoopPoint FirstPoint;			// First point in loop
var array<LoopPoint> LoopPoints;	// List of loop points that protestors follow
var array<FPSPawn>	PawnList;			// List of actual pawn actors in our group

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
	{
	Super.PostBeginPlay();
	}

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
	{
	EndAllAudio();
	Super.Destroyed();
	}

///////////////////////////////////////////////////////////////////////////////
// End all audio that this thing is playing
///////////////////////////////////////////////////////////////////////////////
function EndAllAudio()
	{
	EndMusic();
	AmbientSound = None;
	}

function EndMusic()
	{
	if (MusicHandle != 0)
		{
		FPSGameInfo(Level.Game).StopMusicExt(MusicHandle, MusicFadeOutTime);
		MusicHandle = 0;
		}
	}

///////////////////////////////////////////////////////////////////////////////
// Something has happened to someone in the group, so make the rest react
// and eventually kill this info, so the sound stops.
// This offers either attacker or interestpawn because some things the player
// might do might only piss them off a little, in which case they'll be interestpawns
///////////////////////////////////////////////////////////////////////////////
singular function DisruptGroup(Controller TellerCont, FPSPawn Attacker, FPSPawn InterestPawn, 
					  optional bool bKnowAttacker)
{
	local int i;
	local FPSPawn CheckPawn;
	local LambController LambCheck;
	local PersonController CheckCont, pcont;
	local ProtestorInfo Pinfo;

	pcont = PersonController(TellerCont);

	if(Attacker == None)
		Attacker = InterestPawn;
	else if(InterestPawn == None)
		InterestPawn = Attacker;

	// if neither came through (now that should be transferred by now) return
	if(Attacker == None)
		return;

	// set the one who started this to null also
	LambCheck = LambController(TellerCont);
	if(LambCheck != None)
		LambCheck.MyProtestInfo = None;

	// Tell everyone but me about it
	for(i=0; i<PawnList.Length; i++)
	{	
		CheckPawn = PawnList[i];
		LambCheck = LambController(CheckPawn.Controller);
		if(LambCheck != None)
		{
			LambCheck.MyProtestInfo = None;
			LambCheck.ProtestingDisrupted(Attacker, InterestPawn, bKnowAttacker);
		}
	}
	
	// Tell any other linked infos
	foreach DynamicActors(class'ProtestorInfo', Pinfo, Tag)
		if (Pinfo != Self)
			Pinfo.DisruptGroup(TellerCont, Attacker, InterestPawn, bKnowAttacker);

	EndAllAudio();
	Destroy();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function Trigger( actor Other, pawn EventInstigator )
{
	local P2Player keepp;
	local FPSPawn CheckPawn;
	local PersonController CheckCont;

	// When we get triggered, we attack the player.
	if(PawnList.Length > 0)
	{
		CheckPawn = PawnList[0];
		CheckCont = PersonController(CheckPawn.Controller);
		if(CheckCont != None)
		{
			keepp = CheckCont.GetRandomPlayer();
			// turn on everyone
			DisruptGroup(None, keepp.MyPawn, keepp.MyPawn, true);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Assign a new song out of Songs to AmbientSound
///////////////////////////////////////////////////////////////////////////////
function SetNextSong()
{
	// get a different one each time
	if(bRandomizeSongOrder)
		CurrentSongIndex = Rand(Songs.Length);

	//log(self$" picking "$CurrentSongIndex);

	// Set sound
	if (Songs.Length > 0
		&& Songs[CurrentSongIndex].ThisSong != None)
		AmbientSound = Songs[CurrentSongIndex].ThisSong;
	else
		AmbientSound = None;

	// if not random, then make sure to increment and wrap
	if(!bRandomizeSongOrder)
	{
		CurrentSongIndex++;
		if(CurrentSongIndex >= Songs.Length)
			CurrentSongIndex=0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Gets music going. Starts up right off the bat normally, in Init, unless
// bMusicStartsOff is set to true. 
///////////////////////////////////////////////////////////////////////////////
function StartupMusic()
{
	// Set music
	if (Music != "")
		{
		EndMusic();
		MusicHandle = FPSGameInfo(Level.Game).PlayMusicAttenuateExt(self, Music, MusicFadeInTime, MusicVolume, MusicRadius, SoundPitch/64);
		}

	// Set song
	SetNextSong();

	// If we only have one song, don't bother with playing state
	if(Songs.Length <= 1)
		GotoState('');
	else
		GotoState('Playing');
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Prep all the arrays and pawns
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
auto state Init
{
	///////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////
	function Actor FindByTag(Name thistag)
	{
		local Actor CheckA;

		ForEach AllActors(class'Actor', CheckA, thistag)
		{
			return CheckA;
		}

		log(self$" ERROR: tag not found "$thistag);

		return None;
	}

/*
	///////////////////////////////////////////////////////////////////////////////
	// Setup what this pawn will do, protesting, marching, etc.
	///////////////////////////////////////////////////////////////////////////////
	function SetupPawnStates(FPSPawn CheckPawn)
	{
		local LambController lambc;

		lambc = LambController(CheckPawn.Controller);
		// Figure out our home nodes, if we have any
		if(CheckPawn.bCanEnterHomes)
			lambc.FindHomeList(CheckPawn.HomeTag);
		// Link to the remaining path nodes
		lambc.FindPathList();

		CheckPawn.SetProtesting(true);
		lambc.GotoState('Thinking');
		lambc.GotoState('Protesting');
	}
*/
	///////////////////////////////////////////////////////////////////////////////
	// Setup what this pawn will do, protesting, marching, etc.
	///////////////////////////////////////////////////////////////////////////////
	function SetupPawnStates(FPSPawn CheckPawn)
	{
		CheckPawn.SetProtesting(true);
		CheckPawn.Controller.GotoState('Thinking');
		CheckPawn.Controller.GotoState('Protesting');
	}

	///////////////////////////////////////////////////////////////////////////////
	// Tell all the pawns to protest
	///////////////////////////////////////////////////////////////////////////////
	function SetupInfo()
	{
		local int i;
		local Name CheckName;
		local FPSPawn CheckPawn;
		local bool bFoundAll;
		local vector newloc;

		//log(self$" initting");
		FirstPoint = LoopPoint(FindByTag(FirstLoopPointTag));

		// Prep the pawns in the loop
		ForEach AllActors(class'FPSPawn', CheckPawn)
		{
			// Go through all actors and for each pawn with this tag, set
			// them up to protest.
			// Only include guys that are alive and that aren't setup with
			// someone already in mind to attack.
			for(i=0; i<PawnTagList.Length; i++)
			{
				if(CheckPawn.Tag == PawnTagList[i]
					&& CheckPawn.Health > 0
					&& (PersonController(CheckPawn.Controller) == None
						|| PersonController(CheckPawn.Controller).Attacker == None))
				{
					CheckPawn.MyLoopPoint = FirstPoint;
					CheckPawn.MovementPct = MoveReductionPct;
					SetupPawnStates(CheckPawn);
					// store that pawn in our big pawn list
					PawnList.Insert(PawnList.Length, 1);
					PawnList[PawnList.Length-1] = CheckPawn;
					// and link the controller to us
					LambController(CheckPawn.Controller).LinkToProtestInfo(self);
				}
			}
		}

		if(PawnList.Length > 0)
		{
			// We'll attach the protestor info to our middle guy (middle in the
			// number of protestors, and make it move with him, so the sound will
			// go along with them. 
			//log(self$" midcount "$PawnList.Length/2$" count "$PawnList.Length);
			CheckPawn = PawnList[PawnList.Length/2];
			// But first move our protestor point to this mid guy's position, so our
			// relative offset isn't wacky.
			newloc = CheckPawn.Location;
			newloc.x+=CheckPawn.CollisionRadius;
			SetLocation(newloc);
			// now attach
			SetBase(CheckPawn);
		}
		else // If you don't have any protestors, then delete yourself.
			Destroy();
	}

Begin:
	Sleep(0.2);
	SetupInfo();

	if(!bMusicStartsOff)
		StartupMusic();
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Handle sound changing
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state Playing
{
Begin:
	// The ambient sound will keep looping, so we just get it's duration and
	// wait for it to play however many times was specified, and then we go
	// on to the next one.
	SongPlayTime = GetSoundDuration(Songs[CurrentSongIndex].ThisSong);
	Sleep(SongPlayTime);
	
	LoopNum++;
	if(LoopNum >= TimesToLoopEachSong)
	{
		LoopNum = 0;
		SetNextSong();
	}

	Sleep(0.0);
	Goto('Begin');
}

defaultproperties
{
//	bHidden=false
	MoveReductionPct=1.0
//	Songs[0]=(ThisSong=Sound'dialog.Protestors.wm_protest_rws1')
	bRandomizeSongOrder=true
	TimesToLoopEachSong=8
	MusicVolume=1.0
	MusicRadius=500.0
	Texture=Texture'PostEd.Icons_256.ProtestorInfo'
	DrawScale=0.25
}
