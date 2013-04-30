class CaptorBullet extends UTProj_LinkPlasma;


simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	WorldInfo.Game.Broadcast(self,"Bullet hit "$Wall$" right in the "$WallComp);
	Super.HitWall(HitNormal, Wall, WallComp);
}


defaultProperties{
	
}

