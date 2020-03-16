class DLCListCW extends UMenuMapListCW;

/*
#exec TEXTURE IMPORT FILE=Textures\dlc_01.dds NAME=dlc_01
#exec TEXTURE IMPORT FILE=Textures\dlc_02.dds NAME=dlc_02
#exec TEXTURE IMPORT FILE=Textures\dlc_03.dds NAME=dlc_03
#exec TEXTURE IMPORT FILE=Textures\dlc_04.dds NAME=dlc_04
#exec TEXTURE IMPORT FILE=Textures\dlc_05.dds NAME=dlc_05
#exec TEXTURE IMPORT FILE=Textures\dlc_06.dds NAME=dlc_06
#exec TEXTURE IMPORT FILE=Textures\dlc_07.dds NAME=dlc_07
#exec TEXTURE IMPORT FILE=Textures\P2CInvinciblePack.dds NAME=P2CInvinciblePack
#exec TEXTURE IMPORT FILE=Textures\ParkourPack.dds NAME=ParkourPack
#exec TEXTURE IMPORT FILE=Textures\dlc_08.dds NAME=dlc_08
#exec TEXTURE IMPORT FILE=Textures\RWSSupplyCrate.dds NAME=RWSSupplyCrate
#exec TEXTURE IMPORT FILE=Textures\dlc_x0.dds NAME=dlc_x0
#exec TEXTURE IMPORT FILE=Textures\dlc_x1.dds NAME=dlc_x1
#exec TEXTURE IMPORT FILE=Textures\dlc_09.dds NAME=dlc_09
#exec TEXTURE IMPORT FILE=Textures\dlc_y1.dds NAME=dlc_y1
*/

struct DLCDef {
	var() LevelSummary DLCSummary;
	var() float DLCPrice;
};

var() array<DLCDef> DLCItems;

function Created()
{
	Super(UMenuDialogClientWindow).Created();

	bNoClientBorder = true;
	
	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	FrameExclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMapListFrameCW(CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));

	Exclude = UMenuMapListExclude(CreateWindow(class'DLCListExclude', 0, 0, 100, 100));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMapListInclude(CreateWindow(class'UMenuMapListInclude', 0, 0, 100, 100));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;
	
	LoadMapList();
	
	Exclude.SetSelected(0,0);
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	Super(UMenuDialogClientWindow).Paint(C, X, Y);

	// Draw labels over list boxes
	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.DrawColor.A = 255;
	C.StrLen(ExcludeCaption, W, H);
	ClipText(C, (WinWidth/2 - W)/2, 2, ExcludeCaption, True);
	C.StrLen(IncludeCaption, W, H);
	ClipText(C, WinWidth/2 + (WinWidth/2 - W)/2, 2, IncludeCaption, True);

	// Draw arrows between lists
	TextY = (WinHeight - LIST_LABEL_HEIGHT - (BUTTON_HEIGHT * 2 + BUTTON_SPACEY)) / 2 + LIST_LABEL_HEIGHT;
	C.StrLen(MoveRightText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveRightText, true);
	TextY += BUTTON_HEIGHT + BUTTON_SPACEY;
	C.StrLen(MoveLeftText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveLeftText, true);
}

