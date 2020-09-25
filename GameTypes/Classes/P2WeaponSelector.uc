// 3/21/2014
//
// NOTE: Always assume the client's resolution height is 768 when doing any
// scaling.
class P2WeaponSelector extends P2EInteraction;

#exec OBJ LOAD FILE=P2Fonts.utx

// A struct for remembering weapons by group. Thus all weapons with the same
// InventoryGroup are stored into a subgroup. Then the subgroup is sorted in
// ascending order by GroupOffset.
struct SInvGroupInfo
{
	// Corresponds to an appropriate InventoryGroup.
	var int	InvGroup;

	// All the weapons in InventoryGroup.
	var array< Weapon > WList;
};

// Configurable HUD variables.
var() Color				AmmoBarColor,
					AmmoBarBGColor,
					NormalGroupElementColor,
					SelectedGroupElementColor,
					NormalWeaponElementColor,
					SelectedWeaponElementColor,
					NoAmmoWeaponColor;

var() enum ESelectorType {
	STYPE_Normal,
	STYPE_Carousel,
}	SelectorType;

var() Font				GroupFont, GroupWNameFont;

var() float				AmmoBarHeightFact,
					GroupCellBorder,
					WeaponListIconScale,
					GroupBarWNameSpacing;

var() int				GroupFontSize, GroupWNameFontSize;
var() P2EUtils.FloatRegion		GroupBarPos;
var() Sound				ScrollingThruGroupSound, SelectedWeaponSound, BadWeaponSound;
var() Texture				GroupCellTex, SelectedGroupCellTex;
var() vector				GroupCellScale;

// Carousel-related vars.
var() float				CarouselRadius;
var() vector				CarouselPos;

var() float				CarouselWBarSpacing, CarouselWNameSpacing;

// Internal.
var protected array<SInvGroupInfo>	WeaponGroups;

// All errand weapons are in group 0 and have a higher offset than the hands.
// So all we would need is to check if the player has an errand weapon if he's
// trying to switch to hands.
var bool				bHasErrandWeapon;

var protected int			SelectedGroupIndex, SelectedWListIndex;

// Array MUST match the length of WeaponGroups!!!
var protected array<float>		WeaponGroupAngles;
var protected float			CarouselAngle,
					CurCarouselRadius,
					DesCarouselAngle,
					WeaponAngle;

// Internal HUD stuff. Primarily stuff that changes often.
var protected float			DesCarouselWLOffset, CurCarouselWLOffset;
var protected float			CurGroupWLPos, DesGroupWLPos;

var protected vector			CurCarouselPos, DesCarouselPos;
var protected vector			CurGroupCellSize, CurGroupRowPos, DesGroupRowPos;

var localized string			CannotEmptyHandsNowMsg;

var globalconfig bool	bFullScreen;			// If true, draws the weapon selector on the entire screen instead of confining it
var globalconfig float	TimeoutDelayNormal;	// Auto-timeout delay (normal mode)
var globalconfig float	TimeoutDelayAuto;		// Auto-timeout delay (auto-swap mode)
var float SelectorIdleTime;						// Amount of time the weapon selector has been idle

/*
	Only used whenever weapons are being added to WeaponGroups.
*/
function bool IsValidWeapon(Weapon W)
{
	// The usual deleted actor check.
	if((W == None) || (W.bDeleteMe))
		return false;

	return !( /*((SMWeapon(W) != None) && (SMWeapon(W).bIsSlave)) ||*/ (W.IsA('UrethraWeapon') || W.IsA('CellPhoneWeapon') || W.IsA('FootWeapon')) );
}

function bool ValidIndexesSelected()
{
	return (SelectedGroupIndex != -1 && SelectedWListIndex != -1);
}

/*
	Returns true if weapon is used for an errand for the current day.
*/
function bool IsErrandWeapon(Weapon W)
{
	local DayBase D;
	local int i;
	local P2GameInfoSingle G;

	G = P2GameInfoSingle(PlayerOwner.Level.Game);

	// Skip checking if in MP.
	if(G == None)
		return false;

	D = G.GetCurrentDayBase();

	if(D == None)
		return false;

	for(i = 0; i < D.PlayerInvList.Length; i++)
	{
		if(Caps(string(W.Class)) == Caps(D.PlayerInvList[i].InvClassName))
			return true;
	}
	return false;
}

// Should only be called by PrevWeapon(), NextWeapon(), SwitchWeapon(), and RemoveWeapon()!
protected function CorrectIndexes()
{
	if(SelectedWListIndex < 0)
	{
		SelectedGroupIndex--;
		DesCarouselAngle -= WeaponAngle;

		if(SelectedGroupIndex < 0)
			SelectedGroupIndex = WeaponGroups.Length - 1;

		SelectedWListIndex = WeaponGroups[SelectedGroupIndex].WList.Length - 1;

		// Don't interpolate weapon list positions if we've switched groups.
		DesCarouselWLOffset = SelectedWListIndex * CurGroupCellSize.X;
		CurCarouselWLOffset = DesCarouselWLOffset;

		DesGroupWLPos = SelectedWListIndex * CurGroupCellSize.Y;
		CurGroupWLPos = DesGroupWLPos;
	}

	else if(SelectedWListIndex >= WeaponGroups[SelectedGroupIndex].WList.Length)
	{
		SelectedGroupIndex++;
		DesCarouselAngle += WeaponAngle;

		if(SelectedGroupIndex >= WeaponGroups.Length)
			SelectedGroupIndex = 0;

		SelectedWListIndex = 0;

		// Don't interpolate weapon list positions if we've switched groups.
		DesCarouselWLOffset = SelectedWListIndex * CurGroupCellSize.X;
		CurCarouselWLOffset = DesCarouselWLOffset;

		DesGroupWLPos = SelectedWListIndex * CurGroupCellSize.Y;
		CurGroupWLPos = DesGroupWLPos;
	}
	SelectorIdleTime = 0;
}

protected function RefreshCarouselArray()
{
	local float Inc;
	local int i;

	if(WeaponGroupAngles.Length > 0)
		WeaponGroupAngles.Remove(0, WeaponGroupAngles.Length);

	if(WeaponGroups.Length == 0)
		return;

	WeaponAngle = (360.0 / WeaponGroups.Length);

	for(i = 0; i < WeaponGroups.Length; i++)
	{
		WeaponGroupAngles.Length = WeaponGroupAngles.Length + 1;
		WeaponGroupAngles[WeaponGroupAngles.Length - 1] = Inc;
	//	log(self @ WeaponGroupAngles[i]);

		Inc += WeaponAngle;
	}

	if(ValidIndexesSelected())
	{
		DesCarouselAngle = WeaponGroupAngles[SelectedGroupIndex];
		CarouselAngle = WeaponGroupAngles[SelectedGroupIndex];
	}
}

