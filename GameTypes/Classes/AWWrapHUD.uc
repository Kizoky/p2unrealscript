///////////////////////////////////////////////////////////////////////////////
// AW Wrap Postal 2 HUD
///////////////////////////////////////////////////////////////////////////////
class AWWrapHUD extends AchievementHUD;


///////////////////////////////////////////////////////////////////////////////
// Vars, structs, consts, enums...
///////////////////////////////////////////////////////////////////////////////
var Texture GaryHeadTex;


const HUD_GARY_NUMBERS_OFFSET_X	= +0.040;
const HUD_GARY_NUMBERS_OFFSET_Y	= -0.020;
const HUD_GARY_ICON_OFFSET_X	= +0.045;
const HUD_GARY_ICON_OFFSET_Y	= -0.060;
const HUD_GARY_ICON_SCALE		= 0.6;

///////////////////////////////////////////////////////////////////////////////
// Draw health section or heads
///////////////////////////////////////////////////////////////////////////////
simulated function DrawHealthAndArmor(canvas Canvas, float Scale)
{
	local Texture usetex;
	local int UseHeads;

	Super.DrawHealthAndArmor(Canvas, Scale);

	if(AWDude(PawnOwner) != None && AWDude(PawnOwner).GaryHeads > 0)
	{
		UseHeads = AWDude(PawnOwner).GaryHeads;

		// Draw icon
		Canvas.Style = ERenderStyle.STY_Masked;
		Canvas.DrawColor = DefaultIconColor;
		Canvas.SetPos(
			(IconPos[HealthIndex].X + HUD_GARY_ICON_OFFSET_X) * CanvasWidth,
			(IconPos[HealthIndex].Y + HUD_GARY_ICON_OFFSET_Y) * CanvasHeight);

		Canvas.DrawIcon(GaryHeadTex, Scale * HUD_GARY_ICON_SCALE);

		// Draw numbers
		MyFont.DrawTextEx(Canvas, CanvasWidth, 
			(IconPos[HealthIndex].X + HUD_GARY_NUMBERS_OFFSET_X) * CanvasWidth,
			(IconPos[HealthIndex].Y + HUD_GARY_NUMBERS_OFFSET_Y) * CanvasHeight,
			""$UseHeads, 1);
	}
}

///////////////////////////////////////////////////////////////////////////////
// Added by Man Chrzan: xPatch 2.0
// Draw left middle finger for petition 
///////////////////////////////////////////////////////////////////////////////
simulated event PostRender( canvas Canvas )
{
	// If there's an active screen, check to see if it wants the hud
	// If there's a root window running then never show the hud
	if ((OurPlayer.CurrentScreen == None || OurPlayer.CurrentScreen.ShouldDrawHUD()) && !AreAnyRootWindowsRunning())
	{
		if ( !PlayerOwner.bBehindView )
		{
			// Draw left middle finger	
			if ( (AWPostalDude(PawnOwner) != None) && (AWPostalDude(PawnOwner).LeftHandBird != None) )
				AWPostalDude(PawnOwner).LeftHandBird.RenderOverlays(Canvas);	
		}
	}

	// Super needs to be called after LeftHandBird so it (left hand) won't cover subtitles.
	Super.PostRender(Canvas);
}


