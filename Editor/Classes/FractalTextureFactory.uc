class FractalTextureFactory extends MaterialFactory;

var() Class<FractalTexture> Class;
enum EResolution
{
	Pixels_1,
	Pixels_2,
	Pixels_4,
	Pixels_8,
	Pixels_16,
	Pixels_32,
	Pixels_64,
	Pixels_128,
	Pixels_256,
};
var() EResolution Width, Height;

function Material CreateMaterial( Object InOuter, string InPackage, string InGroup, string InName )
{		
	local int w, h;

	switch(Width)
	{
	case Pixels_1: w=1; break;
	case Pixels_2: w=2; break;
	case Pixels_4: w=4; break;
	case Pixels_8: w=8; break;
	case Pixels_16: w=16; break;
	case Pixels_32: w=32; break;
	case Pixels_64: w=64; break;
	case Pixels_128: w=128; break;
	case Pixels_256: w=256; break;
	}

	switch(Height)
	{
	case Pixels_1: h=1; break;
	case Pixels_2: h=2; break;
	case Pixels_4: h=4; break;
	case Pixels_8: h=8; break;
	case Pixels_16: h=16; break;
	case Pixels_32: h=32; break;
	case Pixels_64: h=64; break;
	case Pixels_128: h=128; break;
	case Pixels_256: h=256; break;
	}

	ConsoleCommand( "TEXTURE NEW NAME=\""$InName$"\" CLASS=\""$String(Class)$"\" GROUP=\""$InGroup$"\" PACKAGE=\""$InPackage$"\" USIZE="$string(w)$" VSIZE="$string(h) );

	if( InGroup == "" )
		return Material( FindObject( InPackage$"."$InName, class'Material') );
	else
		return Material( FindObject( InPackage$"."$InGroup$"."$InName, class'Material') );

}

defaultproperties
{
	Description="Real-time Procedural Texture"
	Class=WetTexture
	Width=Pixels_256;
	Height=Pixels_256;
}