class DLCMainCW extends UTMenuBotmatchCW;

var UWindowScrollingDialogClient Pane;
var UWindowButton BuyButton;

var UWindowLabelControl MoneyWasted;
var localized string MoneyWastedText;

var array<String> BuySounds;

///////////////////////////////////////////////////////////////////////////////
// Get the single player info.
// 02/10/03 JMI Started to macroify this which we seem to be doing commonly
//				lately. 
///////////////////////////////////////////////////////////////////////////////
function P2GameInfoSingle GetGameSingle()
	{
	return P2GameInfoSingle(Root.GetLevel().Game);
	}

function CreatePages()
{
	/*
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	// DLC Tab
	StartTab = Pages.AddPage(StartMatchTab, class'DLCTabSC');
	*/
	
	Pane = UWindowScrollingDialogClient(CreateWindow(class'DLCTabSC', 0, 0, WinWidth, WinHeight));
}

function Created()
{
	CreatePages();

	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	CloseButton.SetText(BackText);
	BuyButton = UWindowButton(CreateControl(class'UWindowSmallButton', WinWidth-160, WinHeight-72, 96, 64));
	BuyButton.WinHeight=64;
	BuyButton.SetText(StartText);
	BuyButton.bAlwaysOnTop=true;
	
	MoneyWasted = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 10, WinHeight-72, 600, 64));
	UpdateMoneyWasted(0.00);
	MoneyWasted.SetFont(F_LargeBold);

	Super(UWindowDialogClientWindow).Created();

	CloseButton.SetFont(F_SmallBold);
	BuyButton.SetFont(F_LargeBold);
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case BuyButton:
				if (!BuyButton.bDisabled)
					StartPressed();
				return;
			default:
				Super.Notify(C, E);
				return;
		}
	default:
		Super.Notify(C, E);
		return;
	}
}

function GameChanged()
{
	// stub
}

function StartPressed()
{
	// Dude says fuck you
	local Sound PlayMe;
	local int i;
	
	i = rand(BuySounds.Length);
	PlayMe = Sound(DynamicLoadObject(BuySounds[i], class'Sound'));
	GetSoundActor().PlaySound(PlayMe, SLOT_Misc, 1.0,,,,false);
}

function UpdateMoneyWasted(float Moneys)
{
	local string jewgolds;
	local int dot;
	
	if (MoneyWasted == None
		|| BuyButton == None)
		return;
	
	jewgolds = "$"$String(Moneys);
	dot = instr(jewgolds,".");
	if (dot == Len(Jewgolds))
		Jewgolds = Jewgolds $"00";
	else if (dot == Len(Jewgolds) - 1)
		Jewgolds = Jewgolds $"0";
	else if (dot == -1)
		Jewgolds = Jewgolds $".00";
	
	MoneyWasted.SetText(MoneyWastedText@Jewgolds);
	if (Moneys > 0)
		BuyButton.bDisabled = false;
	else
		BuyButton.bDisabled = true;
}

function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

function Resized()
{
	Pane.WinWidth = WinWidth;
	Pane.Winheight = WinHeight - 72;

	CloseButton.WinLeft = WinWidth-56;
	CloseButton.WinTop = WinHeight-24;
	BuyButton.WinLeft = WinWidth-160;
	BuyButton.WinTop = WinHeight-72;
	MoneyWasted.WinLeft = 40;
	MoneyWasted.WinTop = WinHeight-72;
}

defaultproperties
{
	StartMatchTab="DLC Items"
	MutatorTab="Mods"
	StartText="BUY!"
	bNetworkGame=False
	MoneyWastedText="Total Money Wasted:"
	BuySounds[0]="DudeDialog.dude_fuckyou"
	BuySounds[1]="DudeDialog.dude_youvegottabekid"
	BuySounds[2]="DudeDialog.dude_uhuh"
	BuySounds[3]="DudeDialog.dude_nope"
	BuySounds[4]="DudeDialog.dude_idontthinkso"
}
