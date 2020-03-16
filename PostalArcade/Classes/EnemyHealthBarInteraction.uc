class EnemyHealthBarInteraction extends Interaction;

var int BackgroundSize;
var float BackgroundScale;
var float BackgroundPositionRatioX;
var float BackgroundPositionRatioY;
var Texture BackgroundTexture;

var int HeadSize;
var float HeadScale;
var float HeadPositionRatioX;
var float HeadPositionRatioY;
var Texture HeadTexture;

var int BarSize;
var float BarScale;
var float BarPositionRatioX;
var float BarPositionRatioY;
var float BarBackgroundPositionRatioX;
var float BarBackgroundPositionRatioY;
var float BarDrawLengthX;
var float BarDrawLengthY;
var float BarBackgroundDrawLengthX;
var float BarBackgroundDrawLengthY;
var Texture BarTexture;

var P2Pawn Enemy;
var PlayerController Player;
var Canvas PlayerCanvas;

// Converts the ratio into a screen position number to support different
// screen resolutions on different computers.
simulated function float GetXDrawPosition(float Ratio, float TextureScale, int TextureSize)
{
    return PlayerCanvas.ClipX/2 + (PlayerCanvas.ClipX/2) * Ratio - (TextureSize/2 * GetScale() * TextureScale);
}

simulated function float GetYDrawPosition(float Ratio, float TextureScale, int TextureSize)
{
    return PlayerCanvas.ClipY/2 + (PlayerCanvas.ClipY/2) * Ratio - (TextureSize/2 * GetScale() * TextureScale);
}

simulated function float GetXDrawLengthRatio()
{
    return Enemy.Health / Enemy.HealthMax;
}

simulated function float GetScale()
{
    return PlayerCanvas.ClipX / 640;
}

simulated function PostRender(Canvas Canvas)
{
    if (PlayerCanvas == None)
        PlayerCanvas = Canvas;

    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.Style = 1;

    if (BackgroundTexture != None)
    {
        Canvas.SetPos(GetXDrawPosition(BackgroundPositionRatioX, BackgroundScale, BackgroundSize), GetYDrawPosition(BackgroundPositionRatioY, BackgroundScale, BackgroundSize));
        Canvas.DrawIcon(BackgroundTexture, GetScale()*BackgroundScale);
    }

    if (HeadTexture != None)
    {
        Canvas.SetPos(GetXDrawPosition(HeadPositionRatioX, HeadScale, HeadSize), GetYDrawPosition(HeadPositionRatioY, HeadScale, HeadSize));
        Canvas.DrawIcon(HeadTexture, GetScale()*HeadScale);
    }

    if (BarTexture != None)
    {
        Canvas.SetDrawColor(0, 0, 0, 255);
        Canvas.SetPos(GetXDrawPosition(BarBackgroundPositionRatioX, BarScale, BarSize), GetYDrawPosition(BarBackgroundPositionRatioY, BarScale, BarSize));
        Canvas.DrawRect(BarTexture, BarBackgroundDrawLengthX*GetScale(), BarBackgroundDrawLengthY*GetScale());

        Canvas.SetDrawColor(255, 255, 255, 255);
        Canvas.SetPos(GetXDrawPosition(BarPositionRatioX, BarScale, BarSize), GetYDrawPosition(BarPositionRatioY, BarScale, BarSize));
        Canvas.DrawRect(BarTexture, BarDrawLengthX*GetXDrawLengthRatio()*GetScale(), BarDrawLengthY*GetScale());
    }
}

defaultproperties
{
     BackgroundSize=128
     BackgroundScale=1.000000
     BackgroundPositionRatioX=-0.800000
     BackgroundPositionRatioY=-0.700000
     BackgroundTexture=Texture'nathans.Inventory.bloodsplat-1'
     HeadSize=64
     HeadScale=1.000000
     HeadPositionRatioX=-0.800000
     HeadPositionRatioY=-0.800000
     HeadTexture=Texture'HUDPack.Icons.Icon_Inv_Cat'
     BarSize=4
     BarScale=1.000000
     BarPositionRatioX=-0.950000
     BarPositionRatioY=-0.650000
     BarBackgroundPositionRatioX=-0.960000
     BarBackgroundPositionRatioY=-0.657500
     BarDrawLengthX=96.000000
     BarDrawLengthY=4.000000
     BarBackgroundDrawLengthX=102.000000
     BarBackgroundDrawLengthY=8.000000
     BarTexture=Texture'HUDPack.Icons.icon_inv_badge_slider'
     bVisible=True
     bRequiresTick=True
}
