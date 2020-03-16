class TimeMessage extends GameEventPlus;

var localized string TimeMessage[16];
var Sound TimeSound[16];

static function string GetString(
	PlayerController P,
	optional int N,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	N = Static.TranslateSwitch(N);
	if ( N > 0 )
		return Default.TimeMessage[N];
}

/* Translate the number of seconds passed in to the appropriate message index
*/
static function int TranslateSwitch(int N)
{	
	if ( N <= 10 )
		return (N-1);

	if ( N == 30 )
		return 10;

	N = N/60;
	if ( (N > 0) && (N < 6) )
		return (N + 10);

	return -1;
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int N,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	N = Static.TranslateSwitch(N);
	if ( N > 0 )
		MpPlayer(P).PlayAnnouncement(default.TimeSound[N],1,true);
}

defaultproperties
{
	Lifetime=1
	 TimeMessage(15)="5 minutes left in the game!"
	 TimeMessage(14)="4 minutes left in the game!"
	 TimeMessage(13)="3 minutes left in the game!"
	 TimeMessage(12)="2 minutes left in the game!"
	 TimeMessage(11)="1 minute left in the game!"
	 TimeMessage(10)="30 seconds left!"
	 TimeMessage(9)="10 seconds left!"
	 TimeMessage(8)="9..."
	 TimeMessage(7)="8..."
	 TimeMessage(6)="7..."
	 TimeMessage(5)="6..."
	 TimeMessage(4)="5 seconds and counting..."
	 TimeMessage(3)="4..."
	 TimeMessage(2)="3..."
	 TimeMessage(1)="2..."
	 TimeMessage(0)="1..."
	 TimeSound(15)=sound'MpAnnouncer.Announcer5min'
	 TimeSound(14)=None
	 TimeSound(13)=sound'MpAnnouncer.Announcer3min'
	 TimeSound(12)=None
	 TimeSound(11)=sound'MpAnnouncer.Announcer1min'
	 TimeSound(10)=sound'MpAnnouncer.Announcer30sec'
	 TimeSound(9)=sound'MpAnnouncer.Announcer10'
	 TimeSound(8)=sound'MpAnnouncer.Announcer9'
	 TimeSound(7)=sound'MpAnnouncer.Announcer8'
	 TimeSound(6)=sound'MpAnnouncer.Announcer7'
	 TimeSound(5)=sound'MpAnnouncer.Announcer6'
	 TimeSound(4)=sound'MpAnnouncer.Announcer5'
	 TimeSound(3)=sound'MpAnnouncer.Announcer4'
	 TimeSound(2)=sound'MpAnnouncer.Announcer3'
	 TimeSound(1)=sound'MpAnnouncer.Announcer2'
	 TimeSound(0)=sound'MpAnnouncer.Announcer1'
}