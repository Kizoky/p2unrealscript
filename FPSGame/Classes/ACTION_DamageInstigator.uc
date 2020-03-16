class ACTION_DamageInstigator extends ScriptedAction;

var(Action) int Damage;
var(Action) class<DamageType>		 DamageType;

function bool InitActionFor(ScriptedController C)
{
	local pawn Damaged;

	Damaged = C.GetInstigator();
	Damaged.TakeDamage( Damage, Damaged, Damaged.Location, vect(0,0,0), DamageType);
	return false;	
}

function string GetActionString()
{
	return ActionString@(string(DamageType))@Damage;
}

defaultproperties
{
     Damage=10
	 DamageType=class'Engine.Crushed'
	 ActionString="Damage instigator"
}