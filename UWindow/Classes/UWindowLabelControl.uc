class UWindowLabelControl extends UWindowDialogControl;

function Created()
{
	TextX = 0;
	TextY = 0;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	
	// Implemented in a child class

	Super.BeforePaint(C, X, Y);
	
	TextSize(C, Text, W, H);
	//WinHeight = H+1;
	//WinWidth = W+1;
	TextY = (WinHeight - H) / 2;
	switch (Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}	
}

function Paint(Canvas C, float X, float Y)
{
	// RWS CHANGE: 02/10/03 Let the LookAndFeel draw the text
	LookAndFeel.Control_DrawText(self, C);
}
