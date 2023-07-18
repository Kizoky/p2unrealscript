class WorkshopGameModsPage extends WorkshopMutatorCW;

var UMenuMutatorListBox OnMouseList;

const ModListPath = "Shell.WorkshopStartGameCW MutatorList";
const KeepModPath = "Shell.WorkshopStartGameCW bKeepMutators";

function Created()
{
	Super(UMenuPageWindow).Created();

	DynamicLoadObject("Shell.WorkshopStartGameCW", class'class');
	
	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, ControlOffset, 270, ControlHeight));
	KeepCheck.SetText(KeepText);
	KeepCheck.SetHelpText(KeepHelp);
	KeepCheck.SetFont(F_SmallBold);
	KeepCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get"@KeepModPath));
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

	MutatorList = GetPlayerOwner().ConsoleCommand("get"@ModListPath);

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

	Super(UMenuPageWindow).SaveConfigs();
	
	for(I = UMenuMutatorList(Include.Items.Next); I != None; I = UMenuMutatorList(I.Next))
	{
		if(MutatorList == "")
			MutatorList = I.MutatorClass;
		else
			MutatorList = MutatorList $ "," $I.MutatorClass;
	}
	GetPlayerOwner().ConsoleCommand("set"@ModListPath@MutatorList);
	GetPlayerOwner().UpdateURL("Mutator", MutatorList,false);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super(UMenuPageWindow).Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case KeepCheck:
			GetPlayerOwner().ConsoleCommand("set"@KeepModPath@KeepCheck.bChecked);
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
	case DE_MouseEnter:
		OnMouseList = UMenuMutatorListBox(C);
		break;
	case DE_MouseLeave:
		OnMouseList = None;
		break;
	}
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	if (Msg==WM_KeyDown)
	{
		if (Key==236 && OnMouseList != None)
			OnMouseList.VertSB.Scroll(-1);
		else if (Key==237 && OnMouseList != None)
			OnMouseList.VertSB.Scroll(1);
			
		return;
	}

	Super.WindowEvent(MSg,C,X,Y,Key);
}

defaultproperties
{
}
