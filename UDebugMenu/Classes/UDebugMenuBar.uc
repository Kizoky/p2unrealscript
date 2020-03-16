class UDebugMenuBar extends UWindowMenuBar;

var UWindowPulldownMenu Game, RModes, Rend, KDraw, Stats, Show, Player, Options;
var UWindowMenuBarItem GameItem, RModesItem, RendItem, KDrawItem, StatsItem, ShowItem, PlayerItem, OptionsItem;
var bool bShowMenu;

function Created()
{
	Super.Created();
	
	GameItem = AddItem("&Game");
	Game = GameItem.CreateMenu(class 'UWindowPulldownMenu');
	Game.MyMenuBar = self;
// RWS CHANGE: Eliminate choices we don't want
//	Game.AddMenuItem("&Load New Map",none);
//	Game.AddMenuItem("-",none);
//	Game.AddMenuItem("&Connect to..",none);
//	Game.AddMenuItem("-",none);
	Game.AddMenuItem("ScreenShot",none);
	Game.AddMenuItem("Flush",none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem("E&xit",none);

	RModesItem = AddItem("&Render Modes");
	RModes = RModesItem.CreateMenu(class 'UWindowPulldownMenu');
	RModes.MyMenuBar = self;
	RModes.AddMenuItem("&Wireframe",none);
	RModes.AddMenuItem("&Zones",none);
	RModes.AddMenuItem("&Flat Shaded BSP",none);
	RModes.AddMenuItem("&BSP Splits",none);
	RModes.AddMenuItem("&Regular",none);
	RModes.AddMenuItem("&Unlit",none);
	RModes.AddMenuItem("&Lighting Only",none);
	RModes.AddMenuItem("&Depth Complexity",none);
	RModes.AddMenuItem("-",None);
	RModes.AddMenuItem("&Top Down",None);
	RModes.AddMenuItem("&Front",None);
	RModes.AddMenuItem("&Side",None);

	RendItem = AddItem("Render &Commands");
	Rend = RendItem.CreateMenu(class 'UWindowPulldownMenu');
	Rend.MyMenuBar = self;
	Rend.AddMenuItem("&Blend",none);
	Rend.AddMenuItem("&Bone",none);
	Rend.AddMenuItem("&Skin",none);

	StatsItem = AddItem("&Stats");
	Stats = StatsItem.CreateMenu(class 'UWindowPulldownMenu');
	Stats.MyMenuBar = self;
	Stats.AddMenuItem("&All",None);
	Stats.AddMenuItem("&None",None);
	Stats.AddMenuItem("-",None);
	Stats.AddMenuItem("&Render",None);
	Stats.AddMenuItem("&Game",None);
	Stats.AddMenuItem("&Hardware",None);
	Stats.AddMenuItem("Ne&t",None);
	Stats.AddMenuItem("Ani&m",None);

	ShowItem = AddItem("Sho&w Commands");
	Show = ShowItem.CreateMenu(class 'UWindowPulldownMenu');
	Show.MyMenuBar = self;
	Show.AddMenuItem("Show &Actors",None);
	Show.AddMenuItem("Show Static &Meshes",None);
	Show.AddMenuItem("Show &Terrain",None);
	Show.AddMenuItem("Show &Fog",None);
	Show.AddMenuItem("Show &Sky",None);
	Show.AddMenuItem("Show &Coronas",None);
	Show.AddMenuItem("Show &Particles",None);
			
// RWS CHANGE: Eliminate options we don't want
//	OptionsItem = AddItem("&Options");
//	Options = OptionsItem.CreateMenu(class 'UWindowPulldownMenu');
//	Options.MyMenuBar = self;
//	Options.AddMenuItem("&Video",None);
//	Options.AddMenuItem("&Audio",None);
//	Options.AddMenuItem("&Keys",None);

	KDrawItem = AddItem("&Karma Physics");
	KDraw = KDrawItem.CreateMenu(class 'UWindowPulldownMenu');
	KDraw.MyMenuBar = self;
	KDraw.AddMenuItem("&Collision",none);
	KDraw.AddMenuItem("C&ontacts",none);
	KDraw.AddMenuItem("&Triangles",none);
	KDraw.AddMenuItem("Co&m",none);
	KDraw.AddMenuItem("-",none);
	KDraw.AddMenuItem("KStop",none);
	KDraw.AddMenuItem("KStep",none);

	bShowMenu = true;
	Spacing = 12;
	
}

function SetHelp(string NewHelpText)
{
}

function ShowHelpItem(UWindowMenuBarItem I)
{
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if(UWindowMenuBarItem(Item).bHelp)
		W = W - 16;
	Super.DrawItem(C, Item, X, Y, W, H);
}

function DrawMenuBar(Canvas C)
{
	local float W, H;
	local string VersionText;

	Super.DrawMenuBar(C);
	
	C.Font = Root.Fonts[F_Normal];
	C.SetDrawColor(0,0,0);
	VersionText = "[Debug Menu] Version "@GetLevel().EngineVersion;
	TextSize(C, VersionText, W, H);
	ClipText(C, WinWidth - W - 20, 3, VersionText);
}

/* RWS CHANGE: Disable clicking in upper right to toggle full screen
function LMouseDown(float X, float Y)
{
	if(X > WinWidth - 13)
		GetPlayerOwner().ConsoleCommand("togglefullscreen");
	Super.LMouseDown(X, Y);
}*/

function NotifyQuitUnreal()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyAfterLevelChange();
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg) 
	{
		case WM_KeyDown:
		
		
			if (Key==27) // GRR
			{
				if (Selected == None)
				{
					Root.GotoState('');
				}

				return;
			}
			break;
	}
	Super.WindowEvent(Msg, C, X, Y, Key);
	
}
	
