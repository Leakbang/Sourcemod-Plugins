#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Leakbang"
#define PLUGIN_VERSION "0.1"

#include <sourcemod>
#include <sdktools>

//Create boolean variables
new bool:RconLock;
new bool:DebugOn;

//Create new variables to store the server rcon password and the timer value in it
new ConVar:RconPass;
new ConVar:RegenTimer;

//Create variables to assign console variables to them
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
	RegenTimer = CreateConVar("sm_regentime", "5", "Set the time in seconds which the password is reset");
	//Hook the created boolean variables to the convars
	DebugOn = GetConVarBool(h_DebugOn);
	RconLock = GetConVarBool(h_RconLock);
	//Call the function when the convar value changed
	HookConVarChange(h_RconLock, OnConvarChange);
	//Call the LockRcon function
	LockRcon();
}

//This function is called when the convar value is changed
public OnConvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	LockRcon();
}

public LockRcon()
{
	//Check the boolean value if true execute the following command(s)
	if (RconLock)
	{
		//Call the RegenRcon function in 5 second intervals
		CreateTimer(RegenTimer, RegenRcon, _, TIMER_REPEAT);
	}
}

public Action RegenRcon(Handle timer)
{
	//Check once more if the boolean variable is true
	if (RconLock)
	{
		//Find the current rcon password and store it in the variable
		RconPass = FindConVar("rcon_password");
		//Find a random number between the given min and max amounts and assign it to the newly created variable
		new rng = GetRandomInt(10000, 99999);
		//Create a new variable to store the newly generated password
		new String:Pass_b[6];
		//Convert the password from integer to string format and store in in the variable
		IntToString(rng, Pass_b, sizeof(Pass_b));
		//Set the new rcon password
		RconPass.SetString(Pass_b);
		if (DebugOn)
		{
			//Send the password to the server console
			PrintToServer("[RconLock] Password: %s", Pass_b);
		}
	}
}