/**
 * LeprechaunController
 *
 * AI Controller for Leprechaun Gary. He'll wander around town as normal,
 * however, when he sees the Dude, he'll scream and run away back to his pot
 * of gold.
 */
class LeprechaunController extends P2EAIController;

/** Whether or not we randomize our start location; Used for debugging */
var bool bRandomizeStartLocation;

/** Whether or not we're playing a pain sound, prevents sound overlapping */
var bool bPlayingPainSound;

/** Chances the Leprechaun will spawn; 0.0f = No Chance, 1.0f = Always spawn */
var float LeprechaunSpawnChance;

/** Distance away from the MoveTarget that's considered reached */
var float DestReachedRange;
/** Distance away from the Pot of Gold that Gary should just jump in */
var float PotofGoldReachedRange;

/** Time in econds before Leprechaun Gary "thinks" while Idle */
var float IdleThinkInterval;
/** Time in seconds before Leprechaun Gary "thinks" while Wandering */
var float WanderThinkInterval;
/** Time in seconds before Leprechaun Gary "thinks" while running away */
var float RunToPotThinkInterval;
/** Time in seconds before Leprechaun Gary screams again */
var float RunTauntInterval;

/** List of idle animations for Leprechaun Gary */
var array<AnimInfo> IdleAnims;
/** List of writhing animations for Leprechaun Gary */
var array<AnimInfo> DeathCurlAnims;

/** Animation to play when Leprechaun Gary takes so much damage he falls */
var AnimInfo FallAnim;
/** Animation to play when Leprechaun Gary screams at the sight of the Dude */
var AnimInfo ScreamAnim;
/** Animation to play when Leprechaun Gary jumpts into his pot of gold */
var AnimInfo DiveAnim;

/** Sound to play when Leprechaun Gary has seen the Dude */
var sound ScreamSound;
/** List of sounds that can be played when Leprechaun Gary is picked up */
var array<sound> PickupSounds;
/** List of sounds to play when we're shot */
var array<sound> PainSounds;
/** List of sounds to play to announce we're losing a lot of blood */
var array<sound> DeathCurlSounds;
/** List of sounds to play to taunt the player while running away */
var array<sound> TauntSounds;

/** Random PathNode to walk to */
var PathNode WanderDest;
/** Pot of Gold PathNode that is chosen for Leprechaun Gary to run to */
var PotOfGoldNode PotOfGoldDest;

/** Speed that Leprechaun Gary will move at when just wandering around */
var float WalkSpeed;
/** Speed that Leprechaun Gary will move at when running away from the Dude */
var float RunSpeed;

/** How much smaller Gary is compared to a normal Pawn, used to adjust the
 * movement animation even more
 */
var float GaryAnimHeightScale;
/** Additional scaling to adjust the speed the run animation plays at */
var float RunAnimScale;

/** Time in seconds from the start of the jump till he is fully inside */
var float PotOfGoldJumpTime;
/** Height of the jump into the pot of gold */
var float PotOfGoldJumpHeight;

/** Time in seconds since the start of the jump */
var float PotOfGoldJumpElapsedTime;
/** Location in the world where the Jump would start */
var vector PotOfGoldJumpStart;

/** Leprechaun Gary that this controller corresponds to in the world */
var LeprechaunGary LeprechaunGary;
/** Pawn that is currently being controlled by the player */
var Pawn PostalDude;
/** Me lucky charms! */
var PotOfGold PotOfGold;

/** Returns whether or not Leprechaun Gary has reached his wander destination
 * @return TRUE if Gary has reached his destination; FALSE otherwise
 */
function bool HasReachedWanderDest() {
    return VSize(WanderDest.Location - Pawn.Location) < DestReachedRange;
}

/** Returns whether or not Leprechaun Gary has reached his lucky charms
 * @param TRUE if Gary has reached his lucky charms; FALSE otherwise
 */
function bool HasReachedPotOfGold() {
    return VSize(PotOfGoldDest.Location - Pawn.Location) < PotOfGoldReachedRange;
}

/** Returns the Pot of Gold that can be spawned the farthest away from
 * Leprechaun Gary's current location. This way the player has the longest
 * possible time to weaken Leprechaun Gary enough to catch him
 * TODO: Might result in array out of bounds if list is empty, might fix later
 * @return Pot of Gold node that's the farthest away from Gary
 */
