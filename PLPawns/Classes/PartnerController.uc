/**
 * PartnerController
 *
 * AI Controller for your AI parnter that will follow you around and
 * support you everywhere you go. It's a bit calculation expensive since your
 * parnter will constantly check your inventory and well being
 */
class PartnerController extends AIController;

/** List of commands that can be issued to the Partner AI */
enum ECommand {
    /** Used by default to designate the player is navigating the menu */
    CM_None,
    /** Partner should follow you */
    CM_Follow,
    /** Partner should hold his/her position */
    CM_HoldPosition,
    /** Partner should attack whatever the player is pointing at */
    CM_Attack,
    /** Delcares to the Partner whether or not you and him are in a hostile territory */
    CM_HostileTerritory,
    /** Partner should holster his/her weapon to avoid attracting attention */
    CM_HolsterWeapon,
    /** Partner should equip his/her weapon */
    CM_EquipWeapon,
    /** Partner is allowed to use */
    CM_UseAnyWeapon,
    /** Partner should use a Pistol in combat from now on */
    CM_UsePistol,
    /** Partner should use a Shotgun from now on in combat */
    CM_UseShotgun,
    /** Partner should use a MachineGun from now on in combat */
    CM_UseMachineGun,
    /** Partner should use a Sniper Rifle in combat from now on */
    CM_UseSniperRifle,
    /** Partner should whip it out and spray it in everyone's face */
    CM_UsePecker
};

/** Player suggested the weapon that the partner should use during combat */
enum ESuggestedWeapon {
    /** Partner is allowed to use any weapon he or she sees fit */
    SW_None,
    /** Partner should use the Pistol in combat */
    SW_Pistol,
    /** Partner should use the Shotgun in combat */
    SW_Shotgun,
    /** Partner should use the MachineGun in combat */
    SW_MachineGun,
    /** Partner should use a Sniper Rifle in combat */
    SW_SniperRifle,
    /** Partner should use his or her genitals in combat, spraying everyone */
    SW_Pecker
};

/** Struct defining various radiuses  */
struct MoveRadiuses {
    /** Distance at which we consider to have reached our destination or we have gotten close */
    var float ReachedRadius, CloseRadius, FarRadius;
};

//-----------------------------------------------------------------------------
// Behavior Variables

/** Whether or not we're in a hostile territory, if we are, attack anyone with a gun */
var bool bInHostileTerritory;

/** Commands like CM_Follow are persistant, so we want to save it */
var ECommand CurrentCommand;
/** Commands like CM_EquipPistol are temporary, so we want to execute and fall back to the previous command. */
var ECommand PendingCommand;

/** Weapon suggested by the player that the Partner should use */
var ESuggestedWeapon SuggestedWeapon;

/** World location where the pawns should go to hold out */
var vector HoldPositionLocation;

/** Pickup to pick up which can be anything from medkits to weapons */
var Pickup SupplyPickup;
/** Distance away from your Partner he will detect useful supplies */
var float SupplySearchRadius;
/** Distance away from the desired pickup that the Partner can pick it up */
var float SupplyPickupRadius;
/** Interest sound to play when your Partner has spotted something he or she'd like */
var sound SupplyInterestSound;

/** An object in the world your Partner should attack */
var Actor AttackTarget;
/** Attack range to use when attacking the AttackTarget */
var float AttackRange;
/** Minimum dot product to be considered inside your Partner's attack cone */
var float AttackCone;

/** Recommended attack range to be in for attacking with a Pistol */
var float AttackRangePistol;
/** Recommended attack range to be in for attacking with a Shotgun */
var float AttackRangeShotgun;
/** Recommended attack range to be in for attacking with a MachineGun */
var float AttackRangeMachineGun;
/** Recommended attack range to be in for attacking with a Sniper Rifle */
var float AttackRangeSniperRifle;
/** Recommended attack range to be in for pissing on people */
var float AttackRangePecker;

/** Radius from your Partner to check for potential threats */
var float ThreatFindRadius;

/** Distances away from the player, used for movement */
var MoveRadiuses FollowPlayerRadiuses;
/** Distances away from our desired hold location, used for movement */
var MoveRadiuses HoldPositionRadiuses;

/** Time in seconds before the Controller thinks again in the Idle state */
var float IdleThinkInterval;
/** Time in seconds before the Controller thinks again in the Follow state */
var float FollowThinkInterval;
/** Time in seconds before the Controller thinks again in the HoldPosition state */
var float HoldThinkInterval;
/** Time in seconds before the Controller thinks again in the Move to Pickup state */
var float PickupThinkInterval;
/** Time in seconds before the Controller thinks again when attacking */
var float AttackThinkInterval;

