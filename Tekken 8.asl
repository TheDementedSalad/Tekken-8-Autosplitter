// Tekken 8 Autosplitter and Load Remover
// Supports Load Remover, Main Story & Character Episode Splits
// Splits for campaigns can be obtained from 
// Script & Pointers by TheDementedSalad

state("Polaris-Win64-Shipping", "SteamRelease")
{
	string8 Map:		0x94B5FB0, 0x58, 0x8, 0x8, 0x128, 0x48, 0x20;
	string300 MapLong:	0x94B5FB0, 0x58, 0x8, 0x8, 0x128, 0x48, 0x20;
	byte Paused:		0x948DE38, 0xB13;				//UEngine 1 cutscene & pause menu 0 in game
	byte PauseMenu:		0x94F08C8, 0x60;				//1 paused, 2 paused in cutscene, 0 unpaused
	
	byte CurrOpp:		0x8E732C8, 0x10, 0x10, 0x74; 	//0,1,2,3,4 character story mode
	byte Wins:			0x8E732C8, 0x10, 0x20, 0x40; 	//0,1,2 depending on how many rounds you win
	byte Cutscene:		0x94B15C0, 0x3E;				//1 Cutscene 0 else
	byte Loading:		0x933D140, 0x528, 0xD0;			//1 loading 0 else
	ushort HP:			0x94B6328, 0x42;
	byte LeftC:			0x94B5110, 0x0, 0x0, 0x10;
	byte RightC:		0x94B5110, 0x0, 0x8, 0x10;
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case (167849984):
			version = "SteamRelease";
			break;
	}
	
	vars.completedSplits = new List<string>();
}

startup
{	
	vars.Stages = new List<String>()
	{"ST05", "ST01", "ST04", "ST03", "ST08", "ST09", "ST10", "ST11", "ST07"};
	
	settings.Add("Chap", false, "Chapter Splits (Splits End of Chapter)");
	settings.Add("CharEp", false, "Character Episodes (Splits On Every Enemy Defeat)");
	settings.CurrentDefaultParent = "CharEp";
	settings.Add("CharEp2", false, "Character Episodes 2 (Splits On Every 5th Enemy Defeat");
	settings.CurrentDefaultParent = null;
}

update
{
	//print(modules.First().ModuleMemorySize.ToString());
	//print(current.Map.ToString());
	
	//Reset variables when the timer is reset.
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
	}
}

start
{
	return (current.HP == 300 || current.HP == 180) && current.Cutscene == 0;
}

split
{
	if(settings["Chap"]){
		if(vars.Stages.Contains(current.Map) && !vars.completedSplits.Contains(current.Map)){
            vars.completedSplits.Add(current.Map);
            return true;
        }
		
		if(current.Map == "ST05" && current.LeftC == 6 && current.RightC == 16 && !vars.completedSplits.Contains("Leo")){
			vars.completedSplits.Add("Leo");
            return true;
        }
		
		if(current.Map == "ST04" && current.LeftC == 8 && current.RightC == 32 && !vars.completedSplits.Contains("Azazel")){
			vars.completedSplits.Add("Azazel");
            return true;
        }
		
		if(current.Map == "ST04" && current.LeftC == 28 && current.RightC == 118 && !vars.completedSplits.Contains("TrueD")){
			vars.completedSplits.Add("TrueD");
            return true;
        }
		
		if(current.Map == "ST03" && current.LeftC == 5 && current.RightC == 119 && !vars.completedSplits.Contains("Jack7")){
			vars.completedSplits.Add("Jack7");
            return true;
        }
		
		if(current.Map == "ST03" && current.LeftC == 17 && current.RightC == 118 && !vars.completedSplits.Contains("TrueD2")){
			vars.completedSplits.Add("TrueD2");
            return true;
        }
		
		if(current.Map == "ST07" && current.Wins == 1 && old.Wins == 0 && !vars.completedSplits.Contains("End")){
			vars.completedSplits.Add("End");
            return true;
        }
	}
	
	if(settings["CharEp"]){
		return current.Wins == 2 && old.Wins == 1;
	}
	
	if(settings["CharEp2"]){
		return current.Wins == 2 && old.Wins == 1 && current.CurrOpp == 4;
	}
}
	
isLoading
{	
	return current.Loading == 1 || current.Cutscene == 1;
}

reset
{
	return current.Map == "ST02" && old.Map == "oot";
}
