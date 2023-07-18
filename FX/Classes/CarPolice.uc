///////////////////////////////////////////////////////////////////////////////
//
// CarPolice
//
// Police version of exploding car
///////////////////////////////////////////////////////////////////////////////
class CarPolice extends CarExplodable;

defaultproperties
{
    StaticMesh=StaticMesh'P2R_Meshes_D.cars.PoliceCar_New'
	Skins[0]=Texture'P2R_Tex_D.cars.Interior'
	Skins[1]=Texture'P2R_Tex_D.cars.Interior'
	Skins[2]=Shader'P2R_Tex_D.cars.police_car_d_shad'
	Skins[3]=Shader'P2R_Tex_D.cars.car_glass_2'
	Skins[4]=Texture'P2R_Tex_D.cars.car_glass_d'
	Skins[5]=Texture'P2R_Tex_D.cars.police_car_lights_d'
	BrokenStaticMesh=StaticMesh'P2R_Meshes_D.cars.PoliceCar_Sploded'
	DamageSkin=Texture'P2R_Tex_D.cars.police_car_d_burnt'
}

