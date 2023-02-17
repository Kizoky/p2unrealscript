// Special version of Vince for the apocalypse conqueror ending
// HealthMax must be HALF of what he's supposed to get.
class PLRWSVinceApocalypse extends PLRWSVince;

defaultproperties
{
	ActorID="PLRWSVince"

    bNoDismemberment=True
    WeapChangeDist=800.000000
    bAdvancedFiring=True
    BaseEquipment(0)=(WeaponClass=Class'Inventory.MachineGunWeapon')
    BaseEquipment(1)=(WeaponClass=Class'Inventory.LauncherWeapon')
    HealthMax=1500.000000
    bPlayerIsFriend=False
    bPlayerIsEnemy=True
    bIgnoresSenses=True
    PawnInitialState=EP_Turret
    bIgnoresHearing=True
    bUseForErrands=True
}
