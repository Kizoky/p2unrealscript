class ACTION_KillInstigator extends ScriptedAction;

var() class<DamageType>		 DamageType;

function bool InitActionFor(ScriptedController C)
{
	C.GetInstigator().Died( None, DamageType, C.Instigator.Location );
	return false;	
}

function string GetActionString()
{
	return ActionString@DamageType;
}

defaultproperties
{
	 DamageType=class'Engine.Crushed'
	 ActionString="Damage instigator"
}