function MenuItemSelected(UWindowBase Sender, UWindowBase Item)
{
	local UWindowPulldownMenu Menu;
	local UWindowPulldownMenuItem I;
	
	Menu = UWindowPulldownMenu(Sender);
	I = UWindowPulldownMenuItem(Item);

	if (Menu!=None)
	{
		switch (Menu)
		{
			case Game:
				switch (I.Tag)
				{
// RWS CHANGE: Eliminate options we don't want
//					case 1 :
//						// Open the Map Menu
//						Root.ShowModal(Root.CreateWindow(class'UDebugMapListWindow', (Root.WinWidth/2)-200, (Root.WinHeight/2)-107, 400, 214, self));
//						return;						
//						break;
//					
//					case 3 :
//						// Open the Map Menu
//						Root.ShowModal(Root.CreateWindow(class'UDebugOpenWindow', (Root.WinWidth/2)-150,(Root.WinHeight/2)-45, 300,90, self));
//						return;						
//						break;
										
					case 5 : Root.ConsoleCommand("Shot"); break;
					case 6 : Root.ConsoleCommand("Flush"); break;
					case 8 : Root.ConsoleCommand("Quit"); break;
				}
				break;
			case RModes:
				if (I.Tag < 9)
					Root.ConsoleCommand("RMode "$I.Tag);
				else if (I.Tag >9)
					Root.ConsoleCommand("RMode "$I.Tag+3);
					
				break;
				
			case Rend:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("rend blend"); break;    
					case 2 : Root.ConsoleCommand("rend bone"); break;    
					case 3 : Root.ConsoleCommand("rend skin"); break;
				}
				break;
			
			case Stats:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("stat All");break;     
					case 2 : Root.ConsoleCommand("stat NONE");break;     
					case 4 : Root.ConsoleCommand("stat RENDER");break;     
					case 5 : Root.ConsoleCommand("stat GAME");break;     
					case 6 : Root.ConsoleCommand("stat HARDWARE");break;     
					case 7 : Root.ConsoleCommand("stat NET");break;     
					case 8 : Root.ConsoleCommand("stat ANIM");break;
				}
				break;
				
			case Show:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand("show Actors"); break;  
					case 2 : Root.ConsoleCommand("show StaticMeshes"); break;  
					case 3 : Root.ConsoleCommand("show Terrain"); break;  
					case 4 : Root.ConsoleCommand("show Fog"); break;  
					case 5 : Root.ConsoleCommand("show Sky"); break;  
					case 6 : Root.ConsoleCommand("show Coronas"); break;  
					case 7 : Root.ConsoleCommand("show Particles"); break;  
				}
				break;
			
// RWS CHANGE: Eliminate options we don't want
//			case Options:
//				switch (I.tag)
//				{
//					case 1 : // Video Menu
//								
//						Root.ShowModal(Root.CreateWindow(class'UDebugVideoWindow', Options.WinLeft, 20, 220, 100, self));
//						return;						
//						break;
//
//					case 2 : break; // Audio Menu
//					case 3 : break; // Input Menu
//				}
//				break;
				
			case KDraw:
				switch (I.tag)
				{
					case 1 : Root.ConsoleCommand("kdraw Collision"); break; 
					case 2 : Root.ConsoleCommand("kdraw Contacts"); break; 
					case 3 : Root.ConsoleCommand("kdraw Triangles"); break; 
					case 4 : Root.ConsoleCommand("kdraw Com"); break; 
					case 6 : Root.ConsoleCommand("kdraw KStop"); break; 
					case 7 : Root.ConsoleCommand("kdraw KStep"); break;
				}
				break; 
		}
	}
	Root.GotoState('');
 
}

defaultproperties
{
}

