// AchievementUnlockMessage
// Big ol' message that displays when an achievement is unlocked.
// Temporary use until we get for-reals Steam achievements

class AchievementProgressMessage extends GameEventPlus;

var localized string UnlockMessage;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if (P2Player(P) != None)
		P2Player(P).CommentOnAchievement(Switch);
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.UnlockMessage;
}

defaultproperties
{
	UnlockMessage = "Achievement Progress"
	Lifetime = 10
	DrawColor(0)=(R=255,G=128,B=128,A=255)
	DrawColor(1)=(R=255,G=128,B=128,A=255)
}