///////////////////////////////////////////////////////////////////////////////
// Default properties
///////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     GaryHeadTex=Texture'AW_Textures.Gary_Icon'
     startinjuries(0)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_gravel',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=1.000000,MoveSpeed=0.400000,Red=255.000000,Green=100.000000,Blue=128.000000,Alpha=80.000000,redchange=2.000000,greenchange=-2.000000,bluechange=5.000000,alphachange=-18.000000,redmax=255.000000,greenmax=100.000000,bluemax=128.000000,AlphaMax=128.000000,redmin=200.000000,greenmin=60.000000,bluemin=50.000000,alphamin=1.000000)
     startinjuries(1)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_wash2_opaque',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=1.500000,MoveSpeed=-0.200000,Red=40.000000,Green=20.000000,Blue=200.000000,Alpha=80.000000,greenchange=3.000000,bluechange=-4.000000,alphachange=-18.000000,redmax=100.000000,greenmax=120.000000,bluemax=255.000000,AlphaMax=128.000000,redmin=100.000000,greenmin=40.000000,bluemin=200.000000,alphamin=1.000000)
     startinjuries(2)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-80.000000,AlphaMax=255.000000,alphamin=1.000000)
     walkinjuries(0)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_gravel',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.500000,MoveSpeed=0.200000,Red=255.000000,Alpha=1.000000,redchange=2.000000,bluechange=1.000000,alphachange=4.000000,redmax=255.000000,bluemax=80.000000,AlphaMax=30.000000,redmin=200.000000,bluemin=1.000000,alphamin=10.000000)
     walkinjuries(1)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_wash2_opaque',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.800000,MoveSpeed=-0.100000,Red=100.000000,Green=100.000000,Blue=200.000000,Alpha=1.000000,greenchange=1.000000,bluechange=-4.000000,alphachange=7.000000,redmax=100.000000,greenmax=255.000000,bluemax=255.000000,AlphaMax=30.000000,redmin=100.000000,greenmin=20.000000,bluemin=200.000000,alphamin=10.000000)
     stopinjuries(0)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-80.000000,AlphaMax=255.000000,alphamin=1.000000)
     stopinjuries(1)=(Tex=Texture'Zo_Smeg.Ground_Alphas.zo_grnd_alpha2',Scale=1.000000,MoveTimeDilation=1.000000,Red=255.000000,Green=255.000000,Blue=255.000000,Alpha=255.000000,alphachange=-80.000000,AlphaMax=255.000000,alphamin=1.000000)
     garyeffects(0)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_gravel',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.600000,MoveSpeed=0.300000,Green=180.000000,Alpha=1.000000,greenchange=2.000000,bluechange=1.000000,alphachange=3.000000,greenmax=180.000000,bluemax=80.000000,AlphaMax=50.000000,greenmin=100.000000,bluemin=1.000000,alphamin=20.000000)
     garyeffects(1)=(Tex=Texture'Zo_Smeg.Special_Brushes.zo_wash2_opaque',xoff=-0.500000,yoff=-0.500000,Scale=2.000000,MoveTimeDilation=0.700000,MoveSpeed=-0.150000,Red=50.000000,Green=100.000000,Blue=200.000000,Alpha=1.000000,greenchange=1.000000,bluechange=-4.000000,alphachange=7.000000,redmax=100.000000,greenmax=100.000000,bluemax=255.000000,AlphaMax=50.000000,redmin=50.000000,greenmin=20.000000,bluemin=200.000000,alphamin=20.000000)
     SectionBackground(0)=Texture'nathans.Inventory.bloodsplat-1'
     SectionBackground(1)=Texture'nathans.Inventory.bloodsplat-2'
     SectionBackground(2)=Texture'nathans.Inventory.bloodsplat-3'
     IconPos(0)=(X=0.935000,Y=0.120000)
     IconPos(1)=(X=0.935000,Y=0.270000)
     IconPos(2)=(X=0.935000,Y=0.420000)
     IconPos(3)=(X=0.935000,Y=0.570000)
     InvTextPos(0)=(X=-0.055000,Y=-0.035000)
     InvTextPos(1)=(X=-0.055000,Y=-0.010000)
     InvTextPos(2)=(X=-0.055000,Y=0.015000)
     WeapTextPos(0)=(X=-0.055000,Y=0.015000)
     WeapTextPos(1)=(X=-0.055000,Y=0.040000)
     WeapTextPos(2)=(X=-0.055000,Y=0.065000)
     WantedTextPos(0)=(X=-0.055000,Y=-0.030000)
     WantedTextPos(1)=(X=-0.055000)
}
