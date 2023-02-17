///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class PLSuperChampController extends SuperChampController;

var() float FireballDistance;			// Minimum distance between us and our attacker before we throw a fireball at 'em
var() Vector FireballOffset;
var() class<GaryHeadHomingProjectile> FireballProjectileClass;
const MouthBone = 'Dummy07';
var int FireballCount;

///////////////////////////////////////////////////////////////////////////////
// Local spot to set my attacker, only assigns old when not none.
///////////////////////////////////////////////////////////////////////////////
function SetAttacker(FPSPawn NewAttacker)
{
	// Reset our fireball count
	if (NewAttacker != Attacker)
		FireballCount = 0;
		
	Super.SetAttacker(NewAttacker);
}

/** Returns the location in the world where the mouth of Mutant Champ is
 * @return Location in the world where Mutant Champ's mouth is at
 */
function vector GetMouthLocation() {
    if (MouthBone == '' || MouthBone == 'None' || Pawn == none)
        return vect(0,0,0);

    return Pawn.GetBoneCoords(MouthBone).Origin;
}

/** Returns the rotation of the mouth bone so that it points outward
 * @return Rotation of the mouth bone so it points outward
 */
function rotator GetMouthRotation() {
    if (MouthBone == '' || MouthBone == 'None' || Pawn == none)
        return rot(0,0,0);

    return Pawn.GetBoneRotation(MouthBone);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Run this target down and pounce on them till they're dead
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state AttackTarget
{
	event BeginState()
	{
		// Sometimes shoot a fireball instead
		if (FireballCount == 0 && VSize(Attacker.Location - MyPawn.Location) >= FireballDistance)
		{
			SetNextState('AttackTarget');
			GotoStateSave('FireballTarget');
		}
		Super.BeginState();
	}
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
state FireballTarget
{
	ignores GetReadyToReactToDanger, StartAttacking;
	
	///////////////////////////////////////////////////////////////////////////////
	// stop at the animation end, and go about as before
	///////////////////////////////////////////////////////////////////////////////
	function AnimEnd(int channel)
	{
		MyPawn.AnimEnd(channel);
		//log("anim end "$channel$" state count "$statecount);
		// Check for the base channel only
		if(channel == 0)
		{
			if(MyNextState == '')
				GotoStateSave('Thinking');
			else
			{
				MyPawn.SetAnimRunning();
				GotoNextState();
			}
		}
	}
	///////////////////////////////////////////////////////////////////////////////
	// laze, copied from MutantChamp
	///////////////////////////////////////////////////////////////////////////////
	function SpawnFireball()
	{
		local vector MouthLocation;
		local rotator MouthRotation;
		local GaryHeadHomingProjectile FireballProj;

		MouthRotation = GetMouthRotation() /*+ FireballRotationOffset*/;

		MouthLocation = GetMouthLocation() + class'P2EMath'.static.GetOffset(MouthRotation, FireballOffset);

		if (FireballProjectileClass != none) {
			FireballProj = Spawn(FireballProjectileClass, self,, MouthLocation, MouthRotation);

			if (FireballProj != none) {
				FireballProj.PrepVelocity(FireballProj.default.Speed * vector(MouthRotation));
				FireballProj.SetTarget(Attacker);
			}
		}
	}
	
Begin:	
	FireballCount++;
	MyPawn.StopAcc();
	Focus=Attacker;
	FinishRotation();
	PLSuperChamp(MyPawn).PlayFireballAttack();
	Sleep(0.16);
	SpawnFireball();
}

defaultproperties
{
	FireballDistance=500
	FireballProjectileClass=class'SuperChampHomingProjectile'
	FireballOffset=(X=30,Z=-100)
}