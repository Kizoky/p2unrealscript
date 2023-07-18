///////////////////////////////////////////////////////////////////////////////
// Player Mutator
//
// This is a sample Workshop mod based off of P2GameMod.
// Feel free to copy this code and use it it as a basis for your own player mods.
//
// This code was written by Man Chrzan
///////////////////////////////////////////////////////////////////////////////

class SamplePlayerMod extends P2GameMod;

//////////////////////////////////////////////
// Variables and stuff
//////////////////////////////////////////////
var Mesh MyBodyMesh;
var Texture MyBodySkin;
var Mesh MyHeadMesh;
var array<Texture> MyHeadSkins;
var Texture MyInjuriedHeadSkin;
var Texture MyHandsTexture;
var Texture MyFootTexture;

var Mesh MyCopBodyMesh;
var Texture MyCopBodySkin;
var Texture MyCopHandsTexture;
var Texture MyCopFootTexture;

var Mesh MyGimpBodyMesh;
var Texture MyGimpBodySkin;
var Mesh MyGimpHeadMesh;
var Texture MyGimpHeadSkin;
var Texture MyGimpHandsTexture;
var Texture MyGimpFootTexture;

var class<P2Dialog> MyDialogClass;
var array<Sound> MyDudeBladeKill;
var array<Sound> MyDudeZombieKill;
var array<Sound> MyDudeMacheteThrow;
var array<Sound> MyDudeMacheteCatch;
var array<Sound> MyDudeButtHit;
var array<Sound> MyDudeHalloweenKill;
var Sound MySuicideSound, MyWrongItemSound;

var string MyHUDClass;

var bool CustomGimpClothes;
var bool CustomCopClothes;
var bool CustomDialog;
var bool CustomHUD;

//////////////////////////////////////////////
// De Code
//////////////////////////////////////////////
function ModifyPlayerInventory(Pawn Other)
{
	local P2Player myPlayer;
	local int i;
	Super.ModifyPlayerInventory(Other);
	myPlayer = P2Player(Other.Controller);
	if( myPlayer != None )
	{
		myPlayer.ChangeAllWeaponHandTextures(MyHandsTexture, MyFootTexture);
		
		if(CustomDialog)
		{
			// Blade Kill
			myPlayer.DudeBladeKill.Length = 0;
			myPlayer.DudeBladeKill.Insert(myPlayer.DudeBladeKill.Length, MyDudeBladeKill.Length);
			
			for(i=0; i<myPlayer.DudeBladeKill.Length; i++)
			{
				myPlayer.DudeBladeKill[i] = MyDudeBladeKill[i];
			}
			
			// Machete Throw
			myPlayer.DudeMacheteThrow.Length = 0;
			myPlayer.DudeMacheteThrow.Insert(myPlayer.DudeMacheteThrow.Length, MyDudeMacheteThrow.Length);
			
			for(i=0; i<myPlayer.DudeMacheteThrow.Length; i++)
			{
				myPlayer.DudeMacheteThrow[i] = MyDudeMacheteThrow[i];
			}
			
			// Machete Catch
			myPlayer.DudeMacheteCatch.Length = 0;
			myPlayer.DudeMacheteCatch.Insert(myPlayer.DudeMacheteCatch.Length, MyDudeMacheteCatch.Length);
			
			for(i=0; i<myPlayer.DudeMacheteCatch.Length; i++)
			{
				myPlayer.DudeMacheteCatch[i] = MyDudeMacheteCatch[i];
			}
			
			// Cow Ass 
			myPlayer.DudeButtHit.Length = 0;
			myPlayer.DudeButtHit.Insert(myPlayer.DudeButtHit.Length, MyDudeButtHit.Length);
			
			for(i=0; i<myPlayer.DudeButtHit.Length; i++)
			{
				myPlayer.DudeButtHit[i] = MyDudeButtHit[i];
			}
			
			// Zombies
			myPlayer.DudeZombieKill.Length = 0;
			myPlayer.DudeZombieKill.Insert(myPlayer.DudeZombieKill.Length, MyDudeZombieKill.Length);
			
			for(i=0; i<myPlayer.DudeZombieKill.Length; i++)
			{
				myPlayer.DudeZombieKill[i] = MyDudeZombieKill[i];
			}	
			
			// Halloween
			myPlayer.DudeHalloweenKill.Length = 0;
			myPlayer.DudeHalloweenKill.Insert(myPlayer.DudeHalloweenKill.Length, MyDudeHalloweenKill.Length);
			
			for(i=0; i<myPlayer.DudeHalloweenKill.Length; i++)
			{
				myPlayer.DudeHalloweenKill[i] = MyDudeHalloweenKill[i];
			}
		}
	}
}