// Basic sorting functions.
final function BubbleSortWeaponGroups()
{
	local int a, b;
	local SInvGroupInfo Tmp;

	for(a = 0; a < WeaponGroups.Length; a++)
	{
		for(b = a; b < WeaponGroups.Length; b++)
		{
			if(WeaponGroups[a].InvGroup > WeaponGroups[b].InvGroup)
			{
				Tmp = WeaponGroups[a];
				WeaponGroups[a] = WeaponGroups[b];
				WeaponGroups[b] = Tmp;
			}
		}
	}
}

final function BubbleSortWList(int GroupIdx)
{
	local int a, b;
	local Weapon Tmp;

	if(GroupIdx < 0 || GroupIdx > WeaponGroups.Length - 1)
		return;

	for(a = 0; a < WeaponGroups[GroupIdx].WList.Length; a++)
	{
		for(b = a; b < WeaponGroups[GroupIdx].WList.Length; b++)
		{
			if(WeaponGroups[GroupIdx].WList[a].Default.GroupOffset > WeaponGroups[GroupIdx].WList[b].Default.GroupOffset)
			{
				Tmp = WeaponGroups[GroupIdx].WList[a];
				WeaponGroups[GroupIdx].WList[a] = WeaponGroups[GroupIdx].WList[b];
				WeaponGroups[GroupIdx].WList[b] = Tmp;
			}
		}
	}
}

// Does what it says.
final function int FindWeaponInWList(Weapon W, int Idx)
{
	local int i;

	if((Idx < 0 || Idx >= WeaponGroups.Length) || !IsValidWeapon(W))
		return -1;

	for(i = 0; i < WeaponGroups[Idx].WList.Length; i++)
	{
		if(WeaponGroups[Idx].WList[i] == W)
			return i;
	}
	return -1;
}

final function int GetWeaponGroupSlot(int T)
{
	local int i;

	for(i = 0; i < WeaponGroups.Length; i++)
	{
		if(WeaponGroups[i].InvGroup == T)
			return i;
	}
	return -1;
}

final function bool AddWeapon(Weapon W)
{
	local int Idx;

	if(!IsValidWeapon(W))
		return false;

	//if(!bHasErrandWeapon)
		//bHasErrandWeapon = IsErrandWeapon(W);

	Idx = GetWeaponGroupSlot(W.InventoryGroup);

	if(Idx == -1)
	{
		WeaponGroups.Length = WeaponGroups.Length + 1;
		WeaponGroups[WeaponGroups.Length - 1].InvGroup = W.InventoryGroup;
		Idx = WeaponGroups.Length - 1;
	}

	if(FindWeaponInWList(W, Idx) != -1)
		return false;

	WeaponGroups[Idx].WList.Length = WeaponGroups[Idx].WList.Length + 1;
	WeaponGroups[Idx].WList[WeaponGroups[Idx].WList.Length - 1] = W;
	BubbleSortWList(Idx);
	BubbleSortWeaponGroups();
	RefreshCarouselArray();
	return true;
}

final function bool RemoveWeapon(Weapon W)
{
	local int Idx, Idx2;

	if(!IsValidWeapon(W))
		return false;

	if(bHasErrandWeapon && (W.InventoryGroup == PlayerOwner.MyPawn.HandsClass.Default.InventoryGroup
					&& W.GroupOffset > PlayerOwner.MyPawn.HandsClass.Default.GroupOffset))
		bHasErrandWeapon = false;

	Idx = GetWeaponGroupSlot(W.InventoryGroup);

	if(Idx == -1)
		return false;

	Idx2 = FindWeaponInWList(W, Idx);

	if(Idx2 == -1)
		return false;

	WeaponGroups[Idx].WList.Remove(Idx2, 1);

	if(WeaponGroups[Idx].WList.Length == 0)
	{
		WeaponGroups.Remove(Idx, 1);
		RefreshCarouselArray();
	}

	if(ValidIndexesSelected())
		CorrectIndexes();

	return true;
}

function bool ValidHandsWeapon(class<Weapon> WeaponClass)
{
	// if same inventory group as hands, look to see if there are any other errand items that
	// should appear over the hands.
	local Inventory Inv;
	local byte HandsOffset;
	
	//ErikFOV Change: Fix problem
	local int Count;
	//end
	
	// Bad pawn or weapon class
	if ((PlayerOwner.Pawn.Inventory == None) || (WeaponClass == None))
		return false;
		
	// Not a hands weapon
	if (WeaponClass.Default.InventoryGroup != PlayerOwner.MyPawn.HandsClass.Default.InventoryGroup)
		return true;
		
	// See if any other "hands" weapons have priority over this one.
	for ( Inv=PlayerOwner.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.Default.InventoryGroup == WeaponClass.Default.InventoryGroup
			&& Inv.Default.GroupOffset > WeaponClass.Default.GroupOffset
			&& Weapon(Inv).HasAmmo())
			return false;
			
			//ErikFOV Change: Fix problem
			Count++;
			if(Count > 5000)
				return true;
			//end
	}
	
	return true;
}

