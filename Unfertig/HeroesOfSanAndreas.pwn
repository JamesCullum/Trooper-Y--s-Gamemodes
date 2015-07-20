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
#include <MapAndreas>
#include <rotation>

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define slots 100
#define maps 5

new Text:choosechar[5][slots],mysqlquery[1024][slots],actualchosenskin[slots],Text:menu1[3][slots],menu1pos[slots],menu1marker[slots];
new menukeys[3][slots],menu1options[5],gotskill[slots][2][5];

enum pldetails
{
	seria[1024],
	tree1,
	tree2,
	tree3, //wird nich benutzt
	alvl,
	klasse,
	exp,
	lvl
}
new player[slots][pldetails];

new Float:mapspawn[15][4] = {
{2265.7600,1675.7874,1090.4453,273.2760}, //2sides t1
{2264.7490,1619.7156,1090.4453,265.8775}, //2sides t2
{2144.2014,1637.1195,993.5761,180.1215}, //caligula t1
{2234.2031,1711.7361,1011.6102,180.4583}, //caligula t2
{1733.6979,-1660.0974,20.2435,15.9801}, //atrium ffa
{1706.9520,-1672.1469,20.2244,5.6634},
{1733.5280,-1641.9490,23.7508,183.0117},
{1709.7881,-1656.1887,23.6953,350.3099},
{1711.0868,-1644.0629,27.2031,226.0604}, //bis hier
{2541.1904,-1318.8124,1031.4219,86.7704}, //crackpal t1
{2538.2844,-1295.5935,1044.1250,262.2154}, //crackpal t2
{2215.9038,-1150.4285,1025.7969,272.2892}, //jefferson t1
{2193.0542,-1147.4236,1033.7969,3.9049} //jefferson t2
};

main()
{
}

public OnGameModeInit()
{
    menu1options[0] = 2,menu1options[1] = 2,menu1options[2] = 2,menu1options[3] = 9;

    MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
    AllowAdminTeleport(1);
    EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	
	mysql_connect("xxx", "xxx", "xxx", "xxx");
	SetTimer("nodrop",60000*10,0);

    AddPlayerClass(50, 1242.3011,-819.4758,1083.1563,178.1433, 0, 0, 0, 0, 0, 0); //ingenieur
    AddPlayerClass(81, 1242.3011,-819.4758,1083.1563,178.1433, 0, 0, 0, 0, 0, 0); //berserker
    AddPlayerClass(285, 1242.3011,-819.4758,1083.1563,178.1433, 0, 0, 0, 0, 0, 0); //assassine
    AddPlayerClass(1, 1242.3011,-819.4758,1083.1563,178.1433, 0, 0, 0, 0, 0, 0); //schamane
    
    SetGameModeText("(c) Nicksoft");

	choosechar[0][0] = TextDrawCreate(0.000000, 1.000000, "1");
	TextDrawBackgroundColor(choosechar[0][0], 255);
	TextDrawFont(choosechar[0][0], 1);
	TextDrawLetterSize(choosechar[0][0], 2.899999, 18.000000);
	TextDrawColor(choosechar[0][0], 255);
	TextDrawSetOutline(choosechar[0][0], 0);
	TextDrawSetProportional(choosechar[0][0], 1);
	TextDrawSetShadow(choosechar[0][0], 1);
	TextDrawUseBox(choosechar[0][0], 1);
	TextDrawBoxColor(choosechar[0][0], 255);
	TextDrawTextSize(choosechar[0][0], 640.000000, 0.000000);
	choosechar[1][0] = TextDrawCreate(-12.000000, 160.000000, "2");
	TextDrawBackgroundColor(choosechar[1][0], 255);
	TextDrawFont(choosechar[1][0], 1);
	TextDrawLetterSize(choosechar[1][0], 0.500000, 32.000000);
	TextDrawColor(choosechar[1][0], 255);
	TextDrawSetOutline(choosechar[1][0], 0);
	TextDrawSetProportional(choosechar[1][0], 1);
	TextDrawSetShadow(choosechar[1][0], 1);
	TextDrawUseBox(choosechar[1][0], 1);
	TextDrawBoxColor(choosechar[1][0], 255);
	TextDrawTextSize(choosechar[1][0], 440.000000, 100.000000);
	choosechar[2][0] = TextDrawCreate(100.000000, 160.000000, "Waehle deinen Charakter");
	TextDrawBackgroundColor(choosechar[2][0], 255);
	TextDrawFont(choosechar[2][0], 1);
	TextDrawLetterSize(choosechar[2][0], 0.500000, 1.000000);
	TextDrawColor(choosechar[2][0], -1);
	TextDrawSetOutline(choosechar[2][0], 0);
	TextDrawSetProportional(choosechar[2][0], 1);
	TextDrawSetShadow(choosechar[2][0], 1);
	choosechar[4][0] = TextDrawCreate(110.000000, 30.000000, "San Andreas Heroes");
	TextDrawBackgroundColor(choosechar[4][0], 255);
	TextDrawFont(choosechar[4][0], 2);
	TextDrawLetterSize(choosechar[4][0], 1.000000, 5.000000);
	TextDrawColor(choosechar[4][0], -65281);
	TextDrawSetOutline(choosechar[4][0], 0);
	TextDrawSetProportional(choosechar[4][0], 1);
	TextDrawSetShadow(choosechar[4][0], 1);
	
	menu1[0][0] = TextDrawCreate(-10.000000, 0.000000, "1");
	TextDrawBackgroundColor(menu1[0][0], 255);
	TextDrawFont(menu1[0][0], 1);
	TextDrawLetterSize(menu1[0][0], 3.509998, 51.000000);
	TextDrawColor(menu1[0][0], 255);
	TextDrawSetOutline(menu1[0][0], 0);
	TextDrawSetProportional(menu1[0][0], 1);
	TextDrawSetShadow(menu1[0][0], 1);
	TextDrawUseBox(menu1[0][0], 1);
	TextDrawBoxColor(menu1[0][0], 255);
	TextDrawTextSize(menu1[0][0], 660.000000, 170.000000);
	menu1[1][0] = TextDrawCreate(160.000000, 40.000000, "San Andreas Heroes");
	TextDrawBackgroundColor(menu1[1][0], 255);
	TextDrawFont(menu1[1][0], 1);
	TextDrawLetterSize(menu1[1][0], 0.950000, 4.900001);
	TextDrawColor(menu1[1][0], -65281);
	TextDrawSetOutline(menu1[1][0], 0);
	TextDrawSetProportional(menu1[1][0], 1);
	TextDrawSetShadow(menu1[1][0], 1);

	print("geladen :)");
	return 1;
}

