class BoxLauncherProjectile2 extends BoxLauncherProjectile;
// When you're being controlled
var int		ControlMult;				// How touchy the controls are, higher, the more you
										// move with each touch of the player.
const ROCKET_MOVE_BASE	=	750.0;		// Base movement mult for controlling the rocket
const ROCKET_MOVE_ADD	=	250.0;		// Multiplied by ControlMult to add to the movement factor
const CONTROL_MULT_MAX	=	10;			// How high ControlMult can get.

///////////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{             
	local P2Player p2p;
	
        p2p = P2Player(Instigator.Controller);                       	
        if(Instigator != None && p2p != None)
        {                      
                p2p.bUseRocketCameras = False;
		p2p.bFreeCamera = False;
		
                if(p2p.ViewTarget == self)                                           	        
                        p2p.RocketDetonated(self);  				
        }
	
	Super.Destroyed();
}
///////////////////////////////////////////////////////////////////////////////
function SetupShot()
{
        Velocity = GetThrownVelocity(Instigator, Rotation, 0.6);
        RandSpin(StartSpinMag);
        GotoState('MovingOut');
}
///////////////////////////////////////////////////////////////////////////////
simulated state MovingOut
{
	///////////////////////////////////////////////////////////////////////////////
	simulated function BeginState()
	{
		local P2Player p2p;

		if(Instigator != None)
		{
			p2p = P2Player(Instigator.Controller);
			if(p2p != None)
			{
		                p2p.bBehindView = True; 
		                p2p.bFreeCamera = True;
				p2p.bUseRocketCameras = True; 
				p2p.StartViewingRocket(self);
			}	
		}		
	}
	///////////////////////////////////////////////////////////////////////////////
	// Rockets can sometimes be controlled by the player
	///////////////////////////////////////////////////////////////////////////////
	function bool AllowControl()
	{
		return (HitPawn == None);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Check to see if the player is changing our trajectory
	///////////////////////////////////////////////////////////////////////////////
	function Tick(float DeltaTime)
	{
		local P2Player p2p;
		local float PlayerTurnX, PlayerTurnY, usemult;
		local vector x1, y1, z1;

		// If he's got a camera on it, let him control the rocket some
		p2p = P2Player(Instigator.Controller);
		if(p2p != None)
		{
		        if(HitPawn != None && HitPawn.bChunkedUp)
			       p2p.Jump();
			       
		        if(p2p.ViewTarget != self)
		               Destroy();			       	
		}	       			
		if(p2p != None
			&& p2p.bUseRocketCameras
			&& p2p.ViewTarget == self)
		{
			// Influence the direction of the rocket
			p2p.ModifyRocketMotion(PlayerTurnX, PlayerTurnY);
			if(PlayerTurnX != 0.0
				|| PlayerTurnY != 0.0)
			{
				if(ControlMult < CONTROL_MULT_MAX)
					ControlMult++;
				usemult = (ROCKET_MOVE_BASE + (ROCKET_MOVE_ADD*ControlMult));
				PlayerTurnX*=usemult;
				PlayerTurnY*=usemult;
				//log(self$" tell rocket to move x "$PlayerTurnX$" y "$PlayerTurnY$" my vel "$Velocity$" control "$ControlMult);
				GetAxes(Rotation, x1, y1, z1);
				// We need z1 and y1 the way their are because of the rotation of the rocket
				Velocity += PlayerTurnY*z1 + PlayerTurnX*y1;
				//Acceleration = ForwardAccelerationMag*Normal(Velocity);
				//log(self$" vel after "$Velocity);
				SetRotation(rotator(Velocity));
			}
			else
			{
				if(ControlMult > 0)
					ControlMult--;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	Skins(0)=Texture'AW7Tex.AMN.redbox' 
	LifeSpan=0.0
}