// Copied from PlayerController.uc so we can select weapons even if
// they're empty.
function GetWeapon(class<Weapon> NewWeaponClass, optional bool bSilent)
{
	local Inventory Inv;
	local int Count;

	if ( (PlayerOwner.Pawn.Inventory == None) || (NewWeaponClass == None)
		|| ((PlayerOwner.Pawn.Weapon != None) && (PlayerOwner.Pawn.Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=PlayerOwner.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Inv.Class == NewWeaponClass )
		{
			if (Weapon(Inv).HasAmmo() && ValidHandsWeapon(NewWeaponClass))
			{
				if( bHasErrandWeapon && (Inv.InventoryGroup == PlayerOwner.MyPawn.HandsClass.Default.InventoryGroup
							&& Inv.GroupOffset == PlayerOwner.MyPawn.HandsClass.Default.GroupOffset))
				{
					if (!bSilent)
					{
						PlayerOwner.ClientMessage(CannotEmptyHandsNowMsg);
						GetSoundActor().PlaySound(BadWeaponSound);
					}
					return;
				}
				PlayerOwner.Pawn.PendingWeapon = Weapon(Inv);
				PlayerOwner.Pawn.Weapon.PutDown();
				if (!bSilent)
					GetSoundActor().PlaySound(SelectedWeaponSound);
				return;
			}
			else if (!bSilent)
				GetSoundActor().PlaySound(BadWeaponSound);
		}
		Count++;
		if ( Count > 5000 )
			return;
	}
}

// Previous weapon and next weapon functions.
function PrevWeapon()
{
	local Weapon W;
	local int i;
	local Inventory Inv;
	
	if(PlayerOwner.Pawn.Weapon == None)
		return;

	if(!ValidIndexesSelected())
	{
		// Change by NickP: MP fix
		xCoopRefreshList();
		// End

		SelectedGroupIndex = GetWeaponGroupSlot(PlayerOwner.Pawn.Weapon.InventoryGroup);
		SelectedWListIndex = FindWeaponInWList(PlayerOwner.Pawn.Weapon, SelectedGroupIndex);
		// Can't find weapon, dude probably has zipper out.
		if (SelectedWListIndex == -1)
		{
			SelectedGroupIndex = GetWeaponGroupSlot(PlayerOwner.LastWeaponGroupPee);
			for (Inv = PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.InventoryGroup == PlayerOwner.LastWeaponGroupPee && Inv.GroupOffset == PlayerOwner.LastWeaponOffsetPee && Weapon(Inv) != None)
				{
					SelectedWListIndex = FindWeaponInWList(Weapon(Inv), SelectedGroupIndex);
					break;
				}
		}
		DesCarouselAngle = WeaponGroupAngles[SelectedGroupIndex];
		CarouselAngle = WeaponGroupAngles[SelectedGroupIndex];

		DesCarouselWLOffset = SelectedWListIndex * CurGroupCellSize.X;
		CurCarouselWLOffset = DesCarouselWLOffset;

		DesGroupWLPos = SelectedWListIndex * CurGroupCellSize.Y;
		CurGroupWLPos = DesGroupWLPos;
		ViewportOwner.Actor.ConsoleCommand("MENUEXCLUSIVEMODE 1");
		return;
	}
	
	W = None;
	while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
	{
		SelectedWListIndex--;
		CorrectIndexes();
		W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
		i++;
	}
	GetSoundActor().PlaySound(ScrollingThruGroupSound);
}

function NextWeapon()
{
	local Weapon W;
	local int i;
	local Inventory Inv;
	
	if(PlayerOwner.Pawn.Weapon == None)
		return;

	if(!ValidIndexesSelected())
	{
		// Change by NickP: MP fix
		xCoopRefreshList();
		// End

		SelectedGroupIndex = GetWeaponGroupSlot(PlayerOwner.Pawn.Weapon.InventoryGroup);
		SelectedWListIndex = FindWeaponInWList(PlayerOwner.Pawn.Weapon, SelectedGroupIndex);
		// Can't find weapon, dude probably has zipper out.
		if (SelectedWListIndex == -1)
		{
			SelectedGroupIndex = GetWeaponGroupSlot(PlayerOwner.LastWeaponGroupPee);
			for (Inv = PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.InventoryGroup == PlayerOwner.LastWeaponGroupPee && Inv.GroupOffset == PlayerOwner.LastWeaponOffsetPee && Weapon(Inv) != None)
				{
					SelectedWListIndex = FindWeaponInWList(Weapon(Inv), SelectedGroupIndex);
					break;
				}
		}
		DesCarouselAngle = WeaponGroupAngles[SelectedGroupIndex];
		CarouselAngle = WeaponGroupAngles[SelectedGroupIndex];

		DesCarouselWLOffset = SelectedWListIndex * CurGroupCellSize.X;
		CurCarouselWLOffset = DesCarouselWLOffset;

		DesGroupWLPos = SelectedWListIndex * CurGroupCellSize.Y;
		CurGroupWLPos = DesGroupWLPos;
		ViewportOwner.Actor.ConsoleCommand("MENUEXCLUSIVEMODE 1");
		return;
	}

	W = None;
	while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
	{
		SelectedWListIndex++;
		CorrectIndexes();
		W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
		i++;
	}
	GetSoundActor().PlaySound(ScrollingThruGroupSound);
}

function SwitchWeapon(byte F)
{
	local Weapon W;
	local int i;
	local int OldGroupIndex;
	local int OldWListIndex;
	
	//log("SwitchWeapon"@F@"Selected"@SelectedGroupIndex@"WList"@SelectedWListIndex);
	
	if (!ValidIndexesSelected())
	{
		// Change by NickP: MP fix
		xCoopRefreshList();
		// End

		ViewportOwner.Actor.ConsoleCommand("MENUEXCLUSIVEMODE 1");
	}
	
	W = None;
	OldGroupIndex = SelectedGroupIndex;
	OldWListIndex = SelectedWListIndex;
	
	while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
	{
		if(WeaponGroups[SelectedGroupIndex].InvGroup != F)
		{
			SelectedGroupIndex = GetWeaponGroupSlot(F);
			SelectedWListIndex = 0;
			if (SelectedGroupIndex == -1)
				break;
		//	CorrectIndexes();
		//	return;
		}
		else
		{
			SelectedWListIndex++;
			if(SelectedWListIndex >= WeaponGroups[SelectedGroupIndex].WList.Length)
				SelectedWListIndex = 0;
		}
			
		W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
		i++;
	}
	
	// Failsafe
	if (W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class))
	{
		SelectedGroupIndex = OldGroupIndex;
		SelectedWListIndex = OldWListIndex;
	}
	else	
		GetSoundActor().PlaySound(ScrollingThruGroupSound);
	SelectorIdleTime = 0;
}

function ResetIndexes()
{
	SelectedGroupIndex = -1;
	SelectedWListIndex = -1;
	ViewportOwner.Actor.ConsoleCommand("MENUEXCLUSIVEMODE 0");
	SelectorIdleTime = 0;
}

