class UMenuDialogClientWindow extends UWindowDialogClientWindow;

function Notify(UWindowDialogControl C, byte E)
{
	local Color TC;
	Super.Notify(C, E);

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;

	if(E == DE_MouseMove)
	{
		//if(UMenuRootWindow(Root) != None)
		//	if(UMenuRootWindow(Root).StatusBar != None)
		//		UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);

		// Root = UWindowRootWindow
		//if (ShellRootWindow(Root) != None)
		//	ShellRootWindow(Root).SetHelp(C.HelpText);
		
		C.SetTextColor(TC);
	}

	if(E == DE_HelpChanged && C.MouseIsOver())
	{
		//if(UMenuRootWindow(Root) != None)
		//	if(UMenuRootWindow(Root).StatusBar != None)
		//		UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);

		//if (ShellRootWindow(Root) != None)
		//	ShellRootWindow(Root).SetHelp(C.HelpText);
		
		C.SetTextColor(TC);
	}

	if(E == DE_MouseLeave)
	{
		//if(UMenuRootWindow(Root) != None)
		//	if(UMenuRootWindow(Root).StatusBar != None)
		//		UMenuRootWindow(Root).StatusBar.SetHelp("");

		//if (ShellRootWindow(Root) != None)
		//	ShellRootWindow(Root).SetHelp(C.HelpText);
		
		C.SetTextColor(TC);
	}
}