/** Pistol weapon that the Partner has */
var PistolWeapon PartnerPistol;
/** Shotgun weapon that the Partner has */
var ShotgunWeapon PartnerShotgun;
/** MachineGun weapon that the Partner has */
var MachineGunWeapon PartnerMachineGun;
/** Sniper Rifle weapon that the Partner has */
var RifleWeapon PartnerSniperRifle;

/** The direction your Partner should look after entering the Idle state */
var vector PreviousStateLookDir;

//-----------------------------------------------------------------------------
// Player Variables

/** Pawn object who we're gonna stick with and swear our virtual life to */
var Pawn Player;
/** Controller object the player uses. We use the handy Enemy variable, thanks RWS coder guy! */
var Controller PlayerController;

/** Radio weapon that the player has */
var PartnerRadioWeapon PlayerRadio;
/** Pistol weapon that the player has */
var PistolWeapon PlayerPistol;
/** Shotgun weapon that the player has */
var ShotgunWeapon PlayerShotgun;
/** MachineGun weapon that the player has */
var MachineGunWeapon PlayerMachineGun;
/** Sniper Rifle weapon that the player has */
var RifleWeapon PlayerSniperRifle;

/** Subclassed to call the AddDefaultInventory method */
function Possess(Pawn aPawn) {
    local P2Pawn P2P;

    super.Possess(aPawn);

    P2P = P2Pawn(aPawn);

    if (P2P != none) {
        P2P.CreateInventoryByClass(class'HandsWeapon');
        P2P.CreateInventoryByClass(class'UrethraWeapon');
    }
}

/** Simple method that causes your Partner to start firing */
function StartFiring() {
    Focus = AttackTarget;
    Pawn.Weapon.Fire(1.0f);
}

/** Simple method that causes your Partner to stop firing */
function StopFiring() {
    bFire = 0;
}

/** Copied and pasted from LambController */
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror) {
    if (AttackTarget != none) {
        if ((ShotgunWeapon(Pawn.Weapon) != none || RifleWeapon(Pawn.Weapon) != none) &&
            P2MoCapPawn(AttackTarget) != none &&
            P2MoCapPawn(AttackTarget).myHead != none)
            return rotator(P2MoCapPawn(AttackTarget).myHead.Location - projStart);
        else
            return rotator(AttackTarget.Location - projStart);
    }
    else
        return Pawn.Rotation;
}

/** Copied and pasted from PersonController */
function bool SwitchToThisWeapon(int GroupNum, int OffsetNum) {
	local float rating;
	local Inventory inv;
	local bool bFoundIt;

	if (Pawn.Inventory == none ||
       (Pawn.Weapon.InventoryGroup == GroupNum && Pawn.Weapon.GroupOffset == OffsetNum))
		return false;

	StopFiring();
	inv = Pawn.Inventory;

	while (inv != none && !bFoundIt) {
		if (Weapon(inv) != none
			&& inv.InventoryGroup == GroupNum
			&& inv.GroupOffset == OffsetNum)
			bFoundIt=true;
		else
			inv = inv.Inventory;
	}

    if (bFoundIt)
		Pawn.PendingWeapon = Weapon(inv);
	else
		return bFoundIt;

	if (Pawn.PendingWeapon == Pawn.Weapon)
		Pawn.PendingWeapon = none;

    if (Pawn.PendingWeapon == none)
		return bFoundIt;

	if (Pawn.Weapon == none)
		Pawn.ChangedWeapon();

	if (Pawn.Weapon != Pawn.PendingWeapon)
		Pawn.Weapon.PutDown();

	return bFoundIt;
}

/** Subclassed to make him run through doors like the player would */
function MoverFinished() {
    PendingMover = none;
    bPreparingMove = false;
}

/** Returns whether or not your Partner is currently unarmed
 * @return TRUE if the current weapon is the HandsWeapon; FALSE otherwise
 */
function bool IsUnarmed() {
    return HandsWeapon(Pawn.Weapon) != none;
}

/** Given a Pickup object, decide whether or not it's a good potential pickup
 * @param P - Pickup object to verify
 * @return TRUE if it's a good pickup; FALSE if it's not, or we should leave it for the player
 */
function bool IsPotentialPickup(Pickup P) {
    return ((PistolPickup(P) != none && PlayerPistol != none && PartnerPistol == none) ||
            (ShotgunPickup(P) != none && PlayerShotgun != none && PartnerShotgun == none) ||
            (MachineGunPickup(P) != none && PlayerMachineGun != none && PartnerMachineGun == none) ||
            (RiflePickup(P) != none && PlayerSniperRifle != none && PartnerSniperRifle == none));
}

/** Given an object, return whether or not the object is a potential and valid target
 * NOTE: OVERHAUL LATER, FAR FROM COMPLETE
 * @param Other - Actor object to verify if it's a better target or not
 */
function bool IsValidTarget(Actor Other) {
    local Pawn P;

    P = Pawn(Other);

    return (P != none && P.Health > 0 && P != Player && P != Pawn);
}

