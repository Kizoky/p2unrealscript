class Modifier extends Material
	native
	editinlinenew
	hidecategories(Material)
	abstract;

var() editinlineuse Material Material;

function Trigger( Actor Other, Actor EventInstigator )
{
	if( Material != None )
		Material.Trigger( Other, EventInstigator );
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}