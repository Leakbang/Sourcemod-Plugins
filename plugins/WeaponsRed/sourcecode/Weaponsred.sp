#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "0.5"

#include <sourcemod>
#include <sdktools>

//Create a variable for each player
new RedON[MAXPLAYERS + 1];

//Define variables to represent a number (For game detection system)
#define NOT_SUPPORTED 0
#define CSGO 1
#define INS 2

//Create a variable and assign a value to it
new GameConfig = NOT_SUPPORTED;

public Plugin myinfo = 
{
	name = "Disarm",
	author = PLUGIN_AUTHOR,
	description = "Allows admins to disallow players from using firearms",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	//Create a variable to store the game folder in it
	new String:Game[20];
	//find the game folder name and store it in the variable
	GetGameFolderName(Game, sizeof(Game));
	//Run if checks to find out what game the client is running and store the data in a variable
	if (StrEqual(Game, "insurgency", false))
	{
		GameConfig = INS;
		PrintToServer("[DISARM] Game detected as: Insurgency");
	}
	else if (StrEqual(Game, "csgo", false))
	{
		GameConfig = CSGO;
		PrintToServer("[DISARM] Game detected as: CSGO");
	}
	else
	{
		GameConfig = NOT_SUPPORTED;
		PrintToServer("[DISARM] Invalid game detected: %s", Game);
		PrintToServer("[DISARM] This plugin is not supported for your game, Contact Leakbang!");
	}
	RegAdminCmd("sm_red", MarkRed, ADMFLAG_CHEATS, "Removes player weapons");
	RegAdminCmd("sm_blu", MarkBlu, ADMFLAG_CHEATS, "Adds player weapons back");
	//Call the function when someone equips or shoots their weapons
	HookEvent("weapon_deploy", EventWeaponDisarm, EventHookMode_Pre);
	HookEvent("weapon_fire", EventWeaponDisarm, EventHookMode_Pre);
	//Load the translation file for some chat messages
	LoadTranslations("disarm.phrases");
}

//Thanks to red! for the isValidPlayer snippet
public bool:isValidPlayer(playerId)
{
	return (( playerId > 0 ) && ( playerId <= GetMaxClients()) && IsClientInGame(playerId) && !IsFakeClient(playerId));
}

//This function marks players to be stripped
public Action MarkRed(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_red <name>");
		return Plugin_Handled;
	}
	//Standard way to target players in sourcepawn
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		//Mark every target as Red so they can be stripped later on
		RedON[i] = 1;
	}
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Disarmed", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Disarmed", "_s", target_name);
	}
	return Plugin_Handled;
}

//This function removes the red mark from players and so won't be stripped anymore. This is a direct counter to the MarkRed function
public Action MarkBlu(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_blu <name>");
		return Plugin_Handled;
	}
	new String: target_name[MAX_TARGET_LENGTH],
		String: buffer[64],
		target_list[MAXPLAYERS],
		bool: tn_is_ml,
		target_count;
	GetCmdArg(1, buffer, sizeof(buffer));
	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		RedON[i] = 0;
	}
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] ", "%t", "Armed", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] ", "%t", "Armed", "_s", target_name);
	}
	return Plugin_Handled;
}

//This function is called whenever someone shoots or equips their weapon 
public EventWeaponDisarm(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Find the player who just triggered this function and store them in a variable
	new pid = GetEventInt(event, "userid");
	new player = GetClientOfUserId(pid);
	//Check if the player has been marked as red, then disarm them
	if (RedON[player] == 1)
	{
		Disarm(player);
	}
}

//Disarming function
public Action:Disarm(client) {
	//Check if the targeted player is a valid client
	if (!isValidPlayer(client)) { return Plugin_Continue; }
	
	//Check what game the plugin is being ran on and execute commands accordingly
	if (GameConfig == INS) {
		
		//Get the primary weapon from slot 0
		new primary = GetPlayerWeaponSlot(client, 0);
		//If the primary weapon exists and qualifies as a valid object, remove it
		if (IsValidEntity(primary)) { 
			RemovePlayerItem(client, primary);
			AcceptEntityInput(primary, "kill");
		}
		new secondary = GetPlayerWeaponSlot(client, 1);
		if (IsValidEntity(secondary)) {
			RemovePlayerItem(client, secondary);
			AcceptEntityInput(secondary, "kill");
		}
		
		//Get the current active weapon
		new active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if (IsValidEntity(active)) {
			new String:weapon_name[32];
			GetEdictClassname(active, weapon_name, sizeof(weapon_name));
			//Check the weapon name and if it didn't match any of these names, remove it
			if (!StrEqual(weapon_name, "weapon_m18") 		&&
				!StrEqual(weapon_name, "weapon_kabar") 		&&
				!StrEqual(weapon_name, "weapon_gurkha"))
				{
					RemovePlayerItem(client, active);
					AcceptEntityInput(active, "kill");
				}
		}
	}
	
	if (GameConfig == CSGO) {
		new primary = GetPlayerWeaponSlot(client, 0);
		if (IsValidEntity(primary)) { 
			RemovePlayerItem(client, primary);
			AcceptEntityInput(primary, "kill");
		}
		new secondary = GetPlayerWeaponSlot(client, 1);
		if (IsValidEntity(secondary)) {
			RemovePlayerItem(client, secondary);
			AcceptEntityInput(secondary, "kill");
		}
		
		new active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if (IsValidEntity(active)) {
			new String:weapon_name[32];
			GetEdictClassname(active, weapon_name, sizeof(weapon_name));
			//Same as above except check if the weapon name matches any of these names, remove it
			if (StrEqual(weapon_name, "weapon_flashbang") 		||
				StrEqual(weapon_name, "weapon_hegrenade") 		||
				StrEqual(weapon_name, "weapon_incgrenade") 		||
				StrEqual(weapon_name, "weapon_molotov") 		||
				StrEqual(weapon_name, "weapon_taser"))
				{
					RemovePlayerItem(client, active);
					AcceptEntityInput(active, "kill");
				}
		}
	}
	
	return Plugin_Continue;
}