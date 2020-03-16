class CTFFlag extends GameObject;

var byte					TeamNum;
var MpTeamInfo				Team;
var MpPawn					OldHolder;
var GameReplicationInfo		GRI;
var Sound					TakenSound;
var Sound					DroppedSound;
var Sound					ReturnedSound;
var Mesh					CarriedMesh;		// Mesh for flag on guy

replication
{
	reliable if ( Role == ROLE_Authority )
		Team;
}

/* RWS CHANGE: We don't dynamically update the flag textures so we don't need this stuff
simulated function UpdateForTeam()
{
	if ( (GRI != None) && (TeamNum < 2) && (MpTeamInfo(GRI.Teams[TeamNum]) != None) && (MpTeamInfo(GRI.Teams[TeamNum]).TeamTexture != None) )
	    TexScaler(Combiner(Shader(FinalBlend(Skins[0]).Material).Diffuse).Material2).Material = GRI.TeamSymbols[TeamNum];
}

simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
	UpdateForTeam();
}	
	
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);
}
*/

// State transitions
function SetHolder(Controller C)
{
	local CTFSquadAI S;
	
	// AI Related
	if ( Bot(C) != None )
		S = CTFSquadAI(Bot(C).Squad);
	else if ( PlayerController(C) != None )
		S = CTFSquadAI(MpTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	if ( S != None )
		S.EnemyFlagTakenBy(C);

	Super.SetHolder(C);
	
    C.SendMessage(None, 'OTHER', C.GetMessageIndex('GOTENEMYFLAG'), 10, 'TEAM');	
}

function Drop(vector newVel)
{
    OldHolder = Holder;

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

    Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

    Super.Drop(Velocity);
}


// Helper funcs
function bool SameTeam(Controller c)
{
    if (c == None || c.PlayerReplicationInfo.Team != Team)
        return false;

    return true;
}

function bool ValidHolder(Actor Other)
{
    local Controller c;

    if (!Super.ValidHolder(Other))
        return false;

    c = Pawn(Other).Controller;
	if (SameTeam(c))
	{
        SameTeamTouch(c);
        return false;
	}

    return true;
}

function SameTeamTouch(Controller c)
{
}

// Events
function Landed(vector HitNormal)
{
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	Super.Landed(HitNormal);
}

// Logging
function LogReturned();

function LogDropped()
{
	BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, Team );
	MpGameInfo(Level.Game).GameEvent("flag_dropped",""$Team.TeamIndex, Holder.PlayerReplicationInfo);
}

singular simulated function BaseChange()
{
	local Sound snd;

	if(Level.NetMode != NM_DedicatedServer)
	{
		if (MpPawn(Base) != None)
			snd = TakenSound;
		else if (StaticMeshActor(Base) != None)
			snd = ReturnedSound;
		else if (Base == None)
			snd = DroppedSound;
		else
			snd = None;

		if (snd != None)
			PlaySound(snd, SLOT_Misc, 1.0, , 100);
		//log(self @ "BaseChange(): Base="$Base$" snd="$snd);
	}

	Super.BaseChange();
}

function CheckPain(); // stub

event FellOutOfWorld()
{
	BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
    SendHome();
}

// States
auto state Home
{
    ignores SendHome, Score, Drop;

    function SameTeamTouch(Controller c)
    {
        local CTFFlag flag;

        if (C.PlayerReplicationInfo.HasFlag == None)
            return;

        // Score!
        flag = CTFFlag(C.PlayerReplicationInfo.HasFlag);
        CTFGame(Level.Game).ScoreFlag(C, flag);
        flag.Score();
		TriggerEvent(HomeBase.Event,HomeBase,C.Pawn);
        if (Bot(C) != None)
            Bot(C).Squad.SetAlternatePath();
    }
        
    function LogTaken(Controller c)
    {
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, Team );
        MpGameInfo(Level.Game).GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
    }

	function Timer()
	{
		if ( VSize(Location - HomeBase.Location) > 10 )
		{
			MpGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
            log(self$" Home.Timer: had to sendhome", 'Error');
			SendHome();
		}
	}

	function BeginState()
	{
        Super.BeginState();
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Home;
		bHidden = true;
		HomeBase.bHidden = false;
		HomeBase.Timer();
		SetTimer(1.0, true);
	}

	function EndState()
	{
        Super.EndState();
		bHidden = false;
		HomeBase.bHidden = true;
		HomeBase.PlayAlarm();
		SetTimer(0.0, false);
	}
}

state Held
{
    ignores SetHolder, SendHome;

	function Timer()
	{
		if (Holder == None)
        {
            log(self$" Held.Timer: had to sendhome", 'Error');
			MpGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			SendHome();
        }
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_HeldEnemy;
        Super.BeginState();
		SetTimer(10.0, true);
		LinkMesh(CarriedMesh);
		LoopAnim('held');
		SimAnim.bAnimLoop = true;
	}
}


state Dropped
{
   ignores Drop;

	function SameTeamTouch(Controller c)
	{
		// Mutators can make it so it will only return after the timer, otherwise,
		// the same team touch returns the flag home
		if(!bNoTouchReturns)
		{
			// returned flag
			CTFGame(Level.Game).ScoreFlag(C, self);
			SendHome();
		}
	}

    function LogTaken(Controller c)
    {
        MpGameInfo(Level.Game).GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
    }

    function CheckFit()
    {
	    local vector X,Y,Z;

	    GetAxes(OldHolder.Rotation, X,Y,Z);
	    SetRotation(rotator(-1 * X));
	    if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5)) 
		    && !SetLocation(OldHolder.Location) )
	    {
		    SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		    if ( !SetLocation(OldHolder.Location) )
		    {
                //log(self$" Drop sent flag home", 'Error');
				MpGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
				BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			    SendHome();
			    return;
		    }
	    }
    }

    function CheckPain()
    {
        if (IsInPain())
            timer();
    }

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
	{
        CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		Super.PhysicsVolumeChange(NewVolume);
        CheckPain();
	}

	function BeginState()
	{
		Disable('Touch');
        Level.Game.GameReplicationInfo.FlagState[TeamNum] = EFlagState.FLAG_Down;
        Super.BeginState();
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        SetCollision(true, false, false);
        CheckFit();
        CheckPain();
		SetTimer(MaxDropTime, false);
		LinkMesh(default.Mesh);
		LoopAnim('dropped');
		SimAnim.bAnimLoop = true;
	    Enable('Touch');
	}
    
    function EndState()
    {
        Super.EndState();
		bCollideWorld = false;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
    }
	
	function Timer()
	{
		BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
		MpGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
		Super.Timer();
	}
}

defaultproperties
{
	bReplicateAnimations=true
	bHidden=true
	bStasis=false
	bHome=True
	bStatic=False
//	bUnlit=True
	bCollideActors=True
	bCollideWorld=True
//	bDynamicLight=true
//	LightType=LT_Steady
//	LightEffect=LE_NonIncidence
	LightBrightness=70
	LightHue=40
	LightSaturation=128
	LightRadius=6
//	bFixedRotationDir=True
	Mass=30.000000
	Buoyancy=20.000000
	RotationRate=(Pitch=0,Yaw=65000,Roll=2048)
//	PrePivot=(X=2,Y=0,Z=0.5)
	NetPriority=+00003.000000
	
	MessageClass=class'CTFMessage'
    MaxDropTime=60			// RWS CHANGE: Decided to make this longer
}