function ModifyAppearance(Pawn Other)
{
	local MpPawn aPawn; 
	if( Other != None && AWDude(Other) != None )
	{
		aPawn = MpPawn(Other);

		if(CustomDialog)
		{
			aPawn.DialogClass = MyDialogClass;
			aPawn.SetupDialog();
			aPawn.DudeSuicideSound = MySuicideSound;
		}
		
		aPawn.SetMyMesh(MyBodyMesh);
		aPawn.Skins[0] = MyBodySkin;
		aPawn.HandsTexture = MyHandsTexture;
		aPawn.FootTexture = MyFootTexture;

		if( AWPostalDude(Other) != None )
		{
			//AWPostalDude(Other).ExpectedHeadMesh = MyHeadMesh;
			AWPostalDude(Other).PreInjuryHeadSkin = MyHeadSkins[1];
			AWPostalDude(Other).PostInjuryHeadSkin = MyInjuriedHeadSkin;
		}

		if( aPawn.myHead != None )
		{
			aPawn.myHead.LinkMesh(MyHeadMesh);
			aPawn.myHead.Setup(MyHeadMesh, MyHeadSkins[0], vect(1,1,1), aPawn.AmbientGlow);
			aPawn.myHead.Skins[0] = MyHeadSkins[0];		// Glitched hair skin fix
			aPawn.myHead.Skins[1] = MyHeadSkins[1];		// Head skin
		}
	}

	Super.ModifyAppearance(Other);
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	if(CustomHUD)
		P2GameInfo(Level.Game).HudType = MyHUDClass;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetupClothes();
}

event PostLoadGame()
{
	Super.PostLoadGame();
	SetupClothes();
}

function SetupClothes()
{
	// Modify Dude's Clothes
	if(CustomGimpClothes)
	{
		DynamicLoadObject("Inventory.DudeClothesInv", class'Class');
		class'Inventory.DudeClothesInv'.default.HandsTexture = MyHandsTexture;
		class'Inventory.DudeClothesInv'.default.FootTexture = MyFootTexture;
		class'Inventory.DudeClothesInv'.default.BodyMesh = MyBodyMesh;
		class'Inventory.DudeClothesInv'.default.BodySkin = MyBodySkin;
		class'Inventory.DudeClothesInv'.default.HeadMesh = MyHeadMesh;
		class'Inventory.DudeClothesInv'.default.HeadSkin = MyHeadSkin;
	}
	
	// Modify Gimp Clothes
	if(CustomGimpClothes)
	{
		DynamicLoadObject("Inventory.GimpClothesInv", class'Class');
		class'Inventory.GimpClothesInv'.default.HandsTexture = MyGimpHandsTexture;
		class'Inventory.GimpClothesInv'.default.FootTexture = MyGimpFootTexture;
		class'Inventory.GimpClothesInv'.default.BodyMesh = MyGimpBodyMesh;
		class'Inventory.GimpClothesInv'.default.BodySkin = MyGimpBodySkin;
		class'Inventory.GimpClothesInv'.default.HeadMesh = MyGimpHeadMesh;
		class'Inventory.GimpClothesInv'.default.HeadSkin = MyGimpHeadSkin;
		
		DynamicLoadObject("Inventory.GimpClothesInvErrand", class'Class');
		class'Inventory.GimpClothesInvErrand'.default.HandsTexture = MyGimpHandsTexture;
		class'Inventory.GimpClothesInvErrand'.default.FootTexture = MyGimpFootTexture;
		class'Inventory.GimpClothesInvErrand'.default.BodyMesh = MyGimpBodyMesh;
		class'Inventory.GimpClothesInvErrand'.default.BodySkin = MyGimpBodySkin;
		class'Inventory.GimpClothesInvErrand'.default.HeadMesh = MyGimpHeadMesh;
		class'Inventory.GimpClothesInvErrand'.default.HeadSkin = MyGimpHeadSkin;
	}

	// Modify Cop Clothes
	if(CustomCopClothes)
	{
		DynamicLoadObject("Inventory.CopClothesInv", class'Class');
		class'Inventory.CopClothesInv'.default.HeadMesh = MyHeadMesh;	// Same as default, add new variable if needed
		class'Inventory.CopClothesInv'.default.HeadSkin = MyHeadSkin;	// Same as default, add new variable if needed
		class'Inventory.CopClothesInv'.default.HandsTexture = MyCopHandsTexture;
		class'Inventory.CopClothesInv'.default.FootTexture = MyCopFootTexture;
		class'Inventory.CopClothesInv'.default.BodyMesh = MyCopBodyMesh;
		class'Inventory.CopClothesInv'.default.BodySkin = MyCopBodySkin;
	}

	// Modify Dialog
	if(CustomDialog)
	{
		DynamicLoadObject("GameTypes.P2CheatManager", class'Class');
		class'GameTypes.P2CheatManager'.default.WrongItemSound[0] = MyWrongItemSound;
		class'GameTypes.P2CheatManager'.default.WrongItemSound[1] = MyWrongItemSound;
	}
}

