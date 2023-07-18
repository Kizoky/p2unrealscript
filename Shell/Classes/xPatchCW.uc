class xPatchCW extends UWindowDialogClientWindow;

// Window
//var localized string MainTabText;
//var localized string BloodTabText;
//var localized string WeaponsTabText;
var localized string ClassicTabText;
var localized string ClassicRGTabText;
//var localized string SkinsTabText;
//var localized string InfoTabText;

var localized string ResetText;
var localized string BackText;

var UWindowPageControl Pages;
var UWindowSmallButton ResetButton;
var UWindowSmallButton CloseButton;

var config string LastTab;

function Created()
{
	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 32));
	CloseButton.SetText(BackText);
	ResetButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-230, WinHeight-24, 112, 32));
	ResetButton.SetText(ResetText);

	Super.Created();

	CloseButton.SetFont(F_SmallBold);
	ResetButton.SetFont(F_Smallbold);

	Pages = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	// Credits Tab
	//Pages.AddPage(InfoTabText, class'xPatchPageInfo');
	// Main Tab
	//Pages.AddPage(MainTabText, class'xPatchPageMain');
	// Blood Tab
	//Pages.AddPage(BloodTabText, class'xPatchPageBlood');
	// Weapons Tab
	//Pages.AddPage(WeaponsTabText, class'xPatchPageWeapons');
	// Classic Tab
	Pages.AddPage(ClassicTabText, class'xPatchPageClassic');
	Pages.AddPage(ClassicRGTabText, class'xPatchPageClassicRG'); 
	// Skins Tab
	//Pages.AddPage(SkinsTabText, class'xPatchPageSkins');


	//if (LastTab != "")
	//	Pages.GotoTab(Pages.GetPage(LastTab));
	//else
	//	Pages.GotoTab(Pages.GetPage(ClassicTabText)); //MainTabText
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	//Pages.Winheight = WinHeight;
	Pages.Winheight = WinHeight - 24;
	
	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-21;
	ResetButton.WinLeft = WinWidth-165;
	ResetButton.WinTop = WinHeight-21;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
		case ResetButton:
			ResetSettings();
			break;
		case CloseButton:
			UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
			break;
		}
	}
}

function UWindowPageWindow GetSelectedTab() 
{
	return UWindowPageControlPage(Pages.SelectedTab).Page;
}

function ResetSettings()
{
	if(xPatchPageBase(GetSelectedTab()) != None)
		xPatchPageBase(GetSelectedTab()).SetDefaultValues();
}

function string GetSelectedTabName() 
{
	return UWindowPageControlPage(Pages.SelectedTab).Caption;
}

function Close(optional bool bByParent) 
{
	LastTab = GetSelectedTabName();
	
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

defaultproperties
{
	//MainTabText="General"
	//BloodTabText="Blood"
	//WeaponsTabText="Weapons"
	ClassicTabText="Classic Mode"
	ClassicRGTabText="Updated Game"
	//SkinsTabText="Skins"
	//InfoTabText="Information"
	
	ResetText="Restore Defaults"
	BackText="Back"
}