/** Returns whether or not someone has a weapon out
 * @param Other - Pawn object to check
 * @return TRUE if the pawn has a weapon out; FALSE otherwise
 */
function bool IsArmed(Pawn Other) {
    return (FPSPawn(Other) != none &&
            FPSPawn(Other).Gang != "RWSStaff" &&
            HandsWeapon(Other.Weapon) == none);
}

/** Returns whether or not an RWS Guy has become hostile. We obviously want to
 * avoid shooting any allys
 * @param Other - Pawn object to check
 * @return TRUE if the RWS guy is pissed at the player; FALSE otherwise
 */
function bool IsHostileRWSGuy(Pawn Other) {
    return (P2Pawn(Other) != none &&
            P2Pawn(Other).Gang == "RWSStaff" &&
			!P2Pawn(Other).bPlayerIsFriend &&
			P2Pawn(Other).bPlayerIsEnemy);
}

/** Returns whether or not the given Pawn will potentially shoot the outselves
 * @param Other - Pawn object we're gonna check
 * @return TRUE if the pawn has a weapon and is looking at ourselves; FALSE otherwise
 */
function bool IsPotentialThreatToSelf(Pawn Other) {
    return (FPSPawn(Other) != none &&
            FPSPawn(Other).Gang != "RWSStaff" &&
            LambController(Other.Controller) != none &&
            HandsWeapon(Other.Weapon) == none &&
           (LambController(Other.Controller).InterestPawn == Pawn ||
            LambController(Other.Controller).Attacker == Pawn ||
            LambController(Other.Controller).Focus == Pawn ||
            LambController(Other.Controller).Enemy == Pawn));
}

/** Returns whether or not the given Pawn will potentially shoot the player
 * @param Other - Pawn object we're gonna check
 * @return TRUE if the pawn has a weapon and is looking at the player; FALSE otherwise
 */
function bool IsPotentialThreatToPlayer(Pawn Other) {
    return (FPSPawn(Other) != none &&
            FPSPawn(Other).Gang != "RWSStaff" &&
            LambController(Other.Controller) != none &&
            HandsWeapon(Other.Weapon) == none &&
           (LambController(Other.Controller).InterestPawn == Player ||
            LambController(Other.Controller).Attacker == Player ||
            LambController(Other.Controller).Focus == Player ||
            LambController(Other.Controller).Enemy == Player));
}

/** Returns whether or not the target has been eliminated
 * NOTE: OVERHAUL LATER, FAR FROM COMPLETE
 * @return TRUE if the pawn or explosive is dead or blown up; FALSE otherwise
 */
function bool IsTargetDead() {
    local Pawn P;

    P = Pawn(AttackTarget);

    return (P != none && P.Health <= 0);
}

/** Returns whether or not we're facing our target
 * @return TRUE if we're facing our target; FALSE otherwise
 */
function bool IsFacingTarget() {
    local vector TargetDir, PawnDir;

    TargetDir = Normal(AttackTarget.Location - Pawn.Location);

    return (TargetDir dot vector(Pawn.Rotation) >= 0.f);
}

/** Returns whether or not the Pawn wants to gun the Dude down
 * @return TRUE if the given Pawn definitely has a hostile intent; FALSE otherwise
 */
function bool IsPlayerHostile(Pawn Seen) {
    local LambController SeenController;

    SeenController = LambController(Seen.Controller);

    return (SeenController != none &&
            SeenController.Attacker == Player &&
            HandsWeapon(Seen.Weapon) == none);
}

/** Returns whether or not your Partner is in attack range
 * @return TRUE if your partner is in range; FALSE otherwise
 */
function bool IsInAttackRange() {
    if (AttackTarget != none)
        return VSize(AttackTarget.Location - Pawn.Location) <= AttackRange;
    else
        return false;
}

/** Returns whether or not the point can actually be reached or not
 * @param Point - World location that you want to verify
 * @return TRUE if the location is reachable; FALSE otherwise
 */
function bool IsPointReachable(vector Point) {
    return (PointReachable(Point) || FindPathTo(Point) != none);
}

/** Returns whether or not the Actor can actually be reached or not
 * @param Dest - Actor object
 * @return TRUE if the location is reachable; FALSE otherwise
 */
function bool IsActorReachable(Actor Dest) {
    return (ActorReachable(Dest) || FindPathToward(Dest) != none);
}

/** Returns whether or not the Partner is far from the player
 * @return TRUE if the partner if far from the player; FALSE otherwise
 */
function bool IsFarFromPlayer() {
    return VSize(Player.Location - Pawn.Location) >= FollowPlayerRadiuses.FarRadius;
}

/** Returns whether or not the Partner has come close to the player
 * @return TRUE if the partner has come close to the player; FALSE otherwise
 */
