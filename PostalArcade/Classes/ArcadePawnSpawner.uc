class ArcadePawnSpawner extends AWPawnSpawner;

var(PawnSpawner) class<P2Dialog> InitDialogClass;
var(PawnSpawner) array< class<Inventory> > InitBaseEquipment;

var P2Pawn Player;

// Modified so it doesn't trigger an event everytime it's triggered.
function Trigger(Actor Other, Pawn EventInstigator)
{
	if (bSetActiveAfterTrigger)
	{
		bSetActiveAfterTrigger = false;
		bActive = true;

        if (bMonitorWorld && bActive)
			InitMonitor();

        if (!bDeleteMe)
		{
			if (PostTriggerStartTime > 0.0)
				SetTimer(PostTriggerStartTime, false);
			else
				DoSpawn();
		}
		else
			return;
	}
	else
	{
		GotoState('');

		if (ClassIsChildOf(Other.class, GetSpawnClass()))
			TotalAlive--;

		if (SpawnRate != 0)
			SetTimer(GetRate(), false);
		else
			DoSpawn();
	}
}

// Modified to do a trace to double check the player doesn't have a line
// of sight to the spawner.
function DoSpawn()
{
    local vector EndTrace, StartTrace;
    local P2Pawn Player;

    if (!bSpawnWhenNotSeen)
    {
        Super.DoSpawn();
        return;
    }

    if (Player == None)
    {
        foreach AllActors(class'P2Pawn', Player)
            if (PlayerController(Player.Controller) != None)
                break;
    }

    if (Player != None)
    {
        StartTrace = Player.Location + Player.EyePosition();
        EndTrace = StartTrace + vector(rotator(Location - Player.Location)) * VSize(Location - Player.Location);

        if (!FastTrace(EndTrace, StartTrace))
            Super.DoSpawn();
    }
}

// Added support for a new DialogClass and overriding BaseEquipment.
function SpecificInits(Actor Spawned)
{
    local int i;
    local P2Pawn CheckPawn;

    CheckPawn = P2Pawn(Spawned);

    if (CheckPawn != None)
    {
        if (InitDialogClass != None)
            CheckPawn.DialogClass = InitDialogClass;

        for (i=0;i<CheckPawn.BaseEquipment.length;i++)
            if (InitBaseEquipment[i] != None)
                CheckPawn.BaseEquipment[i].WeaponClass = InitBaseEquipment[i];
    }

    Super.SpecificInits(Spawned);

    TriggerEvent(Event, self, Instigator);
}

defaultproperties
{
}
