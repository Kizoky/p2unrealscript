class UBrowserOpenCW extends UWindowDialogClientWindow;

var UWindowComboControl OpenCombo;
var localized string	OpenText;
var localized string	OpenHelp;

var config string		OpenHistory[10];

var Color TC;

function Created()
{
	local float EditWidth;
	local int i;

	Super.Created();

	EditWidth = WinWidth - 140;
	OpenCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, 20, EditWidth, 25));
	OpenCombo.SetText(OpenText);
	OpenCombo.SetHelpText(OpenHelp);
	OpenCombo.SetFont(F_SmallBold);
	OpenCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (OpenHistory[i] != "")
			OpenCombo.AddItem(OpenHistory[i]);

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;
	OpenCombo.SetTextColor(TC);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float EditWidth;
	local float XL, YL;

	C.Font = Root.Fonts[OpenCombo.Font];
	TextSize(C, OpenCombo.Text, XL, YL);

	EditWidth = WinWidth - 50;

	OpenCombo.WinLeft = (WinWidth - EditWidth) / 2;
	OpenCombo.WinTop = (WinHeight-OpenCombo.WinHeight) / 2;
	OpenCombo.SetSize(EditWidth, OpenCombo.WinHeight);
	OpenCombo.EditBoxWidth = OpenCombo.WinWidth - XL - 20;

	Super.BeforePaint(C, X, Y);

	OpenCombo.SetTextColor(TC);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if(ParentWindow == None || OpenCombo == None)
		return;

	if((C == OpenCombo && E == DE_EnterPressed) ||
	   (C == UBrowserOpenWindow(ParentWindow).OKButton && E == DE_Click))
		OpenURL();
	
	OpenCombo.SetTextColor(TC);
}

function OpenURL()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;
	local string URL;

	URL = OpenCombo.GetValue();
	if(URL == "")
	{
		OpenCombo.BringToFront();
		return;
	}
	
	for (i=0; i<10; i++)
	{
		if (OpenHistory[i] ~= URL)
			HistoryItem = True;
	}
	if (!HistoryItem)
	{
		OpenCombo.InsertItem(URL);
		while(OpenCombo.List.Items.Count() > 10)
			OpenCombo.List.Items.Last.Remove();

		Item = UWindowComboListItem(OpenCombo.List.Items.Next);
		for (i=0; i<10; i++)
		{
			if(Item != None)
			{
				OpenHistory[i] = Item.Value;
				Item = UWindowComboListItem(Item.Next);
			}
			else
				OpenHistory[i] = "";
		}			
	}
	SaveConfig();

	OpenCombo.ClearValue();
	GetParent(class'UWindowFramedWindow').Close();
	UBrowserMainWindow(ParentWindow.OwnerWindow).OpenURL(URL);
}

defaultproperties
{
	OpenText="Server URL"
	OpenHelp="Enter a standard URL, or select one from the URL history."
}