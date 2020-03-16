//
// CTF Messages
//
// Switch 0: Capture Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 1: Return Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 2: Dropped Message
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//	
// Switch 3: Was Returned Message
//	OptionalObject is the flag's team teaminfo.
//
// Switch 4: Has the flag.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 5: Auto Send Home.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 6: Pickup stray.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.

class CTFMessage extends CriticalEventPlus;

var(Message) localized string ReturnedString[2];
var(Message) localized string ReturnedByString[2];
var(Message) localized string CapturedString[2];
var(Message) localized string DroppedString[2];
var(Message) localized string TakenString[2];

//var Sound	CapturedSounds[2];
var sound	ReturnSounds[2];
var sound	DroppedSounds[2];
var Sound	TakenSounds[2];

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int YouOrThem;
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (TeamInfo(OptionalObject) != None &&
		MpPlayer(P) != None &&
		P.PlayerReplicationInfo != None ||
		P.PlayerReplicationInfo.Team != None )
	{
		if (P.PlayerReplicationInfo.Team.TeamIndex != TeamInfo(OptionalObject).TeamIndex)
			YouOrThem = 1;

		switch (Switch)
		{
			// Captured the flag.
			case 0:
				MpPlayer(P).PlayAnnouncement(MpTeamInfo(RelatedPRI_1.Team).default.TeamScoreSound,1, true);
//				MpPlayer(P).PlayAnnouncement(default.CapturedSounds[YouOrThem],1, true);
				break;
			// Returned the flag.
			case 1:
			case 3:
			case 5:
				MpPlayer(P).PlayAnnouncement(default.ReturnSounds[YouOrThem],2, true);
				break;
			// Dropped the flag.
			case 2:
				MpPlayer(P).PlayAnnouncement(default.DroppedSounds[YouOrThem],2, true);
				break;
			// Took the flag
			case 4:
			case 6:
				MpPlayer(P).PlayAnnouncement(default.TakenSounds[YouOrThem],2, true);
				break;
		}
	}
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int YouOrThem;

	if (TeamInfo(OptionalObject) != None &&
		MpPlayer(P) != None &&
		P.PlayerReplicationInfo != None ||
		P.PlayerReplicationInfo.Team != None )
	{
		if (P.PlayerReplicationInfo.Team.TeamIndex != TeamInfo(OptionalObject).TeamIndex)
			YouOrThem = 1;

		switch (Switch)
		{
			// Captured the flag.
			case 0:
				if (RelatedPRI_1 == None)
					return "";
				return RelatedPRI_1.PlayerName @ Default.CapturedString[YouOrThem];
				break;

			// Returned the flag.
			case 1:
				if (RelatedPRI_1 == None)
					return Default.ReturnedString[YouOrThem];
				return RelatedPRI_1.PlayerName @ Default.ReturnedByString[YouOrThem];
				break;

			// Dropped the flag.
			case 2:
				if (RelatedPRI_1 == None)
					return "";
				return RelatedPRI_1.playername @ Default.DroppedString[YouOrThem];
				break;

			// Was returned.
			case 3:
				return Default.ReturnedString[YouOrThem];
				break;

			// Has the flag.
			case 4:
				if (RelatedPRI_1 == None)
					return "";
				return RelatedPRI_1.playername @ Default.TakenString[YouOrThem];
				break;

			// Auto send home.
			case 5:
				return Default.ReturnedString[YouOrThem];
				break;

			// Pickup
			case 6:
				if (RelatedPRI_1 == None)
					return "";
				return RelatedPRI_1.playername @ Default.TakenString[YouOrThem];
				break;
		}
	}
	return "";
}

defaultproperties
{
	ReturnSounds(0)=sound'MpAnnouncer.AnnouncerYourFlagReturned'
	ReturnSounds(1)=sound'MpAnnouncer.AnnouncerTheirFlagReturned'
	DroppedSounds(0)=Sound'MpAnnouncer.AnnouncerYourFlagDropped'
	DroppedSounds(1)=Sound'MpAnnouncer.AnnouncerTheirFlagDropped'
	TakenSounds(0)=Sound'MpAnnouncer.AnnouncerYourFlagTaken'
	TakenSounds(1)=Sound'MpAnnouncer.AnnouncerTheirFlagTaken'

	ReturnedByString(0)="returned your hottie!" 
	ReturnedByString(1)="returned the enemy ho!"
	ReturnedString(0)="Your hottie was returned!"
	ReturnedString(1)="The enemy ho was returned!"
	DroppedString(0)="dropped your chick!"
	DroppedString(1)="dropped the enemy slut!"
	TakenString(0)="snatched your babe!"
	TakenString(1)="snatched the enemy bitch!"
	CapturedString(0)="scored with your babe!"
	CapturedString(1)="scored with the enemy ho!"
}