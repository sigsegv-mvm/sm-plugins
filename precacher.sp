#include <sourcemod>
#include <halflife>


public Plugin myinfo = {
	name        = "precache",
	author      = "sigsegv",
	description = "Precacher",
	version     = "20170430-1",
	url         = "https://github.com/sigsegv-mvm/sm-plugins",
};


public Action CC_PrecacheModel(int client, int args)
{
	if (args < 1) {
		ReplyToCommand(client, "Usage: precache_model <models/x/y/z.mdl>");
		return Plugin_Handled;
	}
	
	char path[PLATFORM_MAX_PATH];
	GetCmdArg(1, path, sizeof(path));
	
	if (PrecacheModel(path, false) != 0) {
		ReplyToCommand(client, "PrecacheModel(\"%s\", false): success", path);
		return Plugin_Handled;
	} else {
		ReplyToCommand(client, "PrecacheModel(\"%s\", false): failure", path);
		return Plugin_Handled;
	}
}

public Action CC_PreloadModel(int client, int args)
{
	if (args < 1) {
		ReplyToCommand(client, "Usage: preload_model <models/x/y/z.mdl>");
		return Plugin_Handled;
	}
	
	char path[PLATFORM_MAX_PATH];
	GetCmdArg(1, path, sizeof(path));
	
	if (PrecacheModel(path, true) != 0) {
		ReplyToCommand(client, "PrecacheModel(\"%s\", true): success", path);
		return Plugin_Handled;
	} else {
		ReplyToCommand(client, "PrecacheModel(\"%s\", true): failure", path);
		return Plugin_Handled;
	}
}


public void OnPluginStart()
{
	RegAdminCmd("precache_model", CC_PrecacheModel, ADMFLAG_CHEATS, "precache_model <models/x/y/z.mdl>");
	RegAdminCmd("preload_model",  CC_PreloadModel,  ADMFLAG_CHEATS, "preload_model <models/x/y/z.mdl>");
}
