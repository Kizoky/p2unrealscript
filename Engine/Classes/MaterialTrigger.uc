class MaterialTrigger extends Triggers;

#exec Texture Import File=Textures\tmaterialtrigger.bmp Name=S_MaterialTrigger Mips=Off MASKED=1

var() array<Material> MaterialsToTrigger;

function Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0;i<MaterialsToTrigger.Length;i++ )
	{
		if( MaterialsToTrigger[i] != None )
			MaterialsToTrigger[i].Trigger( Other, EventInstigator );
	}
}

///////////////////////////////////////////////////////////////////////////////
// RWS Change 08/27/02
// This goes through any MaterialSwitches in the Materials to trigger and
// sets them to use the specifiec index
// This wasn't extended into our own class
// because some materials already were setup with MaterialTrigger
///////////////////////////////////////////////////////////////////////////////
function SetCurrentMaterialSwitch(int NewCurrent)
{
	local int i;
	for( i=0;i<MaterialsToTrigger.Length;i++ )
	{
		if( MaterialSwitch(MaterialsToTrigger[i]) != None )
			MaterialSwitch(MaterialsToTrigger[i]).SetCurrent(NewCurrent);
	}
}

defaultproperties
{
	Texture=S_MaterialTrigger
	bCollideActors=False
	DrawScale=0.25
}