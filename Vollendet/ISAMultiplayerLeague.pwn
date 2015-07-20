/*###########################################################################################
	Copyright (C) 2015 Nicolas Giese
	Contact for licensing only: http://goo.gl/hKGHFx

	This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	
	This work is licensed under a Creative Commons 
	Attribution-NonCommercial-ShareAlike 4.0 International License.
	You should have received a copy of the License
    along with this program. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
###########################################################################################*/

#include <a_samp>
#include <SII>
#include <mysql>

#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA

#define slots 52

new WepNames[46][128];
//namen unter ongamemodeinit


new VehicleNames[212][] = {
{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
{"Utility Trailer"}
};

enum plopti
{
	Float:racer,
	racew,
	racelo,
	Float:dmratio,
	dmwins,
	dmlosses,
	rck
}

new pl_stats[slots][plopti];
enum challengeopti
{
	track,
	targetperson,
	active,
	challenger,
	tempo1,
	tempo2,
	tempo3[128]
}
new ch2[challengeopti][slots];
enum recopti
{
	name[256],
	Float:time
}
new global_records[10][recopti];
enum lobbiopti
{
	inside,
	challenge
}
new lobbi[slots][lobbiopti];
enum dmopti
{
	valid,
	Float:spx,
	Float:spy,
	Float:spz,
	weapon
}
new global_dm[10][dmopti];
enum opti
{
	Float:startx,
	Float:starty,
	Float:startz,
	Float:startrot,
	Float:startx2,
	Float:starty2,
	Float:startz2,
	Float:startrot2,
	car,
	Float:zielx,
	Float:ziely,
	Float:zielz,
	valid
}
new global_tracks[10][opti]; // [strecken]
new Text:classinfo[slots],txt_info[slots][128],formme[64],countdown2[slots],countdown[slots],formal[slots][128];
new pickup_marker[slots][2],chosentrack[slots],veh[slots],inrace[slots],Text:trackrecord[slots];
new Float:playertime[slots],ClickedPlayerID[slots],debugval,pl_skin[slots],Float:DirX,Float:DirY,Float:DirZ;
new lobbypickups[10],Text3D:lobbytext[10],tempobjects[20],hdwid[slots][128],loggedin[slots];
new clientstart[slots],clientstart2[slots],Text:advert[slots],Text:priceinfo[slots],advertcount;
new adslogan[128],adduration,pricestring[128],otherpl[slots],gangzone,mysqlquery[slots][128],plrIP[slots][16],file_name[slots][128];
new objs[1],lastskin[slots],rlhdwid[slots][128];

forward racestart(playerid); //challenge1
forward racestart2(playerid); //challenge2
forward debugline();
forward upkeepconnection(playerid);
forward refreshadvert();
forward globaltime();
forward afkcheck(playerid);
forward junk_ban(playerid);

main()
{
	print("\n----------------------------------");
	print(" ((1st International SAMP League GM v2)) loaded");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("ISA - MP League");
	SendRconCommand("mapname (c) Nicksoft");
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	AllowInteriorWeapons(0);
	DisableInteriorEnterExits();
	SetTimer("refreshadvert",15000,0);
	SetTimer("globaltime",60000*5,0);
	mysql_connect("xxx", "xxx", "xxx", "xxx");
	gangzone = GangZoneCreate(-101.2526,1599.8019,366.2648,2094.6494);
	
	objs[0] = CreateObject(18249, 2386.1145019531, 2693.5847167969, 16.754724502563, 0, 0, 270.67565917969);
	
	//wepnames
	format(WepNames[24],128,"Desert Eagle");
	format(WepNames[25],128,"Shotgun");
	format(WepNames[28],128,"Micro SMG");
	format(WepNames[29],128,"SMG");
	format(WepNames[31],128,"M4");
	format(WepNames[26],128,"Sawn-off Shotgun");
	format(WepNames[24],128,"Desert Eagle");
	format(WepNames[30],128,"AK47");
	
	//lobby1
	lobbypickups[0] = CreatePickup(1318,23,-2158.7444,642.9451,1052.3750);
	lobbytext[0] = Create3DTextLabel("Enter Lobby 2",COLOR_GREEN,-2158.7444,642.9451,1052.3750,20,0,1);
	lobbypickups[1] = CreatePickup(1318,23,-2171.3052,645.3322,1057.5938);
	lobbytext[1] = Create3DTextLabel("Enter Lobby 3",COLOR_GREEN,-2171.3052,645.3322,1057.5938,20,0,1);
	//lobby2
	lobbypickups[2] = CreatePickup(1318,23,1700.9673,-1668.0292,20.2188);
	lobbytext[2] = Create3DTextLabel("Enter Lobby 3",COLOR_GREEN,1700.9673,-1668.0292,20.2188,20,0,1);
	lobbypickups[3] = CreatePickup(1318,23,1727.0367,-1640.8877,20.2244);
	lobbytext[3] = Create3DTextLabel("Enter Lobby 1",COLOR_GREEN,1727.0367,-1640.8877,20.2244,20,0,1);
	//lobby3
	lobbypickups[4] = CreatePickup(1318,23,1251.7047,-789.2800,1084.0078);
	lobbytext[4] = Create3DTextLabel("Enter Lobby 2",COLOR_GREEN,1251.7047,-789.2800,1084.0078,20,0,1);
	lobbypickups[5] = CreatePickup(1318,23,1280.2421,-789.1942,1084.0078);
	lobbytext[5] = Create3DTextLabel("Enter Lobby 1",COLOR_GREEN,1280.2421,-789.1942,1084.0078,20,0,1);
	
	tempobjects[1] = CreateObject(16662, 1932.2740,-2409.6987,1200.6908, 0.0, 0.0, -27.0);
	tempobjects[2] = CreateObject(3983, 1930.715088, -2417.489990, 1201.556519, 0.0000, 0.0000, 0.0000);
	tempobjects[3] = CreateObject(3983, 1938.750122, -2419.424561, 1201.557129, 0.0000, 268.0403, 0.0000);
	tempobjects[4] = CreateObject(3983, 1922.684082, -2417.233643, 1201.763428, 0.0000, 96.1526, 9.4538);
	tempobjects[5] = CreateObject(3983, 1932.634888, -2426.096436, 1201.592285, 0.0000, 96.1526, 98.8352);
	tempobjects[6] = CreateObject(3983, 1934.155273, -2406.747803, 1201.625122, 0.0000, 254.1853, 98.8352);
	tempobjects[7] = CreateObject(3983, 1938.325562, -2415.805176, 1216.350342, 359.1406, 179.4143, 95.3974);
	tempobjects[8] = CreateObject(1232, 1934.736694, -2413.839844, 1202.169678, 0.0000, 0.0000, 0.0000);
	tempobjects[9] = CreateObject(1232, 1935.306519, -2421.486816, 1202.169678, 0.0000, 0.0000, 0.0000);
	tempobjects[10] = CreateObject(1232, 1928.441406, -2421.002441, 1202.218506, 0.0000, 0.0000, 0.0000);
	tempobjects[11] = CreateObject(1232, 1927.940186, -2413.950928, 1202.244629, 0.0000, 0.0000, 0.0000);
	tempobjects[12] = CreateObject(1232, 1922.012695, -2430.574951, 1202.355225, 0.0000, 53.2850, 55.8633);
	tempobjects[13] = CreateObject(1232, 1942.271362, -2427.741211, 1201.987061, 0.0000, 53.2850, 138.3693);
	tempobjects[14] = CreateObject(1232, 1941.111938, -2403.214844, 1201.988281, 0.0000, 53.2850, 237.2046);
	tempobjects[15] = CreateObject(1232, 1918.437500, -2406.737793, 1201.562622, 0.0000, 53.2850, 321.4290);
	
	//das drunter kann man auch um einiges ressourcensparender machen... wird aber eh nur 1x aufgerufen
	INI_Open("defdm.ini");
	for(new gettr=0;gettr<=10;gettr++)
	{
	    format(formme,64,"index-%d",gettr);
	    if(INI_ReadInt(formme))
	    {
	        global_dm[gettr][valid] = 1;
	        format(formme,64,"startx-%d",gettr);
			global_dm[gettr][spx] = INI_ReadFloat(formme);
			format(formme,64,"starty-%d",gettr);
			global_dm[gettr][spy] = INI_ReadFloat(formme);
			format(formme,64,"startz-%d",gettr);
			global_dm[gettr][spz] = INI_ReadFloat(formme);
	        format(formme,64,"wep-%d",gettr);
			global_dm[gettr][weapon] = INI_ReadInt(formme);
		}
	}
	INI_Close();
	
	INI_Open("deftracks.ini");
	for(new gettr=0;gettr<=10;gettr++)
	{
	    format(formme,64,"index-%d",gettr);
	    if(INI_ReadInt(formme))
	    {
	        global_tracks[gettr][valid] = 1;
			AddPlayerClass(gettr, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
			
			format(formme,64,"startx-%d",gettr);
			global_tracks[gettr][startx] = INI_ReadFloat(formme);
			format(formme,64,"starty-%d",gettr);
			global_tracks[gettr][starty] = INI_ReadFloat(formme);
			format(formme,64,"startz-%d",gettr);
			global_tracks[gettr][startz] = INI_ReadFloat(formme);
			format(formme,64,"startrot-%d",gettr);
			global_tracks[gettr][startrot] = INI_ReadFloat(formme);
			
			format(formme,64,"startx2-%d",gettr);
			global_tracks[gettr][startx2] = INI_ReadFloat(formme);
			format(formme,64,"starty2-%d",gettr);
			global_tracks[gettr][starty2] = INI_ReadFloat(formme);
			format(formme,64,"startz2-%d",gettr);
			global_tracks[gettr][startz2] = INI_ReadFloat(formme);
			format(formme,64,"startrot2-%d",gettr);
			global_tracks[gettr][startrot2] = INI_ReadFloat(formme);
			
			format(formme,64,"car-%d",gettr);
			global_tracks[gettr][car] = INI_ReadInt(formme);
			format(formme,64,"zielx-%d",gettr);
			global_tracks[gettr][zielx] = INI_ReadFloat(formme);
			format(formme,64,"ziely-%d",gettr);
			global_tracks[gettr][ziely] = INI_ReadFloat(formme);
			format(formme,64,"zielz-%d",gettr);
			global_tracks[gettr][zielz] = INI_ReadFloat(formme);
		}
 	}
 	INI_Close();
 	
 	INI_Open("defrecords.ini");
	for(new gettr=0;gettr<=10;gettr++)
	{
	    if(global_tracks[gettr][valid] == 1)
	    {
			format(formme,64,"%d-time",gettr);
			global_records[gettr][time] = INI_ReadFloat(formme);
			format(formme,64,"%d-name",gettr);
			INI_ReadString(global_records[gettr][name],formme,128);
		}
 	}
 	INI_Close();
 	
 	for(new rec=0;rec!=GetMaxPlayers();rec++)
 	{
 	    if(IsPlayerConnected(rec)) OnPlayerConnect(rec);
 	}
 	
  	return 1;
}

public globaltime()
{
    SetTimer("globaltime",60000*5,0);
	new ti[3];
	gettime(ti[0],ti[1],ti[2]);
	SetWorldTime(ti[0]+3);
	new nodrop[256];
	format(nodrop,256,"UPDATE nodrop SET value = '%s' WHERE enta = '1'",random(100));
	mysql_query(nodrop);
	return 1;
}

public OnGameModeExit()
{
	print("Server restarts");
	GangZoneDestroy(gangzone);
	mysql_close();
	for(new dt=0;dt!=sizeof(objs);dt++)
	{
	    if(IsValidObject(objs[dt])) DestroyObject(objs[dt]);
	}
	for(new kck=0;kck<=slots;kck++)
	{
	    ShowPlayerDialog(kck,23,DIALOG_STYLE_MSGBOX,"Server has been restarted","The ISA-MPL Server has been restarted\nWe are sorry for any circumstances,\nbut from time to time we need to restart this server,\nfor example for updates and bugfixes","Ok"," ");
	}
	for(new dest=0;dest<=sizeof(lobbypickups);dest++)
	{
		DestroyPickup(lobbypickups[dest]);
		Delete3DTextLabel(lobbytext[dest]);
	}
    for(new dest2=0;dest2<=sizeof(tempobjects);dest2++) DestroyObject(tempobjects[dest2]);
	return 1;
}

public junk_ban(playerid)
{
	format(mysqlquery[playerid],256,"insert into banlg (hdwid,rly) values('%s',1)",rlhdwid[playerid]);
	mysql_query(mysqlquery[playerid]);
	
	printf("Banned player with hdwid %s",rlhdwid[playerid]);
	TogglePlayerControllable(playerid,0);
	ShowPlayerDialog(playerid,992,0,"You got banned","You got banned for cheating","Dawn"," ");
	BanEx(playerid,"Banned from an Administrator");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(loggedin[playerid] == 0) return 0;
	if(lobbi[playerid][inside] == 0 || lobbi[playerid][challenge] == 0)
	{
	    if(pl_skin[playerid] == 288) pl_skin[playerid] = 0;
	    if(classid != lastskin[playerid]+1) pl_skin[playerid] -= 1;
	    else pl_skin[playerid] += 1;
	    lastskin[playerid] = classid;
	    SetPlayerSkin(playerid,pl_skin[playerid]);
	    SetPlayerPos(playerid, -1820.4644,-149.4375,9.3984);
		SetPlayerFacingAngle(playerid,182.8881);
		SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
	    return 1;
	}
	if(lobbi[playerid][inside] == 1 && lobbi[playerid][challenge] == 1)
	{
		inrace[playerid] = 0;
		SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);

		if(global_tracks[classid][valid] == 0)
		{
		    for(new nextone=classid;nextone<=10;nextone++)
		    {
		        if(global_tracks[nextone][valid] == 1)
		        {
		            classid = nextone;
		            break;
				}
		    }
		}
		TextDrawHideForPlayer(playerid,trackrecord[playerid]);
		TextDrawShowForPlayer(playerid,classinfo[playerid]);
		format(txt_info[playerid],128,"Race Track ~r~%d~w~ ~n~~n~Vehicle : %s~n~Record : ~r~%.1f~w~ seconds~n~Record by ~r~%s~w~~n~ ",classid+1,VehicleNames[global_tracks[classid][car]-400],global_records[classid][time],global_records[classid][name]);
		TextDrawSetString(classinfo[playerid],txt_info[playerid]);

		DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);
		
		//Credits to Luby & Gamer_Z
		
		DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;
	 	
		DirX = floatadd(DirX, floatmul(floatdiv(global_tracks[classid][startx], 3000.0), 1.4062)); //1.7062
	    DirY = floatadd(DirY, floatmul(floatdiv(global_tracks[classid][starty], 3000.0), 1.3577)); //1.7577
	    DirZ = floatadd(DirZ, floatmul(33.0107, 0.045));
	    pickup_marker[playerid][0] = CreatePlayerObject(playerid,1510,DirX,DirY,DirZ,0,0,0);

	    DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;
		DirX = floatadd(DirX, floatmul(floatdiv(global_tracks[classid][zielx], 3000.0), 1.4062));
	    DirY = floatadd(DirY, floatmul(floatdiv(global_tracks[classid][ziely], 3000.0), 1.3577));
	    DirZ = floatadd(DirZ, floatmul(33.0107, 0.045));
	    pickup_marker[playerid][1] = CreatePlayerObject(playerid,1510,DirX,DirY,DirZ,0,0,0);

		chosentrack[playerid] = classid;
    	return 1;
	}
	
	if(lobbi[playerid][inside] == 1 && lobbi[playerid][challenge] == 2)
	{
		inrace[playerid] = 0;
		SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);

		if(global_tracks[classid][valid] == 0)
		{
		    for(new nextone=classid;nextone<=10;nextone++)
		    {
		        if(global_tracks[nextone][valid] == 1)
		        {
		            classid = nextone;
		            break;
				}
		    }
		}
		TextDrawHideForPlayer(playerid,trackrecord[playerid]);
		TextDrawShowForPlayer(playerid,classinfo[playerid]);
		format(txt_info[playerid],128,"Race Track ~r~%d~w~ ~n~~n~Vehicle : %s~n~Record : ~r~%.1f~w~ seconds~n~Record by ~r~%s~w~~n~ ",classid+1,VehicleNames[global_tracks[classid][car]-400],global_records[classid][time],global_records[classid][name]);
		TextDrawSetString(classinfo[playerid],txt_info[playerid]);

		DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);

		//Credits to Luby & Gamer_Z

		DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;

		DirX = floatadd(DirX, floatmul(floatdiv(global_tracks[classid][startx], 3000.0), 1.4062)); //1.7062
	    DirY = floatadd(DirY, floatmul(floatdiv(global_tracks[classid][starty], 3000.0), 1.3577)); //1.7577
	    DirZ = floatadd(DirZ, floatmul(33.0107, 0.045));
	    pickup_marker[playerid][0] = CreatePlayerObject(playerid,1510,DirX,DirY,DirZ,0,0,0);

	    DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;
		DirX = floatadd(DirX, floatmul(floatdiv(global_tracks[classid][zielx], 3000.0), 1.4062));
	    DirY = floatadd(DirY, floatmul(floatdiv(global_tracks[classid][ziely], 3000.0), 1.3577));
	    DirZ = floatadd(DirZ, floatmul(33.0107, 0.045));
	    pickup_marker[playerid][1] = CreatePlayerObject(playerid,1510,DirX,DirY,DirZ,0,0,0);

		chosentrack[playerid] = classid;
    	return 1;
	}
	
	if(lobbi[playerid][inside] == 1 && lobbi[playerid][challenge] == 3)
	{
		SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);

		if(global_dm[classid][valid] == 0)
		{
		    for(new nextone=classid;nextone<=10;nextone++)
		    {
		        if(global_dm[nextone][valid] == 1)
		        {
		            classid = nextone;
		            break;
				}
		    }
		}
		TextDrawHideForPlayer(playerid,trackrecord[playerid]);
		TextDrawShowForPlayer(playerid,classinfo[playerid]);
		format(txt_info[playerid],128,"Spot ~r~#%d~w~ ~n~~n~Weapon : ~g~%s~w~~n~ ",classid+1,WepNames[global_dm[classid][weapon]]);
		TextDrawSetString(classinfo[playerid],txt_info[playerid]);

		DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);

		//Credits to Luby & Gamer_Z
		DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;

		DirX = floatadd(DirX, floatmul(floatdiv(global_dm[classid][spx], 3000.0), 1.4062)); //1.7062
	    DirY = floatadd(DirY, floatmul(floatdiv(global_dm[classid][spy], 3000.0), 1.3577)); //1.7577
	    DirZ = floatadd(DirZ, floatmul(33.0107, 0.045));
	    pickup_marker[playerid][0] = CreatePlayerObject(playerid,1510,DirX,DirY,DirZ,0,0,0);


		chosentrack[playerid] = classid;
    	return 1;
	}
	if(lobbi[playerid][challenge] == 4)
	{
	    SpawnPlayer(playerid);
	    return 1;
	}
	new bugreport[128];
	format(bugreport,128,"il:%d ch:%d",lobbi[playerid][inside],lobbi[playerid][challenge]);
	//SendClientMessage(playerid,COLOR_RED,bugreport);
	printf("il:%d ch:%d",lobbi[playerid][inside],lobbi[playerid][challenge]);
	return 1;
}



