//=============================================================================
// The Cone Limit joint class.
//=============================================================================

#exec Texture Import File=Textures\KConeLimit.bmp Name=S_KConeLimit Mips=Off MASKED=1

class KConeLimit extends KConstraint
    native
    placeable;

var(KarmaConstraint) float KHalfAngle; // ( 65535 = 360 deg )
var(KarmaConstraint) float KStiffness;
var(KarmaConstraint) float KDamping;

//native final function KSetHalfAngle(float HalfAngle);
//native final function KSetStiffness(float Stiffness);
//native final function KSetDamping(float Damping);


defaultproperties
{
    KHalfAngle=8200 // about 45 deg
    KStiffness=50

    Texture=S_KConeLimit
    bDirectional=True
	DrawScale=0.25
}