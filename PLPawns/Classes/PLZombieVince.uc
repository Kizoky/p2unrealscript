///////////////////////////////////////////////////////////////////////////////
// Vince after being zombified.
///////////////////////////////////////////////////////////////////////////////
class PLZombieVince extends PLZombie
	placeable;

// Vince needs to not use the turning anims when using these anims

simulated function PlayLaughingAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim(GetAnimLaugh(), 1.0, 0.15);
}
simulated function PlayYourFiredAnim()
{
	ChangePhysicsAnimUpdate(false);
	PlayAnim('s_fired', 1.0, 0.15);
}

// Let his tag be 'AWRWSVince'

defaultproperties
{
	ActorID="PLZombieVince"

	HeadSkin=Texture'PLCharacterSkins.Zombie_Head.ZombieVince'
	HeadMesh=SkeletalMesh'heads.AvgMale'
	Mesh=SkeletalMesh'Characters.Avg_M_SS_Pants_D'
	Skins[0]=Texture'PLCharacterSkins.Zombie.ZombieVince_Pants'
	DialogClass=class'DialogZombieVince'
	bPersistent=True
	bCanTeleportWithPlayer=False
	bKeepForMovie=True
	bRandomizeHeadScale=False
	bStartupRandomization=False
}