function bool IsCloseToPlayer() {
    return VSize(Player.Location - Pawn.Location) <= FollowPlayerRadiuses.CloseRadius;
}

/** Returns whether or not your Partner is far from the hold location
 * @return TRUE if your partner is far from the hold location
 */
function bool IsFarFromHoldPosition() {
    return VSize(HoldPositionLocation - Pawn.Location) >= HoldPositionRadiuses.FarRadius;
}

/** Returns whether or not your Partner is close to the hold location
 * @return TRUE if your partner is close to the hold location
 */
function bool IsCloseToHoldPosition() {
    return VSize(HoldPositionLocation - Pawn.Location) <= HoldPositionRadiuses.CloseRadius;
}

/** Returns whether or not the Partner has reached the player
 * @return TRUE if the partner is close enough that he or she needs to go no further; FALSE otherwise
 */
function bool HasReachedPlayer() {
    return VSize(Player.Location - Pawn.Location) <= FollowPlayerRadiuses.ReachedRadius;
}

/** Returns whether or not your Partner has reached the hold location
 * @return TRUE if the partner has arrived at the hold location; FALSE otherwise
 */
function bool HasReachedHoldPosition() {
    return VSize(HoldPositionLocation - Pawn.Location) <= HoldPositionRadiuses.ReachedRadius;
}

/** Returns whether or not we've gotten close enough to pickup our item
 * @return TRUE if the partner is close enough to the supply pickup
 */
function bool HasReachedPickup() {
    return VSize(SupplyPickup.Location - Pawn.Location) <= SupplyPickupRadius;
}

/** Returns whether or not your Partner should open fire on the enemy
 * @return TRUE if your partner should open fire; FALSE otherwise
 */
function bool ShouldOpenFire() {
    local vector HitLocation, HitNormal, EndTrace, StartTrace;
    local Actor Other;

    if (AttackTarget == none)
        return false;

    StartTrace = Pawn.Location + Pawn.EyePosition();
    EndTrace = AttackTarget.Location;
    Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

    return (IsInAttackRange() && LineOfSightTo(AttackTarget) &&
            IsFacingTarget() && Other != Player);
}

/** Given the current target object and the weapon
 * NOTE: NOT COMPLETE, OVERHAUL LATER
 * @param Other - Attack target to get the range for
 */
function float GetAttackRange(Actor Other) {
    local ESuggestedWeapon EquipedWeapon;

    EquipedWeapon = GetEquipWeapon();

    switch (GetEquipWeapon()) {
        case SW_Pistol:
            return AttackRangePistol;

        case SW_Shotgun:
            return AttackRangeShotgun;

        case SW_MachineGun:
            return AttackRangeMachineGun;

        case SW_SniperRifle:
            return AttackRangeSniperRifle;

        case SW_Pecker:
            return AttackRangePecker;
    }

    return 0.0f;
}

/** Returns the weapon class that the Partner should use in combat. Your partner
 * prefers the MachineGun first, Sniper Rifle second, Shotgun third, and the
 * Pistol last. Worst case sceanerio with no weapon, he'll use his pecker
 * @return Enum of ESuggestedWeapon that designates the suggested weapon
 */
function ESuggestedWeapon GetEquipWeapon() {
    if (SuggestedWeapon != SW_None)
        return SuggestedWeapon;
    else if (PartnerMachineGun != none)
        return SW_MachineGun;
    else if (PartnerSniperRifle != none)
        return SW_SniperRifle;
    else if (PartnerShotgun != none)
        return SW_Shotgun;
    else if (PartnerPistol != none)
        return SW_Pistol;

    return SW_Pecker;
}

/** Sets the specified Actor as a target and goes into an attack state if it is valid
 * @param Other - Actor object that can potentially be a target
 */
function SetAttackTarget(Actor Other) {
    if (IsValidTarget(Other)) {
        AttackTarget = Other;
        AttackRange = GetAttackRange(Other);
        EquipWeapon();
		PartnerPawn(Pawn).PlayDialog_Attack();

        if (!IsInState('MoveToHoldPosition')) {
            if (IsInAttackRange())
                GotoState('AttackingTarget');
            else if (CurrentCommand != CM_HoldPosition)
                GotoState('MoveToAttackTarget');
        }
    }
}

/** Method gets called when the player's Radio weapon issues a command
 * @param Command - Command type that's been issued by the player
 * @param CommandActor - Actor object that pertains to the command type
 * @param CommandLocation - World location that pertains to the command type
 */
