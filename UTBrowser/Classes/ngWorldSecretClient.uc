class ngWorldSecretClient extends UMenuDialogClientWindow;

// Description Labels
var MenuWrappedTextControl ExplainArea;
var localized string ExplainText;
var float ExplainAreaHeight;

// Secret Combo
var UWindowEditControl PassEdit;
var localized string PassText;

var UWindowSmallButton OKButton;
var localized string OKText;

var float ControlHeight;
var float ControlOffset;

var Color ControlColor;

function Created()
{
	local int ControlWidth, ControlPos;

	ControlColor.R = 0;
	ControlColor.G = 0;
	ControlColor.B = 0;
	ControlColor.A = 255;

	ControlHeight = 24;

	ControlWidth = (WinWidth/4)*3;
	ControlPos = (WinWidth - ControlWidth)/2;

	ControlOffset = 20;

	// Description
	ExplainArea = MenuWrappedTextControl(CreateControl(class'MenuWrappedTextControl', ControlPos, ControlOffset, ControlWidth, ExplainAreaHeight));
	ExplainArea.SetFont(F_SmallBold);
	ExplainArea.SetTextColor(ControlColor);
	ExplainArea.SetText(ExplainText);
	ExplainArea.bShadow = false;
	ExplainArea.bCenterVertical = false;
	ControlOffset += ExplainAreaHeight + ControlHeight;

	// Secret
	PassEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlPos, ControlOffset, ControlWidth, ControlHeight));
	PassEdit.SetText(PassText);
	PassEdit.SetFont(F_SmallBold);
	PassEdit.SetNumericOnly(False);
	PassEdit.SetMaxLength(16);
//	PassEdit.AddItem(GetPlayerOwner().GetNGSecret());
	ControlOffset += ControlHeight;

	OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	OKButton.SetText(OKText);
	OKButton.SetFont(F_SmallBold);

	Super.Created();
}

function Resized()
{
	local int ControlWidth, ControlPos;

	ControlWidth = (WinWidth/4)*3;
	ControlPos = (WinWidth - ControlWidth)/2;

	ExplainArea.SetSize(ControlWidth, ExplainAreaHeight);
	ExplainArea.WinLeft = ControlPos;

	PassEdit.SetSize(ControlWidth, ControlHeight);
	PassEdit.WinLeft = ControlPos;
	PassEdit.EditBoxWidth = 110;

	OKButton.WinLeft = WinWidth-52;
	OKButton.WinTop = WinHeight-20;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	if(!ExplainArea.WindowIsVisible())
		ExplainArea.ShowWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();

	DrawUpBevel( C, 0, WinHeight-22, WinWidth, 22, T);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case OKButton:
				OKPressed();
				break;
		}
	}
}

function Close(optional bool bByParent)
{
	// Store the new secret.
//	GetPlayerOwner().SetNGSecret(PassEdit.GetValue());
//	GetPlayerOwner().ngSecretSet = True;
//	GetPlayerOwner().SaveConfig();
	Super.Close(bByParent);
}

function OKPressed()
{
	// Tell owner we got the password
	if (UTBrowserServerGrid(OwnerWindow) != None)
	{
		UTBrowserServerGrid(OwnerWindow).ReallyJoinStatsPass = PassEdit.GetValue();
		UTBrowserServerGrid(OwnerWindow).bGotStatsPass = true;
	}
	// Tell owner we got the password
	if (UTStartGameCW(OwnerWindow) != None)
	{
		UTStartGameCW(OwnerWindow).JoinStatsPass = PassEdit.GetValue();
		UTStartGameCW(OwnerWindow).bGotStatsPass = true;
	}

	Close();
}

defaultproperties
{
	ExplainText="This server is collecting game stats.\\n\\nIf you want to be included in the stats you must enter a password.  This will protect your stats in case someone uses the same name as you.\\n\\nIf you don't want to be included then leave the password blank."
	ExplainAreaHeight=160
	PassText="Stats Password"
	OKText="OK"
}
