//=============================================================================
// ACTION_AttachActorToBone
// Erik Rossik
//=============================================================================
class ACTION_AttachActorToBone extends ScriptedAction;

var(Action) Name AttachmentTag;
var(Action) Name BoneName;
var(Action) bool Detach;

function bool InitActionFor(ScriptedController C)
{
 local Actor a;

	if(AttachmentTag != 'None')
	{
		ForEach C.AllActors(class'Actor', a, AttachmentTag)
		{
		 if(a != none)
		 {
	 	  If(!Detach)
			{
			 C.Pawn.AttachToBone(a, BoneName );
			}
			else
			{
			 C.Pawn.DetachFromBone(a);
			}	
         }			
		}
	}
	return false;	
}

defaultproperties
{
}
