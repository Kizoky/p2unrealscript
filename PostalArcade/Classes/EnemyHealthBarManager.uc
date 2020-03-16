class EnemyHealthBarManager extends Actor;

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

var bool bShowHealthBar;
var P2Pawn Enemy;
var PlayerController Player;

simulated function bool HasHealthBarInteraction()
{
    local int i;

    if (Player != None)
    {
        for (i=0;i<Player.Player.InteractionMaster.GlobalInteractions.length;i++)
            if (EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]) != None)
                return true;
    }

    return false;
}

simulated function AddHealthBarInteraction()
{
    local int i;
    local EnemyHealthBarInteraction PlayerInteraction;

    if (Player == None)
        return;

    Player.Player.InteractionMaster.AddInteraction("PostalArcade.EnemyHealthBarInteraction");

    for (i=0;i<Player.Player.InteractionMaster.GlobalInteractions.length;i++)
        if (EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]) != None)
            PlayerInteraction = EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]);

    if (PlayerInteraction != None)
    {
         PlayerInteraction.Enemy = Enemy;
         PlayerInteraction.Player = Player;
         PlayerInteraction.BackgroundSize = BackgroundSize;
         PlayerInteraction.BackgroundScale = BackgroundScale;
         PlayerInteraction.BackgroundPositionRatioX = BackgroundPositionRatioX;
         PlayerInteraction.BackgroundPositionRatioY= BackgroundPositionRatioY;
         PlayerInteraction.HeadSize = HeadSize;
         PlayerInteraction.HeadScale = HeadScale;
         PlayerInteraction.HeadPositionRatioX = HeadPositionRatioX;
         PlayerInteraction.HeadPositionRatioY = HeadPositionRatioY;
         PlayerInteraction.BarSize = BarSize;
         PlayerInteraction.BarScale = BarScale;
         PlayerInteraction.BarPositionRatioX = BarPositionRatioX;
         PlayerInteraction.BarPositionRatioY = BarPositionRatioY;
         PlayerInteraction.BarBackgroundPositionRatioX = BarBackgroundPositionRatioX;
         PlayerInteraction.BarBackgroundPositionRatioY = BarBackgroundPositionRatioY;
         PlayerInteraction.BarDrawLengthX = BarDrawLengthX;
         PlayerInteraction.BarDrawLengthY = BarDrawLengthY;
         PlayerInteraction.BarBackgroundDrawLengthX = BarBackgroundDrawLengthX;
         PlayerInteraction.BarBackgroundDrawLengthY = BarBackgroundDrawLengthY;

         if (BackgroundTexture != None)
             PlayerInteraction.BackgroundTexture = BackgroundTexture;

         if (HeadTexture != None)
             PlayerInteraction.HeadTexture = HeadTexture;

         if (BarTexture != None)
             PlayerInteraction.BarTexture = BarTexture;
    }
}

simulated function RemoveHealthBarInteraction()
{
    local int i;

    if (Player != None)
    {
        for (i=0;i<Player.Player.InteractionMaster.GlobalInteractions.length;i++)
            if (EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]) != None)
                Player.Player.InteractionMaster.RemoveInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]);
    }
}

simulated function Tick(float DeltaTime)
{
    if (bShowHealthBar && Player != None && !HasHealthBarInteraction())
        AddHealthBarInteraction();

    if ((Enemy == None || Enemy.Health <= 0) && Player != None && HasHealthBarInteraction())
        RemoveHealthBarInteraction();
}

defaultproperties
{
     bHidden=True
}
