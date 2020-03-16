class GBMessage2 extends CriticalEventPlus;

var(Message) localized string GrabbedABagString1;
var(Message) color YellowColor;

static function color GetColor(
	optional int Switch,
	optional int GameIndex,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.YellowColor;
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.GrabbedABagString1;
}

defaultproperties
{
	GrabbedABagString1="You lost all your bags and power!"

	bIsPartiallyUnique=true
	bIsConsoleMessage=false
	Lifetime=5
	YellowColor=(R=255,G=255,B=0,A=255)
}
