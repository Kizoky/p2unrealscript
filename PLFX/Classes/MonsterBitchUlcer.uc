///////////////////////////////////////////////////////////////////////////////
// MonsterBitchUlcer
// Copyright 2015, Running With Scissors, Inc. All Rights Reserved
//
// A gross, throbbing ulcer within the belly of the Monster Bitch.
// Shoot up enough of these to escape her insides!
///////////////////////////////////////////////////////////////////////////////
class MonsterBitchUlcer extends PropBreakable;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var(PropBreakable) array<Sound> HitSounds;	// Sounds made when damage dealt
var(PropBreakable) float ThrobPct;
var(PropBreakable) float ThrobBase;
var(PropBreakable) float ThrobAmp;
var float BaseDrawScale;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	BaseDrawScale = DrawScale;
}

///////////////////////////////////////////////////////////////////////////////
// Constantly throbbing and pulsating... so gross!
///////////////////////////////////////////////////////////////////////////////
event Tick(float dT)
{
	Super.Tick(dT);
	SetDrawScale(BaseDrawScale + ThrobPct * (Sin(ThrobAmp * Level.TimeSeconds) + ThrobBase));
}

///////////////////////////////////////////////////////////////////////////////
// If strong enough, it breaks the prop
///////////////////////////////////////////////////////////////////////////////
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// Check first if we take this damage
	if(!AcceptThisDamage(damageType))
		return;
		
	// Play a blood splat when hurt
	Spawn(class'BloodImpactMaker',self,,HitLocation,Rotation);
	
	// Play a sound when hurt
	PlaySound(HitSounds[Rand(HitSounds.Length)]);
		
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

///////////////////////////////////////////////////////////////////////////////
// Set it to dead, trigger sounds and all, and blow it up, setting off the physics
///////////////////////////////////////////////////////////////////////////////
function BlowThisUp(int Damage, vector HitLocation, vector Momentum)
{
	local P2Emitter p2e;

	// Instead of breaking, we simply disappear and turn off collision, so we can be turned back on again later.
	SetCollision(false, false, false);
	bHidden = true;
	
	// Reset health
	Health = Default.Health;

	// Spawn effect so we don't have to record the hit values and 
	// do it later in Broken beginstate or something. It's just
	// more efficient here
	p2e = spawn(BreakEffectClass,,,Location);
	if(bFitEffectToProp)
		FitTheEffect(p2e, damage, HitLocation, momentum);

	// Play the breaking sound (code copied from mover)
	PlaySound( BreakingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, 0.96 + FRand()*0.8);	

	// Trigger breaking event, if any.
	if (Event != '')
		TriggerEvent(Event, self, Instigator);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Timb_mesh.fooo.nasty_deli2_timb'
	Health=50
	AmbientGlow=192
	BreakEffectClass=class'CatExplosion'
	BrokenStaticMesh=None
	HitSounds[0]=Sound'WeaponSounds.bullet_hitflesh1'
	HitSounds[1]=Sound'WeaponSounds.bullet_hitflesh2'
	HitSounds[2]=Sound'WeaponSounds.bullet_hitflesh3'
	HitSounds[3]=Sound'WeaponSounds.bullet_hitflesh4'
	ThrobPct=0.75
	ThrobBase=2.0
	ThrobAmp=2.0
}