///////////////////////////////////////////////////////////////////////////////
// Achievement Display HUD
///////////////////////////////////////////////////////////////////////////////
class AchievementHUD extends P2HUD;

// Achievement data
var string AchName, AchDesc;
var Texture AchIcon;
var float AchTimeStart;

var localized string UnlockMsg;

const ACH_DURATION = 5.0;
const ACH_X = 0.02;
const ACH_Y1 = 0.83;
const ACH_ICON_SCREEN_SCALE_Y = 0.15;
const SPACING_Y = 0.04;
const SPACING_X = 0.02;

const ACH_SLIDE_TIME = 0.25;		// Time to "slide" in and out

///////////////////////////////////////////////////////////////////////////////
// Achievement Unlocked -- called by achievement mgr
///////////////////////////////////////////////////////////////////////////////
function AchievementUnlocked(String AchievementName, String Description, Texture Icon)
{
	AchTimeStart = Level.TimeSeconds;
	AchName = AchievementName;
	AchDesc = Description;
	AchIcon = Icon;
}

///////////////////////////////////////////////////////////////////////////////
// Draw achievements over everything
///////////////////////////////////////////////////////////////////////////////
simulated event PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	
	DrawAchievements(Canvas);
}

///////////////////////////////////////////////////////////////////////////////
// Draw achievements
///////////////////////////////////////////////////////////////////////////////
function DrawAchievements(Canvas Canvas)
{
	local float PosX, PosY, Scale;
	
	if (AchName != "")
	{
		PosX = UltraWideOffsetX + ACH_X * CanvasWidth;
		// Slide in
		if (Level.TimeSeconds - AchTimeStart < ACH_SLIDE_TIME)
		{
			PosY = CanvasHeight - ((CanvasHeight - (ACH_Y1 * CanvasHeight)) * (Level.TimeSeconds - AchTimeStart) / ACH_SLIDE_TIME);
			//log(PosY@"="@CanvasHeight@"- ("$ACH_Y1@"*"@CanvasHeight$") * ("$Level.TimeSeconds@"-"@AchTimeStart$") / "$ACH_SLIDE_TIME,'Debug');
		}
		// Slide out
		else if (Level.TimeSeconds - AchTimeStart > ACH_DURATION + ACH_SLIDE_TIME)
		{
			PosY = CanvasHeight - ((CanvasHeight - (ACH_Y1 * CanvasHeight)) * ((ACH_DURATION + 2*ACH_SLIDE_TIME) - (Level.TimeSeconds - AchTimeStart)) / ACH_SLIDE_TIME);
		}
		// Disappear
		else if (Level.TimeSeconds - AchTimeStart > ACH_DURATION + 2*ACH_SLIDE_TIME)
		{
			AchName = "";
			return;
		}
		// Normal draw
		else
			PosY = ACH_Y1 * CanvasHeight;
		
		//// Determine draw scale
		Scale = (ACH_ICON_SCREEN_SCALE_Y * CanvasHeight) / AchIcon.USize;		
		
		// Draw background
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = DefaultIconColor;
		Canvas.SetPos(
			PosX,
			PosY);
		Canvas.DrawIcon(AchIcon, Scale);
		
		PosX += (AchIcon.USize * Scale + SPACING_X * CanvasWidth);

		MyFont.TextColor = RedColor;
		MyFont.DrawTextEX(Canvas, CanvasWidth, PosX, PosY, UnlockMsg, 2, false, EJ_Left);
		PosY += SPACING_Y * CanvasHeight;		
		MyFont.TextColor = WhiteColor;
		MyFont.DrawTextEX(Canvas, CanvasWidth, PosX, PosY, AchName, 1, true, EJ_Left);
		PosY += SPACING_Y * CanvasHeight;
		MyFont.DrawTextEX(Canvas, CanvasWidth, PosX, PosY, AchDesc, 1, true, EJ_Left);
		PosY += SPACING_Y * CanvasHeight;
		MyFont.TextColor = RedColor;		
	}
}

defaultproperties
{
	UnlockMsg="Achievement Unlocked!"
}