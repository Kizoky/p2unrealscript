///////////////////////////////////////////////////////////////////////////////
// Extension of mover that allows two possible paths. The first path goes
// from 0 to SecondPathKeyNum-1. The second path goes from SecondPathKeyNum
// to NumKeys-1.
///////////////////////////////////////////////////////////////////////////////
class SplitMover extends Mover
	placeable;

//-----------------------------------------------------------------------------
// External
var () byte		SecondPathKeyNum;		// Key num index that signifies the second path
										// To get half of 8 keys, use 4, so it'll be 0-3, and 4-7.
var () bool		bUsedAsDoor;			// Defaults to true, so it's a door, which means it can be damaged
										// and opened by certain things

var () bool		bFaceToOpen;			// Defaults to false. If true, you have to be facing the door
										// to try to open it.

// Internal.
// Highest key frame yet edited. 
//var byte HighestKeyFrame;
var bool bOpen;		// if the door is completely open
var byte KeyUseMin;	// current min used for second paths
var byte KeyUseMax; // current max
var float UseStayOpenTime; // working version of StayOpenTime;
						// How long to remain open before closing.(copied from StayOpenTime usually)


//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

function PostBeginPlay()
{
	Super.PostBeginPlay();
	KeyUseMin=0;
	KeyUseMax=NumKeys;
}

