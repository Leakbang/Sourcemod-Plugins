#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "0.5"

#include <sourcemod>
#include <sdktools>

new RedON[MAXPLAYERS + 1];

#define NOT_SUPPORTED 0
#define CSGO 1
#define INS 2

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
	new String:Game[20];
	GetGameFolderName(Game, sizeof(Game));
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
	RegAdminCmd("sm_red", MarkRed, ADMFLAG_CHEATS, "Remvoes player weapons");
	RegAdminCmd("sm_blu", MarkBlu, ADMFLAG_CHEATS, "Adds player weapons back");
	HookEvent("weapon_deploy", EventWeaponDisarm, EventHookMode_Pre);
	HookEvent("weapon_fire", EventWeaponDisarm, EventHookMode_Pre);
	LoadTranslations("disarm.phrases");
}

public bool:isValidPlayer(playerId)
{
	return (( playerId > 0 ) && ( playerId <= GetMaxClients()) && IsClientInGame(playerId) && !IsFakeClient(playerId));
}

public Action MarkRed(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "Usage: sm_red <name>");
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

public EventWeaponDisarm(Handle:event, const String:name[], bool:dontBroadcast)
{
	new pid = GetEventInt(event, "userid");
	new player = GetClientOfUserId(pid);
	if (RedON[player] == 1)
	{
		Disarm(player);
	}
}

public Action:Disarm(client) {
	if (!isValidPlayer(client)) { return Plugin_Continue; }
	
	if (GameConfig == INS) {
		
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
			if (!StrEqual(weapon_name, "weapon_m18") 		&&
				!StrEqual(weapon_name, "weapon_m84") 		&&
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
			if (StrEqual(weapon_name, "weapon_flashbang") 		&&
				StrEqual(weapon_name, "weapon_hegrenade") 		&&
				StrEqual(weapon_name, "weapon_incgrenade") 		&&
				StrEqual(weapon_name, "weapon_molotov") 		&&
				StrEqual(weapon_name, "weapon_taser"))
				{
					RemovePlayerItem(client, active);
					AcceptEntityInput(active, "kill");
				}
		}
	}
	
	return Plugin_Continue;
}