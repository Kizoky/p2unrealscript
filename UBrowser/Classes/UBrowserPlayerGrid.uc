//=============================================================================
// UBrowserPlayerGrid
//=============================================================================
class UBrowserPlayerGrid extends UBrowserGrid;

var UWindowGridColumn NameColumn, FragsColumn, PingColumn, TeamColumn, CharacterColumn; //IDColumn;

var localized string NameText;
var localized string FragsText;
var localized string PingText;
var localized string TeamText;
var localized string CharacterText;
//var localized string MeshText;
//var localized string SkinText;
//var localized string FaceText;
//var localized string IDText;
var localized string ngSecretText;
var localized string EnabledText;
var localized string DisabledText;
var localized string BotText;
var int ngSecretWidth;
var UWindowGridColumn ngSecretColumn;

function Created() 
{
	Super.Created();

	RowHeight = 12;

	NameColumn = AddColumn(NameText, 200);
	FragsColumn = AddColumn(FragsText, 50);
	PingColumn = AddColumn(PingText, 50);
	TeamColumn = AddColumn(TeamText, 60);
	CharacterColumn = AddColumn(CharacterText, 130);
	//AddColumn(MeshText, 110);
	//AddColumn(SkinText, 110);
	//AddColumn(FaceText, 70);
	//IDColumn = AddColumn(IDText, 50);
	ngSecretColumn = AddColumn(ngSecretText, 100);
	ngSecretWidth = 100;
}

function Resized()
{
	local float W;
	Super.Resized();

	W = WinWidth - VertSB.WinWidth;
	NameColumn.WinWidth		= W*0.32;
	FragsColumn.WinWidth	= W*0.08;
	PingColumn.WinWidth		= W*0.08;
	TeamColumn.WinWidth		= W*0.24;
	CharacterColumn.WinWidth = W*0.20;
	ngSecretColumn.WinWidth = W*0.08;
//	IDColumn.WinWidth		= W*0.08;
}

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY) 
{
	local UBrowserServerList Server;
	local UBrowserPlayerList PlayerList, l;
	local int Visible;
	local int Count;
	local int Skipped;
	local int Y;
	local int TopMargin;
	local int BottomMargin;

	C.Font = Root.Fonts[F_Small];

	if(bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Server = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;
	if(Server == None)
		return;
	PlayerList = Server.PlayerList;

	if(PlayerList == None)
		return;
	Count = PlayerList.Count();
	if( ngSecretColumn.WinWidth <= 1 )
	{
		ngSecretColumn.ShowWindow();
		ngSecretColumn.WinWidth = ngSecretWidth;
	}
	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);
	
	VertSB.SetRange(0, Count+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	l = UBrowserPlayerList(PlayerList.Next);
	while((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && (l != None))
	{
		if(Skipped >= VertSB.Pos)
		{
			switch(Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerName );
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerFrags );
				break;
			case 2:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerPing);
				break;
			case 3:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerTeam );
				break;
			case 4:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerCharacter );
				break;
/*			case 4:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerMesh );
				break;
			case 5:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerSkin );
				break;
			case 6:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerFace );
				break;
			case 7:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerID );
				break;*/
			case 5:
				if( l.PlayerStats ~= "bot" )
					Column.ClipText( C, 2, Y + TopMargin, BotText );
				else if( l.PlayerStats ~= "true" )
					Column.ClipText( C, 2, Y + TopMargin, EnabledText );
				else
					Column.ClipText( C, 2, Y + TopMargin, DisabledText );
				break;
			}

			Y = Y + RowHeight;			
		} 
		Skipped ++;
		l = UBrowserPlayerList(l.Next);
	}
}

function RightClickRow(int Row, float X, float Y)
{
	local UBrowserInfoMenu Menu;
	local float MenuX, MenuY;
	local UWindowWindow W;

	W = GetParent(class'UBrowserInfoWindow');
	if(W == None)
		return;
	Menu = UBrowserInfoWindow(W).Menu;

	WindowToGlobal(X, Y, MenuX, MenuY);
	Menu.WinLeft = MenuX;
	Menu.WinTop = MenuY;

	Menu.ShowWindow();
}

function SortColumn(UWindowGridColumn Column) 
{
	local UBrowserServerList S;
	
	S = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;
	if(S != None)
		S.PlayerList.SortByColumn(Column.ColumnNum);
}

function SelectRow(int Row) 
{
}

defaultproperties
{
	NameText="Name"
	FragsText="Score"
	PingText="Ping"
	TeamText="Team"
	CharacterText="Character"
//	MeshText="Mesh"
//	SkinText="Skin"
//	FaceText="Face"
//	IDText="ID"
	bNoKeyboard=True
	ngSecretText="Stats"
	EnabledText="Yes"
	DisabledText="No"
	BotText="Moron"
	DefaultHelpText="Shows current players on the selected server."
}