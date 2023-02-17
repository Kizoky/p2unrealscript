/**
 * ParnterPawn
 *
 * A customized Pawn that displays unique properties. Since this pawn is a
 * persistant partner, he or she can't be killed off, but instead gets
 * incapacitated, can't have his or her head blown off, etc.
 */
class PartnerPawn extends Bystander;

/** How much faster your Partner should move to keep up with you */
var float PartnerSpeedScale;
/** Amount of damage your partner has taken so far */
var travel int PartnerDamage;

var float SayTime;

/** Subclassed to ensure your partner can keep up with you */
function PossessedBy(Controller C) {
    super.PossessedBy(C);

    GroundSpeed = default.GroundSpeed * PartnerSpeedScale;
    BaseMovementRate = default.BaseMovementRate * PartnerSpeedScale;
}

/** Subclassed to notify the AI Controller that the Pawn has been shot */
function TakeDamage(int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, class<DamageType> damageType) {
    PartnerDamage += Damage;

    if (Controller != none)
        Controller.NotifyTakeHit(instigatedBy, HitLocation, -Damage, DamageType, Momentum);
}

/** Stubbed out the features we don't want your partner to do */
function StartPuking(int newpuketype);
simulated function Notify_StartPuking();
function SetProtesting(bool bSet);
function EvaluateWeapons();
simulated function DissociateHead(bool bDestroyHead);
function ExplodeHead(vector HitLocation, vector Momentum);
function PopOffHead(vector HitLocation, vector Momentum);
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation);
simulated function ChunkUp(int Damage);

// Dialog calls
// Shortcuts to play various pawn dialog lines - Rick
function PlayDialog_Attack()
{
	if (Level.TimeSeconds > SayTime)
		SayTime = Level.TimeSeconds + Say(MyDialog.lSeesEnemy, true);
}
function PlayDialog_GetHit()
{
	if (Level.TimeSeconds > SayTime)
		SayTime = Level.TimeSeconds + Say(MyDialog.lGotHit, true);
}
function PlayDialog_AcceptCommand()
{
	//FIXME?!
}
function PlayDialog_Idle()
{
	//FIXME?!
}

defaultproperties
{
    PartnerSpeedScale=1.25f

    TakesShotgunHeadShot=0.25f
    TakesShovelHeadShot=0.35f
    TakesOnFireDamage=0.0f
    TakesAnthraxDamage=0.5f
    TakesShockerDamage=0.3f

    bStartupRandomization=false
    bChameleon=false

    HealthMax=200.0f

    //Gang="RWSStaff"
    DamageMult=2.5f

    ControllerClass=class'PartnerController'
	AmbientGlow=30
	bCellUser=false
}