/**
 * ObeseBitchCollision
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Your ex-wife has gotten so bloated and massive, she needs these special
 * collision boltons to properly calculate collision for her massive size
 *
 * @author Gordon Cheng
 */
class ObeseBitchCollision extends PeoplePart;

var float DamageMult;
var Pawn ObeseBitch;

/** Overriden so we can pass TakeDamage calls over to Obese Bitch */
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType) {
    if (ObeseBitch != none)
        ObeseBitch.TakeDamage(Damage * DamageMult, EventInstigator, HitLocation, Momentum, DamageType);
}

/** Overriden so we can pass touches we get over to Obese Bitch */
event Touch(Actor Other) {
    if (Projectile(Other) != none && Other.Owner != ObeseBitch)
        Projectile(Other).ProcessTouch(ObeseBitch, Other.Location);
}

defaultproperties
{
    DamageMult=1.0

    DrawType=DT_StaticMesh

    StaticMesh=StaticMesh'PL-KamekMesh.MutantChamp.CollisionBolton'
	Skins(0)=Shader'PL-KamekTex.derp.invisitex'

	bHidden=false

	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=false
	bCollideWorld=true
	bBlockZeroExtentTraces=true
	bBlockNonZeroExtentTraces=true
	bUseCylinderCollision=false
	bProjTarget=true
	bStopsRifle=true
}