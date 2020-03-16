//=============================================================================
// UseTrigger: if a player stands within proximity of this trigger, and hits Use, 
// it will send Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class UseTrigger extends Triggers
	hidecategories(Force,Karma,Lighting,LightColor,Shadow,Sound);

#exec Texture Import File=Textures\usetrigger.bmp  Name=S_UseTrigger Mips=Off MASKED=1
#exec Texture Import File=Textures\UseTrigger_64.tga Name=UseTrigger_64 Mips=Off Alpha=1

var() localized string Message;	// Message to display in HUD when player is in range to activate this trigger.
var() Texture HUDIcon;			// Icon to display in HUD when player is in range to activate this trigger.
var() bool bTriggerOnceOnly;	// Only trigger once and then go dormant.
var() bool bInitiallyActive;	// For triggers that are activated/deactivated by other triggers.
var() float ReTriggerDelay; 	// minimum time before trigger can be triggered again

// store for reset
var bool bSavedInitialCollision;
var bool bSavedInitialActive;

function UsedBy( Pawn user )
{
	if (bInitiallyActive)
	{
		TriggerEvent(Event, self, user);
		
		if (bTriggerOnceOnly)
			bInitiallyActive = false;
			
		if (ReTriggerDelay > 0)
		{
			bInitiallyActive = false;
			SetTimer(ReTriggerDelay, false);
		}
	}
}

event Timer()
{
	bInitiallyActive = true;
}

// Skip the message, we show it in the HUD. - K
/*
function Touch( Actor Other )
{
	if( (Message != "") && (Other.Instigator != None) )
		// Send a string message to the toucher.
		Other.Instigator.ClientMessage( Message );
}
*/

function PostBeginPlay()
{
	bSavedInitialActive = bInitiallyActive;
	bSavedInitialCollision = bCollideActors;
	Super.PostBeginPlay();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();

	// collision, bInitiallyactive
	bInitiallyActive = bSavedInitialActive;
	SetCollision(bSavedInitialCollision, bBlockActors, bBlockPlayers );
}

//=============================================================================
// Trigger states.

// Trigger is always active.
auto state() NormalTrigger
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
	}
}


defaultproperties
{
	Texture=S_UseTrigger
	DrawScale=0.25
	HUDIcon=S_UseTrigger
	Message="Press %KEY_InventoryActivate% to use object."
	bInitiallyActive=true
}