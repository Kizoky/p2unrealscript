//=============================================================================
// AWPostalDude.uc
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//=============================================================================
class AWPostalDude extends AWDude
	placeable;
	
///////////////////////////////////////////////////////////////////////////////
// Public vars
///////////////////////////////////////////////////////////////////////////////
var() Material PreInjuryHeadSkin;
var() Material PostInjuryHeadSkin;
var Mesh ExpectedHeadMesh;
var Mesh OldHeadMesh;
var Material GrenadeSuicideEnhanced;

// xPatch:
var Material PreClothesChangeHeadSkin;
var float ADJUST_RELATIVE_HEAD_Y_OLD;
var HandsWeapon LeftHandBird;				// Paradise Lost "Fuck You" feature backport!
var class<HandsWeapon> LeftHandBirdClass;
//var Texture HDSkin;						// Alternative skin from Paradise Lost
const GUNBELT_PISTOL_INDEX = 1;			// Skin index of the gun to turn off in the gunbelt
var int GUNBELT_INDEX;				// Index for the gunbelt bolton
var StaticMesh ExpectedGunbeltMesh;			// Mesh of the gunbelt
var Material InvisiblePistolTex;		// Material to use for the pistol when it's invisible
var Material VisiblePistolTex;		// Material to use when the pistol's turned back on
var array<byte> MaxAllowedList;

