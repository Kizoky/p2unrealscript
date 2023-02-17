///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class ColdBreathInfo extends Info
	placeable;

var() class<Emitter> BreathClass;		// Class of Emitter to attach to pawns
var() class<Emitter> BreathClassDude;	// Class of Emitter to attach to Dude

event PostBeginPlay()
{
	local P2MoCapPawn P;
	local Emitter E;
	local class<Emitter> UseClass;
	
	foreach DynamicActors(class'P2MocapPawn',P)
	{
		if (P.Controller != None && P.Controller.bIsPlayer)
			UseClass = BreathClassDude;
		else
			UseClass = BreathClass;
			
		E = Spawn(UseClass,P,,P.Location,P.Rotation);
		if (E != None)
			P.AttachToBone(E, 'MALE01 head');
	}
}

defaultproperties
{
	BreathClass=class'ColdBreath'
	BreathClassDude=class'ColdBreathDude'
}