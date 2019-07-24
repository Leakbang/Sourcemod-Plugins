#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "0.1"

#include <sourcemod>
#include <sdktools>

new bool:RconLock;
new bool:DebugOn;

new ConVar:RconPass;

new Handle:h_RconLock = INVALID_HANDLE;
new Handle:h_DebugOn = INVALID_HANDLE;

public Plugin myinfo = 
{
	name = "Rcon Lock",
	author = PLUGIN_AUTHOR,
	description = "Prevents unauthorized access to the remote console",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	h_RconLock = CreateConVar("sm_rconlock", "1", "Use values 1/0 to enable or disable the rcon lock on this server");
	h_DebugOn = CreateConVar("sm_enablercondebug", "0", "Use values 1/0 to enable debug messages on this server");
	DebugOn = GetConVarBool(h_DebugOn);
	RconLock = GetConVarBool(h_RconLock);
	HookConVarChange(h_RconLock, OnConvarChange);
	LockRcon();
}

public OnConvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	LockRcon();
}

public LockRcon()
{
	while (RconLock)
	{
		CreateTimer(5.0, RegenRcon, _, TIMER_REPEAT);
	}
}

public Action RegenRcon(Handle timer)
{
	RconPass = FindConVar("rcon_password");
	new rng = GetRandomInt(10000, 99999);
	new String:Pass_b[6];
	IntToString(rng, Pass_b, sizeof(Pass_b));
	RconPass.SetString(Pass_b);
	if (DebugOn)
	{
        PrintToServer("[RconLock] Password: %s", Pass_b);
	}
}