///////////////////////////////////////////////////////////////////////////////
// Dusters ammo
///////////////////////////////////////////////////////////////////////////////
class DustersAmmoInv extends FistsAmmoInv;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function ProcessTraceHit(Weapon W, Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	Super.ProcessTraceHit(W, Other, HitLocation, HitNormal, X, Y, Z);
	
	// If we hit a pawn make the weapon a little bloody
	if ((W.Class == class'DustersWeapon')
		&& Pawn(Other) != None
		&& (P2MocapPawn(Other) == None
		|| P2MocapPawn(Other).MyRace < RACE_Automaton))
		{
			//log(W.Class@P2MoCapPawn(Other)@P2MoCapPawn(Other).MyRace);
			P2BloodWeapon(W).DrewBlood();
		}
}

defaultproperties
{
	DamageJab=5
	DamageUppercut=10
	DamageDownward=20
	DamageHeadPunch=100
	Texture=Texture'EDHud.hud_Dusters'
	DamageTypeInflicted=class'DustersDamage'
	DamageTypeInflictedNPC=class'DustersDamage'
	bAllowHeadPunch=true
}