function PotOfGoldNode GetFarthestPotOfGold() {
    local float PathNodeDistance;
    local PotOfGoldNode PathNode, PotOfGoldNode;

    PathNodeDistance = 0.0f;

    foreach AllActors(class'PotOfGoldNode', PathNode) {
        if (VSize(PathNode.Location - Pawn.Location) > PathNodeDistance) {
            PotOfGoldNode = PathNode;
            PathNodeDistance = VSize(PathNode.Location - Pawn.Location);
        }
    }

    return PotOfGoldNode;
}

/** Overriden to grab variables from */
function Possess(Pawn aPawn) {
    local PathNode RandStart;

    super.Possess(aPawn);

    if (FRand() > LeprechaunSpawnChance) {
        aPawn.Destroy();
        Destroy();
    }

    if (LeprechaunGary(aPawn) != none)
        LeprechaunGary = LeprechaunGary(aPawn);
    else
        Destroy();

    if (LeprechaunGary != none)
        LeprechaunGary.LeprechaunController = self;

    if (bRandomizeStartLocation) {
        RandStart = GetRandomPathNode(true);

        if (RandStart != none)
            Pawn.SetLocation(RandStart.Location);
    }

    aPawn.SetPhysics(PHYS_Falling);

    GotoState('Idle');
}

/** Overriden to implement the proper function calls */
function TimerFinished(name ID) {
    switch (ID) {
        case 'IdleThink':
            IdleThink();
            break;
        case 'WanderThink':
            WanderThink();
            break;
        case 'RunThink':
            RunToPotOfGoldThink();
            break;
        case 'RunTaunt':
            PlayTauntSound();
            break;
        case 'PauseTauntTimer':
            bPlayingPainSound = false;
            SetTimerPauseByID('RunTaunt', false);
            break;
    }
}

/** Think logic for Leprechaun Gary should use while idle. He'll basically be
 * looking at the surrounding Pawns for the Postal Dude
 */
function IdleThink() {
    //LogDebug("IdleThink() method called...");

    CheckSurroundingPawns();
}

/** Think logic for Leprechaun Gary should use while wandering around. While
 * wandering, he'll basically check if he's reached his destination yet and
 * look out for the player
 */
function WanderThink() {
    //LogDebug("WanderThink() method called...");

    CheckSurroundingPawns();

    if (HasReachedWanderDest())
        GotoState('Idle');
}

/** Think logic for Leprechaun Gary while he's running away to his pot of gold.
 * In this state, he'll basically be checking when he's close enough to dive
 * back into his pot of gold.
 */
function RunToPotOfGoldThink() {
    if (HasReachedPotOfGold())
        GotoState('JumpIntoPotOfGold');
}

/** Scream at the top of our tiny lungs at the sight of the Dude */
function PlayScreamSound() {
    Pawn.PlaySound(ScreamSound, SLOT_Talk, 1.0f, false, 300.0f,
                   LeprechaunGary.VoicePitch);
}

/** Plays a general pain grunting sound or taunt as well as pause the taunt
 * timer so we don't have overriding sounds
 */
function PlayPainSound() {
    local int i;

    if (bPlayingPainSound) return;

    i = Rand(PainSounds.length);
    bPlayingPainSound = true;

    SetTimerPauseByID('RunTaunt', true);
    AddTimer(GetSoundDuration(PainSounds[i]), 'PauseTauntTimer', false);

    Pawn.PlaySound(PainSounds[i], SLOT_Talk, 1.0f, false, 300.0f);
}

/** Same as the PlayPainSound() only it makes the Player pawn play it instead */
function PlayPickupSound() {
    PostalDude.PlaySound(PickupSounds[Rand(PickupSounds.length)],
                   SLOT_Talk, 1.0f, false, 300.0f);
}

/** Announce our final wish as we've lost a lot of blood */
function PlayDeathCurlSound() {
    Pawn.PlaySound(DeathCurlSounds[Rand(DeathCurlSounds.length)],
                   SLOT_Talk, 1.0f, false, 300.0f);
}

/** Taunt a little while you're running back to your pot of gold */
function PlayTauntSound() {
    Pawn.PlaySound(TauntSounds[Rand(TauntSounds.length)],
                   SLOT_Talk, 1.0f, false, 300.0f);
}

/** Overriden to implement what Leprechaun Gary should do when he sees a
 * particular Pawn
 */
function PawnSeen(Pawn Other) {
    if (PostalDude != none) return;

    if (Other.Controller != none && Other.Controller.bIsPlayer) {
        PostalDude = Other;
        GotoState('Scream');
    }
}