public OnPlayerConnect(playerid)
{
	TogglePlayerClock(playerid,0);
	for(new cl=0;cl!=12;cl++) SendClientMessage(playerid,COLOR_GREY," ");
	chosentrack[playerid] = 0,inrace[playerid] = 0,lobbi[playerid][inside] = 0,lobbi[playerid][challenge] = 0,pl_skin[playerid] = random(288);
    lastskin[playerid] = 0;
	new nm[16];
    GetPlayerName(playerid,nm,MAX_PLAYER_NAME);
	if(!strcmp(nm,"[IC]",false,4))
	{
 		ShowPlayerDialog(playerid,391,DIALOG_STYLE_MSGBOX,"The IC-Tag is not a clantag","Please remove the [IC]-Tag in front of your name,\nas its reserved for players in challenges\n\nRegards,\nThe ISA-MPL Administration","Ok"," ");
 		Kick(playerid);
 		return 1;
	}
	if(strlen(nm) >= 12)
	{
	    ShowPlayerDialog(playerid,392,0,"Your name is too long","Dear User,\nyour name is too long for playing on the ISA - Multiplayer League.\nPlease exit the game, launch samp, change your name and reconnect\nRegards,\nThe ISA-MPL Administration","Ok"," ");
		Kick(playerid);
		return 1;
	}
	//authentifizierung
    GetPlayerIp(playerid, plrIP[playerid], 16);
    GetPlayerName(playerid,formal[playerid],128);
 	
 	format(mysqlquery[playerid],256,"SELECT hdwid FROM acupkeep WHERE ip = '%s'",plrIP[playerid]);
	mysql_query(mysqlquery[playerid]);
 	mysql_store_result();
	if(mysql_fetch_field("hdwid",hdwid[playerid]))
	{
	    mysql_fetch_field("hdwid",rlhdwid[playerid]);
	    strdel(hdwid[playerid],17,strlen(hdwid[playerid]));
	    printf("IP >%s< ,Name >%s< ,hdwid >%s< - acess gained",plrIP[playerid],formal[playerid],hdwid[playerid]);
	    mysql_free_result();
	    clientstart[playerid] = 0;
	}
	else
	{
	    printf("IP >%s< ,Name >%s< - acess denied",plrIP[playerid],formal[playerid]);
	    ShowPlayerDialog(playerid,74,DIALOG_STYLE_MSGBOX,"No Anticheat-Client found","Welcome to the 1st International SAMP League\nThis server uses his own anticheat-client, for granting a server free from cheaters\nIt looks like you dont have the anticheat-client running\nAs the ISA-Multiplayer League gives prices for winners, we have to make sure you cant cheat\n\nPlease visit www.ISA-MPL.com and download the anticheat-client\n\nLooking forward to see you again,\nThe ISA-MPL Administration","Exit"," ");
		Kick(playerid);
		mysql_free_result();
		return 1;
	}
	
	
	if(!strcmp(plrIP[playerid],"127.0.0.1"))
	{
	    ShowPlayerDialog(playerid,91,DIALOG_STYLE_MSGBOX,"Localhost","You seem to be connecting from localhost\nThis isnt allowed","Exit"," ");
		Kick(playerid);
	    return 1;
	}
	/*
	if(strval(hdwid[playerid]) == 0 || !strlen(hdwid[playerid]) || strval(hdwid[playerid]) == 0 )
	{
	    ShowPlayerDialog(playerid,74,DIALOG_STYLE_MSGBOX,"No Anticheat-Client found","Welcome to the 1st International SAMP League\nThis server uses his own anticheat-client, for granting a server free from cheaters\nIt looks like you dont have the anticheat-client running\nAs the ISA-Multiplayer League gives prices for winners, we have to make sure you cant cheat\n\nPlease visit www.ISA-MPL.com and download the anticheat-client\n\nLooking forward to see you again,\nThe ISA-MPL Administration","Exit"," ");
		Kick(playerid);
	    return 1;
	}*/
	format(file_name[playerid],128,"%s.usr.ini",hdwid[playerid]);
	if(fexist(file_name[playerid]))
	{
	    loggedin[playerid] = 1;
	}
	else
	{
 		loggedin[playerid] = 0;
 		ShowPlayerDialog(playerid,19,DIALOG_STYLE_MSGBOX,"Welcome to ISA-MPL","Welcome to the 1st International SAMP League\n\nYou already got the anticheat-plugin installed, so we can skip this step\nAs this server gives prices for winners, we need a valid email adress to send you the price you won\nOn our Website www.ISA-MPL.com you can watch a list with the best players","Continue","Exit");
	}

	GangZoneShowForPlayer(playerid,gangzone,COLOR_RED);
	format(txt_info[playerid],128," Race Track ~r~%d~w~ :~n~Vehicle : %s~n~~n~ ",1,VehicleNames[global_tracks[0][car]-400]);
    classinfo[playerid] = TextDrawCreate(350.000000, 1.000000, txt_info[playerid]);
	TextDrawBackgroundColor(classinfo[playerid], 255);
	TextDrawFont(classinfo[playerid], 2);
	TextDrawLetterSize(classinfo[playerid], 0.500000, 1.000000);
	TextDrawColor(classinfo[playerid], -1);
	TextDrawSetOutline(classinfo[playerid], 0);
	TextDrawSetProportional(classinfo[playerid], 1);
	TextDrawSetShadow(classinfo[playerid], 1);
	TextDrawUseBox(classinfo[playerid], 1);
	TextDrawBoxColor(classinfo[playerid], 255);
	TextDrawTextSize(classinfo[playerid], 640.000000, 90.000000);

	trackrecord[playerid] = TextDrawCreate(0.000000, 1.000000, "                  - Record : 0 - Your Time : 0                  ");
	TextDrawBackgroundColor(trackrecord[playerid], 255);
	TextDrawFont(trackrecord[playerid], 1);
	TextDrawLetterSize(trackrecord[playerid], 0.500000, 1.000000);
	TextDrawColor(trackrecord[playerid], -1);
	TextDrawSetOutline(trackrecord[playerid], 0);
	TextDrawSetProportional(trackrecord[playerid], 1);
	TextDrawSetShadow(trackrecord[playerid], 1);
	TextDrawUseBox(trackrecord[playerid], 1);
	TextDrawBoxColor(trackrecord[playerid], 2054847098);
	TextDrawTextSize(trackrecord[playerid], 640.000000, 0.000000);
	
	priceinfo[playerid] = TextDrawCreate(460.000000, 400.000000, "Category : ~g~??~w~~n~Price : ~r~??,00~w~ $");
	TextDrawBackgroundColor(priceinfo[playerid], 255);
	TextDrawFont(priceinfo[playerid], 1);
	TextDrawLetterSize(priceinfo[playerid], 0.500000, 1.000000);
	TextDrawColor(priceinfo[playerid], -1);
	TextDrawSetOutline(priceinfo[playerid], 0);
	TextDrawSetProportional(priceinfo[playerid], 1);
	TextDrawSetShadow(priceinfo[playerid], 1);
	
	advert[playerid] = TextDrawCreate(5.000000, 426.000000, "Your advertisement here ? Rent it at www.ISA-MPL.com !");
	TextDrawBackgroundColor(advert[playerid], 255);
	TextDrawFont(advert[playerid], 1);
	TextDrawLetterSize(advert[playerid], 0.500000, 1.000000);
	TextDrawColor(advert[playerid], -1);
	TextDrawSetOutline(advert[playerid], 0);
	TextDrawSetProportional(advert[playerid], 1);
	TextDrawSetShadow(advert[playerid], 1);
	
	SetPVarInt(playerid,"afktimer",SetTimerEx("afkcheck",60000*5,0,"i",playerid));
	SetTimerEx("upkeepconnection",11000,0,"i",playerid);
	return 1;
}

