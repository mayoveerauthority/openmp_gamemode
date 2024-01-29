#define		STREAMER_ENABLE_TAGS

#include	<open.mp>
#include	<sscanf2>

#include	<streamer>
#include	<Pawn.CMD>

forward OnPlayerJoin(playerid, PLAYER_STATE:playerstate);
forward OnPlayerWorldAndCharacterUpdate(playerid, teamid, skinid);
forward OnPlayerInteriorAndVirtualWorldSync(playerid, interiorid, virtualworldid);

enum	//	Unsigned dialog enumerator
{
	DIALOG_NONE,
 	DIALOG_STATS,
	DIALOG_HELP,
 	DIALOG_COMMANDS,
  	DIALOG_CLIENT,
   	DIALOG_ABOUT,
	DIALOG_RULES
}

static
	PLAYER_STATE:	gPlayerState[MAX_PLAYERS];

static
	bool:	IsAdmin[MAX_PLAYERS];

static
	aPlayerState[10][22] = {
 		{"init"},
   		{"onfoot"},
	 	{"driver"},
   		{"passenger"},
	 	{"exit vehicle"},
   		{"enter as driver"},
	 	{"enter as passenger"},
   		{"wasted"},
	 	{"spawned"},
   		{"spectating"}
 };

static
	string:	gPlayerIp[MAX_PLAYERS][16],
	string:	gPlayerName[MAX_PLAYERS][21];

 static
 	gPlayerDialog[MAX_PLAYERS];

static
	WEAPON_SLOT:	gPlayerWeaponSlot[MAX_PLAYERS][12],
	WEAPON:	gPlayerWeapon[MAX_PLAYERS][12], gPlayerAmmo[MAX_PLAYERS][12];

static
	gPlayerInterior[MAX_PLAYERS], gPlayerVirtualWorld[MAX_PLAYERS];

static
	Float:	gPlayerArmour[MAX_PLAYERS],
 	Float:	gPlayerHealth[MAX_PLAYERS];

static
	gPlayerTeam[MAX_PLAYERS],
 	gPlayerSkin[MAX_PLAYERS];

static
	Float:	gPlayerPosX[MAX_PLAYERS],
 	Float:	gPlayerPosY[MAX_PLAYERS],
  	Float:	gPlayerPosZ[MAX_PLAYERS],
   	Float:	gPlayerAngle[MAX_PLAYERS];

static
	Float:	gPlayerLastPosX[MAX_PLAYERS],
 	Float:	gPlayerLastPosY[MAX_PLAYERS],
  	Float:	gPlayerLastPosZ[MAX_PLAYERS],
   	Float:	gPlayerLasAngle[MAX_PLAYER];

main()
{

}

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	gPlayerState[playerid] = GetPlayerState(playerid);

	gPlayerDialog[playerid] = INVALID_DIALOG_ID;

	gPlayerTeam[playerid] = NO_TEAM;
 	gPlayerSkin[playerid] = 74;

 	gPlayerInterior[playerid] = 0;
	gPlayerVirtualWorld[playerid] = 0;

	GetPlayerIp(playerid, gPlayerIp[playerid], sizeof(gPlayerIp));
	GetPlayerName(playerid, gPlayerName[playerid], sizeof(gPlayerName));
 	OnPlayerJoin(playerid, gPlayerState[playerid]);
 	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	static
 		string:	disconnect_reason[5][10] = {
		{"quit"},
  		{"timeout"},
		{"suspended"},
  		{"costum"},
		{"endgame"}
   	};

 	SendClientMessage(playerid, 0xFF0000FF, "%s has disconnected from the server. reason: %s", gPlayerName[playerid], disconnect_reason[reason]);
	gPlayerDialog[playerid] = INVALID_DIALOG_ID;
 	HidePlayerDialog(playerid);
	return 1;
}

public OnPlayerJoin(playerid, PLAYER_STATE:playerstate)
{
	OnPlayerInteriorAndVirtualWorldSync(playerid, gPlayerInterior[playerid], gPlayerVirtualWorld[playerid]);
	return playerstate;
}

