//=============================================================================
// An emitter effected by environment (like wind)
//=============================================================================
class Wemitter extends P2Emitter;

// records what the wind told it the last time it was applied
var vector OldWindAcc;

function ApplyAcc(int num, vector Acc)
{
	Emitters[num].Acceleration.x += Acc.x;
	Emitters[num].Acceleration.y += Acc.y;
}

function RemoveOldAcc(int num, vector OldAcc)
{
	Emitters[num].Acceleration.x -= OldAcc.x;
	Emitters[num].Acceleration.y -= OldAcc.y;
}

function vector ConvertWindAcc(vector Acc)
{
	return Acc;		// STUB
}

function ApplyWindEffects(vector WAcc, vector OldWAcc)
{
	local int num;
	local vector UseWAcc;

	UseWAcc = ConvertWindAcc(WAcc);
	for(num=0; num < Emitters.length; num++)
	{
		RemoveOldAcc(num, OldWindAcc);
		ApplyAcc(num, UseWAcc);
	}
	OldWindAcc = UseWAcc;
}

///////////////////////////////////////////////////////////////////////////////
// See if this actor's cylinder is hitting this line
///////////////////////////////////////////////////////////////////////////////
/*
function bool ThickLineCylinderCollide(vector startpt, vector endpt, 
									   float lineradius, float lineheight, 
									   vector ActorLoc, float ActorRad, float ActorHeight)
{
	//local float rad;
	local vector startxy, endxy, Locxy;
	local vector v1, v2, center;
	local float usedist, useang;
	local float hyp;

	//rad = Other.CollisionRadius;

	// Store only the x and y for most tests.
	startxy.x=startpt.x;
	startxy.y=startpt.y;
	endxy.x=endpt.x;
	endxy.y=endpt.y;
	Locxy.x = ActorLoc.x;
	Locxy.y = ActorLoc.y;

	v1 = Locxy - startxy;
	v2 = startxy - endxy;

	hyp = Vsize(v1);
	// check end points
	if(hyp <= ActorRad + lineradius
		&& abs(startpt.z - ActorLoc.z) < ActorHeight + lineheight)
		return true;
	if(VSize(endxy - Locxy) <= ActorRad + lineradius
		&& abs(endpt.z - ActorLoc.z) < ActorHeight + lineheight)
		return true;
	
	// Did hit the end points, so check the middle
	// Going with angle between two lines, gives us angle. Take hypotenuse (v1) to
	// cylinder from start, and mult by sine of angle to get distance.
	if(hyp == 0)
		return false;

	// Check to make sure neither the vector (v1 or v2) is 0. 
	if(Vsize(v2) == 0)
		return false;

	useang = atan(v2.y/v2.x) - atan(v1.y/v1.x);
	usedist = abs(hyp*sin(useang));
	center = (startxy + endxy)/2;

	// if within the distance to the line and within the radius of the center to the ends
	if(usedist <= ActorRad + lineradius
		&& VSize(center-Locxy) <= VSize(v2)/2)
		return true;

	return false;
}
*/

/*
//	This function finds the closest distance between the the pointval and
//	the line made by points startpoint and endpoint. Use the out u value
//	to find if the point is within the line segment.
//	It is SLOW. So be careful with it.
//	d2line := proc(p,a,v)
//              local lc,lv;
//              lv := sqrt(innerprod(v,v));
//              lc := crossprod(p-a,v);
//              lc := sqrt(innerprod(lc,lc));
//              lc/lv
//          end
function bool PointToLineDist(vector startpoint, vector endpoint, vector pointval,
							   out float perpdist, out float u)
{
	local vector unitdir;
	local vector lc;
	local vector ps, es;
	local float dist;

	es = endpoint - startpoint;
	unitdir = Normal(es);
	if(!(unitdir.x == 0
		&& unitdir.y == 0
		&& unitdir.z == 0))
	{
//		log("unitdir "$unitdir);
		// We don't need to find this distance or divide by it because it is
		// always going to be 1, since we normalized it. (it doesn't keep any
		// direction information here, so don't worry).
		//dist1 = VSize(unitdir);
		//log("dist1 "$dist1);
		ps = (pointval - startpoint);
		lc = (-ps) Cross unitdir;
//		log("lc "$lc);
		perpdist = VSize(lc);
//		log("perpdist "$perpdist);

		u = ps.x*es.x + ps.y*es.y + ps.z*es.z;//(pointval.x - startpoint.x)*(endpoint.x - startpoint.x) + 
			 //(pointval.y - startpoint.y)*(endpoint.y - startpoint.y) + 
			 //(pointval.z - startpoint.z)*(endpoint.z - startpoint.z);
		dist = VSize(es);
		u = u/(dist*dist);
//		log("u : "$u);
		return true;
	}
	else
		return false;
}
*/

///////////////////////////////////////////////////////////////////////////////
// See if this actor's cylinder is hitting this line
///////////////////////////////////////////////////////////////////////////////
function bool SphereCylinderCollide(vector ballpt, float ballrad, Actor Other)
{
	local vector startxy, Locxy;
	local vector v1, v2, center;
	local float usedist, useang;
	local float hyp;

	// Store only the x and y for most tests.
	startxy.x=ballpt.x;
	startxy.y=ballpt.y;
	Locxy.x = Other.Location.x;
	Locxy.y = Other.Location.y;

	if(VSize(startxy - Locxy) <= ballrad + Other.CollisionRadius
		&& abs(ballpt.z - Other.Location.z) <= ballrad + Other.CollisionHeight)
		return true;

	return false;
}

///////////////////////////////////////////////////////////////////////////////
// equals with range
///////////////////////////////////////////////////////////////////////////////
function bool VectorsInFuzz(vector v1, vector v2, float fuzz)
{
	return(v1.x > v2.x-fuzz && v1.x < v2.x+fuzz
		&& v1.y > v2.y-fuzz && v1.y < v2.y+fuzz
		&& v1.z > v2.z-fuzz && v1.z < v2.z+fuzz);

}

defaultproperties
{
}