function ReceiveCommand(ECommand Command,
                        optional Actor CommandActor,
                        optional vector CommandLocation) {
    PendingCommand = Command;

    switch (Command) {
        case CM_Follow:
            OnFollowCommand();
            break;

        case CM_HoldPosition:
            OnHoldPositionCommand(CommandLocation);
            break;

        case CM_Attack:
            OnAttackCommand(CommandActor);
            break;

        case CM_HostileTerritory:
            OnHostileTerritory();
            break;

        case CM_HolsterWeapon:
            OnHolsterCommand();
            break;

        case CM_EquipWeapon:
            OnEquipWeaponCommand();
            break;

        case CM_UseAnyWeapon:
        case CM_UsePistol:
        case CM_UseShotgun:
        case CM_UseMachineGun:
        case CM_UseSniperRifle:
        case CM_UsePecker:
            OnUseWeaponCommand();
            break;
    }
}

/** Checks to see if we can reach the player, if we can, we go */
function OnFollowCommand() {
    CurrentCommand = PendingCommand;
    PendingCommand = CM_None;
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
	
    if (IsActorReachable(Player))
        GotoState('MoveToPlayer');
}

/** Checks to see if the specified location is reachable, if it is, we go */
function OnHoldPositionCommand(vector HoldLocation) {
    CurrentCommand = PendingCommand;
    PendingCommand = CM_None;
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();

    if (IsPointReachable(HoldLocation)) {
        HoldPositionLocation = HoldLocation;
        GotoState('MoveToHoldPosition');
    }
    else
        log(self$": HoldPosition is unreachable");
}

/** Causes your Partner to wail on whatever has been marked by the player */
function OnAttackCommand(Actor Target) {
    SetAttackTarget(Target);
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
}

/** Causes your partner to target */
function OnHostileTerritory() {
    bInHostileTerritory = !bInHostileTerritory;
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
}

/** Causes your Partner to holster his or her weapon */
function OnHolsterCommand() {
    PendingCommand = CM_None;
    SwitchToHands();
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
}

/** Causes your Partner to equip */
function OnEquipWeaponCommand() {
    PendingCommand = CM_None;
    EquipWeapon();
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
}

/** Sets the preferred weapon that your Partner should use in combat */
function OnUseWeaponCommand() {
    switch (PendingCommand) {
        case CM_UseAnyWeapon:
            SuggestedWeapon = SW_None;
            break;

        case CM_UsePistol:
            SuggestedWeapon = SW_Pistol;
            break;

        case CM_UseShotgun:
            SuggestedWeapon = SW_Shotgun;
            break;

        case CM_UseMachineGun:
            SuggestedWeapon = SW_MachineGun;
            break;

        case CM_UseSniperRifle:
            SuggestedWeapon = SW_SniperRifle;
            break;

        case CM_UsePecker:
            SuggestedWeapon= SW_Pecker;
            break;
    }

    PendingCommand = CM_None;
    NotifySuggestedWeaponChanged();
	PartnerPawn(Pawn).PlayDialog_AcceptCommand();
}

/** Sets the pawn into running mode */
function SetRunning() {
    Pawn.SetWalking(false);
}

/** Sets the pawn into walking mode */
function SetWalking() {
    Pawn.SetWalking(true);
}

/** Sets the pawn into crouching mode */
function SetCrouching() {
    Pawn.ShouldCrouch(true);
}

/** Sets the pawn into standing mode */
function SetStanding() {
    Pawn.ShouldCrouch(false);
}

/** Causes the Pawn to stop moving */
function StopMoving() {
    Pawn.Acceleration = vect(0,0,0);
}

/** Busts out your partner's most powerful weapon or suggested weapon */
function EquipWeapon() {
    switch (GetEquipWeapon()) {
        case SW_Pistol:
            SwitchToPistol();
            break;

        case SW_Shotgun:
            SwitchToShotgun();
            break;

        case SW_MachineGun:
            SwitchToMachineGun();
            break;

        case SW_SniperRifle:
            SwitchToSniperRifle();
            break;

        case SW_Pecker:
            SwitchToPecker();
            break;
    }
}

/** Holsters your current Partner's weapons */
function SwitchToHands() {
    SwitchToThisWeapon(0, 2);
}

/** Switches the Partner's current weapon to a Pistol */
function SwitchToPistol() {
    SwitchToThisWeapon(2, 1);
}

/** Switches the Partner's current weapon to a Shotgun */
function SwitchToShotgun() {
    SwitchToThisWeapon(3, 1);
}

/** Switches the Partner's current weapon to a MachineGun */
function SwitchToMachineGun() {
    SwitchToThisWeapon(4, 1);
}

/** Switches the Partner's current weapon to a Sniper Rifle */
function SwitchToSniperRifle() {
    local RifleWeapon Rifle;

    Rifle = RifleWeapon(Pawn.FindInventoryType(class'RifleWeapon'));

    if (Rifle != none) {
        Rifle.TraceAccuracy = 0.0f;

        if (Rifle.AmmoType != none)
            Rifle.AmmoType.ProjectileClass = class'PartnerRifleProjectile';
    }

    SwitchToThisWeapon(8, 1);
}