public OnPlayerSpawn(playerid)
{
	if(gPlayerArmour[playerid] > 0)
 	{
		SetPlayerArmour(playerid, gPlayerArmour[playerid]);
  	}
	SetPlayerHealth(playerid, gPlayerHealth[playerid]);
	SetPlayerInterior(playerid, gPlayerInterior[playerid]);
 	SetPlayerVirtualWorld(playerid, gPlayerVirtualWorld[playerid]);
  	SetPlayerPos(playerid, gPlayerPosX[playerid], gPlayerPosY[playerid],  gPlayerPosZ[playerid]);
   	SetPlayerFacingAngle(playerid, gPlayerAngle[playerid]);
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, WEAPON:reason)
{
	gPlayerInterior[playerid] = GetPlayerInterior(playerid);
 	gPlayerVirtualWorld[playerid] = GetPlayerVirtualWorld(playerid);
	gPlayerTeam[playerid] = GetPlayerTeam(playerid);
 	gPlayerSkin[playerid] = GetPlayerSkin(playerid);
	GetPlayerPos(playerid, gPlayerLastPosX[playerid], gPlayerLastPosY[playerid], gPlayerLastPosZ[playerid]);
 	GetPlayerFacingAngle(playerid, gPlayerLastAngle[playerid]);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	gPlayerState[playerid] = GetPlayerState(playerid);

	for(new weaponslot = 0; weaponslot < 14; weaponslot++)
 	{
		gPlayerWeaponSlot[playerid][weaponslot] = GetWeaponSlot(gPlayerWeapon[playerid][weaponslot]);
  		GetPlayerWeaponData(playerid, gPlayerWeaponSlot[playerid][weaponslot], gPlayerWeapon[playerid][weaponslot], gPlayerAmmo[playerid][weaponslot]);
	}
 
	if(gPlayerState[playerid] == PLAYER_STATE_NONE)
 	{
		SetSpawnInfo(playerid, gPlayerTeam[playerid], gPlayerSkin[playerid], gPlayerPosX[playerid], gPlayerPosY[playerid], gPlayerPosZ[playerid], gPlayerAngle[playerid], gPlayerWeapon[playerid][0], gPlayerAmmo[playerid][0], gPlayerWeapon[playerid][1], gPlayerAmmo[playerid][1], gPlayerWeapon[playerid][2], gPlayerAmmo[playerid][2]); 
  	}
   	else if(gPlayerState[playerid] == PLAYER_STATE_WASTED)
	{
		SetSpawnInfo(playerid, gPlayerTeam[playerid], gPlayerSkin[playerid], gPlayerLastPosX[playerid], gPlayerLastPosY[playerid], gPlayerLastPosZ[playerid], gPlayerLastAngle[playerid], gPlayerWeapon[playerid][0], gPlayerAmmo[playerid][0], gPlayerWeapon[playerid][1], gPlayerAmmo[playerid][1], gPlayerWeapon[playerid][2], gPlayerAmmo[playerid][2]); 
 	}
	else if(gPlayerState[playerid] == PLAYER_STATE_SPECTATING)
 	{
		SetSpawnInfo(playerid, gPlayerTeam[playerid], gPlayerSkin[playerid], gPlayerLastPosX[playerid], gPlayerLastPosY[playerid], gPlayerLastPosZ[playerid], gPlayerLastAngle[playerid], gPlayerWeapon[playerid][0], gPlayerAmmo[playerid][0], gPlayerWeapon[playerid][1], gPlayerAmmo[playerid][1], gPlayerWeapon[playerid][2], gPlayerAmmo[playerid][2]);
  	}
	SpawnPlayer(playerid);
 	SendClientMessage(playerid, 0xFF0000FF, "%s", aPlayerState[gPlayerState[playerid]]);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	gPlayerState[playerid] = GetPlayerState(playerid);
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{

}

public OnPlayerKeyStateChange(playerid, KEYS:newkeys, KEYS:oldkeys)
{

}

public OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
{
	new
 		vehicleid = GetPlayerVehicleID(playerid);
   	GetVehicleModel(vehicleid);
	gPlayerState[playerid] = GetPlayerState(playerid);

	if(newstate == PLAYER_STATE_SPAWNED && oldstate == PLAYER_STATE_NONE) {
		gPlayerArmour[playerid] = 0;
  		gPlayerHealth[playerid] = 100;

 		if(gPlayerSkin[playerid] == 74)
   		{
			gPlayerSkin[playerid] = random(311);
  		}

 		gPlayerSkin[playerid] = random(311);
  	} else if(newstata == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_SPAWNED) {

   	} else if((newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT) || (newstate == PLAYER_STATE_PASSENGER && oldstate == PLAYER_STATE_ONFOOT)) {

 	} else if((newstate == PLAYER_STATE_WASTED && oldstate == PLAYER_STATE_DRIVER) || (newstate == PLAYER_STATE_WASTED && oldstate == PLAYER_STATE_PASSENGER)) {

  	} else if((newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER) || (newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_PASSENGER)) {

 	}
  	SendClientMessage(playerid, 0xFF0000FF, "newstate: {ffffff}%s {ff0000}and oldstate: {ffffff}%s", aPlayerState[newstate], aPlayerState[oldstate]);
	return gPlayerState[playerid];
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(gPlayerDialog[playerid])
 	{
  		case DIALOG_NONE: return 1;
		default: return gPlayerDialog[playerid];
  	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, CLICK_SOURCE:source)
{
	static
 		string:	internal_params[128] = EOS;

	if(source == CLICK_SOURCE_SCOREBOARD)
 	{
  		if(playerid == clickedplayerid)
		{

  		}
		else
  		{

 		}
		return 1;
  	}
	return 0;
}

public OnPlayerUpdate(playerid)
{
	CallLocalFunction("OnPlayerWorldAndCharacterUpdate", "ddd", playerid, gPlayerTeam[playerid], gPlayerSkin[playerid])
	return 1;
}

public OnPlayerWorldAndCharacterUpdate(playerid, teamid, skinid)
{

}

new v_id;
new 
	VEHICLE_PARAMS: v_engine,
 	VEHICLE_PARAMS: v_lights,
  	VEHICLE_PARAMS:	v_alarm,
   	VEHICLE_PARAMS: v_doors,
	VEHICLE_PARAMS: v_boot,
 	VEHICLE_PARAMS:	v_bonnet,
  	VEHICLE_PARAMS:	v_objective;

CMD:engine(playerid, params[])
{
	v_id = GetPlayerVehicleID(playerid);
 	GetVehicleModel(v_id);

  	GetVehicleParamsEx(v_id, v_engine, v_lights, v_alarm, v_doors, v_boot, v_bonnet, v_objective);
	return 1;
}

CMD:lights(playerid, params[])
{
	v_id = GetPlayerVehicleID(playerid);
 	GetVehicleModel(v_id);

	GetVehicleParamsEx(v_id, v_engine, v_lights, v_alarm, v_doors, v_boot, v_bonnet, v_objective);
	return 1;
}

CMD:hood(playerid, params[])
{
	v_id = GetPlayerVehicleID(playerid);
 	GetVehicleModel(v_id);

	GetVehicleParamsEx(v_id, v_engine, v_lights, v_alarm, v_doors, v_boot, v_bonnet, v_objective);
	return 1;
}

CMD:trunk(playerid, params[])
{
	v_id = GetPlayerVehicleID(playerid);
 	GetVehicleModel(v_id);

	GetVehicleParamsEx(v_id, v_engine, v_lights, v_alarm, v_doors, v_boot, v_bonnet, v_objective);
	return 1;
}

CMD:stats(playerid, params[])
{
	new targetid = INVALID_PLAYER_ID;
 	if(sscanf(params, "u", targetid)) {

  	} else { 
   		if(!IsPlayerConnected(targetid)  || targetid == INVALID_PLAYER_ID) {

  		} else if(playerid == targetid) {

 		}
	}

	gPlayerState[playerid] = GetPlayerState(playerid);

 	gPlayerDialog[playerid] = DIALOG_STATS;
	ShowPlayerDialog(playerid, gPlayerDialog[playerid], DIALOG_STYLE_MSGBOX, "Stats", "Player Interior: %d", "Next", "Cancel", gPlayerInterior[playerid]);
	return 1;
}
