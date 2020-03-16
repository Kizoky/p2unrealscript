class ACTION_AddEnemyHealthBarInteraction extends ScriptedAction;

var(Action) int BackgroundSize;
var(Action) float BackgroundScale;
var(Action) float BackgroundPositionRatioX;
var(Action) float BackgroundPositionRatioY;
var(Action) Texture BackgroundTexture;

var(Action) int HeadSize;
var(Action) float HeadScale;
var(Action) float HeadPositionRatioX;
var(Action) float HeadPositionRatioY;
var(Action) Texture HeadTexture;

var(Action) int BarSize;
var(Action) float BarScale;
var(Action) float BarPositionRatioX;
var(Action) float BarPositionRatioY;
var(Action) float BarBackgroundPositionRatioX;
var(Action) float BarBackgroundPositionRatioY;
var(Action) float BarDrawLengthX;
var(Action) float BarDrawLengthY;
var(Action) float BarBackgroundDrawLengthX;
var(Action) float BarBackgroundDrawLengthY;
var(Action) Texture BarTexture;

var(Action) name EnemyTag;

function bool InitActionFor(ScriptedController C)
{
     local int i;
     local PlayerController Player;
     local EnemyHealthBarInteraction PlayerInteraction;
     local EnemyHealthBarManager HealthBarManager;
     local P2Pawn Enemy;

     foreach C.AllActors(class'PlayerController', Player)
         break;

     foreach C.AllActors(class'P2Pawn', Enemy, EnemyTag)
         break;

     foreach C.AllActors(class'EnemyHealthBarManager', HealthBarManager)
         break;

     if (Enemy == None)
         return false;

     PlayerInteraction = EnemyHealthBarInteraction(Player.Player.InteractionMaster.AddInteraction("PostalArcade.EnemyHealthBarInteraction"));

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

     if (HealthBarManager == None)
     {
         HealthBarManager = C.Spawn(class'EnemyHealthBarManager');

         if (HealthBarManager != None)
         {
             HealthBarManager.bShowHealthBar = true;
             HealthBarManager.HeadTexture = HeadTexture;
             HealthBarManager.Enemy = Enemy;
             HealthBarManager.Player = Player;
             HealthBarManager.BackgroundSize = BackgroundSize;
             HealthBarManager.BackgroundScale = BackgroundScale;
             HealthBarManager.BackgroundPositionRatioX = BackgroundPositionRatioX;
             HealthBarManager.BackgroundPositionRatioY= BackgroundPositionRatioY;
             HealthBarManager.BackgroundTexture = BackgroundTexture;
             HealthBarManager.HeadSize = HeadSize;
             HealthBarManager.HeadScale = HeadScale;
             HealthBarManager.HeadPositionRatioX = HeadPositionRatioX;
             HealthBarManager.HeadPositionRatioY = HeadPositionRatioY;
             HealthBarManager.HeadTexture = HeadTexture;
             HealthBarManager.BarSize = BarSize;
             HealthBarManager.BarScale = BarScale;
             HealthBarManager.BarPositionRatioX = BarPositionRatioX;
             HealthBarManager.BarPositionRatioY = BarPositionRatioY;
             HealthBarManager.BarBackgroundPositionRatioX = BarBackgroundPositionRatioX;
             HealthBarManager.BarBackgroundPositionRatioY = BarBackgroundPositionRatioY;
             HealthBarManager.BarDrawLengthX = BarDrawLengthX;
             HealthBarManager.BarDrawLengthY = BarDrawLengthY;
             HealthBarManager.BarBackgroundDrawLengthX = BarBackgroundDrawLengthX;
             HealthBarManager.BarBackgroundDrawLengthY = BarBackgroundDrawLengthY;
             HealthBarManager.BarTexture = BarTexture;
             //HealthBarManager.PlayerInteraction = PlayerInteraction;
         }
     }

     return false;
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
     ActionString="Added Interaction"
}