/** Whip it out! */
function SwitchToPecker() {
    SwitchToThisWeapon(0, 1);
}

/** Check if the Player has attacked anyone or if he or she is getting attacked,
 * ultimately we prioritize people who attack the player first
 */
function CheckForPlayerEnemy() {
    local FPSPawn FPSP;
    local vector ThreatFindOrigin;

    FPSP = FPSPawn(Player);

    if (CurrentCommand == CM_HoldPosition) {
        ThreatFindOrigin = Pawn.Location + Pawn.EyePosition();

        foreach VisibleCollidingActors(class'FPSPawn', FPSP, ThreatFindRadius, ThreatFindOrigin) {
            if ((IsHostileRWSGuy(FPSP)) ||
                (bInHostileTerritory && IsArmed(FPSP)) ||
                (IsPotentialThreatToPlayer(FPSP)))
                SetAttackTarget(FPSP);
        }
    }
    else {
        if ((FPSP != none && FPSP.DamageInstigator != none) ||
            (PlayerController != none && PlayerController.Enemy != none))
            SetAttackTarget(PlayerController.Enemy);

        /** Find someone suspicious if there are no immediate threats */
        if (Player != none) {
            ThreatFindOrigin = Player.Location + Player.EyePosition();

            foreach VisibleCollidingActors(class'FPSPawn', FPSP, ThreatFindRadius, ThreatFindOrigin) {
                if ((IsHostileRWSGuy(FPSP)) ||
                    (bInHostileTerritory && IsArmed(FPSP)) ||
                    (IsPotentialThreatToPlayer(FPSP) || IsPotentialThreatToSelf(FPSP)))
                    SetAttackTarget(FPSP);
            }
        }
    }
}

/** Checks the player's inventory for weapons, and if they're found, we make
 * make references to them for future use
 */
function CheckPlayerInventory() {
    if (Player == none)
        return;

    PlayerPistol = PistolWeapon(Player.FindInventoryType(class'PistolWeapon'));
    PlayerShotgun = ShotgunWeapon(Player.FindInventoryType(class'ShotgunWeapon'));
    PlayerMachineGun = MachineGunWeapon(Player.FindInventoryType(class'MachineGunWeapon'));
    PlayerSniperRifle = RifleWeapon(Player.FindInventoryType(class'RifleWeapon'));
}

/** Checks our own inventory to make sure we only pickup weapons we don't have */
function CheckPartnerInventory() {
    if (Pawn == none)
        return;

    PartnerPistol = PistolWeapon(Pawn.FindInventoryType(class'PistolWeapon'));
    PartnerShotgun = ShotgunWeapon(Pawn.FindInventoryType(class'ShotgunWeapon'));
    PartnerMachineGun = MachineGunWeapon(Pawn.FindInventoryType(class'MachineGunWeapon'));
    PartnerSniperRifle = RifleWeapon(Pawn.FindInventoryType(class'RifleWeapon'));
}

/** Checks out the area to see if there's a potential pickup that we can use
 * @return Closest Pickup object that we should pickup if there is one; None otherwise
 */
function Pickup CheckForSupplies() {
    local int ClosestIndex, i;
    local float ClosestDistance;

    local Pickup P;
    local array<Pickup> PickupList;

    if (Pawn == none)
        return none;

    foreach VisibleCollidingActors(class'Pickup', P, SupplySearchRadius, Pawn.Location) {
        if (P != none && IsPotentialPickup(P)) {
            PickupList.Insert(PickupList.length, 1);
            PickupList[PickupList.length-1] = P;
        }
    }

    if (PickupList.length == 0)
        return none;

    ClosestIndex = 0;
    ClosestDistance = VSize(PickupList[0].Location - Pawn.Location);

    for (i=1;i<PickupList.length;i++) {
        if (VSize(PickupList[i].Location - Pawn.Location) < ClosestDistance) {
            ClosestIndex = i;
            ClosestDistance = VSize(PickupList[i].Location - Pawn.Location);
        }
    }

    return PickupList[ClosestIndex];
}

/** Subclassed to implement reactions to getting hit */
function NotifyTakeHit(Pawn InstigatedBy,
                       vector HitLocation,
                       int Damage,
                       class<DamageType> damageType,
                       vector Momentum) {

	PartnerPawn(Pawn).PlayDialog_GetHit();
    if (!IsInState('AttackingTarget') && !IsInState('MoveToAttackTarget'))
        SetAttackTarget(InstigatedBy);
}

/** Called right after the SuggestedWeapon has been updated. We want to change
 * weapons only if we're not having our weapon holstered to avoid attention
 */
function NotifySuggestedWeaponChanged() {
    EquipWeapon();
}

/** Subclassed to evaluate pawns as you see them */
function SeeMonster(Pawn Seen) {
    if (FPSPawn(Seen) != none && LambController(Seen.Controller) != none &&
        HandsWeapon(Seen.Weapon) == none) {
        log(self$": Someone's eyeing our boss!");
        SetAttackTarget(Seen);
    }
}

