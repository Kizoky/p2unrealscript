class ACTION_MoveStaticMesh extends LatentScriptedAction;

struct SKey
	{
	var() Vector			RelativeLocation;
	var() Rotator			RelativeRotation;
	var() float				DelayFromPrevKey;
	var() float				Duration;
	var float				StartTime;
	var float				EndTime;
	};

var(Action) name			TargetTag;
var(Action) array<SKey>		Keys;
var(Action) bool			bRestoreOriginalInfoAtEnd;

var transient MoveableStaticMeshActor	MSMA;
var vector					OriginalLoc;
var rotator					OriginalRot;
var float					TotalTime;
var float					ElapsedTime;
var int						KeyNum;
var bool					bFinished;

function GetMSMA(ScriptedController C)
	{
	ForEach C.AllActors(class'MoveableStaticMeshActor', MSMA, TargetTag)
		break;
	}

function bool InitActionFor(ScriptedController C)
	{
	local int i;

	GetMSMA(C);
	if (MSMA != None && !MSMA.bDeleteMe)
		{
		KeyNum = 0;

		if (bRestoreOriginalInfoAtEnd)
			{
			OriginalLoc = MSMA.Location;
			OriginalRot = MSMA.Rotation;
			}

		MSMA.SetCollision(False, False, False);
		MSMA.bCollideWorld = false;

		// Calculate starting/ending times (and total time)
		TotalTime = 0.0;
		for (i = 0; i < Keys.length; i++)
			{
			Keys[i].StartTime = TotalTime + Keys[i].DelayFromPrevKey;
			TotalTime += Keys[i].Duration;
			Keys[i].EndTime = TotalTime;
			}

		if (TotalTime > 0.0)
			{
			C.CurrentAction = self;
			C.SetTimer(TotalTime, false);
			}
		}

	// Return true if totaltime is above 0, otherwise there's nothing to wait for
	return TotalTime > 0.0;
	}

function bool StillTicking(ScriptedController C, float DeltaTime)
	{
	local bool bStartNext;
	local float CurrentPercent;

	if (MSMA == None)
		GetMSMA(C);

	ElapsedTime += DeltaTime;

	do {
		bStartNext = false;

		if (ElapsedTime >= Keys[KeyNum].StartTime)
			{
			if (ElapsedTime < Keys[KeyNum].EndTime)
				CurrentPercent = (ElapsedTime - Keys[KeyNum].StartTime) / Keys[KeyNum].Duration;
			else
				{
				CurrentPercent = 1.0;
				bStartNext = true;
				}

			MSMA.SetPhysics(PHYS_None);
			MSMA.SetLocation( MSMA.Location + (Keys[KeyNum].RelativeLocation * CurrentPercent) );
			MSMA.SetRotation( MSMA.Rotation + (Keys[KeyNum].RelativeRotation * CurrentPercent) );
			}

		if (bStartNext)
			{
			KeyNum++;
			if (KeyNum == Keys.length)
				bFinished = true;
			}

		} until (!bStartNext || bFinished);

	if (bFinished && bRestoreOriginalInfoAtEnd)
		{
		MSMA.SetLocation(OriginalLoc);
		MSMA.SetRotation(OriginalRot);
		}

	// Keep ticking as long as we're not finished
	return !bFinished;
	}

function bool TickedAction()
	{
	return TotalTime > 0.0;
	}

function bool CompleteWhenTimer()
	{
	return TotalTime > 0.0;
	}

function string GetActionString()
	{
	return ActionString@TargetTag;
	}

defaultproperties
	{
	ActionString="MoveStaticMesh"
	}