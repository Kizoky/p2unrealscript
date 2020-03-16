class GBMessage extends CriticalEventPlus;

var(Message) localized string GrabbedABagString1;
var(Message) localized string GrabbedABagString2;
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
	local int usescore;

	if(P.Level.NetMode == NM_ListenServer
		&& P.Role == ROLE_Authority
		&& ViewPort(P.Player) != None)
		usescore = int(MpPawn(P.Pawn).FlavinMult*(100*P.PlayerReplicationInfo.Score));
	else
		usescore = int(MpPawn(P.Pawn).FlavinMult*(100*(P.PlayerReplicationInfo.Score + 1)));

	return Default.GrabbedABagString1@(usescore)@Default.GrabbedABagString2;
}

defaultproperties
{
	GrabbedABagString1="You grabbed a bag and are "
	GrabbedABagString2="% stronger now!"

	bIsPartiallyUnique=true
	bIsConsoleMessage=false
	Lifetime=5
	YellowColor=(R=255,G=255,B=0,A=255)
}