/** This state is normally used to */
auto state Idle {

    function BeginState() {
        //log(self$": Entered Idle state");
        SetTimer(IdleThinkInterval, true);

        StopFiring();

        Focus = none;

        if (PreviousStateLookDir != vect(0,0,0)) {
            FocalPoint = Pawn.Location + 256.0f * PreviousStateLookDir;
            PreviousStateLookDir = vect(0,0,0);
        }

        AttackTarget = none;
        AttackRange = 0.0f;

        CheckPlayerInventory();
        CheckPartnerInventory();

        SupplyPickup = CheckForSupplies();

        if (SupplyPickup != none && IsActorReachable(SupplyPickup))
            GotoState('ExpressItemInterest');
    }

    function Timer() {
        CheckForPlayerEnemy();

        //FocalPoint = Player.Location + 1024.0f * vector(Player.Rotation);

        //log(self$": Timer method called in Idle state...");
        if (CurrentCommand == CM_Follow && IsFarFromPlayer())
            GotoState('MoveToPlayer');
        else if (CurrentCommand == CM_HoldPosition && IsFarFromHoldPosition())
            GotoState('MoveToHoldPosition');
    }

Begin:
    StopMoving();
}

/** State where your Partner has been ordered to follow you. If you haven't
 * moved in a while, he or she will go idle.
 */
state MoveToPlayer {

    function BeginState() {
        //log(self$": Entered FollowPlayer state");
        SetTimer(FollowThinkInterval, true);
    }

    function Timer() {
        CheckForPlayerEnemy();

        //log(self$": Timer method called in Follow state...");
        if (!IsCloseToPlayer())
            SetRunning();
        else
            SetWalking();

        // We need this to run in parallel with the latent movement code
        if (HasReachedPlayer()) {
            PreviousStateLookDir = vector(Pawn.Rotation);
            GotoState('Idle');
        }
    }

Begin:
    while (!HasReachedPlayer()) {
        if (ActorReachable(Player))
            MoveToward(Player);
		else {
			MoveTarget = FindPathToward(Player);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
			else {
			    PreviousStateLookDir = vector(Pawn.Rotation);
				GotoState('Idle');
			}
		}
    }
}

/** Your Partner will hold his position in this state */
state MoveToHoldPosition {

    function BeginState() {
        SetTimer(HoldThinkInterval, true);
    }

    function Timer() {
        if (AttackTarget != none) {
            Focus = AttackTarget;

            if (ShouldOpenFire())
                StartFiring();
            else
                StopFiring();

            if (IsTargetDead() || !(IsInAttackRange() && LineOfSightTo(AttackTarget))) {
                PreviousStateLookDir = vector(Pawn.Rotation);
                AttackTarget = none;
                GotoState('Idle');
            }
        }
        else
            CheckForPlayerEnemy();

        if (!IsCloseToHoldPosition())
            SetRunning();
        else
            SetWalking();

        if (HasReachedHoldPosition()) {
            PreviousStateLookDir = vector(Pawn.Rotation);
            GotoState('Idle');
        }
    }

Begin:
    while (!HasReachedHoldPosition()) {
        if (PointReachable(HoldPositionLocation))
            MoveTo(HoldPositionLocation);
		else {
			MoveTarget = FindPathTo(HoldPositionLocation);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
			else {
			    PreviousStateLookDir = vector(Pawn.Rotation);
				GotoState('Idle');
			}
		}
    }
}

/** Simple state that causes your Partner to face the supply pickup and
 * verbally express interest in an item
 */
state ExpressItemInterest {

    function BeginState() {
        Focus = SupplyPickup;

        if (SupplyInterestSound != none) {
            Pawn.PlaySound(SupplyInterestSound, SLOT_Interact, 1.0f, false, 300.0f, 1.0f);
            SetTimer(GetSoundDuration(SupplyInterestSound), false);

            if (PersonPawn(Pawn) != none && Head(PersonPawn(Pawn).MyHead) != none)
                Head(PersonPawn(Pawn).MyHead).Talk(GetSoundDuration(SupplyInterestSound));
        }
        else
            SetTimer(1.0f, false);
    }

    function Timer() {
        CheckForPlayerEnemy();

        if (SupplyPickup != none)
            GotoState('MoveToPickupItem');
        else {
            PreviousStateLookDir = vector(Pawn.Rotation);
            GotoState('Idle');
        }
    }

Begin:
    StopMoving();
}