/** Notification from our Pawn that the player has picked up Leprechaun Gary
 * and added into the Dude's inventory
 */
function NotifyPlayerPickup() {
    local LeprechaunGaryInv PocketLeprechaun;

    if (PostalDude != none) {
		if (P2Player(PostalDude.Controller) != None
			&& P2Player(PostalDude.Controller).GetInv(200, 0) == None)
		{
			PocketLeprechaun = Spawn(class'LeprechaunGaryInv');

			if (PocketLeprechaun != none) {
				PocketLeprechaun.GiveTo(PostalDude);
				PlayPickupSound();

				if (P2Player(PostalDude.Controller) != none)
					P2Player(PostalDude.Controller).SwitchToThisPowerup(200, 0);

				Pawn.Destroy();
				Destroy();
			}
		}
    }
}

/** Notification from our Pawn that the player has bumped into me */
function NotifyPlayerBump() {
    if (IsInState('RunToPotofGold') || IsInState('JumpIntoPotOfGold') ||
        IsInState('FallDown'))
        return;

    if (IsInState('DeathCurl'))
        NotifyPlayerPickup();
    else
        GotoRunToPotOfGoldState();
}

/** Notification from our Pawn that our legs have been cut off and we should
 * immediately fall down into death curl
 */
function NotifyLegsCutOff() {
    NotifyFallDown();
}

/** Method gets called by our controlled Pawn when it's health drops below the
 * point where he collapses
 */
function NotifyFallDown() {
    if (IsInState('FallDown') || IsInState('DeathCurl')) return;

    GotoState('FallDown');
}

/** Overriden to implement running away when shot by the player */
function NotifyTakeHit(Pawn InstigatedBy, vector HitLocation, int Damage,
                       class<DamageType> DamageType, vector Momentum) {
    PlayPainSound();

    if (IsInState('RunToPotofGold') || IsInState('JumpIntoPotOfGold') ||
        IsInState('FallDown') || IsInState('DeathCurl'))
        return;

    if (InstigatedBy.Controller != none && !InstigatedBy.Controller.bIsPlayer)
        return;

    PostalDude = InstigatedBy;
    GotoRunToPotOfGoldState();
}

/** Spawns a pot of gold at the PotOfGoldNode farthest away from Gary's position */
function PotOfGold SpawnPotOfGold() {
    if (PotOfGoldDest == none)
        PotOfGoldDest = GetFarthestPotOfGold();

    if (PotOfGoldDest != none && PotOfGold == none)
        return PotOfGoldDest.SpawnPotOfGold();
}

/** Prepares the map for running to pot of gold state, and if everything is
 * good, we'll jump into that state
 */
function GotoRunToPotOfGoldState() {
    PotOfGold = SpawnPotOfGold();

    if (PotOfGoldDest != none)
        GotoState('RunToPotOfGold');
}

/** Poof out of existance when the Leprechaun is killed. Nice and magical,
 * plus the ragdoll doesn't look right with this scaling
 */
function PoofOutOfExistance() {
    LeprechaunGary.PoofOutOfExistance();
    Destroy();
}

/** Leprechaun Gary has reached his detination and contemplates what to do next
 * while playing a little idle animation
 */
state Idle
{
    function BeginState() {
        local int i;

        LogDebug("Entered Idle state...");

        i = Rand(IdleAnims.length);
        PlayAnimInfo(IdleAnims[i]);
        SetTimer(GetAnimDefaultDuration(IdleAnims[i]), false);

        AddTimer(IdleThinkInterval, 'IdleThink', true);
    }

    function EndState() {
        LogDebug("Exiting Idle state...");

        RemoveTimerByID('IdleThink');
    }

    function Timer() {
        // We're a Leprechaun, we don't give a shit if we go inside homes
        WanderDest = GetRandomPathNode(true);

        LogDebug("WanderDest: " $ string(WanderDest));

        if (WanderDest != none)
            GotoState('Wander');
        else
            BeginState();
    }

Begin:
    StopMoving();
}

/** Leprechaun Gary is simply walking to his wander destination */
state Wander
{
    function BeginState() {
        LogDebug("Entered Wander state...");

        Pawn.GroundSpeed = WalkSpeed;
        Pawn.BaseMovementRate = WalkSpeed * Pawn.DrawScale *
                                GaryAnimHeightScale;

        LeprechaunGary.SetAnimWalking();

        AddTimer(WanderThinkInterval, 'WanderThink', true);
    }

    function EndState() {
        LogDebug("Exiting Wander state...");

        RemoveTimerByID('WanderThink');
    }

Begin:
    while (!HasReachedWanderDest()) {
        if (ActorReachable(WanderDest))
            MoveToward(WanderDest);
		else {
			MoveTarget = FindPathToward(WanderDest);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('Idle');
		}
    }
}

