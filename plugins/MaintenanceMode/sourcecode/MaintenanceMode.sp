#pragma semicolon 1

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

new bool:maintenanceMode;

new Handle:h_maintenanceMode = INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "Maintenance mode",
	author = PLUGIN_AUTHOR,
	description = "Only allows admins with root access to join the server when enabled",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	h_maintenanceMode = CreateConVar("sm_enablemaintenancemode", "0", "Use values 1/0 to enable or disable maintenance mode on this server");
	HookEvent("player_activate", EventPlayerActivate, EventHookMode_Pre);
	HookConVarChange(h_maintenanceMode, OnConvarChange);
}

public OnConvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ScanPlayers();
}

public ScanPlayers()
{
	maintenanceMode = GetConVarBool(h_maintenanceMode);
	if (maintenanceMode) {
		for (new i = 1; i <= MaxClients; i++)
		{
			if ((GetUserFlagBits(i) & ADMFLAG_ROOT))return Plugin_Continue;
			else KickClient(i, "Server is closed and is in maintenance mode, contact the server admin");
		}
	}
	
	return Plugin_Handled;
}

public EventPlayerActivate (Handle:event, const String:name[], bool:dontBroadcast)
{
	maintenanceMode = GetConVarBool(h_maintenanceMode);
	if (maintenanceMode) {
		new player = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(player)) {
			if ((GetUserFlagBits(player) & ADMFLAG_ROOT)) {
				return Plugin_Handled;
			}
			else {
				KickClient(player, "Server is closed and is in maintenance mode, contact the server admin");
			}
		}
	}
	
	return Plugin_Continue;
}