// Should only be called by PLDudePlayer in order to reset the array after each
// loaded game.
final function RefreshSelector()
{
	local Inventory inv;
	local int Count;

	PlayerOwner = P2Player(ViewportOwner.Actor);
	WeaponGroups.Remove(0, WeaponGroups.Length);

	for(inv = PlayerOwner.Pawn.Inventory; inv != None; inv = inv.Inventory)
	{
		if(Weapon(inv) != None)
			AddWeapon(Weapon(inv));

		Count++;

		if(Count > 5000)
			break;
	}
	ResetIndexes();
	RefreshCarouselArray();
	SetDestinations(true);
}

function bool SwitchWeaponByIndex(optional bool bNoReset)
{
	if(!ValidIndexesSelected())
		return false;

	/*PlayerOwner.*/GetWeapon(WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex].Class, true);
	if (!bNoReset)
		ResetIndexes();
	return true;
}

// Canvas-related functions.
// A function to make sure the weapon arrays are properly sorted and managed.
function DrawDebugList(Canvas Canvas)
{
	local float CanvasScale, FontScale, X, Y, XL, YL;
	local int i, j;
	local string S;

	Canvas.Style = 5;

	CanvasScale = (Canvas.ClipY / 768);
	FontScale = ((9.0f * 1.33) / 48) * CanvasScale; // Ensures font is 9 points, regardless of CanvasScale.
							// 1.33 represents a conversion from 72 PPI to 96 PPI.

	Canvas.Font = Font'P2Fonts.Plain48';
	Canvas.TextSize("TEST", XL, YL);
	XL *= FontScale;
	YL *= FontScale;
	Canvas.FontScaleX = FontScale;
	Canvas.FontScaleY = FontScale;

	X = Canvas.ClipX * 0.1;
	Y = Canvas.ClipY * 0.1;

	for(i = 0; i < WeaponGroups.Length; i++)
	{
		Canvas.SetDrawColor(255, 255, 255, 192);

		Canvas.SetPos(X, Y);
		Canvas.DrawText("GROUP" @ WeaponGroups[i].InvGroup);
		Y += YL;

		for(j = 0; j < WeaponGroups[i].WList.Length; j++)
		{
			if(i == SelectedGroupIndex && j == SelectedWListIndex)
				Canvas.SetDrawColor(255, 255, 0, 192);
			else
				Canvas.SetDrawColor(255, 255, 255, 192);

			Canvas.SetPos(X, Y);
			Canvas.DrawText("      " $ WeaponGroups[i].WList[j].ItemName @ WeaponGroups[i].WList[j].GroupOffset);
			Y += YL;
		}
	}

	// Other info.
	Canvas.SetDrawColor(255, 255, 255, 192);
	X = Canvas.ClipX * 0.9;
	Y = Canvas.ClipY * 0.1;
	S = "Cur. carousel angle:" @ string(CarouselAngle);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Y += YL;
	S = "Dest. carousel angle:" @ string(DesCarouselAngle);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Y += YL;
	S = "CurCarouselPos.X:" @ string(CurCarouselPos.X);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Y += YL;
	S = "CurCarouselPos.Y:" @ string(CurCarouselPos.Y);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Y += YL;
	S = "DesCarouselPos.X:" @ string(DesCarouselPos.X);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Y += YL;
	S = "DesCarouselPos.Y:" @ string(DesCarouselPos.Y);
	Canvas.TextSize(S, XL, YL);
	Canvas.SetPos(X - XL, Y);
	Canvas.DrawText(S);

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

// HUD-related functions.
function float GetTotalGroupLength()
{
	return (CurGroupCellSize.X * WeaponGroups.Length);
}

function DrawGroupCell(Canvas C, vector CurPos, int GroupIdx, float CanvasScale)
{
	local float XL, YL;
	local string S;
	local vector TextPos;

	// Set default draw color.
	C.DrawColor = NormalGroupElementColor;

	// Draw background.
	GetP2EUtils().SetPos(C, CurPos.X, CurPos.Y);
	C.DrawTileClipped(GroupCellTex, CurGroupCellSize.X, CurGroupCellSize.Y, 0, 0, GroupCellTex.USize, GroupCellTex.VSize);

	// Draw another background to indicate no ammo or selected.
	if(SelectedGroupIndex == GroupIdx)
	{
		GetP2EUtils().SetPos(C, CurPos.X, CurPos.Y);
		C.DrawColor = SelectedGroupElementColor;
		C.DrawTileClipped(SelectedGroupCellTex, CurGroupCellSize.X, CurGroupCellSize.Y, 0, 0, SelectedGroupCellTex.USize, SelectedGroupCellTex.VSize);
		C.DrawColor = NormalGroupElementColor;
	}

	// Draw group number.
//	C.Font = Font'P2Fonts.Fancy19';
	C.Font = GroupFont;
	GetP2EUtils().SetFontScale(C, GetP2EUtils().GetFontScale(GroupFontSize, 48.0, CanvasScale));

	// Get XL and YL for our text to be drawn.
	S = string(WeaponGroups[GroupIdx].InvGroup);
	C.TextSize(S, XL, YL);

	// Calculate drawing coordinates for the text. By default
	// it is centered inside the cell.
	TextPos.X = CurPos.X + ((CurGroupCellSize.X / 2) - (XL / 2));
	TextPos.Y = CurPos.Y + ((CurGroupCellSize.Y / 2) - (YL / 2));

	// Now set the drawing coordinates in Canvas and draw the text.
	GetP2EUtils().SetPos(C, TextPos.X, TextPos.Y);
	C.DrawTextClipped(S);

	// All done!
	GetP2EUtils().ResetFontScale(C);
}

function DrawWeaponListCell(Canvas C, vector CurPos, int GroupIdx, int ListIdx, float CanvasScale)
{
	local float AmmoPct, IconScaleFact;
	local vector AmmoBarPos, IconPos, IconSize;
	local Texture IconTex;
	local Weapon W;

	W = WeaponGroups[GroupIdx].WList[ListIdx];
	
	// Set default draw color.
	C.DrawColor = NormalWeaponElementColor;

	// Draw background.
	GetP2EUtils().SetPos(C, CurPos.X, CurPos.Y);
	C.DrawTileClipped(GroupCellTex, CurGroupCellSize.X, CurGroupCellSize.Y, 0, 0, GroupCellTex.USize, GroupCellTex.VSize);
//	DrawTextureClipped(C, GroupCellTex, GroupCellScale, CanvasScale);

	// Draw another background to indicate no ammo or selected.
	if(SelectedWListIndex == ListIdx || !W.HasAmmo() || !ValidHandsWeapon(W.Class))
	{
		GetP2EUtils().SetPos(C, CurPos.X, CurPos.Y);

		if(SelectedWListIndex == ListIdx)
			C.DrawColor = SelectedWeaponElementColor;
		else if(!W.HasAmmo() || !ValidHandsWeapon(W.Class))
			C.DrawColor = NoAmmoWeaponColor;

		C.DrawTileClipped(SelectedGroupCellTex, CurGroupCellSize.X, CurGroupCellSize.Y, 0, 0, SelectedGroupCellTex.USize, SelectedGroupCellTex.VSize);
	}
	// Set default draw color.
	C.DrawColor = NormalWeaponElementColor;

	// Set drawing region again to add border.
//	GetP2EUtils().SetDrawingRegion(C, C.OrgX, C.OrgY, C.ClipX, C.ClipY, GroupCellBorder);

	// Draw icon. And assume Texture is 512.
	if (P2Weapon(W) != None && P2Weapon(W).OverrideHUDIcon != None)
		IconTex = P2Weapon(W).OverrideHUDIcon;
	else if ((W.AmmoType != None) && (W.AmmoType.Texture != None))
		IconTex = Texture(W.AmmoType.Texture);
		
	if(IconTex != None)
	{
		if(float(IconTex.USize) > float(IconTex.VSize))
			IconScaleFact = (512.0 / IconTex.VSize);
		else
			IconScaleFact = (512.0 / IconTex.USize);

		IconSize.X = IconTex.USize * IconScaleFact * WeaponListIconScale * CanvasScale;
		IconSize.Y = IconTex.VSize * IconScaleFact * WeaponListIconScale * CanvasScale;

		IconPos.X = CurPos.X + ((CurGroupCellSize.X / 2) - (IconSize.X / 2));
		IconPos.Y = CurPos.Y + ((CurGroupCellSize.Y / 2) - (IconSize.Y / 2));
		GetP2EUtils().SetPos(C, IconPos.X, IconPos.Y);
		C.DrawTileClipped(IconTex, IconSize.X, IconSize.Y, 0, 0, IconTex.USize, IconTex.VSize);
	}

	// Draw ammo bar. But make sure we have ammo before doing so!
	AmmoPct = GetP2EUtils().GetAmmoPercent(W);
	// Skip ammo bar for hidden ammo
	if (W.AmmoType != None && P2AmmoInv(W.AmmoType) != None && !P2AmmoInv(W.AmmoType).bShowAmmoOnHud)
		AmmoPct = -1.0;

	if(AmmoPct != -1.0)
	{
		AmmoBarPos.X = CurPos.X;
		AmmoBarPos.Y = CurPos.Y + (CurGroupCellSize.Y - (CurGroupCellSize.Y * AmmoBarHeightFact));

		// Set initial position.
		GetP2EUtils().SetPos(C, AmmoBarPos.X, AmmoBarPos.Y);

		// Set back. drawing color.
		C.DrawColor = AmmoBarBGColor;

		// Draw max. bar. Going to use C.DrawTextureClipped for this instead.
		C.DrawTileClipped(Texture'Engine.WhiteSquareTexture', CurGroupCellSize.X, CurGroupCellSize.Y * AmmoBarHeightFact, 0, 0, 16, 16);

		// Now draw a red bar representing the ammo.
		// Have to set this again since DrawRect() changes C.CurX and C.CurY.
		GetP2EUtils().SetPos(C, AmmoBarPos.X, AmmoBarPos.Y);

		C.DrawColor = AmmoBarColor;
		C.DrawTileClipped(Texture'Engine.WhiteSquareTexture', CurGroupCellSize.X * AmmoPct, CurGroupCellSize.Y * AmmoBarHeightFact, 0, 0, 16, 16);
	}

	// All done!
//	GetP2EUtils().UnsetDrawingRegion(C);
}

// Master function for drawing the carousel selector.
function DrawCarouselSelector(Canvas C)
{
	local float Diff, CanvasScale, XL, YL;
	local int i, j;
	local string S;
	local vector CurPos, ClientRes, WNamePos;

	C.Style = 5;
	C.Z = 1;

	// Get scaling factors.
	CanvasScale = GetP2EUtils().GetCanvasScale(PlayerOwner);
	GetP2EUtils().GetClientResolution(PlayerOwner, ClientRes);
	WNamePos.X = C.ClipX*GetLeftBound(C);
	GetP2EUtils().SetDrawingRegion(C, WNamePos.X, 0, (C.ClipX*GetRightBound(C)) - WNamePos.X, C.ClipY);

	// Draw weapon name, but refer to DesCarouselPos instead.
	WNamePos.X = DesCarouselPos.X;
	WNamePos.Y = DesCarouselPos.Y - CurCarouselRadius - (CurGroupCellSize.Y * 1.5 * CarouselWBarSpacing);

	if(ValidIndexesSelected())
	{
		C.Font = GroupWNameFont;
		GetP2EUtils().SetFontScale(C,
			GetP2EUtils().GetFontScale(18.0, 48.0, CanvasScale));

		S = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex].Default.ItemName;
		C.TextSize(S, XL, YL);
		C.SetDrawColor(255, 255, 255, 192);
		GetP2EUtils().SetPos(C, WNamePos.X - (XL / 2),
					WNamePos.Y - (CurGroupCellSize.Y * CarouselWNameSpacing));
		C.DrawTextClipped(S);

		// Done! Reset the font scale.
		GetP2EUtils().ResetFontScale(C);
	}

	// Draw weapon groups.
	for(i = 0; i < WeaponGroups.Length; i++)
	{
		Diff = CarouselAngle - WeaponGroupAngles[i];
		CurPos.X = (CurCarouselPos.X + -CurCarouselRadius * Sin(Diff * PI / 180)) - (CurGroupCellSize.X / 2);
		CurPos.Y = (CurCarouselPos.Y - CurCarouselRadius * Cos(Diff * PI / 180)) - (CurGroupCellSize.Y / 2);

		// Temp. set drawing regions inside cell.
		GetP2EUtils().SetDrawingRegion(C, CurPos.X, CurPos.Y, CurGroupCellSize.X, CurGroupCellSize.Y);//, GroupCellBorder);

		// Draw the group cell.
		DrawGroupCell(C, CurPos, i, CanvasScale);

		// Restore previous drawing regions.
		GetP2EUtils().UnsetDrawingRegion(C);

		// If SelectedGroupIndex matches I, draw its weapon list.
		if(ValidIndexesSelected() && SelectedGroupIndex == i)
		{
			CurPos = WNamePos;
			CurPos.X -= (CurCarouselWLOffset + (CurGroupCellSize.X / 2));

			for(j = 0; j < WeaponGroups[i].WList.Length; j++)
			{
				// Temp. set drawing regions inside cell.
				GetP2EUtils().SetDrawingRegion(C, CurPos.X, CurPos.Y, CurGroupCellSize.X, CurGroupCellSize.Y);

				// Draw the list cell.
				DrawWeaponListCell(C, CurPos, i, j, CanvasScale);

				// Restore previous drawing regions.
				GetP2EUtils().UnsetDrawingRegion(C);

				// Increment positions.
				CurPos.X += CurGroupCellSize.X;
			}
		}
	}

	// All done! Reset drawing regions.
	while(GetP2EUtils().UnsetDrawingRegion(C))
		continue;
}

