#pragma semicolon 1

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>

//Create boolean variable
new bool:maintenanceMode;

//Create a variable to assign a console variable to them
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
	//Call the function when the player has connected
	HookEvent("player_activate", EventPlayerActivate, EventHookMode_Pre);
	//Call the function when the convar value changed
	HookConVarChange(h_maintenanceMode, OnConvarChange);
}

//This function is called when the convar value is changed
public OnConvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ScanPlayers();
}

public ScanPlayers()
{
	//Hook the created boolean variable to the convar
	maintenanceMode = GetConVarBool(h_maintenanceMode);
	//Check if maintenance mode is activated
	if (maintenanceMode) {
		//Loop through all players
		for (new i = 1; i <= MaxClients; i++)
		{
			//If the player has root access, skip them
			if ((GetUserFlagBits(i) & ADMFLAG_ROOT))return Plugin_Continue;
			//If they don't kick them
			else KickClient(i, "Server is closed and is in maintenance mode, contact the server admin");
		}
	}
	
	return Plugin_Handled;
}

public EventPlayerActivate (Handle:event, const String:name[], bool:dontBroadcast)
{
	maintenanceMode = GetConVarBool(h_maintenanceMode);
	if (maintenanceMode) {
		//Find the player who just triggered this function and store them in a variable
		new player = GetClientOfUserId(GetEventInt(event, "userid"));
		//Check if client is connected
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
