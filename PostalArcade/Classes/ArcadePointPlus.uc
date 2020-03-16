///////////////////////////////////////////////////////////////////////////////
// ArcadePoint
// By: Kamek
// For: AWP
//
// Arcade points are used to send the player to special bonus levels.
// The player needs tokens to use this. When the player walks up to the machine
// the token class is selected for him and the machine asks for a token.
// The player activates the token inventory to give the token to the machine.
// Once the proper number of tokens have been inserted, the machine will send
// the player to the bonus level specified by URL.
//
// If bActive is false the arcade point will not work. Set bSetActiveOnTrigger
// and the arcade point will set bActive when triggered.
///////////////////////////////////////////////////////////////////////////////
class ArcadePointPlus extends Keypoint
	placeable;

///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var(Token) int TokensRequired;				// Number of tokens needed to play
var(Token) class<P2PowerupInv> RequiredTokenClass;
											// Class of tokens required
											// Some arcades may use different
											// tokens
var(ArcadeGame) string URL;					// Bonus level to send player to
var(ArcadeGame) bool bTakeHisInventory;		// Whether to take the player's
											// inventory at the new level
var(ArcadeGame) bool bActive;				// Disabled if false
var(ArcadeGame) bool bSetActiveOnTrigger;	// Sets active when triggered

var(ArcadeSounds) Sound GimmeAToken;
//var(ArcadeSounds) Sound TokenTaken;
var(ArcadeSounds) Sound ReadyToPlay;

var(Local) localized string InsertMoneyMessage;
var(Local) localized string NoMoneyMessage;
var(Local) localized string GetReadyMessage;

///////////////////////////////////////////////////////////////////////////////
// Internal
///////////////////////////////////////////////////////////////////////////////
//var int TokensNeeded;				// Number of tokens needed to play
									// This is decreased when the player
									// inserts tokens. When it reaches 0 we
									// are satisfied and will allow the bonus
									// stage to begin.

var PlayerController OurPlayer;		// Player controller we're dealing with
var bool bAlreadyPaid;				// Already paid off, don't accept any more

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
//	TokensNeeded = TokensRequired;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Trigger(Actor Other, Pawn EventInstigator)
{
	if (bSetActiveOnTrigger)
		bActive=True;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
singular event Touch(Actor Other)
{
	if (P2Pawn(Other) != None
		&& P2Player(Pawn(Other).Controller) != None
		&& bActive)
	{
		P2Player(Pawn(Other).Controller).SwitchToThisPowerup(RequiredTokenClass.Default.InventoryGroup, RequiredTokenClass.Default.GroupOffset);
		PlaySound(GimmeAToken);
		PlayerController(Pawn(Other).Controller).ClientMessage(InsertMoneyMessage);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function bool AcceptToken(PlayerController Player, P2PowerupInv Token)
{
	if (bActive)
	{
		if (Token.Amount >= TokensRequired && !bAlreadyPaid)
		{
			PlaySound(ReadyToPlay);
			OurPlayer = Player;
			SetTimer(GetSoundDuration(ReadyToPlay) + 1.00, false);
			Player.ClientMessage(GetReadyMessage);
			bAlreadyPaid = true;
			return true;
		}
		else if (!bAlreadyPaid)
		{
//			PlaySound(TokenTaken);
			Player.ClientMessage(NoMoneyMessage);
			return false;
		}

		return false;
	}
	else
		return false;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
event Timer()
{
	if (P2GameInfoSingle(Level.Game) != None && URL != "")
	{
		P2GameInfoSingle(Level.Game).TheGameState.bTakePlayerInventory = bTakeHisInventory;
		P2GameInfoSingle(Level.Game).SendPlayerTo(OurPlayer, URL);
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     TokensRequired=1
     RequiredTokenClass=Class'ArcadeMoneyInv'
     bActive=True
     GimmeAToken=Sound'arcade.arcade_13'
     ReadyToPlay=Sound'arcade.arcade_138'
     InsertMoneyMessage="Insert money to play!"
     NoMoneyMessage="You don't have enough money!"
     GetReadyMessage="Get ready to play!"
     bStatic=False
     CollisionRadius=40.000000
     CollisionHeight=40.000000
     bCollideActors=True
}
