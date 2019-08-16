#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

//Define variables to represent a number (For game detection system)
#define GENERIC 0
#define CSGO 1
#define INS 2

//Create a boolean variable
new bool:AMS;

//Create variables to assign console variables to them
new Handle:h_AMS;
new Handle:h_AMSV;

//Create a variable and assign a value to it
new GameConfig = GENERIC;

public Plugin myinfo = 
{
	name = "Blade Runner",
	author = PLUGIN_AUTHOR,
	description = "Run faster with your knife out",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	//Create a variable to store the game folder in it
	new String:Game[20];
	//Get the game folder name and store it in the variable
	GetGameFolderName(Game, sizeof(Game));
	//Run if checks to find out what game the client is running and store the data in a variable
	if (StrEqual(Game, "insurgency", false))
	{
		GameConfig = INS;
		//Call the function whenever someone equips their gun
		HookEvent("weapon_deploy", EventWeaponDeploy);
	}
	else if (StrEqual(Game, "csgo", false))
	{
		GameConfig = CSGO;
		HookEvent("item_equip", EventWeaponDeploy);
	}
	else
	{
		GameConfig = GENERIC;
		PrintToServer("[Blade Runner] Invalid game detected: %s", Game);
		PrintToServer("[Blade Runner] Running the plugin in generic mode. If you encounter problems, contact leakbang");
	}
	
	h_AMS = CreateConVar("sm_bladerun", "1", "Use values 1/0 to enable or disable running fast with knives on this server");
	h_AMSV = CreateConVar("sm_bladerunspeed", "1.25", "Define the speed multiplier");
}

//This function is called whenever a player joins the server
public void OnClientPutInServer(int client) {
	//Check if the plugin is running in generic mode
	if (GameConfig == GENERIC) {
		//Call ScanWeapons function when a player switches their weapon (This is only for the generic/universal mode)
		SDKHook(client, SDKHook_WeaponSwitchPost, ScanWeapons);
	}
}

public EventWeaponDeploy(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Find the player who just triggered this function and store them in a variable
	new pid = GetEventInt(event, "userid");
	new player = GetClientOfUserId(pid);
	//Call the main function
	ScanWeapons(player);
	
}

public ScanWeapons(int client) {	

	//Hook the created boolean variable to the convar
	AMS = GetConVarBool(h_AMS);
	//If the boolean value is true, execute the following commands
	if (AMS) {

		//Get the melee weapon from slot 2
		new knife = GetPlayerWeaponSlot(client, 2);
		//Create a variable to store the weapon name
		new String:knife_name[32];
		//Get the current active weapon
		new active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		new String:active_name[32];
		//Get the convar floating value
		new AMSV = GetConVarFloat(h_AMSV);
		
		//Get the weapon names and store them in the respective variable
		GetEdictClassname(knife, knife_name, sizeof(knife_name));
		GetEdictClassname(active, active_name, sizeof(active_name));
		
		//Check if the active weapon name is similar to the melee slot weapon
		if (StrEqual(knife_name, active_name)) {
			
			//Set the player speed
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", AMSV);
		}

		//If the if statement returns false, set the player value to default
		else SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
	}
	else SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
}