class AWDynaFOV extends Info
	placeable;

var PlayerController MyPC;
var() float CycleBase;
var() float CycleTime;
var() float CycleRange;
var() float TotalTime;
var() float CycleFinal;

var bool bEnabled;
var float Current;
var float Elapsed;
var float Direction;

function BeginPlay()
{
	Disable( 'Tick' );
	Super.BeginPlay();
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	local Controller P;

	for( P = Level.ControllerList; P != None; P = P.nextController)
	{
		if( P.IsA('PlayerController') )
		{
			MyPC = PlayerController(P);
			break;
		}
	}

	Current = CycleBase;
	MyPC.SetFOV(Current);

	if (CycleTime > 0 && CycleRange != 0)
	{
		Elapsed = 0.5;
		Direction = 1;
		Enable( 'Tick' );
		if (TotalTime > 0)
			SetTimer(TotalTime, false);
		bEnabled = true;
	}

	log(self @ "Trigger() MyPC="$MyPC$" Current="$Current);
}

function Tick(float DeltaTime)
{
	if (bEnabled)
	{
		Elapsed += DeltaTime * Direction;

		if (Elapsed > CycleTime || Elapsed < 0.0)
		{
			Direction = -Direction;
			Elapsed += DeltaTime * Direction * 2;
		}

		Current = CycleBase + (sin(((Elapsed / CycleTime) - 0.5) * (2 * 1.5707)) * CycleRange);

		MyPC.SetFOV(Current);
		log(self @ "Tick() Current="$Current);
	}
}

function Timer()
{
	Disable( 'Tick' );

	Current = CycleFinal;
	MyPC.SetFOV(Current);
	log(self @ "Timer() Current="$Current);
}

defaultproperties
{
     CycleBase=100.000000
     CycleTime=1.000000
     CycleRange=35.000000
     TotalTime=10.000000
     CycleFinal=85.000000
}
