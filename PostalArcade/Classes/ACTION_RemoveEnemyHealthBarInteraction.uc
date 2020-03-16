class ACTION_RemoveEnemyHealthBarInteraction extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
     local int i;
     local PlayerController Player;
     local EnemyHealthBarInteraction PlayerInteraction;
     local EnemyHealthBarManager HealthBarManager;

     foreach C.AllActors(class'PlayerController', Player)
         break;

     foreach C.AllActors(class'EnemyHealthBarManager', HealthBarManager)
         break;

     for (i=0;i<Player.Player.InteractionMaster.GlobalInteractions.length;i++)
        if (EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]) != None)
        {
            PlayerInteraction = EnemyHealthBarInteraction(Player.Player.InteractionMaster.GlobalInteractions[i]);

            if (PlayerInteraction != None)
                Player.Player.InteractionMaster.RemoveInteraction(PlayerInteraction);
        }

     if (HealthBarManager != None)
         HealthBarManager.bShowHealthBar = false;

     return false;
}

defaultproperties
{
     ActionString="Added Interaction"
}
