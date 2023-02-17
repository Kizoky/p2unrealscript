/**
 * MutantChampCollision
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Due to Mutant Champ's large size and shape, we need to use these boltons
 * in order to accurately model Mutant Champ's collision, otherwise we would
 * have large sections of his body that bullets can pass right through
 *
 * @author Gordon Cheng
 */
class MutantChampCollision extends PeoplePart;

var float DamageMult;
var MutantChamp MutantChamp;

/** Overriden so we can pass TakeDamage calls over to Mutant Champ */
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType) {
    if (MutantChamp != none)
        MutantChamp.TakeDamage(Damage * DamageMult, EventInstigator, HitLocation, Momentum, DamageType);
}

/** Overriden so we can pass touches we get over to Mutant Champ */
event Touch(Actor Other) {
    if (Projectile(Other) != none && Other.Owner != MutantChamp)
        Projectile(Other).ProcessTouch(MutantChamp, Other.Location);
}

defaultproperties
{
    DamageMult=1.0

    DrawType=DT_StaticMesh

    StaticMesh=StaticMesh'PL-KamekMesh.MutantChamp.CollisionBolton'
	Skins(0)=Shader'PL-KamekTex.derp.invisitex'
	//Skins(0)=Texture'PL-KamekTex.derp.ColAlphaTexActive'

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
	Physics=PHYS_None
}