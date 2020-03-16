class UBrowserGrid extends UWindowGrid;

function MouseLeaveColumn(UWindowGridColumn Column)
{
	Super.MouseLeaveColumn(Column);
	UBrowserPageWindow(GetParent(class'UBrowserPageWindow')).SetHelpText("");
}

function MouseEnterColumn(UWindowGridColumn Column)
{
	Super.MouseEnterColumn(Column);
	UBrowserPageWindow(GetParent(class'UBrowserPageWindow')).SetHelpText(HelpText);
}