public afkcheck(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	SetPVarInt(playerid,"afktimer",SetTimerEx("afkcheck",60000*5,0,"i",playerid));
	if(GetPVarInt(playerid,"afk") == 0)
	{
	    TogglePlayerControllable(playerid,0);
	    ShowPlayerDialog(playerid,404,0,"You were kicked","You were kicked for being afk for a duration 5-10 minutes\nPlease disconnect in the future if you leave your PC, to give other players your slot","Ok"," ");
	    Kick(playerid);
	    return 1;
	}
	else SetPVarInt(playerid,"afk",0);
	return 1;
}


public upkeepconnection(playerid)
{
	if(!IsPlayerConnected(playerid) || IsPlayerAdmin(playerid) || GetPVarInt(playerid,"upkeepcheck") > 15) return 0;
    SetTimerEx("upkeepconnection",11000,0,"i",playerid);
	
	GetPlayerIp(playerid, plrIP[playerid], 16);
    GetPlayerName(playerid,formal[playerid],128);

 	format(mysqlquery[playerid],256,"SELECT time FROM acupkeep WHERE ip = '%s'",plrIP[playerid]);
	mysql_query(mysqlquery[playerid]);
 	mysql_store_result();
    mysql_fetch_field("time",formal[playerid]);
	clientstart2[playerid] = strval(formal[playerid]);
	mysql_free_result();
	if(clientstart2[playerid] == clientstart[playerid] && clientstart[playerid] != 0)
	{
 		new g_name[128];
		GetPlayerName(playerid,g_name,128);
		printf("%s (hdwid %s) tried to abuse the anticheat with exiting the client (Val %d/%d)",g_name,hdwid[playerid],clientstart[playerid],clientstart2[playerid]);
		ShowPlayerDialog(playerid,991,DIALOG_STYLE_MSGBOX,"Connection aborted","The Connection between the Anticheat-Client and the server got interrupted\nPlease do not exit the Anticheat-Client during the game\nIf you repeat exiting the client to cheat, you will get banned\n\nThe ISA-Multiplayer League Administration","Exit"," ");
		TogglePlayerControllable(playerid,0);
		Kick(playerid);
	}
	if(clientstart2[playerid] != clientstart[playerid]) clientstart[playerid] = clientstart2[playerid];
	SetPVarInt(playerid,"upkeepcheck",GetPVarInt(playerid,"upkeepcheck")+1);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new nom[32];
	GetPlayerName(playerid,nom,32);
    if(!strcmp(nom,"[IC]",false,4))
    {
    	strdel(nom,0,4);
     	SetPlayerName(playerid,nom);
	}
    TextDrawDestroy(classinfo[playerid]);
    TextDrawDestroy(trackrecord[playerid]);
    TextDrawDestroy(priceinfo[playerid]);
    TextDrawDestroy(advert[playerid]);
    DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
	DestroyPlayerObject(playerid,pickup_marker[playerid][1]);
	DestroyVehicle(veh[playerid]);
	KillTimer(GetPVarInt(playerid,"afktimer"));
	if(lobbi[playerid][inside] == 0 && lobbi[playerid][challenge] == 3)
	{
	    ForceClassSelection(otherpl[playerid]);
	    SetPlayerHealth(otherpl[playerid],0);
	    ShowPlayerDialog(otherpl[playerid],35,0,"Your enemy disconnected","Your opponent has left the server\nThe Fight has been aborted","Ok"," ");
	    return 1;
	}
	return 1;
}

