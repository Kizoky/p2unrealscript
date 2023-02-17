// Mostly the same as regular fanatics, but a bit more polite
class DialogFanaticPL extends DialogFanatic;

///////////////////////////////////////////////////////////////////////////////
// Fill in this character's lines
///////////////////////////////////////////////////////////////////////////////
function FillInLines()
	{
	// Let super go first
	Super.FillInLines();
	
	Clear(lgetbumped);
	Addto(lgetbumped,							"FanaticDialog.aq_damage_aghkV1", 1);
	Addto(lgetbumped,							"FanaticDialog.aq_damage_owV1", 1);
	Addto(lgetbumped,								"FanaticDialog.aq_damage_gakV1", 1);
	Addto(lgetbumped,								"FanaticDialog.aq_damage_arghV1", 1);
	Addto(lgetbumped,								"FanaticDialog.aq_damage_aughV1", 1);
}