// Master function for drawing the entire weapon selector.
function DrawNormalSelector(Canvas C)
{
	local float CanvasScale, XL, YL;
	local int i, j;
	local string S;
	local vector CurPos, ClientRes;

	C.Style = 5;
	C.Z = 1;

	// Get scaling factors.
	CanvasScale = GetP2EUtils().GetCanvasScale(PlayerOwner);
	GetP2EUtils().GetClientResolution(PlayerOwner, ClientRes);

	CurPos.X = C.ClipX*GetLeftBound(C);
	if (bFullscreen)
		GetP2EUtils().SetDrawingRegion(C, 0, 0, C.ClipX, C.ClipY);
	else
		GetP2EUtils().SetDrawingRegion(C, CurPos.X, C.ClipY*0.5, (C.ClipX*GetRightBound(C)) - CurPos.X, C.ClipY*0.5);
	CurPos = CurGroupRowPos;

	if(ValidIndexesSelected())
	{
		C.Font = GroupWNameFont;
		GetP2EUtils().SetFontScale(C,
			GetP2EUtils().GetFontScale(GroupWNameFontSize, 48.0, CanvasScale));

		S = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex].Default.ItemName;
		C.TextSize(S, XL, YL);
		C.SetDrawColor(255, 255, 255, 192);
		GetP2EUtils().SetPos(C, (GroupBarPos.X * ClientRes.X) - (XL / 2),
					CurPos.Y + CurGroupCellSize.Y + ((YL * GroupBarWNameSpacing) / 2));
		C.DrawTextClipped(S);

		// Done! Reset the font scale.
		GetP2EUtils().ResetFontScale(C);
	}

	for(i = 0; i < WeaponGroups.Length; i++)
	{
		// Temp. set drawing regions inside cell.
		GetP2EUtils().SetDrawingRegion(C, CurPos.X, CurPos.Y, CurGroupCellSize.X, CurGroupCellSize.Y);//, GroupCellBorder);

		// Draw the group cell.
		DrawGroupCell(C, CurPos, i, CanvasScale);

		// Restore previous drawing regions.
		GetP2EUtils().UnsetDrawingRegion(C);

		// If SelectedGroupIndex matches I, draw its weapon list.
		if(ValidIndexesSelected() && SelectedGroupIndex == i)
		{
			// Set another clipping region above the group bar.
			GetP2EUtils().SetDrawingRegion(C, C.OrgX, C.OrgY, C.ClipX, CurPos.Y - C.OrgY);

			// Add scrolling offset.
			CurPos.Y += CurGroupWLPos;

			for(j = 0; j < WeaponGroups[i].WList.Length; j++)
			{
				CurPos.Y -= CurGroupCellSize.Y;

				// Temp. set drawing regions inside cell.
				GetP2EUtils().SetDrawingRegion(C, CurPos.X, CurPos.Y, CurGroupCellSize.X, CurGroupCellSize.Y);

				// Draw the list cell.
				DrawWeaponListCell(C, CurPos, i, j, CanvasScale);

				// Restore previous drawing regions.
				GetP2EUtils().UnsetDrawingRegion(C);
			}

			// Restore previous drawing regions.
			GetP2EUtils().UnsetDrawingRegion(C);

			// Reset this.
			CurPos.Y = CurGroupRowPos.Y;
		}

		// Recalculate current pos. for next tile.
		CurPos.X += CurGroupCellSize.X;
	}

	// All done! Reset drawing regions.
	while(GetP2EUtils().UnsetDrawingRegion(C))
		continue;
}
// HUD-related functions.

