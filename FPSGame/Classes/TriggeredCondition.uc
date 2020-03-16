class TriggeredCondition extends Triggers
	hidecategories(Collision,Lighting,LightColor,Karma,Force,Shadow,Sound);

var()	bool	bToggled;			// If true, value can be flipped back and forth with each trigger, otherwise triggers once
var()	bool	bEnabled;			// Whether or not this condition is currently enabled.
var()	bool	bTriggerControlled;	// If true, an UnTrigger event will set this to false.
var		bool	bInitialValue;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bInitialValue = bEnabled;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( bToggled )
		bEnabled = !bEnabled;
	else
		bEnabled = !bInitialValue;
}

function Untrigger( actor Other, pawn EventInstigator )
{
	if ( bTriggerControlled )
		bEnabled = bInitialValue;
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.TriggeredCondition_Alt'
	DrawScale=0.25
	bEnabled=True
}