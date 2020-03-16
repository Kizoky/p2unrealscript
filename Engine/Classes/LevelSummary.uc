//=============================================================================
// LevelSummary contains the summary properties from the LevelInfo actor.
// Designed for fast loading.
//=============================================================================
class LevelSummary extends Object
	native;

var(LevelSummary) localized String Title;
var(LevelSummary) String Author;
var(LevelSummary) String Description;

var(LevelSummary) Material Screenshot;
var(LevelSummary) String DecoTextName;

var(LevelSummary) int IdealPlayerCountMin;
var(LevelSummary) int IdealPlayerCountMax;

// RWS CHANGE: Added new GrabBag flag
var(LevelSummary) bool	bGrabBagCompatible;		// Whether this map is compatible with GrabBag game type

var(LevelSummary) bool HideFromMenus;

var(SinglePlayer) int   SinglePlayerTeamSize;

var() localized string LevelEnterText;

defaultproperties
{
}