/** Partner will move to the item to pick it up */
state MoveToPickupItem {

    function BeginState() {
        log(self$": Entered MoveToPickupItem state...");
        SetTimer(PickupThinkInterval, true);
    }

    function Timer() {
        CheckForPlayerEnemy();

        if (SupplyPickup == none) {
            MoveTarget = none;
            Focus = none;
            PreviousStateLookDir = vector(Pawn.Rotation);
            GotoState('Idle');
        }

        if (HasReachedPickup())
            GotoState('PickupItem');
    }

Begin:
    while (!HasReachedPickup()) {
        if (ActorReachable(SupplyPickup))
            MoveToward(SupplyPickup);
		else {
			MoveTarget = FindPathToward(SupplyPickup);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
			else {
			    PreviousStateLookDir = vector(Pawn.Rotation);
				GotoState('Idle');
			}
		}
    }
}

/** Simple state where the pawn bends down to pick something up, assuming no
 * ones a dick and steals everything he wants to pickup. Share the guns, better
 * armed he is, the better off you'll be
 */
state PickupItem {

    function BeginState() {
        SetTimer(1.33f, false);
    }

    function EndState() {
        Pawn.bCanPickupInventory = false;
        PreviousStateLookDir = vector(Pawn.Rotation);
        GotoState('Idle');
    }

Begin:
    StopMoving();
    Pawn.PlayAnim('s_idle_shoe', 2.0f);
    Sleep(0.83f);

    if (SupplyPickup != none) {
        Pawn.bCanPickupInventory = true;
        SupplyPickup.Touch(Pawn);
        Pawn.bCanPickupInventory = false;

        if (PlayerRadio != none)
            PlayerRadio.NotifyPartnerPickup(SupplyPickup);
    }

    MoveTarget = none;
    Focus = none;

    Sleep(0.5f);
    PreviousStateLookDir = vector(Pawn.Rotation);
    GotoState('Idle');
}

/** In this state we've reached a good range to use our weapon, so here we'll
 * stop and start wailing on our enemy with our weapon. I don't feel like
 * extending this state from Idle
 */
state AttackingTarget {

    function BeginState() {
        SetTimer(AttackThinkInterval, true);
        Focus = AttackTarget;
    }

    /** Always ensure our AttackTarget is our focus, kinda an ass way of doing
     * things, but whatever. :P
     */
    function Timer() {
        Focus = AttackTarget;

        if (IsTargetDead()) {
            PreviousStateLookDir = vector(Pawn.Rotation);
            AttackTarget = none;
            GotoState('Idle');
        }

        if (ShouldOpenFire())
            StartFiring();
        else
            StopFiring();

        if (CurrentCommand != CM_HoldPosition && (!IsInAttackRange() || !LineOfSightTo(AttackTarget)))
            GotoState('MoveToAttackTarget');
    }

Begin:
    StopMoving();
}

/** Must move closer to our target until we're in our optimal range for our weapon */
state MoveToAttackTarget {

    function BeginState() {
        SetTimer(AttackThinkInterval, true);
        Focus = AttackTarget;
    }

    /** Always ensure our AttackTarget is our focus, kinda an ass way of doing
     * things, but whatever. :P
     */
    function Timer() {
        Focus = AttackTarget;

        if (IsTargetDead()) {
            PreviousStateLookDir = vector(Pawn.Rotation);
            AttackTarget = none;
            GotoState('Idle');
        }

        if (ShouldOpenFire())
            StartFiring();
        else
            StopFiring();

        if (IsInAttackRange() && LineOfSightTo(AttackTarget))
            GotoState('AttackingTarget');
    }

Begin:
    while (!IsInAttackRange() || !LineOfSightTo(AttackTarget)) {
        if (ActorReachable(AttackTarget))
            MoveToward(AttackTarget);
		else {
			MoveTarget = FindPathToward(AttackTarget);

            if (MoveTarget != none)
				MoveToward(MoveTarget);
			else {
			    PreviousStateLookDir = vector(Pawn.Rotation);
				GotoState('Idle');
			}
		}
    }
}

defaultproperties
{
    CurrentCommand=CM_None
    PendingCommand=CM_None

    SuggestedWeapon=SW_None

    SupplySearchRadius=1024.0f
    SupplyPickupRadius=128.0f
    SupplyInterestSound=sound'WMaleDialog.wm_hmmmm'

    AttackCone=0.45f

    AttackRangePistol=2048.0f
    AttackRangeShotgun=128.0f
    AttackRangeMachineGun=1024.0f
    AttackRangeSniperRifle=16384.0f
    AttackRangePecker=192.0f

    ThreatFindRadius=3072.0f

    FollowPlayerRadiuses=(ReachedRadius=256.0f,CloseRadius=384.0f,FarRadius=512.0f)
    HoldPositionRadiuses=(ReachedRadius=96.0f,CloseRadius=128.0f,FarRadius=512.0f)

    IdleThinkInterval=0.5f
    FollowThinkInterval=0.1f
    HoldThinkInterval=0.1f
    PickupThinkInterval=0.1f
    AttackThinkInterval=0.1f
}