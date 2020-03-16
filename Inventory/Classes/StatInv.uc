class StatInv extends P2PowerupInv;

state Activated
{
	function LookAtIt() {
		local P2Player Player;

		Player = P2Player(P2Pawn(Owner).Controller);
		if (Player != none) {
			TurnOffHints();

			/** Don't add a url parameter, for our purposes we don't want to move
             * the player back to the main menu after the stats screen closes
             */
			Player.DisplayStats();
		}
	}

Begin:
	LookAtIt();
	GotoState('');
}

defaultproperties
{
	bCanThrow=false
	Hint1="Press %KEY_InventoryActivate%"
	Hint2="to view the stats."
	InventoryGroup=103
	GroupOffset=50
	PowerupName="Stats Clipboard"
	PowerupDesc="View a record of your transgressions against society."
	Icon=texture'HUDPack.Icons.icon_inv_stat'
	bCannotBeStolen=true
}
