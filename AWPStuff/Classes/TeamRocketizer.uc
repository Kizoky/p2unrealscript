class TeamRocketizer extends BoxLauncherProjectile;

///////////////////////////////////////////////////////////////////////////////
simulated function HitWall(vector HitNormal, actor Wall)
{	
	Destroy();
}

defaultproperties
{
	bHidden = false
	Skins[0]=ConstantColor'ConstantBlack'
	Speed=1500
}