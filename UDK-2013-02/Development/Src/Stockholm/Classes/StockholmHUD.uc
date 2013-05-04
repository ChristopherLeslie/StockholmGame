class StockholmHUD extends UTHUD;
var StockholmGame game;

function DrawGameHud()
{
	local int NumberOfWardItems;
	local int NumberOfSentryItems;
	local int NumberOfMineItems;
	
	
	game = StockholmGame(WorldInfo.Game);
    if(game.gameOver){
        if(game.winner == game.blueTeamNum){
            //YOU WON
            Canvas.SetPos(200,200);
            Canvas.SetDrawColor(255,255,255,255);
            Canvas.Font = class'Engine'.static.GetLargeFont();
            Canvas.DrawText("YOUVE WON "$game.dispHostageNums());
        }
        else if(game.winner == game.redTeamNum){
            Canvas.SetPos(200,200);
            Canvas.SetDrawColor(255,255,255,255);
            Canvas.Font = class'Engine'.static.GetLargeFont();
            Canvas.DrawText("YOUVE LOST "$game.dispHostageNums());
        }
        else if(game.winner == game.nobodyTeamNum){
            //TIE
        }
    }
    else{
		
		super.DrawGameHud();
		
		//SCORE
		
		//ITEMS		
		
		NumberOfWardItems = CaptorPawn(PlayerOwner.Pawn).WardPickups;
		NumberOfSentryItems = CaptorPawn(PlayerOwner.Pawn).SentryPickups;
		NumberOfMineItems = CaptorPawn(PlayerOwner.Pawn).MinePickups;

    	Canvas.SetPos(50,300);
    	Canvas.DrawTile(Texture2D'Stockholm_Sounds.Mine_Alpha',100,100,0,0,512,512);
    	Canvas.SetPos(50,340);
		Canvas.DrawText(NumberOfMineItems);
		
		Canvas.SetPos(50,400);
		Canvas.DrawTile(Texture2D'Stockholm_Sounds.Turret_Alpha',100,100,0,0,512,512);
		Canvas.SetPos(50,440);
		Canvas.DrawText(NumberOfSentryItems);
		
		Canvas.SetPos(50,500);
		Canvas.DrawTile(Texture2D'Stockholm_Sounds.Ward_Alpha',100,100,0,0,512,512);
		Canvas.SetPos(50,540);
		Canvas.DrawText(NumberOfWardItems);
		
		//TIME
    	Canvas.SetPos(200,200);
    	Canvas.SetDrawColor(255,255,255,255);
        Canvas.Font = class'Engine'.static.GetMediumFont();
    	Canvas.DrawText(game.currentTime());
    	
		//AMMO AND HEALTH
		
    	if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating'))
    	{
    		DrawBar("Health",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,20,200,80,80);         
    		DrawBar("Ammo",UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount ,20,40,80,80,200);    
        }
    }

	
}

function DrawBar(String Title, float Value, float MaxValue,int X, int Y, int R, int G, int B)
{

    local int PosX,NbCases,i;

    PosX = X; // Where we should draw the next rectangle
    NbCases = 10 * Value / MaxValue;	 // Number of active rectangles to draw
    i=0; // Number of rectangles already drawn

    /* Displays active rectangles */
    while(i < NbCases && i < 10)
    {
        Canvas.SetPos(PosX,Y);
        Canvas.SetDrawColor(R,G,B,200);
        Canvas.DrawRect(8,12);

        PosX += 10;
        i++;

    }

    /* Displays desactived rectangles */
    while(i < 10)
    {
        Canvas.SetPos(PosX,Y);
        Canvas.SetDrawColor(255,255,255,80);
        Canvas.DrawRect(8,12);

        PosX += 10;
        i++;

    }

    /* Displays a title */
    Canvas.SetPos(PosX + 5,Y);
    Canvas.SetDrawColor(R,G,B,200);
    Canvas.Font = class'Engine'.static.GetSmallFont();
    Canvas.DrawText(Title);

}

defaultproperties
{
}