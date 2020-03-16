class WorkshopMutatorCW extends UMenuMutatorCW;

defaultproperties
{
	PageHeaderText="Mix and match modifiers to customize the game."
	ExcludeCaption="Available Modifiers"
	ExcludeHelp="These modifiers will not be used.  Click and drag modifiers to the right list if you want to use them."
	IncludeCaption="Modifiers For This Game"
	IncludeHelp="These modifiers will be used.  Click and drag modifiers to the left list to remove them.  Drag them up or down to change the order."
	MutatorBaseClass="Postal2Game.P2GameMod"
	KeepText="Always use these Modifiers"
	KeepHelp="The current list of Modifiers will be used whenever you start a Workshop game."
}