///////////////////////////////////////////////////////////////////////////////
// Make a grenade in his hand
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHand()
{
	Super.Notify_SpawnGrenadeHand();
	if(usegrenade != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		usegrenade.Skins[0] = GrenadeSuicideEnhanced;
}

///////////////////////////////////////////////////////////////////////////////
// Put the grenade in his head and open the mouth
///////////////////////////////////////////////////////////////////////////////
function Notify_SpawnGrenadeHead()
{
	Super.Notify_SpawnGrenadeHead();
	if(usegrenade != None
		&& P2GameInfoSingle(Level.Game).VerifySeqTime())
		usegrenade.Skins[0] = GrenadeSuicideEnhanced;
}

///////////////////////////////////////////////////////////////////////////////
// Die with a grenade in your mouth
// Can't get around this, even with God mode
///////////////////////////////////////////////////////////////////////////////
function GrenadeSuicide()
{
	local Controller Killer;
	local P2Explosion exp;
	local vector Exploc;
	local coords checkcoords;

	// Pick explosion point
	checkcoords = GetBoneCoords(BONE_NECK);
	Exploc = checkcoords.Origin;

	Exploc -= checkcoords.YAxis*GRENADE_FORWARD_MOVE;

	// remove the fake grenade from his head
	Notify_RemoveGrenadeHead();
	
	// Enhanced mode: nuclear fucking explosion
	if (P2GameInfoSingle(Level.Game).VerifySeqTime())
	{
		// Make a grenade explosion here
		exp = spawn(class'MiniNukeHeadExplosion',self,,Exploc);
		exp.ShakeCamera(3000);
	}
	else
	{
		// Make a grenade explosion here
		exp = spawn(class'GrenadeHeadExplosion',self,,Exploc);
		exp.ShakeCamera(300);
	}

	// We must be in blood mode to remove the head but still do
	// the explosion effect above
	if(class'P2Player'.static.BloodMode())
	{
		// Remove head
		ExplodeHead(Exploc, vect(0,0,0));
	}

	// Kill the pawn
	Health = 0;

	Died( Killer, class'Suicided', Location );
}

///////////////////////////////////////////////////////////////////////////////
// Called by AW7GameInfo
///////////////////////////////////////////////////////////////////////////////
function DudeCheckHeadSkin()
{
	// xPatch: Classic Game
	if(P2GameInfoSingle(Level.Game).GetClassicDude())
	{
		if (myHead != None && MyHead.Mesh == Default.ExpectedHeadMesh)
		{
			// Setup old head
			MyHead.LinkMesh(OldHeadMesh, true);
			MyHead.Skins[0] = class'DudeClothesInv'.Default.HeadSkin; 
		}
	}
	
	// xPatch: Adjust head location
	DudeCheckHeadOffset();
	
	// If it's not the weekend yet, use the normal (non-injured) dude head.
	if (!P2GameInfoSingle(Level.Game).IsWeekend())
	{
		//log(self@"swapping to pre-injury head skin",'Debug');
		if(MyHead.Skins[1] == PostInjuryHeadSkin)	// Added by Man Chrzan: xPatch 2.0 mod clothes fix
			MyHead.Skins[1] = PreInjuryHeadSkin;
	}
	else
	{
		//log(self@"swapping to post-injury head skin",'Debug');
		if(MyHead.Skins[1] == PreInjuryHeadSkin)		// Added by Man Chrzan: xPatch 2.0 mod clothes fix
			MyHead.Skins[1] = PostInjuryHeadSkin;
	}
	
	// xPatch: Check for HD skin too.
	//if(Skins[0] == class'DudeClothesInv'.Default.BodySkin //Skins[0] == default.Skins[0]
	//	&& bool(ConsoleCommand("Get Postal2Game.xPatchManager bHDDudeSkin")))
	//	Skins[0] = HDSkin;
}

// xPatch: Head Offset Fix
function DudeCheckHeadOffset()
{
	local vector v;
	
	if (myHead != None)	
	{
		// the Y offset should be adjusted to model.
		if(MyHead.Mesh != ExpectedHeadMesh)
			v.y = ADJUST_RELATIVE_HEAD_Y_OLD;	
		else
			v.y = ADJUST_RELATIVE_HEAD_Y;
			
		v.x = ADJUST_RELATIVE_HEAD_X;
		v.z = ADJUST_RELATIVE_HEAD_Z;
		myHead.SetRelativeLocation(v);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Switch to this new mesh
///////////////////////////////////////////////////////////////////////////////
function SwitchToNewMesh(Mesh NewMesh,
						 Material NewSkin,
						 Mesh NewHeadMesh,
						 Material NewHeadSkin,
						 optional Mesh NewCoreMesh)
{
	local bool bSwappedFromOldDude;

	// Setup body (true means "keep anim state")
	SetMyMesh(NewMesh, NewCoreMesh, true);
	SetMySkin(NewSkin);
	LinkAnims();
	PlayWaiting();

	// xPatch: Before we do anything with the head skin, save the current one.
	if(AWDudeHead(MyHead) != None && MyHead.Mesh == ExpectedHeadMesh && PreClothesChangeHeadSkin == None)
		PreClothesChangeHeadSkin = MyHead.Skins[0];

	// The clothes are wonky, so if they specify using the old dude head, use the new head instead and set
	// the bandage skin accordingly.
	if (NewHeadMesh == class'DudeClothesInv'.Default.HeadMesh && NewHeadSkin == class'DudeClothesInv'.Default.HeadSkin)
	{
		NewHeadMesh = ExpectedHeadMesh;
		NewHeadSkin = PreInjuryHeadSkin;
		bSwappedFromOldDude = True;
	}

	// Setup head
	MyHead.LinkMesh(NewHeadMesh, true);
	// Because our headmesh is screwey, ask the head what it wants to set
	if(AWDudeHead(MyHead) != None && NewHeadMesh == ExpectedHeadMesh)
	{
		AWDudeHead(MyHead).SetMainSkin(NewHeadSkin);
		if(PreClothesChangeHeadSkin != None)
			MyHead.Skins[0] = PreClothesChangeHeadSkin;		// xPatch: Restore the previous Skins[0] too.
	}
	else
		MyHead.Skins[0] = NewHeadSkin; 

	if (bSwappedFromOldDude)
		DudeCheckHeadSkin();
	else // xPatch: Head position check	
		DudeCheckHeadOffset();
}

///////////////////////////////////////////////////////////////////////////////
// Do this here so we access to Left "Fuck You" hand.
///////////////////////////////////////////////////////////////////////////////
function AddDefaultInventory()
{
	// Only let this be called once
	if (!bGotDefaultInventory)
	{
		LeftHandBird = HandsWeapon(CreateInventoryByClass(LeftHandBirdClass));
		if (LeftHandBird != None)
		{
			LeftHandBird.GotoState('Idle');
			LeftHandBird.bJustMade=false;
			if(Controller != None)
				Controller.NotifyAddInventory(LeftHandBird);
		}
		Super.AddDefaultInventory();
	}
}

///////////////////////////////////////////////////////////////////////////////
// Same as cops but edited for dressed up dude player
///////////////////////////////////////////////////////////////////////////////

// Turns off the pistol in our gunbelt
function TurnOffPistol()
{	
	local PeoplePart GunbeltPistol;
	GunbeltPistol = Boltons[GUNBELT_INDEX].Part;

	// Skip if not assigned yet
	if (GunbeltPistol != None)
	{
		if (GunbeltPistol.StaticMesh != ExpectedGunbeltMesh || !P2Player(Controller).DudeIsCop())
			return;

		if (VisiblePistolTex == None)
			VisiblePistolTex = GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX];

		GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX] = InvisiblePistolTex;
		//log(self@"turn off pistol, gunbelt skin now"@GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX]);
	}
}

// Turn back on the pistol in our gunbelt
function TurnOnPistol()
{
	local PeoplePart GunbeltPistol;
	GunbeltPistol = Boltons[GUNBELT_INDEX].Part;
	
	// Skip if not assigned yet
	if (GunbeltPistol != None)
	{
		if (GunbeltPistol.StaticMesh != ExpectedGunbeltMesh || !P2Player(Controller).DudeIsCop())
			return;
			
		if (VisiblePistolTex != None)
			GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX] = VisiblePistolTex;
		//log(self@"turn on pistol, gunbelt skin now"@GunbeltPistol.Skins[GUNBELT_PISTOL_INDEX]);
	}
}

