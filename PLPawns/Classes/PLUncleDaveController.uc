///////////////////////////////////////////////////////////////////////////////
// PLUncleDaveController
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// Extends the PartnerController but we want to do some other stuff
///////////////////////////////////////////////////////////////////////////////
class PLUncleDaveController extends PartnerController;

///////////////////////////////////////////////////////////////////////////////
// Possess the pawn
///////////////////////////////////////////////////////////////////////////////
function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	P2MoCapPawn(aPawn).AddDefaultInventory();
	CheckPartnerInventory();
	SwitchToHands();
}

/** Sets the specified Actor as a target and goes into an attack state if it is valid
 * @param Other - Actor object that can potentially be a target
 */
function SetAttackTarget(Actor Other) {
    if (IsValidTarget(Other)) {
        AttackTarget = Other;
        AttackRange = GetAttackRange(Other);
        EquipWeapon();

        if (!IsInState('MoveToHoldPosition')) {
			// Allow Uncle Dave to attack when holding position. - Rick
            if (IsInAttackRange() || CurrentCommand == CM_HoldPosition)
                GotoState('AttackingTarget');
            else if (CurrentCommand != CM_HoldPosition)
                GotoState('MoveToAttackTarget');
        }
    }
}

/** Returns whether or not your Partner is in attack range
 * @return TRUE if your partner is in range; FALSE otherwise
 */
function bool IsInAttackRange() {
    if (AttackTarget != none)
		// Just have him wail away when holding position. - Rick
        return (VSize(AttackTarget.Location - Pawn.Location) <= AttackRange) || (CurrentCommand == CM_HoldPosition);
    else
        return false;
}
