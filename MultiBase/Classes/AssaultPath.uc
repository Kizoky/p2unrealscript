//********************************************************************
// AssaultPath
// Abstract superclass of attack paths - used to specify alternate routes for attackers
//
//********************************************************************
class AssaultPath extends NavigationPoint
	abstract
	placeable;

var GameObjective AssociatedObjective;
var AssaultPath NextPath;
var() int Position;	// specifies relative position in a chain of AssaultPaths with the same PathTag and the same ObjectiveTag
var() name ObjectiveTag;
var() name PathTag;		// paths that fan out from the same first AssaultPath share the same PathTag
var() bool bEnabled;
var() float Priority;	// 0 to 1, higher means heavier weighting when determining whether to use this path
var() name DivergeTag;	// after reach this path, continue on paths with PathTag = DivergeTag

event Trigger( Actor Other, Pawn EventInstigator )
{
	bEnabled = !bEnabled;
}

function AddTo(GameObjective O)
{
	local AssaultPath A;

	NextPath = None;
	AssociatedObjective = O;
	if ( O.AlternatePaths == None )
	{
		O.AlternatePaths = self;
		return;
	}
	if ( O.AlternatePaths.Position > Position )
	{
		NextPath = O.AlternatePaths;
		O.AlternatePaths = self;
		return;
	}

	for ( A=O.AlternatePaths; A!=None; A=A.NextPath )
	{
		if ( A.NextPath == None )
		{
			A.NextPath = self;
			return;
		}
		if ( A.NextPath.Position > Position )
		{
			NextPath = A.NextPath;
			A.NextPath = self;
			return;
		}
	}
}

function AssaultPath FindNextPath()
{
	local AssaultPath A;
	local AssaultPath List[16];
	local int i,num;
	local float sum,r;

	if ( (DivergeTag == 'None') || (DivergeTag == '') )
		DivergeTag = PathTag;
	
	for ( A=NextPath; A!=None; A=A.NextPath )
	{
		if ( (A.PathTag == DivergeTag) && A.bEnabled )
		{
			if ( (List[0] == None) || (A.Position == List[0].Position) )
			{
				List[num] = A;
				num++;
				if ( num > 15 )
					break;
			}
			else if ( A.Position > List[0].Position )
				break;
		}
	}

	if ( num > 0 )
	{
		for ( i=0; i<num; i++ )
			sum += List[i].Priority;
		r = FRand() * sum;
		sum = 0;
		for ( i=0; i<num; i++ )
		{
			sum += List[i].Priority;
			if ( r <= sum )
				return List[i];
		}
		return List[0];
	}
	return none;
}

defaultproperties
{
	bEnabled=true
	PathTag=Path1
	Priority=+0.5
}
