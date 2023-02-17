/**
 * PLMountedWeaponPawn
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * Just a simple Pawn that has a property for identifying our mounted weapon
 *
 * @author Gordon Cheng
 */
class PLMountedWeaponPawn extends Bystander;

/** Tags of various objects our AI Controller needs to find */
var() name MountedWeaponTag;
var() name MountedWeaponPathNodeTag;
var() name NormalFiringPathNodeTag;

var rotator MountedWeaponRotationRate;

/** Misc objects and values */
var bool bUsingMountedWeapon;
var bool bPressingFire, bPressingAltFire;

var(PawnAttributes) string LieberModeWeapon;				// Weapon we should get in lieber mode

/** Overriden so we only setup movement animations, not the turn animations */
simulated function SetupAnims() {
	LinkAnims();

	TurnLeftAnim = '';
    TurnRightAnim = '';

	MovementAnims[0] = 's_walk1';
	MovementAnims[1] = 's_walk1';
	MovementAnims[2] = 's_strafel';
	MovementAnims[3] = 's_strafer';
}

/** Sets whether or not our mounted weapon Pawn is holding down fire
 * @param bNewPressingFire - Whether or not we're gonna be holding down fire
 */
function SetPressingFire(bool bNewPressingFire) {
    bPressingFire = bNewPressingFire;
}

/** Sets whether or not our mounted weapon Pawn is holding down alt fire
 * @param bNewPressingAltFire - Whether or not we're gonna be holding down alt fire
 */
function SetPressingAltFire(bool bNewPressingAltFire) {
    bPressingAltFire = bNewPressingAltFire;
}

/** Overriden so we can use new booleans separate from the normal bFire and bAltFire */
simulated function bool PressingFire() {
    return bPressingFire;
}

simulated function bool PressingAltFire() {
    return bPressingAltFire;
}

/** Animation names:
 * Minigun_Idle
 * Minigun_StrafeL
 * Minigun_StrafeR
 */

/** Overriden so we can use the mounted weapon movement animations */
simulated function SetAnimStanding() {
    if (bUsingMountedWeapon) {
        TurnLeftAnim = '';
        TurnRightAnim = '';
    }
    else
        super.SetAnimStanding();
}

simulated function SetAnimWalking() {
    if (bUsingMountedWeapon) {
        TurnLeftAnim = '';
        TurnRightAnim = '';
    }
    else
        super.SetAnimWalking();
}

simulated function SetAnimRunning() {
    if (bUsingMountedWeapon) {
        TurnLeftAnim = '';
        TurnRightAnim = '';
    }
    else
        super.SetAnimRunning();
}

simulated event PlayFalling() {
	if (bUsingMountedWeapon)
		return;
	else
		super.PlayFalling();
}

///////////////////////////////////////////////////////////////////////////////
// Adds all the required equipment and picks out the urethra.
// Do this here so we access to the inventory package for specific things
// like HandsWeapon and UrethraWeapon.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	local bool bGotDefault;
	
	bGotDefault = bGotDefaultInventory;
	Super.AddDefaultInventory();	
	
	// Only let this be called once
	if (!bGotDefault)
	{
		// In liebermode, change us out to a regular bystander controller and give us a shovel to fight the Dude with.
		if (P2GameInfo(Level.Game).InLieberMode())
		{
			CreateInventory(LieberModeWeapon);
			PawnInitialState = EP_AttackPlayer;
			Controller.ClientSetWeapon(class'HandsWeapon');
			Controller.Destroy();
			Controller = None;
			Controller = spawn(class'BystanderController');
			// Apparently the controller automatically checks the AI script here
			/*
			if(Controller != None )
			{
				Controller.Possess(self);
				AIController(Controller).Skill += SkillModifier;
				CheckForAIScript();
			}
			*/
		}
	}
	Controller.ClientSetWeapon(class'HandsWeapon');
}

defaultproperties
{
    ExtraAnims(10)=MeshAnimation'PLCharacters.animMountedWeaponPawn'
}
