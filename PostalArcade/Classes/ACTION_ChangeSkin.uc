class ACTION_ChangeSkin extends ScriptedAction;

var(Action) name ActorTag;

var(Action) array<Material> NewBodySkins;
var(Action) array<Material> NewHeadSkins;
var(Action) array<Material> NewActorSkins;

function bool InitActionFor(ScriptedController C)
{
     local int i;
     local Actor Other;

     if (ActorTag != '' || ActorTag != 'None')
         foreach C.AllActors(class'Actor', Other, ActorTag)
             break;

     if (Other == None)
     {
         for (i=0;i<NewBodySkins.length;i++)
             C.Pawn.Skins[i] = NewBodySkins[i];

         if (P2MoCapPawn(C.Pawn) != None)
             for (i=0;i<NewHeadSkins.length;i++)
                 P2MoCapPawn(C.Pawn).myHead.Skins[i] = NewHeadSkins[i];
     }
     else
     {
         for (i=0;i<NewActorSkins.length;i++)
             Other.Skins[i] = NewActorSkins[i];
     }

     return false;
}

defaultproperties
{
     ActionString="Changed Skin"
}
