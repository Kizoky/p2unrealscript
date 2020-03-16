class GBMessage3 extends GBMessage;

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
		usescore = int(MpPawn(P.Pawn).FlavinMult*(100*(P.PlayerReplicationInfo.Score - 1)));

    return Default.GrabbedABagString1@(usescore)@Default.GrabbedABagString2;
}

defaultproperties
{
	GrabbedABagString1="You dropped a bag and are only "
	GrabbedABagString2="% stronger now!"
}
