//
// Postal 2 Multiplayer Death Message.
//
// Switch 0: Kill
//	RelatedPRI_1 is the Killer.
//	RelatedPRI_2 is the Victim.
//	OptionalObject is the DamageType Class.
//

class xDeathMessage extends LocalMessagePlus;

var localized string KilledString, SomeoneString;
var class<LocalMessage>	KillerMessageClass;
var class<LocalMessage> VictimMessageClass;

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local string KillerName, VictimName;

	if (Class<DamageType>(OptionalObject) == None)
		return "";

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.PlayerName;

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName, 
			VictimName,
			Class<DamageType>(OptionalObject).Static.SuicideMessage(RelatedPRI_2) );
	}

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.PlayerName;

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName, 
		VictimName,
		Class<DamageType>(OptionalObject).Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 0 )
	{
		// If this player is the killer or victim then send a special message in addition to this message
		if (RelatedPRI_1 == P.PlayerReplicationInfo)
			P.myHUD.LocalizedMessage( Default.KillerMessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		else if (RelatedPRI_2 == P.PlayerReplicationInfo) 
			P.ReceiveLocalizedMessage( Default.VictimMessageClass, 0, RelatedPRI_1 );
	}

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	KillerMessageClass=class'KillerMessagePlus'
	VictimMessageClass=class'VictimMessage'
	KilledString="was killed by"
	SomeoneString="someone"
	LifeTime=3
}