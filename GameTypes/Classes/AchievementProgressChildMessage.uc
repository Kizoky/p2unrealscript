// AchievementUnlockMessage
// Big ol' message that displays when an achievement is unlocked.
// Temporary use until we get for-reals Steam achievements

class AchievementProgressChildMessage extends GameEventPlus;

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return P.GetEntryLevel().GetAchievementManager().GetAchievementProgress(Switch) @ P.GetEntryLevel().GetAchievementManager().GetAchievementName(Switch);
}

defaultproperties
{
	Lifetime = 8
	MessageCategory = 3
	DrawColor(0)=(R=211,G=199,B=156,A=255)
	DrawColor(1)=(R=211,G=199,B=156,A=255)
}