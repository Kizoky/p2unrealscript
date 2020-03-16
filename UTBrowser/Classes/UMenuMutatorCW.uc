class UMenuMutatorCW extends UMenuPageWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var UMenuMutatorExclude Exclude;
var UMenuMutatorInclude Include;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var UWindowCheckbox KeepCheck;
var localized string KeepText;
var localized string KeepHelp;

var UMenuMutatorFrameCW FrameExclude;
var UMenuMutatorFrameCW FrameInclude;

var float ListTitleY;
var float ListHeight;
var float ListWidth;

var string MutatorBaseClass;

var string MoveLeftText;
var string MoveRightText;

// Mutator description
var UWindowDynamicTextArea DescWindow;
var const float DescAreaHeight;
var float DescAreaTop;

const BUTTON_WIDTH  = 30;
const BUTTON_HEIGHT = 20;
const BUTTON_SPACEY = 4;
const BUTTON_SPACEX = 10;

function Created()
{
	Super.Created();
	
	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));

	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, ControlOffset, 270, ControlHeight));
	KeepCheck.SetText(KeepText);
	KeepCheck.SetHelpText(KeepHelp);
	KeepCheck.SetFont(F_SmallBold);
	KeepCheck.bChecked = BotmatchParent.bKeepMutators;
	KeepCheck.Align = TA_LeftOfText;
	ControlOffset += (ControlHeight * 1.5);

	ListTitleY = ControlOffset;
	ControlOffset += 18;

	FrameExclude = UMenuMutatorFrameCW(CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, ListHeight));
	FrameInclude = UMenuMutatorFrameCW(CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, ListHeight));

	Exclude = UMenuMutatorExclude(CreateWindow(class'UMenuMutatorExclude', 0, 0, 100, ListHeight, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMutatorInclude(CreateWindow(class'UMenuMutatorInclude', 0, 0, 100, ListHeight, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	DescWindow = UWindowDynamicTextArea(CreateWindow(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	DescWindow.bAutoScrollbar = true;
	DescWindow.bScrollOnResize = false;
	DescWindow.bTopCentric = true;

	LoadMutators();
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	ControlLeft = (WinWidth - ControlWidth/2)/2;

	UpdateSizes();

	KeepCheck.SetSize(CheckWidth, ControlHeight);
	KeepCheck.WinLeft = ControlLeft;

	DescWindow.SetSize(BodyWidth - 20, DescAreaHeight);
	DescWindow.WinLeft = BodyLeft + 10;
	DescWindow.WinTop = DescAreaTop;
}

function Paint(Canvas C, float X, float Y)
{
	local float W, H, TextY;

	Super.Paint(C, X, Y);

	C.Font = Root.Fonts[F_SmallBold];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	// Draw labels over list boxes
	C.StrLen(ExcludeCaption, W, H);
	ClipText(C, (WinWidth/2 - W)/2, ListTitleY+2, ExcludeCaption, True);
	C.StrLen(IncludeCaption, W, H);
	ClipText(C, WinWidth/2 + (WinWidth/2 - W)/2, ListTitleY+2, IncludeCaption, True);

	// Draw arrows between lists
	TextY = FrameExclude.WinTop + (FrameExclude.WinHeight - (BUTTON_HEIGHT * 2 + BUTTON_SPACEY)) / 2;
	C.StrLen(MoveRightText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveRightText, true);
	TextY += BUTTON_HEIGHT + BUTTON_SPACEY;
	C.StrLen(MoveLeftText, W, H);
	ClipText(C, (WinWidth - W)/2, TextY, MoveLeftText, true);
}

function Resized()
{
	Super.Resized();

	UpdateSizes();
}

function UpdateSizes()
{
	ListHeight = BodyHeight - (ControlOffset - BodyTop) - (DescAreaHeight + 5);
	ListWidth = BodyWidth/2 - (BUTTON_WIDTH + BUTTON_SPACEX)/2;
	FrameExclude.WinTop = ControlOffset;
	FrameExclude.WinLeft = BodyLeft;
	FrameExclude.SetSize(ListWidth, ListHeight);
	FrameInclude.WinTop = ControlOffset;
	FrameInclude.WinLeft = BodyLeft + BodyWidth - ListWidth;
	FrameInclude.SetSize(ListWidth, ListHeight);

	DescAreaTop = FrameExclude.WinTop + FrameExclude.WinHeight + 5;
}

function LoadMutators()
{
	local int NumMutatorClasses;
	local string NextMutator;
	local UMenuMutatorList I;
	local string MutatorList;
	local int j;
	local int k;
	local class<Mutator> MutatorClass;

	NextMutator = GetPlayerOwner().GetNextInt(MutatorBaseClass, 0);
	while( (NextMutator != "") && (NumMutatorClasses < 200) )
	{
		MutatorClass = class<Mutator>(DynamicLoadObject(NextMutator, class'class'));
		if (MutatorClass != None)
		{
			I = UMenuMutatorList(Exclude.Items.Append(class'UMenuMutatorList'));

			I.MutatorClass = NextMutator;
			I.MutatorName = MutatorClass.default.FriendlyName;
			I.MutatorDescription = MutatorClass.default.Description;
//			I.HelpText = MutatorClass.default.Description;

		}
		else
			warn("Bad mutator INT file entry:"@NextMutator);
		NumMutatorClasses++;
		NextMutator = GetPlayerOwner().GetNextInt(MutatorBaseClass, NumMutatorClasses);
	}

	MutatorList = BotmatchParent.MutatorList;

	while(MutatorList != "")
	{
		j = InStr(MutatorList, ",");
		if(j == -1)
		{
			NextMutator = MutatorList;
			MutatorList = "";
		}
		else
		{
			NextMutator = Left(MutatorList, j);
			MutatorList = Mid(MutatorList, j+1);
		}
		
		I = UMenuMutatorList(Exclude.Items).FindMutator(NextMutator);
		if(I != None)
		{
			I.Remove();
			Include.Items.AppendItem(I);
		}
		else
			Log("Unknown mutator in mutator list: "$NextMutator);
	}

	Exclude.Sort();

	// Start with the first item selected (this indirectly sets the current map, too)
	if (Include.Items.Next != None)
		Include.SetSelectedItem(UMenuMutatorList(Include.Items.Next));
	else if (Exclude.Items.Next != None)
		Exclude.SetSelectedItem(UMenuMutatorList(Exclude.Items.Next));
}

function SaveConfigs()
{
	local UMenuMutatorList I;
	local string MutatorList;

	Super.SaveConfigs();
	
	for(I = UMenuMutatorList(Include.Items.Next); I != None; I = UMenuMutatorList(I.Next))
	{
		if(MutatorList == "")
			MutatorList = I.MutatorClass;
		else
			MutatorList = MutatorList $ "," $I.MutatorClass;
	}
	BotmatchParent.MutatorList = MutatorList;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case KeepCheck:
			BotmatchParent.bKeepMutators = KeepCheck.bChecked;
			break;
		case Exclude:
			break;
		case Include:
			SaveConfigs();
			break;
		}
		break;
	case DE_Click:
		switch(C)
		{
		case Exclude:
			SetDescription(UMenuMutatorList(UWindowListBox(C).SelectedItem));
			Include.ClearSelectedItem();
			break;
		case Include:
			SetDescription(UMenuMutatorList(UWindowListBox(C).SelectedItem));
			Exclude.ClearSelectedItem();
			break;
		}
		break;
	}
}

function SetDescription(UMenuMutatorList Item)
{
	DescWindow.Clear();
	DescWindow.AddText(Item.MutatorName$":");
	DescWindow.AddTExt(Item.MutatorDescription);
}

defaultproperties
{
	MoveLeftText="<--"
	MoveRightText="-->"
	DescAreaHeight=120
	PageHeaderText="Mix and match modifiers to customize the game."
	ExcludeCaption="Available Modifiers"
	ExcludeHelp="These modifiers will not be used.  Click and drag modifiers to the right list if you want to use them."
	IncludeCaption="Modifiers For This Game"
	IncludeHelp="These modifiers will be used.  Click and drag modifiers to the left list to remove them.  Drag them up or down to change the order."
	MutatorBaseClass="Engine.Mutator"
	KeepText="Always use these Modifiers"
	KeepHelp="The current list of Modifiers will be used whenever you start a game."
}