/** Leprechaun Gary has seen the Dude and is freakin' terrified! :( */
state Scream
{
    function BeginState() {
        LogDebug("Entered Scream state...");

        FocalPoint = PostalDude.Location;

        PlayAnimByDuration(ScreamAnim, GetSoundDuration(ScreamSound));
        PlayScreamSound();
        SetTimer(GetSoundDuration(ScreamSound), false);
    }

    function Timer() {
        GotoRunToPotOfGoldState();
    }

Begin:
    StopMoving();
}

/** They're after me lucky charms! */
state RunToPotOfGold
{
    function BeginState() {
        LogDebug("Entered RunToPotOfGold state...");

        Focus = none;

        Pawn.GroundSpeed = RunSpeed;
        Pawn.BaseMovementRate = RunSpeed * Pawn.DrawScale *
                                GaryAnimHeightScale * RunAnimScale;

        LeprechaunGary.SetMood(MOOD_Scared, 1.0f);
        LeprechaunGary.SetAnimRunning();

        AddTimer(RunToPotThinkInterval, 'RunThink', true);
        AddTimer(RunTauntInterval, 'RunTaunt', true);
    }

    function EndState() {
        LogDebug("Exiting RunToPotOfGold state...");

        RemoveTimerByID('RunThink');
        RemoveTimerByID('RunTaunt');
    }

Begin:
    while (!HasReachedPotOfGold()) {
        if (ActorReachable(PotOfGoldDest))
            MoveToward(PotOfGoldDest);
		else {
			MoveTarget = FindPathToward(PotOfGoldDest);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
            else
                GotoState('Idle');
		}
    }
}

/** Run away!!! */
state JumpIntoPotOfGold
{
    function BeginState() {
        PotOfGoldJumpStart = Pawn.Location;
        Pawn.SetCollision(false, false, false);
        Pawn.bCollideWorld = false;

        LeprechaunGary.bOverrideJumpAnim = true;
        PlayAnimInfo(DiveAnim);
    }

    event Tick(float DeltaTime) {
        local float InterpPct;
        local vector InterpVector, InterpLocation;

        PotOfGoldJumpElapsedTime = FMin(PotOfGoldJumpElapsedTime + DeltaTime,
                                        PotOfGoldJumpTime);

        InterpPct = PotOfGoldJumpElapsedTime / PotOfGoldJumpTime;
        InterpVector = PotOfGold.Location - PotOfGoldJumpStart;
        InterpLocation = PotOfGoldJumpStart + InterpVector * InterpPct;
        InterpLocation.Z += sin(Interppct * Pi) * PotOfGoldJumpHeight;

        Pawn.SetLocation(InterpLocation);

        if (PotOfGoldJumpElapsedTime == PotOfGoldJumpTime) {
            PotOfGold.Destroy();
            PoofOutOfExistance();
        }
    }

Begin:
    StopMoving();
}

/** Leprechaun Gary has been shot so badly that he falls down */
state FallDown
{
    function BeginState() {
        LogDebug("Entered FallDown state...");

        MoveTarget = none;

        if (PotOfGold != none)
            PotOfGold.bLeprechaunProtected = false;

        PlayAnimInfo(FallAnim);
        SetTimer(GetAnimDefaultDuration(FallAnim), false);
    }

    function Timer() {
        GotoState('DeathCurl');
    }

Begin:
    StopMoving();
}

/** Leprechaun Gary has been shot enough times that he's below his Death Curl
 * Health percentage and can be picked up by the Dude
 */
state DeathCurl
{
    function BeginState() {
        local int i;

        LogDebug("Entered Death Curl state...");

        i = Rand(DeathCurlAnims.length);
        PlayAnimInfo(DeathCurlAnims[i], 0.5f);
        PlayDeathCurlSound();
        SetTimer(GetAnimDefaultDuration(DeathCurlAnims[i]), false);
    }

    function Timer() {
        local int i;

        i = Rand(DeathCurlAnims.length);
        PlayAnimInfo(DeathCurlAnims[i], 0.5f);
        SetTimer(GetAnimDefaultDuration(DeathCurlAnims[i]), false);
    }
}

