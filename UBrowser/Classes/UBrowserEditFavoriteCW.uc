class UBrowserEditFavoriteCW extends UWindowDialogClientWindow;

var UWindowEditControl	DescriptionEdit;
var localized string	DescriptionText;

var UWindowCheckbox		UpdateDescriptionCheck;
var localized string	UpdateDescriptionText;

var UWindowEditControl	IPEdit;
var localized string	IPText;

var UWindowEditControl	GamePortEdit;
var localized string	GamePortText;

var UWindowEditControl	QueryPortEdit;
var localized string	QueryPortText;

function Created()
{
	local float ControlOffset, CenterPos, CenterWidth;
	local int ItemHeight;

	Super.Created();

	ItemHeight = 20;
	
	DescriptionEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, 10, 240, ItemHeight));
	DescriptionEdit.SetText(DescriptionText);
	DescriptionEdit.SetFont(F_SmallBold);
	DescriptionEdit.SetNumericOnly(False);
	DescriptionEdit.SetMaxLength(300);
	DescriptionEdit.EditBoxWidth = 100;

	UpdateDescriptionCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, 30, 360, ItemHeight));
	UpdateDescriptionCheck.SetText(UpdateDescriptionText);
	UpdateDescriptionCheck.SetFont(F_SmallBold);

	IPEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, 50, 295, ItemHeight));
	IPEdit.SetText(IPText);
	IPEdit.SetFont(F_SmallBold);
	IPEdit.SetNumericOnly(False);
	IPEdit.SetMaxLength(40);
	IPEdit.EditBoxWidth = 140;
	
	GamePortEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, 70, 200, ItemHeight));
	GamePortEdit.SetText(GamePortText);
	GamePortEdit.SetFont(F_SmallBold);
	GamePortEdit.SetNumericOnly(True);
	GamePortEdit.SetMaxLength(5);
	GamePortEdit.EditBoxWidth = 45;

	QueryPortEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, 90, 200, ItemHeight));
	QueryPortEdit.SetText(QueryPortText);
	QueryPortEdit.SetFont(F_SmallBold);
	QueryPortEdit.SetNumericOnly(True);
	QueryPortEdit.SetMaxLength(5);
	QueryPortEdit.EditBoxWidth = 45;

	DescriptionEdit.BringToFront();
	LoadCurrentValues();
}

function LoadCurrentValues()
{
	local UBrowserServerList L;

	L = UBrowserRightClickMenu(ParentWindow.OwnerWindow).List;

	DescriptionEdit.SetValue(L.HostName);
	UpdateDescriptionCheck.bChecked = !L.bKeepDescription;
	IPEdit.SetValue(L.IP);
	GamePortEdit.SetValue(string(L.GamePort));
	QueryPortEdit.SetValue(string(L.QueryPort));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local Color TC;

	Super.BeforePaint(C, X, Y);

	DescriptionEdit.WinWidth = WinWidth - 20;
	DescriptionEdit.EditBoxWidth = WinWidth - 140;

	// Keep all the text black
	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;
	DescriptionEdit.SetTextColor(TC);
	IPEdit.SetTextColor(TC);
	GamePortEdit.SetTextColor(TC);
	QueryPortEdit.SetTextColor(TC);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if((C == UBrowserEditFavoriteWindow(ParentWindow).OKButton && E == DE_Click))
		OKPressed();
}

function OKPressed()
{
	local UBrowserServerList L;

	L = UBrowserRightClickMenu(ParentWindow.OwnerWindow).List;

	L.HostName = DescriptionEdit.GetValue();
	L.bKeepDescription = !UpdateDescriptionCheck.bChecked;
	L.IP = IPEdit.GetValue();
	L.GamePort = Int(GamePortEdit.GetValue());
	L.QueryPort = Int(QueryPortEdit.GetValue());
	
	UBrowserFavoritesFact(UBrowserFavoriteServers(UBrowserRightClickMenu(ParentWindow.OwnerWindow).Grid.GetParent(class'UBrowserFavoriteServers')).Factories[0]).SaveFavorites();
	L.PingServer(False, True, True);

	ParentWindow.Close();
}

defaultproperties
{
	DescriptionText="Description"
	UpdateDescriptionText="Auto-Update Description"
	IPText="Server IP Address"
	GamePortText="Server Port Number"
	QueryPortText="Query Port Number"
}