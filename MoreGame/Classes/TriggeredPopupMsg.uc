///////////////////////////////////////////////////////////////////////////////
// TriggeredPopupMsg
// Copyright 2014, Running With Scissors, Inc.
//
// When player enters the collision radius of this Trigger, a configurable
// HUD message pops up. It can also be used as a normal Trigger
///////////////////////////////////////////////////////////////////////////////
class TriggeredPopupMsg extends Trigger;

///////////////////////////////////////////////////////////////////////////////
// Vars, consts, enums, etc.
///////////////////////////////////////////////////////////////////////////////
var(Message) P2Hud.S_HudMsg Message;	// Message to display
var(Message) float Lifetime;			// How long to display. 0 = displays until player leaves trigger radius. Note that only one "infinite" message can be displayed at a time due to limitations

///////////////////////////////////////////////////////////////////////////////
// Player is the only one who can activate these triggers
///////////////////////////////////////////////////////////////////////////////
function bool IsRelevant(actor Other)
{
	local P2Player p2p;

	if( !bInitiallyActive )
		return false;

	if(P2Pawn(Other) != None)
	{
		p2p = P2Player(P2Pawn(Other).Controller);
		if(p2p != None)
		{
			return !P2GameInfoSingle(Level.Game).ErrandIgnoreThisTag(self);
		}
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Called when something touches the trigger.
///////////////////////////////////////////////////////////////////////////////
function Touch( actor Other )
{
	local array<P2Hud.S_HudMsg> Messages;
	//Super.Touch(Other);
	// if it's who we want
	if( IsRelevant( Other ) )
	{
		TriggerActor = Other;
		if (Lifetime > 0)
		{
			Messages.Insert(0,1);
			Messages[0] = Message;
			P2HUD(P2Player(Pawn(Other).Controller).MyHud).AddHudMsgs(Messages, Lifetime);
		}
		else
		{
			P2HUD(P2Player(Pawn(Other).Controller).MyHud).PopupHudMsg = Message;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// When something untouches the trigger.
///////////////////////////////////////////////////////////////////////////////
function UnTouch( actor Other )
{
	local P2Hud.S_HudMsg BlankMessage;

	Super.UnTouch(Other);
	if( TriggerActor == Other)
		//IsRelevant( Other ) )
	{
		TriggerActor=None;
		if (Lifetime <= 0)
			P2HUD(P2Player(Pawn(Other).Controller).MyHud).PopupHudMsg = BlankMessage;
	}
}

///////////////////////////////////////////////////////////////////////////////
// Hide message if we get destroyed
///////////////////////////////////////////////////////////////////////////////
event Destroyed()
{
	local P2Hud.S_HudMsg BlankMessage;
	
	if (TriggerActor != None)
	{
		if (Lifetime <= 0)
			P2HUD(P2Player(Pawn(TriggerActor).Controller).MyHud).PopupHudMsg = BlankMessage;
		TriggerActor = None;
	}
	
	Super.Destroyed();
}

///////////////////////////////////////////////////////////////////////////////
// Other trigger turns this off.
// Hide message if we get turned off.
///////////////////////////////////////////////////////////////////////////////
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local P2Hud.S_HudMsg BlankMessage;

		bInitiallyActive = false;
		if (TriggerActor != None)
		{
			if (Lifetime <= 0)
				P2HUD(P2Player(Pawn(TriggerActor).Controller).MyHud).PopupHudMsg = BlankMessage;
			TriggerActor = None;
		}
	}
}

defaultproperties
{
	Texture=Texture'PostEd.Icons_256.triggermessage'
}