function Resized()
{
	local float ListWidth;

	Super(UMenuDialogClientWindow).Resized();

	ListWidth = WinWidth/2 - (BUTTON_WIDTH + BUTTON_SPACEX)/2;
	FrameExclude.WinTop = LIST_LABEL_HEIGHT;
	FrameExclude.WinLeft = 0;
	FrameExclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
	FrameInclude.WinTop = LIST_LABEL_HEIGHT;
	FrameInclude.WinLeft = WinWidth - ListWidth;
	FrameInclude.SetSize(ListWidth, WinHeight-LIST_LABEL_HEIGHT);
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function LoadMapList()
	{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local DLCList Item;		

	for (i=0; i < DLCItems.Length; i++)
	{
		Item = DLCList(Exclude.Items.Append(class'DLCList'));
		Item.MapName = DLCItems[i].DLCSummary.Title;
		Item.DisplayName = DLCItems[i].DLCSummary.Title;
		Item.Cost = DLCItems[i].DLCPrice;
	}
	
	//Exclude.Sort();
	}

function SetMap(string MapName)
{
	// find the DLC summary and pass it to DLCTabCW
	local int i;
	
	for (i=0; i < DLCItems.Length; i++)
		if (DLCItems[i].DLCSummary.Title == MapName)
			DLCTabCW(ParentWindow).SetDLC(DLCItems[i].DLCSummary);
}

function RecalcDLCCost()
{
	local UWindowList item;
	local float Total;
	
	Total = 0.0;
	for (item = Include.Items; item != None; item = Item.Next)
		if (DLCList(Item) != None)
			Total += DLCList(Item).Cost;

	DLCMainCW(BotmatchParent).UpdateMoneyWasted(Total);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super(UMenuDialogClientWindow).Notify(C, E);

	switch(E)
	{
	case DE_MouseMove:
		if(helparea != None)
			helparea.SetText(C.HelpText);
		break;
	case DE_MouseLeave:
		if(helparea != None)
			helparea.SetText("");
		break;
	case DE_Click:
		switch(C)
		{
		case Exclude:
			SetMap(UMenuMapList(Exclude.SelectedItem).MapName);
			Include.ClearSelectedItem();
			RecalcDLCCost();
			break;
		case Include:
			SetMap(UMenuMapList(Include.SelectedItem).MapName);
			Exclude.ClearSelectedItem();
			RecalcDLCCost();
			break;
		}
		break;
	// recalc DLC cost on double-click or mouse enter (either of which could potentially change the shopping cart)
	case DE_MouseEnter:
	case DE_DoubleClick:
		switch (C)
		{
			case Exclude:
			case Include:
				RecalcDLCCost();
				break;
		}
		break;
	}
}

// Skip saving map info
function SaveConfigs()
{
	Super(UMenuDialogClientWindow).SaveConfigs();
}

defaultproperties
{
	ExcludeCaption="Available Items"
	ExcludeHelp="Double-click or drag items over to your cart. DO IT NOW!!!"
	IncludeCaption="Shopping Cart"
	IncludeHelp="Items in this list will be purchased. Make sure it's as full as possible before clicking Buy!"

	// DLC summaries... this menu is basically a hack of the multiplayer map selection so just make 'em use the LevelSummary class. No need to reinvent the wheel for this
	Begin Object Class=LevelSummary Name="DLCSummaryWilly"
		Title="Uncensored Dude Willy ($69.99)"
		Description="See the Postal Dude's monster in all its veiny glory!"
		DecoTextName="AprilTex.dlc_01"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryPigeons"
		Title="Super-Fun Pigeon Hunter Mission ($59.99)"
		Description="We finally scrambled together that $3.50 needed to develop this long-awaited mission!"
		DecoTextName="AprilTex.dlc_02"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryGaryLove"
		Title="Gary Coleman Romance Path ($6.99)"
		Description="Tell your true love what you're really talkin' about in this path of forbidden romance!"
		DecoTextName="AprilTex.dlc_03"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryGoldenShower"
		Title="Golden Weapons Pack ($9.99)"
		Description="Shower your weapons in this golden finish!"
		DecoTextName="AprilTex.dlc_04"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryRegen"
		Title="Regenerating Health ($4.99)"
		Description="This protective coating of strawberry love juice on your screen guarantees those pesky flesh wounds will magically heal themselves! So real!"
		DecoTextName="AprilTex.dlc_05"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryLensFlare"
		Title="Lens Flare Pack ($3.99)"
		Description="Dive into a new era of next-generation graphics."
		DecoTextName="AprilTex.dlc_07"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryElite"
		Title="Elite Gamer Pack ($9.99)"
		Description="Enhance your gaming experience with exclusive perks. Rad!"
		DecoTextName="AprilTex.dlc_06"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryInvin"
		Title="Invincible Pack ($4.99)"
		Description="We've removed the god mode cheats, but pay us and you can have them back!"
		DecoTextName="AprilTex.P2CInvinciblePack"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryParkour"
		Title="Parkour Pack ($7.99)"
		Description="You don't need to play those fancy next-gen games to enjoy the fast-paced thrills of wall-walking!"
		DecoTextName="AprilTex.ParkourPack"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryIncognito"
		Title="Incognito Powerup ($1.99)"
		Description="Go undercover with this clever disguise. Each purchase will give you 5 consumable incognito glasses powerups, which, when used, will clear your wanted meter."
		DecoTextName="AprilTex.dlc_08"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummarySupply"
		Title="RWS Co. Supply Crate ($0.99)"
		Description="Use an RWS Co. Supply Crate key to open this, sucker!"
		DecoTextName="AprilTex.RWSSupplyCrate"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryHolidays"
		Title="Holiday Clothing Pack ($4.99)"
		Description="Add a little holiday spirit to your next psychotic rampage with these festive outfits!"
		DecoTextName="AprilTex.dlc_x0"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryCompanion"
		Title="Mike J Companion ($4.99)"
		Description="Your own personal Mike J to boss around! Make him carry all your stuff and send him on suicide missions. It's fun!"
		DecoTextName="AprilTex.dlc_x1"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryFemDude"
		Title="Female Dude ($4.50)"
		Description="Represent gender equality and smash the patriarchy with this FemDude player character pack!"
		DecoTextName="AprilTex.dlc_09"
	End Object
	Begin Object Class=LevelSummary Name="DLCSummaryChampArmor"
		Title="Champ Armor ($2.50)"
		Description="Paradise is a dangerous place. Protect your dog from danger with this beautiful and resilient armor."
		DecoTextName="AprilTex.dlc_y1"
	End Object
	
	DLCItems[0]=(DLCSummary=LevelSummary'DLCSummaryElite',DLCPrice=9.99)
	DLCItems[1]=(DLCSummary=LevelSummary'DLCSummaryGoldenShower',DLCPrice=9.99)
	DLCItems[2]=(DLCSummary=LevelSummary'DLCSummaryHolidays',DLCPrice=4.99)
	DLCItems[3]=(DLCSummary=LevelSummary'DLCSummaryRegen',DLCPrice=4.99)
	DLCItems[4]=(DLCSummary=LevelSummary'DLCSummarySupply',DLCPrice=0.99)
	DLCItems[5]=(DLCSummary=LevelSummary'DLCSummaryInvin',DLCPrice=4.99)
	DLCItems[6]=(DLCSummary=LevelSummary'DLCSummaryParkour',DLCPrice=7.99)
	DLCItems[7]=(DLCSummary=LevelSummary'DLCSummaryLensFlare',DLCPrice=3.99)
	DLCItems[8]=(DLCSummary=LevelSummary'DLCSummaryCompanion',DLCPrice=4.99)
	DLCItems[9]=(DLCSummary=LevelSummary'DLCSummaryPigeons',DLCPrice=59.99)
	DLCItems[10]=(DLCSummary=LevelSummary'DLCSummaryChampArmor',DLCPrice=2.50)
	DLCItems[11]=(DLCSummary=LevelSummary'DLCSummaryGaryLove',DLCPrice=6.99)
	DLCItems[12]=(DLCSummary=LevelSummary'DLCSummaryWilly',DLCPrice=69.99)
	DLCItems[13]=(DLCSummary=LevelSummary'DLCSummaryIncognito',DLCPrice=1.99)
	DLCItems[14]=(DLCSummary=LevelSummary'DLCSummaryFemDude',DLCPrice=4.50)
}