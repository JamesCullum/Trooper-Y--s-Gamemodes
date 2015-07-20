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
#include <MapAndreas>
#include <PointToPoint>
#include <mysql>
#include <nowebu>
#include <Obj_Streamer>

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define ammo 700
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define olquellen 50
#define slots 21

//todo:
//flakgeschütz (5k,25 kills) (3502)
//hydrafabrik (8251)

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

new loggedin[slots],player_name[slots],adminlevel[slots];
new Text:leiste_oben[2],teammoney[2],Float:comzoom[2],Float:calcpos[2];
new vote = 0,votes = 0,teamnumber[2],Float:comview[2][2],comisbuilding[2],Float:combuilding[2][3],combuildid[2]; //comview[team][x/y]
new leistentext[slots][256],combuildinginprogress[2],sub_number[2],Float:subpos[2][olquellen][3],isspawned[slots];
new comcar[2],Text:classinfo[slots],oilhint[30],formattext[128],blockradar,mysqlquery[slots][128],veh[slots];
new subpos_valid[2][olquellen],staticobjects[20],Text3D:playertext[slots],Text:info_bar,Text:counter;
new teamkills[2],meat[2],playersonline,missobjects1[20],missobjects2[100],cpnumber,missmsg[128],miss1pickup;
new ausbildungstime,ausbtimerid,producedtanks[2],producedhunters[2],producedcars[2],tknm[16],wartung = 0,Text:rang[slots];
new capture[10],helinpc[slots],a51obj[10],meattimes = 0,Text:tixtdraw[slots][3];

enum structype
{
	clone,
	CloneSub,
	SAM,
	Armory,
	CloneResearch,
	TankFac,
	HunterFac,
	OilWellDerrick,
	oilsource,
	CarFac,
	Fence,
	Hospital
}
enum opti
{
	exists,
	model,
	Text3D:bubbleid,
	id,
	health,
	Float:placex,
	Float:placey,
	Float:placez,
}
#define gebaudeanzahl 200
new gebaude[gebaudeanzahl][2][opti],gesamtgebaude[2] = 0;
new building_number[structype][2];

enum oilopti
{
	taken,
	Float:posx,
	Float:posy,
	Float:posz
}
new oil_info[olquellen][oilopti];

enum options
{
	level,
	position,
	team,
	klasse,
	kills,
	deaths
}
new player[slots][options];

forward voteoff(playerid);
forward geldausgabe();

main()
{
	return 1;
}

forward nodrop();
public nodrop()
{
    SetTimer("nodrop",60000*10,0);
    new nodropcmd[256];
	format(nodropcmd,256,"UPDATE nodrop SET value = '%d'",random(100));
	mysql_query(nodropcmd);
	return 1;
}

forward info_change();
public info_change()
{
	switch(random(11))
	{
		case 0:TextDrawSetString(info_bar,"Besuch unser Forum: www.savandreas.com");
		case 1:TextDrawSetString(info_bar,"Das Team eines Spielers, der einen 40 killstreak schafft, gewinnt");
        case 2:TextDrawSetString(info_bar,"Hilf deinem Commander, indem du ihm wichtige Positionen zeigst");
        case 3:TextDrawSetString(info_bar,"Spam nicht. Es funktioniert nicht, auch wenn du das glaubst");
        case 4:TextDrawSetString(info_bar,"Wenn kein Admin online ist, kannst du /votekick benutzen");
        case 5:TextDrawSetString(info_bar,"Benutze deine Freundesliste per /friends");
        case 6:TextDrawSetString(info_bar,"Du moechtest in unser Team? www.savandreas.com");
        case 7:TextDrawSetString(info_bar,"Benutz ![text] fuer Teamchats & /pm fuer PMs");
        case 8:TextDrawSetString(info_bar,"Du kannst Einzelspielermissionen per /mission starten");
		case 9:TextDrawSetString(info_bar,"Du kannst dich mit anderen Spielern /duell ieren um SC");
		case 10:TextDrawSetString(info_bar,"Verdiene Savandreas Coins, /duell iere dich und kauf dir coole Features");
	}
	TextDrawShowForAll(info_bar);

}

forward showachiv(playerid);
public showachiv(playerid)
{
	new ids[256],ffield[256];
	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT achievements FROM achievements WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_num_rows() == 0)
	{
	    mysql_free_result();
		for(new gor=1;gor<=200;gor++) format(ids,256,"%s0",ids);
		mysql_free_result();
		format(mysqlquery[playerid],256,"INSERT INTO achievements (name,achievements) VALUES ('%s','%s')",player_name[playerid],ids);
		mysql_query(mysqlquery[playerid]);
	}
	else mysql_fetch_field("achievements",ids);
	mysql_free_result();
	
	new mid[128],pos[2],endstring[2048];
	for(new i=1;i<=200;i++)
	{
		pos[0] = i-1;
		pos[1] = i;
		strmid(mid,ids,pos[0],pos[1]);
        format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE nummer = '%d' AND server='1'",i);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
		if(mysql_num_rows() == 0)
		{
		    mysql_free_result();
			continue;
		}
		mysql_fetch_field("titel",ffield);
		mysql_free_result();
		if(strval(mid) == 0) format(endstring,2048,"{FF0000}%s\n%s",ffield,endstring);
		else format(endstring,2048,"{33FF00}%s\n%s",ffield,endstring);
	}
	ShowPlayerDialog(playerid,911,2,"Auszeichnungen",endstring,"Bedingungen","Schließen");
	return 1;
}

