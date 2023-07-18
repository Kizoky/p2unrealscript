class xWeaponList extends UWindowListBoxItem;

var string WeaponName;
var string WeaponClass;
var string PickupClass;
var string AmmoClass;

function int Compare(UWindowList T, UWindowList B)
{
	if(Caps(xWeaponList(T).WeaponClass) < Caps(xWeaponList(B).WeaponClass))
		return -1;

	return 1;
}

// Call only on sentinel
function xWeaponList FindWeapon(string FindWeaponClass)
{
	local xWeaponList I;

	for(I = xWeaponList(Next); I != None; I = xWeaponList(I.Next))
		if(I.WeaponClass ~= FindWeaponClass)
			return I;

	return None;
}