/** Overriden to implement menu functionality */
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta)
{
/*	if(Action == IST_Release)
	{
		if(Key == IK_LeftMouse)
			return MyLeftClick();

		if(Key == IK_RightMouse)
        		return MyRightClick();
		if(Key == IK_MouseWheelUp)
		{
			PrevWeapon();
			return true;
		}

		if(Key == IK_MouseWheelDown)
		{
			NextWeapon();
			return true;
		}

		if(Key == IK_LeftMouse)
			return SwitchWeaponByIndex();
	}*/
	return HandleJoystick(Key, Action, Delta);
}

protected final function RefreshWeaponArrays()
{
	local int i, j;

	for(i = 0; i < WeaponGroups.Length; i++)
	{
		for(j = 0; j < WeaponGroups[i].WList.Length; j++)
		{
			if((WeaponGroups[i].WList[j] == None) || (WeaponGroups[i].WList[j].bDeleteMe)
			|| (PlayerOwner.Pawn.FindInventoryType(WeaponGroups[i].WList[j].Class) == None))
			{
				WeaponGroups[i].WList.Remove(j, 1);
				j--;

				if(WeaponGroups[i].WList.Length == 0)
				{
					WeaponGroups.Remove(i, 1);
					i--;
				}
			}
		}
	}
}

