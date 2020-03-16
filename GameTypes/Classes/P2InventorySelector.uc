// Powerups: CrackInv, FastFoodInv, PizzaInv, DonutInv, GaryHeadInv, LeprechaunGaryInv, DualWieldInv, WaterBottleInv 
// Animal Control: CatInv, AWCatInv, BurnCatInv, CatnipInv, DogTreatInv, RadarInv, GunRadarPlugInv, CopRadarPlugInv, RocketCamInv, RadarTargetInv
// Errand: PayCheckInv, MilkInv, BookInv, LibraryBookInv, GaryBookInv, TreeInv, CitationInv, KrotchyInv, SteakInv, AlternatorInv, GiftInv, ParcelInv, PillsInv, AWNukeInv, ToiletPaperInv, MotherboardInv, ACPartInv, TicketInv, CureInv, StiltsInv, BlastingCapInv, C4Inv, PartnerRadioPowerupInv
// Misc: DudeClothesInv, CopClothesInv, GimpClothesInv, GimpClothesInvErrand, LawmanClothesInv,  StatInv,  MoneyInv,  ArcadeMoneyInv,  MapInv,  PLMapInv,  NewspaperInv,  PLNewspaperInv,  FlavinInv,  JunkInv, PokerChipInv

///////////////////////////////////////////////////////////////////////////////
// Screen the player can pop up to pick inventory items.
///////////////////////////////////////////////////////////////////////////////
class P2InventorySelector extends P2EInteraction;

///////////////////////////////////////////////////////////////////////////////
// Consts, structs, enums, etc.
///////////////////////////////////////////////////////////////////////////////
struct DisplayItem
{
	var Inventory Inv;						// Pointer to actual inventory item
	var int RowIndex;							// What row this thing should be drawn in
	var int ColIndex;							// What column this thing should be drawn in
	var int SortOrder;						// Sorting order, usually equal to GroupOffset
};

const INV_GROUP_BASE = 100;					// Base inventory group
const INV_GROUP_COUNT = 4;					// Number of rows on the selector
const INV_GROUP_POWERUP = 100;				// Powerup items: crack, dual wield soda, etc.
const INV_GROUP_ANIMAL = 101;				// Animal control and radar items: cats, catnip, dog treats, radar plugins, etc
const INV_GROUP_ERRAND = 102;				// Errand items: paycheck, milk, etc
const INV_GROUP_MISC = 103;					// Miscellaneous items. Also, anything that doesn't match any of the above inventory groups goes into this one (mod items)

///////////////////////////////////////////////////////////////////////////////
// Properties
///////////////////////////////////////////////////////////////////////////////
var() DrawInfo MenuDrawInfo;				// Where to draw the menu (as a function of Canvas 4:3 size)
var() DrawInfo InvDescDrawInfo;				// Where to draw the selected inventory description (as a function of Canvas 4:3 size)
var() DrawInfo InvCountDrawInfo;			// Where to draw the inventory count (as a function of the inventory icon size). Lower-right corner.
var() int IconsPerRow;						// Number of inventory icons to draw per row
var() Font InvInfoFont;						// Font to use for drawing
var() Font RowHeaderFont;					
var() Font InvCountFont;					
var() Texture BackgroundTex;				// Texture of background
var() float BackgroundAlpha;				// Alpha of background
var() Texture LeftArrow;						// Left arrow (duh)
var() Texture RightArrow;					// Right arrow (duh)
var() Texture RowHeader[INV_GROUP_COUNT];	// Row header
var() localized string RowTitle[INV_GROUP_COUNT];	// Row titles
var() Sound BadClickSound;					// Sound played when clicking a disabled arrow
var() Sound GoodClickSound;					// Sound played when clicking an enabled arrow
var() Sound InventorySelectSound;			// Sound made when selecting an inventory item and leaving menu
var() Sound SelectChangeSound;				// Sound made when selection changes