forward triggerachiv(playerid,idi);
public triggerachiv(playerid,idi)
{
	if(IsPlayerNPC(playerid)) return 1;
    new tlong[512];
    new ids[256],ffield[256];

	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT achievements FROM achievements WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_num_rows() == 0)
	{
	    mysql_free_result();
		for(new gor=1;gor<=200;gor++) format(ids,256,"%s0",ids);
		mysql_free_result();
		format(tlong,512,"INSERT INTO achievements (name,achievements) VALUES ('%s','%s')",player_name[playerid],ids);
		mysql_query(tlong);
	}
	else mysql_fetch_field("achievements",ids);
	mysql_free_result();
	
    new mid[128],pos[2];
	for(new i=1;i<=200;i++)
	{
		pos[0] = i-1;
		pos[1] = i;
		strmid(mid,ids,pos[0],pos[1]);
		if(i == idi)
		{
		    if(strval(mid) == 1) return 1;
		    GetPlayerName(playerid,player_name[playerid],16);
			format(mysqlquery[playerid],256,"UPDATE login SET rlmoney=rlmoney+1 WHERE name = '%s'",player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
			getrlmoney(playerid);
			
	        format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE nummer = '%d'",i);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			new tit[128];
			mysql_fetch_field("string",ffield);
			mysql_fetch_field("titel",tit);
			format(ffield,256,"~r~AUSZEICHNUNG ERHALTEN~n~~n~~g~%s~n~~w~%s",tit,ffield);
			mysql_free_result();
			GameTextForPlayer(playerid,ffield,5000,3);
			strdel(ids,pos[0],pos[1]);
			strins(ids,"1",pos[0]);
			format(mysqlquery[playerid],256,"UPDATE achievements SET lastachv = '%s' WHERE name = '%s'",tit,player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
			new tmsg[256];
			format(tmsg,256,"Spieler %s hat die Auszeichnung '%s' erhalten",player_name[playerid],tit);
			SendClientMessageToAll(COLOR_GREEN,tmsg);
			break;
		}
	}
	format(tlong,512,"UPDATE achievements SET achievements = '%s' WHERE name = '%s'",ids,player_name[playerid]);
	mysql_query(tlong);
	
	SendClientMessage(playerid,COLOR_GREEN,"Du hast eine Auszeichnung erhalten");
	SendClientMessage(playerid,COLOR_GREEN,"Schau dir per /auszeichnungen alle Auszeichnungen an");
	
	return 1;
}

public OnGameModeInit()
{
    MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	StreamObject_OnGameModeInit();
    SetGloabalViewDistanceToStream(500);

    AllowAdminTeleport(1);
    SetTimer("geldausgabe",10000,0);
    if(!fexist("cp.mission.ini")) print("no file");
    SetTimer("nodrop",60000*10,0);
	SetGameModeText("Strategy TDM");
	SendRconCommand("mapname Savandreas");
	
	SetWeather(07);
	
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	AllowInteriorWeapons(0);
	DisableInteriorEnterExits();
	
	CreateChristmasTree(-315.5612,1743.0107,43.0388);
	
	staticobjects[0] = CreateObject(974, 2539.39453125, 2823.3244628906, 12.598052978516, 0, 0, 270.67565917969);
	staticobjects[1] = CreateObject(974, 2616.130859375, 2831.1013183594, 12.598052978516, 0, 0, 270.67565917969);
	
	staticobjects[2] = CreateObject(16662, 1932.2740,-2409.6987,1200.6908, 0.0, 0.0, -27.0);
	staticobjects[3] = CreateObject(3983, 1930.715088, -2417.489990, 1201.556519, 0.0000, 0.0000, 0.0000);
	staticobjects[4] = CreateObject(3983, 1938.750122, -2419.424561, 1201.557129, 0.0000, 268.0403, 0.0000);
	staticobjects[5] = CreateObject(3983, 1922.684082, -2417.233643, 1201.763428, 0.0000, 96.1526, 9.4538);
	staticobjects[6] = CreateObject(3983, 1932.634888, -2426.096436, 1201.592285, 0.0000, 96.1526, 98.8352);
	staticobjects[7] = CreateObject(3983, 1934.155273, -2406.747803, 1201.625122, 0.0000, 254.1853, 98.8352);
	staticobjects[8] = CreateObject(3983, 1938.325562, -2415.805176, 1216.350342, 359.1406, 179.4143, 95.3974);
	staticobjects[9] = CreateObject(1232, 1934.736694, -2413.839844, 1202.169678, 0.0000, 0.0000, 0.0000);
	staticobjects[10] = CreateObject(1232, 1935.306519, -2421.486816, 1202.169678, 0.0000, 0.0000, 0.0000);
	staticobjects[11] = CreateObject(1232, 1928.441406, -2421.002441, 1202.218506, 0.0000, 0.0000, 0.0000);
	staticobjects[12] = CreateObject(1232, 1927.940186, -2413.950928, 1202.244629, 0.0000, 0.0000, 0.0000);
	staticobjects[13] = CreateObject(1232, 1922.012695, -2430.574951, 1202.355225, 0.0000, 53.2850, 55.8633);
	staticobjects[14] = CreateObject(1232, 1942.271362, -2427.741211, 1201.987061, 0.0000, 53.2850, 138.3693);
	staticobjects[15] = CreateObject(1232, 1941.111938, -2403.214844, 1201.988281, 0.0000, 53.2850, 237.2046);
	staticobjects[16] = CreateObject(1232, 1918.437500, -2406.737793, 1201.562622, 0.0000, 53.2850, 321.4290);
	
	a51obj[0] = CreateObject(985, 96.669350, 1920.033936, 18.855873, 0.0000, 0.0000, 90.0000);//Area 51 Entrance Gate
	a51obj[1] = CreateObject(10184, 214.337631, 1875.739136, 13.162411, 0.0000, 0.0000, 270.0000);//Area 51 Garage Shutter
	a51obj[2] = CreateObject(970, 245.81625366211, 1863.0125732422, 19.592105865479, 92, 0, 37.849914550781);
	a51obj[3] = CreateObject(970, 246.37686157227, 1862.65625, 19.605094909668, 91.99951171875, 0, 37.847900390625);
	a51obj[4] = CreateObject(975, 256.42984008789, 1844.9969482422, 9.4248466491699, 0, 0, 90);
	a51obj[5] = CreateObject(987, 260.32424926758, 1821.232421875, 3.290093421936, 270, 0, 0);
	
	capture[0] = GangZoneCreate(1349.0438,1174.6425,1626.8640,1870.0157);
	GangZoneShowForAll(capture[0],COLOR_YELLOW);
	capture[1] = CreatePickup(2993,23,1585.7305,1447.5050,10.8352,-1);
	capture[4] = AddStaticVehicle(577,1584.0732,1188.7935,10.7769,183.4205,0,0);
	CreateVehicle(401,0,-500,10.7769,0,0,0,5); //bugfresser
	capture[7] = 0;
	capture[2] = GangZoneCreate(-444.4853,1525.9384,-247.2003,1643.3119);
	GangZoneShowForAll(capture[2],COLOR_YELLOW);
	capture[3] = CreatePickup(2993,23,-362.1327,1584.2163,76.4585,-1);
	capture[8] = 0,capture[9] = 0; //iscapturing
	mysql_init(1);
	mysql_connect("xxx", "xxx", "xxx", "xxx");
	calcpos[0] = 0.0,calcpos[1] = 0.0;
    AddPlayerClass(276, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(287, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(285, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(153, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(284, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(260, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	DisableInteriorEnterExits();
	comcar[0] = AddStaticVehicle(428,2582.3469238281,2845.2854003906,10.72031211853,0,0,0);
	SetVehicleVirtualWorld(comcar[0],50);
	comcar[1] = AddStaticVehicle(428,2576.1403808594,2845.4521484375,10.72031211853,0,0,0);
	SetVehicleVirtualWorld(comcar[1],50);
	LinkVehicleToInterior(comcar[0],8);
	LinkVehicleToInterior(comcar[1],8);
    comzoom[0] = 200.0,comzoom[1] = 200.0,teammoney[0] = 4000,teammoney[1] = 4000;
    
    info_bar = TextDrawCreate(0.000000, 437.000000, "Besuch unser Forum : savandreas.com");
	TextDrawBackgroundColor(info_bar, 255);
	TextDrawFont(info_bar, 1);
	TextDrawLetterSize(info_bar, 0.500000, 1.000000);
	TextDrawColor(info_bar, -1);
	TextDrawSetOutline(info_bar, 1);
	TextDrawSetProportional(info_bar, 1);
	TextDrawUseBox(info_bar, 1);
	TextDrawBoxColor(info_bar, 255);
	TextDrawTextSize(info_bar, 840.000000, 40.000000);
	SetTimer("info_change",15000,1);
	
	//ShowPlayerMarkers(0);
	//Map entfernt
    
	new tk = 0;
    INI_Open("oil.pos.txt");
    for(new addpick=0;addpick!=olquellen;addpick++)
    {
        new Float:readit[3],form[128];
        format(form,128,"%dx",addpick);
        if(INI_ReadFloat(form))
        {
	        readit[0] = INI_ReadFloat(form);
	        format(form,128,"%dy",addpick);
	        readit[1] = INI_ReadFloat(form);
	        format(form,128,"%dz",addpick);
	        readit[2] = INI_ReadFloat(form);
	        oil_info[addpick][posx] = readit[0];
	        oil_info[addpick][posy] = readit[1];
	        oil_info[addpick][posz] = readit[2];
	        building_number[oilsource][0] += 1;
			tk+=1;
			if(tk == 5)
			{
			    combuilding[0][0] = oil_info[addpick][posx];
			    combuilding[0][1] = oil_info[addpick][posy];
			    combuilding[0][2] = oil_info[addpick][posz];
				comisbuilding[0] = 0,combuildinginprogress[0] = 0;
				gebaude[gesamtgebaude[0]][0][id] = CreateObjectToStream(3873,combuilding[0][0],combuilding[0][1],combuilding[0][2]+15.0,0,0,0);
				gebaude[gesamtgebaude[0]][0][health] = 50000;
				gebaude[gesamtgebaude[0]][0][placex] = combuilding[0][0];
				gebaude[gesamtgebaude[0]][0][placey] = combuilding[0][1];
				gebaude[gesamtgebaude[0]][0][placez] = combuilding[0][2]+5;
				gebaude[gesamtgebaude[0]][0][model] = 3873;
				gebaude[gesamtgebaude[0]][0][exists] = 1;
				subpos[0][0][0] = gebaude[gesamtgebaude[0]][0][placex]+15;
				subpos[0][0][1] = gebaude[gesamtgebaude[0]][0][placey]+15;
				subpos_valid[0][0] = 1;
				MapAndreas_FindZ_For2DCoord(subpos[0][0][0],subpos[0][0][1],subpos[0][0][2]);
				comview[0][0] = gebaude[gesamtgebaude[0]][0][placex];
				comview[0][1] = gebaude[gesamtgebaude[0]][0][placey];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",1,gebaude[gesamtgebaude[0]][0][health]);
				gebaude[gesamtgebaude[0]][0][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[0][0][placex],gebaude[0][0][placey],gebaude[0][0][placez],float(100),0,0);
                building_number[clone][0] = 1,gesamtgebaude[0] = 1;
                sub_number[0] = 1;
                building_number[CloneSub][0] = 1;
			}
			if(tk == 4)
			{
			    combuilding[1][0] = oil_info[addpick][posx];
			    combuilding[1][1] = oil_info[addpick][posy];
			    combuilding[1][2] = oil_info[addpick][posz];
			    comisbuilding[1] = 0,combuildinginprogress[1] = 0;
				gebaude[0][1][id] = CreateObjectToStream(3873,combuilding[1][0],combuilding[1][1],combuilding[1][2]+15.0,0,0,0);
				gebaude[0][1][health] = 50000;
				gebaude[0][1][placex] = combuilding[1][0];
				gebaude[0][1][placey] = combuilding[1][1];
				gebaude[0][1][placez] = combuilding[1][2]+5;
				gebaude[0][1][model] = 3873;
				gebaude[0][1][exists] = 1;
				subpos[1][0][0] = -360.4069;
				subpos[1][0][1] = 2250.3542;
				subpos_valid[1][0] = 1;
				MapAndreas_FindZ_For2DCoord(subpos[1][0][0],subpos[1][0][1],subpos[1][0][2]);
				comview[1][0] = gebaude[0][1][placex];
				comview[1][1] = gebaude[0][1][placey];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",2,gebaude[0][1][health]);
				gebaude[0][1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[0][1][placex],gebaude[0][1][placey],gebaude[0][1][placez],float(100),0,0);
                building_number[clone][1] += 1,gesamtgebaude[1] += 1;
                sub_number[1] += 1;
                building_number[CloneSub][1] = 1;
			}
			if(tk == 9) //airport, eig id 8 bei /source
			{
			    CreatePickup(1580,2,readit[0],readit[1],readit[2]);
			}
			else
			{
				oilhint[addpick] = CreatePickup(2062,1,readit[0],readit[1],readit[2]);
			}
		}
	}
	INI_Close();

    blockradar = GangZoneCreate(-9999999999.999, -9999999999.999, 9999999999.999, 9999999999.9999);
    
    counter = TextDrawCreate(83.000000,303.000000,"Zeit: ~n~5");
	TextDrawUseBox(counter,1);
	TextDrawBoxColor(counter,0x00000066);
	TextDrawTextSize(counter,-23.000000,110.000000);//110
	TextDrawAlignment(counter,2);
	TextDrawBackgroundColor(counter,0x000000ff);
	TextDrawFont(counter,3);
	TextDrawLetterSize(counter,0.399999,1.000000);
	TextDrawColor(counter,0xffffffff);
	TextDrawSetOutline(counter,1);
	TextDrawSetProportional(counter,1);
	TextDrawSetShadow(counter,1);
	
	for(new teams=0;teams<2;teams++)
	{
		leiste_oben[teams] = TextDrawCreate(0.000000, 1.000000, "                  - Team :  - Level :  - Teamgeld :  -");
		TextDrawBackgroundColor(leiste_oben[teams], 255);
		TextDrawFont(leiste_oben[teams], 1);
		TextDrawLetterSize(leiste_oben[teams], 0.500000, 1.000000);
		TextDrawColor(leiste_oben[teams], -1);
		TextDrawSetOutline(leiste_oben[teams], 0);
		TextDrawSetProportional(leiste_oben[teams], 1);
		TextDrawSetShadow(leiste_oben[teams], 1);
		TextDrawUseBox(leiste_oben[teams], 1);
		TextDrawBoxColor(leiste_oben[teams], 2054847098);
		TextDrawTextSize(leiste_oben[teams], 640.000000, 0.000000);
	}
    
    print(" ");
	print(" Savandreas GM - (c) Trooper 2010");
	print(" ");
	
	new still_name[16];
	playersonline = 0;
	for(new quit=0;quit<=slots;quit++)
	{
	    if(IsPlayerConnected(quit) && !IsPlayerNPC(quit))
		{
		    playersonline += 1;
		    GetPlayerName(quit,still_name,16);
		    //printf("Player ID %d / %s is still connected",quit,still_name);
			OnPlayerConnect(quit);
		}
	}
	return 1;
}

public OnGameModeExit()
{
    StreamObject_OnGameModeExit();
    TextDrawDestroy(counter);
	TextDrawDestroy(info_bar);
	for(new de=0;de!=gebaudeanzahl;de++)
	{
	    if(IsValidObject(gebaude[de][0][id]))
		{
			DestroyObjectToStream(gebaude[de][0][id]);
			Delete3DTextLabel(gebaude[de][0][bubbleid]);
		}
	    if(IsValidObject(gebaude[de][1][id]))
		{
			DestroyObjectToStream(gebaude[de][1][id]);
			Delete3DTextLabel(gebaude[de][1][bubbleid]);
		}
	}
	for(new cr=0;cr!=slots;cr++)
	{
		DestroyVehicle(veh[cr]);
		veh[cr] = -1;
		DestroyObjectToStream(GetPVarInt(cr,"samrocket"));
		DestroyPickup(GetPVarInt(cr,"mineid"));
	}
	for(new stat=0;stat!=sizeof(staticobjects);stat++) DestroyObject(staticobjects[stat]);
	print("Savandreas GM exits...");
	return 1;
}

forward clearchat(playerid);
public clearchat(playerid)
{
	for(new cl=0;cl!=12;cl++) SendClientMessage(playerid,COLOR_RED," ");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(GetPVarInt(playerid,"mission") == 1) return SpawnPlayer(playerid);
	if(loggedin[playerid] == 0) return 0;
	if(GetPVarInt(playerid,"choosespawn") == 0)
	{
	    clearchat(playerid);
	    SendClientMessage(playerid,COLOR_RED,"Drücke mit der Maus auf 'Spawn', um deinen Spawnort zu wählen");
	    for(new t=0;t!=5;t++) SendClientMessage(playerid,COLOR_GREY," ");
		switch(classid)
		{
		    case 0:TextDrawSetString(classinfo[playerid],"Klasse : ~r~Sanitaeter~w~~n~Der moderne Sanitaeter beherrscht die Heilkunst perfekt~n~~n~~r~Ausruestung ~w~:~n~]Pfeffer Spray");
		    case 1:TextDrawSetString(classinfo[playerid],"Klasse : ~r~Soldat~w~~n~Soldaten sind die normalen Infanteristen einer Armee~n~Sie sind gut ausgerüstet für den offensiven Kampf~n~~n~~r~Ausruestung ~w~:~n~]Colt M1911~n~]SPAS 12~n~]MP5");
		    case 2:TextDrawSetString(classinfo[playerid],"Klasse : ~r~Scout~w~~n~Scouts sammeln Informationen über Ressourcen und den Gegner~n~Sie sind die hinterhaeltigen Einheiten~n~~n~~r~Ausruestung ~w~:~n~]Remington 700~n~]NIETO 1003~n~]Colt M1911 Silenced");
		    case 5:TextDrawSetString(classinfo[playerid],"Klasse : ~r~Bauarbeiter~w~~n~Der Bauarbeiter ist der Mann für den Notfall~n~Er kann Gebäude reparieren~n~~n~~r~Ausruestung ~w~:~n~]Ithaca 37");
		}
		if(classid == 3 && building_number[TankFac][player[playerid][team]-1] == 0) TextDrawSetString(classinfo[playerid],"Klasse : ~r~Panzerfahrer~w~~n~Panzerfahrer koennen schwere Panzer fahren~n~Panzer toeten Infanterie und koennen Gebaeude angreifen~n~~n~~r~Ausruestung ~w~:~n~]Keine~n~~r~NICHT VERFUEGBAR~w~");
		if(classid == 3 && building_number[TankFac][player[playerid][team]-1] != 0) TextDrawSetString(classinfo[playerid],"Klasse : ~r~Panzerfahrer~w~~n~Panzerfahrer koennen schwere Panzer fahren~n~Panzer toeten Infanterie und koennen Gebaeude angreifen~n~~n~~r~Ausruestung ~w~:~n~]Keine~n~");
		if(classid == 4 && building_number[HunterFac][player[playerid][team]-1] == 0) TextDrawSetString(classinfo[playerid],"Klasse : ~r~Hunter Pilot~w~~n~Hunter Piloten sind die ultimative Waffe gegen alle Bodeneinheiten~n~~n~~r~Ausruestung ~w~:~n~]Keine~n~~r~NICHT VERFUEGBAR~w~");
		if(classid == 4 && building_number[HunterFac][player[playerid][team]-1] != 0) TextDrawSetString(classinfo[playerid],"Klasse : ~r~Hunter Pilot~w~~n~Hunter Piloten sind die ultimative Waffe gegen alle Bodeneinheiten~n~~n~~r~Ausruestung ~w~:~n~]Keine~n~");
		TextDrawShowForPlayer(playerid,classinfo[playerid]);
		SetPlayerPos(playerid, -1820.4644,-149.4375,9.3984);
		SetPlayerFacingAngle(playerid,182.8881);
		SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
		SetPVarInt(playerid,"skin",classid);
	}
	if(GetPVarInt(playerid,"choosespawn") == 1)
	{
	    TextDrawHideForPlayer(playerid,classinfo[playerid]);
	    SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);

		new tendenz;
		if(classid > GetPVarInt(playerid,"prev_class") || (classid == 0 && GetPVarInt(playerid,"prev_class")==5)) tendenz = 1;
	    if(classid < GetPVarInt(playerid,"prev_class") || (classid == 5 && GetPVarInt(playerid,"prev_class")==0)) tendenz = 0;
        SetPVarInt(playerid,"prev_class",classid);
        
		if(tendenz == 1)
		{
			for(new gs=1;gs<=sub_number[player[playerid][team]-1];gs++)
			{
			    if(subpos_valid[player[playerid][team]-1][GetPVarInt(playerid,"entrypoint")+gs] == 1)
			    {
			        SetPVarInt(playerid,"entrypoint",GetPVarInt(playerid,"entrypoint")+gs);
			        break;
			    }
			}
		}
  		else
		{
			for(new gs=1;gs<=sub_number[player[playerid][team]-1];gs++)
			{
			    if(subpos_valid[player[playerid][team]-1][GetPVarInt(playerid,"entrypoint")-gs] == 1)
			    {
			        SetPVarInt(playerid,"entrypoint",GetPVarInt(playerid,"entrypoint")-gs);
			        break;
			    }
			}
		}
		
		//Credits to Luby & Gamer_Z
		new Float:DirX,Float:DirY,Float:DirZ;
		DirX = 1931.7674;
		DirY = -2417.5302;
	 	DirZ = 1200.0000;
        DirX = floatadd(DirX, floatmul(floatdiv(subpos[player[playerid][team]-1][GetPVarInt(playerid,"entrypoint")][0], 3000.0), 1.7062));
        DirY = floatadd(DirY, floatmul(floatdiv(subpos[player[playerid][team]-1][GetPVarInt(playerid,"entrypoint")][1], 3000.0), 1.7577));
        DirZ = floatadd(DirZ, floatmul(subpos[player[playerid][team]-1][GetPVarInt(playerid,"entrypoint")][2], 0.001));
	
	    DestroyPlayerObject(playerid,GetPVarInt(playerid,"spawnflag"));
	    SetPVarInt(playerid,"spawnflag",CreatePlayerObject(playerid,1234,DirX,DirY,DirZ,0,0,0));
	}
	
	if(player[playerid][team] == 0)
	{
	    if(teamnumber[0] > teamnumber[1])
	    {
	        player[playerid][team] = 2;
	        SetPlayerTeam(playerid,2);
	        SetPlayerColor(playerid,COLOR_RED);
	        teamnumber[1] += 1;
	        return 1;
		}
		if(teamnumber[0] < teamnumber[1])
		{
		    player[playerid][team] = 1;
		    SetPlayerTeam(playerid,1);
		    SetPlayerColor(playerid,COLOR_GREEN);
		    teamnumber[0] += 1;
		    return 1;
		}
		if(teamnumber[0] == teamnumber[1])
		{
		    player[playerid][team] = random(1)+1;
		    SetPlayerTeam(playerid,player[playerid][team]);
		    switch(player[playerid][team])
		    {
		        case 1:SetPlayerColor(playerid,COLOR_GREEN);
		        case 2:SetPlayerColor(playerid,COLOR_RED);
			}
			teamnumber[player[playerid][team]-1] += 1;
			return 1;
		}

	}
	return 1;
}

forward miss_win(playerid);
public miss_win(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    triggerachiv(playerid,8);
	
	    cpnumber = 0;
	    
	    new winform[256],winnumber;
	    switch(GetPVarInt(playerid,"diffi"))
	    {
			case 1:winnumber = 1;
            case 2:winnumber = 2;
	        case 3:winnumber = 5;
	        case 4:winnumber = 30;
	        case 5:
			{
				winnumber = 100;
				triggerachiv(playerid,9);
			}
	    }
	    format(winform,256,"Du hast es geschafft\nDu hast %d kills gutgeschrieben bekommen\nDu kannst die Mission nun\nauf einer schwierigeren Stufe nochmal versuchen",winnumber);
	    
		GetPlayerName(playerid,tknm,16);
	    format(mysqlquery[playerid],128,"UPDATE sav_score SET kills=kills+%d WHERE name = '%s'",winnumber,tknm);
		mysql_query(mysqlquery[playerid]);
		
		SetPlayerScore(playerid,GetPlayerScore(playerid)+winnumber);
		
		for(new kb=0;kb!=10;kb++) if(IsPlayerNPC(kb)) Kick(kb);
		dcmd_abort(playerid," ");
		ShowPlayerDialog(playerid,13337,0,"WIN !!!",winform,"Mach","ich");
        for(new cly=0;cly!=10;cly++) SendClientMessage(playerid,COLOR_GREY," ");
	}
	return 1;
}

forward nextcp(playerid);
public nextcp(playerid)
{
	cpnumber += 1;
	switch(GetPVarInt(playerid,"chosenmiss"))
	{
	    case 1:
	    {
		    DisablePlayerCheckpoint(playerid);
		    switch(cpnumber)
		    {
		        case 1:SetPlayerCheckpoint(playerid,-2339.8698,1533.3115,20.2343,1);
		        case 2:SetPlayerCheckpoint(playerid,-2364.0480,1539.1875,20.2343,1);
		        case 3:SetPlayerCheckpoint(playerid,-2375.0598,1538.4737,20.2343,1);
		        case 4:SetPlayerCheckpoint(playerid,-2388.1091,1553.4107,26.0468,1);
		        case 5:SetPlayerCheckpoint(playerid,-2401.3703,1532.5173,26.0468,1);
		        case 6:SetPlayerCheckpoint(playerid,-2424.4982,1557.6213,23.1406,1);
		        case 7:SetPlayerCheckpoint(playerid,-2441.0349,1554.3577,2.1231,1);
		        case 8:SetPlayerCheckpoint(playerid,-2399.8659,1554.4759,2.1171,1);
		    }

		    if(cpnumber == 9)
			{
		        miss1pickup = CreatePickup(1210,22,-2373.1677,1552.5616,2.1898,0);
		        DisablePlayerCheckpoint(playerid);
			}
			if(cpnumber == 10)
			{
				ausbildungstime = 30;

			    SendClientMessage(playerid,COLOR_GREEN,"Wenn du 30 Sekunden überlebst, hast du gewonnen");
			    missobjects2[50] = CreateObject(2944, -2468.340576, 1547.937744, 24.258755, 0.0000, 0.0000, 0.0000);

		    	if(GetPVarInt(playerid,"diffi") >= 4)
		    	{
			        format(missmsg,128,"miss_%d_1",cpnumber-1);
					ConnectNPC("npc3",missmsg);
				}
			    ausbtimerid = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
			}

			format(missmsg,128,"miss_%d_1",cpnumber-1);
		    ConnectNPC("npc1",missmsg);
		    if(GetPVarInt(playerid,"diffi") >= 3)
			{
			    format(missmsg,128,"miss_%d_2",cpnumber-1);
			    ConnectNPC("npc2",missmsg);
			}
		}
		case 2:
		{
		    DisablePlayerCheckpoint(playerid);
		    switch(cpnumber)
		    {
		        case 1:
				{
					SetPlayerCheckpoint(playerid,211.9258,1812.2900,21.8672,1);
					SetTimerEx("miss2_patrol",1500,0,"i",playerid);
					SendClientMessage(playerid,COLOR_RED,"Öffne die Garage, ohne gesehen zu werden");
				}
		        case 2:
				{
					SetPlayerCheckpoint(playerid,254.7495,1879.3922,11.4609,1);
                    MoveObject(a51obj[1], 214.337631, 1875.739136, 9.000, 100);
				}
		        case 3:SetPlayerCheckpoint(playerid,249.1252,1809.4850,7.5547,1);
		        case 4:SetPlayerCheckpoint(playerid,277.2800,1840.7772,7.8281,1);
		        case 5:SetPlayerCheckpoint(playerid,331.8190,1838.0906,7.8281,1);
		        case 6:SetPlayerCheckpoint(playerid,297.7055,1846.8442,7.7266,1);
		        case 7:SetPlayerCheckpoint(playerid,279.9681,1869.6759,8.7578,1);
		        case 8:SetPlayerCheckpoint(playerid,268.7669,1870.5626,8.6094,1);
		    }
		    if(cpnumber == 9)
			{
		        miss1pickup = CreatePickup(2976,22,268.8571,1884.2451,-30.0938,0);
		        GameTextForPlayer(playerid,"Stehle den gruenen Schleim",3000,1);
		        DisablePlayerCheckpoint(playerid);
		        return 1;
			}
			if(cpnumber == 10)
			{
				MoveObject(a51obj[1],214.337631, 1875.739136, 13.162411,100); //schließen
				switch(GetPVarInt(playerid,"diffi")) //türe öffnen
				{
				    case 1: MoveObject(a51obj[0], 96.669350, 1925.953735, 18.855873, 0.2);
				    case 2,3: MoveObject(a51obj[0], 96.669350, 1925.953735, 18.855873, 0.15);
				    case 4: MoveObject(a51obj[0], 96.669350, 1925.953735, 18.855873, 0.1);
				    case 5: MoveObject(a51obj[0], 96.669350, 1925.953735, 18.855873, 0.05);
				}
                SetPlayerCheckpoint(playerid,87.3153,1919.7640,17.8488,1);
                
                ConnectNPC("heli1","hunter1_a51");
                if(GetPVarInt(playerid,"diffi") >= 3) ConnectNPC("heli2","hunter2_a51");
                
       			if(GetPVarInt(playerid,"diffi") == 5)
		    	{
					ConnectNPC("heli3","hunter3_a51");
				}
				return 1;
			}
			if(cpnumber == 11)
			{
			    miss_win(playerid);
			    return 1;
			}
		    format(missmsg,128,"miss2_%d_1",cpnumber);
		    ConnectNPC("npc1",missmsg);
		    if(GetPVarInt(playerid,"diffi") >= 3)
			{
			    format(missmsg,128,"miss2_%d_2",cpnumber);
			    ConnectNPC("npc2",missmsg);
			}
		
		}
	}
	return 1;
}

forward playmission(playerid);
public playmission(playerid)
{
	if(GetPVarInt(playerid,"mission") == 1) return 1;
    playersonline = 0;
	for(new plon=0;plon!=slots;plon++) if(IsPlayerConnected(plon) && !IsPlayerNPC(plon)) playersonline += 1;
	if(playersonline == 1 || adminlevel[playerid] == 3)
	{
	    SetPlayerArmour(playerid,0);
	    SetPVarInt(playerid,"mission",1);
	    KillTimer(GetPVarInt(playerid,"actimer"));
		TextDrawHideForPlayer(playerid,classinfo[playerid]);
		ShowPlayerDialog(playerid,723,0,"Singleplayer Mission","Folge den roten Markierungen\n\nScripting: Trooper[Y]\nMapping: InternetInk","Los","gehts");
	    KillTimer(ausbtimerid);
	    ResetPlayerWeapons(playerid);
	    SetPlayerWeather(playerid,08);
	    
		switch(GetPVarInt(playerid,"diffi"))
		{
		    case 1:
		    {
		        SetPlayerHealth(playerid,30);
		        GivePlayerWeapon(playerid,31,300);
		    }
		    case 2:
		    {
		        SetPlayerHealth(playerid,20);
		        GivePlayerWeapon(playerid,31,200);
		    }
		    case 3:
		    {
		        SetPlayerHealth(playerid,15);
		        GivePlayerWeapon(playerid,31,150);
		    }
            case 4:
		    {
		        SetPlayerHealth(playerid,10);
		        GivePlayerWeapon(playerid,31,100);
		    }
		    case 5:
		    {
		        SetPlayerHealth(playerid,7);
		        GivePlayerWeapon(playerid,31,55);
		        if(GetPVarInt(playerid,"chosenmiss") == 1) ConnectNPC("helibot","helibot");
		    }
		}
	    SetPlayerSkin(playerid,285);
	    
		switch(GetPVarInt(playerid,"chosenmiss"))
	    {
			case 1:SetPlayerPos(playerid,-2316.7119,1546.2045,18.7734);
			case 2:
			{
				SetPlayerPos(playerid,98.5116,1920.5602,18.2037);
				
				MoveObject(a51obj[0],96.669350, 1920.033936, 18.855873,100);
				MoveObject(a51obj[1],214.337631, 1875.739136, 13.162411,100);
			}
		}
		
		cpnumber = 0;
	    nextcp(playerid);
		
	}
	else SendClientMessage(playerid,COLOR_RED,"Es heißt nicht umsonst 'Singleplayer-Mission'");
	
	return 1;
}

forward miss2_patrol(playerid);
public miss2_patrol(playerid)
{
	if(!IsPlayerConnected(playerid) || cpnumber != 1) return 0;
	SetTimerEx("miss2_patrol",1500,0,"i",playerid);
	new Float:plpo[10];
	GetPlayerPos(playerid,plpo[0],plpo[1],plpo[2]);
	for(new che=0;che!=slots;che++)
	{
	    if(IsPlayerNPC(che))
	    {
	        GetPlayerPos(che,plpo[6],plpo[7],plpo[8]);
	        GetPlayerFacingAngle(che,plpo[3]);
	        plpo[4] = plpo[6]+(15 * floatsin(-plpo[3], degrees));
			plpo[5] = plpo[7]+(15 * floatcos(-plpo[3], degrees));
			
	        if(IsPlayerInRangeOfPoint(playerid,15,plpo[4],plpo[5],plpo[8]))
	        {
	            GameTextForPlayer(playerid,"~r~Du wurdest ertappt",3000,1);
	            dcmd_abort(playerid," ");
	        }
	    }
	}
	return 1;
}

forward spawnpl(playerid);
public spawnpl(playerid)
{
	SpawnPlayer(playerid);
	return 1;
}

forward checkban(playerid);
public checkban(playerid)
{
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);

	new tmpoutput5[256];
	format(mysqlquery[playerid],256,"SELECT * FROM bans WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
 	if(mysql_num_rows() > 0)
	{
	    mysql_fetch_field("reason",tmpoutput5);
	    mysql_free_result();
	    new kmsg2[256];
		format(kmsg2,256,"Du bist gebannt wegen : %s",tmpoutput5);
		SendClientMessage(playerid,COLOR_RED,kmsg2);
	    Kick(playerid);
	    return 0;
	}
	mysql_free_result();

	new mip[255];
	gpci(playerid, mip, 255);
	format(mysqlquery[playerid],256,"SELECT * FROM bans WHERE hdwid = '%s'",mip);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
	    mysql_fetch_field("reason",tmpoutput5);
	    mysql_free_result();
	    new kmsg2[256];
		format(kmsg2,256,"Du bist gebannt wegen : %s",tmpoutput5);
		SendClientMessage(playerid,COLOR_RED,kmsg2);
	    Kick(playerid);
	    return 0;
	}
	mysql_free_result();

	return 1;
}

public OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid))
	{
		loggedin[playerid] = 1;
		SpawnPlayer(playerid);
		SetTimerEx("spawnpl",500,0,"i",playerid);
		return 1;
	}
	if(!checkban(playerid)) return 0;
	//sektion variabeln
	loggedin[playerid] = 0,adminlevel[playerid] = 0,isspawned[playerid] = 0,veh[playerid] = -1;
	player[playerid][level] = 0,player[playerid][position] = 0,player[playerid][team] = 0,player[playerid][klasse] = 0;
	player[playerid][kills] = 0,player[playerid][deaths] = 0;
	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);
	SetPVarString(playerid,"lasttext","gzdasgzasdgz");
	AllowPlayerTeleport(playerid,0);
	SetPVarInt(playerid,"opponent",-1);
	
	//effekte
	playertext[playerid] = Create3DTextLabel(" ",COLOR_RED,0,0,-5000,20,0,1);
	Attach3DTextLabelToPlayer(playertext[playerid],playerid,0,0,0.75);
	
	classinfo[playerid] = TextDrawCreate(45.000000, 131.000000, "Klasse : ~r~Sanitaeter~w~~n~Der moderne Sanitaeter beherrscht die Heilkunst perfekt~n~~n~~r~Ausruestung ~w~:~n~]Pfeffer Spray");
	TextDrawBackgroundColor(classinfo[playerid], 255);
	TextDrawFont(classinfo[playerid], 2);
	TextDrawLetterSize(classinfo[playerid], 0.500000, 1.000000);
	TextDrawColor(classinfo[playerid], -1);
	TextDrawSetOutline(classinfo[playerid], 0);
	TextDrawSetProportional(classinfo[playerid], 1);
	TextDrawSetShadow(classinfo[playerid], 1);
	TextDrawUseBox(classinfo[playerid], 1);
	TextDrawBoxColor(classinfo[playerid], 255);
	TextDrawTextSize(classinfo[playerid], 345.000000, 130.000000);
	
	tixtdraw[0][playerid] = TextDrawCreate(546.000000, 55.000000, "0 SC");
	TextDrawBackgroundColor(tixtdraw[0][playerid], 255);
	TextDrawFont(tixtdraw[0][playerid], 2);
	TextDrawLetterSize(tixtdraw[0][playerid], 0.500000, 1.000000);
	TextDrawColor(tixtdraw[0][playerid], -1);
	TextDrawSetOutline(tixtdraw[0][playerid], 1);
	TextDrawSetProportional(tixtdraw[0][playerid], 1);
	
	rang[playerid] = TextDrawCreate(540.000000, 100.000000, "Private");
	TextDrawAlignment(rang[playerid], 2);
	TextDrawBackgroundColor(rang[playerid], 255);
	TextDrawFont(rang[playerid], 1);
	TextDrawLetterSize(rang[playerid], 0.500000, 1.000000);
	//TextDrawColor(rang[playerid], -16776961);
	TextDrawSetOutline(rang[playerid], 0);
	TextDrawSetProportional(rang[playerid], 1);
	TextDrawSetShadow(rang[playerid], 1);
	
	for(new addpick=0;addpick!=olquellen;addpick++)
 	{
 		SetPlayerMapIcon(playerid, addpick, oil_info[addpick][posx], oil_info[addpick][posy], oil_info[addpick][posz], 1, 0xFFFFB8FF);
	}
	
	switch(capture[7])
	{
	    case 0:GangZoneShowForAll(capture[2],COLOR_WHITE);
	    case 1:GangZoneShowForAll(capture[2],COLOR_GREEN);
	    case 2:GangZoneShowForAll(capture[2],COLOR_RED);
	}
	
	switch(capture[6])
	{
	    case 0:GangZoneShowForAll(capture[0],COLOR_WHITE);
	    case 1:GangZoneShowForAll(capture[0],COLOR_GREEN);
	    case 2:GangZoneShowForAll(capture[0],COLOR_RED);
	}
	new tmpoutput5[256];
    format(mysqlquery[playerid],256,"SELECT name FROM sav_score WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	mysql_fetch_field("name",tmpoutput5);
	if(strlen(tmpoutput5) < 2) //register
	{
	    mysql_free_result();
		new nim[16];
		GetPlayerName(playerid,nim,16);
	 	format(mysqlquery[playerid],128,"REPLACE INTO sav_score (alvl,name,kills,deaths,gamewins,gamelosses) VALUES ('0','%s','0','0','0','0')",nim);
		mysql_query(mysqlquery[playerid]);
	}
	mysql_free_result();
	
	//join-message
	
    format(mysqlquery[playerid],256,"SELECT pw FROM login WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_fetch_field("pw",tmpoutput5))
	{
        ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Willkommen zurück auf dem Savandreas Strategy TDM Server\n\nGib dein Passwort ein:","Ok","");
	}
	else ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen auf dem Savandreas Strategy TDM Server\n\nBitte gib ein Passwort ein:","Ok","");
	mysql_free_result();
	
	return 1;
}

forward getrlmoney(playerid);
public getrlmoney(playerid)
{
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT * FROM login WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	new tmpoutput2[128],calcu;
	mysql_fetch_field("rlmoney",tmpoutput2);
	calcu = strval(tmpoutput2);
	mysql_free_result();
	format(tmpoutput2,128,"%d SC",calcu);
	TextDrawSetString(tixtdraw[0][playerid],tmpoutput2);
	TextDrawShowForPlayer(playerid,tixtdraw[0][playerid]);

	return calcu;
}

public OnPlayerDisconnect(playerid, reason)
{
    StreamObject_OnPlayerDisconnect(playerid);
	if(IsPlayerNPC(playerid))
	{
		if(cpnumber == 10)
		{
		    GetPlayerName(playerid,player_name[playerid],16);
		    if(random(50) < 25) ConnectNPC(player_name[playerid],"miss_9_1");
		    else ConnectNPC(player_name[playerid],"miss_9_2");
		}
		return 1;
	}
	for(new srsp=0;srsp!=10;srsp++) if(IsPlayerNPC(srsp))
	{
	    DestroyVehicle(helinpc[srsp]);
		Kick(srsp);
	}
	for(new dt=0;dt!=sizeof(missobjects2);dt++) if(IsValidObject(missobjects2[dt])) DestroyObject(missobjects2[dt]);
	
	if(GetPVarInt(playerid,"opponent") != -1)
	{
	    new op = GetPVarInt(playerid,"opponent");
	    SetPVarInt(playerid,"opponent",-1);
	    SetPVarInt(op,"opponent",-1);
	    SetPlayerVirtualWorld(playerid,0);
	    SetPlayerVirtualWorld(op,0);
	    OnPlayerSpawn(op);
	    SendClientMessage(op,COLOR_GREY,"Dein Gegner hat das Spiel verlassen");
	    return 1;
	}
	
    DestroyPlayerObject(playerid,GetPVarInt(playerid,"spawnflag"));
    DestroyObjectToStream(GetPVarInt(playerid,"samrocket"));
	TextDrawHideForPlayer(playerid,info_bar);
	Delete3DTextLabel(playertext[playerid]);
	DestroyObjectToStream(GetPVarInt(playerid,"Adromada"));
	DestroyObjectToStream(GetPVarInt(playerid,"Adromada2"));
	if(player[playerid][position] == 4)
	{
	    comzoom[player[playerid][team]-1] = 200.0,player[playerid][position] = 0;
 	}
 	teamnumber[player[playerid][team]-1] -= 1;
	TextDrawDestroy(classinfo[playerid]);
	GetPlayerName(playerid,player_name[playerid],64);
	
	DestroyVehicle(veh[playerid]);
	veh[playerid] = -1;
	return 1;
}

forward respawn(playerid);
public respawn(playerid)
{
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid,1);
	SetPlayerVirtualWorld(playerid,0);
	OnPlayerSpawn(playerid);
	return 1;
}

forward giveweaponset(playerid,opt);
public giveweaponset(playerid,opt)
{
	ResetPlayerWeapons(playerid);
    switch(GetPVarInt(playerid,"skin"))
	{
	    case 5: //worker
	    {
	        GivePlayerWeapon(playerid,25,ammo);
	    }
		case 0: //medic
		{
		    GivePlayerWeapon(playerid,41,100);
		}
		case 1:
		{
			GivePlayerWeapon(playerid,22,ammo);
			GivePlayerWeapon(playerid,27,ammo);
			GivePlayerWeapon(playerid,29,ammo);
		}
		case 2:
		{
			GivePlayerWeapon(playerid,23,ammo);
			GivePlayerWeapon(playerid,4,1);
			GivePlayerWeapon(playerid,34,ammo);
		}
	}
    if(building_number[Armory][player[playerid][team]-1] != 0 && opt == 1)
    {
        SetPlayerArmour(playerid,floatmul(float(building_number[Armory][player[playerid][team]-1]),float(10)));
		GivePlayerWeapon(playerid,16,building_number[Armory][player[playerid][team]-1]);
		GivePlayerWeapon(playerid,35,building_number[Armory][player[playerid][team]-1]);
		GivePlayerWeapon(playerid,39,building_number[Armory][player[playerid][team]-1]);
        GivePlayerWeapon(playerid,31,building_number[Armory][player[playerid][team]-1]*20);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
    triggerachiv(playerid,1);
    SetPlayerWeather(playerid,07);
    SetPVarInt(playerid,"opponent",-1);
	if(IsPlayerNPC(playerid))
	{
	    new npcn[16];
	    GetPlayerName(playerid,npcn,16);
	    if(!strcmp(npcn,"helibot") || !strcmp(npcn,"heli1") || !strcmp(npcn,"heli2") || !strcmp(npcn,"heli3"))
	    {
			helinpc[playerid] = CreateVehicle(425,-2228.9744,2333.5889,8.2546,184.6783,0,0,10);
			PutPlayerInVehicle(playerid,helinpc[playerid],0);
	    }
	    switch(random(6))
		{
		    case 0:SetPlayerSkin(playerid,111);
		    case 1:SetPlayerSkin(playerid,112);
		    case 2:SetPlayerSkin(playerid,120);
		    case 3:SetPlayerSkin(playerid,126);
		    case 4:SetPlayerSkin(playerid,124);
		    case 5:SetPlayerSkin(playerid,206);
		}
	    return 1;
	}
	if(GetPVarInt(playerid,"mission") == 1) return playmission(playerid);
	ResetPlayerWeapons(playerid);
	KillTimer(GetPVarInt(playerid,"actimer"));
	TogglePlayerControllable(playerid,1);
	getrlmoney(playerid);
    SetPVarInt(playerid,"actimer",SetTimerEx("anticheat",10000,0,"i",playerid));
  	if(player[playerid][position] == 4)
  	{
  	    isspawned[playerid] = 1;
  	    TextDrawHideForPlayer(playerid,classinfo[playerid]);
		PutPlayerInVehicle(playerid,comcar[player[playerid][team]-1],0);
		updatebar(playerid);

	    SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
		SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);
		SetPVarInt(playerid,"isdead",0);
		return 1;
	}
	switch(GetPVarInt(playerid,"skin"))
    {
		case 0:SetPlayerSkin(playerid,276);
        case 1:SetPlayerSkin(playerid,287);
        case 2:SetPlayerSkin(playerid,285);
        case 3:SetPlayerSkin(playerid,153);
        case 4:SetPlayerSkin(playerid,284);
    }
    
	if(GetPVarInt(playerid,"killed") == 1)
	{
	    SetPVarInt(playerid,"killed",0);
	    SetPlayerVirtualWorld(playerid,playerid+1);
	    SetPlayerPos(playerid, -1820.4644,-149.4375,9.3984);
		SetPlayerFacingAngle(playerid,182.8881);
		SetPlayerCameraPos(playerid, -1822.1163,-155.3545,9.4056);
		SetPlayerCameraLookAt(playerid, -1822.3245,-149.2125,9.4056);
		//TogglePlayerControllable(playerid,0);
	    new var12[2],respmsg[128];
		var12[0] = building_number[CloneResearch][player[playerid][team]-1];
	    if(var12[0] == 0) var12[1] = 15000;
	    if(var12[0] == 1) var12[1] = 10000;
	    if(var12[0] == 2) var12[1] = 5000;
	    if(var12[0] > 2) var12[1] = 2000;
		SetTimerEx("respawn",var12[1],0,"i",playerid);
		var12[1] = var12[1]/1000;
		format(respmsg,128,"Du wirst wiedergeboren in %d Sekunden",var12[1]);
		SendClientMessage(playerid,COLOR_RED,respmsg);
		SendClientMessage(playerid,COLOR_RED,"Clone Research Centers verringern die Respawnzeit");
		SetPVarInt(playerid,"respawns",1);
		return 1;
	}
	else
	{
	    SetPVarInt(playerid,"respawns",0);
	    DestroyPickup(GetPVarInt(playerid,"heartpick"));
	    DestroyPickup(GetPVarInt(playerid,"weappick"));
	}
	SetPVarInt(playerid,"isdead",0);
	TextDrawHideForPlayer(playerid,classinfo[playerid]);
	isspawned[playerid] = 1;
    updatebar(playerid);
    SetCameraBehindPlayer(playerid);
    ResetPlayerWeapons(playerid);

    new Float:rlspawn[3],chosenspawn = GetPVarInt(playerid,"entrypoint");
    if(player[playerid][position] != 4)
	{
		TextDrawHideForPlayer(playerid,classinfo[playerid]);
		SetPlayerPos(playerid,subpos[player[playerid][team]-1][chosenspawn][0],subpos[player[playerid][team]-1][chosenspawn][1],subpos[player[playerid][team]-1][chosenspawn][2]+1);
        rlspawn[0] = subpos[player[playerid][team]-1][chosenspawn][0];
        rlspawn[1] = subpos[player[playerid][team]-1][chosenspawn][1];
        rlspawn[2] = subpos[player[playerid][team]-1][chosenspawn][2];
        player[playerid][position] = 1,isspawned[playerid] = 1;
        SetPVarInt(playerid,"choosespawn",0);
 	}
    
    if(building_number[Armory][player[playerid][team]-1] != 0)
    {
        SetPlayerArmour(playerid,floatmul(float(building_number[Armory][player[playerid][team]-1]),float(10)));
		GivePlayerWeapon(playerid,16,building_number[Armory][player[playerid][team]-1]);
		GivePlayerWeapon(playerid,35,building_number[Armory][player[playerid][team]-1]);
		GivePlayerWeapon(playerid,39,building_number[Armory][player[playerid][team]-1]);
        GivePlayerWeapon(playerid,31,building_number[Armory][player[playerid][team]-1]*20);
		SendClientMessage(playerid,COLOR_RED,"Dein Team besitzt Armorys, du hast eine Rüstung und mehr Waffen erhalten");
	}
	new fsk,tmpoutput2[128];
	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT strat_blife FROM login WHERE name='%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	mysql_fetch_field("strat_blife",tmpoutput2);
	fsk = strval(tmpoutput2);
	mysql_free_result();
	
	SetPlayerHealth(playerid,100+fsk+(building_number[CloneResearch][player[playerid][team]-1]*15));
    DestroyVehicle(veh[playerid]);
    
	switch(GetPVarInt(playerid,"skin"))
	{
	    case 5: //worker
	    {
	        GivePlayerWeapon(playerid,25,ammo);
	        SendClientMessage(playerid,COLOR_RED,"Du bist als Bauarbeiter gespawnt. Suche beschädigte Gebäude und /repair sie");
		    if(producedcars[player[playerid][team]-1] >= 1) SendClientMessage(playerid,COLOR_GREY,"Du kannst Autos per /cars erstellen");
	    }
		case 0: //medic
		{
		    GivePlayerWeapon(playerid,41,100);
		    SendClientMessage(playerid,COLOR_RED,"Du bist als Sanitaeter gespawnt. Heile Kameraden per /heal");
		    if(producedcars[player[playerid][team]-1] >= 1) SendClientMessage(playerid,COLOR_GREY,"Du kannst Autos per /cars erstellen");
		}
		case 1: //soldier
		{
		    SendClientMessage(playerid,COLOR_RED,"Du bist als Soldat gespawnt. Finde und zerstör den Gegner");
			GivePlayerWeapon(playerid,22,ammo);
			GivePlayerWeapon(playerid,27,ammo);
			GivePlayerWeapon(playerid,29,ammo);
			if(producedcars[player[playerid][team]-1] >= 1) SendClientMessage(playerid,COLOR_GREY,"Du kannst Autos per /cars erstellen");
		}
		case 2: //scout
		{
		    SendClientMessage(playerid,COLOR_RED,"Du bist als Scout gespawnt. Finde und zerstör den Gegner");
			GivePlayerWeapon(playerid,23,ammo);
			GivePlayerWeapon(playerid,4,1);
			GivePlayerWeapon(playerid,34,ammo);
			if(producedcars[player[playerid][team]-1] >= 1) SendClientMessage(playerid,COLOR_GREY,"Du kannst Autos per /cars erstellen");
		}
		case 3: //tank
		{
		    if(building_number[TankFac][player[playerid][team]-1] == 0)
		    {
		        SetPlayerSkin(playerid,276);
		        SendClientMessage(playerid,COLOR_RED,"Dein Team hat noch keine Panzerfabrik");
		        SendClientMessage(playerid,COLOR_RED,"Du bist als Sanitaeter gespawnt. Heile Kameraden per /heal");
			}
			else
			{
		    	SendClientMessage(playerid,COLOR_RED,"Du bist als Panzerfahrer gespawnt");
				if(producedtanks[player[playerid][team]-1] >= 1)
				{
				    SetPlayerPos(playerid,rlspawn[0],rlspawn[1],rlspawn[2]);
					veh[playerid] = CreateVehicle(432,rlspawn[0],rlspawn[1],rlspawn[2],0,0,0,999999999999999);
			    	PutPlayerInVehicle(playerid,veh[playerid],0);
                    producedtanks[player[playerid][team]-1] -= 1;
                    triggerachiv(playerid,16);
				}
				else
				{
				    SendClientMessage(playerid,COLOR_RED,"Dein Team hat zu wenige Panzer");
				}
		    }
		}
		case 4: //hunter
		{
		    if(building_number[HunterFac][player[playerid][team]-1] == 0)
		    {
		        SetPlayerSkin(playerid,276);
		        SendClientMessage(playerid,COLOR_RED,"Dein Team hat noch keine Helifabrik");
		        SendClientMessage(playerid,COLOR_RED,"Du bist als Sanitaeter gespawnt. Heile Kameraden per /heal");
			}
			else
			{
		    	SendClientMessage(playerid,COLOR_RED,"Du bist als Hunter Pilot gespawnt. Töte Gegner");
		    	if(producedhunters[player[playerid][team]-1] >= 1)
				{
				    DestroyVehicle(veh[playerid]);
					veh[playerid] = CreateVehicle(425,floatadd(rlspawn[0],float(random(150))),floatadd(rlspawn[1],float(random(150))),rlspawn[2]+750,0,0,0,9999999999999999999999);
		    		PutPlayerInVehicle(playerid,veh[playerid],0);
		    		producedhunters[player[playerid][team]-1] -= 1;
		    		triggerachiv(playerid,17);
				}
				else
				{
				    SendClientMessage(playerid,COLOR_RED,"Dein Team hat zu wenige Hunter");
				}
		    }
		}
	}
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT strat_bskin FROM login WHERE name='%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	mysql_fetch_field("strat_bskin",tmpoutput2);
	fsk = strval(tmpoutput2)-1;
	mysql_free_result();
	if(fsk >= 0)
	{
		SetPlayerSkin(playerid,fsk);
		triggerachiv(playerid,15);
	}

	refresh3d(playerid);
	return 1;
}

forward refresh3d(playerid);
public refresh3d(playerid)
{
    new updstr[256],updstr2[256];
    switch(GetPVarInt(playerid,"skin"))
	{
		case 0: format(updstr,256,"Team %d\nSanitäter",player[playerid][team]); //medic
		case 1: format(updstr,256,"Team %d\nSoldat",player[playerid][team]); //soldier
		case 2: format(updstr,256,"Team %d\nScout",player[playerid][team]); //scout
		case 3: format(updstr,256,"Team %d\nPanzerfahrer",player[playerid][team]); //tank
		case 4: format(updstr,256,"Team %d\nHunter Pilot",player[playerid][team]); //hunter
		case 5: format(updstr,256,"Team %d\nBauarbeiter",player[playerid][team]); //hunter
	}
	new Float:kd,dt;
	if(GetPlayerScore(playerid) <= 0) kd = float(0);
	else
	{
	    if(player[playerid][deaths] == 0) dt=1;
	    else dt=player[playerid][deaths];
		kd = floatdiv(float(GetPlayerScore(playerid)),float(dt));
	}
	
	format(updstr2,256,"Private");
	if(GetPlayerScore(playerid) > 25)format(updstr2,256,"Private 1st Class");
	if(GetPlayerScore(playerid) > 50)format(updstr2,256,"Corporal");
	if(GetPlayerScore(playerid) > 75)format(updstr2,256,"Sergeant");
    if(GetPlayerScore(playerid) > 100)format(updstr2,256,"Staff Sergeant");
	if(GetPlayerScore(playerid) > 125)format(updstr2,256,"Seargent 1st Class");
	if(GetPlayerScore(playerid) > 150)format(updstr2,256,"Master Sergeant");
	if(GetPlayerScore(playerid) > 175)format(updstr2,256,"Sergeant Major");
	if(GetPlayerScore(playerid) > 200)format(updstr2,256,"Com. Sergeant Major");
	if(GetPlayerScore(playerid) > 225)format(updstr2,256,"Second Lieutenant");
	if(GetPlayerScore(playerid) > 250)format(updstr2,256,"First Lieutenant");
	if(GetPlayerScore(playerid) > 275)format(updstr2,256,"Captain");
	if(GetPlayerScore(playerid) > 300)format(updstr2,256,"Major");
	if(GetPlayerScore(playerid) > 325)format(updstr2,256,"Lt. Colonel");
    if(GetPlayerScore(playerid) > 350)format(updstr2,256,"Colonel");
	if(GetPlayerScore(playerid) > 375)format(updstr2,256,"Brigadier General");
	if(GetPlayerScore(playerid) > 400)format(updstr2,256,"Major General");
	if(GetPlayerScore(playerid) > 425)format(updstr2,256,"Lt. General");
	if(GetPlayerScore(playerid) > 450)format(updstr2,256,"General");
	if(GetPlayerScore(playerid) > 500)format(updstr2,256,"Warlock I");
	if(GetPlayerScore(playerid) > 600)format(updstr2,256,"Warlock II");
	if(GetPlayerScore(playerid) > 800)format(updstr2,256,"Warlock III");
	if(GetPlayerScore(playerid) > 1000)format(updstr2,256,"Warlock IV");
	if(GetPlayerScore(playerid) > 1500)format(updstr2,256,"Warlock V");
	if(GetPlayerScore(playerid) > 2000)format(updstr2,256,"Warlock VI");
	if(GetPlayerScore(playerid) > 2500)format(updstr2,256,"Warlock VII");
	if(GetPlayerScore(playerid) > 3000)format(updstr2,256,"Warlock VIII");
	if(GetPlayerScore(playerid) > 3500)format(updstr2,256,"Warlock IX");
	if(GetPlayerScore(playerid) > 4000)format(updstr2,256,"Warlock X");

	TextDrawSetString(rang[playerid],updstr2);
	TextDrawShowForPlayer(playerid,rang[playerid]);

	format(updstr2,256,"%s\n%s\n%.2f",updstr,updstr2,kd);
 	Update3DTextLabelText(playertext[playerid],COLOR_RED,updstr2);
	return 1;
}

forward addrlmoney(playerid,moneten);
public addrlmoney(playerid,moneten)
{
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"UPDATE login SET rlmoney=rlmoney+%d WHERE name = '%s'",moneten,player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	return 1;
}

forward withrlmoney(playerid,moneten);
public withrlmoney(playerid,moneten)
{
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"UPDATE login SET rlmoney=rlmoney-%d WHERE name = '%s'",moneten,player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	return 1;
}

forward testhh2_duell(playerid);
public testhh2_duell(playerid)
{
    new op = GetPVarInt(playerid,"opponent");
    new Float:gh;
    GetPlayerHealth(playerid,gh);
	if(gh == float(100))
	{
	    SendClientMessage(op,COLOR_RED,"Dein Gegner hat gecheatet, und wurde daher gebannt");
	    bansql(playerid,"Duell-Godmode");
	    return 1;
	}
	else
	{
	    SetPlayerVirtualWorld(op,0);
	    OnPlayerSpawn(op);
	    getrlmoney(op);
	    getrlmoney(playerid);
	    addrlmoney(op,GetPVarInt(playerid,"einsatz"));
	    withrlmoney(playerid,GetPVarInt(playerid,"einsatz"));
	}

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(GetPVarInt(playerid,"opponent") != -1)
	{
	    new op = GetPVarInt(playerid,"opponent");
	    SetPVarInt(playerid,"opponent",-1);
	    SetPVarInt(op,"opponent",-1);
	    SetPlayerVirtualWorld(playerid,0);
	    
	    
	    SendClientMessage(op,COLOR_GREEN,"Du hast das Duell gewonnen !");
	    SendClientMessage(playerid,COLOR_RED,"Du hast das Duell verloren !");
	    
	    SetPlayerHealth(op,100);
		SetPlayerVirtualWorld(op,op+1);

	    SetPlayerPos(op,197.7850,175.3622,1003.0234);
	    CreateExplosion(197.7850,175.3622,1003.0234,8,15);
		SetTimerEx("testhh2_duell",500,0,"i",op);
	}
    SetPlayerHealth( playerid, 1.0 );
    triggerachiv(killerid,10);
	if(player[playerid][position] == 4) return Kick(killerid);
	SetPVarInt(playerid,"createpick",0);
	if(GetPVarInt(playerid,"mission") == 1)
	{
	    dcmd_abort(playerid,"");
	}
	SetPVarInt(playerid,"dropw",GetPlayerWeapon(playerid));
	new Float:fu[4];
 	fu[3] = 1;
	GetPlayerPos(playerid,fu[0],fu[1],fu[2]);
	SetPVarFloat(playerid,"deadposx",fu[0]);
	SetPVarFloat(playerid,"deadposy",fu[1]);
	SetPVarFloat(playerid,"deadposz",fu[2]);
	SetPVarInt(playerid,"heartpick",CreatePickup(1240,23,GetPVarFloat(playerid,"deadposx")+2,GetPVarFloat(playerid,"deadposy"),GetPVarFloat(playerid,"deadposz")));
	new model5 = 0;
	switch(GetPVarInt(playerid,"dropw"))
	{
		case 4:model5=335;
		case 22:model5=346;
		case 23:model5=347;
		case 27:model5=351;
		case 29:model5=353;
		case 31:model5=356;
		case 34:model5=358;
		case 35:model5=359;
		case 25:model5=349;
	}
	if(model5 != 0)
	{
		SetPVarInt(playerid,"weappick",CreatePickup(model5,23,GetPVarFloat(playerid,"deadposx")-2,GetPVarFloat(playerid,"deadposy"),GetPVarFloat(playerid,"deadposz")));
	}
    adddeath(playerid,killerid,reason);
	return 1;
}

forward adddeath(playerid,killerid,reason);
public adddeath(playerid,killerid,reason)
{
    SetPVarInt(playerid,"destroyedarm",0);
    if(GetPVarInt(playerid,"mission") == 1)
	{
	    for(new srsp=0;srsp!=10;srsp++) if(IsPlayerNPC(srsp)) Kick(srsp);
	    DisablePlayerCheckpoint(playerid);
	    return SetPVarInt(playerid,"mission",0);
	}
    SetPVarInt(playerid,"isdead",1);
	if(IsPlayerConnected(killerid))
	{
	    if(player[playerid][team] == player[killerid][team])
	    {
			SendClientMessage(playerid,COLOR_RED,"Du wurdest von einem Kameraden getötet. Keine Sorge, er wurde bestraft");
			SendClientMessage(killerid,COLOR_RED,"Du hast einen Kameraden getötet. Dein Bildschirm wurde angegriffen und du hast 3 kills verloren");
			new Float:fu[3];
			GetPlayerPos(killerid,fu[0],fu[1],fu[2]);
			SetPlayerVelocity(killerid,fu[0],fu[1],fu[2]);
			GetPlayerName(killerid,tknm,16);
            format(mysqlquery[killerid],128,"UPDATE sav_score SET kills=kills-3 WHERE name = '%s'",tknm);
			mysql_query(mysqlquery[killerid]);
			return 1;
		}
	}
	
	DestroyVehicle(veh[playerid]);
	veh[playerid] = -1;
	if(GetPVarInt(playerid,"ausnahme") == 1)
	{
	    SetPVarInt(playerid,"ausnahme",0);
	    SetPVarInt(playerid,"killed",0);
	    return 1;
	}
	else
	{
	    SetPVarInt(playerid,"streak",0);
    	SetPVarInt(playerid,"killed",1);
    	SendDeathMessage(killerid,playerid,reason);
	}
	teammoney[player[playerid][team]-1] -= 1;
	if(IsPlayerConnected(killerid))
	{
	    player[playerid][kills] += 1;
	    SetPlayerScore(killerid,GetPlayerScore(killerid)+1);
	    new nam[16];
	    GetPlayerName(killerid,nam,16);
        format(mysqlquery[killerid],128,"UPDATE sav_score SET kills=kills+1 WHERE name = '%s'",nam);
		mysql_query(mysqlquery[killerid]);
		teammoney[player[killerid][team]-1] += 100;
		teamkills[player[killerid][team]-1] += 1;
		//updatebar(player[killerid][team]);
		SetPVarInt(killerid,"streak",GetPVarInt(killerid,"streak")+1);
		new streakmsg[128],streaknm[16];
		GetPlayerName(killerid,streaknm,16);
		refresh3d(killerid);
		switch(GetPVarInt(killerid,"streak"))
		{
		    case 5:
			{
				format(streakmsg,128,"Sie ist ein echter Killer... Spieler %s hat einen 5 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 1*GetPVarInt(killerid,"streak");
			}
		    case 10:
			{
				format(streakmsg,128,"Dawn Asshole !!! Spieler %s hat einen 10 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 30;
				teammoney[player[killerid][team]-1] += 5*GetPVarInt(killerid,"streak");
			}
			case 15:
			{
				format(streakmsg,128,"WTF?! Thats insane !!! Spieler %s hat einen 15 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 15*GetPVarInt(killerid,"streak");
			}
			case 20:
			{
				format(streakmsg,128,"Its got to be cheating !!! Spieler %s hat einen 20 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 35*GetPVarInt(killerid,"streak");
			}
			case 25:
			{
				format(streakmsg,128,"Ok, dude, its getting boring... Spieler %s hat einen 25 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 55*GetPVarInt(killerid,"streak");
			}
			case 30:
			{
				format(streakmsg,128,"Im sure, hes a cheater !!! Spieler %s hat einen 30 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 100*GetPVarInt(killerid,"streak");
			}
			case 35:
			{
				format(streakmsg,128,"Fuck, only 5 kills to defeat !!! Spieler %s hat einen 35 Killstreak erreicht",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				teammoney[player[killerid][team]-1] += 500*GetPVarInt(killerid,"streak");
			}
			case 40:
			{
			    format(streakmsg,128,"Spieler %s hat das Spiel mit einem 40 Killstreak beendet",streaknm);
				SendClientMessageToAll(COLOR_YELLOW,streakmsg);
				new wmsg[128];
				format(wmsg,128,"Team %d hat gewonnen",player[killerid][team]);
				SendClientMessageToAll(COLOR_RED,wmsg);
				new nwm[16];
				for(new endgame=0;endgame!=slots;endgame++)
				{
					if(IsPlayerConnected(endgame))
					{
						TogglePlayerControllable(endgame,0);
						GetPlayerName(endgame,nwm,16);
						if(player[killerid][team] == player[endgame][team]) //unlogisch, aber .. ka
						{
							GameTextForPlayer(endgame,"Du hast ~g~gewonnen",1000,1);
							format(mysqlquery[endgame],128,"UPDATE sav_score SET gamewins=gamewins+1 WHERE name = '%s'",nwm);
							mysql_query(mysqlquery[endgame]);
						}
						else
						{
							GameTextForPlayer(endgame,"Du hast ~r~verloren",1000,1);
							format(mysqlquery[endgame],128,"UPDATE sav_score SET gamelosses=gamelosses+1 WHERE name = '%s'",nwm);
							mysql_query(mysqlquery[endgame]);
						}
					}
				}
				GameModeExit();
				return 1;
			}
		}
		refresh3d(killerid);
		for(new act=0;act!=slots;act++) if(player[killerid][team] != player[act][team]) updatebar(act);
	}

    new nom[16];
 	GetPlayerName(playerid,nom,16);
    format(mysqlquery[playerid],128,"UPDATE sav_score SET deaths=deaths+1 WHERE name = '%s'",nom);
	mysql_query(mysqlquery[playerid]);
	player[playerid][deaths] += 1;
	refresh3d(playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(vehicleid == comcar[0] || vehicleid == comcar[1]) Kick(killerid);
	if(IsPlayerConnected(killerid))
	{
	    for(new checkteam=0;checkteam!=slots;checkteam++)
	    {
			if(vehicleid == veh[checkteam])
			{
			    if(player[killerid][team] == player[checkteam][team] && killerid != checkteam)
			    {
					SendClientMessage(checkteam,COLOR_RED,"Du wurdest von einem Kameraden getötet. Keine Sorge, er wurde bestraft");
					SendClientMessage(killerid,COLOR_RED,"Du hast einen Kameraden getötet. Dein Bildschirm wurde angegriffen und du hast 3 kills verloren");
					new Float:fu[3];
					GetPlayerPos(killerid,fu[0],fu[1],fu[2]);
					SetPlayerVelocity(killerid,fu[0],fu[1],fu[2]);
					GetPlayerName(killerid,tknm,16);
		            format(mysqlquery[killerid],128,"UPDATE sav_score SET kills=kills-3 WHERE name = '%s'",tknm);
					mysql_query(mysqlquery[killerid]);
					return 1;
				}
				else return 1;
			}
	    }
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
    new checkstr[128];
	GetPVarString(playerid,"lasttext",checkstr,128);
	if(!strcmp(checkstr,text))
	{
	    SetPVarString(playerid,"lasttext",text);
		SendPlayerMessageToPlayer(playerid,playerid,text);
		return 0;
	}
	else SetPVarString(playerid,"lasttext",text);
	if(player[playerid][position] != 4)
	{
	    new tmid[128];
	    strmid(tmid,text,0,1,128);
	    if(!strcmp(tmid,"!"))
	    {
			strdel(text,0,1);
	        new nhm[16];
	        GetPlayerName(playerid,nhm,16);
			format(tmid,128,"[TMSG] %s : %s",nhm,text);
			for(new smsg=0;smsg!=slots;smsg++) if(player[smsg][team] == player[playerid][team]) SendClientMessage(smsg,COLOR_GREY,tmid);
			return 0;
	    }
	    return 1;
	}
	GetPlayerName(playerid,player_name[playerid],MAX_PLAYER_NAME);
	format(formattext,128,"Commander %s : %s",player_name[playerid],text);
	for(new send=0;send<=slots;send++)
	{
	    if(IsPlayerConnected(send))
	    {
			if(player[send][team] == player[playerid][team]) SendClientMessage(send,COLOR_YELLOW,formattext);
		}
	}
	return 0;
}

dcmd_createoil(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] != 3) return 0;
	new Float:pos[3],formatoil[128],stillone = -1;
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	
	INI_Open("oil.pos.txt");
	for(new searchoil=0;searchoil<=40;searchoil++)
	{
	    format(formatoil,128,"%dx",searchoil);
	    if(!INI_ReadFloat(formatoil))
	    {
	        stillone=searchoil;
	        break;
		}
	}
	format(formatoil,128,"%dx",stillone);
	INI_WriteFloat(formatoil,pos[0]);
	format(formatoil,128,"%dy",stillone);
	INI_WriteFloat(formatoil,pos[1]);
	format(formatoil,128,"%dz",stillone);
	INI_WriteFloat(formatoil,pos[2]);
	INI_Save();
	INI_Close();
	
	SendClientMessage(playerid,COLOR_RED,"Oilpos saved");
	
 	return 1;
}

dcmd_jetpack(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] != 3) return 0;
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USEJETPACK);
	return 1;
}

dcmd_friends(playerid,params[])
{
	#pragma unused params
	new listform[128],nfm[16],srchnm[16],frstring[1024];
	GetPlayerName(playerid,nfm,16);
	format(listform,128,"%s.friends.ini",nfm);
	INI_Open(listform);
	format(frstring,1024,"Freunde online :",frstring,srchnm);
	for(new gogo=0;gogo!=slots;gogo++)
	{
	    if(IsPlayerConnected(gogo))
	    {
	        GetPlayerName(gogo,srchnm,16);
	        if(INI_ReadInt(srchnm)) format(frstring,1024,"%s\n%s",frstring,srchnm);
	    }
	}
	INI_Close();
	ShowPlayerDialog(playerid,209,2,"Friends",frstring,"Info","Abbrechen");
	return 1;
}

dcmd_deletefriend(playerid,params[])
{
    if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax : /deletefriend [Name]");
	new delnm[16],delms[128],readstr2[128];
    GetPlayerName(playerid,delnm,16);
	format(delms,128,"%s.friends.ini",delnm);
	INI_Open(delms);
	if(!INI_ReadString(readstr2,params,16))
	{
	    SendClientMessage(playerid,COLOR_RED,"Spieler ist nicht in deiner Freundesliste");
	    INI_Close();
	    return 1;
	}
	INI_RemoveEntry(params);
	INI_Save();
	INI_Close();
	SendClientMessage(playerid,COLOR_GREEN,"Spieler entfernt");
	return 1;
}

dcmd_addfriend(playerid,params[]) 
{
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax : /addfriend [Name]");
	new addform[128],addnm[16],readstr[128];
	GetPlayerName(playerid,addnm,16);
	format(addform,128,"%s.friends.ini",addnm);
	INI_Open(addform);
	if(INI_ReadString(readstr,params,16))
	{
	    SendClientMessage(playerid,COLOR_RED,"Spieler ist bereits auf deiner Liste");
	    INI_Close();
	    return 1;
	}
	INI_WriteInt(params,1);
	INI_Save();
	INI_Close();
	SendClientMessage(playerid,COLOR_GREEN,"Freund hinzugefügt");
	return 1;
}

dcmd_kill(playerid,params[])
{
	#pragma unused params
	SetPlayerHealth(playerid,0);
	return 1;
}

dcmd_sethealth(playerid,params[])
{
	if(adminlevel[playerid] == 0) return 0;
	SetPlayerHealth(playerid,strval(params));
	return 1;
}

dcmd_mission(playerid,params[])
{
	#pragma unused params
    SetPVarInt(playerid,"aborted",0);
    SetPVarInt(playerid,"mission",0);
    ShowPlayerDialog(playerid,9875,2,"Wähle eine Mission","[COD4] Shipment\n[GTA:SA] Get the goo","Wählen","Abbrechen");

	return 1;
}

dcmd_cars(playerid,params[])
{
	#pragma unused params
	spawnvehicle(playerid);
	return 1;
}

dcmd_abort(playerid,params[])
{
	#pragma unused params
	SetPVarInt(playerid,"ausnahme",1);
	SetPVarInt(playerid,"mission",0);
	SetPVarInt(playerid,"aborted",1);
	//SendClientMessage(playerid,COLOR_RED,"You aborted the SP Mission");
	DisablePlayerCheckpoint(playerid);
	SetPlayerDrunkLevel(playerid,2000);
	SetPlayerWeather(playerid,10);
	DestroyPickup(miss1pickup);
	KillTimer(ausbtimerid);
	for(new srsp=0;srsp!=10;srsp++) if(IsPlayerNPC(srsp))
	{
		Kick(srsp);
		DestroyVehicle(helinpc[srsp]);
	}
	for(new desp=0;desp!=sizeof(missobjects2);desp++) DestroyObject(missobjects2[desp]);
	ForceClassSelection(playerid);
	SetPlayerHealth(playerid,0);
	
	return 1;
}

dcmd_wartung(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] != 3) return 0;
	if(wartung == 0)
	{
		SendRconCommand("hostname -Server unter Bearbeitung-");
		wartung = 1;
		SendClientMessageToAll(COLOR_RED,"Der Server wird gerade gewartet");
		SendClientMessageToAll(COLOR_RED,"Während dieser Arbeiten können nur Teammitglieder auf dem Server bleiben");
		SendClientMessageToAll(COLOR_RED,"Bitte warte, bis der Server wieder freigegeben ist");
		for(new wa=0;wa!=slots;wa++) if(IsPlayerConnected(wa) && adminlevel[wa] == 0) Kick(wa);
	}
	else
	{
	    wartung = 0;
	    SendClientMessageToAll(COLOR_GREEN,"Server geöffnet");
	    SendRconCommand("hostname Strategy TDM");
	}
	teammoney[0] = 5000000;
	teammoney[1] = 5000000;
	teamkills[0] = 50;
	teamkills[1] = 50;
	return 1;
}

dcmd_auszeichnungen(playerid,params[])
{
	#pragma unused params
	showachiv(playerid);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(wartung,7,cmdtext);
	dcmd(abort,5,cmdtext);
	dcmd(sethealth,9,cmdtext);
	dcmd(jetpack,7,cmdtext);
    if(GetPVarInt(playerid,"mission") == 1) return SendClientMessage(playerid,COLOR_RED,"Du brauchst keine Befehle");
    dcmd(setteam,7,cmdtext);
    dcmd(kill,4,cmdtext);
    if(GetPVarInt(playerid,"isdead") == 1) return SendClientMessage(playerid,COLOR_RED,"Du kannst während des Respawns keine Befehle nutzen");
	dcmd(cars,4,cmdtext);
	dcmd(tutorial,8,cmdtext);
	dcmd(auszeichnungen,14,cmdtext);
	dcmd(duell,5,cmdtext);
	dcmd(detonate,8,cmdtext);
	dcmd(source,6,cmdtext);
	dcmd(tower,5,cmdtext);
	dcmd(flak,4,cmdtext);
	dcmd(repair,6,cmdtext);
	dcmd(freeze,6,cmdtext);
	dcmd(unfreeze,8,cmdtext);
	dcmd(mission,7,cmdtext);
	dcmd(meat,4,cmdtext);
	dcmd(gethere,7,cmdtext);
    dcmd(deletefriend,12,cmdtext);
	dcmd(friends,7,cmdtext);
	dcmd(givekills,9,cmdtext);
	dcmd(addfriend,9,cmdtext);
	dcmd(spectate,8,cmdtext);
	dcmd(pm,2,cmdtext);
	dcmd(report,6,cmdtext);
	dcmd(plantmine,9,cmdtext);
	dcmd(airstrike,9,cmdtext);
	dcmd(paradrop,8,cmdtext);
	dcmd(help,4,cmdtext);
	dcmd(heal,4,cmdtext);
	dcmd(whosyourdaddy,13,cmdtext);
	dcmd(votekick, 8, cmdtext);
	dcmd(vote, 4, cmdtext);
	dcmd(moveto,6,cmdtext);
	dcmd(ban,3,cmdtext);
	dcmd(kick,4,cmdtext);
	dcmd(com,3,cmdtext);
	dcmd(resign,6,cmdtext);
	dcmd(createoil,9,cmdtext);
	dcmd(focus,5,cmdtext);
	dcmd(testhh,6,cmdtext);
	return 0;
}

dcmd_duell(playerid,params[])
{
    new einsatz,pID;
	if(sscanf(params, "dd",pID,einsatz)) return SendClientMessage(playerid,COLOR_RED,"Syntax : /duell [ID] [Einsatz]");
	if(playerid == pID) return SendClientMessage(playerid,COLOR_RED,"Scherzkeks");
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid,COLOR_RED,"Spieler nicht online");
	if(getrlmoney(playerid) < einsatz) return SendClientMessage(playerid,COLOR_RED,"Du hast nicht soviel SC");
	if(getrlmoney(pID) < einsatz) return SendClientMessage(playerid,COLOR_RED,"Dein Gegner hat nicht soviel SC");
	SendClientMessage(playerid,COLOR_GREY,"Dein Gegner wurde über deine Herausforderung benachrichtigt");
	SendClientMessage(playerid,COLOR_GREY,"Bitte warte auf seine Antwort");
	TogglePlayerControllable(playerid,0);
	SetPVarInt(playerid,"opponent",pID);
	SetPVarInt(pID,"opponent",playerid);
	SetPVarInt(playerid,"einsatz",einsatz);
	SetPVarInt(pID,"einsatz",einsatz);
	new formd[256];
	GetPlayerName(playerid,player_name[playerid],16);
	format(formd,256,"Du wurdest für ein Duell herausgefordert\nGegner : %s\nEinsatz : %d SC\n\nMöchtest du das Duell annehmen?",player_name[playerid],einsatz);
	ShowPlayerDialog(pID,151,0,"Du wurdest herausgefordert",formd,"Ja","Nein");
	return 1;
}

dcmd_repair(playerid,params[])
{
	#pragma unused params
	if(GetPVarInt(playerid,"skin") != 5) return SendClientMessage(playerid,COLOR_RED,"Nur Bauarbeiter können reparieren");
    new gtm = player[playerid][team]-1;
    new Float:gpof[3];
    GetPlayerPos(playerid,gpof[0],gpof[1],gpof[2]);
    for(new at=0;at!=gesamtgebaude[gtm]+1;at++)
	{
		if(gebaude[at][gtm][exists] == 1)
		{
			if(PointToPoint2D(gpof[0],gpof[1],gebaude[at][gtm][placex],gebaude[at][gtm][placey]) <= 30)
			{
                new needrepair=0,price = 0; //preis pro 50 health
                switch(gebaude[at][gtm][model])
                {
					case 3940:
					{
						if(gebaude[at][gtm][health] < 10000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 3637:
					{
						if(gebaude[at][gtm][health] < 1000)
						{
							needrepair=1;
							price=250;
						}
					}
                    case 3986:
					{
						if(gebaude[at][gtm][health] < 15000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 4726:
					{
						if(gebaude[at][gtm][health] < 15000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 4889:
					{
						if(gebaude[at][gtm][health] < 15000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 3998:
					{
						if(gebaude[at][gtm][health] < 8000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 9244:
					{
						if(gebaude[at][gtm][health] < 8000)
						{
							needrepair=1;
							price=100;
						}
					}
                    case 9237:
					{
						if(gebaude[at][gtm][health] < 1000)
						{
							needrepair=1;
							price=500;
						}
					}
                    case 987:
					{
						if(gebaude[at][gtm][health] < 15000)
						{
							needrepair=1;
							price=50;
						}
					}
                    case 18241:
					{
						if(gebaude[at][gtm][health] < 8000)
						{
							needrepair=1;
							price=100;
						}
					}
                }
                if(needrepair == 0 || price == 0) return SendClientMessage(playerid,COLOR_RED,"Kein beschädigtes Gebäude in der Nähe");
				SetPVarInt(playerid,"repairing",1);
				SendClientMessage(playerid,COLOR_GREY,"Du kannst mit LMouse das Bauen abbrechen");
				SetTimerEx("repair",0,0,"iiii",playerid,at,gtm,price); //sofortiger aufruf wg direktem startes
			}
		}
	}
	return 1;
}

forward repair(playerid,buildid,plteam,price);
public repair(playerid,buildid,plteam,price)
{
    if(teammoney[plteam]<price) return SendClientMessage(playerid,COLOR_RED,"Dein Team hat nicht genügend Geld dafür");
    new needrepair=0,newhealth[128];
    switch(gebaude[buildid][plteam][model])
    {
		case 3940: if(gebaude[buildid][plteam][health] < 10000) needrepair=1;
        case 3637: if(gebaude[buildid][plteam][health] < 1000) needrepair=1;
        case 3986: if(gebaude[buildid][plteam][health] < 15000) needrepair=1;
        case 4726: if(gebaude[buildid][plteam][health] < 15000) needrepair=1;
        case 4889: if(gebaude[buildid][plteam][health] < 15000) needrepair=1;
        case 3998: if(gebaude[buildid][plteam][health] < 8000) needrepair=1;
        case 9244: if(gebaude[buildid][plteam][health] < 8000) needrepair=1;
        case 9237: if(gebaude[buildid][plteam][health] < 1000) needrepair=1;
        case 987: if(gebaude[buildid][plteam][health] < 15000) needrepair=1;
        case 18241: if(gebaude[buildid][plteam][health] < 8000) needrepair=1;
    }
    if(needrepair == 0)
	{
		ClearAnimations(playerid);
		return SendClientMessage(playerid,COLOR_GREEN,"Building repaired");
	}
	if(!IsPlayerConnected(playerid) || GetPVarInt(playerid,"repairing") == 0 || !IsPlayerInRangeOfPoint(playerid,30,gebaude[buildid][plteam][placex],gebaude[buildid][plteam][placey],gebaude[buildid][plteam][placez])) return 0;
	else SetTimerEx("repair",5000,0,"iiii",playerid,buildid,plteam,price);
	ApplyAnimation(playerid,"BOMBER","BOM_Plant_Loop",4.2,1,0,0,1,0);
	gebaude[buildid][plteam][health] += 250;
    format(newhealth,128,"Team: %d\nLeben: %d",plteam+1,gebaude[buildid][plteam][health]);
	if(gebaude[buildid][plteam][model] == 9237) format(newhealth,128,"Team: %d\nLeben: %d\nGib /tower ein, um einzutreten",plteam+1,gebaude[buildid][plteam][health]);
    if(gebaude[buildid][plteam][model] == 9237) format(newhealth,128,"Team: %d\nLeben: %d\nGib /flak ein, um einzutreten",plteam+1,gebaude[buildid][plteam][health]);
	Update3DTextLabelText(gebaude[buildid][plteam][bubbleid],COLOR_GREY,newhealth);
	return 1;
}

forward tower_func(playerid,twid,Float:towerz);
public tower_func(playerid,twid,Float:towerz)
{
	if(IsPlayerConnected(playerid) && GetPVarInt(playerid,"ontower") == 1) SetTimerEx("tower_func",150,0,"iif",playerid,twid,towerz);
	if(gebaude[twid][player[playerid][team]-1][exists] != 1)
	{
	    SetPVarInt(playerid,"ontower",0);
	    SetPlayerHealth(playerid,0);
		return 0;
	}
	SetPVarInt(playerid,"checkz",GetPVarInt(playerid,"checkz")+1);
	if(GetPVarInt(playerid,"checkz") >= 10)
	{
	    SetPVarInt(playerid,"checkz",0);
		new Float:cho[6];
		GetPlayerPos(playerid,cho[0],cho[1],cho[2]);
		if(cho[2] < towerz)
		{
		    SetPVarInt(playerid,"ontower",0);
		    SetPlayerHealth(playerid,0);
		    SendClientMessage(playerid,COLOR_GREEN,"Turm verlassen");
			return 0;
		}
	}
	SetPlayerArmedWeapon(playerid,35);
	return 1;
}

dcmd_tower(playerid,params[])
{
	#pragma unused params
	new gtm,Float:dx,Float:dy,Float:dz,found = 0;
	GetPlayerPos(playerid,dx,dy,dz);
	gtm = player[playerid][team]-1;
	SetPVarInt(playerid,"ontower",!GetPVarInt(playerid,"ontower"));
	
    for(new at=0;at!=gesamtgebaude[gtm]+1;at++)
	{
		if(gebaude[at][gtm][exists] == 1)
		{
			if(PointToPoint2D(dx,dy,gebaude[at][gtm][placex],gebaude[at][gtm][placey]) <= 10)
			{
				if(gebaude[at][gtm][model] == 9237)
				{
				    if(GetPVarInt(playerid,"ontower") == 1)
				    {
	                    SetPlayerPos(playerid,gebaude[at][gtm][placex],gebaude[at][gtm][placey]+3,gebaude[at][gtm][placez]+4);
	                    SetPlayerHealth(playerid,100.0);
	                    SetPlayerHealth(playerid,10000.0);
						ResetPlayerWeapons(playerid);
						GivePlayerWeapon(playerid,35,99999);
						SetTimerEx("tower_func",150,0,"iif",playerid,at,gebaude[at][gtm][placez]-3);
						SendClientMessage(playerid,COLOR_GREEN,"Du bist auf einem Verteidigungsturm");
						SendClientMessage(playerid,COLOR_GREEN,"Du hast sehr viel Leben und einen RPG");
						SendClientMessage(playerid,COLOR_GREEN,"Töte alle Gegner");
						SendClientMessage(playerid,COLOR_GREEN,"Gib /tower ein, um den Turm zu verlassen");
						found = 1;
						break;
					}
					else
					{
					    SetPlayerHealth(playerid,100);
					    new Float:wannaz;
					    MapAndreas_FindZ_For2DCoord(gebaude[at][gtm][placex]+5,gebaude[at][gtm][placey]+5,wannaz);
					    SetPlayerPos(playerid,gebaude[at][gtm][placex]+5,gebaude[at][gtm][placey]+5,wannaz);
					    SendClientMessage(playerid,COLOR_GREEN,"Turm verlassen");
					    giveweaponset(playerid,0);
					    found = 1;
						break;
					}
				}
			}
		}
	}
	if(found == 0) return SendClientMessage(playerid,COLOR_RED,"Keine Türme in der Nähe");

	return 1;
}

dcmd_flak(playerid,params[])
{
	#pragma unused params
	new gtm,Float:dx,Float:dy,Float:dz,found = 0;
	GetPlayerPos(playerid,dx,dy,dz);
	gtm = player[playerid][team]-1;
	SetPVarInt(playerid,"ontower",!GetPVarInt(playerid,"ontower"));

    for(new at=0;at!=gesamtgebaude[gtm]+1;at++)
	{
		if(gebaude[at][gtm][exists] == 1)
		{
			if(PointToPoint2D(dx,dy,gebaude[at][gtm][placex],gebaude[at][gtm][placey]) <= 10)
			{
				if(gebaude[at][gtm][model] == 3502)
				{
				    if(GetPVarInt(playerid,"ontower") == 1)
				    {
				        new Float:wannaz;
					    MapAndreas_FindZ_For2DCoord(gebaude[at][gtm][placex],gebaude[at][gtm][placey],wannaz);
	                    SetPlayerPos(playerid,gebaude[at][gtm][placex],gebaude[at][gtm][placey],wannaz);
	                    SetPlayerHealth(playerid,100.0);
	                    SetPlayerHealth(playerid,10000.0);
						ResetPlayerWeapons(playerid);
						GivePlayerWeapon(playerid,38,99999);
						SendClientMessage(playerid,COLOR_GREEN,"Du bist in einem Flakgeschütz");
						SendClientMessage(playerid,COLOR_GREEN,"Du hast sehr viel Leben und ein Antiluft-Geschütz");
						SendClientMessage(playerid,COLOR_GREEN,"Töte alle Gegner");
						SendClientMessage(playerid,COLOR_GREEN,"Gib /flak ein, um den Turm zu verlassen");
						found = 1;
						break;
					}
					else
					{
					    SetPlayerHealth(playerid,100);
					    new Float:wannaz;
					    MapAndreas_FindZ_For2DCoord(gebaude[at][gtm][placex]+5,gebaude[at][gtm][placey]+5,wannaz);
					    SetPlayerPos(playerid,gebaude[at][gtm][placex]+5,gebaude[at][gtm][placey]+5,wannaz);
					    SendClientMessage(playerid,COLOR_GREEN,"Flak verlassen");
					    giveweaponset(playerid,0);
					    found = 1;
						break;
					}
				}
			}
		}
	}
	if(found == 0) return SendClientMessage(playerid,COLOR_RED,"Keine Flak in der Nähe");

	return 1;
}

dcmd_source(playerid,params[])
{
    if(adminlevel[playerid] != 3) return 0;
    SetPlayerPos(playerid,oil_info[strval(params)][posx],oil_info[strval(params)][posy],oil_info[strval(params)][posz]);
	return 1;
}

dcmd_detonate(playerid,params[])
{
	#pragma unused params
    if(GetPVarInt(playerid,"planted") == 0) return SendClientMessage(playerid,COLOR_RED,"Du musst zuerst C4 platzieren");
	SetPVarInt(playerid,"planted",0);
	CreateExplosion(GetPVarFloat(playerid,"c4_asx"),GetPVarFloat(playerid,"c4_asy"),GetPVarFloat(playerid,"c4_asz"),6,5);
    SendClientMessage(playerid,COLOR_GREY,"C4 detonatiert");
    SetPVarInt(playerid,"dmg",0);

    damagearea(playerid,GetPVarFloat(playerid,"c4_asx"),GetPVarFloat(playerid,"c4_asy"),GetPVarFloat(playerid,"c4_asz"),500);
	return 1;
}

dcmd_tutorial(playerid,params[])
{
    SetPVarInt(playerid,"tutorial",1);
    SetPVarInt(playerid,"tutorial_nr",strval(params));
    SetPlayerColor(playerid,0xFFFFFF00);
    ShowPlayerDialog(playerid,912,0,"Tutorial","Willkommen zum Tutorial\nIch würde dir gerne das Strategy TDM Genre erklären\nBitte lies das Tutorial sorgfältig, es enthält wichtige Informationen\nDu kannst das Tutorial jederzeit abbrechen","Ok","Abbrechen");

	return 1;
}

dcmd_meat(playerid,params[])
{
	#pragma unused params
	if(player[playerid][position] != 4) return SendClientMessage(playerid,COLOR_RED,"Dieser Befehl ist für Commander");
	ShowPlayerDialog(playerid,137,2,"Meat Shop","+3 teamkills\t\t\t15 meat\n+1 kill\t\t\t\t15 meat\nHeile 1 Einheit\t\t\t1 meat\nHeil Team\t\t\t30 meat","Select","Abbrechen");
	return 1;
}

dcmd_pm(playerid,params[])
{
	new checkstr[128],pID,text[128];
	if(sscanf(params, "dz",pID,text)) return SendClientMessage(playerid,COLOR_RED,"Syntax : /pm [ID] [text]");
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid,COLOR_RED,"ID nicht verfügbar");
	GetPVarString(playerid,"lasttext",checkstr,128);
	if(!strcmp(checkstr,text))
	{
	    SetPVarString(playerid,"lasttext",text);
		SendClientMessage(playerid,COLOR_YELLOW,"Private Nachricht gesendet");
		return 1;
	}
	else SetPVarString(playerid,"lasttext",text);
	SendClientMessage(playerid,COLOR_YELLOW,"Private Nachricht gesendet");
	new formpm[128],pmnm[16];
	GetPlayerName(playerid,pmnm,16);
	format(formpm,128,"PM from %s(%d): %s",pmnm,playerid,text);
	SendClientMessage(pID,COLOR_YELLOW,formpm);
	return 1;
}

dcmd_givekills(playerid,params[])
{
	if(adminlevel[playerid] != 3) return 0;
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax: /givekills [Value]");
	
	teamkills[player[playerid][team]-1] += strval(params);
 	return 1;
}

dcmd_gethere(playerid,params[])
{
	if(adminlevel[playerid] == 0) return 0;
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax: /gethere [ID]");
	if(GetPVarInt(strval(params),"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"He hasnt been reported yet, dont abuse");
	if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid,COLOR_RED,"ID nicht online");
	new Float:gtpos[3];
	GetPlayerPos(playerid,gtpos[0],gtpos[1],gtpos[2]);
	if(!IsPlayerInAnyVehicle(strval(params))) SetPlayerPos(strval(params),gtpos[0],gtpos[1],gtpos[2]+1);
	else SetVehiclePos(GetPlayerVehicleID(strval(params)),gtpos[0],gtpos[1],gtpos[2]+1);
	return 1;
}

dcmd_spectate(playerid,params[])
{
	if(adminlevel[playerid] == 0) return 0;
	if(!strlen(params)) return TogglePlayerSpectating(playerid,0);
	TogglePlayerSpectating(playerid,1);
	PlayerSpectatePlayer(playerid,strval(params));
	return 1;
}

forward unastrike(playerid);
public unastrike(playerid)
{
    SetPVarInt(playerid,"astrike",0);
    SendClientMessage(playerid,COLOR_GREEN,"Du kannst /airstrike & /paradrop wieder nutzen");
	return 1;
}

forward unmine(playerid);
public unmine(playerid)
{
    SetPVarInt(playerid,"mined",0);
	return 1;
}

forward astrike_f(playerid,Float:asx,Float:asy,Float:asz);
public astrike_f(playerid,Float:asx,Float:asy,Float:asz)
{
	//SendClientMessage(playerid,COLOR_GREEN,"Airstrike arriving");
    CreateExplosion(asx,asy,asz+1,6,5);
	CreateExplosion(asx+3,asy,asz+1,6,5);
	CreateExplosion(asx+2,asy,asz+1,6,5);
	CreateExplosion(asx+4,asy,asz+1,6,5);
	CreateExplosion(asx+6,asy,asz+1,6,5);
	CreateExplosion(asx+8,asy,asz+1,6,5);
	CreateExplosion(asx+10,asy,asz+1,6,5);
	CreateExplosion(asx+12,asy,asz+1,6,5);
	CreateExplosion(asx+14,asy,asz+1,6,5);
	CreateExplosion(asx+16,asy,asz+1,6,5);
	CreateExplosion(asx+18,asy,asz+1,6,5);
	CreateExplosion(asx+20,asy,asz+1,6,5);
	CreateExplosion(asx+22,asy,asz+1,6,5);
	CreateExplosion(asx+24,asy,asz+1,6,5);
	CreateExplosion(asx+26,asy,asz+1,6,5);
	CreateExplosion(asx+28,asy,asz+1,6,5);
	CreateExplosion(asx+30,asy,asz+1,6,5);
	CreateExplosion(asx+32,asy,asz+1,6,5);
	damagearea(playerid,asx,asy,asz,500);
	SetTimerEx("destandro",10000,0,"i",playerid);
	triggerachiv(playerid,19);
	return 1;
}

forward destandro(playerid);
public destandro(playerid)
{
    DestroyObjectToStream(GetPVarInt(playerid,"Adromada"));
    DestroyObjectToStream(GetPVarInt(playerid,"Adromada2"));
	return 1;
}

dcmd_plantmine(playerid,params[])
{
	#pragma unused params
	if(GetPlayerState(playerid) != 1) return SendClientMessage(playerid,COLOR_RED,"Du musst zu Fuß sein");
	if(GetPVarInt(playerid,"mined") == 1) return SendClientMessage(playerid,COLOR_RED,"Du kannst nur jede Minute eine Mine legen");
	SetPVarInt(playerid,"mined",1);
	SetTimerEx("unmine",60000,0,"i",playerid);
	
	new tmpoutput3[128],nlm[16];
	GetPlayerName(playerid,nlm,16);
    format(mysqlquery[playerid],256,"SELECT kills FROM sav_score WHERE name = '%s'",nlm);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_fetch_field("kills",tmpoutput3))
	{
		if(strval(tmpoutput3) < 100) return SendClientMessage(playerid,COLOR_RED,"Du benötigst 100 kills");
		new Float:aspos[3];
		SetPVarInt(playerid,"planted",1);
		GetPlayerPos(playerid,aspos[0],aspos[1],aspos[2]);
		SetPVarFloat(playerid,"mx",aspos[0]);
		SetPVarFloat(playerid,"my",aspos[1]);
		SetPVarFloat(playerid,"mz",aspos[2]);
		DestroyPickup(GetPVarInt(playerid,"mineid"));
		SetPVarInt(playerid,"mineid",CreatePickup(1510,14,aspos[0],aspos[1],aspos[2]-1.03));
		SendClientMessage(playerid,COLOR_GREEN,"Mine planted");
	}
	mysql_free_result();
	return 1;
}

dcmd_airstrike(playerid,params[])
{
	#pragma unused params
	if(GetPlayerState(playerid) != 1) return SendClientMessage(playerid,COLOR_RED,"Du musst zu Fuß sein");
	if(GetPVarInt(playerid,"astrike") == 1) return SendClientMessage(playerid,COLOR_RED,"Du kannst /airstrike & /paradrop nur alle 10 Minuten nutzen");
	SetPVarInt(playerid,"astrike",1);
	SetTimerEx("unastrike",600000,0,"i",playerid);
	new tmpoutput3[128],nlm[16];
	GetPlayerName(playerid,nlm,16);
    format(mysqlquery[playerid],256,"SELECT kills FROM sav_score WHERE name = '%s'",nlm);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_fetch_field("kills",tmpoutput3))
	{
			if(strval(tmpoutput3) < 100) return SendClientMessage(playerid,COLOR_RED,"Du benötigst 100 kills");
            AllowPlayerTeleport(playerid,1);
            TogglePlayerControllable(playerid,0);
            SendClientMessage(playerid,COLOR_RED,"Um ein Ziel zu definieren, drück Escape,");
            SendClientMessage(playerid,COLOR_RED,"wähle die Karte aus und drück rechts auf das Ziel");
			new Float:aspos[3];
			GetPlayerPos(playerid,aspos[0],aspos[1],aspos[2]);
			SetPVarFloat(playerid,"asx",aspos[0]);
			SetPVarFloat(playerid,"asy",aspos[1]);
			SetPVarFloat(playerid,"asz",aspos[2]);
			
			SetTimerEx("astrike_check",1000,0,"i",playerid);
	}
	mysql_free_result();
	return 1;
}

dcmd_paradrop(playerid,params[])
{
	#pragma unused params
	if(GetPlayerState(playerid) != 1) return SendClientMessage(playerid,COLOR_RED,"Du musst zu Fuß sein");
	if(GetPVarInt(playerid,"astrike") == 1) return SendClientMessage(playerid,COLOR_RED,"Du kannst /airstrike & /paradrop nur alle 10 Minuten nutzen");
	SetPVarInt(playerid,"astrike",1);
	SetTimerEx("unastrike",600000,0,"i",playerid);
	new tmpoutput3[128],nlm[16];
	GetPlayerName(playerid,nlm,16);
    format(mysqlquery[playerid],256,"SELECT kills FROM sav_score WHERE name = '%s'",nlm);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_fetch_field("kills",tmpoutput3))
	{
			if(strval(tmpoutput3) < 100) return SendClientMessage(playerid,COLOR_RED,"Du benötigst 100 kills");
			AllowPlayerTeleport(playerid,1);
            TogglePlayerControllable(playerid,0);
            SendClientMessage(playerid,COLOR_RED,"Um ein Ziel zu definieren, drück Escape,");
            SendClientMessage(playerid,COLOR_RED,"wähle die Karte aus und drück rechts auf das Ziel");
			new Float:aspos[3];
			GetPlayerPos(playerid,aspos[0],aspos[1],aspos[2]);
			SetPVarFloat(playerid,"asx",aspos[0]);
			SetPVarFloat(playerid,"asy",aspos[1]);
			SetPVarFloat(playerid,"asz",aspos[2]);
			
			SetPVarInt(playerid,"Adromada",CreateObjectToStream(14553,aspos[0],aspos[1],aspos[2]+100,0.000000,0.000000,90));
    		MoveObjectToStream(GetPVarInt(playerid,"Adromada"),aspos[0],aspos[1],aspos[2]+10,25);

			SetTimerEx("paradrop_check",1000,0,"i",playerid);
	}
	mysql_free_result();
	return 1;
}

forward paradrop_check(playerid);
public paradrop_check(playerid)
{
    new Float:aspos2[3];
	GetPlayerPos(playerid,aspos2[0],aspos2[1],aspos2[2]);
	if(aspos2[0] != GetPVarFloat(playerid,"asx") || aspos2[1] != GetPVarFloat(playerid,"asy") || aspos2[2] != GetPVarFloat(playerid,"asz"))
	{
	    MoveObjectToStream(GetPVarInt(playerid,"Adromada"),GetPVarFloat(playerid,"asx"),GetPVarFloat(playerid,"asy"),GetPVarFloat(playerid,"asz")+600,25);
	    
	    AllowPlayerTeleport(playerid,0);
	    SetPlayerPos(playerid,GetPVarFloat(playerid,"asx"),GetPVarFloat(playerid,"asy"),GetPVarFloat(playerid,"asz"));
	    SendClientMessage(playerid,COLOR_RED,"Mach dich bereit");
	    new Float:targp[3],Float:nonsense;
	    GetPlayerPos(playerid,targp[0],targp[1],nonsense);
	    MapAndreas_FindZ_For2DCoord(targp[0],targp[1],targp[2]);
	    
	    SetPlayerCameraPos(playerid,targp[0],targp[1],targp[2]+150);
	    SetPlayerCameraLookAt(playerid,targp[0],targp[1],targp[2]);

	    SetPVarInt(playerid,"Adromada2",CreateObjectToStream(14553,targp[0]-150,targp[1],targp[2]+100,0.000000,0.000000,90));
    	MoveObjectToStream(GetPVarInt(playerid,"Adromada2"),targp[0]+550,targp[1],targp[2]+100,50);
		SetTimerEx("paradrop_f",4000,0,"ifff",playerid,targp[0],targp[1],targp[2]);
		TogglePlayerControllable(playerid,1);
		GivePlayerWeapon(playerid,46,1);
	}
	else SetTimerEx("paradrop_check",500,0,"i",playerid);
	return 1;
}

forward paradrop_f(playerid,Float:asx,Float:asy,Float:asz);
public paradrop_f(playerid,Float:asx,Float:asy,Float:asz)
{
	SetCameraBehindPlayer(playerid);
    SetPlayerPos(playerid,asx,asy,asz+100);
    ClearAnimations(playerid);
	SetTimerEx("destandro",10000,0,"i",playerid);
	triggerachiv(playerid,18);
	return 1;
}

forward astrike_check(playerid);
public astrike_check(playerid)
{
    new Float:aspos2[3];
	GetPlayerPos(playerid,aspos2[0],aspos2[1],aspos2[2]);
	if(aspos2[0] != GetPVarFloat(playerid,"asx") || aspos2[1] != GetPVarFloat(playerid,"asy") || aspos2[2] != GetPVarFloat(playerid,"asz"))
	{
	    AllowPlayerTeleport(playerid,0);
	    SetPlayerPos(playerid,GetPVarFloat(playerid,"asx"),GetPVarFloat(playerid,"asy"),GetPVarFloat(playerid,"asz"));
	    SendClientMessage(playerid,COLOR_RED,"Ziel markiert, Airstrike kommt");
	    new Float:targp[3],Float:nonsense;
	    GetPlayerPos(playerid,targp[0],targp[1],nonsense);
	    MapAndreas_FindZ_For2DCoord(targp[0],targp[1],targp[2]);
	    
	    SetPVarInt(playerid,"Adromada",CreateObjectToStream(14553,targp[0]-150,targp[1],targp[2]+40,0.000000,0.000000,90));
    	MoveObjectToStream(GetPVarInt(playerid,"Adromada"),targp[0]+550,targp[1],targp[2]+40,50);
		SetTimerEx("astrike_f",4000,0,"ifff",playerid,targp[0],targp[1],targp[2]);
		TogglePlayerControllable(playerid,1);
	}
	else SetTimerEx("astrike_check",500,0,"i",playerid);
	return 1;
}

dcmd_setteam(playerid,params[])
{
	if(adminlevel[playerid] <= 2) return 0;
	new pID,newteam;
	if(sscanf(params, "dd",pID,newteam)) return SendClientMessage(playerid,COLOR_RED,"Syntax : /setteam [playerid] [Team]");
    teamnumber[player[pID][team]-1] -= 1;
	if(newteam == 2)
	{
		player[pID][team] = 2;
	    SetPlayerTeam(pID,2);
	    SetPlayerColor(pID,COLOR_RED);
	    teamnumber[1] += 1;
	    return 1;
	}
	if(newteam == 1)
	{
	    player[pID][team] = 1;
	    SetPlayerTeam(pID,1);
	    SetPlayerColor(pID,COLOR_GREEN);
	    teamnumber[0] += 1;
	    return 1;
	}
	return 1;
}

dcmd_help(playerid,params[])
{
	#pragma unused params
	ShowPlayerDialog(playerid,99,2,"Hilfemeü","Commander Tasten\nKlassen\nGebäude\nTricks\nGameplay\nFreundessystem\nCredits\nMeat System","Select","Abbrechen");
	return 1;
}

forward healcooldown(playerid);
public healcooldown(playerid)
{
    SetPVarInt(playerid,"healed",0);
	SendClientMessage(playerid,COLOR_RED,"Du kannst wieder jemanden heilen per /heal");
	return 1;
}

dcmd_heal(playerid,params[])
{
	if(GetPVarInt(playerid,"skin") != 0) return 0;
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax: /heal [playerid]");
	if(strval(params) == playerid) return SendClientMessage(playerid,COLOR_RED,"Du kannst dich nicht selber heilen");
	if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid,COLOR_RED,"ID nicht online");
	if(GetPVarInt(playerid,"healed") == 1) return SendClientMessage(playerid,COLOR_RED,"Du musst 30 Sekunden warten");
    if(player[playerid][team] != player[strval(params)][team]) return SendClientMessage(playerid,COLOR_RED,"Du kannst nur Kameraden heilen");
	SetPVarInt(playerid,"healed",1);
	SetPlayerHealth(strval(params),100);
	SetTimerEx("healcooldown",30000,0,"i",playerid);
	SendClientMessage(playerid,COLOR_YELLOW,"Erfolgreich geheilt");
	SendClientMessage(strval(params),COLOR_YELLOW,"Du wurdest geheilt");
	return 1;
}

dcmd_whosyourdaddy(playerid,params[])
{
	if(adminlevel[playerid] != 3) return 0;
	teammoney[player[playerid][team]-1] += strval(params);
	print("whosyourdaddy cheated");
	return 1;
}

public geldausgabe()
{
	SetTimer("geldausgabe",10000,0);

	if(GetVehicleModel(GetPlayerVehicleID(capture[5])) != 577)
	{
	    DestroyVehicle(capture[4]);
		capture[4] = CreateVehicle(577,1584.0732,1188.7935,10.7769,183.4205,0,0,5);
	}

	if(capture[8] == 0)
	{
	    DestroyPickup(capture[1]);
	    capture[1] = CreatePickup(2993,23,1585.7305,1447.5050,10.8352,-1);
	}
	if(capture[9] == 0)
	{
		DestroyPickup(capture[3]);
		capture[3] = CreatePickup(2993,23,-362.1327,1584.2163,76.4585,-1);
	}
	meattimes += 1;
	new found[2];
	found[0] = 0,found[1] = 0;
	for(new search=0;search!=slots;search++)
	{
	    if(IsPlayerConnected(search))
	    {
	        found[player[search][team]-1] = 1;
	    }
	}
	if(found[0] == 1)
	{
		if(building_number[clone][0] != 0)
		{
		    teammoney[0] += 50+(building_number[OilWellDerrick][0]*50);
		}
		producedtanks[0] += building_number[TankFac][0];
		producedhunters[0] += building_number[HunterFac][0];
	    producedcars[0] += building_number[CarFac][0];
	    
	    if(meattimes >= 3)
	    {
	        new found_build = 0;
	        for(new at=0;at!=gesamtgebaude[0]+1;at++)
			{
				if(gebaude[at][0][exists] == 1)
				{
					if(PointToPoint2D(oil_info[8][posx],oil_info[8][posy],gebaude[at][0][placex],gebaude[at][0][placey]) <= 100)
					{
					    found_build = 1;
					    break;
					}
				}
			}
		    if(found_build == 1)
			{
			    for(new sa=0;sa!=slots;sa++) if(IsPlayerConnected(sa) && player[sa][team] == 1 && player[sa][position] == 4) triggerachiv(sa,14);
				meat[0] += 1;
			}
		}
	}
	if(found[1] == 1)
	{
		if(building_number[clone][1] != 0)
		{
		    teammoney[1] += 50+(building_number[OilWellDerrick][1]*50);
		}
		producedtanks[1] += building_number[TankFac][1];
		producedhunters[1] += building_number[HunterFac][1];
	    producedcars[1] += building_number[CarFac][1];
	    
	    if(meattimes >= 3)
	    {
	        new found_build = 0;
	        for(new at=0;at!=gesamtgebaude[1]+1;at++)
			{
				if(gebaude[at][1][exists] == 1)
				{
					if(PointToPoint2D(oil_info[8][posx],oil_info[8][posy],gebaude[at][1][placex],gebaude[at][1][placey]) <= 100)
					{
					    found_build = 1;
					    break;
					}
				}
			}
		    if(found_build == 1)
			{
                for(new sa=0;sa!=slots;sa++) if(IsPlayerConnected(sa) && player[sa][team] == 1 && player[sa][position] == 4) triggerachiv(sa,14);
                meat[1] += 1;
			}
		}
	}
	if(meattimes >= 3) meattimes = 0;
	for(new update=0;update!=slots;update++)
	{
	    if(IsPlayerConnected(update) && isspawned[update] == 1)
	    {
   			updatebar(update);
		}
		if(player[update][position] == 4 && !IsPlayerInAnyVehicle(update))
		{
			PutPlayerInVehicle(update,comcar[player[update][team]-1],0);
		}
	}

    for(new enable=0;enable<=slots;enable++)
	{
		if(IsPlayerConnected(enable))
		{
			if(player[enable][team] == capture[7])
			{
				for(new p; p!=slots; p++) if(IsPlayerConnected(p)) SetPlayerMarkerForPlayer(enable,p,GetPlayerColor(p));
			}
			else
			{
				for(new p=0; p!=slots; p++) if(IsPlayerConnected(p)) SetPlayerMarkerForPlayer(enable,p,( GetPlayerColor(p) & 0xFFFFFF00 ));
			}
		}
	}

	return 1;
}


dcmd_focus(playerid,params[])
{
	if(player[playerid][position] != 4) return 0;
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax: /focus [ID]");
	if(player[strval(params)][team] != player[playerid][team]) return SendClientMessage(playerid,COLOR_RED,"Spieler nicht in deinem Team");
	
	new Float:focuspos[3];
	GetPlayerPos(strval(params),focuspos[0],focuspos[1],focuspos[2]);

    comview[player[playerid][team]-1][0] = focuspos[0],comview[player[playerid][team]-1][1] = focuspos[1];

    SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
	SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);

	return 1;
}

dcmd_resign(playerid,params[])
{
	#pragma unused params
	if(player[playerid][position] != 4) return 0;
	switch(player[playerid][team])
	{
	    case 1:SetPlayerColor(playerid,COLOR_GREEN);
	    case 2:SetPlayerColor(playerid,COLOR_RED);
	}
	SetPlayerVirtualWorld(playerid,0);
	comzoom[player[playerid][team]-1] = 200.0,player[playerid][position] = 0;
	new rsmsg[128];
	format(rsmsg,128,"Der Commander von Team %d hat abgedankt",player[playerid][team]);
	SendClientMessageToAll(COLOR_YELLOW,rsmsg);
	SetCameraBehindPlayer(playerid);
	GangZoneHideForPlayer(playerid,blockradar);
	SetPlayerWorldBounds(playerid,20000.0000, -20000.0000, 20000.0000, -20000.0000);
	ForceClassSelection(playerid);
	SetPVarInt(playerid,"ausnahme",1);
	SetPlayerHealth(playerid,0);
	player[playerid][position] = 0;
	return 1;
}

dcmd_com(playerid,params[])
{
	#pragma unused params
	if(GetPlayerScore(playerid) < 15) return SendClientMessage(playerid,COLOR_GREY,"Du benötigst 15 Kills");
	if(player[playerid][position] == 4 || player[playerid][team] == 0) return 1;
    new found_com =0;
    for(new check=0;check<=slots;check++)
    {
        if(IsPlayerConnected(check))
        {
            if(player[check][team] == player[playerid][team] && player[check][position] == 4 ) //4 = commander
            {
                found_com = 1;
                break;
            }
        }
    }
    if(found_com == 1) return SendClientMessage(playerid,COLOR_RED,"Posten bereits besetzt");
    SetPlayerColor( playerid, 0xFFFFFF00 );
	SetPlayerVirtualWorld(playerid,50);
    new asmsg[128],nm[16];
    GetPlayerName(playerid,nm,16);
	DestroyVehicle(veh[playerid]);
	veh[playerid] = -1;
    format(asmsg,128,"Spieler %s ist der neue Commander von Team %d",nm,player[playerid][team]);
    triggerachiv(playerid,11);
    SendClientMessageToAll(COLOR_YELLOW,asmsg);
    SetPlayerWorldBounds(playerid,20000.0000, -20000.0000, 20000.0000, -20000.0000);
    GangZoneShowForPlayer(playerid, blockradar, 0x000000FF);
    player[playerid][position] = 4;
    SpawnPlayer(playerid);
    return 1;
}

dcmd_vote(playerid,params[])
{
	#pragma unused playerid
	#pragma unused params
	if(vote == 0) { return 0; }
	votes = votes + 1;
	return 1;
}

dcmd_testhh(playerid,params[])
{
    if(!IsPlayerConnected(strval(params))) return 0;
	if(!strlen(params)) return SendClientMessage(playerid,COLOR_RED,"Syntax: /testhh [ID]");
    if(GetPVarInt(strval(params),"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"He hasnt been reported yet, dont abuse");
	//SendClientMessage(strval(params),COLOR_RED,"An Admin tests you for Health-Hacks");
	SetPlayerHealth(strval(params),100);
	SetPlayerVirtualWorld(strval(params),strval(params)+1);
	new Float:aspos[3];
	GetPlayerPos(strval(params),aspos[0],aspos[1],aspos[2]);
	SetPVarFloat(strval(params),"asx",aspos[0]);
	SetPVarFloat(strval(params),"asy",aspos[1]);
	SetPVarFloat(strval(params),"asz",aspos[2]);
	RemovePlayerFromVehicle(strval(params));
	
    SetPlayerPos(strval(params),197.7850,175.3622,1003.0234);
    CreateExplosion(197.7850,175.3622,1003.0234,8,15);
	SetTimerEx("testhh2",500,0,"ii",strval(params),playerid);
	return 1;
}

forward testhh2(playerid,admin);
public testhh2(playerid,admin)
{
	new Float:gh;
	GetPlayerHealth(playerid,gh);
	if(gh == float(100))
	{
	    SendClientMessage(admin,COLOR_RED,"Spieler cheatet");
	    SetPlayerPos(playerid,GetPVarFloat(playerid,"asx"),GetPVarFloat(playerid,"asy"),GetPVarFloat(playerid,"asz"));
	    SetPlayerHealth(playerid,100);
	    SetPlayerVirtualWorld(playerid,0);
	}
	else
	{
	    SendClientMessage(playerid,COLOR_GREEN,"Du wurdest gegen Godmode geprüft");
	    SendClientMessage(admin,COLOR_GREEN,"Spieler sauber");
	    SetPlayerPos(playerid,GetPVarFloat(playerid,"asx"),GetPVarFloat(playerid,"asy"),GetPVarFloat(playerid,"asz"));
	    SetPlayerHealth(playerid,100);
	    SetPlayerVirtualWorld(playerid,0);
	}

	return 1;
}

dcmd_moveto(playerid, params[])
{
	if(adminlevel[playerid] == 0) return 0;
	//if(GetPVarInt(strval(params),"reported") == 0 || adminlevel[playerid] != 3) return SendClientMessage(playerid,COLOR_RED,"He hasnt been reported yet, dont abuse");
    new Float:x,Float:y,Float:z;
	GetPlayerPos(strval(params),x,y,z);
	SetPlayerPos(playerid,x,y,z);
	return 1;
}

dcmd_votekick(playerid, params[])
{
	for(new a; a<slots; a++)
	{
	    if(IsPlayerConnected(a) && adminlevel[a] >= 1) { return SendClientMessage(playerid,COLOR_RED,"Admins sind online, sprich mit diesen !"); }
	}
	if(vote == 1) { return SendClientMessage(playerid,COLOR_GREY,"Voting noch aktiv !"); }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /votekick [playerid] [Reason]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID nicht online !");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"Votekick gegen %s (ID %d), Grund: %s",ThePlayer,pID,sGrund[0] ? sGrund : "<Kein Grund>");
	SendClientMessageToAll(COLOR_RED,string);
	SendClientMessageToAll(COLOR_RED,"Gib /vote ein, wenn du ihn rauswerfen willst !");
	vote = 1;
	votes = 0;
	SetTimerEx("voteoff",30000,0,"i",pID);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(vehicleid == capture[4])
	{
	    if(capture[5] != playerid && GetVehicleModel(GetPlayerVehicleID(capture[5])) == 577 && IsPlayerConnected(capture[5]) )
		{
		    TogglePlayerControllable(playerid,0);
	    	TogglePlayerControllable(playerid,1);
			SendClientMessage(playerid,COLOR_RED,"Klaue keine Autos");
			return 1;
		}
	    if(capture[6] != player[playerid][team])
	    {
	        TogglePlayerControllable(playerid,0);
	    	TogglePlayerControllable(playerid,1);
			SendClientMessage(playerid,COLOR_RED,"Dein Team besitzt den Flughafen nicht");
			return 1;
		}
		capture[5] = playerid;
		SendClientMessage(playerid,COLOR_YELLOW,"Du betrittst den AT-400 Bomber");
		SendClientMessage(playerid,COLOR_YELLOW,"Wirf einen Bombenteppich ab per L.Mouse / STRG");
		triggerachiv(playerid,3);
		return 1;
	}
	if(ispassenger == 0 && vehicleid != veh[playerid])
	{
	    TogglePlayerControllable(playerid,0);
	    TogglePlayerControllable(playerid,1);
	    RemovePlayerFromVehicle(playerid);
	    SendClientMessage(playerid,COLOR_RED,"Klau keine Autos, benutz /cars");
	    return 0;
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(player[playerid][position] == 4)
	{
		PutPlayerInVehicle(playerid,comcar[player[playerid][team]-1],0);
		return 0;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(player[playerid][position] == 4 && (oldstate == 2 && newstate == 1))
	{
		PutPlayerInVehicle(playerid,comcar[player[playerid][team]-1],0);
		SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
		return 0;
	}
	/*
	if(oldstate == 2 && newstate == 1)
	{
	    DestroyVehicle(veh[playerid]);
	    veh[playerid] = -1;
	}
	*/
	if(newstate == 5)
	{
	    if(GetPlayerVehicleID(playerid) != veh[playerid])
	    {
		    TogglePlayerControllable(playerid,0);
		    TogglePlayerControllable(playerid,1);
		    RemovePlayerFromVehicle(playerid);
		    SendClientMessage(playerid,COLOR_RED,"Klau keine Autos, benutz /cars");
		    return 0;
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(GetPVarInt(playerid,"mission") == 1)
	{
	    for(new kb=0;kb!=10;kb++)
		{
		    new npcn[16];
	    	GetPlayerName(kb,npcn,16);
			if(IsPlayerNPC(kb) && strcmp(npcn,"helibot")) Kick(kb);
		}
	    nextcp(playerid);
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
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

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	
    if(loggedin[playerid] == 0 && playersonline != 1)
	{
		ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Willkommen zurück auf dem Savandreas Strategy TDM Server\n\nGib dein Passwort ein:","Ok","");
	    return 0;
	}
	SetPVarInt(playerid,"choosespawn",GetPVarInt(playerid,"choosespawn")+1);
	if(GetPVarInt(playerid,"choosespawn") == 1)
	{
	    TextDrawHideForPlayer(playerid,classinfo[playerid]);
	    SetPlayerCameraPos(playerid, 1931.7674, -2417.5302, 1205.6908);
		SetPlayerCameraLookAt(playerid, 1931.7674, -2417.5202, 1200.6908);
		
		SetPVarInt(playerid,"entrypoint",0);
		SetPVarInt(playerid,"prev_class",4);
		return 0;
	}
	DestroyPlayerObject(playerid,GetPVarInt(playerid,"spawnflag"));
 	if(teamnumber[0] > teamnumber[1]+2)
    {
        teamnumber[0] -= 1;
        player[playerid][team] = 2;
        SetPlayerTeam(playerid,2);
        SetPlayerColor(playerid,COLOR_RED);
        teamnumber[1] += 1;
        SendClientMessage(playerid,COLOR_YELLOW,"Du wurdest in Team 2 verschoben");
	}
	if(teamnumber[0]+2 < teamnumber[1])
	{
	    teamnumber[1] -= 1;
	    player[playerid][team] = 1;
	    SetPlayerTeam(playerid,1);
	    SetPlayerColor(playerid,COLOR_GREEN);
	    teamnumber[0] += 1;
	    SendClientMessage(playerid,COLOR_YELLOW,"Du wurdest in Team 1 verschoben");
	}
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

forward ausbildungstimer(playerid);
public ausbildungstimer(playerid)
{
	KillTimer(ausbtimerid);
	TextDrawShowForPlayer(playerid,counter);
	ausbildungstime -= 1;
	new ausbtimer[128];
    format(ausbtimer,128,"Zeit: ~n~%d",ausbildungstime);
    TextDrawSetString(counter,ausbtimer);
    if(ausbildungstime <= 0)
	{
	    if(cpnumber != 10)
	    {
			TextDrawHideForPlayer(playerid,counter);
			new Float:gw[3];
			GetPlayerPos(playerid,gw[0],gw[1],gw[2]);
			if(gw[2] < 16.103621) CreateExplosion(gw[0],gw[1],gw[2],0,15);
			return 1;
		}
		else miss_win(playerid);
	}
    ausbtimerid = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
 	return 1;
}

forward capture1(playerid);
public capture1(playerid)
{
    if(!IsPlayerInRangeOfPoint(playerid,2,1585.7305,1447.5050,10.8352))
    {
   		GangZoneStopFlashForAll(capture[0]);
   		SetPVarInt(playerid,"capturing",0);
   		capture[8] = 0;
        return SendClientMessage(playerid,COLOR_RED,"Du hast die Flagge verlassen");
    }
    if(GetPVarInt(playerid,"notafk") == 1) SetPVarInt(playerid,"notafk",0);
    else
    {
        GangZoneStopFlashForAll(capture[0]);
        SetPVarInt(playerid,"capturing",0);
        capture[8] = 0;
        return SendClientMessage(playerid,COLOR_RED,"Du kannst die Flagge nicht einnehmen, während du AFK bist");
    }
    SetPVarInt(playerid,"capture",GetPVarInt(playerid,"capture")-1);

	if(GetPVarInt(playerid,"capture") <= 0)
	{
		GangZoneStopFlashForAll(capture[0]);
	    switch(player[playerid][team])
		{
		    case 1:GangZoneShowForAll(capture[0],COLOR_GREEN);
		    case 2:GangZoneShowForAll(capture[0],COLOR_RED);
		}
	    capture[6] = player[playerid][team];
	    new formma2[256];
		GetPlayerName(playerid,player_name[playerid],16);
		format(formma2,256,"%s (Team %d) hat den Flughafen eingenommen",player_name[playerid],player[playerid][team]);
		SendClientMessageToAll(COLOR_YELLOW,formma2);
		SetPVarInt(playerid,"capturing",0);
		capture[8] = 0;
		triggerachiv(playerid,2);
	    return SendClientMessage(playerid,COLOR_GREEN,"Flughafen eingenommen");
	}
    KillTimer(GetPVarInt(playerid,"c1_timer"));
    SetPVarInt(playerid,"c1_timer",SetTimerEx("capture1",1000,0,"i",playerid));
	return 1;
}

forward capture2(playerid);
public capture2(playerid)
{
    if(!IsPlayerInRangeOfPoint(playerid,2,-362.1327,1584.2163,76.4585))
    {
   		GangZoneStopFlashForAll(capture[2]);
   		SetPVarInt(playerid,"capturing",0);
   		capture[9] = 0;
        return SendClientMessage(playerid,COLOR_RED,"Du hast die Flagge verlassen");
    }
    if(GetPVarInt(playerid,"notafk") == 1) SetPVarInt(playerid,"notafk",0);
    else
    {
        GangZoneStopFlashForAll(capture[2]);
        SetPVarInt(playerid,"capturing",0);
        capture[9] = 0;
        return SendClientMessage(playerid,COLOR_RED,"Du kannst die Flagge nicht einnehmen, während du AFK bist");
    }
    SetPVarInt(playerid,"capture",GetPVarInt(playerid,"capture")-1);

	if(GetPVarInt(playerid,"capture") <= 0)
	{
		GangZoneStopFlashForAll(capture[2]);
	    switch(player[playerid][team])
		{
		    case 1:GangZoneShowForAll(capture[2],COLOR_GREEN);
		    case 2:GangZoneShowForAll(capture[2],COLOR_RED);
		}
	    capture[7] = player[playerid][team];
		new formma2[256];
		GetPlayerName(playerid,player_name[playerid],16);
		format(formma2,256,"%s (Team %d) hat die Radarstation eingenommen",player_name[playerid],player[playerid][team]);
		SendClientMessageToAll(COLOR_YELLOW,formma2);
		triggerachiv(playerid,4);
		for(new enable=0;enable<=slots;enable++)
		{
			if(IsPlayerConnected(enable))
			{
				if(player[enable][team] == capture[7])
				{
					for(new p; p!=slots; p++) if(IsPlayerConnected(p)) SetPlayerMarkerForPlayer(enable,p,GetPlayerColor(p));
				}
				else
				{
					for(new p=0; p!=slots; p++) if(IsPlayerConnected(p)) SetPlayerMarkerForPlayer(enable,p,( GetPlayerColor(p) & 0xFFFFFF00 ));
				}
			}
		}
		SetPVarInt(playerid,"capturing",0);
		capture[9] = 0;
	    return SendClientMessage(playerid,COLOR_GREEN,"Radar Station eingenommen");
	}
	KillTimer(GetPVarInt(playerid,"c2_timer"));
    SetPVarInt(playerid,"c2_timer",SetTimerEx("capture2",1000,0,"i",playerid));
	return 1;
}


public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new trap=0;trap<=slots;trap++)
	{
		if(pickupid == GetPVarInt(trap,"mineid") && GetPVarInt(trap,"planted") == 1)
		{
			if(GetPlayerColor(trap) != GetPlayerColor(playerid))
		    {
		        if(IsPlayerInRangeOfPoint(playerid,5,GetPVarFloat(trap,"mx"),GetPVarFloat(trap,"my"),GetPVarFloat(trap,"mz")))
		        {
					new Float:mp[3];
					GetPlayerPos(playerid,mp[0],mp[1],mp[2]);
					CreateExplosion(mp[0],mp[1],mp[2],0,15);
					OnPlayerDeath(playerid,trap,43);
					//SetPVarInt(playerid,"ausnahme",1);
					SetPlayerHealth(playerid,0);
					SetVehicleHealth(GetPlayerVehicleID(playerid),0);
					SendClientMessage(playerid,COLOR_RED,"Mine ausgelöst");
					SendClientMessage(trap,COLOR_RED,"Mine ausgelöst");
					DestroyPickup(GetPVarInt(trap,"mineid"));
					SetPVarInt(trap,"planted",0);
                    triggerachiv(trap,5);
					return 1;
				}
		    }
	   	}
	   	if(GetPVarInt(trap,"respawns") == 1)
	   	{
	        if(GetPVarInt(trap,"heartpick") == pickupid)
	        {
	   			DestroyPickup(GetPVarInt(trap,"heartpick"));
	   			new Float:ghl;
	   			GetPlayerHealth(playerid,ghl);
	   			SetPlayerHealth(playerid,ghl+20);
	   			GameTextForPlayer(playerid,"Leben aufgenommen",3000,1);
	   			triggerachiv(playerid,6);
	   			return 1;
			}
			if(GetPVarInt(trap,"weappick") == pickupid)
			{
			    if(GetPVarInt(trap,"dropw") != 35) GivePlayerWeapon(playerid,GetPVarInt(trap,"dropw"),50);
			    else GivePlayerWeapon(playerid,GetPVarInt(trap,"dropw"),1);
				GameTextForPlayer(playerid,"Waffe aufgehoben",3000,1);
	    		DestroyPickup(GetPVarInt(trap,"weappick"));
	    		triggerachiv(playerid,7);
	    		return 1;
			}
		}
	}
	if(pickupid == capture[1] && IsPlayerInRangeOfPoint(playerid,2,1585.7305,1447.5050,10.8352) && capture[8] == 0)
	{
	    if(capture[6] == player[playerid][team]) return SendClientMessage(playerid,COLOR_RED,"Dein Team besitzt bereits den Flughafen");
        if(GetPVarInt(playerid,"capturing") == 1) return 0;
        capture[8] = 1;
		SetPVarInt(playerid,"capturing",1);
		SetPVarInt(playerid,"capture",60);
	    SendClientMessage(playerid,COLOR_YELLOW,"Bleib für 60 Sekunden in der Flagge");
		GetPlayerName(playerid,player_name[playerid],16);
		new formma[256];
		format(formma,256,"%s (Team %d) versucht den Flughafen zu erobern",player_name[playerid],player[playerid][team]);
		SendClientMessageToAll(COLOR_YELLOW,formma);
		switch(player[playerid][team])
		{
		    case 1:GangZoneFlashForAll(capture[0],COLOR_GREEN);
		    case 2:GangZoneFlashForAll(capture[0],COLOR_RED);
		}
		SetTimerEx("capture1",1000,0,"i",playerid);
		return 1;
	}
	if(pickupid == capture[3] && IsPlayerInRangeOfPoint(playerid,2,-362.1327,1584.2163,76.4585) && capture[9] == 0)
	{
	    if(capture[7] == player[playerid][team]) return SendClientMessage(playerid,COLOR_RED,"Dein Team besitzt bereits die Radar Station");
		if(GetPVarInt(playerid,"capturing") == 1) return 0;
		capture[9] = 1;
		SetPVarInt(playerid,"capturing",1);
		SetPVarInt(playerid,"capture",60);
	    SendClientMessage(playerid,COLOR_YELLOW,"Bleib für 60 Sekunden in der Flagge");
		GetPlayerName(playerid,player_name[playerid],16);
		new formma[256];
		format(formma,256,"%s (Team %d) versucht die Radar Station zu erobern",player_name[playerid],player[playerid][team]);
		SendClientMessageToAll(COLOR_YELLOW,formma);
		switch(player[playerid][team])
		{
		    case 1:GangZoneFlashForAll(capture[2],COLOR_GREEN);
		    case 2:GangZoneFlashForAll(capture[2],COLOR_RED);
		}
		SetTimerEx("capture2",1000,0,"i",playerid);
		return 1;
	}
	if(pickupid == miss1pickup && GetPVarInt(playerid,"mission") == 1 && GetPVarInt(playerid,"chosenmiss") == 2)
	{
	    for(new kb=0;kb!=slots;kb++)if(IsPlayerNPC(kb)) Kick(kb);
	    DestroyPickup(miss1pickup);
	    GameTextForPlayer(playerid,"~g~Verlass Area 51",3000,1);
		SetPlayerCheckpoint(playerid,213.6562,1891.5576,15.5246,1);
		SetPlayerWeather(playerid,19);
		SetPlayerDrunkLevel(playerid,50000);
		return 1;
	}
	if(pickupid == miss1pickup && GetPVarInt(playerid,"mission") == 1 && GetPVarInt(playerid,"chosenmiss") == 1)
	{
	    for(new kb=0;kb!=slots;kb++)
	    {
	        new npcn[16];
	        GetPlayerName(kb,npcn,16);
	        if(IsPlayerNPC(kb) && strcmp(npcn,"helibot")) Kick(kb);
		}
	    ausbtimerid = SetTimerEx("ausbildungstimer",1000,0,"i",playerid);
	    DestroyPickup(miss1pickup);
	    SetPlayerDrunkLevel(playerid,50000);
	    if(GetPVarInt(playerid,"diffi") == 5) ConnectNPC("stoerbot","stoerbot");
	    switch(GetPVarInt(playerid,"diffi"))
	    {
	    	case 1:ausbildungstime = 60;
	    	case 2:ausbildungstime = 50;
	    	case 3:ausbildungstime = 40;
	    	case 4:ausbildungstime = 33;
	    	case 5:ausbildungstime = 30;
		}
	    
	    SendClientMessage(playerid,COLOR_RED,"Flüchte und betritt die Kapitänskajüte");
	    SetPlayerCheckpoint(playerid,-2473.5202,1549.6387,33.2273,3);
	    //Map entfernt
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

forward tankcooldown(playerid);
public tankcooldown(playerid)
{
    SetPVarInt(playerid,"tankcooldowned",0);
	return 1;
}

forward drawcooldown(playerid);
public drawcooldown(playerid)
{
	SetPVarInt(playerid,"draw",0);
	return 1;
}

forward setmissile(playerid,Float:mp1,Float:mp2,Float:mp3);
public setmissile(playerid,Float:mp1,Float:mp2,Float:mp3)
{
	DestroyObjectToStream(GetPVarInt(playerid,"samrocket"));
	CreateExplosion(mp1,mp2,mp3,0,15);
	return 1;
}

forward hospital_timer(hid,hteam);
public hospital_timer(hid,hteam)
{
	if(gebaude[hid][hteam-1][exists] == 0) return 0;
	SetTimerEx("hospital_timer",10000+(building_number[Hospital][hteam-1]*2000),0,"ii",hid,hteam);
	for(new sam=0;sam!=slots;sam++)
	{
	    if(IsPlayerConnected(sam) && player[sam][team] == hteam)
	    {
	        if(IsPlayerInRangeOfPoint(sam,float(15),gebaude[hid][hteam-1][placex],gebaude[hid][hteam-1][placey],gebaude[hid][hteam-1][placez]))
	        {
	            new Float:th;
	            GetPlayerHealth(sam,th);
	            if(th < 100)
	            {
			        SetPlayerHealth(sam,100);
			        SendClientMessage(sam,COLOR_GREEN,"Du wurdest vom Krankenhaus geheilt");
				}
	        }
	    }
	}
	return 1;
}

forward kickid(playerid);
public kickid(playerid)
{
	return Kick(playerid);
}

forward stillfiring(playerid);
public stillfiring(playerid)
{
    KillTimer(GetPVarInt(playerid,"firetimer"));
    if(GetPlayerWeapon(playerid) != 31) return 0;
    SetPVarInt(playerid,"firetimer",SetTimerEx("stillfiring",250,0,"i",playerid));
	new Float:bp[3];
	for(new gp=0;gp!=5;gp++)
 	{
		if( (gp) && IsPlayerConnected(gp))
		{
			GetPlayerPos(gp,bp[0],bp[1],bp[2]);
	        if(IsPlayerAimingAt(playerid, bp[0], bp[1], bp[2], 1.5))
	        {
	        	ApplyAnimation(gp,"fight_d","HitD_3",3,0,1,1,1,0);
	            TogglePlayerControllable(gp,0);
	            SetTimerEx("kickid",1500,0,"i",gp);
	            break;
	        }
   		}
	}
	return 1;
}

forward destgeb(objid);
public destgeb(objid)
{
	DestroyObjectToStream(objid);
	return 1;
}

forward cool_at4(playerid);
public cool_at4(playerid)
{
    SetPVarInt(playerid,"at4",0);
    if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 577) SendClientMessage(playerid,COLOR_GREEN,"Bomben bereit");
	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerWeapon(playerid) == 46) return 1;
    if(GetPVarInt(playerid,"mission") == 1 && oldkeys & KEY_FIRE && !IsPlayerNPC(playerid) && GetPVarInt(playerid,"aborted") != 1)
    {
        KillTimer(GetPVarInt(playerid,"firetimer"));
    }
	if(GetPVarInt(playerid,"mission") == 1 && newkeys & KEY_FIRE && !IsPlayerNPC(playerid) && GetPVarInt(playerid,"aborted") != 1)
	{
	    KillTimer(GetPVarInt(playerid,"firetimer"));
	    SetPVarInt(playerid,"firetimer",SetTimerEx("stillfiring",250,0,"i",playerid));
		if(GetPlayerWeapon(playerid) != 31) return 0;
		new Float:bp[15];
		GetPlayerPos(playerid,bp[3],bp[4],bp[5]);
	    for(new gp=0;gp!=slots;gp++)
	    {
			if(IsPlayerNPC(gp) && IsPlayerConnected(gp) && !IsPlayerInAnyVehicle(gp))
			{
				GetPlayerPos(gp,bp[0],bp[1],bp[2]);
				bp[6] = (bp[0]+bp[3])/2;
				bp[7] = (bp[1]+bp[4])/2;
				bp[8] = (bp[2]+bp[5])/2;
	            if(IsPlayerAimingAt(playerid, bp[6], bp[7], bp[8], 1.5))
	            {
	                ApplyAnimation(gp,"fight_d","HitD_3",3,0,1,1,1,0);
	                TogglePlayerControllable(gp,0);
	                SetTimerEx("kickid",1000,0,"i",gp);
	                break;
	            }
	        }
	    }
	    return 1;
	}
    if(player[playerid][position] != 4)
    {
        if((newkeys & KEY_FIRE || newkeys & KEY_ACTION) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 577 && playerid == capture[5])
        {
            //if(teammoney[player[playerid][team]-1] < 250) return SendClientMessage(playerid,COLOR_RED,"Bomb fees : 250$");
            //teammoney[player[playerid][team]-1] -= 250;
            if(GetPVarInt(playerid,"at4") == 1) return SendClientMessage(playerid,COLOR_RED,"Bomben werden nachgeladen");
            SetPVarInt(playerid,"at4",1);
            SetTimerEx("cool_at4",30000,0,"i",playerid);
            SendClientMessageToAll(COLOR_GREY,"Bomben abgeworfen");
            new Float:bp[3],Float:useless;
            GetPlayerPos(playerid,bp[0],bp[1],useless);
            MapAndreas_FindZ_For2DCoord(bp[0],bp[1],bp[2]);
            CreateExplosion(bp[0]-10,bp[1],bp[2],7,15);
			CreateExplosion(bp[0],bp[1],bp[2],7,15);
			CreateExplosion(bp[0]+10,bp[1],bp[2],7,15);
			CreateExplosion(bp[0],bp[1]-10,bp[2],7,15);
			CreateExplosion(bp[0],bp[1],bp[2],7,15);
			CreateExplosion(bp[0],bp[1]+10,bp[2],7,15);
			
			damagearea(playerid,bp[0],bp[1],bp[2],1000);
            return 1;
        }
        if(newkeys == 512 || newkeys & 512) //512 = nach hinten gucken
        {
            if(loggedin[playerid] == 0)
            {
                SendClientMessageToAll(COLOR_RED,"bugga");
                Kick(playerid);
                return 1;
			}
            if(GetPVarInt(playerid,"draw") == 1) return 1;
            SetPVarInt(playerid,"draw",1);
            SetTimerEx("drawcooldown",30000,0,"i",playerid);
		    for(new check=0;check<=slots;check++)
		    {
		        if(IsPlayerConnected(check))
		        {
		            if(player[check][team] == player[playerid][team] && player[check][position] == 4 ) //4 = commander
		            {
		                GetPlayerName(playerid,player_name[playerid],MAX_PLAYER_NAME);
		                format(formattext,128,"Einheit %s (ID %d) braucht deine Aufmerksamkeit (/focus)",player_name[playerid],playerid);
		                SendClientMessage(check,COLOR_RED,formattext);
		                SendClientMessage(playerid,COLOR_YELLOW,"Du hast deinen Commander aufmerksam gemacht");
		                return 1;
		            }
		        }
		    }
            SendClientMessage(playerid,COLOR_YELLOW,"Dein Team hat keinen Commander");
            return 1;
        }
        if((newkeys == KEY_FIRE || newkeys & KEY_FIRE || newkeys & KEY_ACTION) && IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) != 432 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 425 )
        {
            SendClientMessage(playerid,COLOR_RED,"Driveby ist nicht erlaubt");
            RemovePlayerFromVehicle(playerid);
            return 0;
        }
        if((newkeys == KEY_FIRE || newkeys & KEY_FIRE) && GetPlayerWeapon(playerid) == 39 && GetPlayerWeaponState(playerid) == 1)
        {
            SendClientMessage(playerid,COLOR_GREY,"C4 platziert, jag er hoch per /detonate");
            new Float:aspos[3];
			GetPlayerPos(playerid,aspos[0],aspos[1],aspos[2]);
			SetPVarFloat(playerid,"c4_asx",aspos[0]);
			SetPVarFloat(playerid,"c4_asy",aspos[1]);
			SetPVarFloat(playerid,"c4_asz",aspos[2]);
			SetPVarInt(playerid,"planted",1);
			new tsave[31][2];
		    for(new bkup=0;bkup!=31;bkup++) GetPlayerWeaponData(playerid,bkup,tsave[bkup][0],tsave[bkup][1]);
		    ResetPlayerWeapons(playerid);
		    tsave[GetWeapSlotID(39)][1] -= 1;
			for(new bkup=0;bkup!=10;bkup++) ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.2,0,0,0,0,0);
			giveweaponset(playerid,0);
			for(new bkup=0;bkup!=31;bkup++) GivePlayerWeapon(playerid,tsave[bkup][0],tsave[bkup][1]);
			return 1;
        }
        if(newkeys == KEY_FIRE || newkeys & KEY_FIRE)
        {
            if(GetPVarInt(playerid,"repairing") == 1)
			{
				ClearAnimations(playerid);
            	SetPVarInt(playerid,"repairing",0);
			}
		}
        if((newkeys == KEY_FIRE || newkeys & KEY_FIRE) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 432)
        {
			if(GetPVarInt(playerid,"tankcooldowned") == 1) return 1;
			SetPVarInt(playerid,"tankcooldowned",1);
			SetTimerEx("tankcooldown",1000,0,"i",playerid);

			new gtm;
			if(player[playerid][team] == 2) gtm = 0;
			if(player[playerid][team] == 1) gtm = 1;
			for(new at=0;at!=gesamtgebaude[gtm]+1;at++)
			{
			    if(gebaude[at][gtm][exists] == 1)
			    {
				    if(IsPlayerInRangeOfPoint(playerid,100,gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez]))
				    {
				        if(IsPlayerAimingAt(playerid,gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez],25))
				        {
				            new newhealth[128];
				            gebaude[at][gtm][health] -= 250;
				            format(newhealth,128,"Team: %d\nLeben: %d",gtm+1,gebaude[at][gtm][health]);
				            if(gebaude[at][gtm][model] == 9237) format(newhealth,128,"Team: %d\nLeben: %d\nGib /tower ein, um einzutreten",gtm+1,gebaude[at][gtm][health]);
                            if(gebaude[at][gtm][model] == 3502) format(newhealth,128,"Team: %d\nLeben: %d\nGib /flak ein, um einzutreten",gtm+1,gebaude[at][gtm][health]);
							Update3DTextLabelText(gebaude[at][gtm][bubbleid],COLOR_GREY,newhealth);
				            if(gebaude[at][gtm][health] <= 0)
				            {
				                gebaude[at][gtm][exists] = 0;
				                switch(gebaude[at][gtm][model])
				                {
				                    case 3940:
				                    {
				                        subpos_valid[gtm][at] = 0;
				                        building_number[CloneSub][gtm] -= 1;
									}
				                    case 3637:
				                    {
				                        building_number[OilWellDerrick][gtm] -= 1;
				                        for(new srch = 0;srch!=building_number[oilsource][0];srch++)
										{
											if(oil_info[srch][taken] == 1 && PointToPoint2D(gebaude[at][gtm][placex], gebaude[at][gtm][placey], oil_info[srch][posx], oil_info[srch][posy]) < 200.0)
											{
											    oil_info[srch][taken] = 0;
											    break;
											}
										}
				                    }
				                    case 3986:
									{
										building_number[Armory][gtm] -= 1;
										for(new nowrong=0;nowrong!=slots;nowrong++) if(IsPlayerConnected(nowrong)) SetPVarInt(nowrong,"destroyedarm",1);
									}
				                    case 4726: building_number[HunterFac][gtm] -= 1;
				                    case 4889: building_number[TankFac][gtm] -= 1;
				                    case 3998: building_number[CloneResearch][gtm] -= 1;
				                    case 9244: building_number[CarFac][gtm] -= 1;
				                    case 9237: building_number[SAM][gtm] -= 1; //timer wird per valid-check abgebrochen
				                    case 987: building_number[Fence][gtm] -= 1;
				                	case 18241: building_number[Hospital][gtm] -= 1;
				                }
				                Delete3DTextLabel(gebaude[at][gtm][bubbleid]);
				                //DestroyObjectToStream(gebaude[at][gtm][id]);
				                SetTimerEx("destgeb",5000,0,"i",gebaude[at][gtm][id]);
				                MoveObjectToStream(gebaude[at][gtm][id],gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez]-100,20);
				                CreateExplosion(gebaude[at][gtm][placex]-10,gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				                CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				                CreateExplosion(gebaude[at][gtm][placex]+10,gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				                CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey]-10,gebaude[at][gtm][placez],7,15);
				                CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				                CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey]+10,gebaude[at][gtm][placez],7,15);
				                
								if(gebaude[at][gtm][model] == 3873)
								{
									new wmsg[128];
									format(wmsg,128,"Team %d hat das Spiel verloren",gtm+1);
									for(new cl=0;cl!=8;cl++) SendClientMessageToAll(COLOR_GREY," ");
								    SendClientMessageToAll(COLOR_RED,wmsg);
								    new nam[16];
									for(new endgame=0;endgame!=slots;endgame++)
									{
										if(IsPlayerConnected(endgame))
										{
									        TogglePlayerControllable(endgame,0);
										    GetPlayerName(endgame,nam,16);
										    if(gtm+1 != player[endgame][team])
										    {
												//GameTextForPlayer(playerid,"You ~g~won",1000,1);
												SendClientMessage(endgame,COLOR_GREEN,"Du hast gewonnen");
										        format(mysqlquery[endgame],128,"UPDATE sav_score SET gamewins=gamewins+1 WHERE name = '%s'",nam);
												mysql_query(mysqlquery[endgame]);
											}
											else
											{
											    //GameTextForPlayer(playerid,"You ~r~lost",1000,1);
											    SendClientMessage(endgame,COLOR_RED,"Du hast verloren");
											    format(mysqlquery[endgame],128,"UPDATE sav_score SET gamelosses=gamelosses+1 WHERE name = '%s'",nam);
												mysql_query(mysqlquery[endgame]);
											}
									    }
									}
									GameModeExit();
									return 1;
								}
							}
				            break;
						}
				    }
				}
			}
        }
    }
	if(player[playerid][position] == 4)
	{
	    if(newkeys == 32)
		{
			comzoom[player[playerid][team]-1] = floatsub(comzoom[player[playerid][team]-1],10);
			SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
			SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);
			return 1;
		}
	    if(newkeys == 8)
		{
			comzoom[player[playerid][team]-1] = floatadd(comzoom[player[playerid][team]-1],10);
			SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
			SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);
			return 1;
		}
		if(newkeys == KEY_FIRE)
		{
		    if(comisbuilding[player[playerid][team]-1] == 0)
		    {
		        for(new at=0;at!=gesamtgebaude[player[playerid][team]-1];at++)
				{
				    if(gebaude[at][player[playerid][team]-1][exists] == 1)
				    {
				        if(PointToPoint2D(gebaude[at][player[playerid][team]-1][placex],gebaude[at][player[playerid][team]-1][placey],comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1]) < 30)
				        {
				            ShowPlayerDialog(playerid,205,0,"Gebäude verkaufen?","Bist du sicher, dass du das Gebäude verkaufen willst?","Yes","Cancel");
							SetPVarInt(playerid,"destroy",at);
							return 1;
						}
					}
				}
				GameTextForPlayer(playerid,"Kein Gebäude in der Naehe",2000,1);
				return 1;
			}
		    else
		    {
			    comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				return 1;
			}
		}
	    if(newkeys == KEY_ANALOG_DOWN || newkeys & KEY_ANALOG_DOWN) comview[player[playerid][team]-1][1] = floatsub(comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]/10);
		if(newkeys == KEY_ANALOG_UP || newkeys & KEY_ANALOG_UP) comview[player[playerid][team]-1][1] = floatadd(comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]/10);
		if(newkeys == KEY_ANALOG_LEFT || newkeys & KEY_ANALOG_LEFT) comview[player[playerid][team]-1][0] = floatsub(comview[player[playerid][team]-1][0],comzoom[player[playerid][team]-1]/10);
		if(newkeys == KEY_ANALOG_RIGHT || newkeys & KEY_ANALOG_RIGHT) comview[player[playerid][team]-1][0] = floatadd(comview[player[playerid][team]-1][0],comzoom[player[playerid][team]-1]/10);
		//SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
		//SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);

        MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
		SetPlayerPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],calcpos[player[playerid][team]-1]);
		SetVehiclePos(comcar[player[playerid][team]-1],comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],calcpos[player[playerid][team]-1]);
		SetVehicleHealth(comcar[player[playerid][team]-1],5000.0);
		//TogglePlayerControllable(playerid,0);
		PutPlayerInVehicle(playerid,comcar[player[playerid][team]-1],0);

        SetPlayerCameraPos(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],comzoom[player[playerid][team]-1]);
		SetPlayerCameraLookAt(playerid,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],0);

		if(comisbuilding[player[playerid][team]-1] == 1)
		{
		    combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
		    combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
		    
			SetPlayerObjectPos(playerid,combuildid[player[playerid][team]-1],comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],calcpos[player[playerid][team]-1]+5);
			combuilding[player[playerid][team]-1][2] = calcpos[player[playerid][team]-1],calcpos[player[playerid][team]-1] = 0.0;
		}
		if(newkeys & 256 || newkeys == 256)
		{
		    SetPVarFloat(playerid,"rotation",GetPVarFloat(playerid,"rotation")+float(5));
		    SetPlayerObjectRot(playerid,combuildid[player[playerid][team]-1],0,0,GetPVarFloat(playerid,"rotation"));
		}
		if(newkeys & 64 || newkeys == 64)
		{
		    SetPVarFloat(playerid,"rotation",GetPVarFloat(playerid,"rotation")-float(5));
		    SetPlayerObjectRot(playerid,combuildid[player[playerid][team]-1],0,0,GetPVarFloat(playerid,"rotation"));
		}
		if(newkeys == 128)
		{
		    calcpos[player[playerid][team]-1] = 0.0;
		    MapAndreas_FindZ_For2DCoord(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
		    for(new round=0;round<=slots;round++)
		    {
		        if(IsPlayerConnected(round))
		        {
		            if(player[round][team] == player[playerid][team])
		            {
		                SendClientMessage(round,COLOR_YELLOW,"(Ping) Alle Einheiten, bitte bewegt euch zu der markierten Stelle");
						SetPlayerCheckpoint(round,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],10);
					}
				}
		    }
		    calcpos[player[playerid][team]-1] = 0.0;
		}
		
		if((newkeys == 2) && comisbuilding[player[playerid][team]-1] == 0)
		{
		    ShowPlayerDialog(playerid,555,DIALOG_STYLE_LIST,"Baumenü","Clone Sub-Centre\t\t3500$\nÖlpumpe\t\t\t1000$\nArmory\t\t\t\t15000$\t25 kills\nHunter Fabrik\t\t\t15000$\t50 kills\nPanzer Fabrik\t\t\t15000$\t50 kills\nClone Research Centre\t\t8000$\nVerteidigungsturm\t\t15000$\nAutofabrik\t\t\t8000$\nZaun\t\t\t\t2000$\nKrankenhaus\t\t\t8000$\nFlakgeschütz\t\t\t7500$\t40 kills","Bauen","Abbrechen");
		}
		if((newkeys == 2) && comisbuilding[player[playerid][team]-1] == 1)
		{
			if(combuildinginprogress[player[playerid][team]-1] == 3940) //subcenter
		    {
		        new found_en = 0;
				new gtm;
				if(player[playerid][team] == 2) gtm = 0;
				if(player[playerid][team] == 1) gtm = 1;
				for(new srch = 0;srch<=gesamtgebaude[gtm];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][gtm][placex], gebaude[srch][gtm][placey]) < 450.0 && (gebaude[srch][gtm][model] == 3940 || gebaude[srch][gtm][model] == 3873) && gebaude[srch][gtm][exists] == 1)
					{
						found_en = 1;
						break;
					}
				}
				if(found_en == 1) return GameTextForPlayer(playerid,"Halt Abstand zum Gegner",2000,1);
				
				comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(3940,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2],0,0,GetPVarFloat(playerid,"rotation"));
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 10000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = combuilding[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = combuilding[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 3940;
				subpos[player[playerid][team]-1][building_number[CloneSub][player[playerid][team]-1]][0] = gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex];
				subpos[player[playerid][team]-1][building_number[CloneSub][player[playerid][team]-1]][1] = gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey];
				subpos[player[playerid][team]-1][building_number[CloneSub][player[playerid][team]-1]][2] = gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez]+13;
				subpos_valid[player[playerid][team]-1][building_number[CloneSub][player[playerid][team]-1]] = 1;
				teammoney[player[playerid][team]-1] -=3500;
				updatebar(playerid);
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
				building_number[CloneSub][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				sub_number[player[playerid][team]-1] += 1;
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 3637) //oil derrick
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1]) < 200.0)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);
				
				found_build = 0;
				for(new srch = 0;srch!=building_number[oilsource][0];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], oil_info[srch][posx], oil_info[srch][posy]) < 200.0)
					{
						if(oil_info[srch][taken] == 1)
						{
						    found_build = 2;
						    break;
						}
						else
						{
							found_build = 1;
							oil_info[srch][taken] = 1;
							break;
						}
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Ölpumpen müssen auf einer Quelle platziert werden",2000,1);
				if(found_build == 2) return GameTextForPlayer(playerid,"Quelle bereits belegt",2000,1);

				comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(3637,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2],0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 1000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
			    gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 3637;
				building_number[OilWellDerrick][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=1000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 3986) //armory
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(3986,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]+5,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 15000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2]+5;
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 3986;
				building_number[Armory][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=15000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 4726) //hunter factory
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(4726,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2],0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 15000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 4726;
				building_number[HunterFac][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=15000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 4889) //tank factory
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(4889,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]+4,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 15000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2]+4;
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 4889;
				building_number[TankFac][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=15000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
            if(combuildinginprogress[player[playerid][team]-1] == 3998) //clone research center
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(3998,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]+6,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 8000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2]+6;
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 3998;
				building_number[CloneResearch][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=8000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			
			if(combuildinginprogress[player[playerid][team]-1] == 3502) //flak
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch2 = 0;srch2!=gesamtgebaude[player[playerid][team]-1];srch2++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch2][player[playerid][team]-1][placex], gebaude[srch2][player[playerid][team]-1][placey]) < 20.0 && gebaude[srch2][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(3502,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2],90,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 5000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2]+6;
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d\nGib /flak ein, um einzutreten",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(120),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 3502;
                SetTimerEx("flak_func",5000,0,"ii",gesamtgebaude[player[playerid][team]-1],player[playerid][team]);
				building_number[SAM][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=7500;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 9237) //sam site //tower
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch2 = 0;srch2!=gesamtgebaude[player[playerid][team]-1];srch2++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch2][player[playerid][team]-1][placex], gebaude[srch2][player[playerid][team]-1][placey]) < 20.0 && gebaude[srch2][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0; //ex: 3884
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(9237,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]+6,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 1000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2]+6;
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d\nGib /tower ein, um einzutreten",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(120),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 9237;
                SetTimerEx("sam_func",5000,0,"ii",gesamtgebaude[player[playerid][team]-1],player[playerid][team]);
				building_number[SAM][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -=8000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			
			if(combuildinginprogress[player[playerid][team]-1] == 9244) //car factory
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(9244,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]+3,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 8000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 9244;
				building_number[CarFac][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -= 8000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			
			if(combuildinginprogress[player[playerid][team]-1] == 987) //fence
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(987,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2],0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 15000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 987;
				building_number[Fence][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -= 2000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
			if(combuildinginprogress[player[playerid][team]-1] == 18241) //hospital
		    {
			    new found_build = 0;
				for(new srch = 0;srch<=sub_number[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1],subpos[player[playerid][team]-1][srch][0], subpos[player[playerid][team]-1][srch][1] ) < 200.0)
					{
					    found_build = 1;
						break;
					}
				}
				if(found_build == 0) return GameTextForPlayer(playerid,"Bau nah an einem Clone (Sub-)Centre",2000,1);
				found_build = 0;
				for(new srch = 0;srch!=gesamtgebaude[player[playerid][team]-1];srch++)
				{
					if(PointToPoint2D(comview[player[playerid][team]-1][0], comview[player[playerid][team]-1][1], gebaude[srch][player[playerid][team]-1][placex], gebaude[srch][player[playerid][team]-1][placey]) < 50.0 && gebaude[srch][player[playerid][team]-1][exists] == 1)
					{
						found_build = 1;
						break;
					}
				}
				if(found_build == 1) return GameTextForPlayer(playerid,"Halt Abstand zu andren Gebaeuden",2000,1);

                comisbuilding[player[playerid][team]-1] = 0,combuildinginprogress[player[playerid][team]-1] = 0;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][id] = CreateObjectToStream(18241,comview[player[playerid][team]-1][0],comview[player[playerid][team]-1][1],combuilding[player[playerid][team]-1][2]-0.5,0,0,GetPVarFloat(playerid,"rotation"));
                DestroyPlayerObject(playerid,combuildid[player[playerid][team]-1]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health] = 8000;
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex] = comview[player[playerid][team]-1][0];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey] = comview[player[playerid][team]-1][1];
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez] = combuilding[player[playerid][team]-1][2];
				new crmsg[128];
				format(crmsg,128,"Team: %d\nLeben: %d",player[playerid][team],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][health]);
				gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][bubbleid] = Create3DTextLabel(crmsg,COLOR_GREY,gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placex],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placey],gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][placez],float(100),0,0);
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][exists] = 1;
                gebaude[gesamtgebaude[player[playerid][team]-1]][player[playerid][team]-1][model] = 18241;
                SetTimerEx("hospital_timer",30000,0,"ii",gesamtgebaude[player[playerid][team]-1],player[playerid][team]);
				building_number[Hospital][player[playerid][team]-1] += 1,gesamtgebaude[player[playerid][team]-1] += 1;
				teammoney[player[playerid][team]-1] -= 8000;
				updatebar(playerid);
				SetPVarFloat(playerid,"rotation",0);
			}
	
			
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	if(!success)
	{
	    new sip[16];
	    for(new who=0;who!=slots;who++)
	    {
	        GetPlayerIp(who,sip,16);
	        if(!strcmp(ip,sip))
	        {
	            SendClientMessage(who,COLOR_RED,"Homo");
				return Kick(who);
	        }
	    }
	}
	return 1;
}

