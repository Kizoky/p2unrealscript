class MaterialSwitch extends Modifier
	editinlinenew
	hidecategories(Modifier)
	native;

cpptext
{
	virtual void PostEditChange();
	virtual UBOOL CheckCircularReferences( TArray<class UMaterial*>& History );
}

var() int Current;
var() editinline array<Material> Materials;

function Trigger( Actor Other, Actor EventInstigator )
{
	Current++;
	if( Current >= Materials.Length )
		Current = 0;

	Material = Materials[Current];

	if( Material != None )
		Material.Trigger( Other, EventInstigator );
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

///////////////////////////////////////////////////////////////////////////////
// RWS Change 08/27/02
// This is to allow switchable materials to be directly set to a certain texture
// This is usually accomplished using the other RWS function SetCurrentMaterialSwitch
// in MaterialTrigger. 
// This wasn't extended into our own class
// because some materials already were setup with MaterialSwitch
///////////////////////////////////////////////////////////////////////////////
function SetCurrent(int NewCurrent)
{
	Current = NewCurrent;

	Material = Materials[Current];
}

defaultproperties
{
	Current=0
}