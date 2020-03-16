//=============================================================================
//ErikFOV, 2017, SubtitleSystem
//=============================================================================
class SubtitleManager extends Actor
	config(Subtitles)
	native
	placeable;

struct native SubT
{
	var() Array<String> Text;
};

struct native DispT
{
	var() Array<int> Time;
};

// Subtitle info
var() config Array<Sound> SubSound;
var() config Array<Color> TextColor;
var() config Array<Color> NameColor;
var() config Array<SubT> Subtitle;
var() config Array<SubT> SpeakerName;
var() config Array<DispT> DisplayTime;
var() config Array<int> Priority;
var() config Array<String> SubTag;
// end

// Actors info
var() config Array<name> ActorID;
var() config Array<Color> ActorTextColor;
var() config Array<SubT> ActorName;
var() config Array<Color> ActorNameColor;
// end

var	config Color DefaultColor;
var	config Color DefaultNameColor;
var	config Color AppealForPlayerColor;
var	config Color EnemyColor;
var	config Color PlayerColor;

struct SoundFilter
{
	var sound Sound;
	var float time;
};

var Array<SoundFilter> InvalidSounds;
var () float InvalidTime; //If the same sound play during this time, subtitle not show.

struct PendingSound
{
	var sound Sound;
	var Actor Actor;
	var float time;
	var int index;
	var int Aindex;
};

var Array<PendingSound> PendingSounds;

event Postbeginplay()
{

}

native final function ShowSubtitle(String Tag);

defaultproperties
{
	bhidden=true
	InvalidTime=5
	bAlwaysTick=True
}