// Just changed to pendingWeapon
function ChangedWeapon()
{	
	Super.ChangedWeapon();
	
	//log(self@"changed weapon pending"@pendingweapon@"weapon"@weapon);

	// Turn off the pistol in the gunbelt if they're holding it
	if (PistolWeapon(Weapon) != None)
		TurnOffPistol();
	else // Turn it back on if they switch back to hands or to the baton, etc
		TurnOnPistol();
}

// toss out the weapon currently held
function TossWeapon(vector TossVel)
{
	// If they toss their pistol for whatever reason, turn the gunbelt pistol off
	if (PistolWeapon(Weapon) != None)
		TurnOffPistol();
	
	Super.TossWeapon(TossVel);
}

// Use MP running animations for Pistol (Looks weird otherwise in 3rd Person View)
simulated function SetAnimRunning()
{
	local EWeaponHoldStyle hold;
	local name useanim1;
	local bool bUseSuper;
	
	bUseSuper = True;

/*	if(Controller != None) 
	{
		if(Controller.IsInState('RunningBlind') 
			|| (P2Player(Controller) != None && !P2Player(Controller).ThirdPersonView))
		{
			Super.SetAnimRunning();
			return;
		}
	} 	
*/
	
	if (MyBodyFire == None)
	{
		hold = GetWeaponHoldStyle();

		if ((hold != WEAPONHOLDSTYLE_None) && (mood == MOOD_Combat))
			{
			switch (GetWeaponHoldStyle())
				{
				case WEAPONHOLDSTYLE_Single:
					// MP running forward with a pistol (because you can shoot while running
					useanim1='ss_run3';	
					
					TurnLeftAnim		= 'ss_base_singleframe';
					TurnRightAnim		= 'ss_base_singleframe';
					MovementAnims[0]	= useanim1;
					if(!AllowBackpeddle())
						MovementAnims[1]	= MovementAnims[0];
					else
						MovementAnims[1]	= 'ss_runback';
					MovementAnims[2]	= 'ss_strafel';
					MovementAnims[3]	= 'ss_strafer';

					bUseSuper = False;
					break;
				}
			}
	}
	if(bUseSuper)
		Super.SetAnimRunning();
}

