/**
 * BanditLeader
 * Copyright 2014, Running With Scissors, Inc. All Rights Reserved.
 *
 * The leader of the bandits that wields a minigun. Totally not compensating.
 *
 * @author Gordon Cheng
 */
class BanditLeader extends PLMountedWeaponPawn
    placeable;
	
var() string TwoEarsHealthText;	// Text to search for
var() localized string HealthBarText_Wuss;
var() localized string HealthBarText_Easy;
var() localized string HealthBarText_Normal;
var() localized string HealthBarText_Moderate;
var() localized string HealthBarText_Hard;
var() localized string HealthBarText_Badass;
var() localized string HealthBarText_SuperBadass;
var() localized string HealthBarText_Impossible;

// 5/15 - Make the "level" of Two-Ears variable based on game difficulty
simulated event PostBeginPlay()
{
	local ScriptedSequence S;
	local int i;
	local int Diff;
	local string HealthBarText;
	
	Super.PostBeginPlay();
	
	Diff = P2GameInfo(Level.Game).GetGameDifficulty();
	if (Diff < 4)
		HealthBarText = HealthBarText_Easy;
	else if (Diff < 6)
		HealthBarText = HealthBarText_Moderate;
	else if (Diff < 8)
		HealthBarText = HealthBarText_Hard;
	else if (Diff <= 10)
		HealthBarText = HealthBarText_Badass;

	if (P2GameInfo(Level.Game).InLieberMode())
		HealthBarText = HealthBarText_Wuss;
	if (P2GameInfo(Level.Game).InHestonMode() || P2GameInfo(Level.Game).InNightmareMode())
		HealthBarText = HealthBarText_SuperBadass;
	if (P2GameInfoSingle(Level.Game).InImpossibleMode())
		HealthBarText = HealthBarText_Impossible;
	
	// Find any scripted sequences that set up Two-Ears's health bar and change the text
	foreach AllActors(class'ScriptedSequence', S)
	{
		for (i = 0; i < S.Actions.Length; i++)
			if (ACTION_EnemyHealth(S.Actions[i]) != None && ACTION_EnemyHealth(S.Actions[i]).HealthBarText == TwoEarsHealthText)
				ACTION_EnemyHealth(S.Actions[i]).HealthBarText = HealthBarText;
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

defaultproperties
{
	ActorID="BanditLeader"

    bRandomizeHeadScale=false
	bStartupRandomization=false
	bNoChamelBoltons=true

	RotationRate=(Pitch=0,Yaw=48000,Roll=0)
	MountedWeaponRotationRate=(Pitch=0,Yaw=4000,Roll=0)

    ControllerClass=none

    Mesh=SkeletalMesh'PLCharacters.Avg_Bandit'

    Skins(0)=Texture'PLCharacterSkins.Bandits.MW__410__Avg_Bandit'
	HeadSkin=Texture'ChamelHeadSkins.Male.MWA__006__AvgMale'
	Boltons(0)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_leather_mask',bAttachToHead=True)
	Boltons(1)=(Bone="NODE_Parent",StaticMesh=StaticMesh'PLCharacterMeshes.Bandit.bandit_mohawk',bAttachToHead=True)

    HealthMax=1000

    Gang="Bandits"

	PawnInitialState=EP_Turret
	AmbientGlow=30
	bCellUser=false
	
	TwoEarsHealthText="**TwoEarsHealth**"
	HealthBarText_Wuss="01 Two-Ears"
	HealthBarText_Easy="15 Two-Ears"
	HealthBarText_Normal="32 Two-Ears"
	HealthBarText_Moderate="52 Two-Ears"
	HealthBarText_Hard="63 Two-Ears"
	HealthBarText_Badass="74 Two-Ears"
	HealthBarText_SuperBadass="82 Two-Ears"
	HealthBarText_Impossible="112 Two-Ears the Almost Invincible"

	bNoDismemberment=True
	TakesShotgunHeadShot=0.1
}
