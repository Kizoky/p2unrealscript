///////////////////////////////////////////////////////////////////////////////
// ColeMen
// Copyright 2014, Running With Scissors, Inc. All Rights Reserved
//
// These midgets at least have a bit more sense than Borderlands's.
///////////////////////////////////////////////////////////////////////////////
class ColeMen extends Bystander
	placeable;
	
const FRIENDLY_DAY = 3;		// Friends with the dude on Thursday, when he's working for us.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function GameInfoIsNowValid()
{
	local String MyGang;
	local Inventory Inv;
	
	MyGang = Gang;
	
	// On the day designated as our "friendly day" we will be friends with the Dude.
	// However, if the game is in They Hate Me mode, we won't be friends but we won't attack them either.
	if (P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).GetCurrentDay() == FRIENDLY_DAY
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& !P2GameInfoSingle(Level.Game).IsPlayerReadyForHome())	// But NOT when the errands are completed - they turn hostile during the ColeMine escape.
	{
		bPlayerIsEnemy = false;
		bPlayerHater = false;
		// Reset our gang, too - Impossible mode sets all NPCs to the same gang so they'll all beat up on the player. We obviously don't want that
		Gang = MyGang;
		// If we're NOT in They Hate Me, set us as being friends
		if (!P2GameInfo(Level.Game).TheyHateMeMode())
		{
			bPlayerIsFriend = true;
			if (HealthMax / 4 > FriendDamageThreshold)
				FriendDamageThreshold = HealthMax / 4;
		}
		// Otherwise, take away our guns - this is a cheap way of ensuring that they won't interfere with the carnage between the player and the rest of the world
		else
		{
			// Removing inventory items breaks the chain, so we just run through the whole list each time until they have no violent weapons left.
			while (bHasViolentWeapon)
			{
				for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
				{
					if (P2Weapon(Inv) != None && P2Weapon(Inv).ViolenceRank > 0)
					{
						DeleteInventory(Inv);
						break;
					}
				}
				EvaluateWeapons();
			}
		}
	}
}

	
///////////////////////////////////////////////////////////////////////////////
// Setup dialog
///////////////////////////////////////////////////////////////////////////////
function SetupDialog()
{
	Super.SetupDialog();

	if (bStartupRandomization)
		RandomizeAttribute(VoicePitch, RAND_ATTRIBUTE_DEFAULT, 1.75, 1.35);	// Higher pitched voices for little people. It's supposed to be funny or something, laugh dammit !
}

///////////////////////////////////////////////////////////////////////////////
// Get ready
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	bIsFeminine=false;		// Never use feminine walk for these
	bIsGhetto=false;		// Also never use ghetto walk
	SetAnimWalking();		// Reset walking anims to normal
	// Try the friendly check immediately, if it fails then GameInfo will call it again for us.
	GameInfoIsNowValid();
}

///////////////////////////////////////////////////////////////////////////////
// Setup movement
///////////////////////////////////////////////////////////////////////////////
simulated function SetAnimWalking()
{
	Super.SetAnimWalking();
	
	// Never use "s_walk4" for these guys, not sure why it's being set...
	if (MovementAnims[0] == 's_walk4')
		MovementAnims[0] = 's_walk1';
	if (MovementAnims[1] == 's_walk4')
		MovementAnims[1] = 's_walk1';
	if (MovementAnims[2] == 's_walk4')
		MovementAnims[2] = 's_walk1';
	if (MovementAnims[3] == 's_walk4')
		MovementAnims[3] = 's_walk1';
}


	
defaultproperties
{
	ActorID="ColeMen"

	Skins[0]=Texture'PLCharacterSkins.ColeMen.XX__420__Mini_M_Jacket_Pants'
	Mesh=SkeletalMesh'Gary_Characters.Mini_M_Jacket_Pants'
	ChameleonMeshPkgs(0)="Gary_Characters"
	ChameleonSkins(0)="PLCharacterSkins.ColeMen.MB__420__Mini_M_Jacket_Pants"
	ChameleonSkins(1)="PLCharacterSkins.ColeMen.MM__421__Mini_M_Jacket_Pants"
	ChameleonSkins(2)="PLCharacterSkins.ColeMen.MW__422__Mini_M_Jacket_Pants"
	ChameleonSkins(3)="end"	// end-of-list marker (in case super defines more skins)
	Gang="ColeMen"
	BaseEquipment[0]=(weaponclass=class'Inventory.MachineGunWeapon')
	HealthMax=100
	BlockMeleeFreq=0.40
	Beg=0.1
	PainThreshold=0.9
	Cajones=0.9
	Rebel=0.8
	WillDodge=0.600000
	WillKneel=0
	WillUseCover=0.700000
	Stomach=0.8
	VoicePitch=1.5
	CharacterType=CHARACTER_Mini
	CoreMeshAnim=MeshAnimation'Gary_Characters.animMini'
	PeeBody=class'UrineSmallBodyDrip'
	GasBody=class'GasSmallBodyDrip'
    StumpClass=Class'StumpGary'
    LimbClass=Class'LimbGary'
    AW_SPMeshAnim=MeshAnimation'AWGary_Characters.animMini_AW'
	ExtraAnims(0)=MeshAnimation'MP_Gary_Characters.anim_GaryMP'
	PLAnims=MeshAnimation'Gary_Characters.animMini_PL'
	
	RandomizedBoltons(0)=None
	RandomizedBoltons(1)=None
	RandomizedBoltons(2)=None
	RandomizedBoltons(3)=None
	RandomizedBoltons(4)=None
	RandomizedBoltons(5)=None
	RandomizedBoltons(6)=None
	RandomizedBoltons(7)=None	
	AmbientGlow=30
	bCellUser=false
	HEAD_RATIO_OF_FULL_HEIGHT=0.1
}