//=============================================================================
// Erik Rossik.
// Revival Games 2015.
// DAttachLight.
//=============================================================================
class DAttachLight extends AttachLight;

var () Bool CoronaAct;

function Trigger( actor Other, pawn EventInstigator )
{
	If(CoronaAct)
    {  
     bcorona = True;
    }
    else
    {
     LightType = LT_Steady;
    }
}

defaultproperties
{
}
