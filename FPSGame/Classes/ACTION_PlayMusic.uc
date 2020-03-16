class ACTION_PlayMusic extends ScriptedAction;

// Use ACTION_StopMusic to stop this song with this handle
// but be sure to call it before any other songs get played, so the songhandle will still be valid
// in the scripted controller.

var(Action) string				Song;					// Filename of song to play
var Actor.EMusicTransition	Transition;	// UNUSED now that we're calling PlayMusicExt instead of ClientSetMusic
var(Action) bool				bAffectAllPlayers;		// Whether to affect all players or just the instigating player
var(Action) float				FadeInSongTime;			// Fade in time

function bool InitActionFor(ScriptedController C)
{
	local PlayerController P;
	local Controller A;

	if (Song != "")
	{
		if( bAffectAllPlayers )
		{
			For ( A=C.Level.ControllerList; A!=None; A=A.nextController )
				if ( A.IsA('PlayerController') )
				{
					C.SongHandle = FPSGameInfo(C.Level.Game).PlayMusicExt(Song, FadeInSongTime);
				}
		}
		else
		{
			// Only affect the one player.
			P = PlayerController(C.GetInstigator().Controller);
			if( P==None )
				return false;
				
			// Go to music.
			C.SongHandle = FPSGameInfo(C.Level.Game).PlayMusicExt(Song, FadeInSongTime);
		}
	}
	return false;	
}

function string GetActionString()
{
	return ActionString@Song;
}

defaultproperties
{
	 bAffectAllPlayers=True
	 FadeInSongTime=1.0
	 ActionString="play song"
}