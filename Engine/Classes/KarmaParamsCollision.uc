//=============================================================================
// The Karma Collision parameters class.
// This provides 'extra' parameters needed to create Karma collision for this Actor.
// You can _only_ turn on collision, not dynamics.
// NB: All parameters are in KARMA scale!
//=============================================================================

class KarmaParamsCollision extends Object
	editinlinenew
	native;

// Used internally for Karma stuff - DO NOT CHANGE!
var transient const int     KarmaData;

var const float				KScale;  // Usually kept in sync with actor's DrawScale, this is how much to scale moi/com-offset (but not mass!)

var()    float   KFriction;          // Multiplied pairwise to get contact friction
var()    float   KRestitution;       // 'Bouncy-ness' - Normally between 0 and 1. Multiplied pairwise to get contact restitution.
var()    float   KImpactThreshold;   // threshold velocity magnitude to call KImpact event

// default is sphere with mass 1 and radius 1
defaultproperties
{
    KFriction=0.7
	KRestitution=0.3
    KImpactThreshold=250
	KScale=1
}