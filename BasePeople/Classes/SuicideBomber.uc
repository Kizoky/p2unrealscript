// Suicide Bomber for Band Camp Achievement.
// Intended only for suburbs-3
// Got sick of fussing about with scripted triggers and other bullshit so here's a uscript solution
class SuicideBomber extends Fanatics;

var bool bSuicided;
var class<TimedMarker> TimedMarkerMade;

// When triggered, cause an earth-shattering kaboom
event Trigger( Actor Other, Pawn EventInstigator )
{
	bSuicided=True;
	Spawn(class'SuicideBomberExplosion',Self,,Location,Rotation);
	// The explosion should kill us, but die anyway just in case.
	Died(None, class'DamageType', Location);
}

// If we died to anything OTHER than being suicided, the dude saved the band and should be awarded for it
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if (!bSuicided)	
	{
		if( Level.NetMode != NM_DedicatedServer ) P2GameInfoSingle(Level.Game).GetPlayer().GetEntryLevel().EvaluateAchievement(P2GameInfoSingle(Level.Game).GetPlayer(),'BandCamp');
	}
		
	Super.Died(Killer, DamageType, HitLocation);
}

// Tell everyone that we exist
event PostBeginPlay()
{
	TimedMarkerMade.static.NotifyControllersStatic(Level,TimedMarkerMade,Self,Self,TimedMarkerMade.Default.CollisionRadius,Location);
	Super.PostBeginPlay();
}

defaultproperties
{
	ChameleonSkins(0)="ChameleonSkins.MF__166__Avg_Dude"
	ChameleonSkins(1)="end"	// end-of-list marker (in case super defines more skins)
//	BaseEquipment[0]=None
	TimedMarkerMade=class'SuicideBomberMarker'
}