forward nodrop();
public nodrop()
{
    SetTimer("nodrop",60000*10,0);
    new nodropcmd[256];
	format(nodropcmd,256,"UPDATE nodrop SET value = '%d' WHERE enta = '1'",random(100));
	mysql_query(nodropcmd);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(player[playerid][klasse] != 0)
    {
        SpawnPlayer(playerid);
        return 1;
    }
    
    actualchosenskin[playerid] = classid+1;
    
    SetPlayerInterior(playerid,5);
    SetPlayerPos(playerid,1242.3011,-819.4758,1083.1563);
    SetPlayerFacingAngle(playerid,178.1433);
    clearchat(playerid);
    TextDrawShowForPlayer(playerid,choosechar[0][0]);
    TextDrawShowForPlayer(playerid,choosechar[1][0]);
    TextDrawShowForPlayer(playerid,choosechar[2][0]);
    TextDrawShowForPlayer(playerid,choosechar[3][playerid]);
    TextDrawShowForPlayer(playerid,choosechar[4][0]);

	SetPlayerCameraPos(playerid,1238.1060-2,-828.6057+3,1083.5815);
	SetPlayerCameraLookAt(playerid,1238.2250,-820.0812,1083.1563+1);
	
	switch(classid)
	{
	    case 0:TextDrawSetString(choosechar[3][playerid],"~>~~r~Ingenieur~w~ - Held der Maschinen~n~~n~Berserker - Held des Blutes~n~~n~Assassine - Held der Unsichtbaren~n~~n~Schamane - Held der Natur");
	    case 1:TextDrawSetString(choosechar[3][playerid],"Ingenieur - Held der Maschinen~n~~n~~>~~r~Berserker~w~ - Held des Blutes~n~~n~Assassine - Held der Unsichtbaren~n~~n~Schamane - Held der Natur");
	    case 2:TextDrawSetString(choosechar[3][playerid],"Ingenieur - Held der Maschinen~n~~n~Berserker - Held des Blutes~n~~n~~>~~r~Assassine~w~ - Held der Unsichtbaren~n~~n~Schamane - Held der Natur");
	    case 3:TextDrawSetString(choosechar[3][playerid],"Ingenieur - Held der Maschinen~n~~n~Berserker - Held des Blutes~n~~n~Assassine - Held der Unsichtbaren~n~~n~~>~~r~Schamane~w~ - Held der Natur");
	}

	return 1;
}

public OnGameModeExit()
{
	TextDrawHideForAll(choosechar[0][0]);
	TextDrawDestroy(choosechar[0][0]);
	TextDrawHideForAll(choosechar[1][0]);
	TextDrawDestroy(choosechar[1][0]);
	TextDrawHideForAll(choosechar[2][0]);
	TextDrawDestroy(choosechar[2][0]);
	TextDrawHideForAll(choosechar[4][0]);
	TextDrawDestroy(choosechar[4][0]);
	for(new i=0;i!=slots;i++)
	{
		TextDrawHideForAll(choosechar[3][i]);
		TextDrawDestroy(choosechar[3][i]);
		TextDrawHideForAll(menu1[2][i]);
		TextDrawDestroy(menu1[2][i]);
	}
	TextDrawHideForAll(menu1[0][0]);
	TextDrawDestroy(menu1[0][0]);
	TextDrawHideForAll(menu1[1][0]);
	TextDrawDestroy(menu1[1][0]);
	
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerVirtualWorld(playerid,playerid+1);
	SetPlayerInterior(playerid,5);
    SetPlayerPos(playerid,1242.3011,-819.4758,1083.1563);
    SetPlayerFacingAngle(playerid,178.1433);
    
    TextDrawShowForPlayer(playerid,menu1[0][0]);
    TextDrawShowForPlayer(playerid,menu1[1][0]);
    TextDrawShowForPlayer(playerid,menu1[2][playerid]);
    
    TextDrawHideForPlayer(playerid,choosechar[0][0]);
    TextDrawHideForPlayer(playerid,choosechar[1][0]);
    TextDrawHideForPlayer(playerid,choosechar[2][0]);
    TextDrawHideForPlayer(playerid,choosechar[4][0]);
    TextDrawHideForPlayer(playerid,choosechar[3][playerid]);
    
	SetTimerEx("menu1_func",250,0,"i",playerid);
	
	return 1;
}