protected function SetDestinations(bool bNoInterp)
{
	local vector ClientRes;

	GetP2EUtils().GetClientResolution(ViewportOwner.Actor, ClientRes);

	if(!ValidIndexesSelected())
	{
		DesGroupRowPos.Y = ClientRes.Y + CurGroupCellSize.Y;
		DesCarouselPos.X = CarouselPos.X * ClientRes.X;
		DesCarouselPos.Y = ClientRes.Y + CurCarouselRadius + (CurGroupCellSize.Y / 2);
	}
	else
	{
		DesGroupRowPos.X = (ClientRes.X * GroupBarPos.X) - ((CurGroupCellSize.X / 2) + SelectedGroupIndex * CurGroupCellSize.X);
		DesGroupRowPos.Y = (ClientRes.Y * GroupBarPos.Y) - CurGroupCellSize.Y;
		DesCarouselPos.X = CarouselPos.X * ClientRes.X;
		DesCarouselPos.Y = CarouselPos.Y * ClientRes.Y;
		DesCarouselWLOffset = SelectedWListIndex * CurGroupCellSize.X;
		DesGroupWLPos = SelectedWListIndex * CurGroupCellSize.Y;
	}

	if(bNoInterp)
	{
		CurGroupRowPos = DesGroupRowPos;
		CurCarouselWLOffset = DesCarouselWLOffset;
		CurCarouselPos = DesCarouselPos;
		CarouselAngle = DesCarouselAngle;
		CurGroupWLPos = DesGroupWLPos;
	}
}

function NotifyLevelChanged(string OldL, string NewL)
{
//	RefreshWeaponArrays();
//	ResetIndexes();
	RefreshSelector();
}

// Only recalculate cell size and other dimensions here.
function NotifyResolutionChanged(vector OldRes, vector NewRes)
{
	local float CanvasScale;

	CanvasScale = GetP2EUtils().GetCanvasScale(PlayerOwner);

	// Set initial positions.
	CurGroupCellSize.X = GroupCellTex.USize * GroupCellScale.X * CanvasScale;
	CurGroupCellSize.Y = GroupCellTex.VSize * GroupCellScale.Y * CanvasScale;

	CurCarouselRadius = CarouselRadius * CanvasScale;
	ResetIndexes();
	SetDestinations(true);
}

function UpdateScrollOffsets(float Delta)
{
	CurGroupRowPos = GetP2EUtils().VectorSpringInterp(DesGroupRowPos, CurGroupRowPos, Delta, 1024.0);
	CurCarouselPos = GetP2EUtils().VectorSpringInterp(DesCarouselPos, CurCarouselPos, Delta, 1024.0);
	CarouselAngle = GetP2EUtils().FloatSpringInterp(DesCarouselAngle, CarouselAngle, Delta, 1024.0);
	CurCarouselWLOffset = GetP2EUtils().FloatSpringInterp(DesCarouselWLOffset, CurCarouselWLOffset, Delta, 2048.0);
	CurGroupWLPos = GetP2EUtils().FloatSpringInterp(DesGroupWLPos, CurGroupWLPos, Delta, 1024.0);
/*
	// Hopefully the following will fix clamping problems caused by lag spikes!
	if(CurGroupRowPos.X > DesGroupRowPos.X)
		CurGroupRowPos.X = FMax(DesGroupRowPos.X, CurGroupRowPos.X);
	else
		CurGroupRowPos.X = FMin(CurGroupRowPos.X, DesGroupRowPos.X);

	if(CurGroupRowPos.Y > DesGroupRowPos.Y)
		CurGroupRowPos.Y = FMax(DesGroupRowPos.Y, CurGroupRowPos.Y);
	else
		CurGroupRowPos.Y = FMin(CurGroupRowPos.Y, DesGroupRowPos.Y);

	if(CurCarouselPos.X > DesCarouselPos.X)
		CurCarouselPos.X = FMax(DesCarouselPos.X, CurCarouselPos.X);
	else
		CurCarouselPos.X = FMin(CurCarouselPos.X, DesCarouselPos.X);

	if(CurCarouselPos.Y > DesCarouselPos.Y)
		CurCarouselPos.Y = FMax(DesCarouselPos.Y, CurCarouselPos.Y);
	else
		CurCarouselPos.Y = FMin(CurCarouselPos.Y, DesCarouselPos.Y);
*/
}

function Tick(float Delta)
{
	local int i;

	Super.Tick(Delta);

	if(PlayerOwner == None)
		return;

	if(PlayerOwner.Pawn == None)
	{
		// Keep group array empty if player has no pawn.
		if(WeaponGroups.Length > 0)
			WeaponGroups.Remove(0, WeaponGroups.Length);

		ResetIndexes();
		SetDestinations(true);
		return;
	}

	// Check for active screens.
	for(i = 0; i < ViewportOwner.LocalInteractions.Length; i++)
	{
		if((P2Screen(ViewportOwner.LocalInteractions[i]) != None)
		&& (P2Screen(ViewportOwner.LocalInteractions[i]).IsRunning()))
		{
			ResetIndexes();
			break;
		}
	}

	SetDestinations(false);
	UpdateScrollOffsets(Delta);

	if (ValidIndexesSelected())
	{
		SelectorIdleTime += Delta;
		//ErikFOV Change: Fix problem
		/*if ((P2GameInfo(PlayerOwner.Level.Game).bWeaponSelectorAutoSwitch && SelectorIdleTime > TimeoutDelayAuto && TimeoutDelayAuto != 0)
			|| (!P2GameInfo(PlayerOwner.Level.Game).bWeaponSelectorAutoSwitch && SelectorIdleTime > TimeoutDelayNormal && TimeoutDelayNormal != 0)
			)*/
			
		if (( class'P2GameInfo'.Default.bWeaponSelectorAutoSwitch && SelectorIdleTime > TimeoutDelayAuto && TimeoutDelayAuto != 0)
			|| (!class'P2GameInfo'.Default.bWeaponSelectorAutoSwitch && SelectorIdleTime > TimeoutDelayNormal && TimeoutDelayNormal != 0)
			)
			//end
			ResetIndexes();
	}
}

