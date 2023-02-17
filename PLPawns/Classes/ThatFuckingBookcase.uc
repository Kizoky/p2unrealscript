/**
 * ThatFuckingBookcase
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * Dear god! It's that fucking bookcase, and it can fucking walk!
 *
 * @author Gordon Cheng
 */
class ThatFuckingBookcase extends Bystander
    placeable;

struct BookcaseBolton {
    var vector Scale3D, RelLoc;
    var rotator RelRot;
    var name BoneName;
};

var StaticMesh BookcaseStaticMesh;
var array<BookcaseBolton> BookcaseBoltons;

function SetupBoltons() {
    local int i;
    local BoltonPart bp;

    for (i=0;i<BookcaseBoltons.length;i++) {
        if (BookcaseBoltons[i].BoneName != '' &&
            BookcaseBoltons[i].BoneName != 'None' &&
            BookcaseStaticMesh != none) {
            bp = Spawn(class'BoltonPart');

            if (bp != none) {
                AttachToBone(bp, BookcaseBoltons[i].BoneName);

                bp.SetDrawType(DT_StaticMesh);
                bp.SetStaticMesh(BookcaseStaticMesh);
                bp.SetDrawScale3D(BookcaseBoltons[i].Scale3D);
                bp.SetRelativeLocation(BookcaseBoltons[i].RelLoc);
                bp.SetRelativeRotation(BookcaseBoltons[i].RelRot);
            }
        }
    }

    super.SetupBoltons();
}

defaultproperties
{
	ActorID="ThatFuckingBookcase"

    bRandomizeHeadScale=false
	bStartupRandomization=false
	bNoChamelBoltons=true

	BookcaseStaticMesh=StaticMesh'stv-protocrap.bookshelf'

	Mesh=SkeletalMesh'MP_Characters.Avg_M_SS_Pants'

	HeadClass=class'ThatFuckingBookcaseHead'
	HeadScale=(X=-0.3,Y=0.05,Z=0.1)
    HeadSkin=Shader'P2InteriorTex.glass1'

    Skins(0)=Shader'P2InteriorTex.glass1'

    BookcaseBoltons(0)=(Scale3D=(X=0.1,Y=0.1,Z=0.2),RelLoc=(X=43,Y=-5,Z=-13),RelRot=(Yaw=16384,Roll=-16384),BoneName="MALE01 spine")

    BookcaseBoltons(1)=(Scale3D=(X=0.1,Y=0.025,Z=0.1),RelLoc=(X=-3,Y=4,Z=-3),RelRot=(Yaw=-16384,Roll=49152),BoneName="MALE01 L UpperArm")
    BookcaseBoltons(2)=(Scale3D=(X=0.1,Y=0.025,Z=0.1),RelLoc=(X=-3,Y=4,Z=-3),RelRot=(Yaw=-16384,Roll=49152),BoneName="MALE01 R UpperArm")

    BookcaseBoltons(3)=(Scale3D=(X=0.1,Y=0.025,Z=0.125),RelLoc=(X=-3,Y=4,Z=-3),RelRot=(Yaw=-16384,Roll=49152),BoneName="MALE01 L Forearm")
    BookcaseBoltons(4)=(Scale3D=(X=0.1,Y=0.025,Z=0.125),RelLoc=(X=-3,Y=4,Z=-3),RelRot=(Yaw=-16384,Roll=49152),BoneName="MALE01 R Forearm")

    BookcaseBoltons(5)=(Scale3D=(X=0.025,Y=0.025,Z=0.03),RelLoc=(X=1,Y=-1,Z=2),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 L Hand")
    BookcaseBoltons(6)=(Scale3D=(X=0.025,Y=0.025,Z=0.03),RelLoc=(X=1,Y=-1,Z=4),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 r hand")

    BookcaseBoltons(7)=(Scale3D=(X=0.1,Y=0.05,Z=0.15),RelLoc=(Y=-5,Z=7),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 L Thigh")
    BookcaseBoltons(8)=(Scale3D=(X=0.1,Y=0.05,Z=0.15),RelLoc=(Y=-5,Z=7),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 R Thigh")

    BookcaseBoltons(9)=(Scale3D=(X=0.1,Y=0.05,Z=0.15),RelLoc=(Y=-5,Z=7),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 L Calf")
    BookcaseBoltons(10)=(Scale3D=(X=0.1,Y=0.05,Z=0.15),RelLoc=(Y=-5,Z=7),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 r calf")

    BookcaseBoltons(11)=(Scale3D=(X=0.1,Y=0.05,Z=0.1),RelLoc=(X=-13,Y=-7,Z=5),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 L Toe0")
    BookcaseBoltons(12)=(Scale3D=(X=0.1,Y=0.05,Z=0.1),RelLoc=(X=-13,Y=-7,Z=5),RelRot=(Yaw=16384,Roll=16384),BoneName="MALE01 R Toe0")
	AmbientGlow=30
	bCellUser=false
}
