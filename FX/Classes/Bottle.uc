///////////////////////////////////////////////////////////////////////////////
// Our breakable version of a window that blocks when it's not dead
// but turns off collision when broken.
///////////////////////////////////////////////////////////////////////////////

class Bottle extends Window;

var() color ParticleColor;

const MOMENTUM_RATIO = 0.02;
const MOM_MAX	=	20000;

///////////////////////////////////////////////////////////////////////////////
// Orient the breaking effect and size it
///////////////////////////////////////////////////////////////////////////////
function FitTheEffect(P2Emitter pse, int damage, vector HitLocation, vector HitMomentum)
{
	local float xsize, xradsize, yradsize, zradsize;
	local vector vecrot;
	local float totalarea, startarea;
	local float usedot;
	local float velmag;
	local int i;
	local int newmax;

	// Cap the momentum, so explosions and such don't send them so absurdly far
//	if(VSize(HitMomentum) < MOM_MAX)
//		HitMomentum = MOM_MAX*Normal(HitMomentum);

	pse.Emitters[0].StartLocationRange.X.Max =  CollisionRadius;
	pse.Emitters[0].StartLocationRange.X.Min = -CollisionRadius;
	pse.Emitters[0].StartLocationRange.Y.Max =  CollisionRadius;
	pse.Emitters[0].StartLocationRange.Y.Min = -CollisionRadius;
	pse.Emitters[0].StartLocationRange.Z.Max =  CollisionHeight;
	pse.Emitters[0].StartLocationRange.Z.Min = -CollisionHeight;

	// Use this as your speed from the emitter, but also throw in some
	// of the damage.
	pse.Emitters[0].StartVelocityRange.X.Max=MOMENTUM_RATIO*HitMomentum.x + pse.Emitters[0].StartVelocityRange.X.Max;
	pse.Emitters[0].StartVelocityRange.X.Min=-pse.Emitters[0].StartVelocityRange.X.Max/8;
	pse.Emitters[0].StartVelocityRange.Y.Max=MOMENTUM_RATIO*HitMomentum.y;
	pse.Emitters[0].StartVelocityRange.Y.Min=-pse.Emitters[0].StartVelocityRange.Y.Max/8;
	pse.Emitters[0].StartVelocityRange.Z.Max=MOMENTUM_RATIO*HitMomentum.z;
	pse.Emitters[0].StartVelocityRange.Z.Min=-pse.Emitters[0].StartVelocityRange.Z.Max/8;

	// Color the emitters
	for(i=0; i<pse.Emitters.Length; i++)
	{
		pse.Emitters[i].ColorScale[0].Color = ParticleColor;
		pse.Emitters[i].ColorScale[0].RelativeTime = 0.0;

		pse.Emitters[i].ColorScale[1].Color = ParticleColor;
		pse.Emitters[i].ColorScale[1].RelativeTime = 1.0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Only projectiles can break this
///////////////////////////////////////////////////////////////////////////////
function Bump( actor Other )
{
	local FPSPawn pawnbumper;
	local Pickup pickbumper;
	local P2PowerupPickup p2pickbumper;
	local Projectile projbumper;
	local int damage;
	local float usedot;

	projbumper = Projectile(Other);
	if(projbumper != None)
	{
		damage = VSize(projbumper.Velocity)/PROJECTILE_DAMAGE_RATIO;
		TakeDamage(damage, None, Location, -(projbumper.Velocity/4), class'KickingDamage');
		return;
	}
}

defaultproperties
{
	DrawType=DT_StaticMesh
	StaticMesh = StaticMesh'Timb_mesh.fooo.40oz'
	BreakEffectClass=Class'ShatterBottle'
	BreakingSound=Sound'MiscSounds.Glass.bottleBreak'
	CollisionRadius=12
	CollisionHeight=24
	DamageFilter=class'BurnedDamage'
	bBlockFilter=true
	bBlockActors=true
	BreakPct=0.70
	ParticleColor=(G=200,R=230)
	DangerMarker=None
}

