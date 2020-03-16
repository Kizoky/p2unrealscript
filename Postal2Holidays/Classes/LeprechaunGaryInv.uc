/**
 * LeprechaunGaryInv
 *
 * Leprechaun Gary in the form of an inventory item. When activated, it'll
 * bring up a wish menu which you can use to make the Dude make a wish
 */
class LeprechaunGaryInv extends OwnedInv;

#exec Texture Import File=Textures\leprechaun_icon_64.dds Name=leprechaun_icon Mips=Off MASKED=1

/** Type of wish that is currently being granted that persists for some time */
enum EWishType
{
    /** Currently no wish has been made */
    WT_None,
    /** Currently granting the dick growing wish */
    WT_DickGrow,
    /** Currently granting the hottest person in town wish */
    WT_HottestPerson,
    /** Currently granted and viewing yourself as a leprechaun */
    WT_InfiniteWishes
};

//-----------------------------------------------------------------------------
// General Wish Variables

/** Which wish are we currently granting */
var travel EWishType WishType;
/** Time remaining until the wish has been fulfilled */
var travel float WishTimeRemaining;

//-----------------------------------------------------------------------------
// Dick Grow Wish Variables

/** Time in seconds for your dick to full grow to elephant */
var float DickGrowTime;
/** Time in seconds since your dick has started turning into a trumpet */
var travel float DickGrowElapsedTime;
/** New draw scale for your dick censor bubble */
var float DickGrowSize;
/** Urethra attachment in the form of a censor bubble */
var travel UrethraWeapon Dick;
/** Sound to play when your dick grows */
var sound DickGrowSound;

//-----------------------------------------------------------------------------
// Hottest Person in Town Variables

/** Time in seconds the Dude will stay as a human inferno */
var float InfernoDuration;
/** Time in seconds since the Dude has initiated his wish */
var travel float InfernoElapsedTime;
/** Time in seconds between inferno explosions */
var float InfernoExplosionInterval;

//-----------------------------------------------------------------------------
// Hot Bitches Wish Variables

/** Time in seconds after their spawn for them to turn on the Dude  */
var float HotBitchesAttackDelay;
/** Locations and by extent, the number of HotBitches to spawn */
var array<vector> HotBitchesSpawnLocations;
/** List of the hot bitches just spawned so we may make them go berserk */
var array<DogPawn> HotBitches;

//-----------------------------------------------------------------------------
// Infinite Wishes Backfire Variables

/** Time in seconds to view the Dude when he's turned into a leprechaun */
var float MiniDudeThirdPersonViewTime;
/** Time in seconds since the start of viewing the Dude in third person */
var travel float MiniDudeElapsedTime;
/** Sound to play of the Dude saying "You gotta be fucking kidding me" */
var sound MiniDudeTransformCommentary;

/** Overriden to implement the continuation of wish granting */
event TravelPostAccept() {
    super.TravelPostAccept();

    switch (WishType) {
        case WT_DickGrow:
            GotoState('GrowDick');
            break;
        case WT_HottestPerson:
            GotoState('WalkingInferno');
            break;
        case WT_InfiniteWishes:
            GotoState('InfiniteWishesBackfire');
            break;
    }
}

/** Sets the player's camera either to first or third person free camera
 * @param bFree - Whether or not the camera should be free
 */
function SetFreeCamera(bool bFree) {
    if (Pawn(Owner) != none && PlayerController(Pawn(Owner).Controller) != none) {
        PlayerController(Pawn(Owner).Controller).bBehindView = bFree;
        PlayerController(Pawn(Owner).Controller).bFreeCamera = bFree;
    }
}

/** Overriden to implement the adding of the wishing interface */
function Activate() {
    local PlayerController PC;
    local LeprechaunGaryInteraction WishMenu;

    if (WishType != WT_None) return;

    if (Pawn(Owner) != none)
        PC = PlayerController(Pawn(Owner).Controller);

    if (PC != none)
        WishMenu = LeprechaunGaryInteraction(PC.Player.InteractionMaster.AddInteraction("Postal2Holidays.LeprechaunGaryInteraction", PC.Player));

    if (WishMenu != none)
        WishMenu.LeprechaunInv = self;
}

/** Simply grows the Dude's censor bubble over time lol! */
function ElephantSizedDickWish() {
    local P2Player P2P;

    log(self$": I wish for an elephant sized dick!");

    WishType = WT_DickGrow;
    WishTimeRemaining = DickGrowTime;

    if (Pawn(Owner) != none) {
        Dick = UrethraWeapon(Pawn(Owner).FindInventoryType(class'UrethraWeapon'));

        if (P2Player(Pawn(Owner).Controller) != none)
            P2P = P2Player(Pawn(Owner).Controller);

        if (P2P != none
			&& Pawn(Owner).Weapon != Dick)
		{
			P2P.LastWeaponGroupPee = Pawn(Owner).Weapon.InventoryGroup;
			P2P.LastWeaponOffsetPee= Pawn(Owner).Weapon.GroupOffset;
			P2P.SwitchToThisWeapon(Dick.InventoryGroup, Dick.GroupOffset);
		}
    }

    if (Dick != none) {
        if (DickGrowSound != none)
            Pawn(Owner).PlaySound(DickGrowSound, SLOT_Interact);

        Dick.bElephantMode = true;
        GotoState('GrowDick');
    }
}

/** Initializes and sets up the Dude's wish to be the hottest person in town */
function HottestPersonWish() {
    log(self$": I wish to be the hottest person in town!");

    WishType = WT_HottestPerson;
    WishTimeRemaining = InfernoDuration;

    GotoState('WalkingInferno');
}

