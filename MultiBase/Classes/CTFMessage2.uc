class CTFMessage2 extends CriticalEventPlus;

// CTF Messages
//
// Switch 0: You have the flag message.
//
// Switch 1: Enemy has the flag message.

var(Message) localized string YouHaveFlagString;
var(Message) localized string EnemyHasFlagString;
var(Message) color RedColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional int GameIndex,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (Switch == 0)
		return Default.YellowColor;
	else
		return Default.RedColor;
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
	    return Default.YouHaveFlagString;
    else
	    return Default.EnemyHasFlagString;
}

defaultproperties
{
	YouHaveFlagString="You snatched their ho, get her in bed!"
	EnemyHasFlagString="They snatched your babe, snatch her back!"

	bIsPartiallyUnique=true
	bIsConsoleMessage=false
	Lifetime=1
	RedColor=(R=255,G=0,B=0,A=255)
	YellowColor=(R=255,G=255,B=0,A=255)
}
