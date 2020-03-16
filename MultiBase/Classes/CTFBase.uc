//=============================================================================
// CTFBase.
//=============================================================================
class CTFBase extends GameObjective
	abstract;

var CTFFlag myFlag;
var class<CTFFlag> FlagType;

function BeginPlay()
{
	Super.BeginPlay();
	bHidden = false;

	myFlag = Spawn(FlagType, self);

	if (myFlag==None)
	{
		warn(Self$" could not spawn flag of type '"$FlagType$"' at "$location);
		return;
	}
	else
	{
		myFlag.HomeBase = self;
		myFlag.TeamNum = DefenderTeamIndex;
	}
}

defaultproperties
{
	bStatic=false
	bStasis=false
	bAlwaysRelevant=true
	SoundRadius=255
	SoundVolume=255
    bCollideActors=True
    bBlockActors=False
    bBlockPlayers=False
	NetUpdateFrequency=8
}