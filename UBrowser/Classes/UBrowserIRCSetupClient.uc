class UBrowserIRCSetupClient extends UWindowDialogClientWindow;

var UWindowComboControl ServerCombo;
var UWindowComboControl ChannelCombo;
var UWindowSmallButton ConnectButton;

var config string		IRCServerHistory[10];
var config string		IRCChannelHistory[10];
var config bool			bHasReadWarning;

var localized string	ServerText;
var localized string	ChannelText;
var localized string	ServerHelp;
var localized string	ChannelHelp;

var localized string	ConnectText;
var localized string	DisconnectText;
var localized string	ConnectHelp;
var localized string	DisconnectHelp;

var localized string	WarningText;
var localized string	WarningTitle;

var UWindowMessageBox ConfirmJoin;
var UBrowserIRCSystemPage SystemPage;

var UWindowSmallButton	RemoveServer;
var UWindowSmallButton	RemoveChannel;

var localized string	RemoveServerText;
var localized string	RemoveChannelText;
var localized string	RemoveServerHelp;
var localized string	RemoveChannelHelp;

var UWindowSmallButton	JoinChannel;
var localized string	JoinChannelText;
var localized string	JoinChannelHelp;

var bool bConnected;

var Color TC;

function Created()
{
	local int i;

	bConnected = false;

	Super.Created();

	SystemPage = UBrowserIRCSystemPage(OwnerWindow);

	ServerCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10, 1, 280, 25));
	ServerCombo.EditBoxWidth = 160;
	ServerCombo.SetText(ServerText);
	ServerCombo.SetHelpText(ServerHelp);
	ServerCombo.SetFont(F_SmallBold);
	ServerCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (IRCServerHistory[i] != "")
			ServerCombo.AddItem(IRCServerHistory[i]);

	RemoveServer = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 310, 6, 80, 20));
	RemoveServer.WinHeight = 20;
	RemoveServer.SetText(RemoveServerText);
	RemoveServer.SetHelpText(RemoveServerHelp);
	RemoveServer.SetFont(F_SmallBold);

	TC.R = 230;
	TC.G = 230;
	TC.B = 230;
	TC.A = 255;
	ServerCombo.SetTextColor(TC);
	ServerCombo.SetSelectedIndex(0);

	ChannelCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10, 25, 280, 25));
	ChannelCombo.EditBoxWidth = 160;
	ChannelCombo.SetText(ChannelText);
	ChannelCombo.SetHelpText(ChannelHelp);
	ChannelCombo.SetFont(F_SmallBold);
	ChannelCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (IRCChannelHistory[i] != "")
			ChannelCombo.AddItem(IRCChannelHistory[i]);
	ChannelCombo.SetSelectedIndex(0);
	ChannelCombo.SetTextColor(TC);

	RemoveChannel = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 310, 29, 80, 20));
	RemoveChannel.WinHeight = 20;
	RemoveChannel.SetText(RemoveChannelText);
	RemoveChannel.SetHelpText(RemoveChannelHelp);
	RemoveChannel.SetFont(F_SmallBold);

	ConnectButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 465, 6, 80, 20));
	ConnectButton.bIgnoreLDoubleclick = True;
	ConnectButton.WinHeight = 20;
	ConnectButton.SetFont(F_SmallBold);
	ConnectButton.SetText(ConnectText);
	ConnectButton.SetHelpText(ConnectHelp);

	JoinChannel = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 465, 29, 80, 20));
	JoinChannel.SetText(JoinChannelText);
	JoinChannel.SetHelpText(JoinChannelHelp);
	JoinChannel.bIgnoreLDoubleClick = True;
	JoinChannel.WinHeight = 20;
	JoinChannel.SetFont(F_SmallBold);
	JoinChannel.HideWindow();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	if(bConnected != SystemPage.bConnected)
	{
		bConnected = SystemPage.bConnected;
		if(SystemPage.bConnected)
		{
			ConnectButton.SetText(DisconnectText);
			ConnectButton.SetHelpText(DisconnectHelp);
			JoinChannel.ShowWindow();
		}
		else
		{
			ConnectButton.SetText(ConnectText);
			ConnectButton.SetHelpText(ConnectHelp);
			JoinChannel.HideWindow();
		}
	}

	ServerCombo.SetTextColor(TC);
	ChannelCombo.SetTextColor(TC);

	ConnectButton.AutoWidth(C);
	JoinChannel.AutoWidth(C);

	RemoveServer.AutoWidth(C);
	RemoveChannel.AutoWidth(C);
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
//	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