/** Spawns some fiery dogs that attacks the Dude */
function HotBitchesWish() {
    log(self$": I wish for hot bitches to work my balls");

    GotoState('HotBitchesAttack');
}

/** Gives the Dude a taste of what it's like to be a Leprechaun */
function InfiniteWishesWish() {
    local AWDude Dude;
    local P2Player P2P;

    log(self$": I wish for infinite wishes");

    WishType = WT_InfiniteWishes;
    WishTimeRemaining = MiniDudeThirdPersonViewTime;
    Dude = AWDude(Owner);

    if (Dude != none) {
        Dude.bLeprechaunMode = true;
        Dude.TurnIntoLeprechaun();
        Spawn(class'LeprechaunExplosion',,, Owner.Location);

        P2P = P2Player(Dude.Controller);

        if (P2P != none && MiniDudeTransformCommentary != none)
            P2P.SayCustomLine(MiniDudeTransformCommentary);
    }

    GotoState('InfiniteWishesBackfire');
}

/** Perform the dick growing */
state GrowDick
{
    function BeginState() {
        SetFreeCamera(true);
    }

    event Tick(float DeltaTime) {
        local float InterpPct, InterpDif;

        DickGrowElapsedTime = FMin(DickGrowElapsedTime + DeltaTime, DickGrowTime);
        InterpPct = DickGrowElapsedTime / DickGrowTime;
        InterpDif = DickGrowSize - Dick.default.CensorBarScale;

        Dick.SetCensorBarScale(Dick.default.CensorBarScale +
                               InterpPct * InterpDif);

        if (DickGrowElapsedTime == WishTimeRemaining) {
            SetFreeCamera(false);
            UsedUp();
        }
    }
}

/** Turn the Dude into a walking inferno */
state WalkingInferno
{
    function BeginState() {
        if (P2Pawn(Owner) != none)
            P2Pawn(Owner).TakesOnFireDamage = 0.0f;

        SetTimer(InfernoExplosionInterval, true);
    }

    function Timer() {
        if (Owner != none)
            Spawn(class'InfernoExplosion',,, Owner.Location);
    }

    event Tick(float DeltaTime) {
        InfernoElapsedTime = FMin(InfernoElapsedTime + DeltaTime, InfernoDuration);

        if (InfernoElapsedTime == InfernoDuration) {
            if (P2Pawn(Owner) != none
				&& !P2GameInfoSingle(Level.Game).VerifySeqTime())
                P2Pawn(Owner).TakesOnFireDamage = P2Pawn(Owner).default.TakesOnFireDamage;

            UsedUp();
        }
    }
}

/** Make the hot bitches attack the Dude after a short delay */
state HotBitchesAttack
{
    function BeginState() {
        local int i;
        local vector SpawnLoc;
        local DogPawn Bitch;
        local AWDogController BitchController;

        for (i=0;i<HotBitchesSpawnLocations.length;i++) {
            SpawnLoc = Owner.Location + class'P2EMath'.static.GetOffset(Owner.Rotation, HotBitchesSpawnLocations[i]);
            Bitch = Spawn(class'HotBitch',,, SpawnLoc);
            Spawn(class'LeprechaunExplosion',,, SpawnLoc);

            // Sometimes a bitch can't spawn, if that's the case, then just
            // don't add it to the list
            if (Bitch != none) {
                BitchController = Spawn(class'AWDogController');

                if (BitchController != none)
                    BitchController.Possess(Bitch);

                if (FPSPawn(Owner) != none)
                    Bitch.SetOnFire(FPSPawn(Owner), false);

                Bitch.SetPhysics(PHYS_Falling);

                HotBitches.Insert(HotBitches.length, 1);
                HotBitches[HotBitches.length - 1] = Bitch;
            }
        }

        SetTimer(HotBitchesAttackDelay, false);
    }

    function Timer() {
        local int i;
        local DogController BitchController;

        for (i=0;i<HotBitches.length;i++) {
            BitchController = DogController(HotBitches[i].Controller);

            if (BitchController != none) {
                BitchController.SetToAttackPlayer(FPSPawn(Owner));
                BitchController.GotoNextState();
            }
        }

        UsedUp();
    }
}

state InfiniteWishesBackfire
{
    function BeginState() {
        SetFreeCamera(true);
    }

    event Tick(float DeltaTime) {
        MiniDudeElapsedTime = FMin(MiniDudeElapsedTime + DeltaTime,
                                   MiniDudeThirdPersonViewTime);

        if (MiniDudeElapsedTime == MiniDudeThirdPersonViewTime) {
            SetFreeCamera(false);
            UsedUp();
        }
    }
}

defaultproperties
{
	WishType=WT_None

    DickGrowTime=4.0f
	DickGrowSize=0.5f
	DickGrowSound=sound'arcade.arcade_141'

	InfernoDuration=45.0f
	InfernoExplosionInterval=0.25f

	HotBitchesAttackDelay=0.1f
	HotBitchesSpawnLocations(0)=(X=384.0f,Y=0.0f,Z=0.0f)
	HotBitchesSpawnLocations(1)=(X=-384.0f,Y=256.0f,Z=0.0f)
	HotBitchesSpawnLocations(2)=(X=-384.0f,Y=256.0f,Z=0.0f)

	MiniDudeThirdPersonViewTime=5.0f
	MiniDudeTransformCommentary=sound'DudeDialog.dude_youvegottabekid'

    PickupClass=class'LeprechaunGaryPickup'
	Icon=texture'leprechaun_icon'

	InventoryGroup=100
	GroupOffset=6
	PowerupName="Leprechaun"
	PowerupDesc="Make a wish..."

	bPaidFor=false
	bCanThrow=false
	Hint1="Press %KEY_InventoryActivate%"
	Hint2="to make a wish"
	bUsePaidHints=false
}