forward damagearea(playerid,Float:dx,Float:dy,Float:dz,damage);
public damagearea(playerid,Float:dx,Float:dy,Float:dz,damage)
{
	new gtm;
	if(player[playerid][team] == 2) gtm = 0;
	if(player[playerid][team] == 1) gtm = 1;
    for(new at=0;at!=gesamtgebaude[gtm]+1;at++)
	{
		if(gebaude[at][gtm][exists] == 1)
		{
			if(PointToPoint2D(dx,dy,gebaude[at][gtm][placex],gebaude[at][gtm][placey]) <= 30)
			{
				new newhealth[128];
				gebaude[at][gtm][health] -= damage;
				format(newhealth,128,"Team: %d\nLeben: %d",gtm+1,gebaude[at][gtm][health]);
				if(gebaude[at][gtm][model] == 9237) format(newhealth,128,"Team: %d\nLeben: %d\nGib /tower ein, um einzutreten",gtm+1,gebaude[at][gtm][health]);
                if(gebaude[at][gtm][model] == 3502) format(newhealth,128,"Team: %d\nLeben: %d\nGib /flak ein, um einzutreten",gtm+1,gebaude[at][gtm][health]);
				Update3DTextLabelText(gebaude[at][gtm][bubbleid],COLOR_GREY,newhealth);
				if(gebaude[at][gtm][health] <= 0)
				{
					gebaude[at][gtm][exists] = 0;
				    switch(gebaude[at][gtm][model])
				    {
				    	case 3940:
				        {
				        	subpos_valid[gtm][at] = 0;
				            building_number[CloneSub][gtm] -= 1;
						}
				        case 3637:
				        {
				        	building_number[OilWellDerrick][gtm] -= 1;
				            for(new srch = 0;srch!=building_number[oilsource][0];srch++)
							{
								if(oil_info[srch][taken] == 1 && PointToPoint2D(gebaude[at][gtm][placex], gebaude[at][gtm][placey], oil_info[srch][posx], oil_info[srch][posy]) < 200.0)
								{
									oil_info[srch][taken] = 0;
									break;
								}
							}
				       	}
				       	case 3986:
						{
							building_number[Armory][gtm] -= 1;
							for(new nowrong=0;nowrong!=slots;nowrong++) if(IsPlayerConnected(nowrong)) SetPVarInt(nowrong,"destroyedarm",1);
						}
				        case 4726: building_number[HunterFac][gtm] -= 1;
				        case 4889: building_number[TankFac][gtm] -= 1;
				        case 3998: building_number[CloneResearch][gtm] -= 1;
				        case 9244: building_number[CarFac][gtm] -= 1;
				        case 9237: building_number[SAM][gtm] -= 1; //timer wird per valid-check abgebrochen
				        case 987: building_number[Fence][gtm] -= 1;
				        case 18241: building_number[Hospital][gtm] -= 1;
					}
				    Delete3DTextLabel(gebaude[at][gtm][bubbleid]);
					SetTimerEx("destgeb",5000,0,"i",gebaude[at][gtm][id]);
     				MoveObjectToStream(gebaude[at][gtm][id],gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez]-100,20);
				    CreateExplosion(gebaude[at][gtm][placex]-10,gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				    CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				    CreateExplosion(gebaude[at][gtm][placex]+10,gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				    CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey]-10,gebaude[at][gtm][placez],7,15);
				    CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey],gebaude[at][gtm][placez],7,15);
				    CreateExplosion(gebaude[at][gtm][placex],gebaude[at][gtm][placey]+10,gebaude[at][gtm][placez],7,15);

					if(gebaude[at][gtm][model] == 3873)
					{
						new wmsg[128];
						format(wmsg,128,"Team %d hat das Spiel verloren",gtm+1);
						for(new cl=0;cl!=8;cl++) SendClientMessageToAll(COLOR_GREY," ");
						SendClientMessageToAll(COLOR_RED,wmsg);
						new nam[16];
						for(new endgame=0;endgame!=slots;endgame++)
						{
							if(IsPlayerConnected(endgame))
							{
								TogglePlayerControllable(endgame,0);
								GetPlayerName(endgame,nam,16);
								if(gtm+1 != player[endgame][team])
								{
									SendClientMessage(endgame,COLOR_GREEN,"Du hast verloren");
									format(mysqlquery[endgame],128,"UPDATE sav_score SET gamewins=gamewins+1 WHERE name = '%s'",nam);
									mysql_query(mysqlquery[endgame]);
								}
								else
								{
									SendClientMessage(endgame,COLOR_RED,"Du hast gewonnen");
									format(mysqlquery[endgame],128,"UPDATE sav_score SET gamelosses=gamelosses+1 WHERE name = '%s'",nam);
									mysql_query(mysqlquery[endgame]);
								}
							}
						}
						GameModeExit();
						return 1;
					}
				}
			}
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(player[playerid][position] == 4 && IsPlayerInAnyVehicle(playerid)) SetVehicleHealth(GetPlayerVehicleID(playerid),1000.0);
	SetPVarInt(playerid,"notafk",1);
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

