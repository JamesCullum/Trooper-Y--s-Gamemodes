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
#include <mysql>
//#include <mapandreas>
#include <eum>
#include <progress>

#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA

#define slots 75

new player_name[slots][16];

enum skill_para
{
	name[128],
	beschreibung[256],
	level
}
#define skillcount 15
new skill[skillcount][skill_para]; //50 = menge an skills

enum map_para
{
	spawns,
	Float:minx,
	Float:maxx,
	Float:miny,
	Float:maxy,
	name[128]
}
#define mapcount 1
#define botcount 50
new maps[mapcount][map_para],Float:mapspawn[mapcount][3][5],mysqlquery[slots][256],atmmap,Text:counter,countdown[2];
new skillsett[slots][2]; //4 skill slots, 2 fähigkeiten
new Text:txtdraws[10],Text3D:dishide[slots],PlayerText3D:anvi[slots],PlayerText3D:templerbl[slots][slots],Bar:expbar[slots];
new Text:verfolgertxt[slots];

main()
{
}

forward AddMap(id,name2[128],Float:minx2,Float:maxx2,Float:miny2,Float:maxy2);
public AddMap(id,name2[128],Float:minx2,Float:maxx2,Float:miny2,Float:maxy2)
{
	maps[id][minx] = minx2;
	maps[id][maxx] = maxx2;
	maps[id][miny] = miny2;
	maps[id][maxy] = maxy2;
	maps[id][name] = name2;
	return 1;
}

Float:GetDistance(Float:x1,Float:y1,Float:z1,Float:x3,Float:y3,Float:z3)
{
	return floatsqroot(floatpower(floatabs(floatsub(x3,x1)),2)+floatpower(floatabs(floatsub(y3,y1)),2)+floatpower(floatabs(floatsub(z3,z1)),2));
}

forward AddSpawn(id,spid,Float:x,Float:y,Float:z);
public AddSpawn(id,spid,Float:x,Float:y,Float:z)
{
	maps[id][spawns] += 1;
	mapspawn[id][0][spid] = x;
	mapspawn[id][1][spid] = y;
	mapspawn[id][2][spid] = z;
	return 1;
}

