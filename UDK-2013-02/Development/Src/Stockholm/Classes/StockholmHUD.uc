class StockholmHUD extends UTHUD;
var StockholmGame game;

function DrawGameHud()
{
	game = StockholmGame(WorldInfo.Game);
	super.DrawGameHud();
	
	Canvas.SetPos(Canvas.ClipX/2,Canvas.ClipY/2);
    Canvas.SetDrawColor(255,255,255,255);
    Canvas.Font = class'Engine'.static.GetMediumFont();
    Canvas.DrawText(game.dispHostageNums());
}

defaultproperties
{
}