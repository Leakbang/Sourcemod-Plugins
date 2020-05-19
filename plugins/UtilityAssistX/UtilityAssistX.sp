#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>


new UA_ON[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Utility Assist X",
	author = PLUGIN_AUTHOR,
	description = "Utility Assist X For Practicing Effective Utility Usage",
	version = PLUGIN_VERSION,
	url = "https://github.com/Leakbang"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_utility", ToggleUA, "Toggles Utiltiy Assist");
	HookEvent("player_hurt", EventPlayerHurt);
	HookEvent("player_blind", EventPlayerBlind);
}

public Action ToggleUA(int client, int args)
{
	if (client == 0)
	{
		return Plugin_Handled;
	}
	
	if (args != 0)
	{
		ReplyToCommand(client, "Usage: sm_utility | Toggles Utiltiy Assist on and off.");
		return Plugin_Handled;
	}
	
	if (UA_ON[client] == 1)
	{
		UA_ON[client] = 0;
		PrintCenterText(client, "Utility Assist Toggled Off");
	}
	
	if (UA_ON[client] == 0)
	{
		UA_ON[client] = 1;
		PrintCenterText(client, "Utility Assist Toggled On");
	}
}

public EventPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:weapon_name[46];
	new String:target_name[100];
	
	new target = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new weapon = GetEventString(event, "weapon", weapon_name, sizeof(weapon_name));
	new DamageDone = GetEventInt(event, "dmg_health");
	
	new targetName = GetClientName(target, target_name, sizeof(target_name));
	if (StrEqual(weapon_name, "hegrenade"))
	{
		if (UA_ON[attacker] == 1)
		{
			PrintToChat(attacker,"Naded \x0A[%s] \x01for:\x07 %d \x01 damage", target_name, DamageDone);
		}
	}
}

public EventPlayerBlind(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:target_name[100];
	
	new target = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new flashduration = GetEventInt(event, "blind_duration");
	
	new targetName = GetClientName(target, target_name, sizeof(target_name));
	
	if (UA_ON[attacker] == 1)
	{
		PrintToChat(attacker, "Blinded \x0A [%s] \x01for\x04  %d seconds", target_name, flashduration);
	}
}