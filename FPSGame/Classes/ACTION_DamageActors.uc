class ACTION_DamageActors extends ScriptedAction;

var(Action) int Damage;
var(Action) class<DamageType>		 DamageType;
var(Action) name DamageTag;

function bool InitActionFor(ScriptedController C)
{
	local Actor Damaged;

	foreach C.AllActors(class'Actor',Damaged,DamageTag)
		Damaged.TakeDamage( Damage, C.GetInstigator(), Damaged.Location, vect(0,0,0), DamageType);
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
	 ActionString="Damage tagged"
}