///////////////////////////////////////////////////////////////////////////////
// Vars
///////////////////////////////////////////////////////////////////////////////
var bool bMenuVisible;						// True if we're in the menu
var array<DisplayItem> DisplayItems;		// List of items we should draw
var int SelectOffset[INV_GROUP_COUNT];		// Offset of current icon selections
var int ItemCount[INV_GROUP_COUNT];		// Count of items per row, so we don't have to parse the entire array every frame
var byte bLockLeftArrow[INV_GROUP_COUNT];
var byte bLockRightArrow[INV_GROUP_COUNT];
var string HelpTitle, HelpText;				// Inventory information
var int SelectedItem;						// Which item we have selected, -1 for none
var int SelectedLeftArrow;					// Which left arrow we have selected, -1 for none
var int SelectedRightArrow;					// Which right arrow we have selected, -1 for none
var bool bUpdateMouseSelection;				// True if we should update the mouse selection
var int SetMouseX, SetMouseY;

///////////////////////////////////////////////////////////////////////////////
// ShowMenu - Pops up the inventory menu
///////////////////////////////////////////////////////////////////////////////
function ShowMenu()
{
	bMenuVisible = true;
	PauseGame();
	
	// Sort player's items into DisplayItems array.
	SortItemsIntoArray();
}

///////////////////////////////////////////////////////////////////////////////
// HideMenu - Closes the menu
///////////////////////////////////////////////////////////////////////////////
function HideMenu(optional bool bDontResume)
{
	bMenuVisible = false;
	if (!bDontResume)
		ResumeGame();
}

///////////////////////////////////////////////////////////////////////////////
// ToggleMenu - Shows menu if it's hidden, hides if it's not
///////////////////////////////////////////////////////////////////////////////
function ToggleMenu()
{
	if (bMenuVisible)
		HideMenu();
	else
		ShowMenu();
}

///////////////////////////////////////////////////////////////////////////////
// Failsafe, this should never be called when the menu is up but just in case.
///////////////////////////////////////////////////////////////////////////////
event NotifyLevelChanged(string OldL, string NewL)
{
	if (bMenuVisible)
		HideMenu();
		
	Super.NotifyLevelChanged(OldL, NewL);
}

///////////////////////////////////////////////////////////////////////////////
// SortItemsIntoArray - Sorts the Dude's items into a DisplayItem array
///////////////////////////////////////////////////////////////////////////////
function SortItemsIntoArray()
{
	local int i;
	local Inventory Inv;
	local P2PowerupInv Powerup;
	local int PowerupIndex[INV_GROUP_COUNT];	// Keep track of what order we're in
	local int UseRow, UseCol, UseSort;			// Temp vars
	
	// Empty current item list, if any.
	DisplayItems.Length = 0;
	for (i = 0; i < INV_GROUP_COUNT; i++)
	{
		ItemCount[i] = 0;
		bLockLeftArrow[i] = 0;
		bLockRightArrow[i] = 0;
	}

	for (Inv = PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		// Only track actual P2Powerup items
		if (P2PowerupInv(Inv) != None)
		{		
			Powerup = P2PowerupInv(Inv);
			DisplayItems.Insert(0, 1);
			
			// Sanity check inventory group, if it doesn't fit in with anything then lump it into the misc category
			if (Inv.InventoryGroup < INV_GROUP_BASE
				|| Inv.InventoryGroup >= INV_GROUP_BASE + INV_GROUP_COUNT)
			{
				UseRow = INV_GROUP_COUNT - 1;
				UseSort = 255;
			}
			else
			{
				UseRow = Inv.InventoryGroup - INV_GROUP_BASE;
				UseSort = Inv.GroupOffset;
			}
			
			DisplayItems[0].Inv = Inv;
			DisplayItems[0].RowIndex = UseRow;
			DisplayItems[0].ColIndex = PowerupIndex[UseRow]++;
			DisplayItems[0].SortOrder = UseSort;
			ItemCount[UseRow]++;
		}
	}
	
	// Sort items so they'll draw from left to right based on group offset
	BubbleSortDisplayOrder();
	
	// Debug Me
	//for (i = 0; i < DisplayItems.Length; i++)
		//log("********************"@DisplayItems[i].Inv@DisplayItems[i].RowIndex@DisplayItems[i].ColIndex);
	for (i = 0; i < INV_GROUP_COUNT; i++)
	{
		//log("ROW"@i@"ITEM COUNT ="@ItemCount[i]);
		if (ItemCount[i] - IconsPerRow < 0)
			SelectOffset[i] = 0;
		else if (SelectOffset[i] > ItemCount[i] - IconsPerRow)
			SelectOffset[i] = ItemCount[i] - IconsPerRow;
	}
	RefreshArrows();
}

