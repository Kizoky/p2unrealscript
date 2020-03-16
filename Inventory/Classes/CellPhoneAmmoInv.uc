///////////////////////////////////////////////////////////////////////////////
// CellPhoneAmmoInv
// Copyright 2004 Running With Scissors, Inc.  All Rights Reserved.
//
//	Cell Phone ammo--nothing.
//
///////////////////////////////////////////////////////////////////////////////
class CellPhoneAmmoInv extends InfiniteAmmoInv;

simulated function bool HasAmmo()
{
	return false;
}

defaultproperties
{
     bReadyForUse=False
}