function DoJoin()
{
	SystemPage.Server = ServerCombo.GetValue();
	SystemPage.DefaultChannel = ChannelCombo.GetValue();
	SystemPage.Connect();

	SaveServerCombo();
	SaveChannelCombo();
	SaveConfig();
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmJoin && Result == MR_Yes)
	{
		bHasReadWarning = True;		
		DoJoin();
	}
}

function JoinIRCServer()
{
	if(bHasReadWarning)
		DoJoin();
	else
		ConfirmJoin = MessageBox(WarningTitle, WarningText, MB_YesNo, MR_No);
}

function JoinIRCChannel()
{
	SystemPage.JoinChannel(ChannelCombo.GetValue());
	SaveChannelCombo();
	SaveConfig();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
		case DE_Click:
			switch(C)
			{
				case ConnectButton:
					if(SystemPage.bConnected)
						SystemPage.Disconnect();
					else
						JoinIRCServer();
					break;

				case JoinChannel:
					JoinIRCChannel();
					break;
					
				case RemoveServer:
					ServerCombo.RemoveItem(ServerCombo.GetSelectedIndex());
					ServerCombo.SetSelectedIndex(0);
					break;

				case RemoveChannel:
					ChannelCombo.RemoveItem(ChannelCombo.GetSelectedIndex());
					ChannelCombo.SetSelectedIndex(0);
					break;
			}
			break;
		case DE_EnterPressed:
			switch(C)
			{
				case ServerCombo:
					JoinIRCServer();
					break;

				case ChannelCombo:
					JoinIRCChannel();
					break;
			}
			break;
	}
}

function NewIRCServer(string S)
{
	if(ServerCombo.List.Items.Count() == 1 && ServerCombo.GetValue() != S)
	{
		Log("Received new IRC server from UpdateServer: "$S);
		ServerCombo.Clear();
		ServerCombo.AddItem(S);
		ServerCombo.SetSelectedIndex(0);
		SaveServerCombo();
		SaveConfig();
	}
}

function SaveServerCombo()
{
	local UWindowComboListItem Item;
	local int i;

	ServerCombo.RemoveItem(ServerCombo.FindItemIndex(ServerCombo.GetValue()));
	ServerCombo.InsertItem(ServerCombo.GetValue());
	while(ServerCombo.List.Items.Count() > 10)
		ServerCombo.List.Items.Last.Remove();

	Item = UWindowComboListItem(ServerCombo.List.Items.Next);
	for (i=0; i<10; i++)
	{
		if(Item != None)
		{
			IRCServerHistory[i] = Item.Value;
			Item = UWindowComboListItem(Item.Next);
		}
		else
			IRCServerHistory[i] = "";
	}			
}

function SaveChannelCombo()
{
	local UWindowComboListItem Item;
	local int i;

	ChannelCombo.RemoveItem(ChannelCombo.FindItemIndex(ChannelCombo.GetValue()));
	ChannelCombo.InsertItem(ChannelCombo.GetValue());
	while(ChannelCombo.List.Items.Count() > 10)
		ChannelCombo.List.Items.Last.Remove();

	Item = UWindowComboListItem(ChannelCombo.List.Items.Next);
	for (i=0; i<10; i++)
	{
		if(Item != None)
		{
			IRCChannelHistory[i] = Item.Value;
			Item = UWindowComboListItem(Item.Next);
		}
		else
			IRCChannelHistory[i] = "";
	}			
}

// 1409 version updatted the IRCServerHistory to default from irc.gamesnet.net, to irc.gamesurge.net
// because surge bought out the net one. 
defaultproperties
{
	ServerText="IRC Server"
	ServerHelp="Choose an IRC server from the list or type in your own IRC server name or IP address."
	ChannelText="Chat Channel"
	ChannelHelp="Choose a default channel to join once the server has connected, or type in your own channel name."
	JoinChannelText="Join Channel"
	JoinChannelHelp="Connect to this channel on the current IRC server."
	RemoveServerText="Remove Server"
	RemoveChannelText="Remove Channel"
	RemoveServerHelp="Delete current server From IRC Server list."
	RemoveChannelHelp="Delete current channel from IRC channel list."
	IRCServerHistory(0)="irc.gamesurge.net"
	IRCChannelHistory(0)="#postal2"
	ConnectText="Connect"
	DisconnectText="Logoff"
	ConnectHelp="Connect to the IRC chat server."
	DisconnectHelp="Disconnect from the IRC chat server."
	WarningTitle="Warning"
	WarningText="The chat facility will connect you to the Internet Relay Chat (IRC) network.\\n\\nRunning With Scissors is not responsible for the content of any channels in IRC. You enter these channels at your own risk.\\n\\nAre you sure you still want to connect?"
}