public OnGameModeInit()
{
	print(" -------------------------------- ");
	print(" ------- ACB GM lädt --------- ");
	//MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
    SetGameModeText("FFA DM");
	SendRconCommand("mapname Savandreas");
	DisableInteriorEnterExits();
	mysql_init();
    mysql_connect("xxx", "xxx", "xxx", "xxx");
    SetTimer("nodrop",60000*10,0);
	SetTimer("changeweather",60000*10,1);
	changeweather();
	ShowNameTags(0);

	AddPlayerClass(123,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	AddPlayerClass(111,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	AddPlayerClass(127,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	AddPlayerClass(165,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	AddPlayerClass(166,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	AddPlayerClass(285,972.7090,-2.7833,1001.1484,182.2034,0,0,0,0,0,0);
	
	countdown[0] = 60*10; //standartzeit
	countdown[1] = countdown[0]; //restzeit
	SetTimer("countit",1000,1);
	counter = TextDrawCreate(83.000000,250.000000,"Zeit: ~n~0");
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
	
	txtdraws[0] = TextDrawCreate(0.000000, 0.000000, "space"); //cinematic
	TextDrawBackgroundColor(txtdraws[0], 255);
	TextDrawFont(txtdraws[0], 1);
	TextDrawLetterSize(txtdraws[0], 1.500000, 11.799999);
	TextDrawColor(txtdraws[0], 255);
	TextDrawSetOutline(txtdraws[0], 0);
	TextDrawSetProportional(txtdraws[0], 1);
	TextDrawSetShadow(txtdraws[0], 1);
	TextDrawUseBox(txtdraws[0], 1);
	TextDrawBoxColor(txtdraws[0], 255);
	TextDrawTextSize(txtdraws[0], 640.000000, 190.000000);
	
	txtdraws[6] = TextDrawCreate(1.000000, 310.000000, "space2"); //cinematic
	TextDrawBackgroundColor(txtdraws[6], 255);
	TextDrawFont(txtdraws[6], 1);
	TextDrawLetterSize(txtdraws[6], 0.500000, 15.300001);
	TextDrawColor(txtdraws[6], 255);
	TextDrawSetOutline(txtdraws[6], 0);
	TextDrawSetProportional(txtdraws[6], 1);
	TextDrawSetShadow(txtdraws[6], 1);
	TextDrawUseBox(txtdraws[6], 1);
	TextDrawBoxColor(txtdraws[6], 255);
	TextDrawTextSize(txtdraws[6], 640.000000, 0.000000);
	
	txtdraws[7] = TextDrawCreate(0.000000, 1.000000, "1"); //blenden
	TextDrawBackgroundColor(txtdraws[7], 0);
	TextDrawFont(txtdraws[7], 1);
	TextDrawLetterSize(txtdraws[7], 2.899999, 18.000000);
	TextDrawColor(txtdraws[7], 0);
	TextDrawSetOutline(txtdraws[7], 0);
	TextDrawSetProportional(txtdraws[7], 1);
	TextDrawSetShadow(txtdraws[7], 1);
	TextDrawUseBox(txtdraws[7], 1);
	TextDrawBoxColor(txtdraws[7], 0);
	TextDrawTextSize(txtdraws[7], 640.000000, 0.000000);
	
	txtdraws[1] = TextDrawCreate(82.000000, 308.000000, "Yakuza");
	TextDrawAlignment(txtdraws[1], 2);
	TextDrawBackgroundColor(txtdraws[1], 255);
	TextDrawFont(txtdraws[1], 0);
	TextDrawLetterSize(txtdraws[1], 1.000000, 3.000000);
	TextDrawColor(txtdraws[1], -1);
	TextDrawSetOutline(txtdraws[1], 1);
	TextDrawSetProportional(txtdraws[1], 1);
	
	txtdraws[2] = TextDrawCreate(82.000000, 308.000000, "Tambowskaja");
	TextDrawAlignment(txtdraws[2], 2);
	TextDrawBackgroundColor(txtdraws[2], 255);
	TextDrawFont(txtdraws[2], 0);
	TextDrawLetterSize(txtdraws[2], 1.000000, 3.000000);
	TextDrawColor(txtdraws[2], -1);
	TextDrawSetOutline(txtdraws[2], 1);
	TextDrawSetProportional(txtdraws[2], 1);
	
	txtdraws[6] = TextDrawCreate(82.000000, 308.000000, "Hitmen");
	TextDrawAlignment(txtdraws[6], 2);
	TextDrawBackgroundColor(txtdraws[6], 255);
	TextDrawFont(txtdraws[6], 0);
	TextDrawLetterSize(txtdraws[6], 1.000000, 3.000000);
	TextDrawColor(txtdraws[6], -1);
	TextDrawSetOutline(txtdraws[6], 1);
	TextDrawSetProportional(txtdraws[6], 1);
	
	txtdraws[3] = TextDrawCreate(82.000000, 308.000000, "CIA");
	TextDrawAlignment(txtdraws[3], 2);
	TextDrawBackgroundColor(txtdraws[3], 255);
	TextDrawFont(txtdraws[3], 0);
	TextDrawLetterSize(txtdraws[3], 1.000000, 3.000000);
	TextDrawColor(txtdraws[3], -1);
	TextDrawSetOutline(txtdraws[3], 1);
	TextDrawSetProportional(txtdraws[3], 1);
	
	txtdraws[4] = TextDrawCreate(82.000000, 308.000000, "FBI");
	TextDrawAlignment(txtdraws[4], 2);
	TextDrawBackgroundColor(txtdraws[4], 255);
	TextDrawFont(txtdraws[4], 0);
	TextDrawLetterSize(txtdraws[4], 1.000000, 3.000000);
	TextDrawColor(txtdraws[4], -1);
	TextDrawSetOutline(txtdraws[4], 4);
	TextDrawSetProportional(txtdraws[4], 1);
	
	txtdraws[5] = TextDrawCreate(82.000000, 308.000000, "SWAT");
	TextDrawAlignment(txtdraws[5], 2);
	TextDrawBackgroundColor(txtdraws[5], 255);
	TextDrawFont(txtdraws[5], 0);
	TextDrawLetterSize(txtdraws[5], 1.000000, 3.000000);
	TextDrawColor(txtdraws[5], -1);
	TextDrawSetOutline(txtdraws[5], 1);
	TextDrawSetProportional(txtdraws[5], 1);
	
	//Fähigkeiten
	AddSkill(0,"Tarnung","Verwandle dich kurzweilig in jemand andres",2);
	AddSkill(1,"Trubel","Verwandle Passanten in dich",3);
	AddSkill(2,"Pistole","Töte Gegner aus der Entfernung",4);
	AddSkill(3,"Knallkörper","Filtere und blende Assassinen aus der Menge heraus",6);
	AddSkill(4,"Rauchbombe","Betäub Assassinen",8);
	AddSkill(5,"Templerblick","Erkenne Assassinen",10);
	AddSkill(6,"Gift","Töte ein Opfer mit Verzögerung",13);
	AddSkill(7,"Großer Trubel","Verwandle viele Passanten in dich",15);
	AddSkill(8,"Sniper","Töte Gegner aus großer Entfernung",17);
	AddSkill(9,"Starke Rauchbombe","Betäub Assassinen länger",20);
	AddSkill(10,"Langsames Gift","Töte einen Gegner mit viel Verzögerung",25);
	AddSkill(11,"Weiter Templerblick","Filtere und blende Assassinen aus der Menge heraus",25);
	
	// maps
	//1: einkaufszentrum ls
	AddMap(0,"Einkaufszentrum",1059.1766357422,1184.1437988281,-1558.5205078125,-1415.90234375);
	AddSpawn(0,0,1167.4498291016,-1490.205078125,22.757677078247);
	AddSpawn(0,1,1129.7176513672,-1489.25,22.769031524658);
	AddSpawn(0,2,1089.9152832031,-1491.4445800781,22.761547088623);
	AddSpawn(0,3,1127.6458740234,-1541.5450439453,22.753995895386);
	AddSpawn(0,4,1098.5167236328,-1428.0538330078,22.764768600464);
	AddSpawn(0,5,1157.1888427734,-1427.5316162109,22.766672134399);

	// endmaps
	
	atmmap = random(mapcount);
	loadmap();
	
	print(" ------- ACB GM geladen --------- ");
	print(" ----------------------------------- ");
	
	
	
	return 1;
}

forward loadmap();
public loadmap()
{
	countdown[1] = countdown[0];
	for(new res=0;res!=slots;res++)
	{
	    if(IsPlayerNPC(res)) Kick(res);
		if(IsPlayerConnected(res) && !IsPlayerNPC(res)) OnPlayerSpawn(res);
	}
	new prm[2][128];
	for(new sp=0;sp!=botcount;sp++)
	{
		format(prm[0],128,"npc%d",sp);
	    format(prm[1],128,"map%drunner%d",atmmap,random(15));
	    ConnectNPC(prm[0],prm[1]);
	}
	return 1;
}

forward countit();
public countit()
{
	new tf[128],Float:calco;
	if(countdown[1] <= 0) return 0;
	countdown[1] -= 1;
	calco = float(countdown[1])/float(60);
	format(tf,128,"Zeit: ~n~%0.2f",calco);
	TextDrawSetString(counter,tf);
	
	if(countdown[1] == 0)
	{
	    atmmap = random(mapcount);
	    loadmap();
	}
	
	for(new show=0;show!=slots;show++) if(IsPlayerConnected(show) && !IsPlayerNPC(show)) TextDrawShowForPlayer(show,counter);
	
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

forward nodrop();
public nodrop()
{
    SetTimer("nodrop",60000*10,0);
    new nodropcmd[256];
	format(nodropcmd,256,"UPDATE nodrop SET value = '%d'",random(100));
	mysql_query(nodropcmd);
	return 1;
}

forward changeweather();
public changeweather()
{
	SetWorldTime(random(23)+1);
	switch(random(5))
	{
	    case 0:SetWeather(08);
	    case 1:SetWeather(09);
	    case 2:SetWeather(10);
	    case 3:SetWeather(10);
	    case 4:SetWeather(16);
	}
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return SpawnPlayer(playerid);
	SetPlayerPos(playerid,973.2206,8.1626,1001.1484);
	SetPlayerInterior(playerid,3);
	SetPlayerFacingAngle(playerid, 182.2034);
	SetPlayerCameraPos(playerid,972.7090,-2.7833,1001.1484);
	SetPlayerCameraLookAt(playerid,973.2206,8.1626,1001.1484);
	SetPVarInt(playerid,"skin",classid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if(!checkban(playerid)) return 0;
    
    verfolgertxt[playerid] = TextDrawCreate(83.000000, 426.000000, "0"); //verfolger
	TextDrawAlignment(verfolgertxt[playerid], 2);
	TextDrawBackgroundColor(verfolgertxt[playerid], 255);
	TextDrawFont(verfolgertxt[playerid], 1);
	TextDrawLetterSize(verfolgertxt[playerid], 0.500000, 1.000000);
	TextDrawColor(verfolgertxt[playerid], -16776961);
	TextDrawSetOutline(verfolgertxt[playerid], 0);
	TextDrawSetProportional(verfolgertxt[playerid], 1);
	TextDrawSetShadow(verfolgertxt[playerid], 0);

	expbar[playerid] = CreateProgressBar(130.000000, 440.000000, 500, 5, COLOR_YELLOW, 100); //erfahrung
    
    SetPVarInt(playerid,"anvi",-1);
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT pw FROM login WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
		mysql_free_result();

		format(mysqlquery[playerid],256,"SELECT * FROM acb_stat WHERE name = '%s'",player_name[playerid]);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
		if(mysql_num_rows() <= 0)
		{
			format(mysqlquery[playerid],256,"INSERT INTO acb_stat (name,exp,skillsetting,admlvl) VALUES ('%s','0','0|0','0')",player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
		}

		mysql_free_result();
		ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Willkommen auf dem Assassins Creed:Brotherhood Server\nDieser Server ist Teil des Savandreas Networks\nWebsite: www.savandreas.com\n\nBitte gib dein Passwort ein:","Absenden","");
	}
	else ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen auf dem Assassins Creed:Brotherhood\nDieser Server ist Teil des Savandreas Networks\nBans werden im Netzwerk geteilt\n\nBitte gib ein geheimes Passwort ein:","Registrieren","");
	mysql_free_result();
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

public OnPlayerDisconnect(playerid, reason)
{
    savestats(playerid);
    DestroyProgressBar(expbar[playerid]);
    EUM_DestroyForPlayer(playerid);
	return 1;
}

public OnPlayerResponse(playerid, option) // EUM_ShowForPlayer(playerid, identifyid, titel,text,möglichkeiten);
{
    if(EUM_Indentify(playerid, 1)) //1. Aussehen aendern~n~2. Faehigkeiten aendern~n~~n~3. Hilfe~n~4. Credits~n~5. Auszeichnungen
	{
	    EUM_DestroyForPlayer(playerid);
        switch(option)
        {
            case 1: ShowPlayerDialog(playerid,3,2,"Aussehen ändern","Yakuza\nTambowskaja\nHitmen\nCIA\nFBI\nSWAT","Nehmen","Abbrechen");
			case 2: showskills(playerid);
			case 3: ShowPlayerDialog(playerid,177,0,"Das Netzwerk","Dieser Server ist Teil des Savandreas Networks\nIm Netzwerk werden Logins,Bans,\nCoins und Auszeichnungen geteilt\nDie gemeinsame Website findest du auf savandreas.com\n\nNächste Seite: Das HUD","Weiter","Abbrechen");
			case 4: ShowPlayerDialog(playerid,999,0,"Credits","Trooper[Y]\tScripting\nStrickenkid\tMySQL Plugin\nLuka P.\tEUM\nToribio\t\tProgressbar","Ok","");
			case 5: showachiv(playerid);
		}
		
        return 1;
 	}

	return 1;
}

forward AddSkill(id,name2[128],beschreibung2[256],level2);
public AddSkill(id,name2[128],beschreibung2[256],level2)
{
	skill[id][name] = name2;
	skill[id][beschreibung] = beschreibung2;
	skill[id][level] = level2;
	return 1;
}

forward getlevel(playerid);
public getlevel(playerid)
{
	new endlvl= 0;
	
	for(new cha=5;cha<=5^25;cha=cha*2)
	{
	    if(GetPVarInt(playerid,"exp") > cha*100*2) endlvl += 1;
	}

	return endlvl;
}

forward showskills(playerid);
public showskills(playerid)
{
	new endstring[2048],owl = getlevel(playerid);
	for(new chk=0;chk!=skillcount;chk++)
	{
	    if(skill[chk][level] == 0) continue;
		if(skill[chk][level] > owl)
		{
		    format(endstring,2048,"{AFAFAF}%s\n%s",skill[chk][name],endstring);
		}
		else
		{
			if(chk == skillsett[playerid][0] || chk == skillsett[playerid][1])
			{
                format(endstring,2048,"{33AA33}%s\n%s",skill[chk][name],endstring);
			}
			else format(endstring,2048,"{AA3333}%s\n%s",skill[chk][name],endstring);
		}
	}
	ShowPlayerDialog(playerid,4,2,"Fähigkeiten",endstring,"Infos","Schließen");
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid,0);
	if(IsPlayerNPC(playerid))
	{
		switch(random(6))
		{
		    case 0:SetPlayerSkin(playerid,123);
		    case 1:SetPlayerSkin(playerid,111);
		    case 2:SetPlayerSkin(playerid,127);
		    case 3:SetPlayerSkin(playerid,165);
		    case 4:SetPlayerSkin(playerid,166);
		    case 5:SetPlayerSkin(playerid,285);
		}
	    return 1;
	}
	clear4msg(playerid,0);
	GameTextForPlayer(playerid,maps[atmmap][name],2000,1);
	//openplayermenu(playerid);
	GameTextForPlayer(playerid,"Oeffne per ~r~~k~~VEHICLE_ENTER_EXIT~~y~ das Menue",4000,3);
	new spid = random(maps[atmmap][spawns]);
	while(mapspawn[atmmap][0][spid] == 0.0)
	{
	    spid = random(maps[atmmap][spawns]);
	}
	SetPlayerPos(playerid,mapspawn[atmmap][0][spid],mapspawn[atmmap][1][spid],mapspawn[atmmap][2][spid]);
	SetPlayerHealth(playerid,1000.0);

	switch(GetPVarInt(playerid,"skin"))
	{
	    case 0:SetPlayerSkin(playerid,123);
	    case 1:SetPlayerSkin(playerid,111);
	    case 2:SetPlayerSkin(playerid,127);
	    case 3:SetPlayerSkin(playerid,165);
	    case 4:SetPlayerSkin(playerid,166);
	    case 5:SetPlayerSkin(playerid,285);
	}

	pickrandomtarget(playerid);
	triggerachiv(playerid,42);
	SetPlayerWorldBounds(playerid,maps[atmmap][maxx],maps[atmmap][minx],maps[atmmap][maxy],maps[atmmap][miny]);
	return 1;
}

forward pickrandomtarget(playerid);
public pickrandomtarget(playerid)
{
    for(new sort=0;sort!=50;sort++)
	{
		for(new ranp=0;ranp!=slots;ranp++)
		{
		    if(IsPlayerConnected(ranp) && !IsPlayerNPC(ranp) && ranp != playerid)
		    {
		        if(GetPVarInt(ranp,"verfolger") == sort)
		        {
		            addverfolger(ranp,playerid);
		            break;
		        }
		    }
		}
	}
	return SendClientMessage(playerid,COLOR_RED,"Du bist alleine");
}

forward addverfolger(opfer,hunter);
public addverfolger(opfer,hunter)
{
	GameTextForPlayer(opfer,"Ein neuer ~r~Verfolger",1000,3);
	GameTextForPlayer(hunter,"Neues ~r~Ziel",1000,3);
	triggerachiv(opfer,43);
	for(new hid=1;hid<=5;hid++) TextDrawHideForPlayer(hunter,txtdraws[hid]);
	switch(GetPlayerSkin(opfer))
	{
		case 123:TextDrawShowForPlayer(hunter,txtdraws[1]);
		case 111:TextDrawShowForPlayer(hunter,txtdraws[2]);
		case 127:TextDrawShowForPlayer(hunter,txtdraws[6]);
		case 165:TextDrawShowForPlayer(hunter,txtdraws[3]);
		case 166:TextDrawShowForPlayer(hunter,txtdraws[4]);
		case 285:TextDrawShowForPlayer(hunter,txtdraws[5]);
	}
	GameTextForPlayer(hunter,"Toete dein ~r~Ziel",1000,3);
	SetPVarInt(opfer,"verfolger",GetPVarInt(opfer,"verfolger")+1);
	SetPVarInt(hunter,"ziel",opfer);
	
	KillTimer(GetPVarInt(hunter,"tiptimer"));
	SetPVarInt(hunter,"tiptimer",SetTimerEx("hint",2000,0,"ii",hunter,opfer));
	return 1;
}

forward hint(playerid,opfer);
public hint(playerid,opfer)
{
    if(!IsPlayerConnected(opfer)) return pickrandomtarget(playerid);
	
	new Float:gph[6];
	GetPlayerPos(opfer,gph[0],gph[1],gph[2]);
	GetPlayerPos(playerid,gph[3],gph[4],gph[5]);
	
	RemovePlayerMapIcon(playerid,opfer);
	SetPlayerMapIcon(playerid,opfer,gph[0],gph[1],gph[2],23,0,MAPICON_GLOBAL);
	
	KillTimer(GetPVarInt(playerid,"tiptimer"));
	SetPVarInt(playerid,"tiptimer",SetTimerEx("hint",floatround(GetDistance(gph[0],gph[1],gph[2],gph[3],gph[4],gph[5])*100),0,"ii",playerid,opfer));

	new gkh[3];
	GetPlayerKeys(playerid,gkh[0],gkh[1],gkh[2]);
	
	if((gkh[1] != 0 || gkh[2] != 0) && !(gkh[0] & KEY_WALK))
	{
	    if(gkh[0] & KEY_SPRINT)
	    {
	        SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
	        GameTextForPlayer(playerid,"~r~Laufen~w~ ist sehr auffaellig",2000,3);
		}
		else
		{
			SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+1);
	    	GameTextForPlayer(playerid,"~r~Joggen~w~ ist auffaellig",2000,3);
		}
	}
	
	if(GetPlayerWantedLevel(playerid) > 0)
	{
	    triggerachiv(playerid,47);
		SetPlayerDrunkLevel(playerid,GetPlayerWantedLevel(playerid)*8000+2000);
		Delete3DTextLabel(dishide[playerid]);
		dishide[playerid] = Create3DTextLabel("Assassine",COLOR_RED,0,0,0,GetPlayerWantedLevel(playerid)*5,0,0);
		Attach3DTextLabelToPlayer(dishide[playerid],playerid,0,0,1);
	}

	return 1;
}

forward openplayermenu(playerid);
public openplayermenu(playerid)
{
	//return 1;
	return EUM_ShowForPlayer(playerid, 1, "Was tun?","1. Aussehen aendern~n~2. Faehigkeiten aendern~n~~n~3. Hilfe~n~4. Credits~n~5. Auszeichnungen",5);
}

forward clear4msg(playerid,lines);
public clear4msg(playerid,lines)
{
	for(new o=0;o!=10-lines;o++) SendClientMessage(playerid,COLOR_GREY," ");
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(record,6,cmdtext);
	dcmd(ae,2,cmdtext);
	dcmd(gmx,3,cmdtext);
	return 1;
}

dcmd_gmx(playerid,params[])
{
    #pragma unused params
    if(GetPVarInt(playerid,"admlvl") < 3) return 0;
	for(new go=0;go!=slots;go++) if(IsPlayerConnected(go) && !IsPlayerNPC(go)) savestats(go);
	GameModeExit();
	return 1;
}

dcmd_ae(playerid,params[])
{
    if(GetPVarInt(playerid,"admlvl") < 3) return 0;
    
    addexp(playerid,strval(params));
	GameTextForPlayer(playerid,"added",1000,3);
	return 1;
}
    
dcmd_record(playerid,params[])
{
	#pragma unused params
	if(GetPVarInt(playerid,"admlvl") < 3) return 0;
	if(GetPVarInt(playerid,"reco") == 1)
	{
		StopRecordingPlayerData(playerid);
		SetPVarInt(playerid,"reco",0);
	    return GameTextForPlayer(playerid,"STOP",1000,3);
	}
	new recn[128];
	for(new find=0;find<=100;find++)
	{
		format(recn,128,"map%drunner%d",atmmap,find);
		if(!fexist(recn))
		{
            StartRecordingPlayerData(playerid,2,recn);
            SetPVarInt(playerid,"reco",1);
            return GameTextForPlayer(playerid,"GO",1000,3);
		}
	}
	

	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
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

forward cooldown(playerid,ef);
public cooldown(playerid,ef)
{
	switch(ef)
	{
	    case 0:SetPVarInt(playerid,"markcool",0);
	    case 1:
		{
			SetPVarInt(playerid,"skill1cool",0);
			GameTextForPlayer(playerid,"Skill 1 kann wieder verwendet werden",1000,3);
		}
		case 2:
		{
			SetPVarInt(playerid,"skill2cool",0);
			GameTextForPlayer(playerid,"Skill 2 kann wieder verwendet werden",1000,3);
		}
		case 3:
		{
		    switch(GetPVarInt(playerid,"skin"))
			{
			    case 0:SetPlayerSkin(playerid,123);
			    case 1:SetPlayerSkin(playerid,111);
			    case 2:SetPlayerSkin(playerid,127);
			    case 3:SetPlayerSkin(playerid,165);
			    case 4:SetPlayerSkin(playerid,166);
			    case 5:SetPlayerSkin(playerid,285);
			}
		}
		case 4:
		{
		    for(new suc=0;suc!=slots;suc++)if(IsPlayerConnected(suc) && !IsPlayerNPC(suc)) DeletePlayer3DTextLabel(playerid,templerbl[playerid][suc]);
		}
		case 5: TextDrawHideForPlayer(playerid,txtdraws[7]);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	/*
	new form[16];
	format(form,16,"%d",newkeys);
	GameTextForPlayer(playerid,form,500,3);
	*/
	new anvippl = GetPVarInt(playerid,"anvi");
	
	if(newkeys & KEY_SECONDARY_ATTACK)
	{
	    if(newkeys & KEY_LOOK_BEHIND)
	    {
	        return useskill(playerid,1);
	    }
	    else
	    {
	        if(GetPVarInt(playerid,"markcool") == 1) return 0;
	        SetPVarInt(playerid,"markcool",1);
	        SetTimerEx("cooldown",500,0,"ii",playerid,0);
	        
		    new Float:chp[3];
		    for(new i=0;i<=slots;i++)
		    {
		        if(IsPlayerConnected(i) && i != playerid)
		        {
		            GetPlayerPos(i,chp[0],chp[1],chp[2]);
		        	if(IsPlayerAimingAt(playerid,chp[0],chp[1],chp[2],1.0))
		        	{
		        	    SetPVarInt(playerid,"anvi",i);
		        	    anvippl = i;
		        	    DeletePlayer3DTextLabel(playerid,anvi[playerid]);
						anvi[playerid] = CreatePlayer3DTextLabel(playerid,"Ziel erfasst",COLOR_RED,0,0,0,500.0,i,INVALID_VEHICLE_ID,0);
		        		break;
		        	}
				}
		    }
		}
	}
	
	if(newkeys & KEY_FIRE)
	{
	    if(!IsPlayerConnected(anvippl))
		{
			GameTextForPlayer(playerid,"Kein Ziel anvisiert",1000,3);
			TogglePlayerControllable(playerid,0);
			TogglePlayerControllable(playerid,1);
			return 0;
		}
	    attentat(playerid,anvippl);
	    triggerachiv(playerid,46);
	    return 0;
	}
	
	if(newkeys & 16) return openplayermenu(playerid);
	
	if(newkeys & KEY_LOOK_BEHIND) return useskill(playerid,0);
	
	return 1;
}

forward useskill(playerid,id);
public useskill(playerid,id)
{
	if(skillsett[playerid][id] == -1) return GameTextForPlayer(playerid,"Keinen Skill ausgeruestet",1000,3);
	if(skill[skillsett[playerid][id]][level] > getlevel(playerid)) return 0;
	if(skillsett[playerid][id] == 1)
	{
		if(GetPVarInt(playerid,"skill1cool") == 1) return GameTextForPlayer(playerid,"Skill kann noch nicht benutzt werden",1000,3);
		else
		{
			SetPVarInt(playerid,"skill1cool",1);
			SetTimerEx("cooldown",15000,0,"ii",playerid,1);
		}
	}
	else
	{
	    if(GetPVarInt(playerid,"skill2cool") == 1) return GameTextForPlayer(playerid,"Skill kann noch nicht benutzt werden",1000,3);
		else
		{
			SetPVarInt(playerid,"skill2cool",1);
			SetTimerEx("cooldown",15000,0,"ii",playerid,2);
		}
	}
	
	new anvippl = GetPVarInt(playerid,"anvi");
	
	/*
	AddSkill(0,"Tarnung","Verwandle dich kurzweilig in jemand andres",2);
	AddSkill(1,"Trubel","Verwandle Passanten in dich",3);
	AddSkill(2,"Pistole","Töte Gegner aus der Entfernung",4);
	AddSkill(3,"Knallkörper","Filtere und blende Assassinen aus der Menge heraus",6);
	AddSkill(4,"Rauchbombe","Betäub Assassinen",8);
	AddSkill(5,"Templerblick","Erkenne Assassinen",10);
	AddSkill(6,"Gift","Töte ein Opfer mit Verzögerung",13);
	AddSkill(7,"Großer Trubel","Verwandle viele Passanten in dich",15);
	AddSkill(8,"Sniper","Töte Gegner aus großer Entfernung",17);
	AddSkill(9,"Starke Rauchbombe","Betäub Assassinen länger",20);
	AddSkill(10,"Langsames Gift","Töte einen Gegner mit viel Verzögerung",25);
	11 = langer templerblick
	*/
	
	switch(id)
	{
	    case 0:
	    {
	        switch(random(6))
			{
			    case 0:SetPlayerSkin(playerid,123);
			    case 1:SetPlayerSkin(playerid,111);
			    case 2:SetPlayerSkin(playerid,127);
			    case 3:SetPlayerSkin(playerid,165);
			    case 4:SetPlayerSkin(playerid,166);
			    case 5:SetPlayerSkin(playerid,285);
			}
	        SetTimerEx("cooldown",15000,0,"ii",playerid,3);
	        triggerachiv(playerid,49);
	    }
	    case 1:
	    {
	        new Float:gfu[3];
	        GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
	        triggerachiv(playerid,50);
	        for(new su=0;su<=slots;su++) if(IsPlayerNPC(su) && IsPlayerInRangeOfPoint(su,7.5,gfu[0],gfu[1],gfu[2])) SetPlayerSkin(su,GetPlayerSkin(playerid));
	    }
	    case 2:
	    {
	        if(!IsPlayerConnected(anvippl)) return GameTextForPlayer(playerid,"Du musst zuerst jemanden anvisieren",1000,3);
	        new Float:gph[6];
			GetPlayerPos(anvippl,gph[0],gph[1],gph[2]);
			GetPlayerPos(playerid,gph[3],gph[4],gph[5]);
	        if(GetDistance(gph[0],gph[1],gph[2],gph[3],gph[4],gph[5]) > 15) return GameTextForPlayer(playerid,"Ziel zu weit entfernt",1000,3);

            TextDrawShowForPlayer(playerid,txtdraws[0]);
			TextDrawShowForPlayer(playerid,txtdraws[6]);
			TextDrawShowForPlayer(anvippl,txtdraws[0]);
			TextDrawShowForPlayer(anvippl,txtdraws[1]);

            triggerachiv(playerid,51);

			GivePlayerWeapon(playerid,23,1);
	        PlayerPlaySound(playerid,1132,gph[3],gph[4],gph[5]);
	        PlayerPlaySound(anvippl,1132,gph[3],gph[4],gph[5]);
	        ApplyAnimation(anvippl,"fight_d","HitD_3",3,0,1,1,1,0);
	        
	        SetTimerEx("att_over",1200,0,"ii",playerid,anvippl);
	        
		    if(IsPlayerNPC(anvippl))
			{
				GameTextForPlayer(playerid,"Du hast einen ~r~Zivilisten~w~ getroffen",3000,3);
				SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
				triggerachiv(playerid,47);
				return 1;
    		}

			if(anvippl != GetPVarInt(playerid,"ziel"))
			{
				if(GetPVarInt(anvippl,"ziel") == playerid)
			    {
			    	triggerachiv(playerid,48);
			        GameTextForPlayer(playerid,"Du hast einen ~g~Verfolger~w~ getroffen~n~~y~+200 EXP",2000,3);
			        return addexp(playerid,200);
			    }
			    else
			    {
			    	GameTextForPlayer(playerid,"Du hast den ~r~falschen~w~ Assassinen getroffen",3000,3);
					SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
					triggerachiv(playerid,47);
					return 1;
				}
    		}
			else
			{
				addexp(playerid,100);

				format(mysqlquery[playerid],256,"Du hast das ~g~Ziel~w~ getroffen~n~+%d EXP",100);
				GameTextForPlayer(playerid,mysqlquery[playerid],2000,3);
				return 1;
		    }
	    }
	    case 3:
	    {
	        new Float:gfu[3];
	        GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
	        SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+1);
	        triggerachiv(playerid,52);
			for(new suc=0;suc!=slots;suc++)
			{
			    if(IsPlayerConnected(suc) && !IsPlayerNPC(suc) && IsPlayerInRangeOfPoint(suc,7.5,gfu[0],gfu[1],gfu[2]))
			    {
			        TextDrawShowForPlayer(suc,txtdraws[7]);
			        SetTimerEx("cooldown",4000,0,"ii",playerid,5);
			        GameTextForPlayer(suc,"Du wurdest ~r~geblendet",4000,3);
				}
			}
	    }
	    case 4:
	    {
	        new Float:gfu[3];
	        GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
	        triggerachiv(playerid,53);
			for(new suc=0;suc!=slots;suc++) if(IsPlayerConnected(suc) && !IsPlayerNPC(suc) && IsPlayerInRangeOfPoint(suc,7.5,gfu[0],gfu[1],gfu[2]) && suc != playerid) ApplyAnimation(suc,"ped","gas_cwr",4.2,1,1,1,0,5000,1);
	    }
	    case 5:
	    {
            triggerachiv(playerid,54);
	    
	        for(new suc=0;suc!=slots;suc++)
			{
			    if(IsPlayerConnected(suc) && !IsPlayerNPC(suc))
			    {
			        templerbl[playerid][suc] = CreatePlayer3DTextLabel(playerid,"Assassine",COLOR_GREY,0,0,0,50.0,suc,INVALID_VEHICLE_ID,1);
				}
	        }
	        SetTimerEx("cooldown",3000,0,"ii",playerid,4);
	    }
	    case 6:
	    {
	        if(!IsPlayerConnected(anvippl)) return GameTextForPlayer(playerid,"Du musst zuerst jemanden anvisieren",1000,3);

            new Float:gph[6];
			GetPlayerPos(anvippl,gph[0],gph[1],gph[2]);
			GetPlayerPos(playerid,gph[3],gph[4],gph[5]);
	        if(GetDistance(gph[0],gph[1],gph[2],gph[3],gph[4],gph[5]) > 1) return GameTextForPlayer(playerid,"Ziel zu weit entfernt",1000,3);

			SetTimerEx("giftgo",5000,0,"iii",playerid,anvippl,1);

			triggerachiv(playerid,55);
	    }
	    case 7:
	    {
			new Float:gfu[3];
	        GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
	        for(new su=0;su<=slots;su++) if(IsPlayerNPC(su) && IsPlayerInRangeOfPoint(su,15.0,gfu[0],gfu[1],gfu[2])) SetPlayerSkin(su,GetPlayerSkin(playerid));
	    }
	    case 8:
	    {
	        if(!IsPlayerConnected(anvippl)) return GameTextForPlayer(playerid,"Du musst zuerst jemanden anvisieren",1000,3);
	        new Float:gph[6];
			GetPlayerPos(anvippl,gph[0],gph[1],gph[2]);
			GetPlayerPos(playerid,gph[3],gph[4],gph[5]);
	        if(GetDistance(gph[0],gph[1],gph[2],gph[3],gph[4],gph[5]) > 30) return GameTextForPlayer(playerid,"Ziel zu weit entfernt",1000,3);

            TextDrawShowForPlayer(playerid,txtdraws[0]);
			TextDrawShowForPlayer(playerid,txtdraws[6]);
			TextDrawShowForPlayer(anvippl,txtdraws[0]);
			TextDrawShowForPlayer(anvippl,txtdraws[1]);

			GivePlayerWeapon(playerid,23,1);
	        PlayerPlaySound(playerid,1132,gph[3],gph[4],gph[5]);
	        PlayerPlaySound(anvippl,1132,gph[3],gph[4],gph[5]);
	        ApplyAnimation(anvippl,"fight_d","HitD_3",3,0,1,1,1,0);

	        SetTimerEx("att_over",1200,0,"ii",playerid,anvippl);

		    if(IsPlayerNPC(anvippl))
			{
				GameTextForPlayer(playerid,"Du hast einen ~r~Zivilisten~w~ getroffen",3000,3);
				SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
				triggerachiv(playerid,47);
				return 1;
    		}

			if(anvippl != GetPVarInt(playerid,"ziel"))
			{
				if(GetPVarInt(anvippl,"ziel") == playerid)
			    {
			    	triggerachiv(playerid,48);
			        GameTextForPlayer(playerid,"Du hast einen ~g~Verfolger~w~ getroffen~n~~y~+200 EXP",2000,3);
			        return addexp(playerid,200);
			    }
			    else
			    {
			    	GameTextForPlayer(playerid,"Du hast den ~r~falschen~w~ Assassinen getroffen",3000,3);
					SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
					triggerachiv(playerid,47);
					return 1;
				}
    		}
			else
			{
				addexp(playerid,100);

				format(mysqlquery[playerid],256,"Du hast das ~g~Ziel~w~ getroffen~n~+%d EXP",100);
				GameTextForPlayer(playerid,mysqlquery[playerid],2000,3);
				return 1;
		    }
	    }
	    case 9:
	    {
	        new Float:gfu[3];
	        GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
			for(new suc=0;suc!=slots;suc++) if(IsPlayerConnected(suc) && !IsPlayerNPC(suc) && suc != playerid && IsPlayerInRangeOfPoint(suc,7.5,gfu[0],gfu[1],gfu[2])) ApplyAnimation(suc,"ped","gas_cwr",4.2,1,1,1,0,10000,1);
	    }
	    case 10:
	    {
	        if(!IsPlayerConnected(anvippl)) return GameTextForPlayer(playerid,"Du musst zuerst jemanden anvisieren",1000,3);

            new Float:gph[6];
			GetPlayerPos(anvippl,gph[0],gph[1],gph[2]);
			GetPlayerPos(playerid,gph[3],gph[4],gph[5]);
	        if(GetDistance(gph[0],gph[1],gph[2],gph[3],gph[4],gph[5]) > 1) return GameTextForPlayer(playerid,"Ziel zu weit entfernt",1000,3);

			SetTimerEx("giftgo",10000,0,"iii",playerid,anvippl,2);
	    }
	    case 11:
	    {
	        for(new suc=0;suc!=slots;suc++)
			{
			    if(IsPlayerConnected(suc) && !IsPlayerNPC(suc))
			    {
			        templerbl[playerid][suc] = CreatePlayer3DTextLabel(playerid,"Assassine",COLOR_GREY,0,0,0,100.0,suc,INVALID_VEHICLE_ID,1);
				}
	        }
	        SetTimerEx("cooldown",6000,0,"ii",playerid,4);
	    }
	}

	return GameTextForPlayer(playerid,skill[id][name],1000,3);
}

forward giftgo(playerid,opfer,id);
public giftgo(playerid,opfer,id)
{
    SetTimerEx("att_over",2000,0,"ii",playerid,opfer);
    
    TextDrawShowForPlayer(opfer,txtdraws[0]);
	TextDrawShowForPlayer(opfer,txtdraws[1]);
    ApplyAnimation(opfer,"fight_d","HitD_3",3,0,1,1,1,0);

    if(IsPlayerNPC(opfer))
    {
		GameTextForPlayer(playerid,"Du hast einen ~r~Zivilisten~w~ getroffen",3000,3);
		SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
		triggerachiv(playerid,47);
		return 1;
    }

    if(opfer != GetPVarInt(playerid,"ziel"))
    {
        if(GetPVarInt(opfer,"ziel") == playerid)
        {
            triggerachiv(playerid,48);
            GameTextForPlayer(playerid,"Du hast einen ~g~Verfolger~w~ getroffen~n~~y~+200 EXP",2000,3);
            return addexp(playerid,200);
        }
        else
        {
            GameTextForPlayer(playerid,"Du hast den ~r~falschen~w~ Assassinen getroffen",3000,3);
			SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
			triggerachiv(playerid,47);
			return 1;
        }
    }
    else
    {
		new gixp;
        switch(GetPlayerWantedLevel(playerid))
		{
			case 0:gixp = 400;
			case 1:gixp = 200;
			case 2..6:gixp = 50;
		}
		gixp += id*100;
		addexp(playerid,gixp);
		format(mysqlquery[playerid],256,"Du hast das ~g~Ziel~w~ getroffen~n~+%d EXP",gixp);
		GameTextForPlayer(playerid,mysqlquery[playerid],2000,3);
		return 1;
    }
}


forward attentat(playerid,opfer);
public attentat(playerid,opfer)
{
	TextDrawShowForPlayer(playerid,txtdraws[0]);
	TextDrawShowForPlayer(playerid,txtdraws[6]);
	TextDrawShowForPlayer(opfer,txtdraws[0]);
	TextDrawShowForPlayer(opfer,txtdraws[1]);
	
	new Float:atp[3];
	GetPlayerPos(opfer,atp[0],atp[1],atp[2]);
	
	SetPlayerPos(playerid,atp[0]+1,atp[1],atp[2]);
	SetPlayerFacingAngle(playerid,270.0);
	SetPlayerFacingAngle(opfer,90.0);
	
	switch(random(3))
	{
	    case 0:
	    {
	        ApplyAnimation(playerid,"FIGHT_D","FightD_3",3,0,1,1,1,0,1);
	        ApplyAnimation(opfer,"FIGHT_D","HitD_3",3,0,1,1,1,0,1);
	    }
	    case 1:
	    {
	        ApplyAnimation(playerid,"FIGHT_B","FightB_3",3,0,1,1,1,0,1);
	        ApplyAnimation(opfer,"FIGHT_B","HitB_3",3,0,1,1,1,0,1);
	    }
	    case 2:
	    {
	        ApplyAnimation(playerid,"FIGHT_C","FightC_3",3,0,1,1,1,0,1);
	        ApplyAnimation(opfer,"FIGHT_C","HitC_3",3,0,1,1,1,0,1);
	    }
	}
	SetTimerEx("att_over",1200,0,"ii",playerid,opfer);
	
 	if(IsPlayerNPC(opfer))
    {
		GameTextForPlayer(playerid,"Du hast einen ~r~Zivilisten~w~ getroffen",3000,3);
		SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
		triggerachiv(playerid,47);
		return 1;
    }
    
    if(opfer != GetPVarInt(playerid,"ziel"))
    {
        if(GetPVarInt(opfer,"ziel") == playerid)
        {
            triggerachiv(playerid,48);
            GameTextForPlayer(playerid,"Du hast einen ~g~Verfolger~w~ getroffen~n~~y~+200 EXP",2000,3);
            return addexp(playerid,200);
        }
        else
        {
            GameTextForPlayer(playerid,"Du hast den ~r~falschen~w~ Assassinen getroffen",3000,3);
			SetPlayerWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
			triggerachiv(playerid,47);
			return 1;
        }
    }
    else
    {
		new gixp;
        switch(GetPlayerWantedLevel(playerid))
		{
			case 0:gixp = 400;
			case 1:gixp = 200;
			case 2..6:gixp = 50;
		}
		addexp(playerid,gixp);
		format(mysqlquery[playerid],256,"Du hast das ~g~Ziel~w~ getroffen~n~+%d EXP",gixp);
		GameTextForPlayer(playerid,mysqlquery[playerid],2000,3);
		return 1;
    }
}

forward att_over(playerid,opfer);
public att_over(playerid,opfer)
{
	ResetPlayerWeapons(playerid);

	ClearAnimations(playerid,1);
	ClearAnimations(opfer,1);

    pickrandomtarget(playerid);
    if(!IsPlayerNPC(opfer)) pickrandomtarget(opfer);
	
	TextDrawHideForPlayer(playerid,txtdraws[0]);
	TextDrawHideForPlayer(playerid,txtdraws[1]);
	TextDrawHideForPlayer(opfer,txtdraws[0]);
	TextDrawHideForPlayer(opfer,txtdraws[1]);

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
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

forward savestats(playerid);
public savestats(playerid)
{
	if(GetPVarInt(playerid,"exp") == 0) return 0;
	GetPlayerName(playerid,player_name[playerid],16);
    format(mysqlquery[playerid],256,"UPDATE acb_stat SET exp = '%d', skillsetting = '%d|%d' WHERE name = '%s'",GetPVarInt(playerid,"exp"),skillsett[playerid][0],skillsett[playerid][1],player_name[playerid]);
    mysql_query(mysqlquery[playerid]);
	return 1;
}

forward addexp(playerid,exp);
public addexp(playerid,exp) //markme
{
	SetPVarInt(playerid,"exp",GetPVarInt(playerid,"exp")+exp);
	
	ShowProgressBarForPlayer(playerid, expbar[playerid]);
	
	for(new cha=5;cha<=5^25;cha=cha*2)
	{
	    if(GetPVarInt(playerid,"exp") < cha*100)
	    {
	        SetProgressBarMaxValue(expbar[playerid],cha*100*2);
	        SetProgressBarValue(expbar[playerid],GetPVarInt(playerid,"exp"));
	        UpdateProgressBar(expbar[playerid]);
	        return 1;
	    }
	}
	

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response && (dialogid == 1 || dialogid == 2)) return Kick(playerid);
	switch(dialogid)
	{
	    case 177: if(response) return ShowPlayerDialog(playerid,178,0,"Das HUD","Unten links beim Radar siehst du verschiedene Anzeigen\nDer Text beschreibt deine Zielperson\nDie rote Zahl ist die Anzahl deiner Verfolger\nAuf dem Radar siehst du ein Symbol, wo dein Opfer gesichtet wurde\nJe näher du deinem Ziel kommst, desto öfter aktualisiert sich dieses\n\nNächste Seite:  Heimlichkeit","Weiter","Abbrechen");
        case 178: if(response) return ShowPlayerDialog(playerid,179,0,"Heimlichkeit","Es ist wichtig, dass du in der Menge untertauchst\nWenn du joggst oder rennst, erhöht sich deine Sichtbarkeit,\nmarkiert durch Sterne oben rechts\nMit steugender Auffälligkeit sehen Gegner dich schon von weitem,\nund deine Wahrnehmung lässt nach\n\nNächste Seite: Steuerung","Weiter","Abbrechen");
        case 179: if(response) return ShowPlayerDialog(playerid,180,0,"Steuerung","Legende: Taste (Funktion) - Effekt\n\nALT (Gehen) - Unauffällig fortbewegen\nLMouse (Attacke) - Attentat durchführen\nRMouse (Zielen) - Opfer selektieren\nMausrad (Nach hinten sehen) - Skill aus Slot 1 einsetzen\nMausrad + RMouse - Skill aus Slot 2 einsetzen","Beenden","");
		case 180: return triggerachiv(playerid,44);
		case 4:
	    {
	        if(!response) return 0;
	        new owl2 = getlevel(playerid),rlid = -1;
	        for(new gets=0;gets!=skillcount;gets++)
			{
				if(!strcmp(inputtext,skill[gets][name]))
				{
				    rlid = gets;
				    break;
				}
			}
			if(rlid == -1) return 0;
			if(skill[listitem][level] > owl2)
			{
			    format(mysqlquery[playerid],256,"Du bekommst diese Fähigkeit erst mit Level %d",skill[rlid][level]);
			    SendClientMessage(playerid,COLOR_GREY,mysqlquery[playerid]);
			    return showskills(playerid);
			}
			SetPVarInt(playerid,"selectedskill",listitem);
	        return ShowPlayerDialog(playerid,5,0,skill[listitem][name],skill[listitem][beschreibung],"Nehmen","Zurück");
	    }
	    case 5:
	    {
	        if(!response) return showskills(playerid);
	        format(mysqlquery[playerid],256,"Welcher Slot soll freigemacht werden ?\n\n1 = %s\n2 = %s",skill[skillsett[playerid][0]][name],skill[skillsett[playerid][1]][name]);
	        ShowPlayerDialog(playerid,6,0,"Skill nehmen",mysqlquery[playerid],"1","2");
	        return 1;
	    }
	    case 6:
	    {
	        skillsett[playerid][response] = GetPVarInt(playerid,"selectedskill");
	        return showskills(playerid);
	    }
	    case 3: if(response)
		{
		    triggerachiv(playerid,45);
			return SetPVarInt(playerid,"skin",listitem);
		}
	    case 911: //auszeichnungen
        {
            if(!response) return 0;
            new ffield[256];
            strdel(inputtext,0,strfind(inputtext,"}")+1);
            format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE titel = '%s'",inputtext);
            mysql_query(mysqlquery[playerid]);
            mysql_store_result();
            mysql_fetch_field("string",ffield);
            mysql_free_result();
            ShowPlayerDialog(playerid,910,0,inputtext,ffield,"Zurück","Schließen");
            return 1;
        }
        case 910:
        {
            if(response) return showachiv(playerid);
        }
		case 1: //register
	    {
	        if(!strlen(inputtext)) return ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Bitte gib ein geheimes Passwort ein:","Registrieren","");
			GetPlayerName(playerid,player_name[playerid],16);
			
			format(mysqlquery[playerid],256,"INSERT INTO acb_stat (name,exp,skillsetting,admlvl) VALUES ('%s','0','0|0','0')",player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
			
			SetPVarInt(playerid,"loggedin",1);

            skillsett[playerid][0] = -1,skillsett[playerid][1] = -1;
            
			switch(GetPVarInt(playerid,"admlvl"))
			{
			    case 1:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Supporter");
			    case 2:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Moderator");
			    case 3:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Skripter");
			}

	        new output1[128];
			format(output1,sizeof(output1),"%s hat den Server betreten",player_name[playerid]);
			SendClientMessageToAll(COLOR_GREY,output1);
			//SetTimerEx("forcespawn",2000,0,"i",playerid);
			return 1;
		}
		case 2: //login
		{
		    if(!strlen(inputtext)) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Du hast ein falsches Passwort eingegeben !\n\nVersuch es noch einmal:","Absenden","");
		    GetPlayerName(playerid,player_name[playerid],16);
			new tmpoutput5[128];
		    format(mysqlquery[playerid],256,"SELECT pw FROM login WHERE name = '%s'",player_name[playerid]);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			if(mysql_fetch_field("pw",tmpoutput5))
			{
		        if(!strcmp(tmpoutput5,inputtext))
		        {
		            format(mysqlquery[playerid],256,"SELECT * FROM acb_stat WHERE name = '%s'",player_name[playerid]);
					mysql_query(mysqlquery[playerid]);
					mysql_store_result();
					new tmpoutput[128];
					mysql_fetch_field("admlvl",tmpoutput);
					SetPVarInt(playerid,"admlvl",strval(tmpoutput));
					switch(GetPVarInt(playerid,"admlvl"))
					{
					    case 1:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Supporter");
					    case 2:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Moderator");
					    case 3:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Skripter");
					}
					mysql_fetch_field("exp",tmpoutput);
					SetPVarInt(playerid,"exp",strval(tmpoutput));
					addexp(playerid,GetPVarInt(playerid,"exp"));
					mysql_fetch_field("skillsetting",tmpoutput);
					new transf[2];
					strmid(transf,tmpoutput,2,0,strfind(tmpoutput,"|"));
					skillsett[playerid][0] = strval(transf);
					strmid(transf,tmpoutput,2,strfind(tmpoutput,"|")+1,strlen(tmpoutput));
					skillsett[playerid][1] = strval(transf);
					mysql_free_result();
		        }
		        else
				{
					ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Falsches Passwort","Du hast ein falsches Passwort eingegeben !\n\nVersuch es noch einmal:","Absenden","");
	    			mysql_free_result();
					return 0;
				}
			}
			mysql_free_result();

			new output1[128];
			GetPlayerName(playerid,player_name[playerid],16);
			format(output1,sizeof(output1),"%s hat den Server betreten",player_name[playerid]);
		    SendClientMessageToAll(COLOR_GREY,output1);
		    //SetTimerEx("forcespawn",500,0,"i",playerid);
		    return 1;
		}
	}
	return 1;
}

forward forcespawn(playerid);
public forcespawn(playerid)
{
	if(GetPlayerState(playerid) == 2 || GetPlayerState(playerid) == 1) return 0;
	SetTimerEx("forcespawn",750,0,"i",playerid);
	return SpawnPlayer(playerid);
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
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
	for(new i=41;i<=100;i++)
	{
		pos[0] = i-1;
		pos[1] = i;
		strmid(mid,ids,pos[0],pos[1]);
        format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE nummer = '%d' AND server='3'",i);
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
	ShowPlayerDialog(playerid,911,2,"Auszeichnungen",endstring,"Ansehen","Schließen");
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
			format(ffield,256,"%s hat die Auszeichnung '%s' erhalten",player_name[playerid],tit);
			SendClientMessageToAll(COLOR_GREEN,ffield);
			break;
		}
	}
	format(tlong,512,"UPDATE achievements SET achievements = '%s' WHERE name = '%s'",ids,player_name[playerid]);
	mysql_query(tlong);

	return 1;
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
