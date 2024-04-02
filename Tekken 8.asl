// Tekken 8 Autosplitter and Load Remover
// Supports Load Remover, Main Story & Character Episode Splits
// Splits for campaigns can be obtained from 
// Script & Pointers by TheDementedSalad

state("Polaris-Win64-Shipping"){}

init
{
	vars.completedSplits = new List<string>();
	
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr CharacterInfo = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 03 71");
	IntPtr SelectedChar = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 49 ba");
	IntPtr Cutscenes = vars.Helper.ScanRel(3, "48 8b 0d ?? ?? ?? ?? 41 0f 28 d4");
	IntPtr CurrLevel = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 89 45 ?? 48 8b 00");
	
	if (gWorld == IntPtr.Zero || CurrLevel == IntPtr.Zero || Cutscenes == IntPtr.Zero || CharacterInfo == IntPtr.Zero || SelectedChar == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}
	
	vars.Helper["Cutscene"] = vars.Helper.Make<bool>(Cutscenes, 0x3E);
	vars.Helper["LeftC"] = vars.Helper.Make<byte>(SelectedChar, 0x7C8);
	vars.Helper["RightC"] = vars.Helper.Make<byte>(SelectedChar, 0x7CC);
	vars.Helper["CurrOpp"] = vars.Helper.Make<byte>(CharacterInfo, 0x10, 0x10, 0x74);
	vars.Helper["Wins"] = vars.Helper.Make<byte>(CharacterInfo, 0x10, 0x20, 0x40);
	vars.Helper["HP"] = vars.Helper.Make<ushort>(CharacterInfo, 0x10, 0x18, 0x30, 0x8, 0x18, 0x10, 0x8, 0x42);
	vars.Helper["Loading"] = vars.Helper.Make<bool>(gWorld, 0x1E0, 0x50, 0x20, 0x180, 0x78, 0x540, 0x90);
	vars.Helper["Level"] = vars.Helper.MakeString(CurrLevel, 0x58, 0x8, 0x8, 0x128, 0x48, 0x20);
}

startup
{	
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	
	vars.Stages = new List<String>()
	{"ST05", "ST01", "ST04", "ST03", "ST08", "ST09", "ST10", "ST11", "ST07"};
	
	settings.Add("Chap", false, "Chapter Splits (Splits End of Chapter)");
	settings.Add("CharEp", false, "Character Episodes (Splits On Every Enemy Defeat)");
	settings.Add("CharEp2", false, "Character Episodes 2 (Splits On Every 5th Enemy Defeat");
	
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();
	
	//print(modules.First().ModuleMemorySize.ToString());
	//print(current.Map.ToString());
	//print(current.Loading.ToString());
	
	//Reset variables when the timer is reset.
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
	}
	
	if(!string.IsNullOrEmpty(current.Level) && current.Level != "oot"){
		current.Map = current.Level.Substring(0, 4);
	}
}

start
{
	return current.HP == 300 && !current.Cutscene && current.HP == 180 && current.RightC != 255 && !current.Loading && old.Loading;
}

split
{
	if(settings["Chap"]){
		if(vars.Stages.Contains(current.Map) && !vars.completedSplits.Contains(current.Map)){
            vars.completedSplits.Add(current.Map);
            return true;
        }
		else if(current.Map == "ST05" && current.LeftC == 6 && current.RightC == 16 && !vars.completedSplits.Contains("Leo")){
			vars.completedSplits.Add("Leo");
            return true;
        }
		else if(current.Map == "ST04" && current.LeftC == 8 && current.RightC == 32 && !vars.completedSplits.Contains("Azazel")){
			vars.completedSplits.Add("Azazel");
            return true;
        }
		else if(current.Map == "ST04" && current.LeftC == 28 && current.RightC == 118 && !vars.completedSplits.Contains("TrueD")){
			vars.completedSplits.Add("TrueD");
            return true;
        }
		else if(current.Map == "ST03" && current.LeftC == 5 && current.RightC == 119 && !vars.completedSplits.Contains("Jack7")){
			vars.completedSplits.Add("Jack7");
            return true;
        }
		else if(current.Map == "ST03" && current.LeftC == 17 && current.RightC == 118 && !vars.completedSplits.Contains("TrueD2")){
			vars.completedSplits.Add("TrueD2");
            return true;
        }
		else if(current.Map == "ST07" && current.Wins == 1 && old.Wins == 0 && !vars.completedSplits.Contains("End")){
			vars.completedSplits.Add("End");
            return true;
        }
		else return false;
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
	return current.Loading || current.Cutscene;
}

reset
{
	return current.Map == "ST02" && old.Map == "oot";
}
