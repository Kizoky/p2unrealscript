/**
 * ThatFuckingBookcaseHead
 * Copyright 2015, Running With Scissors, Inc. All Rights Reserved.
 *
 * How does someone with so many books in his head be so dumb?
 *
 * @author Gordon Cheng
 */
class ThatFuckingBookcaseHead extends AWHead
    placeable;

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'stv-protocrap.bookshelf'

    ExplodeHeadSound=sound'LevelSoundsToo.library.woodCrash02'
    HeadExplosionEffect=class'WoodPieces'

    PrePivot=(X=50,Y=120,Z=-160)
}