// A function to test out parented clipping regions.
function DrawClipDebug(Canvas C)
{
	local vector ClientRes, TS;
	local float CanvasScale;
	local vector BoxSize, BoxPos;
	local string S;

	C.Style = 5;
	C.Z = 1;

	// Get scaling factors.
	CanvasScale = GetP2EUtils().GetCanvasScale(PlayerOwner);
	GetP2EUtils().GetClientResolution(PlayerOwner, ClientRes);

	// Set first clipping.
	GetP2EUtils().SetDrawingRegion(C, C.ClipX*0.25, C.ClipY*0.25, C.ClipX*0.5, C.ClipY*0.5);

	// Set box size.
	BoxPos.X = ViewportOwner.WindowsMouseX;
	BoxPos.Y = ViewportOwner.WindowsMouseY;
	BoxSize.X = 300 * CanvasScale;
	BoxSize.Y = 150 * CanvasScale;
	GetP2EUtils().SetDrawingRegion(C, BoxPos.X, BoxPos.Y, BoxSize.X, BoxSize.Y);

	// Draw the box.
	GetP2EUtils().SetPos(C, BoxPos.X, BoxPos.Y);
	C.DrawTileClipped(GroupCellTex, BoxSize.X, BoxSize.Y, 0, 0, GroupCellTex.USize, GroupCellTex.VSize);

	// Draw some text in the box.
	S = string(C.OrgX) @ string(C.OrgY) @ string(C.ClipX) @ string(C.ClipY);
	C.Font = GroupFont;
	GetP2EUtils().SetFontScale(C, GetP2EUtils().GetFontScale(15, 48.0, CanvasScale));

	C.TextSize(S, TS.X, TS.Y);
	GetP2EUtils().SetPos(C, BoxPos.X + ((BoxSize.X / 2) - (TS.X / 2)),
			BoxPos.Y + ((BoxSize.Y / 2) - (TS.Y / 2)));

	C.SetDrawColor(255,255,255,255);
	C.DrawTextClipped(S);
	GetP2EUtils().ResetFontScale(C);

	// All done! Reset drawing regions.
	while(GetP2EUtils().UnsetDrawingRegion(C))
		continue;
}

function PostRender(Canvas Canvas)
{
	if(PlayerOwner == None)
		return;

	if((PlayerOwner.Pawn == None) || (WeaponGroups.Length == 0))
		return;

	if(SelectorType == STYPE_Carousel)
		DrawCarouselSelector(Canvas);
	else
		DrawNormalSelector(Canvas);

//	DrawClipDebug(Canvas);
}

///////////////////////////////////////////////////////////////////////////////
// Menu keys enabled while using the weapon selector.
///////////////////////////////////////////////////////////////////////////////
function execMenuButton();
function execConfirmButton();
function execBackButton();
function execMenuUpButton()
{
	local Weapon W;
	local int i;
	
	if (ValidIndexesSelected())
	{	
		W = None;
		while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
		{
			SelectedWListIndex++;
			CorrectIndexes();
			W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
			i++;
		}
		GetSoundActor().PlaySound(ScrollingThruGroupSound);	
	}
}
function execMenuDownButton()
{
	local Weapon W;
	local int i;
	
	if (ValidIndexesSelected())
	{	
		W = None;
		while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
		{
			SelectedWListIndex--;
			CorrectIndexes();
			W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
			i++;
		}
		GetSoundActor().PlaySound(ScrollingThruGroupSound);	
	}
}
function execMenuLeftButton()
{
	local Weapon W;
	local int i;

	if (ValidIndexesSelected())
	{	
		W = None;
		while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
		{
			SelectedGroupIndex--;
			SelectedWListIndex=0;
			CorrectIndexes();
			W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
			i++;
		}
		GetSoundActor().PlaySound(ScrollingThruGroupSound);	
	}
}
function execMenuRightButton()
{
	local Weapon W;
	local int i;
	
	if (ValidIndexesSelected())
	{	
		W = None;
		while ((W == None || !W.HasAmmo() || !ValidHandsWeapon(W.Class)) && i < 100)
		{
			SelectedGroupIndex++;
			SelectedWListIndex=0;
			CorrectIndexes();
			W = WeaponGroups[SelectedGroupIndex].WList[SelectedWListIndex];
			i++;
		}
		GetSoundActor().PlaySound(ScrollingThruGroupSound);	
	}
}

//ErikFOV Change: For Nick's coop
function CoopClearList()
{
	WeaponGroups.Remove(0, WeaponGroups.Length);
}

function CoopGetList()
{
	local Inventory inv;
	local int Count;

	PlayerOwner = P2Player(ViewportOwner.Actor);
	//WeaponGroups.Remove(0, WeaponGroups.Length);

	for(inv = PlayerOwner.Pawn.Inventory; inv != None; inv = inv.Inventory)
	{
		if( inv != None && !inv.bDeleteMe && Weapon(inv) != None )
			AddWeapon(Weapon(inv));

		Count++;

		if(Count > 5000)
			break;
	}
	ResetIndexes();
	RefreshCarouselArray();
	SetDestinations(true);
}
//end

// Change by NickP: MP fix
function xCoopRefreshList()
{
	if(PlayerOwner != None && PlayerOwner.Role < ROLE_Authority)
	{
		CoopClearList();
		CoopGetList();
	}
}
// End

defaultproperties
{
	NormalGroupElementColor=(R=255,G=255,B=255,A=255)
	SelectedGroupElementColor=(R=255,G=255,B=0,A=63)
	NormalWeaponElementColor=(R=255,G=255,B=255,A=255)
	SelectedWeaponElementColor=(R=255,G=255,B=0,A=63)
	NoAmmoWeaponColor=(R=160,G=0,B=0,A=63)

	AmmoBarBGColor=(R=63,G=63,B=63,A=255)
	AmmoBarColor=(R=160,G=0,B=0,A=255)

	SelectorType=STYPE_Normal

	GroupFont=Font'P2Fonts.Fancy48'
	GroupWNameFont=Font'P2Fonts.Fancy48'

	GroupFontSize=18
	GroupWNameFontSize=18

	AmmoBarHeightFact=0.1

	GroupBarPos=(X=0.5,Y=0.9)
	GroupBarWNameSpacing=1.25

	GroupCellBorder=0.1
	GroupCellTex=Texture'MpHUD.HUD.field_gray'
	GroupCellScale=(X=0.25,Y=0.5)
	SelectedGroupCellTex=Texture'Engine.WhiteSquareTexture'

	CarouselPos=(X=0.5,Y=1.1)
	CarouselRadius=150
	CarouselWBarSpacing=1.25
	CarouselWNameSpacing=1.25

	WeaponListIconScale=0.075

	SelectedWeaponSound=Sound'MiscSounds.Menu.MenuNew'
	ScrollingThruGroupSound=Sound'MiscSounds.Menu.MenuClick'
	BadWeaponSound=Sound'WeaponSounds.weapon_none'

	SelectedGroupIndex=-1
	SelectedWListIndex=-1

//	bAutoRemoveAfterLevelChange=True

	CannotEmptyHandsNowMsg="You cannot empty your hands right now."
	
	TimeoutDelayNormal=0.000000
	TimeoutDelayAuto=5.000000
}
