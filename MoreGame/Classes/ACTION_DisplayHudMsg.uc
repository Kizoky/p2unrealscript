class ACTION_DisplayHudMsg extends ScriptedAction;

var(Action) editinline array<P2HUD.S_HudMsg> HudMsgs;
var(Action) float Lifetime;

function bool InitActionFor(ScriptedController C)
{
	local P2Player p2p;
	
	if (HudMsgs.Length > 0)
		{
		foreach C.AllActors(class'P2Player', p2p)
			break;
		if (p2p != None && P2HUD(p2p.MyHUD) != None)
			P2HUD(p2p.MyHUD).AddHudMsgs(HudMsgs, Lifetime);
		}
	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="display hud msg"
}