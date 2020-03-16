class StartupMessage extends GameEventPlus;

var localized string Stage[8], NotReady, SinglePlayer;
//var sound	Riff;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( (Switch > 1) && (Switch < 5) 
		&& P.ViewTarget != None)	// Uses this to play sound
		P.PlayBeepSound();
// RWS CHANGE: Disable for now
//	else if ( Switch == 7 )
//		P.ClientPlaySound(Default.Riff);
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( (RelatedPRI_1 != None) && (RelatedPRI_1.Level.NetMode == NM_Standalone) )
	{
		if ( Switch < 2 )
			return Default.SinglePlayer;
	}	
	else if ( switch == 1 )
	{
		if ( (RelatedPRI_1 == None) || !RelatedPRI_1.bWaitingPlayer )
			return Default.Stage[0];
		else if ( RelatedPRI_1.bReadyToPlay )
			return Default.Stage[1];
		else
			return Default.NotReady;
	}
	return Default.Stage[Switch];
}

defaultproperties
{
	Lifetime=1
	Stage(0)="Waiting for other players to join..."
	Stage(1)="Waiting for other players to press fire..."
	Stage(2)="The match is about to begin...3"
	Stage(3)="The match is about to begin...2"
	Stage(4)="The match is about to begin...1"
	Stage(5)="The match has begun!"
	Stage(6)="The match has begun!"
	Stage(7)="The match goes into OVERTIME!"
	NotReady="Press %KEY_Fire% when you are ready..."
	SinglePlayer="Press %KEY_Fire% to start"

//	Riff=sound'GameSounds.UT2K3Fanfare11'
}