defaultproperties
{
    bRandomizeStartLocation=true
    bControlAnimations=true

    LeprechaunSpawnChance=0.75f

    DestReachedRange=128.0f
    PotofGoldReachedRange=512.0f

    IdleThinkInterval=0.1f
    WanderThinkInterval=0.1f
    RunToPotThinkInterval=0.1f
    RunTauntInterval=3.0f

    IdleAnims(0)=(Anim="s_idle_crotch",Rate=1.0f,AnimTime=2.83f)
    IdleAnims(1)=(Anim="s_idle_survey",Rate=1.0f,AnimTime=5.53f)
    IdleAnims(2)=(Anim="s_idle_shoe",Rate=1.0f,AnimTime=3.33f)
    IdleAnims(3)=(Anim="s_idle_speck",Rate=1.0f,AnimTime=7.66f)
    IdleAnims(4)=(Anim="s_idle_stretch",Rate=1.0f,AnimTime=3.66f)
    IdleAnims(5)=(Anim="s_idle_watch",Rate=1.0f,AnimTime=4.0f)

    DeathCurlAnims(0)=(Anim="p_cower",Rate=1.0f,AnimTime=3.33f)
    DeathCurlAnims(1)=(Anim="p_cower2",Rate=1.0f,AnimTime=3.33f)

    FallAnim=(Anim="s_explosion_fore_inplace",Rate=1.0f,AnimTime=1.46f)
    ScreamAnim=(Anim="s_scream",Rate=1.0f,AnimTime=4.03f)
    DiveAnim=(Anim="gary_pot_dive_inplace",Rate=0.35f,AnimTime=1.1f)

    ScreamSound=sound'GaryDialog.gary_firescream'
    //ScreamSound=sound'StPatricksDaySounds.Scream.aiieeee'

    PickupSounds(0)=sound'StPatricksDaySounds.Pain.Hurt_JesusChrist'
    PickupSounds(1)=sound'StPatricksDaySounds.Pain.ough'
    PickupSounds(2)=sound'StPatricksDaySounds.Pain.pain1'
    PickupSounds(3)=sound'StPatricksDaySounds.Pain.pain2'
    PickupSounds(4)=sound'StPatricksDaySounds.Scream.aiieeee'

    PainSounds(0)=sound'StPatricksDaySounds.Pain.Hurt_JesusChrist'
    PainSounds(1)=sound'StPatricksDaySounds.Pain.Hurt_KeepShooting2'
    PainSounds(2)=sound'StPatricksDaySounds.Pain.Hurt_StopShootingMe'
    PainSounds(3)=sound'StPatricksDaySounds.Pain.Hurt_ThatFuckinHurt'
    PainSounds(4)=sound'StPatricksDaySounds.Pain.Hurt1'
    PainSounds(5)=sound'StPatricksDaySounds.Pain.ouch1'
    PainSounds(6)=sound'StPatricksDaySounds.Pain.ouch2'
    PainSounds(7)=sound'StPatricksDaySounds.Pain.ough'
    PainSounds(8)=sound'StPatricksDaySounds.Pain.pain1'
    PainSounds(9)=sound'StPatricksDaySounds.Pain.pain2'
    PainSounds(10)=sound'StPatricksDaySounds.Scream.aiieeee'

    DeathCurlSounds(0)=sound'StPatricksDaySounds.DeathCurl.Dead_OneMoreWhiskey'
    DeathCurlSounds(1)=sound'StPatricksDaySounds.DeathCurl.Dead_OneMoreWhiskey1'
    DeathCurlSounds(2)=sound'StPatricksDaySounds.DeathCurl.Dead_OneMoreWhisky2'

    TauntSounds(0)=sound'StPatricksDaySounds.Taunt.HadEnough'
    TauntSounds(1)=sound'StPatricksDaySounds.Taunt.Taunt_AwayAndShoite'
    TauntSounds(2)=sound'StPatricksDaySounds.Taunt.Taunt_CatchMeFirst'
    TauntSounds(3)=sound'StPatricksDaySounds.Taunt.Taunt_NeverGetMeLuckyCharms'
    TauntSounds(4)=sound'StPatricksDaySounds.Taunt.Taunt_NeverKeepUpWithMe'

    WalkSpeed=112.0f
    RunSpeed=550.0f

    GaryAnimHeightScale=0.66f
    RunAnimScale=0.5f

    PotOfGoldJumpTime=2.0f
    PotOfGoldJumpHeight=384.0f

    VisionFOV=90.0f
    VisionRange=2048.0f

    bLogDebug=false
}