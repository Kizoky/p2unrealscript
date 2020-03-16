///////////////////////////////////////////////////////////////////////////////
// HolidaySpawner
// Copyright 2014, Running With Scissors. Inc. All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
class HolidaySpawner extends HolidaySpawnerBase;

///////////////////////////////////////////////////////////////////////////////
// Halloween: swap out shovel pickups
///////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
	local ShovelPickup shuvel;
	
	Super.PostBeginPlay();
	if (P2GameInfoSingle(Level.Game).IsHoliday('SeasonalHalloween'))
	{
		foreach DynamicActors(class'ShovelPickup', shuvel)
		{
			// Only do actual shovel pickups
			if (shuvel.Class == class'ShovelPickup'
				&& !shuvel.bForTransferOnly)
			{
				shuvel.InventoryType = class'PitchforkPickup'.default.InventoryType;
				shuvel.PickupMessage = class'PitchforkPickup'.default.PickupMessage;
				shuvel.default.InventoryType = class'PitchforkPickup'.default.InventoryType;
				shuvel.default.PickupMessage = class'PitchforkPickup'.default.PickupMessage;
				shuvel.SetStaticMesh(class'PitchforkPickup'.default.StaticMesh);
			}
		}
	}
}


defaultproperties
{
	//Spawns[0]=(Pawns=(class'SkeletonZombie'),HolidayName="SeasonalHalloween",SpawnChancePct=0.083333,SpawnLocation=ES_SpawnRadius,SpawnRadiusMin=500,SpawnRadiusMax=5000,SpawnEffect=class'SkeletonSpawnEffect',PawnInitialState=EP_AttackPlayer)
	Spawns[0]=(Pawns=(class'SkeletonKamikaze'),HolidayName="SeasonalHalloween",SpawnChancePct=0.05,SpawnLocation=ES_SpawnRadius_WhenSeen,SpawnRadiusMin=400,SpawnRadiusMax=2000,SpawnEffect=class'SkeletonSpawnEffect',SpawnMarker=class'AnimalAttackMarker',SpawnMarkerRadius=250)
	Spawns[1]=(Pawns=(class'SkeletonMace'),HolidayName="SeasonalHalloween",SpawnChancePct=0.05,SpawnLocation=ES_SpawnRadius_WhenSeen,SpawnRadiusMin=400,SpawnRadiusMax=2000,SpawnEffect=class'SkeletonSpawnEffect',SpawnMarker=class'AnimalAttackMarker',SpawnMarkerRadius=250)
	Spawns[2]=(Pawns=(class'SkeletonSword'),HolidayName="SeasonalHalloween",SpawnChancePct=0.04,SpawnLocation=ES_SpawnRadius_WhenSeen,SpawnRadiusMin=400,SpawnRadiusMax=2000,SpawnEffect=class'SkeletonSpawnEffect',SpawnMarker=class'AnimalAttackMarker',SpawnMarkerRadius=250)
	Spawns[3]=(Pawns=(class'SkeletonSwordShield'),HolidayName="SeasonalHalloween",SpawnChancePct=0.04,SpawnLocation=ES_SpawnRadius_WhenSeen,SpawnRadiusMin=400,SpawnRadiusMax=2000,SpawnEffect=class'SkeletonSpawnEffect',SpawnMarker=class'AnimalAttackMarker',SpawnMarkerRadius=250)
	Spawns[4]=(Pawns=(class'GaryGhost'),HolidayName="SeasonalHalloween",SpawnChancePct=0.03,SpawnLocation=ES_SpawnRadius_NotSeen,SpawnRadiusMin=1000,SpawnRadiusMax=10000,MaxSpawnedPerLevel=1)
}
