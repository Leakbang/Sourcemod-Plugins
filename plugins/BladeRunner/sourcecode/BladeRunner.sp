#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define GENERIC 0
#define CSGO 1
#define INS 2

new bool:AMS;

new Handle:h_AMS;
new Handle:h_AMSV;

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
	new String:Game[20];
	GetGameFolderName(Game, sizeof(Game));
	if (StrEqual(Game, "insurgency", false))
	{
		GameConfig = INS;
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

public void OnClientPutInServer(int client) {
	if (GameConfig == GENERIC) {
		SDKHook(client, SDKHook_WeaponSwitchPost, ScanWeapons);
	}
}

public EventWeaponDeploy(Handle:event, const String:name[], bool:dontBroadcast)
{
	new pid = GetEventInt(event, "userid");
	new player = GetClientOfUserId(pid);
	ScanWeapons(player);
	
}

public ScanWeapons(int client) {
	
	AMS = GetConVarBool(h_AMS);
	if (AMS) {
		
		new knife = GetPlayerWeaponSlot(client, 2);
		new String:knife_name[32];
		new active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		new String:active_name[32];
		new AMSV = GetConVarFloat(h_AMSV);
		
		GetEdictClassname(knife, knife_name, sizeof(knife_name));
		GetEdictClassname(active, active_name, sizeof(active_name));
		
		if (StrEqual(knife_name, active_name)) {
			
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", AMSV);
		}
		
		else SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
	}
	else SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
}