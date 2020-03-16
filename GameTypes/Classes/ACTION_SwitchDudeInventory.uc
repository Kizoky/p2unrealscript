///////////////////////////////////////////////////////////////////////////////
// Switch dude's inventory to the desired inventory class.
///////////////////////////////////////////////////////////////////////////////
class ACTION_SwitchDudeInventory extends P2ScriptedAction;

var() class<Inventory> SwitchTo;

function bool InitActionFor(ScriptedController C)
	{
	GetPlayer(C).SwitchToThisPowerup(SwitchTo.Default.InventoryGroup, SwitchTo.Default.GroupOffset);

	return false;
	}

function string GetActionString()
{
	return ActionString$SwitchTo;
}

	defaultproperties
{
     ActionString="Dude switch to powerup"
	 SwitchTo=class'MoneyInv'
}
