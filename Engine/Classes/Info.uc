//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force,Shadow)
	native;

defaultproperties
{
     bHidden=True
	 bOnlyDirtyReplication=true
	 bSkipActorPropertyReplication=true
}
