class GameObject extends Decoration
    abstract notplaceable;

var bool            bHome;
var bool            bHeld;
var MpPawn          Holder;
var MpPlayerReplicationInfo HolderPRI;
var GameObjective   HomeBase;
var float           TakenTime;
var float           MaxDropTime;
var bool            bDisabled;
var Controller FirstTouch;			// Who touched this objective first
var array<Controller> Assists;		// Who tocuhes it after
var name 	GameObjBone;
var TeamInfo OldTeam;

var bool bNoTouchReturns; // False by default, mutators can make it true--for Snatch
						// it means that when the girl is dropped she won't return when you touch her
						// she'll only return after the time limit (30 seconds or so).

replication
{
    reliable if (Role == ROLE_Authority)
        bHome, bHeld, HolderPRI;
}

// Initialization
function PostBeginPlay()
{
    //log(self$" PostBeginPlay owner="$owner, 'GameObject');

    HomeBase = GameObjective(Owner);
    SetOwner(None);

    Super.PostBeginPlay();
}

// State transitions
function SetHolder(Controller C)
{
	local int i;

	//log(self$" setholder c="$c$" c.Pawn="$C.Pawn, 'GameObject');
    LogTaken(c);
    Holder = MpPawn(C.Pawn);
    Holder.SpawnTime = -100000;
    HolderPRI = MpPlayerReplicationInfo(Holder.PlayerReplicationInfo);
    C.PlayerReplicationInfo.HasFlag = self;

    GotoState('Held');

	// AI Related	
	C.MoveTimer = -1;
	Holder.MakeNoise(2.0);

	// Track First Touch
	
	if (FirstTouch == None)
		FirstTouch = C; 

	// Track Assists

	for (i=0;i<Assists.Length;i++)
		if (Assists[i] == C)
		  return;
	
	Assists.Length = Assists.Length+1;
  	Assists[Assists.Length-1] = C;

}

function Score()
{
    //log(self$" score holder="$holder, 'GameObject');
    Disable('Touch');
    SetLocation(HomeBase.Location);
    SetRotation(HomeBase.Rotation);
    CalcSetHome();
    GotoState('Home');			
}

function Drop(vector newVel)
{
    //log(self$" drop holder="$holder, 'GameObject');

	SetLocation(Holder.Location);
    LogDropped();
    Velocity = newVel;
    GotoState('Dropped');
}

function SendHome()
{
    CalcSetHome();
    GotoState('Home');			
}

function SendHomeDisabled(float TimeOut);

// Helper funcs
protected function CalcSetHome()
{
    local Controller c;

	// AI Related	
    for (c = Level.ControllerList; c!=None; c=c.nextController)
        if (c.MoveTarget == self)
            c.MoveTimer = -1.0;

			
	LogReturned();
				
	// Reset the assists and First Touch
			
	FirstTouch = None;
	
	while (Assists.Length!=0)
	  Assists.Remove(0,1);
}

function ClearHolder()
{
	local int i;
	local GameReplicationInfo GRI;
	
    if (Holder == None)       
        return;

	if ( Holder.PlayerReplicationInfo == None )
	{
		GRI = Level.Game.GameReplicationInfo;
		for (i=0; i<GRI.PRIArray.Length; i++)
			if ( GRI.PRIArray[i].HasFlag == self )
				GRI.PRIArray[i].HasFlag = None;
	}
	else
		Holder.PlayerReplicationInfo.HasFlag = None;
    Holder = None;
    HolderPRI = None;
}

protected function SetDisable(bool disable)
{
    bDisabled = disable;
    bHidden = disable;
}

function Actor Position()
{
    if (bHeld)
        return Holder;

    if (bHome)
        return HomeBase;

    return self;
}

function bool IsHome()
{
    return false;
}

function bool ValidHolder(Actor other)
{
    local Pawn p;

    if( bDisabled )
        return false;
    //log(self$" ValidHolder other="$other, 'GameObject');

    p = Pawn(other);
    if (p == None || p.Health <= 0 || !p.IsPlayerPawn())
        return false;

    return true;
}

// Events
singular function Touch(Actor Other)
{
    //log(self$" Touch other="$other, 'GameObject');

    if (!ValidHolder(Other))
        return;

    SetHolder(Pawn(Other).Controller);
}

event FellOutOfWorld()
{
    //log(self$" FellOutOfWorld", 'GameObject');
    SendHome();
}

event NotReachableBy(Pawn P)
{
	if (Level.Game.NumBots > 0)
		SendHome();
}

function Landed(vector HitNormall)
{
	local Controller C;

    //log(self$" landed", 'GameObject');
	
    // tell nearby bots about this
/* RWS FIXME: Our old-style bots don't have Retask() function, so no point in doing this
    for (C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if ((C.Pawn != None) && (Bot(C) != None) 
            && (C.RouteGoal != self) && (C.Movetarget != self) 
            && (VSize(C.Pawn.Location - Location) < 1600)
            && C.LineOfSightTo(self) )
        {
			Bot(C).Squad.Retask(Bot(C));	
        }
    }*/
}

singular simulated function BaseChange()
{
    //log(self$" BaseChange, Base="$Base, 'GameObject');
}

// Logging
function LogTaken(Controller c);
function LogDropped();
function LogReturned();

// States
auto state Home
{
    ignores SendHome, Score, Drop;

	function CheckTouching()
	{
		local int i;
		
		for ( i=0; i<Touching.Length; i++ )
			if ( ValidHolder(Touching[i]) )
			{
				SetHolder(Pawn(Touching[i]).Controller);
				return;
			}
	}	

    function bool IsHome()
    {
        return true;
    }

    function BeginState()
    {
        Disable('Touch');
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
        Enable('Touch');
    }

    function EndState()
    {
        bHome = false;
        TakenTime = Level.TimeSeconds;
    }
    
Begin:
	// check if an enemy was standing on the base
	Sleep(0.05);
	CheckTouching();
}

state Held
{
    ignores SetHolder, SendHome;

    function BeginState()
    {
//      bOnlyDrawIfAttached = true;	// RWS FIXME: Merge from UT2003 if object doesn't attach properly
        bHeld = true;
        bCollideWorld = false;
        SetCollision(false, false, false);
        SetLocation(Holder.Location);
        Holder.HoldGameObject(self,GameObjBone);
    }

    function EndState()
    {
        //log(self$" held.endstate", 'GameObject');
//      bOnlyDrawIfAttached = false;  // RWS FIXME: Merge from UT2003 if object doesn't attach properly
        ClearHolder();
        bHeld = false;
        bCollideWorld = true;
        SetCollision(true, false, false);
        SetBase(None);
        SetRelativeLocation(vect(0,0,0));
        SetRelativeRotation(rot(0,0,0));
    }
}

state Dropped
{
    ignores Drop;

    function BeginState()
    {
        SetPhysics(PHYS_Falling);
        SetTimer(MaxDropTime, false);
    }

    function EndState()
    {
        //log(self$" dropped.endstate", 'GameObject');
        SetPhysics(PHYS_None);
    }

    function Timer()
	{
		SendHome();
	}
}

defaultproperties
{
	GameObjBone="Male01 spine1"
    MaxDropTime=25.f
    Physics=PHYS_None
	bUseCylinderCollision=true
	bAlwaysZeroBoneOffset=true
}