//////////////////////////////////////////////
// Default Properties
//////////////////////////////////////////////
defaultproperties
{
     FriendlyName="Your player mod name"
     Description="Your player mod description."
	 	
	 // Set TRUE if you want to use custom hud class.
	 CustomHUD=FALSE
	 MyHUDClass="GameTypes.AWWrapHUD"
	 
	 // Default Dude's properties, feel free to change them.
	 MyBodyMesh=SkeletalMesh'Characters.Avg_Dude'
     MyBodySkin=Texture'ChameleonSkins.Special.Dude'
	 MyHeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	 MyHeadSkins[0]=Texture'AW_Characters.Special.Alphatex'
     MyHeadSkins[1]=Texture'AW_Characters.Special.Dude_AW'				// Head skin for Monday-Friday
	 MyInjuriedHeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'	// Bandaged head skin for Weekend.
     MyHandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_dude'
     MyFootTexture=Texture'ChameleonSkins.Special.Dude'					// Usually foot uses the same skin as body
     
	 // Set to TRUE if you want to customize cop clothes.
	 CustomCopClothes=FALSE
	 MyCopBodyMesh = SkeletalMesh'Characters.Avg_M_SS_Pants'
	 MyCopBodySkin = Texture'ChameleonSkins.Dude_Cop'
	 MyCopHandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_robber'
     MyCopFootTexture=Texture'ChameleonSkins.Dude_Cop'
    
	 // Set to TRUE if you want to customize gimp clothes.
	 CustomGimpClothes=FALSE
 	 MyGimpBodyMesh=SkeletalMesh'Characters.Avg_Gimp'
     MyGimpBodySkin=Texture'ChameleonSkins.Special.Gimp'
	 MyGimpHandsTexture=Texture'MP_FPArms.LS_arms.LS_hands_gimp'
     MyGimpFootTexture=Texture'ChameleonSkins.Special.Gimp'
	 
	 // Set TRUE and fill in stuff below if you want to customize the dialogues.
	 CustomDialog=FALSE
	 MyDialogClass=class'DialogDude'						// Main dialog class
	 MySuicideSound=Sound'DudeDialog.dude_iregretnothing'	// Comment for suicide.
     MyWrongItemSound=Sound'DudeDialog.dude_notright'		// Comment for wrong IWant command.
	 // Some dialogues need to be modified seaparately outside of dialog class.
	 // Feel free to increase or decrease lenght of arrays below (the function will adjust to it).
	 MyDudeButtHit[0]=Sound'AWDialog.Dude.Dude_CowAss_1'
     MyDudeButtHit[1]=Sound'AWDialog.Dude.Dude_CowAss_2'
     MyDudeButtHit[2]=Sound'AWDialog.Dude.Dude_CowAss_3'
     MyDudeButtHit[3]=Sound'AWDialog.Dude.Dude_CowAss_4'
     MyDudeBladeKill[0]=Sound'AWDialog.Dude.Dude_EdgedWeapon_1'
     MyDudeBladeKill[1]=Sound'AWDialog.Dude.Dude_EdgedWeapon_2'
     MyDudeBladeKill[2]=Sound'AWDialog.Dude.Dude_EdgedWeapon_3'
     MyDudeBladeKill[3]=Sound'AWDialog.Dude.Dude_EdgedWeapon_4'
     MyDudeBladeKill[4]=Sound'AWDialog.Dude.Dude_UseBlade_1'
     MyDudeBladeKill[5]=Sound'AWDialog.Dude.Dude_UseBlade_2'
     MyDudeBladeKill[6]=Sound'AWDialog.Dude.Dude_UseBlade_3'
     MyDudeMacheteThrow[0]=Sound'AWDialog.Dude.Dude_AltBlade_1'
     MyDudeMacheteThrow[1]=Sound'AWDialog.Dude.Dude_AltBlade_2'
     MyDudeMacheteThrow[2]=Sound'AWDialog.Dude.Dude_AltBlade_3'
     MyDudeMacheteCatch[0]=Sound'AWDialog.Dude.Dude_Machete_Daddy'
     MyDudeMacheteCatch[1]=Sound'AWDialog.Dude.Dude_Machete_Fingers'
     MyDudeMacheteCatch[2]=Sound'AWDialog.Dude.Dude_Machete_ImGood'
     MyDudeMacheteCatch[3]=Sound'AWDialog.Dude.Dude_Machete_ThereItIs'
	 MyDudeZombieKill[0]=Sound'AWDialog.Dude.Dude_Zombies_1'
	 MyDudeZombieKill[1]=Sound'AWDialog.Dude.Dude_Zombies_2'
	 MyDudeZombieKill[2]=Sound'AWDialog.Dude.Dude_Zombies_3'
	 MyDudeZombieKill[3]=Sound'AWDialog.Dude.Dude_Zombies_4'
	 MyDudeZombieKill[4]=Sound'AWDialog.Dude.Dude_Zombies_5'
	 MyDudeHalloweenKill[0]=Sound'DudeDialog.dude_halloween_happyhalloween1'
	 MyDudeHalloweenKill[1]=Sound'DudeDialog.dude_halloween_happyhalloween2'
	 MyDudeHalloweenKill[2]=Sound'DudeDialog.dude_halloween_happyhalloween3'
	 MyDudeHalloweenKill[3]=Sound'DudeDialog.dude_halloween_trickortreat1'
	 MyDudeHalloweenKill[4]=Sound'DudeDialog.dude_halloween_trickortreat2'
	 MyDudeHalloweenKill[5]=Sound'DudeDialog.dude_halloween_trickortreat3'
}