///////////////////////////////////////////////////////////////////////////////
// Masochist Mode / Ludicrous Difficulty
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (P2GameInfoSingle(Level.Game) != None 
		&& P2GameInfoSingle(Level.Game).InMasochistMode())
	{
		bMasochistPlayer=True;
		TakesMacheteDamage=1.0;
		TakesSledgeDamage=1.0;
		TakesScytheDamage=1.0;
		TakesShotgunHeadShot=1.0;
		TakesRifleHeadShot=0.5;	// 1.0 was way too much LOL, NPCs always aim for the head 
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called by player controller to see if the dude can 
// pick up any more weapons of the same group.
///////////////////////////////////////////////////////////////////////////////
function bool WeaponGroupFull(class<Inventory> InvType, optional out int MaxCount)
{
	local Inventory Inv;
	local P2Weapon P2Weap;
	local int WGroup, MaxAllowed;
	local int LoopCount, WCount, i;
	
	WGroup = InvType.default.InventoryGroup;
	
	// Allow one or only few weapons per group.
	MaxAllowed = MaxAllowedList[WGroup];

	// Make sure it's not 0 (Use 0 for infinite, we want it for hands) 
	if(MaxAllowed > 0)
	{
		// Count weapons in group.
		for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if(P2Weapon(Inv) != None)
			{
				P2Weap = P2Weapon(Inv);
				
				// Ignore weapon we already own
				if(P2Weap.Class == InvType)
					return false;
				
				// Now count how many weapons we have
				if(P2Weap.InventoryGroup == WGroup)
				{
					// If we don't have ammo for it at all
					// don't count, throw it away instead.
					if(!P2Weap.HasAmmo())
					{
						// destroy empty throwables
						if(P2Weap.bThrownByFiring)
						{
							DeleteInventory(P2Weap);
							P2Weap.Destroy();
						}
						// toss out everything else
						else
						{
							if(!P2AmmoInv(P2Weap.AmmoType).HasAmmoStrict()
								|| P2Weap.bReloadableWeapon)	// No need to use strict for reloadable ones.
								TossEmptyWeapon(P2Weap);
						}
					}
					else
						WCount++;
						
					// Ignore Base Equipment
					if(P2Weap.HasAmmo())
					{
						for(i=0; i<BaseEquipment.Length; i++)
						{
							if(P2Weap.Class == BaseEquipment[i].WeaponClass)
								WCount--;
						}
					}
				}
			}
			LoopCount++;

			if(LoopCount > 5000)
				break;
		}

		MaxCount = MaxAllowed;
		//P2Player(Controller).ClientMessage("Weapons found in Group"@WGroup@"="@WCount);
		
		return (WCount >= MaxAllowed);
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// toss out the empty weapon 
///////////////////////////////////////////////////////////////////////////////
function TossEmptyWeapon(P2Weapon EmptyWeapon)
{
	local vector X,Y,Z;
	local vector TossVel;

	if(EmptyWeapon == None)
		return;
		
	if(P2Player(Controller) != None)
		P2Player(Controller).ClientMessage("Your empty weapon was tossed out.");

	// Really make it stop doing it's stuff
	// And don't drop things that can't be dropped
	if(!EmptyWeapon.bCanThrow
		|| (!EmptyWeapon.bCanThrowMP
			&& !Level.Game.bIsSinglePlayer))
		return;

	TossVel = vector(Rotation);
	TossVel = (FRand()*127)*Normal(TossVel);
	TossVel.z+=(FRand()*255);

	EmptyWeapon.velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	// And make the weapon align with the direction of the throw
	EmptyWeapon.SetRotation(Rotation);
	EmptyWeapon.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
}

defaultproperties
{
    BaseEquipment(0)=(WeaponClass=Class'UrethraWeapon')
    BaseEquipment(1)=(WeaponClass=Class'FootWeapon')
    BaseEquipment(2)=(WeaponClass=Class'MatchesWeapon')
    BaseEquipment(3)=(WeaponClass=Class'CellPhoneWeapon')
    Skins(0)=Texture'ChameleonSkins.Special.Dude'
	ExpectedHeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	OldHeadMesh=SkeletalMesh'heads.AvgDude'
	PreInjuryHeadSkin=Texture'AW_Characters.Special.Dude_AW'
	PostInjuryHeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadClass=Class'AWDudeHead'
    HeadSkin=Texture'AW_Characters.Special.Dude_AW_Bandage'
    HeadMesh=SkeletalMesh'MoreHeads.AW_Dude'
	//Tag="PostalDude"

	Begin Object Class=ConstantColor Name=ConstantBlack
		Color=(R=0,G=0,B=0)
	End Object
	Begin Object Class=Combiner Name=BlackGrenade
		CombineOperation=CO_Subtract
		Material1=Texture'WeaponSkins.grenade3_timb'
		Material2=ConstantColor'ConstantBlack'
	End Object
	Begin Object Class=Shader Name=BlackGrenadeShader
		Diffuse=Combiner'BlackGrenade'
		Specular=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
		SpecularityMask=TexEnvMap'AW7Tex.Cubes.CubeShineMap'
	End Object
	GrenadeSuicideEnhanced=Texture'AW7Tex.Nuke.nuclear_grenade'
	
	// Added by Man Chrzan: xPatch
	HandsClass="Inventory.HandsWeapon"
	HandsClassNormal="Inventory.HandsWeapon" 
	LeftHandBirdClass=class'Inventory.HandsWeaponLeft'
	
	ADJUST_RELATIVE_HEAD_Y_OLD=0
	//HDSkin=Texture'xPatchExtraTex.Dude_HiRes'
	
	GUNBELT_INDEX=3
	ExpectedGunbeltMesh=StaticMesh'Boltons_Package.Cops.Gunbelt_M_Avg'
	InvisiblePistolTex=Shader'AW7Tex.Weapons.InvisiblePistol'
	VisiblePistolTex=Texture'WeaponSkins.desert_eagle_timb'

	MaxAllowedList[0]=0		// Hands
	MaxAllowedList[1]=3		// Melee
	MaxAllowedList[2]=2		// Pistols
	MaxAllowedList[3]=2		// Shotguns
	MaxAllowedList[4]=2		// Machine Guns
	MaxAllowedList[5]=2		// Gasoline stuff
	MaxAllowedList[6]=2		// Grenades
	MaxAllowedList[7]=1		// Scissors, Cow Head
	MaxAllowedList[8]=1		// Sniper Rifles
	MaxAllowedList[9]=2		// Rocket Launchers
	MaxAllowedList[10]=2	// Other Launchers
}