// Interpolation ended.
// 0 to NumKeys-1
event KeyFrameReached()
{
	local byte OldKeyNum;

	OldKeyNum  = PrevKeyNum;
	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;
	ClientUpdate--;

	// If more than two keyframes, chain them.
	if( KeyNum>KeyUseMin && KeyNum<OldKeyNum )
	{
		// Chain to previous.
		InterpolateTo(KeyNum-1,MoveTime);
	}
	else if( KeyNum<KeyUseMax-1 && KeyNum>OldKeyNum )
	{
		// Chain to next.
		InterpolateTo(KeyNum+1,MoveTime);
	}
	else
	{
		// Finished interpolating.
		AmbientSound = None;
		if ( (ClientUpdate == 0) && (Level.NetMode != NM_Client) )
		{
			RealPosition = Location;
			RealRotation = Rotation;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle when the mover finishes opening.
///////////////////////////////////////////////////////////////////////////////
function FinishedOpening()
{
	Super.FinishedOpening();

	bOpen=true;
}

//-----------------------------------------------------------------------------
// Override functions originally described in mover

// Returns true if the first path should be used, and false for the second path
function bool UseFirstPath(float thedot)
{
	if(thedot > 0)
		return true;
	else
		return false;
}

// Check if locked in the direction your coming
function bool OperateLock(float thedot, Actor Other)
{
	return true;
}

// Picks which of the two possible paths to use, based on direction
// and decide if its unlocked or whatever
function bool PickMoverPathAndCheckLock(Actor Other, vector UseLocation, vector UseRotation)
{
	local float doordot, hingedot;
	local vector arot;
	local vector myrot;
	local bool WasOpened;
	local vector diffvec;

	// First get the direction of the actor hitting you and this mover
	arot = Normal(UseRotation);
	myrot = Normal(vector(Rotation));

	diffvec = Location - UseLocation;
//	log("diffvec "$diffvec);
	hingedot = diffvec Dot myrot;
//	log("new dot "$doordot);
	
	doordot = arot Dot myrot;
//	log("arot "$arot);
//	log("myrot "$myrot);
//	log(self$" doordot "$doordot$" hinge dot "$hingedot);

	// Then decide if the door is locked on this side or whatever
	WasOpened = OperateLock(hingedot, Other);

	if(WasOpened == true)
	{
		// If he's on the right side of the door to operate it, but is
		// facing the wrong way, or vice versa, then don't let it work.
		if(bFaceToOpen
			&& ((doordot >= 0
					&& hingedot < 0)
				|| (doordot < 0
					&& hingedot >= 0)))
			return false;

		// And now pick which path you'll use, depending on hit direction
		if(UseFirstPath(hingedot))
		// Use the first path
		{
			// if you're trying to open it and it's already open
			// We check if it's already open and the key num where you are (if you're 
			// open it'll be at KeyUseMax-1 and then if it's equal to the KeyUseMax
			// we want to set now, which is SecondPathKeyNum;
			if(!(bOpen && KeyNum == SecondPathKeyNum-1))
			{
				KeyUseMin = 0;
				KeyUseMax = SecondPathKeyNum;
			}
			else
				return false;
		}
		else	// use the second path
		{
			// if you're trying to open it and it's already open
			// We check if it's already open and the key num where you are (if you're 
			// open it'll be at KeyUseMax-1 and then if it's equal to the KeyUseMax
			// we want to set now, which is NumKeys;
			if(!(bOpen && KeyNum == NumKeys-1))
			{
				KeyUseMin = SecondPathKeyNum;
				KeyUseMax = NumKeys;
			}
			else
				return false;
		}
		KeyNum = KeyUseMin;
	}

	return WasOpened;
}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;
	InterpolateTo( KeyUseMin+1, MoveTime );
	PlaySound( OpeningSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
	if(bUsedAsDoor)
	{
		// Reset the move time, if the guy kicked it in
		MoveTime = default.MoveTime;
	}

	bOpen=false;
	bOpening = false;
	bDelaying = false;
	InterpolateTo( Max(KeyUseMin,KeyNum-1), MoveTime );
	PlaySound( ClosingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
}

///////////////////////////////////////////////////////////////////////////////
// Player kicked door in
///////////////////////////////////////////////////////////////////////////////
function KickedIn( actor Other )
{
	if(bUsedAsDoor)
	{
		// Increase move time, so the door will open faster, because we're kicking it in
		MoveTime = default.MoveTime/2;

		Bump(Other);
	}
}

///////////////////////////////////////////////////////////////////////////////
// When bumped by player.
///////////////////////////////////////////////////////////////////////////////
function Bump( actor Other )
{
	local pawn  P;

	P = Pawn(Other);

	if(Other != None)
		PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation));

	if ( bUseTriggered && (P != None) && !P.IsHumanControlled() && P.IsPlayerPawn() )
	{
		Trigger(P,P);
		P.Controller.WaitForMover(self);
	}	
	if ( (BumpType != BT_AnyBump) && (P == None) )
		return;
	if ( (BumpType == BT_PlayerBump) && !P.IsPlayerPawn() )
		return;
	if ( (BumpType == BT_PawnBump) && P.bAmbientCreature )
		return;
	TriggerEvent(BumpEvent, self, P);

	if ( (P != None) && P.IsPlayerPawn() )
		TriggerEvent(PlayerBumpEvent, self, P);
}

///////////////////////////////////////////////////////////////////////////////
// Open when stood on, wait, then close.
///////////////////////////////////////////////////////////////////////////////
state() StandOpenTimed
{
	function Attach( actor Other )
	{
		local pawn  P;

		P = Pawn(Other);
		if ( (BumpType != BT_AnyBump) && (P == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !P.IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) 
			&& (Other != None 
				&& Other.Mass < 10) )
			return;
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		SavedTrigger = None;

		GotoState( 'StandOpenTimed', 'Open' );
	}
}

// Open when bumped, wait, then close.
state() BumpOpenTimed
{
	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) 
			&& (Pawn(Other) == None) 
			&& Other != None)
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) 
			&& (Other != None 
				&& Other.Mass < 10) )
			return;
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		Global.Bump( Other );
		SavedTrigger = None;
		Instigator = Pawn(Other);
		Instigator.Controller.WaitForMover(self);
		GotoState( 'BumpOpenTimed', 'Open' );
	}
}

// When triggered, open, wait, then close.
state() TriggerOpenTimed
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerOpenTimed', 'Open' );
	}
}

//=================================================================
// Other Mover States