forward menu1_func(playerid);
public menu1_func(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	GetPlayerKeys(playerid,menukeys[0][playerid],menukeys[1][playerid],menukeys[2][playerid]);
	
	switch(menukeys[2][playerid]) //rechts/links
	{
	    case 128: //rechts
	    {
			switch(menu1pos[playerid])
			{
			    case 0:
			    {
			        if(menu1marker[playerid] == 0) return joingame(playerid);
			        menu1pos[playerid] = menu1marker[playerid]+1; //+1, da 0 ja die übersicht ist
		       		menu1marker[playerid] = 0;
				}
			    //case 1:joingame(playerid,menu1marker[playerid]);
				case 2:
				{
				    if(player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]) != 0)
				    {
				        if(menu1marker[playerid] > 4)
				        {
				            player[playerid][tree2] += 1;
				            savesqlstat(playerid,"tree2",player[playerid][tree2]);
				        }
				        else
				        {
				            player[playerid][tree1] += 1;
				            savesqlstat(playerid,"tree1",player[playerid][tree1]);
				        }
				    }
				}
			}
	    }
	    case -128: //links
		{
			menu1pos[playerid] = 0;
			menu1marker[playerid] = 0;
		}
	}
	switch(menukeys[1][playerid]) //hoch/runter
	{
	    case 128:menu1marker[playerid] += 1;
		case -128:menu1marker[playerid] -= 1;
	}
	if(menu1options[menu1pos[playerid]] < menu1marker[playerid]) menu1marker[playerid] = 0;
    if(0 > menu1marker[playerid]) menu1marker[playerid] = menu1options[menu1pos[playerid]];
    
	switch(menu1pos[playerid])
	{
	    case 0: //Übersicht
		{
			switch(menu1marker[playerid])
			{
			    case 0:TextDrawSetString(menu1[2][playerid],"~>~~r~Spiel beitreten~w~~n~~n~Faehigkeiten~n~~n~Spiel verlassen");
			    case 1:TextDrawSetString(menu1[2][playerid],"Spiel beitreten~n~~n~~>~~r~Faehigkeiten~w~~n~~n~Spiel verlassen");
			    case 2:TextDrawSetString(menu1[2][playerid],"Spiel beitreten~n~~n~Faehigkeiten~n~~n~~>~~r~Spiel verlassen~w~");
			}
		}
		/*
		case 1: //Spiel beitreten
		{
		    switch(menu1marker[playerid])
			{
			    case 0:TextDrawSetString(menu1[2][playerid],"~>~~r~Alle gegen Alle~w~~n~~n~Team Deathmatch");
                case 1:TextDrawSetString(menu1[2][playerid],"Alle gegen Alle - Eng~n~~n~~>~~r~Team Deathmatch~w~");
			}
		}
		*/
		case 2: //Fähigkeiten
		{
		    new endstring[1024];

			if(player[playerid][tree1] >= 5) gotskill[playerid][0][0] = 5;
			else gotskill[playerid][0][0] = player[playerid][tree1];
            if(player[playerid][tree1] >= 10) gotskill[playerid][0][1] = 5;
			else gotskill[playerid][0][1] = player[playerid][tree1]-5;
			if(player[playerid][tree1] >= 15) gotskill[playerid][0][2] = 5;
			else gotskill[playerid][0][2] = player[playerid][tree1]-10;
			if(player[playerid][tree1] >= 20) gotskill[playerid][0][3] = 5;
			else gotskill[playerid][0][3] = player[playerid][tree1]-15;
			if(player[playerid][tree1] >= 25) gotskill[playerid][0][4] = 5;
			else gotskill[playerid][0][4] = player[playerid][tree1]-20;

            if(player[playerid][tree2] >= 5) gotskill[playerid][1][0] = 5;
			else gotskill[playerid][1][0] = player[playerid][tree2];
            if(player[playerid][tree2] >= 10) gotskill[playerid][1][1] = 5;
			else gotskill[playerid][1][1] = player[playerid][tree2]-5;
			if(player[playerid][tree2] >= 15) gotskill[playerid][1][2] = 5;
			else gotskill[playerid][1][2] = player[playerid][tree2]-10;
			if(player[playerid][tree2] >= 20) gotskill[playerid][1][3] = 5;
			else gotskill[playerid][1][3] = player[playerid][tree2]-15;
			if(player[playerid][tree2] >= 25) gotskill[playerid][1][4] = 5;
			else gotskill[playerid][1][4] = player[playerid][tree2]-20;
			
		    if(player[playerid][klasse] == 1) //ingenieur
		    {
			    switch(menu1marker[playerid])
				{
				    case 0:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Ironman~w~~n~~n~~>~~r~Megasprung (%d/5) - Spring hoeher~w~~n~Koerperpanzer (%d/5)~n~Intensivschlag (%d/5)~n~Bacta-Tank (%d/5)~n~Allzeit bereit (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 1:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Ironman~w~~n~~n~Megasprung (%d/5)~n~~>~~r~Koerperpanzer (%d/5) - Erhalte einen Stahlpanzer~w~~n~Intensivschlag (%d/5)~n~Bacta-Tank (%d/5)~n~Allzeit bereit (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 2:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Ironman~w~~n~~n~Megasprung (%d/5)~n~Koerperpanzer (%d/5)~n~~>~~r~Intensivschlag (%d/5) - Schlag härter zu~w~~n~Bacta-Tank (%d/5)~n~Allzeit bereit (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 3:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Ironman~w~~n~~n~Megasprung (%d/5)~n~Koerperpanzer (%d/5)~n~Intensivschlag (%d/5)~n~~>~~r~Bacta-Tank (%d/5) - Deine Ruestung heilt dich~w~~n~Allzeit bereit (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 4:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Ironman~w~~n~~n~Megasprung (%d/5)~n~Koerperpanzer (%d/5)~n~Intensivschlag (%d/5)~n~Bacta-Tank (%d/5)~n~~>~~r~Allzeit bereit (%d/5) - Lerne Fliegen~w~~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);

					case 5:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Dell Conagher~w~~n~~n~~>~~r~Little Boy (%d/5) - Leichte Selbstschussanlage~w~~n~Guter Schueler (%d/5)~n~Slayer (%d/5)~n~Fat Boy (%d/5)~n~Predator (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 6:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Dell Conagher~w~~n~~n~Little Boy (%d/5)~n~~>~~r~Guter Schueler (%d/5) - Leichte Selbstschussanlage~w~~n~Slayer (%d/5)~n~Fat Boy (%d/5)~n~Predator (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 7:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Dell Conagher~w~~n~~n~Little Boy (%d/5)~n~Guter Schueler (%d/5)~n~~>~~r~Slayer (%d/5) - Starke Selbstschussanlage~w~~n~Fat Boy (%d/5)~n~Predator (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 8:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Dell Conagher~w~~n~~n~Little Boy (%d/5)~n~Guter Schueler (%d/5)~n~Slayer (%d/5)~n~~>~~r~Fat Boy (%d/5) - Starke Selbstschussanlage~w~~n~Predator (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 9:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Dell Conagher~w~~n~~n~Little Boy (%d/5)~n~Guter Schueler (%d/5)~n~Slayer (%d/5)~n~Fat Boy (%d/5)~n~~>~~r~Predator (%d/5) - Schwere Selbstschussanlage~w~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
				}
			}
			if(player[playerid][klasse] == 2) //berserker
		    {
			    switch(menu1marker[playerid])
				{
				    case 0:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Hulk~w~~n~~n~~>~~r~Dicke Haut (%d/5) - Mehr Leben~w~~n~Rage (%d/5)~n~Flitzer (%d/5)~n~Hau den Lukas (%d/5)~n~Mutation (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
			        case 1:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Hulk~w~~n~~n~Dicke Haut (%d/5)~n~~>~~r~Rage (%d/5) - Schmerzlos Gluecklich~w~~n~Flitzer (%d/5)~n~Hau den Lukas (%d/5)~n~Mutation (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
			        case 2:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Hulk~w~~n~~n~Dicke Haut (%d/5)~n~Rage (%d/5)~n~~>~~r~Flitzer (%d/5) - Lauf schneller~w~~n~Hau den Lukas (%d/5)~n~Mutation (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
			        case 3:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Hulk~w~~n~~n~Dicke Haut (%d/5)~n~Rage (%d/5)~n~Flitzer (%d/5)~n~~>~~r~Hau den Lukas (%d/5) - Schlag staerker~w~~n~Mutation (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
			        case 4:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Hulk~w~~n~~n~Dicke Haut (%d/5)~n~Rage (%d/5)~n~Flitzer (%d/5)~n~Hau den Lukas (%d/5)~n~~>~~r~Mutation (%d/5) - Unkontrollierte Kraft~w~~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
			
			        case 5:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vitali Klitschko~w~~n~~n~~>~~r~Richtige Technik (%d/5) - Starke Schlagkombo~w~~n~Harte Linke (%d/5)~n~Fitness (%d/5)~n~Entwaffnungsschlag (%d/5)~n~K.O.-Sieg (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 6:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vitali Klitschko~w~~n~~n~Richtige Technik (%d/5)~n~~>~~r~Harte Linke (%d/5) - Mehr Schaden~w~~n~Fitness (%d/5)~n~Entwaffnungsschlag (%d/5)~n~K.O.-Sieg (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 7:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vitali Klitschko~w~~n~~n~Richtige Technik (%d/5)~n~Harte Linke (%d/5)~n~~>~~r~Fitness (%d/5) - Lauf schneller~w~~n~Entwaffnungsschlag (%d/5)~n~K.O.-Sieg (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 8:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vitali Klitschko~w~~n~~n~Richtige Technik (%d/5)~n~Harte Linke (%d/5)~n~Fitness (%d/5)~n~~>~~r~Entwaffnungsschlag (%d/5) - Entwaffnet Gegner~w~~n~K.O.-Sieg (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 9:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vitali Klitschko~w~~n~~n~Richtige Technik (%d/5)~n~Harte Linke (%d/5)~n~Fitness (%d/5)~n~Entwaffnungsschlag (%d/5)~n~~>~~r~K.O.-Sieg (%d/5) - Schlag Gegner K.O.~w~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
				}
			}
			if(player[playerid][klasse] == 3) //assassine
		    {
			    switch(menu1marker[playerid])
				{
				    case 0:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Prototype~w~~n~~n~~>~~r~Mutation (%d/5) - Zufaellige Verwandlung~w~~n~Megasprung (%d/5)~n~Dicke Haut (%d/5)~n~Hau den Lukas (%d/5)~n~Anpassung (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 1:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Prototype~w~~n~~n~Mutation (%d/5)~n~~>~~r~Megasprung (%d/5) - Spring hoeher~w~~n~Dicke Haut (%d/5)~n~Hau den Lukas (%d/5)~n~Anpassung (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 2:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Prototype~w~~n~~n~Mutation (%d/5)~n~Megasprung (%d/5)~n~~>~~r~Dicke Haut (%d/5) - Mehr Leben~w~~n~Hau den Lukas (%d/5)~n~Anpassung (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 3:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Prototype~w~~n~~n~Mutation (%d/5)~n~Megasprung (%d/5)~n~Dicke Haut (%d/5)~n~~>~~r~Hau den Lukas (%d/5) - Schlag staerker~w~~n~Anpassung (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 4:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Prototype~w~~n~~n~Mutation (%d/5)~n~Megasprung (%d/5)~n~Dicke Haut (%d/5)~n~Hau den Lukas (%d/5)~n~~>~~r~Anpassung (%d/5) - Verwandle dich in Gegner~w~~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    
                    case 5:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Ghost~w~~n~~n~~>~~r~UAV Jammer (%d/5) - Unsichtbar auf dem Radar~w~~n~HPs Mantel (%d/5)~n~C4 (%d/5)~n~Rauchbombe (%d/5)~n~Schattenbild (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 6:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Ghost~w~~n~~n~UAV Jammer (%d/5)~n~~>~~r~HPs Mantel (%d/5) - Sei unsichtbar~w~~n~C4 (%d/5)~n~Rauchbombe (%d/5)~n~Schattenbild (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 7:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Ghost~w~~n~~n~UAV Jammer (%d/5)~n~HPs Mantel (%d/5)~n~~>~~r~C4 (%d/5) - Bomben mit Fernzuender~w~~n~Rauchbombe (%d/5)~n~Schattenbild (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 8:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Ghost~w~~n~~n~UAV Jammer (%d/5)~n~HPs Mantel (%d/5)~n~C4 (%d/5)~n~~>~~r~Rauchbombe (%d/5) - Taktischer Rueckzug~w~~n~Schattenbild (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 9:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Ghost~w~~n~~n~UAV Jammer (%d/5)~n~HPs Mantel (%d/5)~n~C4 (%d/5)~n~Rauchbombe (%d/5)~n~~>~~r~Schattenbild (%d/5) - Erstelle ein Spiegelbild~w~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
				}
			}
			if(player[playerid][klasse] == 4) //schamane
		    {
			    switch(menu1marker[playerid])
				{
				    case 0:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Priester~w~~n~~n~~>~~r~Heilung (%d/5) - Heile jemanden~w~~n~Adrenalin (%d/5)~n~Wiederbelebung (%d/5)~n~Sonnenschein (%d/5)~n~Elixier des Lebens (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 1:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Priester~w~~n~~n~Heilung (%d/5)~n~~>~~r~Adrenalin (%d/5) - Staerke jemanden~w~~n~Wiederbelebung (%d/5)~n~Sonnenschein (%d/5)~n~Elixier des Lebens (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 2:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Priester~w~~n~~n~Heilung (%d/5)~n~Adrenalin (%d/5)~n~~>~~r~Wiederbelebung (%d/5) - Belebe Tote wieder~w~~n~Sonnenschein (%d/5)~n~Elixier des Lebens (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 3:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Priester~w~~n~~n~Heilung (%d/5)~n~Adrenalin (%d/5)~n~Wiederbelebung (%d/5)~n~~>~~r~Sonnenschein (%d/5) - Anti-Zombie & Assassine~w~~n~Elixier des Lebens (%d/5)~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);
                    case 4:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~b~Priester~w~~n~~n~Heilung (%d/5)~n~Adrenalin (%d/5)~n~Wiederbelebung (%d/5)~n~Sonnenschein (%d/5)~n~~>~~r~Elixier des Lebens (%d/5) - Mache jmd unverwundbar~w~~n~~d~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][0][0],gotskill[playerid][0][1],gotskill[playerid][0][2],gotskill[playerid][0][3],gotskill[playerid][0][4]);

                    case 5:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vodoo-Zauberer~w~~n~~n~~>~~r~Verkrüppeln (%d/5)~w~~n~Halluzinationen (%d/5)~n~Voodoo (%d/5)~n~Machtschub (%d/5)~n~Dead Rising (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 6:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vodoo-Zauberer~w~~n~~n~Verkrüppeln (%d/5)~n~~>~~r~Halluzinationen (%d/5)~w~~n~Voodoo (%d/5)~n~Machtschub (%d/5)~n~Dead Rising (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 7:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vodoo-Zauberer~w~~n~~n~Verkrüppeln (%d/5)~n~Halluzinationen (%d/5)~n~~>~~r~Voodoo (%d/5)~w~~n~Machtschub (%d/5)~n~Dead Rising (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 8:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vodoo-Zauberer~w~~n~~n~Verkrüppeln (%d/5)~n~Halluzinationen (%d/5)~n~Voodoo (%d/5)~n~~>~~r~Machtschub (%d/5)~w~~n~Dead Rising (%d/5)",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);
                    case 9:format(endstring,1024,"Ungenutzte Skillpunkte: %d~n~~u~~b~Vodoo-Zauberer~w~~n~~n~Verkrüppeln (%d/5)~n~Halluzinationen (%d/5)~n~Voodoo (%d/5)~n~Machtschub (%d/5)~n~~>~~r~Dead Rising (%d/5)~w~",player[playerid][lvl]-(player[playerid][tree1]+player[playerid][tree2]),gotskill[playerid][1][0],gotskill[playerid][1][1],gotskill[playerid][1][2],gotskill[playerid][1][3],gotskill[playerid][1][4]);

				}
			}
		}
		case 3:
		{
			return Kick(playerid);
		}
	}

    SetTimerEx("menu1_func",100,0,"i",playerid);
	return 1;
}

forward joingame(playerid);
public joingame(playerid)
{
    TextDrawHideForPlayer(playerid,menu1[0][0]);
    TextDrawHideForPlayer(playerid,menu1[1][0]);
    TextDrawHideForPlayer(playerid,menu1[2][playerid]);
    
    SetPVarInt(playerid,"mapcho",0);
    
    SetTimerEx("mapchoose",100,0,"i",playerid);
    clearchat(playerid);

	return 1;
}

forward clearchat(playerid);
public clearchat(playerid)
{
	for(new cl=0;cl!=10;cl++) SendClientMessage(playerid,COLOR_GREY," ");
	return 1;
}

forward mapchoose(playerid);
public mapchoose(playerid) //markme
{
	if(!IsPlayerConnected(playerid)) return 0;
	GetPlayerKeys(playerid,menukeys[0][playerid],menukeys[1][playerid],menukeys[2][playerid]);
	
	switch(menukeys[2][playerid]) //rechts/links
	{
	    case 128: SetPVarInt(playerid,"mapcho",GetPVarInt(playerid,"mapcho")+1); //rechts
	    case -128: SetPVarInt(playerid,"mapcho",GetPVarInt(playerid,"mapcho")-1);
	}
	/*
	switch(menukeys[1][playerid]) //hoch/runter
	{
	    case 128: SetPVarInt(playerid,"mapcho",GetPVarInt(playerid,"mapcho")+1); //hoch
	    case -128: SetPVarInt(playerid,"mapcho",GetPVarInt(playerid,"mapcho")-1);
	}*/
	if(GetPVarInt(playerid,"mapcho") >= maps) SetPVarInt(playerid,"mapcho",0);
	if(GetPVarInt(playerid,"mapcho") < 0) SetPVarInt(playerid,"mapcho",5);
	
	clearchat(playerid);
	switch(GetPVarInt(playerid,"mapcho"))
	{
	    case 0:
	    {
	        SendClientMessage(playerid,COLOR_GREY,"Map: 2sides");
	        SendClientMessage(playerid,COLOR_GREY,"Genre: TDM");
	        SendClientMessage(playerid,COLOR_GREY,"Größe: Klein");
	        SetPlayerInterior(playerid,1);
	        SetPlayerCameraPos(playerid,2210.3515625,1635.4904785156,1078.2211914063);
	        SetPlayerCameraLookAt(playerid,2269.2182617188,1645.8936767578,1100.234375);
	    }
	    case 1:
	    {
	        SendClientMessage(playerid,COLOR_GREY,"Map: Canigula");
	        SendClientMessage(playerid,COLOR_GREY,"Genre: FFA");
	        SendClientMessage(playerid,COLOR_GREY,"Größe: Groß");
	        SetPlayerInterior(playerid,1);
	        SetPlayerCameraPos(playerid,2100.1281738281,1636.5346679688,1132.0791015625);
	        SetPlayerCameraLookAt(playerid,2186.2802734375,1613.6839599609,1005.0625);
	    }
	    case 2:
	    {
	        SendClientMessage(playerid,COLOR_GREY,"Map: Atrium");
	        SendClientMessage(playerid,COLOR_GREY,"Genre: FFA");
	        SendClientMessage(playerid,COLOR_GREY,"Größe: Klein");
	        SetPlayerInterior(playerid,18);
	        SetPlayerCameraPos(playerid,1717.5223388672,-1669.1574707031,60.47526550293);
	        SetPlayerCameraLookAt(playerid,1718.4307861328,-1662.1887207031,42.473415374756);
	    }
	    case 3:
	    {
	        SendClientMessage(playerid,COLOR_GREY,"Map: Crackpalace");
	        SendClientMessage(playerid,COLOR_GREY,"Genre: TDM");
	        SendClientMessage(playerid,COLOR_GREY,"Größe: Riesig");
	        SetPlayerInterior(playerid,2);
	        SetPlayerCameraPos(playerid,2600.2780761719,-1361.3981933594,1051.5290527344);
	        SetPlayerCameraLookAt(playerid,2561.5256347656,-1307.3981933594,1053.6461181641);
	    }
	    case 4:
	    {
	        SendClientMessage(playerid,COLOR_GREY,"Map: Jefferson");
	        SendClientMessage(playerid,COLOR_GREY,"Genre: TDM");
	        SendClientMessage(playerid,COLOR_GREY,"Größe: Groß");
	        SetPlayerInterior(playerid,15);
	        SetPlayerCameraPos(playerid,2255.7016601563,-1197.2963867188,1051.796875);
	        SetPlayerCameraLookAt(playerid,2226.7958984375,-1177.9702148438,1033.2985839844);
	    }
	}

    SendClientMessage(playerid,COLOR_GREY," ");
    SendClientMessage(playerid,COLOR_GREY,"Drücken Sie rechts/links, um die Karte zu wechseln");
    SendClientMessage(playerid,COLOR_GREY,"Drücken Sie Enter, um die Karte auszuwählen");
    if(menukeys[0][playerid] & KEY_ACTION || menukeys[0][playerid] & KEY_FIRE)
    {
        SetPVarInt(playerid,"ingame",1);
		startgame(playerid,GetPVarInt(playerid,"mapcho"));
    }
    else
	{
		SetTimerEx("mapchoose",100,0,"i",playerid);
	}
 	return 1;
}

forward startgame(playerid,choice);
public startgame(playerid,choice)
{
	SetPlayerVirtualWorld(playerid,0);


	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	if(player[playerid][klasse] == 0)
	{
		format(mysqlquery[playerid],128,"REPLACE INTO her_score (alvl,name,tree1,tree2,tree3,klasse) VALUES ('0','%s','0','0','0','%s');",player[playerid][seria],actualchosenskin[playerid]);
		mysql_query(mysqlquery[playerid]);
        player[playerid][klasse] = actualchosenskin[playerid];
	}
	
	return 1;
}

public OnPlayerConnect(playerid)
{
    gpci(playerid, player[playerid][seria], 1024);
    
   	new tmpoutput5[256];
	format(mysqlquery[playerid],256,"SELECT * FROM bans WHERE name = '%s'",player[playerid][seria]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_fetch_field("reason",tmpoutput5))
	{
	    mysql_free_result();
	    new kmsg2[256];
		format(kmsg2,256,"You are still banned for: %s",tmpoutput5);
		SendClientMessage(playerid,COLOR_RED,kmsg2);
	    return Kick(playerid);
	}
	mysql_free_result();

    format(mysqlquery[playerid],256,"SELECT * FROM login WHERE name = '%s'",player[playerid][seria]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(!mysql_fetch_field("name",tmpoutput5))
	{
	    format(mysqlquery[playerid],128,"REPLACE INTO her_score (exp,lvl,alvl,name,tree1,tree2,tree3,klasse) VALUES ('0','1','0','%s','0','0','0','0')",player[playerid][seria]);
		mysql_query(mysqlquery[playerid]);
		
		format(mysqlquery[playerid],128,"REPLACE INTO login (name,pw) VALUES ('%s','0')",player[playerid][seria]);
		mysql_query(mysqlquery[playerid]);
	}
	mysql_free_result();
	
	format(mysqlquery[playerid],256,"SELECT * FROM her_score WHERE name = '%s'",player[playerid][seria]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
    mysql_fetch_field("alvl",tmpoutput5);
    player[playerid][alvl] = strval(tmpoutput5);
	switch(player[playerid][alvl])
	{
	    case 1:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Supporter");
	    case 2:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Moderator");
	    case 3:SendClientMessage(playerid,COLOR_GREEN,"Eingeloggt als Skripter");
	}
    mysql_fetch_field("tree1",tmpoutput5);
    player[playerid][tree1] = strval(tmpoutput5);
    mysql_fetch_field("tree2",tmpoutput5);
    player[playerid][tree2] = strval(tmpoutput5);
    mysql_fetch_field("tree3",tmpoutput5);
    player[playerid][tree3] = strval(tmpoutput5);
    mysql_fetch_field("klasse",tmpoutput5);
    player[playerid][klasse] = strval(tmpoutput5);
    mysql_fetch_field("exp",tmpoutput5);
    player[playerid][exp] = strval(tmpoutput5);
    mysql_fetch_field("lvl",tmpoutput5);
    player[playerid][lvl] = strval(tmpoutput5);
    mysql_free_result();
    
    if(player[playerid][tree1] >= 5) gotskill[playerid][0][0] = 5;
	else gotskill[playerid][0][0] = player[playerid][tree1];
    if(player[playerid][tree1] >= 10) gotskill[playerid][0][1] = 5;
	else gotskill[playerid][0][1] = player[playerid][tree1]-5;
	if(player[playerid][tree1] >= 15) gotskill[playerid][0][2] = 5;
	else gotskill[playerid][0][2] = player[playerid][tree1]-10;
	if(player[playerid][tree1] >= 20) gotskill[playerid][0][3] = 5;
	else gotskill[playerid][0][3] = player[playerid][tree1]-15;
	if(player[playerid][tree1] >= 25) gotskill[playerid][0][4] = 5;
	else gotskill[playerid][0][4] = player[playerid][tree1]-20;

    if(player[playerid][tree2] >= 5) gotskill[playerid][1][0] = 5;
	else gotskill[playerid][1][0] = player[playerid][tree2];
    if(player[playerid][tree2] >= 10) gotskill[playerid][1][1] = 5;
	else gotskill[playerid][1][1] = player[playerid][tree2]-5;
	if(player[playerid][tree2] >= 15) gotskill[playerid][1][2] = 5;
	else gotskill[playerid][1][2] = player[playerid][tree2]-10;
	if(player[playerid][tree2] >= 20) gotskill[playerid][1][3] = 5;
	else gotskill[playerid][1][3] = player[playerid][tree2]-15;
	if(player[playerid][tree2] >= 25) gotskill[playerid][1][4] = 5;
	else gotskill[playerid][1][4] = player[playerid][tree2]-20;

    choosechar[3][playerid] = TextDrawCreate( 120.000000-30.0, 230.000000, "~>~~r~Ingenieur~w~ - Held der Maschinen~n~~n~Berserker - Held des Blutes~n~~n~Assassine - Held der Unsichtbaren~n~~n~Schamane - Held der Natur");
	TextDrawBackgroundColor(choosechar[3][playerid], 255);
	TextDrawFont(choosechar[3][playerid], 1);
	TextDrawLetterSize(choosechar[3][playerid], 0.500000, 1.000000);
	TextDrawColor(choosechar[3][playerid], -1);
	TextDrawSetOutline(choosechar[3][playerid], 0);
	TextDrawSetProportional(choosechar[3][playerid], 1);
	TextDrawSetShadow(choosechar[3][playerid], 1);
	
	menu1[2][playerid] = TextDrawCreate(110.000000, 150.000000, "~>~~r~Spiel beitreten~w~~n~~n~Spiel erstellen~n~~n~Auszeichnungen~n~~n~Charakter betrachten~n~~n~Fähigkeiten~n~~n~Spiel verlassen");
	TextDrawBackgroundColor(menu1[2][playerid], 255);
	TextDrawFont(menu1[2][playerid], 1);
	TextDrawLetterSize(menu1[2][playerid], 0.500000, 1.000000);
	TextDrawColor(menu1[2][playerid], -1);
	TextDrawSetOutline(menu1[2][playerid], 0);
	TextDrawSetProportional(menu1[2][playerid], 1);
	TextDrawSetShadow(menu1[2][playerid], 1);

	TextDrawShowForPlayer(playerid,menu1[2][playerid]); //deko
	clearchat(playerid);

	return 1;
}

forward bansql(playerid,reason[]);
public bansql(playerid,reason[])
{
    gpci(playerid, player[playerid][seria], 1024);

    format(mysqlquery[playerid],128,"INSERT INTO bans (name,ip,reason) VALUES ('%s','%s','%s')",player[playerid][seria],"0",reason);
	mysql_query(mysqlquery[playerid]);

	Kick(playerid);

	return 1;
}

public OnPlayerDisconnect(playerid,reason)
{
	TextDrawDestroy(choosechar[3][playerid]);
	TextDrawDestroy(menu1[2][playerid]);
	menu1pos[playerid]=0,menu1marker[playerid] = 0;
	return 1;
}

forward savesqlstat(playerid,name[256],wert);
public savesqlstat(playerid,name[256],wert)
{
    gpci(playerid, player[playerid][seria], 1024);
    
    format(mysqlquery[playerid],128,"UPDATE her_score SET %s='%d' WHERE name='%s' LIMIT 1;",name,wert,player[playerid][seria]);
	mysql_query(mysqlquery[playerid]);

	return 1;
}
