/**
 * PLBossPawn
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * This is designed to be the base for bosses that the Dude will have to face.
 * They're much tougher in that you simply can't hit them with weapons that
 * cut off their limbs and kill them instantly.
 *
 * You're gonna have to do it the old fashion way which is simply shoot them
 * with a lot of bullets
 *
 * @author Gordon Cheng
 */
class PLBossPawn extends Bystander;

var name PeacefulTakedownEvent, ViolentTakedownEvent;

///////////////////////////////////////////////////////////////////////////////
// PostBeginPlay - Modify health and damage based on difficulty.
// Only scale down for the easier difficulties - we didn't test scaling UP
// for the harder difficulties, so we're just gonna leave 'em as is.
///////////////////////////////////////////////////////////////////////////////
simulated event PostBeginPlay()
{
	local float DiffMod;
	local float UseMul;
	
	Super.PostBeginPlay();
	DiffMod = P2GameInfo(Level.Game).GetDifficultyOffset();
	if (DiffMod < 0)
	{
		UseMul = 1 + DiffMod / 10.0;
		HealthMax *= UseMul;
		Health *= UseMul;
		DamageMult *= UseMul;
	}
}

/** Overriden to prevent the SawnOff Shotgun for exploding boss' heads */
function ExplodeHead(vector HitLocation, vector Momentum) {
    if (Health <= 0)
        super.ExplodeHead(HitLocation, Momentum);
}

/** Overriden to prevent instant kills from severing */
function bool HandleSever(Pawn InstigatedBy, vector Momentum, out class<DamageType> DamageType, int CutIndex, out int Damage, out vector HitLocation) {
    if (Health > 0)
        return true;
    else
        return super.HandleSever(Instigatedby, Momentum, DamageType, CutIndex, Damage, HitLocation);
}

/** Overriden to prevent instant kills from head trauma */
function bool HandleSledge(Pawn InstigatedBy, vector Momentum, out class<DamageType> DamageType, out int Damage, out vector HitLocation) {
    if (Health > 0)
        return true;
    else
        return super.HandleSledge(Instigatedby, Momentum, DamageType, Damage, HitLocation);
}

/** Overriden to prevent instant hills from being cut in half */
function bool HandleScythe(Pawn InstigatedBy, out vector Momentum, out class<DamageType> DamageType, out int Damage, out vector HitLocation) {
    if (Health > 0)
        return true;
    else
        return super.HandleScythe(Instigatedby, Momentum, DamageType, Damage, HitLocation);
}

/** Overriden just to be sure */
function bool HandleBali(Pawn InstigatedBy, out vector Momentum, out class<DamageType> DamageType, out int Damage, out vector HitLocation) {
    if (Health > 0)
        return true;
    else
        return super.HandleBali(Instigatedby, Momentum, DamageType, Damage, HitLocation);
}

/** Overriden so we always deal normal damage specified in the AmmoType. We
 * don't take the Dude's damage multiplier into consideration
 */
function int ModifyDamageByBodyLocation( int Damage, Pawn InstigatedBy,
						  vector HitLocation, vector Momentum,
						  out class<DamageType> ThisDamage,
						  out byte HeadShot) {
    return Damage;
}

/** Overriden to prevent some special cases such as the Sawn off shotgun and Chainsaw */
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType) {
    // SawnOff Shotguns deal Damage = Health for instant kills
    // Prevent this on bosses
    if (ClassIsChildOf(DamageType, class'SuperShotgunDamage') ||
        ClassIsChildOf(DamageType, class'SuperShotgunBodyDamage'))
        Damage = class'ShotGunBulletAmmoInv'.default.DamageAmount;

    // Reduce damage from chainsaw to prevent instant cheese kills
	if (ClassIsChildOf(DamageType, class'ChainSawBodyDamage') ||
        ClassIsChildOf(DamageType, class'ChainSawDamage'))
		Damage = 1;

    super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

/** Overriden so we can provide events for both peaceful and violent takedowns */
function Died(Controller Killer, class<DamageType> DamageType, vector HitLocation) {
    if (Killer == none || Killer == Controller)
        TriggerEvent(PeacefulTakedownEvent, self, Killer.Pawn);
    else
        TriggerEvent(ViolentTakedownEvent, self, none);

    super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
{
    bRandomizeHeadScale=false
	bStartupRandomization=false
	bNoChamelBoltons=true

	RotationRate=(Pitch=0,Yaw=48000,Roll=0)
	AmbientGlow=30
}