// Toggle when triggered.
state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		if( KeyNum==0 || KeyNum<PrevKeyNum )
			GotoState( 'TriggerToggle', 'Open' );
		else
			GotoState( 'TriggerToggle', 'Close' );
	}
}

// Open when triggered, close when get untriggered.
state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		GotoState( 'TriggerControl', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		numTriggerEvents--;
		if ( numTriggerEvents <=0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = Other;
			Instigator = EventInstigator;
			SavedTrigger.BeginEvent();
			GotoState( 'TriggerControl', 'Close' );
		}
	}
}

// Start pounding when triggered.
state() TriggerPound
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		numTriggerEvents++;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState( 'TriggerPound', 'Open' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		numTriggerEvents--;
		if ( numTriggerEvents <= 0 )
		{
			numTriggerEvents = 0;
			SavedTrigger = None;
			Instigator = None;
			GotoState( 'TriggerPound', 'Close' );
		}
	}
}

//-----------------------------------------------------------------------------
// Bump states.


// Open when bumped, close when reset.
state() BumpButton
{
	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) 
			&& (Pawn(Other) == None) 
			&& Other != None)
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early
		
		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		if(Instigator != None)
			Instigator.Controller.WaitForMover(self);
		GotoState( 'BumpButton', 'Open' );
	}
}

///////////////////////////////////////////////////////////////////////////////
// Open when bumped and already closed. Close when bumped and already open
///////////////////////////////////////////////////////////////////////////////
state() BumpToggle
{
	function CheckForPlayer(bool bThePlayer)
	{
		bSlave=false;
		UseStayOpenTime = StayOpenTime;
		// STUB, handled in next state
	}

	function Bump( actor Other )
	{
		// Only do this if fully closed or fully open
		if(//!bOpen && 
			!bClosed)
		{
			return;
		}
		if ( (BumpType != BT_AnyBump) 
			&& (Pawn(Other) == None) 
			&& Other != None)
			return;
		if ( (BumpType == BT_PlayerBump) 
			&& Other != None
			&& !Pawn(Other).IsPlayerPawn() )
			return;
		if ( (BumpType == BT_PawnBump) 
			&& (Other != None
				&& Other.Mass < 10) )
			return;
		if(Other != None
			&& PickMoverPathAndCheckLock(Other, Other.Location, vector(Other.Rotation)) == false)
			return; // quit early

		if(Other != None)
			CheckForPlayer(Pawn(Other).IsPlayerPawn());

		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		if(Instigator != None)
			Instigator.Controller.WaitForMover(self);

		if(bOpen)
		{
			GotoState( GetStateName(), 'Close' );
		}
		else if(bClosed)
		{
			GotoState( GetStateName(), 'Open' );
		}
	}
	function BeginEvent()
	{
		bSlave=true;
	}
	function EndEvent()
	{
		bSlave     = false;
		Instigator = None;
		GotoState( GetStateName(), 'Close' );
	}
Open:
	bClosed = false;
	Disable( 'Bump' );
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Sleep( UseStayOpenTime );
	Instigator = None;
	if( bTriggerOnceOnly )
		GotoState('');
	if( bSlave )
		Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
}

///////////////////////////////////////////////////////////////////////////////
// Player: Open when bumped and already closed. Close when bumped and already open
// Pawn: bump open, StayOpenTime till it closes automatically.
///////////////////////////////////////////////////////////////////////////////
state() BumpPlayerStandOpenTimedPawn extends BumpToggle
{
	function CheckForPlayer(bool bThePlayer)
	{
			bSlave=false;
			UseStayOpenTime = StayOpenTime;
			/*
		// The player bumps and sends it open, and it stays open
		if(bThePlayer)
		{
			bSlave=true;
			UseStayOpenTime=0;
		}
		else
		{
			// Non-players bumps it open, and it will close after this amount of time
			bSlave=false;
			UseStayOpenTime = StayOpenTime;
		}
		*/
	}
}

defaultproperties
{
	bUsedAsDoor=true
	bFaceToOpen=false
}