///////////////////////////////////////////////////////////////////////////////
// Bubble sorts display order
///////////////////////////////////////////////////////////////////////////////
function BubbleSortDisplayOrder()
{
	local int i, j, k;
	
	// Ensure inventory items are sorted by group offset
	for (i = 0; i < DisplayItems.Length; i++)
		for (j = 0; j < DisplayItems.Length; j++)
		{
			if (DisplayItems[i].RowIndex == DisplayItems[j].RowIndex
				&& DisplayItems[i].SortOrder < DisplayItems[j].SortOrder
				&& DisplayItems[i].ColIndex > DisplayItems[j].ColIndex)
			{
				k = DisplayItems[i].ColIndex;
				DisplayItems[i].ColIndex = DisplayItems[j].ColIndex;
				DisplayItems[j].ColIndex = k;
			}
		}
}

// Fits tile scaled and centered in a given region (X1,Y1)-(X2,Y2)
function FitTile(Canvas Canvas, Texture Tile, float X1, float Y1, float dX, float dY, optional float Scale)
{
	local float UseScale, PosX, PosY;
	
	if (Scale == 0)
		Scale = 1.f;
	
	// Scale down if too big.
	if (Tile.USize > dX || Tile.VSize > dY)
	{
		if (Tile.USize > Tile.VSize)
			UseScale = dX / Tile.USize;
		else
			UseScale = dY / Tile.VSize;
	}
	// Scale up if too small.
	else if (Tile.USize < dX && Tile.vSize < dY)
	{
		if (Tile.USize > Tile.VSize)
			UseScale = dX / Tile.USize;
		else
			UseScale = dY / Tile.VSize;
	}
	else
		UseScale = 1.f;
	
	// Align tile
	PosX = X1 + (dX - (Tile.USize * UseScale * Scale)) / 2.f;
	PosY = Y1 + (dY - (Tile.VSize * UseScale * Scale)) / 2.f;
	
	// Draw tile
	Canvas.SetPos(PosX, PosY);
	Canvas.DrawTile(Tile, Tile.USize * UseScale * Scale, Tile.VSize * UseScale * Scale, 0, 0, Tile.USize, Tile.VSize);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function PostRender(Canvas Canvas)
{
	local float CanvasScale;
	local vector CanvasDimensions, TopLeft;
	local int i, j, ColPos, amount;
	local float IconXSize, IconYSize;			// Size of icons to draw
	local float PosX, PosY, XL, YL, OldYL;
	local float MouseX, MouseY;	
	
	// Only draw the menu if it should be visible.
	if (!bMenuVisible)
		return;		
	
    /** Half assed fix for preventing the menu from persisting during Pausing
     * and then quitting back to the main menu
     */
    if (AreAnyRootWindowsRunning())
        HideMenu(true);

	if (bUpdateMouseSelection)
	{
		MouseX = ViewportOwner.WindowsMouseX;
		MouseY = ViewportOwner.WindowsMouseY;
		SelectedItem = -1;
		SelectedLeftArrow = -1;
		SelectedRightArrow = -1;
	}
	
   /** Setup initial rendering stuff like the style and font */
	Canvas.Reset();
	Canvas.ClipX = Canvas.SizeX;
	Canvas.ClipY = Canvas.SizeY;
    Canvas.Style = 5; // Steven: Changed to STY_Alpha.
    Canvas.Font = InvInfoFont;
    Canvas.SetDrawColor(255, 255, 255, 255);

    /** Find our draw scale, left bound, and record original font scale */
    CanvasScale = Canvas.ClipY / 768.0f;

    /** We want to ignore the extra X space as a result from widescreen resolutions */
    CanvasDimensions.X = ((4.0f / 3.0f) * Canvas.ClipY);
    CanvasDimensions.Y = Canvas.ClipY;
	
    TopLeft.X = GetLeftBound(Canvas) * CanvasDimensions.X + CanvasDimensions.X * MenuDrawInfo.Pos.X;
    TopLeft.Y = CanvasDimensions.Y * MenuDrawInfo.Pos.Y;
	
	// Calc size of icons
	IconXSize = CanvasDimensions.X * (MenuDrawInfo.Scale.X / (3.f + IconsPerRow));
	IconYSize = CanvasDimensions.Y * (MenuDrawInfo.Scale.Y / INV_GROUP_COUNT);
	
	// Draw background
	Canvas.SetDrawColor(255, 255, 255, BackgroundAlpha * 255);
	Canvas.SetPos(TopLeft.X, TopLeft.Y);
	Canvas.DrawTile(BackgroundTex, CanvasDimensions.X * MenuDrawInfo.Scale.X, CanvasDimensions.Y * MenuDrawInfo.Scale.Y, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
	Canvas.SetDrawColor(255, 255, 255, 255);
	
	// Draw row headers, forward, and back buttons
	GetP2EUtils().SetDrawingRegion(Canvas, TopLeft.X, TopLeft.Y, CanvasDimensions.X * MenuDrawInfo.Scale.X, CanvasDimensions.X * MenuDrawInfo.Scale.Y);
	//Canvas.SetOrigin(TopLeft.X, TopLeft.Y);
	//Canvas.SetClip(CanvasDimensions.X * MenuDrawInfo.Scale.X, CanvasDimensions.X * MenuDrawInfo.Scale.Y);
	for (i = 0; i < INV_GROUP_COUNT; i++)
	{
		// Row header
		Canvas.SetDrawColor(255, 255, 255, 255);
		PosX = 1;
		PosY = IconYSize * i;		
		//FitTile(Canvas, RowHeader[i], PosX, PosY, IconXSize, IconYSize);
		Canvas.StrLen(RowTitle[i], XL, YL);
		PosX += (IconXSize - XL) / 2.f;
		PosY += (IconYSize - YL) / 2.f;
		Canvas.Font = RowHeaderFont;
		Canvas.SetPos(PosX, PosY);
		Canvas.DrawText(RowTitle[i]);
		
		// Back arrow
		PosX = IconXSize;
		PosY = IconYSize * i;
		//Canvas.SetPos(PosX, PosY);
		if (bUpdateMouseSelection &&
			MouseX >= PosX + TopLeft.X && MouseX <= PosX + TopLeft.X + IconXSize
			&& MouseY >= PosY + TopLeft.Y && MouseY <= PosY + TopLeft.Y + IconYSize)
		{
			SelectedLeftArrow = i;
			HelpTitle = "";
			HelpText = "";
		}
		// Draw selection tile
		if (SelectedLeftArrow == i)
		{
			Canvas.SetDrawColor(64, 64, 64, 255);
			Canvas.SetPos(PosX, PosY);
			Canvas.DrawPattern(Texture'engine.WhiteSquareTexture', IconXSize, IconYSize, 1.0);
		}
		// Dim arrow if it's locked and unusable
		if (bLockLeftArrow[i] == 1)
			Canvas.SetDrawColor(64, 64, 64, 255);
		else
			Canvas.SetDrawColor(255, 255, 255, 255);
		FitTile(Canvas, LeftArrow, PosX, PosY, IconXSize, IconYSize);
		
		// Forward arrow
		PosX += IconXSize * (IconsPerRow + 1);
		//Canvas.SetPos(PosX, PosY);
		if (bUpdateMouseSelection &&
			MouseX >= PosX + TopLeft.X && MouseX <= PosX + TopLeft.X + IconXSize
			&& MouseY >= PosY + TopLeft.Y && MouseY <= PosY + TopLeft.Y + IconYSize)
		{
			SelectedRightArrow = i;
			HelpTitle = "";
			HelpText = "";
		}
		// Draw selection tile
		if (SelectedRightArrow == i)
		{
			Canvas.SetDrawColor(64, 64, 64, 255);
			Canvas.SetPos(PosX, PosY);
			Canvas.DrawPattern(Texture'engine.WhiteSquareTexture', IconXSize, IconYSize, 1.0);
		}
		// Dim arrow if it's locked and unusable
		if (bLockRightArrow[i] == 1)
			Canvas.SetDrawColor(64, 64, 64, 255);
		else
			Canvas.SetDrawColor(255, 255, 255, 255);
		FitTile(Canvas, RightArrow, PosX, PosY, IconXSize, IconYSize);
	}
	
	// Draw icons
	Canvas.SetDrawColor(255, 255, 255, 255);
	for (i = 0; i < DisplayItems.Length; i++)
	{
		// Sanity check.
		if (DisplayItems[i].Inv != None)
		{
			// Figure position based on current selection
			// Determine position in row and whether or not it's "on-screen" and should be drawn
			ColPos = 2 + DisplayItems[i].ColIndex - SelectOffset[DisplayItems[i].RowIndex];
			if (ColPos >= 2 && ColPos < 2 + IconsPerRow)
			{
				PosX = IconXSize * ColPos;
				PosY = IconYSize * (DisplayItems[i].RowIndex);
				//Canvas.SetPos(PosX, PosY);
				//DrawTexture(Canvas, Texture(DisplayItems[i].Inv.Icon), Vect(0.25,0.25,0), CanvasScale);
				
				if (bUpdateMouseSelection &&
					MouseX >= PosX + TopLeft.X && MouseX <= PosX + TopLeft.X + IconXSize
					&& MouseY >= PosY + TopLeft.Y && MouseY <= PosY + TopLeft.Y + IconYSize)
				{
					SelectedItem = i;
					HelpTitle = P2PowerupInv(DisplayItems[i].Inv).PowerupName;
					HelpText = P2PowerupInv(DisplayItems[i].Inv).PowerupDesc;
					bUpdateMouseSelection = false;
				}
				// Draw selection tile
				if (SelectedItem == i)
				{
					Canvas.SetDrawColor(64, 64, 64, 255);
					Canvas.SetPos(PosX, PosY);
					Canvas.DrawPattern(Texture'engine.WhiteSquareTexture', IconXSize, IconYSize, 1.0);
					Canvas.SetDrawColor(255, 255, 255, 255);
				}
				FitTile(Canvas, Texture(DisplayItems[i].Inv.Icon), PosX, PosY, IconXSize, IconYSize, 0.75);
				
				// Draw inv count
				if (P2PowerupInv(DisplayItems[i].Inv).Amount > 1)
				{
					Canvas.Font = InvCountFont;
					amount = P2PowerupInv(DisplayItems[i].Inv).Amount;
					Canvas.StrLen(amount, XL, YL);
					Canvas.SetPos(PosX + InvCountDrawInfo.Pos.X * IconXSize - XL, PosY + InvCountDrawInfo.Pos.Y * IconYSize - YL);
					Canvas.DrawText(amount);
				}
			}
		}
	}
	
	if (bUpdateMouseSelection && SelectedLeftArrow == -1 && SelectedRightArrow == -1 && SelectedItem == -1)
	{
		bUpdateMouseSelection = false;
		HelpTitle = "";
		HelpText = "";
	}

	GetP2EUtils().UnsetDrawingRegion(Canvas);

	// Border box
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TopLeft.X - 1, TopLeft.Y - 1);
	Canvas.DrawBox(Canvas, CanvasDimensions.X * MenuDrawInfo.Scale.X, CanvasDimensions.Y * MenuDrawInfo.Scale.Y);
	
	// Grid Lines
	for (i = 0; i < INV_GROUP_COUNT; i++)
	{
		Canvas.SetPos(TopLeft.X, TopLeft.Y + IconYSize * (i + 1));
		Canvas.DrawLine(3, IconXSize * (IconsPerRow + 3));
	}
	
	// Draw help text
    TopLeft.X = GetLeftBound(Canvas) * CanvasDimensions.X + CanvasDimensions.X * InvDescDrawInfo.Pos.X;
    TopLeft.Y = CanvasDimensions.Y * InvDescDrawInfo.Pos.Y;
	
	GetP2EUtils().SetDrawingRegion(Canvas, TopLeft.X, TopLeft.Y, CanvasDimensions.X * InvDescDrawInfo.Scale.X, CanvasDimensions.Y * InvDescDrawInfo.Scale.Y);
	//Canvas.SetOrigin(TopLeft.X, TopLeft.Y);
	//Canvas.SetClip(CanvasDimensions.X * InvDescDrawInfo.Scale.X, CanvasDimensions.Y * InvDescDrawInfo.Scale.Y);
	Canvas.Font = InvInfoFont;
	
	// Line 1
	Canvas.StrLen(HelpTitle, XL, YL);
	Canvas.SetPos((InvDescDrawInfo.Scale.X * CanvasDimensions.X - XL) / 2.f + 2, 2);
	Canvas.SetDrawColor(0, 0, 0, 255);
	Canvas.DrawText(HelpTitle);
	Canvas.SetPos((InvDescDrawInfo.Scale.X * CanvasDimensions.X - XL) / 2.f, 0);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawText(HelpTitle);
	OldYL = YL;
	
	// Line 2
	Canvas.StrLen(HelpText, XL, YL);
	Canvas.SetPos((InvDescDrawInfo.Scale.X * CanvasDimensions.X - XL) / 2.f + 2, OldYL + 2);
	Canvas.SetDrawColor(0, 0, 0, 255);
	Canvas.DrawText(HelpText);
	Canvas.SetPos((InvDescDrawInfo.Scale.X * CanvasDimensions.X - XL) / 2.f, OldYL);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawText(HelpText);
	
	GetP2EUtils().UnsetDrawingRegion(Canvas);	

    /** Draw the player's cursor last so it goes over everything */
    if (CursorTexture != none
		&& !UWindowRootWindow(Master.BaseMenu).bUsingJoystick) {
        Canvas.SetPos(ViewportOwner.WindowsMouseX, ViewportOwner.WindowsMouseY);
        DrawTexture(Canvas, CursorTexture, CursorDrawScale, CanvasScale);
    }
}

///////////////////////////////////////////////////////////////////////////////
// Determines whether the various arrows should be locked out or not
///////////////////////////////////////////////////////////////////////////////
function RefreshArrows()
{
	local int i;
	
	for (i = 0; i < INV_GROUP_COUNT; i++)
	{
		// Left arrow
		if (SelectOffset[i] <= 0)
			bLockLeftArrow[i] = 1;
		else
			bLockLeftArrow[i] = 0;
			
		// Right arrow
		if (SelectOffset[i] >= ItemCount[i] - IconsPerRow)
			bLockRightArrow[i] = 1;
		else
			bLockRightArrow[i] = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Scrolls icons in a row by a given offset
///////////////////////////////////////////////////////////////////////////////
function ScrollRow(int Row, int Offset)
{
	local int OldValue;
	
	OldValue = SelectOffset[Row];
	
	SelectOffset[Row] += Offset;

	// Sanity clamp
	if (SelectOffset[Row] < 0)
		SelectOffset[Row] = 0;
	else if (SelectOffset[Row] > ItemCount[Row] - IconsPerRow)
		SelectOffset[Row] = ItemCount[Row] - IconsPerRow;
	if (ItemCount[Row] - IconsPerRow < 0)
		SelectOffset[Row] = 0;
		
	// Play a click when we scroll
	if (OldValue != SelectOffset[Row])
		GetSoundActor().PlaySound(GoodClickSound);
		
	// Update arrows
	RefreshArrows();
	
	// Update selection
	bUpdateMouseSelection = true;
}

///////////////////////////////////////////////////////////////////////////////
// They clicked the mouse, do something.
///////////////////////////////////////////////////////////////////////////////
function MouseClick()
{
	if (SelectedLeftArrow > -1)
	{
		ScrollRow(SelectedLeftArrow, -1);
		/*
		if (bLockLeftArrow[SelectedLeftArrow] == 0)
			//GetSoundActor().PlaySound(BadClickSound);
		//else
			GetSoundActor().PlaySound(GoodClickSound);
		
		// Scroll selected row back
		SelectOffset[SelectedLeftArrow]--;
		// Sanity clamp
		if (SelectOffset[SelectedLeftArrow] < 0)
			SelectOffset[SelectedLeftArrow] = 0;
		else if (SelectOffset[SelectedLeftArrow] > ItemCount[SelectedLeftArrow] - IconsPerRow)
			SelectOffset[SelectedLeftArrow] = ItemCount[SelectedLeftArrow] - IconsPerRow;
		if (ItemCount[SelectedLeftArrow] - IconsPerRow < 0)
			SelectOffset[SelectedLeftArrow] = 0;
		//Clamp(SelectOffset[SelectedLeftArrow], 0, ItemCount[SelectedLeftArrow] - IconsPerRow);
		//log("Clamped"@SelectOffset[SelectedLeftArrow]@"to 0-"@ItemCount[SelectedLeftArrow] - IconsPerRow);		
		RefreshArrows();
		*/
	}
	if (SelectedRightArrow > -1)
	{
		ScrollRow(SelectedRightArrow, 1);
		/*
		if (bLockRightArrow[SelectedRightArrow] == 0)
			//GetSoundActor().PlaySound(BadClickSound);
		//else
			GetSoundActor().PlaySound(GoodClickSound);
			
		// Scroll selected row forward
		SelectOffset[SelectedRightArrow]++;
		// Sanity clamp
		if (SelectOffset[SelectedRightArrow] < 0)
			SelectOffset[SelectedRightArrow] = 0;
		else if (SelectOffset[SelectedRightArrow] > ItemCount[SelectedRightArrow] - IconsPerRow)
			SelectOffset[SelectedRightArrow] = ItemCount[SelectedRightArrow] - IconsPerRow;
		if (ItemCount[SelectedRightArrow] - IconsPerRow < 0)
			SelectOffset[SelectedRightArrow] = 0;
		//Clamp(SelectOffset[SelectedRightArrow], 0, ItemCount[SelectedRightArrow] - IconsPerRow);
		//log("Clamped"@SelectOffset[SelectedRightArrow]@"to 0-"@ItemCount[SelectedRightArrow] - IconsPerRow);
		RefreshArrows();
		*/
	}
	if (SelectedItem > -1)
	{
		// Change to selected item and resume the game.
		//log("SwitchToThis"@DisplayItems[SelectedItem].Inv@DisplayItems[SelectedItem].Inv.InventoryGroup@DisplayItems[SelectedItem].Inv.GroupOffset);
		//PlayerOwner.SwitchToThisPowerup(DisplayItems[SelectedItem].Inv.InventoryGroup, DisplayItems[SelectedItem].Inv.GroupOffset);
		PlayerOwner.Pawn.SelectedItem = Powerups(DisplayItems[SelectedItem].Inv);
		PlayerOwner.InvChanged();
		GetSoundActor().PlaySound(InventorySelectSound);
		HideMenu();
	}
}

///////////////////////////////////////////////////////////////////////////////
// They clicked the mouse, do something.
///////////////////////////////////////////////////////////////////////////////
function MouseWheel(int Offset)
{
	local int Row;
	
	// Figure what row they're in and scroll that row
	Row = -1;
	
	if (SelectedLeftArrow > -1)
		Row = SelectedLeftArrow;
	else if (SelectedRightArrow > -1)
		Row = SelectedRightArrow;
	else if (SelectedItem > -1)
		Row = DisplayItems[SelectedItem].RowIndex;
		
	if (Row != -1)
		ScrollRow(Row, Offset);
}

///////////////////////////////////////////////////////////////////////////////
// Navigate on the grid based on current selection
///////////////////////////////////////////////////////////////////////////////
function Navigate(int XDelta, int YDelta)
{
	local int i, MinRow, MinCol, XCur, YCur, OldSelectedItem;
	local bool bDone;
	MinRow = INV_GROUP_COUNT + 1;
	MinCol = IconsPerRow;
	
	// If we're not on anything, go to first inventory slot.
	if (SelectedItem == -1)
	{
		// Find first item
		for (i = 0; i < DisplayItems.Length; i++)
			if (DisplayItems[i].RowIndex < MinRow
				&& DisplayItems[i].ColIndex < MinCol)
			{
				SelectedItem = i;
				MinRow = DisplayItems[i].RowIndex;
				MinCol = DisplayItems[i].ColIndex;
			}
	}
	else
	{
		// Back up current selection in case we need to go back to it.
		OldSelectedItem = SelectedItem;
		
		YCur = DisplayItems[SelectedItem].RowIndex;
		// Find actual X position on grid (will not match ColIndex)
		XCur = DisplayItems[SelectedItem].ColIndex - SelectOffset[DisplayItems[SelectedItem].RowIndex];
		
		// Shift to where we want to go
		XCur += XDelta;
		YCur += YDelta;
		
		// If we're off the grid, cycle items if possible.
		if (XCur < 0)
		{
			XCur = 0;
			ScrollRow(YCur, -1);
		}
		if (XCur >= IconsPerRow)
		{
			XCur = IconsPerRow - 1;
			ScrollRow(YCur, 1);
		}
		
		// Find item that matches, if any.
		while (!bDone)
		{
			SelectedItem = -1;
			for (i = 0; i < DisplayItems.Length; i++)
				if (DisplayItems[i].RowIndex == YCur
					&& DisplayItems[i].ColIndex - SelectOffset[DisplayItems[i].RowIndex] == XCur)
				{
					SelectedItem = i;
					break;
				}
				
			// Didn't find it? Try another row.
			if (SelectedItem == -1)
			{
				YCur += YDelta;
				XCur += XDelta;
				if (YCur < 0 || YCur > INV_GROUP_COUNT - 1
					|| XCur < 0 || XCur > IconsPerRow - 1)
				{
					// Bomb out.
					bDone = true;
					SelectedItem = OldSelectedItem;
				}
			}
			else
				bDone = true;
		}			
		// Failsafe
		if (SelectedItem == -1)
			SelectedItem = OldSelectedItem;
	}
	
	// Play a click
	GetSoundActor().PlaySound(GoodClickSound);
	
	// Update arrows
	RefreshArrows();
	
	// DO NOT update mouse selection, we're using the joystick.
	bUpdateMouseSelection = false;
	
	// DO update the inv hints
	if (SelectedItem != -1)
	{
		HelpTitle = P2PowerupInv(DisplayItems[SelectedItem].Inv).PowerupName;
		HelpText = P2PowerupInv(DisplayItems[SelectedItem].Inv).PowerupDesc;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Handle joystick input.
///////////////////////////////////////////////////////////////////////////////
function execMenuButton()
{
	HideMenu();
}
function execConfirmButton()
{
	MouseClick();
}
function execBackButton()
{
	HideMenu();
}
function execMenuUpButton()
{
	Navigate(0, -1);
}
function execMenuDownButton()
{
	Navigate(0, 1);
}
function execMenuLeftButton()
{
	Navigate(-1, 0);
}
function execMenuRightButton()
{
	Navigate(1, 0);
}

///////////////////////////////////////////////////////////////////////////////
// Handle input.
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta)
{
	if (bMenuVisible)
	{
		// Exit out on ESC
		if (Key == IK_Escape && Action == IST_Release)
			HideMenu();
		// Handle mouse
		else if (Action == IST_Axis && (Key == IK_MouseX || Key == IK_MouseY))
		{
			UWindowRootWindow(Master.BaseMenu).bUsingJoystick = false;
			bUpdateMouseSelection = true;
		}
		else if (Key == IK_LeftMouse && Action == IST_Release)
			MouseClick();
		else if (Key == IK_MouseWheelUp && Action == IST_Release)
			MouseWheel(-1);
		else if (Key == IK_MouseWheelDown && Action == IST_Release)
			MouseWheel(1);
		else if (Action == IST_Press && PlayerOwner.ConsoleCommand("ISKEYBIND"@Key@"InventoryMenu") == "1" && Key < IK_Joy1)
			HideMenu();
		else
			HandleJoystick(Key, Action, Delta);

		return true;
	}
	else
		return false;	
}

defaultproperties
{
    bActive=true
    bVisible=true
    bRequiresTick=true
	
    InvInfoFont=Font'P2Fonts.Plain24'
    RowHeaderFont=Font'P2Fonts.Plain19'
	InvCountFont=Font'P2Fonts.Plain19'
	MenuDrawInfo=(Pos=(X=0.15,Y=0.2),Scale=(X=0.7,Y=0.6))
	InvDescDrawInfo=(Pos=(X=0.15,Y=0.85),Scale=(X=0.7,Y=0.05)
	InvCountDrawInfo=(Pos=(X=0.95,Y=0.95))
	IconsPerRow=4
	BackgroundTex=Texture'nathans.Inventory.blackbox64'
	BackgroundAlpha=0.7
	LeftArrow=Texture'P2Misc.Icons.InvArrowLeft'
	RightArrow=Texture'P2Misc.Icons.InvArrowRight'
	RowHeader(0)=Texture'Josh-textures.signs.Cell_Block_A'
	RowHeader(1)=Texture'Josh-textures.signs.Cell_Block_B'
	RowHeader(2)=Texture'Josh-textures.signs.Cell_Block_H'
	RowHeader(3)=Texture'Josh-textures.signs.Cell_Block_FU'
	HelpTitle=""
	HelpText=""
	RowTitle(0)="Health"
	RowTitle(1)="Animals"
	RowTitle(2)="Errand"
	RowTitle(3)="Other"
	BadClickSound=Sound'WeaponSounds.weapon_none'
	GoodClickSound=Sound'MiscSounds.Menu.MenuClick'
	InventorySelectSound=Sound'MiscSounds.Menu.MenuNew'
	SelectChangeSound=Sound'MpSounds.Menu.MenuBeat'
	SelectedItem=-1
	SelectedLeftArrow=-1
	SelectedRightArrow=-1
}
