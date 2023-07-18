//=============================================================================
// NPC Dude Pawn for DudeVSDude cheat 
//=============================================================================
class PostalDudeNPC extends Bystanders
	placeable;

var() Material PostInjuryHeadSkin;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (P2GameInfoSingle(Level.Game).IsWeekend())
		MyHead.Skins[1] = PostInjuryHeadSkin;
}

defaultproperties
	{
	ActorID="Dude"
	Mesh=Mesh'Characters.Avg_Dude'
	Skins[0]=Texture'ChameleonSkins.Special.Dude'
	//HeadSkin=Texture'ChamelHeadSkins.Special.Dude'
	//HeadMesh=Mesh'Heads.AvgDude'
	DialogClass=class'BasePeople.DialogDudeNPC'
	
	ADJUST_RELATIVE_HEAD_Y=-2
	HeadClass=Class'AWDudeHead'
    HeadSkin=Texture'AW_Characters.Special.Dude_AW'
	PostInjuryHeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	
	bNoChamelBoltons=true
	bIsTrained=true
	BaseEquipment[0]=(weaponclass=class'Inventory.PistolWeapon')
	BaseEquipment[1]=(weaponclass=class'Inventory.MachinegunWeapon')
	bPlayerIsFriend=False
	bPlayerIsEnemy=True
	Gang="DudeClones"
	bRandomizeHeadScale=false
	bStartupRandomization=false
	HealthMax=200
	PainThreshold=1.0
	Rebel=1.0
	DamageMult=2.5
	Cajones=1.0
	Stomach=1.0
	Psychic=0.4
	Glaucoma=0.3
	ViolenceRankTolerance=0
	FriendDamageThreshold=170
	TakesShotgunHeadShot=	0.25
	TakesShovelHeadShot=	0.35
	TakesOnFireDamage=		0.4
	TakesAnthraxDamage=		0.5
	TakesShockerDamage=		0.3
	TakesChemDamage=		0.6
	TakesPistolHeadShot=	0.25
	BlockMeleeFreq=1.0
	}