public refreshadvert()
{
	advertcount+=1;
	INI_Open("advert.ini");
	format(formme,128,"%d",advertcount);
	if(!INI_ReadString(adslogan,formme,128))
	{
	    advertcount=0;
	    adduration = 15000;
	    SetTimer("refreshadvert",15000,0);
	    format(adslogan,128,"%s","Your advertisement here ? Rent it at ~g~www.ISA-MPL.com~w~ !");
	}
	else
	{
	    format(formme,128,"dur-%d",advertcount);
        adduration = INI_ReadInt(formme);
        SetTimer("refreshadvert",adduration,0);
	}
	INI_Close();
	
	for(new ref=0;ref<=slots;ref++)
	{
	    if(IsPlayerConnected(ref))
	    {
			if(GetPlayerState(ref) == 1 || GetPlayerState(ref) == 2)
			{
				TextDrawShowForPlayer(ref,advert[ref]);
				TextDrawSetString(advert[ref],adslogan);
			}
			else TextDrawHideForPlayer(ref,advert[ref]);
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerVirtualWorld(playerid,0);
	ResetPlayerWeapons(playerid);
	SetPlayerWorldBounds(playerid,20000.0000, -20000.0000, 20000.0000, -20000.0000);
	DisablePlayerRaceCheckpoint(playerid);
	
	if(lobbi[playerid][challenge] == 0)
	{
	    new nm[16];
	    GetPlayerName(playerid,nm,MAX_PLAYER_NAME);
	    if(!strcmp(nm,"[IC]",false,4))
	    {
	        strdel(nm,0,4);
	        SetPlayerName(playerid,nm);
		}
	    
	    TextDrawHideForPlayer(playerid,trackrecord[playerid]);
	    SetPlayerHealth(playerid,400);
	    switch(random(3))
	    {
	        case 0:
	        {
			    SetPlayerInterior(playerid,1);
			    SetPlayerPos(playerid,-2168.0701,644.5532,1052.3750);
			    SetPlayerFacingAngle(playerid,176.0499);
			}
			case 1:
			{
				SetPlayerInterior(playerid,18);
	    		SetPlayerPos(playerid,1722.2061,-1648.3342,20.2281);
			}
			case 2:
			{
			    SetPlayerInterior(playerid,5);
  				SetPlayerPos(playerid,1266.0510,-793.1976,1084.0078);
			}
		}
			    
	    for(new lo=0;lo<=10;lo++) SendClientMessage(playerid,COLOR_GREY," ");
		ShowPlayerDialog(playerid,112,DIALOG_STYLE_MSGBOX,"Welcome on the ISA-MP League","Welcome to the 1st International SAMP League.\n\nCurrently, you are at the Lobby, where you can chat with other users\nTo start a challenge, press [ENTER]\n\nPlease visit our website ISAMP-League.com for further informations","Ok","");
        lobbi[playerid][inside] = 1;
        
		INI_Open("price.ini");
		INI_ReadString(formme,"cat",128);
		format(pricestring,128,"Category : ~g~%s~w~~n~Price : ~r~%d,00~w~ $",formme,INI_ReadInt("price"));
		INI_Close();
		TextDrawShowForPlayer(playerid,priceinfo[playerid]);
		TextDrawSetString(priceinfo[playerid],pricestring);
	    return 1;
	}
	if(lobbi[playerid][challenge] == 1 && lobbi[playerid][inside] == 1)
	{
	    new nm2[16];
	    GetPlayerName(playerid,nm2,MAX_PLAYER_NAME);
		strins(nm2,"[IC]",0);
		SetPlayerName(playerid,nm2);
	    
	    lobbi[playerid][inside] = 0;
	    SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
		inrace[playerid] = 0;
	    DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);
		TogglePlayerControllable(playerid,0);
		TextDrawHideForPlayer(playerid,classinfo[playerid]);
		
		SetPlayerVirtualWorld(playerid,playerid+1);
		SetPlayerSkin(playerid,pl_skin[playerid]);
  		SetCameraBehindPlayer(playerid);
		veh[playerid] = CreateVehicle(global_tracks[chosentrack[playerid]][car],global_tracks[chosentrack[playerid]][startx],global_tracks[chosentrack[playerid]][starty],global_tracks[chosentrack[playerid]][startz],global_tracks[chosentrack[playerid]][startrot],random(252),random(252),1);
		AddVehicleComponent(veh[playerid],1009);
		SetVehicleVirtualWorld(veh[playerid],playerid+1);
		PutPlayerInVehicle(playerid,veh[playerid],0);
	    TogglePlayerControllable(playerid,0);
	    GameTextForPlayer(playerid,"~r~5",1000,3);
	    SetTimerEx("racestart",1000,0,"i",playerid);
	    inrace[playerid] = 1,countdown[playerid] = 5;
	    playertime[playerid] = float(0);

		SetPlayerRaceCheckpoint(playerid,1,global_tracks[chosentrack[playerid]][zielx],global_tracks[chosentrack[playerid]][ziely],global_tracks[chosentrack[playerid]][zielz],0,0,0,5);

		return 1;
	}
	if(lobbi[playerid][challenge] == 2  && lobbi[playerid][inside] == 1)
	{
	    new nm3[16];
	    GetPlayerName(playerid,nm3,MAX_PLAYER_NAME);
		strins(nm3,"[IC]",0);
		SetPlayerName(playerid,nm3);
		
	    lobbi[playerid][inside] = 0,inrace[playerid] = 0;
	    DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);
	    SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
		TogglePlayerControllable(playerid,0);
		TextDrawHideForPlayer(playerid,classinfo[playerid]);
		
		ShowPlayerDialog(playerid,87,DIALOG_STYLE_INPUT,"Race Challenge against...","Type the name or playerid of the opponent you want to race against :","Submit","Abort");
		
	    return 1;
	}
    if(lobbi[playerid][challenge] == 3  && lobbi[playerid][inside] == 1)
	{
	    new nm4[16];
	    GetPlayerName(playerid,nm4,MAX_PLAYER_NAME);
		strins(nm4,"[IC]",0);
		SetPlayerName(playerid,nm4);

	    lobbi[playerid][inside] = 0,inrace[playerid] = 0;
	    DestroyPlayerObject(playerid,pickup_marker[playerid][0]);
		DestroyPlayerObject(playerid,pickup_marker[playerid][1]);
	    SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
		TextDrawHideForPlayer(playerid,classinfo[playerid]);

		ShowPlayerDialog(playerid,89,DIALOG_STYLE_INPUT,"Fight against...","Type the name of the opponent you want to fight against :","Submit","Abort");

	    return 1;
	}
	if(lobbi[playerid][challenge] == 4 && lobbi[playerid][inside] == 0)
	{
	    ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid,46,1);
		GivePlayerWeapon(playerid,4,1);
		GivePlayerWeapon(playerid,24,999999);
		GivePlayerWeapon(playerid,26,999999);
		GivePlayerWeapon(playerid,29,999999);
		GivePlayerWeapon(playerid,31,999999);
		GivePlayerWeapon(playerid,34,999999);
		SetPlayerPos(playerid,float(random(366+101)-101),float(random(2094-1600)+1600),random(200)+700);
		SetPlayerWorldBounds(playerid,366.2648,-101.2526,2094.6494,1599.8019);
		SetPlayerHealth(playerid,50);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	
	if(!IsPlayerConnected(killerid)) return 1;
	if(lobbi[killerid][challenge] == 3)
	{
		ch2[active][playerid] = 0;
		new otherone = otherpl[playerid];
		ch2[active][otherone] = 0,lobbi[playerid][challenge] = 0,lobbi[otherone][challenge] = 0;
		SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
		SetPlayerCameraPos(otherone, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(otherone, -1822.3245,-149.2125,9.4056);
		format(file_name[playerid],128,"%s.usr.ini",hdwid[killerid]);
		INI_Open(file_name[playerid]);
		//winner
		new winform[128];
		format(winform,128,"%s-dmratio",hdwid[killerid]);
		pl_stats[killerid][dmratio] = INI_ReadFloat(winform);
		format(winform,128,"%s-dmkills",hdwid[killerid]);
	 	pl_stats[killerid][dmwins] = INI_ReadInt(winform);
		format(winform,128,"%s-dmdeath",hdwid[killerid]);
		pl_stats[killerid][dmlosses] = INI_ReadInt(winform);
	    pl_stats[killerid][dmwins]+=1;
	    if(float(pl_stats[killerid][dmlosses]) == 0 || float(pl_stats[killerid][dmwins]) == 0) pl_stats[killerid][dmratio] = float(0);
	    else pl_stats[killerid][dmratio] = floatdiv(float(pl_stats[killerid][dmwins]),float(pl_stats[killerid][dmlosses]));
	    format(winform,128,"%s-dmratio",hdwid[killerid]);
		INI_WriteFloat(winform,pl_stats[killerid][dmratio]);
	    format(winform,128,"%s-dmkills",hdwid[killerid]);
		INI_WriteInt(winform,pl_stats[killerid][dmwins]);
		INI_Save();
		INI_Close();
		
		format(file_name[playerid],128,"%s.usr.ini",hdwid[playerid]);
		INI_Open(file_name[playerid]);
		//loser
		format(winform,128,"%s-dmratio",hdwid[playerid]);
		pl_stats[playerid][dmratio] = INI_ReadFloat(winform);
		format(winform,128,"%s-dmkills",hdwid[playerid]);
		pl_stats[playerid][dmwins] = INI_ReadInt(winform);
		format(winform,128,"%s-dmdeath",hdwid[playerid]);
		pl_stats[playerid][dmlosses] = INI_ReadInt(winform);
	    pl_stats[playerid][dmlosses]+=1;
	    if(float(pl_stats[playerid][dmlosses]) == 0 || float(pl_stats[playerid][dmwins]) == 0) pl_stats[playerid][dmratio] = float(0);
	    else pl_stats[playerid][dmratio] = floatdiv(float(pl_stats[playerid][dmwins]),float(pl_stats[playerid][dmlosses]));
	    format(winform,128,"%s-dmratio",hdwid[playerid]);
		INI_WriteFloat(winform,pl_stats[playerid][dmratio]);
	    format(winform,128,"%s-dmdeath",hdwid[playerid]);
		INI_WriteInt(winform,pl_stats[playerid][dmlosses]);

		INI_Save();
		INI_Close();

		INI_Open("bestversus.ini");
		if(pl_stats[killerid][dmratio] > INI_ReadFloat("dmversus"))
		{
		    new bestname[MAX_PLAYER_NAME];
		    GetPlayerName(killerid,bestname,sizeof(bestname));
		    if(!strcmp(bestname,"[IC]",false,4)) strdel(bestname,0,4);
		    INI_WriteFloat("dmversus",pl_stats[killerid][dmratio]);
			INI_WriteString("dmversus-who",hdwid[killerid]);
			INI_WriteString("dmversus-who-alias",bestname);
			INI_Save();
		}
		INI_Close();

		format(winform,128,"You lost the Fight\n\nYour new stats:\nWins : %d\nLosses : %d\nRatio : %f",pl_stats[playerid][dmwins],pl_stats[playerid][dmlosses],pl_stats[playerid][dmratio]);
		ShowPlayerDialog(playerid,571,DIALOG_STYLE_MSGBOX,"You lost the Fight",winform,"Ok"," ");
		format(winform,128,"You won the dm\n\nYour new stats:\nWins : %d\nLosses : %d\nRatio : %f",pl_stats[killerid][dmwins],pl_stats[killerid][dmlosses],pl_stats[killerid][dmratio]);
		ShowPlayerDialog(killerid,571,DIALOG_STYLE_MSGBOX,"You won the Fight",winform,"Ok"," ");

		ForceClassSelection(playerid);
		ForceClassSelection(otherone);
		SetPlayerHealth(playerid,0);
		SetPlayerHealth(otherone,0);
	}
	if(lobbi[killerid][challenge] == 4)
	{
	    if(!IsPlayerConnected(killerid)) return 1; //bekommt halt kener n punkt :D
	    GameTextForPlayer(playerid,"You got ~r~killed",1000,1);

	    format(file_name[playerid],128,"%s.usr.ini",hdwid[playerid]);
		INI_Open(file_name[playerid]);
		//winner
		new winform[128];
		format(winform,128,"%s-rck",hdwid[killerid]);
		pl_stats[killerid][rck] = INI_ReadInt(winform);
		INI_WriteInt(winform,pl_stats[killerid][rck]+1);
		INI_Save();
		INI_Close();
		format(winform,128,"Hit ! (New Score:%d)",pl_stats[killerid][rck]+1);
        GameTextForPlayer(killerid,winform,1000,1);
		INI_Open("bestversus.ini");
		if(pl_stats[killerid][rck] > INI_ReadInt("rckills"))
		{
  			new bestname[MAX_PLAYER_NAME];
			GetPlayerName(killerid,bestname,sizeof(bestname));
			if(!strcmp(bestname,"[IC]",false,4)) strdel(bestname,0,4);
			INI_WriteInt("rckills",pl_stats[killerid][rck]);
			INI_WriteString("rckills-who",hdwid[rck]);
			INI_WriteString("rckills-who-alias",bestname);
			INI_Save();
		}
		INI_Close();
	    return 1; 
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	/*
	if(!IsPlayerConnected(killerid)) return 1;
	for(new getv=0;getv<=slots;getv++)
	{
	    if(vehicleid == veh[getv])
	    {
            DestroyVehicle(veh[getv]);
			veh[getv] = CreateVehicle(464,float(random(366+101)-101),float(random(2094-1600)+1600),random(500)+100,0,random(252),random(252),1);
			PutPlayerInVehicle(getv,veh[getv],0);
			GameTextForPlayer(getv,"You were ~r~killed~w~",1000,1);
			GameTextForPlayer(killerid,"~g~+1~w~",1000,1);
			
			INI_Open("Users.ini");
			//winner
			new winform[128];
			format(winform,128,"%s-rck",hdwid[killerid]);
			pl_stats[killerid][rck] = INI_ReadInt(winform);
			INI_WriteInt(winform,pl_stats[killerid][rck]+1);
			INI_Save();
			INI_Close();
			
			INI_Open("bestversus.ini");
			if(pl_stats[killerid][rck] > INI_ReadInt("rckills"))
			{
			    new bestname[MAX_PLAYER_NAME];
			    GetPlayerName(killerid,bestname,sizeof(bestname));
			    if(!strcmp(bestname,"[IC]",false,4)) strdel(bestname,0,4);
			    INI_WriteInt("rckills",pl_stats[killerid][rck]);
				INI_WriteString("rckills-who",hdwid[rck]);
				INI_WriteString("rckills-who-alias",bestname);
				INI_Save();
			}
			INI_Close();
		}
	}
	*/
	return 1;
}

public OnPlayerText(playerid, text[])
{
	SetPlayerChatBubble(playerid,text,COLOR_GREY,20.0,5000);
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(savepos,7,cmdtext);
	dcmd(savepos2,8,cmdtext);
	dcmd(savedm,6,cmdtext);
	dcmd(spawncar,8,cmdtext);
	dcmd(setskin,7,cmdtext);
	dcmd(debug,5,cmdtext);
	dcmd(ban,3,cmdtext);
	//dcmd(challenges,10,cmdtext);
	return 1;
}

dcmd_ban(playerid,params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	if(!IsPlayerConnected(strval(params)) || !strlen(params)) return GameTextForPlayer(playerid,"invalid",1000,2);
	junk_ban(playerid);
	return 1;
}

/*
dcmd_challenges(playerid,params[])
{
	if(lobbi[playerid][inside] == 0) return 1;
	if(!strlen(params)) return ShowPlayerDialog(playerid,91,DIALOG_STYLE_LIST,"Choose a challenge","Solo Race\nVersus Race 1on1\nVersus Deathmatch 1on1","Confirm","Cancel");
	if(strval(params) > 0 && strval(params) < 4)
	{
		lobbi[playerid][challenge] = strval(params);
		SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
		SetPlayerPos(playerid,0,0,0);
		ForceClassSelection(playerid);
		SetPlayerInterior(playerid,0);
		SetPlayerHealth(playerid,0);
	}
	else ShowPlayerDialog(playerid,91,DIALOG_STYLE_LIST,"Choose a challenge","Solo Race\nVersus Race\nVersus Deathmatch","Confirm","Cancel");
	return 1;
}
*/

dcmd_debug(playerid,params[])
{
    if(!IsPlayerAdmin(playerid)) return 1;
    #pragma unused params
	SetPlayerPos(playerid,0,0,0);
	SetPlayerHealth(playerid,300);
	SetPlayerInterior(playerid,0);
    return 1;
}

dcmd_spawncar(playerid,params[])
{
    if(!IsPlayerAdmin(playerid)) return 1;
	new Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	new sthcar = CreateVehicle(strval(params),pos[0],pos[1],pos[2]+2,0,0,0,9999999);
	PutPlayerInVehicle(playerid,sthcar,0);
	return 1;
}

dcmd_setskin(playerid,params[])
{
    if(!IsPlayerAdmin(playerid)) return 1;
    SetPlayerSkin(playerid,strval(params));
    return 1;
}

dcmd_savedm(playerid,params[])
{
    #pragma unused params
    if(!IsPlayerAdmin(playerid)) return 1;
    new Float:savepos[3];
    INI_Open("defdm.ini");
	if(IsPlayerInAnyVehicle(playerid)) GetVehiclePos(GetPlayerVehicleID(playerid),savepos[0],savepos[1],savepos[2]);
	else GetPlayerPos(playerid,savepos[0],savepos[1],savepos[2]);
    format(formme,64,"index-%d",strval(params));
	INI_WriteInt(formme,1);
	format(formme,64,"wep-%d",strval(params));
	INI_WriteInt(formme,GetPlayerWeapon(playerid));
	format(formme,64,"startx-%d",strval(params));
	INI_WriteFloat(formme,savepos[0]);
	format(formme,64,"starty-%d",strval(params));
	INI_WriteFloat(formme,savepos[1]);
	format(formme,64,"startz-%d",strval(params));
	INI_WriteFloat(formme,savepos[2]);
	SendClientMessage(playerid,COLOR_GREEN,"DM-position gespeichert");
	INI_Save();
	INI_Close();

	return 1;
}

dcmd_savepos2(playerid,params[])
{
	#pragma unused params
    if(!IsPlayerAdmin(playerid)) return 1;
    new Float:savepos[3];
    INI_Open("deftracks2.ini");
	GetVehiclePos(GetPlayerVehicleID(playerid),savepos[0],savepos[1],savepos[2]);
    new Float:angla;
	GetVehicleZAngle(GetPlayerVehicleID(playerid),angla);
	format(formme,64,"startx2-%d",chosentrack[playerid]);
	INI_WriteFloat(formme,savepos[0]);
	format(formme,64,"starty2-%d",chosentrack[playerid]);
	INI_WriteFloat(formme,savepos[1]);
	format(formme,64,"startz2-%d",chosentrack[playerid]);
	INI_WriteFloat(formme,savepos[2]);
	format(formme,64,"startrot2-%d",chosentrack[playerid]);
	INI_WriteFloat(formme,angla);
	SendClientMessage(playerid,COLOR_GREEN,"Startposition (SP2) gespeichert");
	INI_Save();
	INI_Close();

	return 1;
}

dcmd_savepos(playerid,params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	new startorend,trackid;
	if(sscanf(params,"ii",startorend,trackid)) return SendClientMessage(playerid,COLOR_RED,"/save [0/1] [trackid]");
    INI_Open("deftracks.ini");
    format(formme,64,"index-%d",trackid);
	INI_WriteInt(formme,1);
	format(formme,64,"car-%d",trackid);
	INI_WriteInt(formme,GetVehicleModel(GetPlayerVehicleID(playerid)));
	new Float:savepos[3];
	GetVehiclePos(GetPlayerVehicleID(playerid),savepos[0],savepos[1],savepos[2]);
	switch(startorend)
	{
	    case 0:
	    {
	        new Float:angla;
			GetVehicleZAngle(GetPlayerVehicleID(playerid),angla);
			format(formme,64,"startx-%d",trackid);
			INI_WriteFloat(formme,savepos[0]);
			format(formme,64,"starty-%d",trackid);
			INI_WriteFloat(formme,savepos[1]);
			format(formme,64,"startz-%d",trackid);
			INI_WriteFloat(formme,savepos[2]);
			format(formme,64,"startrot-%d",trackid);
			INI_WriteFloat(formme,angla);
			SendClientMessage(playerid,COLOR_GREEN,"Startposition gespeichert");
		}
		case 1:
		{
			format(formme,64,"zielx-%d",trackid);
			INI_WriteFloat(formme,savepos[0]);
			format(formme,64,"ziely-%d",trackid);
			INI_WriteFloat(formme,savepos[1]);
			format(formme,64,"zielz-%d",trackid);
			INI_WriteFloat(formme,savepos[2]);
			SendClientMessage(playerid,COLOR_GREEN,"Zielposition gespeichert");
		}
 	}
 	INI_Save();
	INI_Close();
	
    INI_Open("defrecords.ini");
    format(formme,64,"%d-time",trackid);
	INI_WriteInt(formme,99999);
	GetPlayerName(playerid,formal[playerid],128);
	if(!strcmp(formal[playerid],"[IC]",false,4)) strdel(formal[playerid],0,4);
    format(formme,64,"%d-name",trackid);
	INI_WriteString(formme,formal[playerid]);
	INI_Save();
	INI_Close();
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    lobbi[playerid][challenge] = 0;
	DestroyVehicle(veh[playerid]);
	ForceClassSelection(playerid);
	SetPlayerHealth(playerid,0);
	inrace[playerid] = 0;
	DisablePlayerRaceCheckpoint(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate != 2 && oldstate == 2)
	{
	    lobbi[playerid][challenge] = 0;
		DestroyVehicle(veh[playerid]);
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid,0);
		inrace[playerid] = 0;
		DisablePlayerRaceCheckpoint(playerid);
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(lobbi[playerid][challenge] == 2)
    {
		if(ch2[active][playerid] == 1 || ch2[active][playerid] == 0) //causing bugs
		{
		    ch2[active][playerid] = 0,ch2[active][otherpl[playerid]] = 0;
		    new otherone = otherpl[playerid];
		    lobbi[playerid][challenge] = 0,lobbi[otherone][challenge] = 0;
		    
		    DisablePlayerRaceCheckpoint(playerid);
		    if(lobbi[otherone][inside] == 0) DisablePlayerRaceCheckpoint(otherone);
			if(lobbi[otherone][inside] == 0) DestroyVehicle(veh[otherone]);
			DestroyVehicle(veh[playerid]);
		    SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
			SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
			if(lobbi[otherone][inside] == 0) SetPlayerCameraPos(otherone, -1822.1163,-155.3545,9.4056);
			if(lobbi[otherone][inside] == 0) SetPlayerCameraLookAt(otherone, -1822.3245,-149.2125,9.4056);
			format(file_name[playerid],128,"%s.usr.ini",hdwid[playerid]);
		    INI_Open(file_name[playerid]);
		    //winner
	        format(formal[playerid],128,"%s-racew",hdwid[playerid]);
	        pl_stats[playerid][racew] = INI_ReadInt(formal[playerid]);
	        format(formal[playerid],128,"%s-racelo",hdwid[playerid]);
	        pl_stats[playerid][racelo] = INI_ReadInt(formal[playerid]);
            pl_stats[playerid][racew]+=1;
            if(pl_stats[playerid][racew] == 0 || pl_stats[playerid][racelo] == 0) pl_stats[playerid][racer] = float(0);
            else pl_stats[playerid][racer] = floatdiv(float(pl_stats[playerid][racew]),float(pl_stats[playerid][racelo]));
            printf("raceratio : wins:%d (%f) losses:%d (%f) ratio:%f",pl_stats[playerid][racew],float(pl_stats[playerid][racew]),pl_stats[playerid][racelo],float(pl_stats[playerid][racelo]),pl_stats[playerid][racer]);
            format(formal[playerid],128,"%s-racer",hdwid[playerid]);
			INI_WriteFloat(formal[playerid],pl_stats[playerid][racer]);
            format(formal[playerid],128,"%s-racew",hdwid[playerid]);
			INI_WriteInt(formal[playerid],pl_stats[playerid][racew]);
			INI_Save();
			INI_Close();

			format(file_name[playerid],128,"%s.usr.ini",hdwid[otherone]);
			INI_Open(file_name[playerid]);
			//loser
	        format(formal[otherone],128,"%s-racew",hdwid[otherone]);
	        pl_stats[otherone][racew] = INI_ReadInt(formal[otherone]);
	        format(formal[otherone],128,"%s-racelo",hdwid[otherone]);
	        pl_stats[otherone][racelo] = INI_ReadInt(formal[otherone]);
            pl_stats[otherone][racelo]+=1;
            if(pl_stats[otherone][racew] == 0 || pl_stats[otherone][racelo] == 0) pl_stats[otherone][racer] = float(0);
            else pl_stats[otherone][racer] = floatdiv(float(pl_stats[otherone][racew]),float(pl_stats[otherone][racelo]));
            printf("raceratio : wins:%d (%f) losses:%d (%f) ratio:%f",pl_stats[otherone][racew],float(pl_stats[otherone][racew]),pl_stats[otherone][racelo],float(pl_stats[otherone][racelo]),pl_stats[otherone][racer]);
            format(formal[otherone],128,"%s-racer",hdwid[otherone]);
			INI_WriteFloat(formal[otherone],pl_stats[otherone][racer]);
            format(formal[otherone],128,"%s-racelo",hdwid[otherone]);
			INI_WriteInt(formal[otherone],pl_stats[otherone][racelo]);

	        INI_Save();
	        INI_Close();
	        
	        INI_Open("bestversus.ini");
			if(pl_stats[playerid][racer] > INI_ReadFloat("raceversus"))
			{
			    new bestname[MAX_PLAYER_NAME];
	    		GetPlayerName(playerid,bestname,sizeof(bestname));
	    		if(!strcmp(bestname,"[IC]",false,4)) strdel(bestname,0,4);
			    INI_WriteFloat("raceversus",pl_stats[playerid][racer]);
				INI_WriteString("raceversus-who",hdwid[playerid]);
				INI_WriteString("raceversus-who-alias",bestname);
				INI_Save();
			}
			INI_Close();
		    
            format(formal[otherone],128,"You lost the race\n\nYour new stats:\nWins : %d\nLosses : %d\nRatio : %f",pl_stats[otherone][racew],pl_stats[otherone][racelo],pl_stats[otherone][racer]);
		    ShowPlayerDialog(otherone,571,DIALOG_STYLE_MSGBOX,"You lost the race",formal[otherone],"Ok"," ");
		    format(formal[otherone],128,"You won the race\n\nYour new stats:\nWins : %d\nLosses : %d\nRatio : %f",pl_stats[playerid][racew],pl_stats[playerid][racelo],pl_stats[playerid][racer]);
		    ShowPlayerDialog(playerid,571,DIALOG_STYLE_MSGBOX,"You won the race",formal[otherone],"Ok"," ");
		    
		    ForceClassSelection(playerid);
			if(lobbi[otherone][inside] == 0) ForceClassSelection(otherone);
		    SetPlayerHealth(playerid,0);
		    if(lobbi[otherone][inside] == 0) SetPlayerHealth(otherone,0);
		    
            return 1;
        }
    }
	if(lobbi[playerid][challenge] == 1)
	{
	    playertime[playerid] = floatdiv(playertime[playerid],10);
	    inrace[playerid] = 0;
		if(GetPlayerVehicleID(playerid) != veh[playerid])
		{
		    SendClientMessage(playerid,COLOR_RED,"You entered with the wrong vehicle");
		    lobbi[playerid][challenge] = 0,inrace[playerid] = 0;
		    DestroyVehicle(veh[playerid]);
		    ForceClassSelection(playerid);
		    SetPlayerHealth(playerid,0);
			return 1;
		}
		TogglePlayerControllable(playerid,0);
		for(new cl=0;cl!=10;cl++) SendClientMessage(playerid,COLOR_GREY," ");
		format(formal[playerid],128,"You reached the end of the track %d with a time of %.1f seconds",chosentrack[playerid],playertime[playerid]);
		SendClientMessage(playerid,COLOR_GREY,formal[playerid]);
		for(new cle=0;cle!=9;cle++) SendClientMessage(playerid,COLOR_RED," ");
		if(playertime[playerid] < global_records[chosentrack[playerid]][time])
		{
		    GetPlayerName(playerid,formme,64);
		    if(!strcmp(formme,"[IC]",false,4)) strdel(formme,0,4);
			format(formal[playerid],128,"[New World Record]  [Track:%d]  [Time:%.1f]  [Player:%s]",chosentrack[playerid],playertime[playerid],formme);
			SendClientMessageToAll(COLOR_GREEN,formal[playerid]);
			for(new cl=0;cl!=9;cl++) SendClientMessageToAll(COLOR_GREEN," ");
			INI_Open("defrecords.ini");
		    format(formme,64,"%d-time",chosentrack[playerid]);
			INI_WriteFloat(formme,playertime[playerid]);
			global_records[chosentrack[playerid]][time] = playertime[playerid];
			GetPlayerName(playerid,formal[playerid],128);
			if(!strcmp(formal[playerid],"[IC]",false,4)) strdel(formal[playerid],0,4);
		    format(formme,64,"%d-name",chosentrack[playerid]);
			INI_WriteString(formme,formal[playerid]);
			format(global_records[chosentrack[playerid]][name],128,"%s",formal[playerid]);
			INI_Save();
			INI_Close();
		}
		lobbi[playerid][challenge] = 0,inrace[playerid] = 0;
		DestroyVehicle(veh[playerid]);
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid,0);
		TextDrawHideForPlayer(playerid,trackrecord[playerid]);
		//ShowPlayerDialog(playerid,10,DIALOG_STYLE_MSGBOX,"You reached your destination",formal[playerid],"Continue"," ");
		SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public debugline()
{
	debugval++;
	printf("%d",debugval);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == lobbypickups[0] || pickupid == lobbypickups[4]) //go to lobby 2
 	{
  		SetPlayerInterior(playerid,18);
	    SetPlayerPos(playerid,1722.2061,-1648.3342,20.2281);
	}
	if(pickupid == lobbypickups[1] || pickupid == lobbypickups[2]) // got to lobby 3
	{
		SetPlayerInterior(playerid,5);
  		SetPlayerPos(playerid,1266.0510,-793.1976,1084.0078);
	}
	if(pickupid == lobbypickups[3] || pickupid == lobbypickups[5]) // go to lobby 1
	{
	    SetPlayerInterior(playerid,1);
	    SetPlayerPos(playerid,-2168.0701,644.5532,1052.3750);
	}
	
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if((newkeys == 16 || newkeys & 16) && lobbi[playerid][inside] == 0 && lobbi[playerid][challenge] == 4 && GetPlayerState(playerid) == 1)
	{
	    lobbi[playerid][challenge] = 0;
	    ForceClassSelection(playerid);
	    SetPlayerHealth(playerid,0);
	    inrace[playerid] = 0;
	    return 1;
	}
	if((newkeys == KEY_FIRE || newkeys & KEY_FIRE || newkeys == KEY_SECONDARY_ATTACK || newkeys & KEY_SECONDARY_ATTACK) && lobbi[playerid][inside] == 1)
	{
		if(GetPlayerWeapon(playerid) != 0) Kick(playerid);
		if(!IsPlayerInAnyVehicle(playerid))
		{
		    TogglePlayerControllable(playerid,1);
		    TogglePlayerControllable(playerid,0);
		    SetPVarInt(playerid,"lobbyattacks",GetPVarInt(playerid,"lobbyattacks")+2);
		    KillTimer(GetPVarInt(playerid,"unfrez"));
			SetPVarInt(playerid,"unfrez",SetTimerEx("unfreeze",GetPVarInt(playerid,"lobbyattacks")*1000,0,"i",playerid));
		    ShowPlayerDialog(playerid,41,DIALOG_STYLE_MSGBOX,"Restrictions","Its restricted to attack other players while being in the lobby\nTo fight, use the Deathmatch Challenge\nEvery time you attempt to attack other players, your punishment will increase for 2 seconds","Ok"," ");
		}
	}
	if((newkeys == 16 || newkeys & 16) && lobbi[playerid][inside] == 1 && lobbi[playerid][challenge] == 0 && GetPlayerState(playerid) == 1)
	{
	    return ShowPlayerDialog(playerid,91,DIALOG_STYLE_LIST,"Choose a challenge","Solo Race\nVersus Race\nVersus Deathmatch\nFree For All Deathmatch","Confirm","Cancel");
	}
	if((newkeys == 16 || newkeys & 16) && IsPlayerInAnyVehicle(playerid))
	{
		lobbi[playerid][challenge] = 0;
		DestroyVehicle(veh[playerid]);
		ForceClassSelection(playerid);
		SetPlayerHealth(playerid,0);
		inrace[playerid] = 0;
		DisablePlayerRaceCheckpoint(playerid);
		return 1;
	}
	return 1;
}

forward unfreeze(playerid);
public unfreeze(playerid)
{
    return TogglePlayerControllable(playerid,1);
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	SetPVarInt(playerid,"afk",1);
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case 87:
	    {
	        if(!response || !strlen(inputtext))
	        {
	            lobbi[playerid][inside] = 1,lobbi[playerid][challenge] = 0;
	            ForceClassSelection(playerid);
	            SetPlayerHealth(playerid,0);
				return 1;
			}
			ch2[tempo1][playerid] = -1; //found-variable
			for(new tempsearch=0;tempsearch<=slots;tempsearch++)
			{
			    if(IsPlayerConnected(tempsearch) && tempsearch != playerid)
			    {
			        GetPlayerName(tempsearch,ch2[tempo3][playerid],128);
				    if(!strcmp(inputtext,ch2[tempo3][playerid],true))
				    {
						ch2[tempo1][playerid] = 1;
						otherpl[playerid] = tempsearch;
						break;
					}
				}
				if(IsPlayerConnected(strval(inputtext)) && tempsearch != playerid)
				{
				    ch2[tempo1][playerid] = 1;
				    otherpl[playerid] = tempsearch;
				    break;
				}
			}
			if(ch2[tempo1][playerid]==-1 || !IsPlayerConnected(otherpl[playerid])) return ShowPlayerDialog(playerid,87,DIALOG_STYLE_INPUT,"Race Challenge against...","The User you typed was not found\n\nType the name or the playerid of the opponent you want to race against :","Submit","Abort");
			if(playerid == otherpl[playerid]) return ShowPlayerDialog(playerid,87,DIALOG_STYLE_INPUT,"Race Challenge against...","You entered your own Username\n\nType the name or the playerid of the opponent you want to race against :","Submit","Abort");
			if(lobbi[otherpl[playerid]][inside] == 0) return ShowPlayerDialog(playerid,87,DIALOG_STYLE_INPUT,"Race Challenge against...","The User you wanted to race against is busy, try again later\n\nType the name or the playerid of the opponent you want to race against :","Submit","Abort");
			new mynam[16];
			SendClientMessage(playerid,COLOR_GREY,"Your opponent has been asked whether he wants to accept your challenge");
			for(new cle=0;cle!=9;cle++) SendClientMessage(playerid,COLOR_RED," ");
			GetPlayerName(playerid,mynam,16);
			otherpl[otherpl[playerid]] = playerid,ch2[active][playerid] = 1,ch2[active][otherpl[playerid]] = 1;
			format(ch2[tempo3][playerid],128,"You have been challenged by %s for a 1on1 Race at Track %d\n\nPlease decide now, if you want to accept or decline this request",mynam,chosentrack[playerid]);
			ShowPlayerDialog(otherpl[playerid],60,DIALOG_STYLE_MSGBOX,"You have been challenged",ch2[tempo3][playerid],"Accept","Decline");
			
	        return 1;
	    }
	    case 89: //dm 1on1
	    {
	        if(!response || !strlen(inputtext))
	        {
	            lobbi[playerid][inside] = 1,lobbi[playerid][challenge] = 0;
	            ForceClassSelection(playerid);
	            SetPlayerHealth(playerid,0);
				return 1;
			}
			ch2[tempo1][playerid] = -1; //found-variable
			for(new tempsearch=0;tempsearch<=slots;tempsearch++)
			{
			    if(IsPlayerConnected(tempsearch) && tempsearch != playerid)
			    {
			        GetPlayerName(tempsearch,ch2[tempo3][playerid],128);
				    if(!strcmp(inputtext,ch2[tempo3][playerid],true))
				    {
						ch2[tempo1][playerid] = 1;
						otherpl[playerid] = tempsearch;
						break;
					}
				}
				if(IsPlayerConnected(strval(inputtext)) && tempsearch != playerid)
				{
				    ch2[tempo1][playerid] = 1;
				    otherpl[playerid] = tempsearch;
				    break;
				}
			}
			if(ch2[tempo1][playerid]==-1 || !IsPlayerConnected(otherpl[playerid])) return ShowPlayerDialog(playerid,89,DIALOG_STYLE_INPUT,"Fight against...","The User you typed was not found\n\nType the name or the playeride of the opponent you want to fight against :","Submit","Abort");
			if(playerid == otherpl[playerid]) return ShowPlayerDialog(playerid,89,DIALOG_STYLE_INPUT,"Fight against...","You entered your own Username\n\nType the name or the playerid of the opponent you want to fight against :","Submit","Abort");
			if(lobbi[otherpl[playerid]][inside] == 0) return ShowPlayerDialog(playerid,89,DIALOG_STYLE_INPUT,"Fight against...","The User you wanted to fight against is busy, try again later\n\nType the name or the playerid of the opponent you want to fight against :","Submit","Abort");
            new mynam[16];
            SendClientMessage(playerid,COLOR_GREY,"Your opponent has been asked whether he wants to accept your challenge");
			for(new cle=0;cle!=9;cle++) SendClientMessage(playerid,COLOR_RED," ");
			GetPlayerName(playerid,mynam,16);
			otherpl[otherpl[playerid]] = playerid,ch2[active][playerid] = 1,ch2[active][otherpl[playerid]] = 1;
			format(ch2[tempo3][playerid],128,"You have been challenged by %s for a 1on1 Deathmatch at Spot %d , using Weapon %s\n\nPlease decide now, if you want to accept or decline this request",mynam,chosentrack[playerid],WepNames[global_dm[chosentrack[playerid]][weapon]]);
			ShowPlayerDialog(otherpl[playerid],69,DIALOG_STYLE_MSGBOX,"You have been challenged",ch2[tempo3][playerid],"Accept","Decline");

	        return 1;
	    }
	    case 60: //race 1on1 accept/decline
	    {
	        if(!response)
	        {
	            TogglePlayerControllable(otherpl[playerid],1);
	            //ShowPlayerDialog(otherpl[playerid],0,35,"You request has been declined","The person you wanted to race against declined your request\n\nDont worry, you still can challenge other players or go for the world record","Ok"," ");
                SendClientMessage(otherpl[playerid], COLOR_RED, "The person you wanted to race against declined your request");
	        	for(new cle=0;cle!=9;cle++) SendClientMessage(otherpl[playerid],COLOR_RED," ");
	        	
				lobbi[otherpl[playerid]][challenge] = 0;
				ForceClassSelection(otherpl[playerid]);
				SetPlayerHealth(otherpl[playerid],0);
			    return 1;
			}
			new nm2[16];
		    GetPlayerName(playerid,nm2,MAX_PLAYER_NAME);
			strins(nm2,"[IC]",0);
			SetPlayerName(playerid,nm2);
			
			chosentrack[playerid] = chosentrack[otherpl[playerid]];
			SetPlayerVirtualWorld(playerid,playerid+1);
			SetPlayerVirtualWorld(otherpl[playerid],playerid+1);
			SetPlayerSkin(playerid,pl_skin[playerid]);
			SetPlayerSkin(otherpl[playerid],pl_skin[otherpl[playerid]]);
	  		SetCameraBehindPlayer(playerid);
	  		SetCameraBehindPlayer(otherpl[playerid]);
	  		SetPlayerInterior(playerid,0);
	  		SetPlayerInterior(otherpl[playerid],0);
			veh[playerid] = CreateVehicle(global_tracks[chosentrack[otherpl[playerid]]][car],global_tracks[chosentrack[otherpl[playerid]]][startx],global_tracks[chosentrack[otherpl[playerid]]][starty],global_tracks[chosentrack[otherpl[playerid]]][startz],global_tracks[chosentrack[otherpl[playerid]]][startrot],random(252),random(252),1);
            AddVehicleComponent(veh[playerid],1009);
			veh[otherpl[playerid]] = CreateVehicle(global_tracks[chosentrack[otherpl[playerid]]][car],global_tracks[chosentrack[otherpl[playerid]]][startx2],global_tracks[chosentrack[otherpl[playerid]]][starty2],global_tracks[chosentrack[otherpl[playerid]]][startz2],global_tracks[chosentrack[otherpl[playerid]]][startrot],random(252),random(252),1);
            AddVehicleComponent(veh[otherpl[playerid]],1009);
			SetVehicleVirtualWorld(veh[playerid],playerid+1);
			SetVehicleVirtualWorld(veh[otherpl[playerid]],playerid+1);
			PutPlayerInVehicle(playerid,veh[playerid],0);
			PutPlayerInVehicle(otherpl[playerid],veh[otherpl[playerid]],0);
		    TogglePlayerControllable(playerid,0);
		    TogglePlayerControllable(otherpl[playerid],0);
		    GameTextForPlayer(playerid,"~r~5",1000,3);
		    GameTextForPlayer(otherpl[playerid],"~r~5",1000,3);
		    SetTimerEx("racestart2",1000,0,"i",playerid);
		    SetTimerEx("racestart2",1000,0,"i",otherpl[playerid]);
		    inrace[playerid] = 1,countdown2[playerid] = 5;
		    inrace[otherpl[playerid]] = 1,countdown2[otherpl[playerid]] = 5;
		    lobbi[otherpl[playerid]][challenge] = 2,lobbi[playerid][inside] = 0,lobbi[otherpl[playerid]][inside] = 0;
			lobbi[playerid][challenge] = 2;
			SetPlayerRaceCheckpoint(playerid,1,global_tracks[chosentrack[playerid]][zielx],global_tracks[chosentrack[playerid]][ziely],global_tracks[chosentrack[playerid]][zielz],0,0,0,5);
            SetPlayerRaceCheckpoint(otherpl[playerid],1,global_tracks[chosentrack[playerid]][zielx],global_tracks[chosentrack[playerid]][ziely],global_tracks[chosentrack[playerid]][zielz],0,0,0,5);
	    
	    }
	    case 69: //dm 1on1 accep/decline
	    {
	        if(!response)
	        {
	            TogglePlayerControllable(otherpl[playerid],1);
	            //ShowPlayerDialog(otherpl[playerid],0,35,"You request has been declined","The person you wanted to fight against declined your request\n\nDont worry, you still can challenge other players","Ok"," ");
                SendClientMessage(otherpl[playerid], COLOR_RED, "The person you wanted to fight against declined your request");
	        	for(new cle=0;cle!=9;cle++) SendClientMessage(otherpl[playerid],COLOR_RED," ");

				lobbi[otherpl[playerid]][challenge] = 0;
				ForceClassSelection(otherpl[playerid]);
				SetPlayerHealth(otherpl[playerid],0);
			    return 1;
			}
			new nm2[16];
		    GetPlayerName(playerid,nm2,MAX_PLAYER_NAME);
			strins(nm2,"[IC]",0);
			SetPlayerName(playerid,nm2);
			
			SetPlayerInterior(playerid,0);
	  		SetPlayerInterior(otherpl[playerid],0);
	  		TogglePlayerControllable(playerid,1);
	  		TogglePlayerControllable(otherpl[playerid],1);
			SetPlayerHealth(playerid,30);
			SetPlayerHealth(otherpl[playerid],30);
			SetPlayerVirtualWorld(playerid,playerid+1);
			SetPlayerVirtualWorld(otherpl[playerid],otherpl[playerid]+1);
			SetPlayerSkin(playerid,pl_skin[playerid]);
			SetPlayerSkin(otherpl[playerid],pl_skin[otherpl[playerid]]);
	  		SetCameraBehindPlayer(playerid);
	  		SetCameraBehindPlayer(otherpl[playerid]);
	  		GivePlayerWeapon(playerid,global_dm[chosentrack[otherpl[playerid]]][weapon],99999);
	  		GivePlayerWeapon(otherpl[playerid],global_dm[chosentrack[otherpl[playerid]]][weapon],99999);
		    ShowPlayerDialog(playerid,77,DIALOG_STYLE_MSGBOX,"Fight started","The Match started, get in position\nIn 10 seconds you will be able to see your opponent","Ok"," ");
            ShowPlayerDialog(otherpl[playerid],77,DIALOG_STYLE_MSGBOX,"Fight started","The Match started, get in position\nIn 10 seconds you will be able to see your opponent","Ok"," ");
		    SetTimerEx("dmstart",10000,0,"i",playerid); //absichtlich nur einer
		    inrace[playerid] = 1,inrace[otherpl[playerid]] = 1;
		    ForceClassSelection(playerid);
		    ForceClassSelection(otherpl[playerid]);
		    lobbi[otherpl[playerid]][challenge] = 3,lobbi[playerid][challenge] = 3;
		    lobbi[playerid][inside] = 0,lobbi[otherpl[playerid]][inside] = 0;

			SetPlayerPos(playerid,global_dm[chosentrack[otherpl[playerid]]][spx],global_dm[chosentrack[otherpl[playerid]]][spy],global_dm[chosentrack[otherpl[playerid]]][spz]);
			SetPlayerPos(otherpl[playerid],global_dm[chosentrack[otherpl[playerid]]][spx],global_dm[chosentrack[otherpl[playerid]]][spy],global_dm[chosentrack[otherpl[playerid]]][spz]);

			SetPlayerWorldBounds(playerid,global_dm[chosentrack[otherpl[playerid]]][spx]+100,global_dm[chosentrack[otherpl[playerid]]][spx]-100,global_dm[chosentrack[otherpl[playerid]]][spy]+100,global_dm[chosentrack[otherpl[playerid]]][spy]-100);
			SetPlayerWorldBounds(otherpl[playerid],global_dm[chosentrack[otherpl[playerid]]][spx]+100,global_dm[chosentrack[otherpl[playerid]]][spx]-100,global_dm[chosentrack[otherpl[playerid]]][spy]+100,global_dm[chosentrack[otherpl[playerid]]][spy]-100);

	    }
	    case 19:
	    {
	        if(!response) Kick(playerid);
			ShowPlayerDialog(playerid,18,DIALOG_STYLE_INPUT,"2nd Step - Your email adress","Now please enter a valid email adress, from which we can contact you in the case you won\nWe dont check whether the email adress is valid\nWe recommend you to enter a valid mail, as you cant change this email adress\nIf youve won, but you doesnt answer in less time than a week, you dont have any rights anymore on the price","Submit","Exit");
	    
	        return 1;
	    }
	    case 18:
	    {
	        if(!response) Kick(playerid);
	        if(!strlen(inputtext)) return ShowPlayerDialog(playerid,18,DIALOG_STYLE_INPUT,"2nd Step - Your email adress","Now please enter a valid email adress, from which we can contact you in the case you won\nWe dont check whether the email adress is valid\nWe recommend you to enter a valid mail, as you cant change this email adress\nIf youve won, but you doesnt answer in less time than a week, you dont have any rights anymore on the price","Submit","Exit");
            format(file_name[playerid],128,"%s.usr.ini",hdwid[playerid]);
			INI_Open(file_name[playerid]);
			format(formal[playerid],128,"%s",hdwid[playerid]);
	        INI_WriteInt(formal[playerid],1);
			format(formal[playerid],128,"%s-racer",hdwid[playerid]);
	        INI_WriteFloat(formal[playerid],1.0000);
	        format(formal[playerid],128,"%s-racew",hdwid[playerid]);
	        INI_WriteInt(formal[playerid],1);
	        format(formal[playerid],128,"%s-racelo",hdwid[playerid]);
	        INI_WriteInt(formal[playerid],1);
	        format(formal[playerid],128,"%s-dmkills",hdwid[playerid]);
	        INI_WriteInt(formal[playerid],1);
	        format(formal[playerid],128,"%s-dmdeath",hdwid[playerid]);
	        INI_WriteInt(formal[playerid],1);
	        format(formal[playerid],128,"%s-dmratio",hdwid[playerid]);
	        INI_WriteFloat(formal[playerid],1.0000);
	        format(formal[playerid],128,"%s-email",hdwid[playerid]);
	        INI_WriteString(formal[playerid],inputtext);
	        
	        INI_Save();
	        INI_Close();
	        
	        ShowPlayerDialog(playerid,17,DIALOG_STYLE_MSGBOX,"Registration complete","Congratulations - the registration was sucessfull\nYou can now start with challenging other players for rising in the toplist\nIf you want to check the prices out, visit our website www.ISA-MPL.com\n\nThis server doesnt needs any passwords, as it gathered some anonym informations to identify you\n\nGood Luck and Have Fun,\nThe ISA-MPL Administration","Ok"," ");
	        loggedin[playerid] = 1;
	        return 1;
	    }
	    case 177:
	    {
            if(!response || !strlen(inputtext)) return 0;
	        new message [128];
	        new clickedplayer[MAX_PLAYER_NAME];
	        new playername[MAX_PLAYER_NAME];
	        GetPlayerName(ClickedPlayerID[playerid], clickedplayer, sizeof(clickedplayer)); 
	        GetPlayerName(playerid, playername, sizeof(playername));
	        format(message, sizeof(message), "You sent %s(%d): %s", clickedplayer, ClickedPlayerID, inputtext); 
	        SendClientMessage(playerid, 0xFFFFFFFF, message); 
	        for(new cle=0;cle!=9;cle++) SendClientMessage(playerid,COLOR_RED," ");
	        format(message, sizeof(message), "PM from %s(%d): %s", playername, playerid, inputtext); 
	        SendClientMessage(ClickedPlayerID[playerid], 0xFFFFFFFF, message); 
	        for(new cle=0;cle!=9;cle++) SendClientMessage(ClickedPlayerID[playerid],COLOR_RED," ");
	        return 1;
	    
	    }
	    case 91:
	    {
	        if(!response) return 0;
			lobbi[playerid][challenge] = listitem+1;
			if(lobbi[playerid][challenge] <= 3)
			{
			    SetPlayerPos(playerid,0,0,5);
				SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
				SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
				ForceClassSelection(playerid);
				SetPlayerInterior(playerid,0);
				SetPlayerHealth(playerid,0);
				inrace[playerid] = 1;
			}
			if(lobbi[playerid][challenge] == 4)
			{
			    new nm2[16];
			    GetPlayerName(playerid,nm2,MAX_PLAYER_NAME);
				strins(nm2,"[IC]",0);
				SetPlayerName(playerid,nm2);
      		 	SetPlayerInterior(playerid,0);
			    SetPlayerVirtualWorld(playerid,0);
			    lobbi[playerid][inside] = 0;
			    SetPlayerHealth(playerid,50);
			    SetPlayerArmour(playerid,0);
			    inrace[playerid] = 1;
			    ResetPlayerWeapons(playerid);
			    GivePlayerWeapon(playerid,4,1);
			    GivePlayerWeapon(playerid,24,999999);
			    GivePlayerWeapon(playerid,26,999999);
			    GivePlayerWeapon(playerid,29,999999);
			    GivePlayerWeapon(playerid,31,999999);
			    GivePlayerWeapon(playerid,34,999999);
			    GivePlayerWeapon(playerid,46,1);
				SetPlayerPos(playerid,float(random(366+101)-101),float(random(2094-1600)+1600),random(200)+700);
				SetPlayerWorldBounds(playerid,366.2648,-101.2526,2094.6494,1599.8019);

				SendClientMessage(playerid,COLOR_RED,"Press ENTER to get back to the lobby");
				for(new cle=0;cle!=9;cle++) SendClientMessage(playerid,COLOR_RED," ");
			}
			return 1;
		}
	}
	return 1;
}

forward dmstart(playerid);
public dmstart(playerid)
{
	if(!IsPlayerConnected(otherpl[playerid]))
	{
	    lobbi[playerid][inside] = 1,lobbi[playerid][challenge] = 0;
	    ForceClassSelection(playerid);
	    SetPlayerHealth(playerid,0);
		ShowPlayerDialog(playerid,983,DIALOG_STYLE_MSGBOX,"Error","The enemy you wanted to fight has quit","Ok"," ");
		return 1;
	}
	if(!IsPlayerConnected(playerid))
	{
		lobbi[otherpl[playerid]][inside] = 1,lobbi[otherpl[playerid]][challenge] = 0;
	    ForceClassSelection(otherpl[playerid]);
	    SetPlayerHealth(otherpl[playerid],0);
		ShowPlayerDialog(otherpl[playerid],983,DIALOG_STYLE_MSGBOX,"Error","The enemy you wanted to fight has quit","Ok"," ");
		return 1;
	}

	SetPlayerVirtualWorld(otherpl[playerid],GetPlayerVirtualWorld(playerid));
	GameTextForPlayer(playerid,"~g~Go",1000,4);
	GameTextForPlayer(otherpl[playerid],"~g~Go",1000,4);

 	return 1;
}

public racestart(playerid)
{
    TextDrawShowForPlayer(playerid,trackrecord[playerid]);
	format(formal[playerid],128,"             - Record : ~r~%s with %.1f seconds~w~ - Your Time : %.1f",global_records[chosentrack[playerid]][name],global_records[chosentrack[playerid]][time],floatdiv(playertime[playerid],10));
	TextDrawSetString(trackrecord[playerid],formal[playerid]);
	if(!IsPlayerInAnyVehicle(playerid) || inrace[playerid] == 0)
	{
	    TextDrawHideForPlayer(playerid,trackrecord[playerid]);
	    return 1;
	}
	if(countdown[playerid] != 0)
	{
	    TogglePlayerControllable(playerid,0);
	    switch(countdown[playerid])
	    {
	        case 1:GameTextForPlayer(playerid,"~g~Go",1000,3);
	        case 2:GameTextForPlayer(playerid,"~y~1",1000,3);
	        case 3:GameTextForPlayer(playerid,"~r~2",1000,3);
	        case 4:GameTextForPlayer(playerid,"~r~3",1000,3);
	        case 5:GameTextForPlayer(playerid,"~r~4",1000,3);
		}
		countdown[playerid] -= 1;
	    SetTimerEx("racestart",1000,0,"i",playerid);
	    return 1;
	}
	playertime[playerid] += 1;
	SetTimerEx("racestart",100,0,"i",playerid);
	TogglePlayerControllable(playerid,1);
	return 1;
}

public racestart2(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid) || inrace[playerid] == 0)
	{
	    return 1;
	}
	if(countdown2[playerid] != 0)
	{
	    TogglePlayerControllable(playerid,0);
	    switch(countdown2[playerid])
	    {
	        case 1:GameTextForPlayer(playerid,"~g~Go",1000,3);
	        case 2:GameTextForPlayer(playerid,"~y~1",1000,3);
	        case 3:GameTextForPlayer(playerid,"~r~2",1000,3);
	        case 4:GameTextForPlayer(playerid,"~r~3",1000,3);
	        case 5:GameTextForPlayer(playerid,"~r~4",1000,3);
		}
		countdown2[playerid] -= 1;
	    SetTimerEx("racestart2",1000,0,"i",playerid);
	    return 1;
	}
	TogglePlayerControllable(playerid,1);
	lobbi[playerid][challenge] = 2,ch2[active][playerid] = 1;
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new dialog[128];
 	new clickedplayer[MAX_PLAYER_NAME];
  	GetPlayerName(clickedplayerid, clickedplayer, sizeof(clickedplayer));
   	format(dialog, sizeof(dialog), "Send a Message to %s", clickedplayer);
    ShowPlayerDialog(playerid,177,DIALOG_STYLE_INPUT,"Private Message",dialog,"Send","Cancel");
    ClickedPlayerID[playerid] = clickedplayerid;
	return 1;
}

stock sscanf(string[], format[], {Float,_}:...)
{
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs();
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if (ch >= '0' && ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return 1;
					}
				}
				while ((ch = string[stringPos]) && ch != ' ');
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					ch,
					num = 0;
				while ((ch = string[stringPos++]))
				{
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						case ' ':
						{
							break;
						}
						default:
						{
							return 1;
						}
					}
				}
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{
                new tmp[25];
                strmid(tmp, string, stringPos, stringPos+sizeof(tmp)-2);
				setarg(paramPos, 0, _:floatstr(tmp));
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != ' ')
					{
						setarg(paramPos, i++, ch);
					}
					if (!i) return 1;
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != ' ')
		{
			stringPos++;
		}
		while (string[stringPos] == ' ')
		{
			stringPos++;
		}
		paramPos++;
	}
	while (format[formatPos] == 'z') formatPos++;
	return format[formatPos];
}

stock IsValidSkin(skinid)
{
    #define MAX_BAD_SKINS (14)
    new
            badSkins[MAX_BAD_SKINS] = {
        3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 273, 289
    };
    for(new i = 0; i < MAX_BAD_SKINS; i++)
    {
        if(skinid == badSkins[i]) return false;
    }
    #undef MAX_BAD_SKINS
    return 1;
}
