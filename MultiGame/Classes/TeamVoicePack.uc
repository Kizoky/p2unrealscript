//=============================================================================
// TeamVoicePack.
//=============================================================================
class TeamVoicePack extends VoicePack
	abstract;

var() Sound NameSound[4]; // leader names

var() Sound AckSound[16]; // acknowledgement sounds
var() string AckString[16];
var() string AckAbbrev[16];
var() int numAcks;

var() Sound FFireSound[16];
var() string FFireString[16];
var() string FFireAbbrev[16];
var() int numFFires;

var() Sound TauntSound[32];
var() string TauntString[32];
var() string TauntAbbrev[32];
var() int numTaunts;
var() byte MatureTaunt[32];
var   float Pitch;

var String LeaderSign[4];

/* Orders (in same order as in Orders Menu 
	0 = Defend, 
	1 = Hold, 
	2 = Attack, 
	3 = Follow, 
	4 = FreeLance
*/
var() Sound OrderSound[16];
var() localized string OrderString[16];
var() localized string OrderAbbrev[16];

var string CommaText;

/* Other messages - use passed messageIndex
	0 = Base Undefended
	1 = Get Flag
	2 = Got Flag
	3 = Back up
	4 = Im Hit
	5 = Under Attack
	6 = Man Down
*/
var() Sound OtherSound[32];
var() string OtherString[32];
var() string OtherAbbrev[32];
var() byte OtherDelayed[32];

var Sound Phrase[8];
var int PhraseNum;
var string DelayedResponse;
var bool bDelayedResponse;
var PlayerReplicationInfo DelayedSender;

function string GetCallSign( PlayerReplicationInfo P )
{
	if ( P == None )
		return "";
	if ( (Level.NetMode == NM_Standalone) && (P.TeamID == 0) )
		return LeaderSign[P.Team.TeamIndex];
	else
		return P.PlayerName;
}

function BotInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local int m;
	local Sound MessageSound;

	if ( messagetype == 'ACK' )
		SetAckMessage(Rand(NumAcks), Recipient, MessageSound);
	else
	{
		SetTimer(0.1, false);
		if ( recipient != None )
		{
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[0] = NameSound[recipient.Team.TeamIndex];
				m = 1;
			}
			DelayedResponse = GetCallSign(Recipient)$CommaText;
		}	
		else
			m = 0;
		if ( messagetype == 'FRIENDLYFIRE' )
			SetFFireMessage(Rand(NumFFires), Recipient, MessageSound);
		else if ( (messagetype == 'AUTOTAUNT') || (messagetype == 'TAUNT') )
			SetTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'ORDER' )
			SetOrderMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetOtherMessage(messageIndex, Recipient, MessageSound);

		Phrase[m] = MessageSound;
	}
}

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local int m;
	local Sound MessageSound;

	DelayedSender = Sender;
	bDelayedResponse = true;

	if ( Sender.bBot )
	{
		BotInitialize(Sender, Recipient, messagetype, messageIndex);
		return;
	}

	SetTimer(0.6, false);

	if ( messagetype == 'ACK' )
		SetClientAckMessage(messageIndex, Recipient, MessageSound);
	else
	{
		if ( recipient != None )
		{
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[0] = NameSound[recipient.Team.TeamIndex];
				m = 1;
			}
			DelayedResponse = GetCallSign(Recipient)$CommaText;
		}
		else if ( (messageType == 'OTHER') && (messageIndex == 9) )
		{
			Phrase[0] = NameSound[Sender.Team.TeamIndex];
			m = 1;
		}
		else
			m = 0;
		if ( messagetype == 'FRIENDLYFIRE' )
			SetClientFFireMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'TAUNT' )
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'AUTOTAUNT' )
		{
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
			SetTimer(1, false);
		}
		else if ( messagetype == 'ORDER' )
			SetClientOrderMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetClientOtherMessage(messageIndex, Recipient, MessageSound);
	}
	Phrase[m] = MessageSound;
}

function SetClientAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numAcks-1);

	if (Recipient != None)
		DelayedResponse = AckString[messageIndex]$CommaText$GetCallsign(Recipient);
	else
		DelayedResponse = AckString[messageIndex];

	MessageSound = AckSound[messageIndex];

	if ( (Recipient != None) && (Level.NetMode == NM_Standalone) 
		&& (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[Recipient.Team.TeamIndex];
	}
}

function SetAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	DelayedResponse = AckString[messageIndex]$CommaText$GetCallSign(recipient);
	SetTimer(2 + FRand(), false); // wait for initial order to be spoken
	Phrase[0] = AckSound[messageIndex];
	if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
		Phrase[1] = NameSound[recipient.Team.TeamIndex];
}

function SetClientFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numFFires-1);

	DelayedResponse = DelayedResponse$FFireString[messageIndex];
	MessageSound = FFireSound[messageIndex];
}

function SetFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	DelayedResponse = DelayedResponse$FFireString[messageIndex];
	MessageSound = FFireSound[messageIndex];
}

function SetClientTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);
	DelayedResponse = DelayedResponse$TauntString[messageIndex];
	MessageSound = TauntSound[messageIndex];
}

function SetTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	DelayedResponse = DelayedResponse$TauntString[messageIndex];
	MessageSound = TauntSound[messageIndex];
	SetTimer(1.0, false);
}

function SetClientOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	DelayedResponse = DelayedResponse$OrderString[messageIndex];
	MessageSound = OrderSound[messageIndex];
}

function SetOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	if ( messageIndex == 2 )
	{
		if ( Level.Game.IsA('CTFGame') )
			messageIndex = 10;
	}
	else if ( messageIndex == 4 )
	{
		if ( FRand() < 0.4 )
			messageIndex = 11;
	}
	DelayedResponse = DelayedResponse$OrderString[messageIndex];
	MessageSound = OrderSound[messageIndex];
}

// for Voice message popup menu - since order names may be replaced for some game types
static function string GetOrderString(int i, string GameType )
{
	if ( i > 9 )
		return ""; //high index order strings are alternates to the base orders 
	if (i == 2)
	{
		if (GameType == "Capture the Flag")
		{
			if ( Default.OrderAbbrev[10] != "" )
				return Default.OrderAbbrev[10];
			else
				return Default.OrderString[10];
		} else if (GameType == "Domination") {
			if ( Default.OrderAbbrev[11] != "" )
				return Default.OrderAbbrev[11];
			else
				return Default.OrderString[11];
		}
	}

	if ( Default.OrderAbbrev[i] != "" )
		return Default.OrderAbbrev[i];

	return Default.OrderString[i];
}

function SetClientOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	DelayedResponse = DelayedResponse$OtherString[messageIndex];
	MessageSound = OtherSound[messageIndex];
}

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	if ( OtherDelayed[messageIndex] != 0 )
		SetTimer(3 + FRand(), false); // wait for initial request to be spoken
	DelayedResponse = DelayedResponse$OtherString[messageIndex];
	MessageSound = OtherSound[messageIndex];
}

function Timer()
{
	local name MessageType;
	local PlayerController PlayerOwner;

	PlayerOwner = PlayerController(Owner);
	if ( bDelayedResponse )
	{
		bDelayedResponse = false;
		if ( PlayerOwner != None )
		{
			if ( PlayerOwner.GameReplicationInfo.bTeamGame 
				 && (PlayerOwner.PlayerReplicationInfo.Team == DelayedSender.Team) )
				MessageType = 'TeamSay';
			else
				MessageType = 'Say';
			PlayerOwner.TeamMessage(DelayedSender, DelayedResponse, MessageType);
		}
	}
	if ( Phrase[PhraseNum] != None )
	{
		if ( Level.TimeSeconds - PlayerOwner.LastPlaySound > 2 ) 
		{
			if ( (PlayerOwner.ViewTarget != None) )
			{
				PlayerOwner.ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0,,,Pitch,false);
			}
			else
			{
				PlayerOwner.PlaySound(Phrase[PhraseNum], SLOT_Interface, 16.0,,,Pitch,false);
			}
		}
		if ( Phrase[PhraseNum+1] == None )
			Destroy();
		else
		{
			SetTimer(GetSoundDuration(Phrase[PhraseNum]), false);
			PhraseNum++;
		}
	}
	else 
		Destroy();
}

function PlayerSpeech( name Type, int Index, int Callsign )
{
	local name SendMode;
	local PlayerReplicationInfo Recipient;
	local Controller C;

	switch (Type)
	{
		case 'ACK':					// Acknowledgements
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 'FRIENDLYFIRE':		// Friendly Fire
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 'ORDER':				// Orders
			SendMode = 'TEAM';		// Only send to team.
			if (Index == 2)
			{
				if (Level.Game.IsA('CTFGame'))
					Index = 10;
				if (Level.Game.IsA('Domination'))
					Index = 11;
			}
			if ( PlayerController(Owner).GameReplicationInfo.bTeamGame )
			{
				if ( Callsign == -1 )
					Recipient = None;
				else {
					for ( C=Level.ControllerList; C!=None; C=C.NextController )
						if ( C.bIsPlayer && (C.PlayerReplicationInfo.TeamId == Callsign)
							&& (C.PlayerReplicationInfo.Team == PlayerController(Owner).PlayerReplicationInfo.Team) )
						{
							Recipient = C.PlayerReplicationInfo;
							break;
						}
				}
			}
			break;
		case 'TAUNT':				// Taunts
			SendMode = 'GLOBAL';	// Send to all teams.
			Recipient = None;		// Send to everyone.
			break;
		case 'OTHER':				// Other
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
	}
	if (!PlayerController(Owner).GameReplicationInfo.bTeamGame)
		SendMode = 'GLOBAL';  // Not a team game? Send to everyone.

	Controller(Owner).SendVoiceMessage( Pawn(Owner).PlayerReplicationInfo, Recipient, Type, Index, SendMode );
}

static function string GetAckString(int i)
{
	if ( Default.AckAbbrev[i] != "" )
		return Default.AckAbbrev[i];

	return default.AckString[i];
}

static function string GetFFireString(int i)
{
	if ( default.FFireAbbrev[i] != "" )
		return default.FFireAbbrev[i];

	return default.FFireString[i];
}

static function string GetTauntString(int i)
{
	if ( default.TauntAbbrev[i] != "" )
		return default.TauntAbbrev[i];
	
	return default.TauntString[i];
}

static function string GetOtherString(int i)
{
	if ( Default.OtherAbbrev[i] != "" )
		return default.OtherAbbrev[i];
	
	return default.OtherString[i];
}

DefaultProperties
{
	LeaderSign(0)="Red Leader"
	LeaderSign(1)="Blue Leader"
	LeaderSign(2)="Green Leader"
	LeaderSign(3)="Gold Leader"
	LifeSpan=10.0
	CommaText=", "
	Pitch=+1.0
}