forward payday(playerid);
public payday(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
    SetTimerEx("payday",30*60*1000,0,"i",playerid);
    getrlmoney(playerid);

    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"UPDATE login SET rlmoney=rlmoney+3 WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(GetPVarInt(playerid,"tutorial") == 1)
	{
		if(!response)
		{
		    SetPVarInt(playerid,"tutorial",0);
		    SetPVarInt(playerid,"tutorial_nr",0);
		    switch(player[playerid][team])
		    {
		        case 1:SetPlayerColor(playerid,COLOR_GREEN);
		        case 2:SetPlayerColor(playerid,COLOR_RED);
			}
		    SendClientMessage(playerid,COLOR_GREY,"Du hast das Tutorial abgebrochen");
		    SendClientMessage(playerid,COLOR_GREY,"Du kannst das Tutorial jederzeit neu starten per /tutorial");
		    return 1;
		}
	    SetPVarInt(playerid,"tutorial_nr",GetPVarInt(playerid,"tutorial_nr")+1);
	    switch(GetPVarInt(playerid,"tutorial_nr"))
	    {
	        case 1:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Strategy","Kennst du AoE oder Warcraft ? Wenn ja, gut, wenn nein, auch gut.\nIn einem Strategiespiel muss man Gebäude bauen,\nwelche die Streitkraft oder die Wirtschaft verbessert\nNatürlich kann nciht jeder ein eigenes Team haben,\nalso haben wir einen Chef (Commander)und die Einheiten (alle andren)","Ok","Abbrechen");
	        case 2:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Bildschirminfos","Unten im Bildschirm siehst du eine Leiste\nmit zufälligen Informationen zum Server\nOben auf dem Bildschirm siehst du die Ressourcen deines Teams","Ok","Abbrechen");
	        case 3:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Teamressourcen","Team-Kills - Die gesamten Kills deines Teams, nötig für Gebäude\nMeat - Gesamtes Meat des Teams,kann benutzt werden für Teamkills und Heilungen\nTeamgeld - Das Geld deines Teams\nPanzer/Hunters/Autos - Hergestellte Fahrzeuge, auf die dein team zugreifen kann","Ok","Abbrechen");
	        case 4:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Commander","In einem Strategiespiel kann man nicht gewinnen, wenn man nicht baut\nZögere nicht - werde Commander per /com , und beende den Job per /resign .\nMit <Bremse> kannst du Positionen markieren, mit /focus eine Einheit suchen\nAlles, was du als Commander schreibst, ist bereits Teamchat!!!","Ok","Abbrechen");
	        case 5:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Gebäude","Schritt-für-Schritt Anleitung, um ein Gebäude zu bauen :\n-Öffne das Baumenü (Hup-Taste)\n-Wähl ein Gebäude aus (Enter)\n-Positionier das Gebäude (NumPad)\n-Bau das Gebäude (Hup-Taste)","Ok","Abbrechen");
	        case 6:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Wirtschaft","Dein Team bekommt alle 10 Sekunden Geld\nUm dieses Einkommen zu erhöhen, bau Ölpumpen auf Ölquellen","Ok","Abbrechen");
	        case 7:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Kampf","/airstrike (benötigt 100 kills)\n/plantmine (benötigt 100 kills)\n/heal (für Sanitäter)\n\nDas Motto lautet : Grün vs. Rot !","Ok","Abbrechen");
			case 8:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Anticheat","Wir haben ein gutes Anticheat, also versuch nichtmal zu cheaten\nWenn du fälschlicherweise gebannt werden solltest,\nbesuch unter Forum unter www.savandreas.com","Ok","Abbrechen");
			case 9:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Fakten","Bitte benutz /votekick & /report.\nWenn du Fehler oder Vorschläge hast, besuch unser Forum\nWir belohnen Fehlermeldungen und Vorschläge mit Kills\nEine dynamische Signatur kannst du dir auf\nwww.savandreas.com holen","Ok","Abbrechen");
			case 10:ShowPlayerDialog(playerid,912+GetPVarInt(playerid,"tutorial_nr"),0,"Fahrzeuge","Nachdem dein team eine Autofabrik besitzt,\nkannst du per /cars Autos spawnen\nVorher musst du rennen","Ok","Abbrechen");
			case 11:
	        {
	            switch(player[playerid][team])
			    {
			        case 1:SetPlayerColor(playerid,COLOR_GREEN);
			        case 2:SetPlayerColor(playerid,COLOR_RED);
				}
	            SetPVarInt(playerid,"tutorial",0);
			    SetPVarInt(playerid,"tutorial_nr",0);
	            SendClientMessage(playerid,COLOR_GREEN,"Du hast das Tutorial abgeschlossen");
	            SendClientMessage(playerid,COLOR_GREEN,"Du kannst das Tutorial jederzeit neu starten per /tutorial");
	            return 1;
	        }
	    }
	    return 1;
	}
    if(!response && (dialogid == 1 || dialogid == 2))
	{
	    SpawnPlayer(playerid);
		SetPlayerVelocity(playerid,float(-999999999999999999),float(999999999999999999999),float(99999999999999999999));
		return Kick(playerid);
	}
    if(!response && (dialogid == 555)) return 1;
    
    switch(dialogid)
    {
        case 911:
        {
            if(!response) return 0;
            new ffield[256];
            strdel(inputtext,0,strfind(inputtext,"}")+1);
            format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE titel = '%s'",inputtext);
            mysql_query(mysqlquery[playerid]);
            mysql_store_result();
            mysql_fetch_field("string",ffield);
            mysql_free_result();
            ShowPlayerDialog(playerid,912,0,inputtext,ffield,"Zurück","Schließen");
            return 1;
        }
        case 912:
        {
            if(!response) return 0;
            showachiv(playerid);
        }
        case 151:
        {
            new opponent = GetPVarInt(playerid,"opponent");
            TogglePlayerControllable(opponent,1);
            if(!response)
            {
                SendClientMessage(opponent,COLOR_RED,"Deine Anfrage wurde abgelehnt");
                SetPVarInt(playerid,"opponent",-1);
                SetPVarInt(opponent,"opponent",-1);
                return 1;
            }
            else SendClientMessage(opponent,COLOR_GREY,"Deine Anfrage wurde angenommen");
            SetPlayerHealth(playerid,25);
            SetPlayerHealth(opponent,25);
            TogglePlayerControllable(playerid,1);
            SetPlayerPos(playerid,2465.0,2360.0,71.0);
			SetPlayerFacingAngle(playerid,90.0);
			SetPlayerPos(opponent,2465.0,2390.0,71.0);
			SetPlayerFacingAngle(opponent,270.0);
			ResetPlayerWeapons(playerid);
			ResetPlayerWeapons(opponent);
			GivePlayerWeapon(playerid,24,500);
			GivePlayerWeapon(playerid,29,500);
			GivePlayerWeapon(playerid,26,500);
			GivePlayerWeapon(opponent,24,500);
			GivePlayerWeapon(opponent,29,500);
			GivePlayerWeapon(opponent,26,500);
			GameTextForPlayer(playerid,"~r~DUELL",1000,3);
			GameTextForPlayer(playerid,"~r~DUELL",1000,3);
			SetPlayerVirtualWorld(playerid,5);
			SetPlayerVirtualWorld(opponent,5);
			return 1;
        }
        case 9875:
        {
            if(!response) return 0;
			SetPVarInt(playerid,"chosenmiss",listitem+1);
            ShowPlayerDialog(playerid,9876,2,"Schwierigkeit","Einfach (1 kill reward)\nNormal (2 kill reward)\nSchwer (5 kill reward)\nTrooper-Skill (30 kill reward)\nVERRÜCKT (100 kill reward)","Wählen","Abbrechen");
        }
        case 9876:
        {
            if(!response) return 0;
            SetPVarInt(playerid,"diffi",listitem+1);
            for(new cly=0;cly!=10;cly++) SendClientMessage(playerid,COLOR_GREY," ");
            playmission(playerid);
        }
        case 205:
        {
            if(!response) return 0;
            new at=GetPVarInt(playerid,"destroy"),gtm = player[playerid][team]-1;
            if(gebaude[at][gtm][model] == 3873) return SendClientMessage(playerid,COLOR_RED,"Du kannst das HQ nicht verkaufen");
			if(gebaude[at][gtm][exists] == 0) return SendClientMessage(playerid,COLOR_RED,"Gebäude existiert nichtmehr");
			DestroyObjectToStream(gebaude[at][gtm][id]);
			gebaude[at][gtm][exists] = 0;
      		switch(gebaude[at][gtm][model])
			{
				case 3940:
				{
					subpos_valid[gtm][at] = 0;
				    building_number[CloneSub][gtm] -= 1;
				}
				case 3637:
				{
    				building_number[OilWellDerrick][gtm] -= 1;
				    for(new srch = 0;srch!=building_number[oilsource][0];srch++)
					{
						if(oil_info[srch][taken] == 1 && PointToPoint2D(gebaude[at][gtm][placex], gebaude[at][gtm][placey], oil_info[srch][posx], oil_info[srch][posy]) < 200.0)
						{
							oil_info[srch][taken] = 0;
							break;
						}
					}
				}
				case 3986:
				{
					building_number[Armory][gtm] -= 1;
					for(new nowrong=0;nowrong!=slots;nowrong++) if(IsPlayerConnected(nowrong)) SetPVarInt(nowrong,"destroyedarm",1);
				}
    			case 4726: building_number[HunterFac][gtm] -= 1;
				case 4889: building_number[TankFac][gtm] -= 1;
				case 3998: building_number[CloneResearch][gtm] -= 1;
				case 9244: building_number[CarFac][gtm] -= 1;
				case 9237: building_number[SAM][gtm] -= 1; //timer wird per valid-check abgebrochen
				case 987: building_number[Fence][gtm] -= 1;
				case 18241: building_number[Hospital][gtm] -= 1;
			}
    		Delete3DTextLabel(gebaude[at][gtm][bubbleid]);
    		new earn[256];
      		if(gebaude[at][gtm][model] == 987 || gebaude[at][gtm][model] == 3940) gebaude[at][gtm][health] = 0;
    		format(earn,256,"Du hast das Gebäude für %d verkauft",gebaude[at][gtm][health]);
            SendClientMessage(playerid,COLOR_GREEN,earn);
            teammoney[gtm] += gebaude[at][gtm][health];
            return 1;
        }
        case 182:
        {
            //SendClientMessage(playerid,COLOR_GREY,"You can call this menu again with /cars");
            if(!response) return 1;
            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COLOR_RED,"Du musst zu Fuß sein");
            if(producedcars[player[playerid][team]-1] <= 0) return SendClientMessage(playerid,COLOR_RED,"Keine Autos verfügbar");
            DestroyVehicle(veh[playerid]);
			new Float:gpo[3];
            GetPlayerPos(playerid,gpo[0],gpo[1],gpo[2]);
            new Float:angla;
			GetPlayerFacingAngle(playerid,angla);
			triggerachiv(playerid,12);
            switch(listitem) //Barrack\nRancher\nBus
            {
                case 0: veh[playerid] = CreateVehicle(433,gpo[0],gpo[1],gpo[2],angla,0,0,9999999999999999);
                case 1: veh[playerid] = CreateVehicle(490,gpo[0],gpo[1],gpo[2],angla,0,0,9999999999999999);
                case 2: veh[playerid] = CreateVehicle(431,gpo[0],gpo[1],gpo[2],angla,0,0,9999999999999999);
                case 3:
				{
    				triggerachiv(playerid,13);
					veh[playerid] = CreateVehicle(GetPVarInt(playerid,"sca"),gpo[0],gpo[1],gpo[2],angla,0,0,9999999999999999);
				}
			}

            PutPlayerInVehicle(playerid,veh[playerid],0);
            producedcars[player[playerid][team]-1] -= 1;
            return 1;
        }
        case 137: //	ShowPlayerDialog(playerid,137,2,"Meat Shop","+3 teamkill,5 meat\n+1 kill,5 meat\nHeal 1 Unit, meat\nHeal team,00 meat
        {
            if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			        if(meat[player[playerid][team]-1] < 15) return SendClientMessage(playerid,COLOR_RED,"Zuwenig Meat");
			        meat[player[playerid][team]-1] -= 15,teamkills[player[playerid][team]-1] += 3;
			        SendClientMessage(playerid,COLOR_GREEN,"Teamkills gekauft");
			    }
			    case 1:
			    {
			        if(meat[player[playerid][team]-1] < 15) return SendClientMessage(playerid,COLOR_RED,"Zuwenig Meat");
			        meat[player[playerid][team]-1] -= 15;
			        SetPlayerScore(playerid,GetPlayerScore(playerid)+1);
					GetPlayerName(playerid,tknm,16);
            		format(mysqlquery[playerid],128,"UPDATE sav_score SET kills=kills+1 WHERE name = '%s'",tknm);
					mysql_query(mysqlquery[playerid]);
			        SendClientMessage(playerid,COLOR_GREEN,"Kills gekauft");
			    }
			    case 2:
				{
				    if(meat[player[playerid][team]-1] < 1) return SendClientMessage(playerid,COLOR_RED,"Zuwenig Meat");
				    ShowPlayerDialog(playerid,138,1,"Einheit heilen","Gib die ID der Einheit ein:","Heilen","Abbrechen");
				}
				case 3:
				{
				    if(meat[player[playerid][team]-1] < 30) return SendClientMessage(playerid,COLOR_RED,"Zuwenig Meat");
				    meat[player[playerid][team]-1] -= 30;
				    for(new hil=0;hil!=slots;hil++)
					{
						if(player[hil][team] != player[playerid][team])
						{
						    SetPlayerHealth(hil,100);
						    SendClientMessage(strval(inputtext),COLOR_GREEN,"Der Commander hat dich geheilt");
						}
					}
			        SendClientMessage(playerid,COLOR_GREEN,"Team geheilt");
				}
			}
        }
        case 138:
        {
            if(!IsPlayerConnected(strval(inputtext))) ShowPlayerDialog(playerid,138,1,"Einheit heilen","Gib die ID der Einheit ein:","Heilen","Abbrechen");
            meat[player[playerid][team]-1] -= 1;
            SetPlayerHealth(strval(inputtext),100);
            SendClientMessage(playerid,COLOR_GREEN,"Einheit geheilt");
            SendClientMessage(strval(inputtext),COLOR_GREEN,"Der Commander hat dich geheilt");
            return 1;
        }
        case 209:
        {
            if(!response) return 1;
			if(!strcmp("Friends online :",inputtext)) return 1;
            format(mysqlquery[playerid],256,"SELECT * FROM sav_score WHERE name = '%s'",inputtext);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			new statmsg[256],tid,srnm[16],data[256],field[6][32];
			mysql_fetch_row(data, "|");
			split(data, field, '|');
			for(new srch1=0;srch1!=slots;srch1++)
			{
			    if(IsPlayerConnected(srch1))
			    {
			        GetPlayerName(srch1,srnm,16);
			        if(!strcmp(inputtext,srnm))
			        {
			            tid = srch1;
			            break;
			        }
			    }
			}
			format(statmsg,256,"Playerid:\t\t%d\nKills:\t\t\t%d\nTode:\t\t%d\nSiege:\t\t\t%d\nVerloren:\t\t%d\nAdminlevel:\t\t%d",tid,strval(field[1]),strval(field[2]),strval(field[3]),strval(field[4]),strval(field[5]));
			ShowPlayerDialog(playerid,100,0,inputtext,statmsg,"Ok","");
			mysql_free_result();
			return 1;
        }
        case 1: //register
        {
            if(wartung == 1)
			{
			    SendClientMessage(playerid,COLOR_RED,"Der Server ist unter Bearbeitung, du kannst nicht beitreten");
				return Kick(playerid);
			}
            if(!strlen(inputtext)) ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen auf dem Savandreas Strategy TDM Server\n\nBitte gib ein Passwort ein:","Ok","");
			new nim[16];
			GetPlayerName(playerid,nim,16);
		    format(mysqlquery[playerid],128,"REPLACE INTO sav_score (alvl,name,kills,deaths,gamewins,gamelosses) VALUES ('0','%s','0','0','0','0')",nim);
			mysql_query(mysqlquery[playerid]);
			
			format(mysqlquery[playerid],128,"REPLACE INTO login (name,pw) VALUES ('%s','%s')",nim,inputtext);
			mysql_query(mysqlquery[playerid]);

			loggedin[playerid] = 1;
            //TextDrawShowForPlayer(playerid,classinfo[playerid]);
            SetPVarInt(playerid,"tutorial",1);
            SetPlayerColor(playerid,0xFFFFFF00);
            ShowPlayerDialog(playerid,912,0,"Tutorial","Willkommen zum Tutorial\nIch würde dir gerne das Strategy TDM Genre erklären\nBitte lies das Tutorial sorgfältig, es enthält wichtige Informationen\nDu kannst das Tutorial jederzeit abbrechen","Ok","Abbrechen");
            new output1[128];
			format(output1,sizeof(output1),"%s hat den Server betreten",nim);
		    SendClientMessageToAll(COLOR_GREY,output1);
		    SetTimerEx("payday",30*60*1000,0,"i",playerid);
			return 1;
		}
		case 2: //login
		{
		    if(!strlen(inputtext)) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Das eingegebene Passwort war falsch !\n\n Versuch es erneut:","Absenden","");
		    GetPlayerName(playerid,player_name[playerid],16);
			new tmpoutput5[128];
		    format(mysqlquery[playerid],256,"SELECT pw FROM login WHERE name = '%s'",player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			if(mysql_fetch_field("pw",tmpoutput5))
			{
		        if(!strcmp(tmpoutput5,inputtext))
		        {
		            mysql_free_result();
		            
		            new num[16];
				  	GetPlayerName(playerid,num,16);
	                format(mysqlquery[playerid],256,"SELECT * FROM sav_score WHERE name = '%s'",num);
					mysql_query(mysqlquery[playerid]);
					mysql_store_result();
					
					mysql_fetch_field("kills",tmpoutput5);
		            player[playerid][kills] = strval(tmpoutput5);
		            mysql_fetch_field("deaths",tmpoutput5);
		            player[playerid][deaths] = strval(tmpoutput5);
					
			        loggedin[playerid] = 1;
	                TextDrawShowForPlayer(playerid,classinfo[playerid]);
	                
				 	
				 	new tmpoutput[128];
					if(mysql_fetch_field("alvl",tmpoutput))
					{
					    if(strval(tmpoutput) != 0)
					    {
					        if(strval(tmpoutput) != 0) AllowPlayerTeleport(playerid,1);
							switch(strval(tmpoutput))
							{
								case 1:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Supporter");
								case 2:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Moderator");
								case 3:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Scripter");
							}
						}
					    else
					    {
					        if(wartung == 1)
							{
							    SendClientMessage(playerid,COLOR_RED,"Der Server wird gerade gewartet, du kannst solange nicht beitreten");
								return Kick(playerid);
							}
					    }
						adminlevel[playerid] = strval(tmpoutput);
					}
					mysql_free_result();
					format(mysqlquery[playerid],256,"SELECT kills FROM sav_score WHERE name = '%s'",num);
					mysql_query(mysqlquery[playerid]);
				 	mysql_store_result();
					if(mysql_fetch_field("kills",tmpoutput))
					{
						player[playerid][kills] = strval(tmpoutput);
						SetPlayerScore(playerid,player[playerid][kills]);
					}
					mysql_free_result();
		        }
		        else
				{
					ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Das eingegebene Passwort war falsch !\n\n Versuch es erneut:","Absenden","");
                    mysql_free_result();
					return 0;
				}
			}
			mysql_free_result();

			new output1[128];
			GetPlayerName(playerid,player_name[playerid],16);
			format(output1,sizeof(output1),"%s hat den Server betreten",player_name[playerid]);
		    SendClientMessageToAll(COLOR_GREY,output1);
		    
		    SetTimerEx("payday",30*60*1000,0,"i",playerid);
		    return 1;
		}
		case 555: //commander build menu
		{
		    switch(listitem)
		    {
		        case 0:
		        {
		        	if(teammoney[player[playerid][team]-1] < 3500)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 3940;
                    combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,3940,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
					
				}
				case 1:
				{
					if(teammoney[player[playerid][team]-1] < 1000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
		            comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 3637;
		            combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,3637,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
		        }
		        case 2:
		        {
		            if(teammoney[player[playerid][team]-1] < 15000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					if(teamkills[player[playerid][team]-1] < 25) return GameTextForPlayer(playerid,"Zu wenige Kills",2000,1);
		            comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 3986;
		            combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,3986,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
		        }
		        case 3:
		        {
		            if(teammoney[player[playerid][team]-1] < 15000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					if(teamkills[player[playerid][team]-1] < 50) return GameTextForPlayer(playerid,"Zuw enige Kills",2000,1);
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 4726;
					combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,4726,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 4:
				{
				    if(teammoney[player[playerid][team]-1] < 15000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					if(teamkills[player[playerid][team]-1] < 50) return GameTextForPlayer(playerid,"Zu wenige Kills",2000,1);
		            comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 4889;
		            combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,4889,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
		        }
		        case 5:
		        {
		            if(teammoney[player[playerid][team]-1] < 8000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 3998;
					combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,3998,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 6:
				{
				    if(teammoney[player[playerid][team]-1] < 15000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					//if(teamkills[player[playerid][team]-1] < 25) return GameTextForPlayer(playerid,"Too less kills",2000,1);
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 9237;
					combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,9237,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 7:
				{
				    if(teammoney[player[playerid][team]-1] < 8000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 9244;
					combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,9244,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 8:
				{
				    if(teammoney[player[playerid][team]-1] < 2000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 987;
				    combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,987,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 9:
				{
				    if(teammoney[player[playerid][team]-1] < 8000)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 18241;
				    combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,18241,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],0,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
				}
				case 10:
				{
				    if(teammoney[player[playerid][team]-1] < 7500)
		        	{
		        	    return GameTextForPlayer(playerid,"Das Gebäude ist zu teuer",2000,1);
					}
					if(teamkills[player[playerid][team]-1] < 40) return GameTextForPlayer(playerid,"Zu wenige Kills",2000,1);
		            comisbuilding[player[playerid][team]-1] = 1,combuildinginprogress[player[playerid][team]-1] = 3502;
		            combuilding[player[playerid][team]-1][0] = comview[player[playerid][team]-1][0];
					combuilding[player[playerid][team]-1][1] = comview[player[playerid][team]-1][1];
					MapAndreas_FindZ_For2DCoord(combuilding[player[playerid][team]-1][0], combuilding[player[playerid][team]-1][1], calcpos[player[playerid][team]-1]);
					combuildid[player[playerid][team]-1] = CreatePlayerObject(playerid,3502,combuilding[player[playerid][team]-1][0],combuilding[player[playerid][team]-1][1],calcpos[player[playerid][team]-1],90,0,0);
					calcpos[player[playerid][team]-1] = 0.0;
		        }
		    }
		}
		case 99: //Commander Keys\nClasses\nBuildings\nTricks\nGameplay\nFriend System\nCredits\nmeat
		{
  			if(!response) return 1;
  			switch(listitem)
  			{
				case 0: ShowPlayerDialog(playerid,100,0,"Commander Tasten","w/s\t\tzoom\nNumPad\tKamera bewegen/Gebäude paltzieren\nHupe\t\tBaumenü öffnen/Gebäude setzen\nAngriff\t\tBau abbrechen/Gebäude verkaufen\n/com\t\tWerde Commander\n/resign\t\tAbdanken als Commander\n/focus [ID]\tAuf Einheit Kamera zentrieren\nBremse\t\tPosition markieren\nQ/E\t\tGebäude rotieren","Ok","");
				case 1: ShowPlayerDialog(playerid,100,0,"Klassen","Sanitäter\t\tHeilt Einheiten\nSoldat\t\tBeste Infanterieeinheit\nScout\t\tFernkampfinfanterie\nPanzerfahrer\tKann Einheiten und Gebäude angreifen\nHunter Pilot\t#1 Killer","Ok","");
				case 2: ShowPlayerDialog(playerid,100,0,"Gebäude","Clone Centre\t\t\tHauptgebäude,Zerstören zum Sieg\nSubclone Centre\t\tSpawn-Position,erlaubt bauen weiterer Gebäude\nArmory\t\t\tGibt Rüstung und Waffen\nÖlpumpe\t\tErhöht Einkommen\nPanzer Fabrik\t\t\tProduziert Panzer\nHunter Fabrik\t\tProduziert Hunters\nClone Research Center\tSenkt Respawnzeit\nVerteidigungsturm\t\t\tVerteidigt Position\nAuto Fabrik\t\t\tProduziert Autos\nZaun\t\t\tBlockiert Durchgänge","Ok","");
				case 3: ShowPlayerDialog(playerid,100,0,"Tricks","Du würdest gerne ein Profi werden ?\nBesuch unser Forum www.savandreas.com und lerne Tricks & Kniffe","Ok","");
				case 4: ShowPlayerDialog(playerid,100,0,"Gameplay","Now you may ask yourself, whats this all about...\nOne little question: You ever played Warcraft, Age Of Empires or any other Strategy Game ?\nWell, that makes it more easy. So, every team have one commander\nThis commander have the possibility to build buildings (watch /help -> building), which the units need\nThe Units now have to defeat the opposite team\nThe Game ends, when the main structure of any team got brought destroyed","Ok","");
                case 5: ShowPlayerDialog(playerid,100,0,"Freundessystem","/addfriend [Name]\t\tFügt einen Freund hinzu\n/deletefriend [Name]\t\tEntfernt Freund\n/friends\t\t\tZeigt Freunde, die online sind\n\nMit dem Freundessystem,\nkannst du Freunde sehen, die online sind,\nund ihre Statistik","Ok","");
				case 6: ShowPlayerDialog(playerid,100,0,"Credits","Trooper[Y]\tScripting\nKye\t\tMapAndreas\n[Drug]Slick\tSII\nG-sTyLeZzZ\tMySQL Plugin\nStrickenKid\tPointToPoint Plugin\nInternetInk\tSP Mission","Ok","");
				case 7: ShowPlayerDialog(playerid,100,0,"Meat System","Bau Meat ab, indem du ein Clone Subcentre am alten Flughafen baust\nMeat erlaubt dem Commander, das Team zu unterstützen","Ok","");
			}
		}
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward anticheat(playerid);
public anticheat(playerid)
{
    KillTimer(GetPVarInt(playerid,"actimer"));
	if(!IsPlayerConnected(playerid)) return 0;
	new Float:tval;
	if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK && adminlevel[playerid] != 3) return banit(playerid,"Jetpack Hack");
	if(GetPlayerMoney(playerid) > 0) return banit(playerid,"Money Hack");
	GetPlayerArmour(playerid,tval);
	if(tval != float(0))
	{
		if(tval > floatmul(float(building_number[Armory][player[playerid][team]-1]),float(10))) return banit(playerid,"Armor Hack");
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(GetPlayerVehicleID(playerid) != veh[playerid] && player[playerid][position] != 4 && GetPlayerState(playerid) == 2 && playerid != capture[5])
	    {
	        SendClientMessage(playerid,COLOR_RED,"Du kannst keine Autos klauen, aber hast es... Hack ?");
	        return Kick(playerid);
	    }
	}
	else
	{
	    new Float:aa[3],Float:nz = 0;
		GetPlayerPos(playerid,aa[0],aa[1],nz);
		MapAndreas_FindZ_For2DCoord(aa[0],aa[1],aa[2]);
		if(nz-100 > aa[2] && GetPVarInt(playerid,"skin") != 2 && capture[5] != playerid && GetPlayerSurfingVehicleID(playerid) == INVALID_VEHICLE_ID) banit(playerid,"Airbreak");
	}

	SetPVarInt(playerid,"actimer",SetTimerEx("anticheat",10000,0,"i",playerid));
	return 1;
}

public voteoff(playerid)
{
	new maxplayers = 0;
    for(new vid; vid<slots; vid++)
    {
		if(IsPlayerConnected(vid)) { maxplayers = maxplayers + 1; }
    }
    if(votes > maxplayers/1.5)
    {
        new
			ThePlayer[MAX_PLAYER_NAME],
		    string[128];
		GetPlayerName(playerid,ThePlayer,sizeof(ThePlayer));
		format(string,sizeof(string),"%s (ID %d) wurde durch eine Abstimmung gekickt !",ThePlayer,playerid);
		SendClientMessageToAll(COLOR_GREY,string);
		Kick(playerid);
    }
    if(votes <= maxplayers)
    {
        SendClientMessageToAll(COLOR_GREY,"Abstimmung fehlgeschlagen !");
    }
    votes = 0;
    vote = 0;
    return 1;
}

forward banit(playerid,reason[]);
public banit(playerid,reason[])
{
	if(GetPVarInt(playerid,"destroyedarm") != 0) return 0;
	new bmsg[128],npm[16];
	GetPlayerName(playerid,npm,16);
	
	if(strfind(reason,"Waffen") != -1)
	{
	    /*
	    format(bmsg,128,"User %s got banned from Trooper[Y], Reason: %s (%d,%d)",npm,reason,GetPVarInt(playerid,"iw"),GetPVarInt(playerid,"ia"));
		SendClientMessageToAll(COLOR_RED,bmsg);
		new n_r[256];
		format(n_r,256,"%s (%d,%d)",reason,GetPVarInt(playerid,"iw"),GetPVarInt(playerid,"ia"));
		if(adminlevel[playerid] == 0) bansql(playerid,n_r);
		//if(adminlevel[playerid] == 0) Kick(playerid);
		else SendClientMessage(playerid,COLOR_RED,"Your a teammember, you didnt get banned");
		*/
		return 0; //wird von nowebu erledigt
	}
	else
	{
	    format(bmsg,128,"User %s wurde gebannt von Trooper[Y], Grund: %s",npm,reason);
		SendClientMessageToAll(COLOR_RED,bmsg);
		if(adminlevel[playerid] == 0) bansql(playerid,reason);
		//if(adminlevel[playerid] == 0) Kick(playerid);
		else SendClientMessage(playerid,COLOR_RED,"Du gehörst zum Team, und konntest nicht gebannt werden");
	}

	return 1;
}



dcmd_kick(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /kick [playerid] [Reason]");
	}
	if(GetPVarInt(pID,"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Spieler wurde noch nicht gemeldet");
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID nicht online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"%s (ID %d) wurde gekickt, Grund: %s",ThePlayer,pID,sGrund);
	SendClientMessageToAll(COLOR_GREY,string);
	Kick(pID);
	return 1;
}

dcmd_unfreeze(playerid, params[])
{
    if(adminlevel[playerid] == 0) {return 0; }
    if(GetPVarInt(strval(params),"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"He hasnt been reported yet, dont abuse");
	TogglePlayerControllable(strval(params),1);
	return 1;
}

dcmd_freeze(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /freeze [playerid] [Reason]");
	}
	if(GetPVarInt(pID,"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Spieler wurde noch nicht gemeldet");
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID nicht online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"%s (ID %d) wurde gefreezed, Grund: %s",ThePlayer,pID,sGrund);
	SendClientMessageToAll(COLOR_GREY,string);
	TogglePlayerControllable(pID,0);
	return 1;
}

dcmd_report(playerid, params[])
{
	if(adminlevel[playerid] != 0) return 0;
	new foundad=0;
	for(new ison=0;ison!=slots;ison++)
	{
	    if(IsPlayerConnected(ison) && adminlevel[ison] != 0)
	    {
	        foundad = 1;
	        break;
		}
	}
	if(foundad == 0) return SendClientMessage(playerid,COLOR_RED,"Kein Admin online, benutz /votekick");
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /report [playerid] [Reason]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID nicht online");
	}
	new rpmsg[128],usrnm[16],rpnm[16];
	GetPlayerName(playerid,usrnm,16);
	GetPlayerName(pID,rpnm,16);
	format(rpmsg,128,"Spieler %s (%d) meldete Spieler %s (%d) : %s",usrnm,playerid,rpnm,pID,sGrund);
	for(new ison=0;ison!=slots;ison++)
	{
	    if(IsPlayerConnected(ison) && adminlevel[ison] != 0)
	    {
	        SendClientMessage(ison,COLOR_YELLOW,rpmsg);
		}
	}
	SetPVarInt(pID,"reported",1);
	SendClientMessage(playerid,COLOR_GREEN,"Report erfolgreich");
	return 1;
}

dcmd_ban(playerid, params[])
{
	if(adminlevel[playerid] == 0) { return 0; }
	if(adminlevel[playerid] < 2) { return SendClientMessage(playerid,COLOR_RED,"Du brauchst adm lvl 2 !"); }

	new
	    sGrund[128],
		pID;
	if(sscanf(params, "dz",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /ban [playerid] [Reason]");
	}
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID not online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	GetPlayerName(playerid,player_name[playerid],16);
	format(string,128,"User %s wurde gebannt von %s, Grund: %s",ThePlayer,player_name[playerid],sGrund);
	SendClientMessageToAll(COLOR_RED,string);
	bansql(pID,sGrund);
	return 1;
}

forward bansql(playerid,reason[]);
public bansql(playerid,reason[])
{
	new sinfo[128];
	GetPlayerName(playerid,player_name[playerid],16);
	GetPlayerIp(playerid,sinfo,128);

	format(mysqlquery[playerid],256,"Du wurdest gebannt wegen %s",reason);
    SendClientMessage(playerid,COLOR_RED,mysqlquery[playerid]);

	if(!strcmp(sinfo,"127.0.0.1")) return 0;
    new mip[255];
	gpci(playerid, mip, 255);
    format(mysqlquery[playerid],256,"INSERT INTO bans (name,ip,reason,hdwid) VALUES ('%s','%s','%s','%s')",player_name[playerid],sinfo,reason,mip);
	mysql_query(mysqlquery[playerid]);

	Kick(playerid);
	return 1;
}

forward updatebar(playerid);
public updatebar(playerid)
{
    new gtm,formtry[5][128];
	if(player[playerid][team] == 2) gtm = 0;
	if(player[playerid][team] == 1) gtm = 1;
	TextDrawHideForPlayer(playerid,leiste_oben[gtm]);
	if(producedhunters[player[playerid][team]-1] > 0) format(formtry[0],128," Hunter:%d -",producedhunters[player[playerid][team]-1]);
    if(producedtanks[player[playerid][team]-1] > 0) format(formtry[1],128," Panzer:%d -",producedtanks[player[playerid][team]-1]);
    if(producedcars[player[playerid][team]-1] > 0) format(formtry[2],128," Autos:%d -",producedcars[player[playerid][team]-1]);
	format(leistentext[playerid],265," - Team-Kills:%d - Meat:%d - Teamgeld:%d -%s%s%s",teamkills[player[playerid][team]-1],meat[player[playerid][team]-1],teammoney[player[playerid][team]-1],formtry[0],formtry[1],formtry[2]);
	//producedtanks[player[playerid][team]-1],producedhunters[player[playerid][team]-1],producedcars[player[playerid][team]-1]
	TextDrawSetString(leiste_oben[player[playerid][team]-1],leistentext[playerid]);
	if(GetPVarInt(playerid,"mission") == 1) TextDrawHideForPlayer(playerid,leiste_oben[player[playerid][team]-1]);
	else TextDrawShowForPlayer(playerid,leiste_oben[player[playerid][team]-1]);
	return 1;
}



forward spawnvehicle(playerid);
public spawnvehicle(playerid)
{
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT strat_bcar FROM login WHERE name='%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	new tmpoutput2[128],fsk;
	mysql_fetch_field("strat_bcar",tmpoutput2);
	fsk = strval(tmpoutput2);
	SetPVarInt(playerid,"sca",fsk);
	mysql_free_result();
	if(fsk > 0) format(tmpoutput2,128,"Barrack\nRancher\nBus\n%s",VehicleNames[fsk-400]);
	else format(tmpoutput2,128,"Barrack\nRancher\nBus");
	return ShowPlayerDialog(playerid,182,2,"Wähl ein Auto",tmpoutput2,"Choose","Abbrechen");
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

Float:DistanceCameraTargetToLocation(Float:CamX, Float:CamY, Float:CamZ,   Float:ObjX, Float:ObjY, Float:ObjZ,   Float:FrX, Float:FrY, Float:FrZ) {

	new Float:TGTDistance;

	// get distance from camera to target
	TGTDistance = floatsqroot((CamX - ObjX) * (CamX - ObjX) + (CamY - ObjY) * (CamY - ObjY) + (CamZ - ObjZ) * (CamZ - ObjZ));

	new Float:tmpX, Float:tmpY, Float:tmpZ;

	tmpX = FrX * TGTDistance + CamX;
	tmpY = FrY * TGTDistance + CamY;
	tmpZ = FrZ * TGTDistance + CamZ;

	return floatsqroot((tmpX - ObjX) * (tmpX - ObjX) + (tmpY - ObjY) * (tmpY - ObjY) + (tmpZ - ObjZ) * (tmpZ - ObjZ));
}

stock IsPlayerAimingAt(playerid, Float:x, Float:y, Float:z, Float:radius)
{
	new Float:cx,Float:cy,Float:cz,Float:fx,Float:fy,Float:fz;
	GetPlayerCameraPos(playerid, cx, cy, cz);
	GetPlayerCameraFrontVector(playerid, fx, fy, fz);
	return (radius >= DistanceCameraTargetToLocation(cx, cy, cz, x, y, z, fx, fy, fz));
}

stock CreateChristmasTree(Float:X, Float:Y, Float:Z)
{
	CreateObjectToStream(3472,X+0.28564453,Y+0.23718262,Z+27.00000000,0.00000000,0.00000000,230.48021);
	CreateObjectToStream(664,X+0.20312500,Y+0.01171875,Z+-3.00000000,0.00000000,0.00000000,0.00000000);
	CreateObjectToStream(3472,X+0.45312500,Y+0.51562500,Z+4.00000000,0.00000000,0.00000000,69.7851562);
	CreateObjectToStream(3472,X+0.65136719,Y+1.84570312,Z+17.00000000,0.00000000,0.00000000,41.863403);
	CreateObjectToStream(7666,X+0.34130859,Y+0.16845703,Z+45.00000000,0.00000000,0.00000000,298.12524);
	CreateObjectToStream(7666,X+0.34082031,Y+0.16796875,Z+45.00000000,0.00000000,0.00000000,27.850342);
	CreateObjectToStream(3472,X+0.45312500,Y+0.51562500,Z+12.00000000,0.00000000,0.00000000,350.02441);
	CreateObjectToStream(3472,X+0.45312500,Y+0.51562500,Z+7.00000000,0.00000000,0.00000000,30.0805664);
	CreateObjectToStream(3472,X+0.45312500,Y+0.51562500,Z+22.00000000,0.00000000,0.00000000,230.47119);
	CreateObjectToStream(1262,X+0.15039062,Y+0.57128906,Z+29.45285416,0.00000000,0.00000000,162.90527);
}
