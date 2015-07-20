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
#include <SII>
#include <eum>
#include <mapandreas>
#include <progress>
#include <a_http>
#include <smoothrot>

#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_FUNK 0x3366FF

#define fallicon 1254
#define fallspeed 30
#define slots 26


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

new loggedin[slots],player_name[slots][256],adminlevel[slots],mysqlquery[slots][256],wartung =0;
new tuning[slots][14],Text:txtdraw[4][slots],Text3D:info[slots],staticpickup[50];
new iPickups[MAX_PICKUPS][5],Bar:barrid[2][slots],Text:wtxt,ClickedPlayerID[slots];
new car_info[30][6];

enum fall_para
{
	pickid,
	fallorroll, //1=fallen,2=rollen
	objid,
	Float:ux,
	Float:uy,
	Float:uz,
	Float:ex,
	Float:ey,
	Float:ez,
	Float:uax,
	Float:uay,
	Float:uaz,
	Float:eax,
	Float:eay,
	Float:eaz,
	Float:pickx,
	Float:picky,
	Float:pickz,
	triggered
}
new fallevent[15][fall_para];

enum versteck_para
{
	pickid,
	Float:vx,
	Float:vy,
	Float:vz,
	Float:va
}
new Float:verstecke[6][versteck_para];

main()
{
}

public OnGameModeInit()
{
	print(" -------------------------------- ");
	print(" ------- NFS:MW II GM lädt --------- ");
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);

    SetGameModeText("Racing");
	SendRconCommand("mapname Savandreas");
    EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	mysql_init();
    mysql_connect("xxx", "xxx", "xxx", "xxx");
    SetTimer("nodrop",60000*10,0);
	SetTimer("changeweather",30000*10,1);
	changeweather();
	LimitPlayerMarkerRadius(50000.0);
	ShowPlayerMarkers(1);
	ShowNameTags(0);
	
	car_info[0][3]= 400, car_info[0][4] = 5000;
	car_info[1][3] = 404, car_info[1][4] = 5000;
	car_info[2][3] = 413, car_info[2][4] = 5000;
	car_info[3][3] = 458, car_info[3][4] = 5000;
	car_info[4][3] = 418, car_info[4][4] = 5000;
	car_info[5][3] = 422, car_info[5][4] = 5000;
	car_info[6][3] = 426, car_info[6][4] = 10000;
	car_info[7][3] = 434, car_info[7][4] = 10000;
	car_info[8][3] = 421, car_info[8][4] = 10000;
	car_info[9][3] = 410, car_info[9][4] = 10000;
	car_info[10][3] = 405, car_info[10][4] = 10000;
	car_info[11][3] = 496, car_info[11][4] = 15000, car_info[11][5] = 15;
	car_info[12][3] = 589, car_info[12][4] = 20000, car_info[12][5] = 14;
	car_info[13][3] = 475, car_info[13][4] = 20000, car_info[13][5] = 13;
	car_info[14][3] = 480, car_info[14][4] = 25000, car_info[14][5] = 12;
	car_info[15][3] = 602, car_info[15][4] = 30000, car_info[15][5] = 11;
	car_info[16][3] = 429, car_info[16][4] = 35000, car_info[16][5] = 10;
	car_info[17][3] = 402, car_info[17][4] = 40000, car_info[17][5] = 9;
	car_info[18][3] = 415, car_info[18][4] = 45000, car_info[18][5] = 8;
	car_info[19][3] = 559, car_info[19][4] = 50000, car_info[19][5] = 7;
	car_info[20][3] = 411, car_info[20][4] = 55000, car_info[20][5] = 6;
	car_info[21][3] = 506, car_info[21][4] = 60000, car_info[21][5] = 5;
	car_info[22][3] = 477, car_info[22][4] = 60000, car_info[22][5] = 4;
	car_info[23][3] = 560, car_info[23][4] = 60000, car_info[23][5] = 3;
	car_info[24][3] = 541, car_info[24][4] = 60000, car_info[24][5] = 2;
	car_info[25][3] = 451, car_info[25][4] = 60000, car_info[25][5] = 1;
	
	for(new op=0;op<=50;op++) AddPlayerClass(276, -1820.4644,-149.4375,9.3984, 182.8881, 0, 0, 0, 0, 0, 0);
	
	//straßenblockaden
	CreateObject(966, -2671.55859375, 1280.4191894531, 54.945579528809, 0, 0, 180.54052734375);
	CreateObject(966, -2681.1162109375, 1280.5202636719, 54.945575714111, 0, 0, 180.53833007813);
	CreateObject(966, -2689.6813964844, 1280.4716796875, 54.952522277832, 0, 0, 180.53833007813);
	CreateObject(966, -2691.3508300781, 1280.4942626953, 54.952522277832, 0, 0, 359.99789428711);
	CreateObject(968, -2671.8156738281, 1280.4312744141, 55.89826965332, 0, 90, 0);
	CreateObject(968, -2681.373046875, 1280.5108642578, 55.935333251953, 0, 90, 0);
	CreateObject(968, -2689.9326171875, 1280.4884033203, 55.952522277832, 0, 90, 0);
	CreateObject(968, -2691.0939941406, 1280.4965820313, 55.876392364502, 0, 90, 179.41491699219);
	CreateObject(4511, -2676.4743652344, 1309.6123046875, 59.629688262939, 0, 0, 270.27026367188);
	CreateObject(4504, -2887.1665039063, -983.84777832031, 11.4921875, 0, 0, 77.729919433594);
	CreateObject(4506, -2870.2719726563, -985.43798828125, 11.4921875, 0, 0, 85.714965820313);
	CreateObject(4514, -1604.779296875, -1611.28515625, 37.040702819824, 0, 0, 294.17541503906);
	CreateObject(4526, -1213.37890625, -2344.6044921875, 18.392995834351, 0, 0, 45.785522460938);
	CreateObject(16436, -1188.5225830078, -2639.10546875, 12.740320205688, 0, 0, 270.27026367188);
	CreateObject(4526, -1110.6031494141, -2858.0158691406, 68.754653930664, 0, 0, 61.714935302734);
	CreateObject(4506, -1493.30078125, 592.26324462891, 36.278125762939, 0, 0, 214.46545410156);
	CreateObject(4526, -1532.0045166016, 687.22595214844, 45.581386566162, 0, 0, 262.33032226563);
	CreateObject(16436, -1738.4306640625, -727.53515625, 33.401378631592, 347, 2, 51.835021972656);
	CreateObject(4526, -1564.76953125, -1199.3448486328, 103.39581298828, 0, 0, 204.45043945313);
	CreateObject(16437, -1555.2307128906, -1182.9406738281, 103.16691589355, 0, 0, 47.820007324219);
	CreateObject(4526, -1391.0543212891, -1649.3950195313, 46.224700927734, 0, 0, 224.39038085938);
	CreateObject(4526, -1379.5432128906, -1671.1240234375, 45.600975036621, 0, 5, 240.40539550781);
	CreateObject(4507, -1982.8830566406, -609.31884765625, 27.513778686523, 0, 0, 87.014953613281);
	CreateObject(973, -1905.9810791016, -1388.7115478516, 40.188117980957, 0, 0, 332.1201171875);
	CreateObject(973, -1898.3698730469, -1392.6502685547, 39.972774505615, 0, 0, 334.09973144531);
	CreateObject(973, -1890.3453369141, -1396.3610839844, 39.739921569824, 0, 0, 336.08276367188);
	//paynspray blocks
	CreateObject(994, -1907.6975097656, 279.29504394531, 40.046875, 0, 0, 0);
	CreateObject(994, -2428.8901367188, 1027.5050048828, 49.397659301758, 0, 0, 0);
	
	//fallevents :
	//1 : burgershot fahrschule
	fallevent[0][fallorroll] = 1;
	CreateObject(18248, -2263.0061035156, -129.54252624512, 42.238403320313, 0, 0, 71.775085449219);
	fallevent[0][pickid] = CreatePickup(fallicon, 14, -2262.3041992188, -125.28035736084, 34.479076385498);
	fallevent[0][pickx] = -2262.3041992188,fallevent[0][picky] = -125.28035736084,fallevent[0][pickz] = 34.479076385498;
	CreateObject(14397, -2254.076171875, -122.392578125, 32.745571136475, 0, 0, 0);
	CreateObject(14397, -2264.2412109375, -122.921875, 32.745571136475, 0, 0, 0);
	fallevent[0][objid] = CreateObject(3502, -2259.8142089844, -126.25009155273, 44.10831451416, 0, 0, 77.41455078125);
	GetObjectPos(fallevent[0][objid],fallevent[0][ux],fallevent[0][uy],fallevent[0][uz]);
	GetObjectPos(fallevent[0][objid],fallevent[0][ex],fallevent[0][ey],fallevent[0][ez]);
 	MapAndreas_FindZ_For2DCoord(fallevent[0][ex],fallevent[0][ey],fallevent[0][ez]);
	//2 : baustelle wang
	fallevent[1][fallorroll] = 1;
	CreateObject(5126, -2026.1759033203, 273.02798461914, 47.769157409668, 0, 0, 0);
	CreateObject(11406, -2004.7039794922, 273.25604248047, 45.812610626221, 0, 0, 270.27026367188);
	CreateObject(16337, -2019.4510498047, 290.73187255859, 33.48509979248, 0, 0, 270.27026367188);
	fallevent[1][pickid] = CreatePickup(fallicon, 14, -2016.2739257813, 290.47183227539, 33.531028747559);
	fallevent[1][pickx] = -2016.2739257813,fallevent[1][picky] = 290.47183227539,fallevent[1][pickz] = 33.531028747559;
	fallevent[1][objid] = CreateObject(3502, -2005.6781005859, 273.64410400391, 43.910091400146, 0, 0, 270.27026367188);
	GetObjectPos(fallevent[1][objid],fallevent[1][ux],fallevent[1][uy],fallevent[1][uz]);
	GetObjectPos(fallevent[1][objid],fallevent[1][ex],fallevent[1][ey],fallevent[1][ez]);
 	MapAndreas_FindZ_For2DCoord(fallevent[1][ex],fallevent[1][ey],fallevent[1][ez]);
 	fallevent[1][ez]+=0.3;
	//3: stueck zwischen chinatown und dem supermarkt
	fallevent[2][fallorroll] = 1;
	CreateObject(1459, -2281.6909179688, 729.77722167969, 49.044971466064, 0, 0, 300.18017578125);
	CreateObject(1459, -2280.9614257813, 723.36315917969, 49.032863616943, 0, 0, 264.26953125);
	CreateObject(1459, -2280.916015625, 726.71630859375, 49.036693572998, 0, 0, 270.22009277344);
	CreateObject(1459, -2370.1281738281, 723.73815917969, 35.722774505615, 0, 0, 298.18969726563);
	CreateObject(1459, -2370.0844726563, 728.22930908203, 35.732837677002, 0, 0, 256.33032226563);
	CreateObject(3799, -2311.990234375, 729.54174804688, 50.682815551758, 0, 0, 0);
	CreateObject(3799, -2311.9436035156, 729.52313232422, 48.433013916016, 0, 0, 0);
	CreateObject(3799, -2311.8950195313, 729.52795410156, 52.832614898682, 0, 0, 0);
	CreateObject(3799, -2311.9262695313, 729.52844238281, 54.982414245605, 0, 0, 0);
	fallevent[2][pickid] = CreatePickup(fallicon, 14, -2312.12890625, 725.12322998047, 48.726188659668);
	fallevent[2][pickx] = -2312.12890625,fallevent[2][picky] = 725.12322998047,fallevent[2][pickz] = 48.726188659668;
	fallevent[2][objid] = CreateObject(2960, -2311.6501464844, 726.78973388672, 57.731857299805, 0, 0, 260.30029296875);
	GetObjectPos(fallevent[2][objid],fallevent[2][ux],fallevent[2][uy],fallevent[2][uz]);
	GetObjectPos(fallevent[2][objid],fallevent[2][ex],fallevent[2][ey],fallevent[2][ez]);
 	MapAndreas_FindZ_For2DCoord(fallevent[2][ex],fallevent[2][ey],fallevent[2][ez]);
 	fallevent[2][ez]+=0.5;
 	//4: kippender baseball nähe jizzys / bruecke
 	fallevent[3][fallorroll] = 2;
	fallevent[3][objid] = CreateObject(11395, -2525.0454101563, 1203.9753417969, 56.101669311523, 0, 0, 248.43542480469);
	fallevent[3][pickid] = CreatePickup(fallicon, 14, -2524.7827148438, 1196.0773925781, 41.182483673096);
	fallevent[3][pickx] = -2524.7827148438,fallevent[3][picky] = 1196.077392578,fallevent[3][pickz] = 41.182483673096;
	GetObjectPos(fallevent[3][objid],fallevent[3][ux],fallevent[3][uy],fallevent[3][uz]);
	GetObjectRot(fallevent[3][objid],fallevent[3][uax],fallevent[3][uay],fallevent[3][uaz]);
	new tval = CreateObject(11395, -2528.3420410156, 1191.2824707031, 46.101135253906, 0, 85, 248.43383789063);
	GetObjectPos(tval,fallevent[3][ex],fallevent[3][ey],fallevent[3][ez]);
	GetObjectRot(tval,fallevent[3][eax],fallevent[3][eay],fallevent[3][eaz]);
	DestroyObject(tval);
	//5: tunnel nähe bruecke / jizzys
	fallevent[4][fallorroll] = 1;
	CreateObject(3569, -2169.7172851563, 1065.0776367188, 57.401924133301, 0, 0, 220.37524414063);
	CreateObject(3572, -2165.859375, 1046.5588378906, 56.074501037598, 0, 0, 270.45043945313);
	CreateObject(3572, -2165.8435058594, 1046.5590820313, 58.771827697754, 0, 0, 270.44494628906);
	CreateObject(3572, -2179.9152832031, 1085.3035888672, 56.076133728027, 0, 0, 270.44494628906);
	CreateObject(3572, -2179.7475585938, 1085.3612060547, 58.773460388184, 0, 0, 270.45043945313);
	CreateObject(14397, -2154.4296875, 1079.4306640625, 53.151821136475, 0, 0, 0);
	fallevent[4][objid] = CreateObject(3502, -2178.3098144531, 1076.0061035156, 63.056205749512, 0, 0, 25.940002441406);
	CreateObject(3959, -2191.0888671875, 1075.0103759766, 61.003101348877, 0, 0, 0);
	CreateObject(3447, -2177.9328613281, 1075.78125, 62.076240539551, 0, 0, 290.21020507813);
	fallevent[4][pickid] = CreatePickup(fallicon, 14, -2176.2526855469, 1075.6430664063, 54.877529144287);
	fallevent[4][pickx] = -2176.2526855469,fallevent[4][picky] = 1075.6430664063,fallevent[4][pickz] = 54.877529144287;
	GetObjectPos(fallevent[4][objid],fallevent[4][ux],fallevent[4][uy],fallevent[4][uz]);
	tval = CreateObject(3502, -2178.759765625, 1075.9654541016, 56.506767272949, 0, 0, 25.938720703125);
    GetObjectPos(tval,fallevent[4][ex],fallevent[4][ey],fallevent[4][ez]);
    DestroyObject(tval);
    //6: nähe stadion
    fallevent[5][fallorroll] = 1;
    CreateObject(3570, -2232.4267578125, -339.37841796875, 38.213890075684, 0, 0, 0);
	CreateObject(3571, -2232.3752441406, -339.3639831543, 40.91121673584, 0, 0, 0);
	CreateObject(3572, -2232.5522460938, -329.81784057617, 38.210578918457, 0, 0, 0);
	CreateObject(3570, -2232.5153808594, -329.77145385742, 40.907905578613, 0, 0, 0);
	fallevent[5][objid] = CreateObject(2934, -2232.5856933594, -334.60150146484, 43.315761566162, 0, 0, 0);
	fallevent[5][pickid] = CreatePickup(fallicon, 14, -2233.1403808594, -334.94393920898, 37.183166503906);
    fallevent[5][pickx] = -2233.1403808594,fallevent[5][picky] = -334.94393920898,fallevent[5][pickz] = 37.183166503906;
    GetObjectPos(fallevent[5][objid],fallevent[5][ux],fallevent[5][uy],fallevent[5][uz]);
	GetObjectPos(fallevent[5][objid],fallevent[5][ex],fallevent[5][ey],fallevent[5][ez]);
 	MapAndreas_FindZ_For2DCoord(fallevent[5][ex],fallevent[5][ey],fallevent[5][ez]);
 	//7: heu v. fahrschule richtung strand
 	#define heuoffz 2
    fallevent[6][fallorroll] = 1;
	CreateObject(16406, -2544.2822265625, 26.435068130493, 21.917530059814-heuoffz, 0, 0, 85.805114746094);
	fallevent[6][pickid] = CreatePickup(fallicon, 14, -2545.3303222656, 34.988712310791, 15.752055168152);
	fallevent[6][objid] = CreateObject(1454, -2543.6784667969, 34.432674407959, 24.200107574463-heuoffz, 0, 0, 264.31500244141);
	CreateObject(1454, -2543.8627929688, 31.937061309814, 24.200107574463-heuoffz, 0, 0, 264.31457519531);
	CreateObject(1454, -2544.0419921875, 29.876844406128, 24.200107574463-heuoffz, 0, 0, 264.31457519531);
	fallevent[6][pickx] = -2545.3303222656,fallevent[6][picky] = 34.988712310791,fallevent[6][pickz] = 15.752055168152;
	GetObjectPos(fallevent[6][objid],fallevent[6][ux],fallevent[6][uy],fallevent[6][uz]);
	tval = CreateObject(1454, -2545.4436035156, 37.115489959717, 16.243515014648, 0, 0, 264.31457519531);
	GetObjectPos(tval,fallevent[6][ex],fallevent[6][ey],fallevent[6][ez]);
    DestroyObject(tval);
	//8:kino nähe strand/ammunation, kippende tafel
	fallevent[7][fallorroll] = 2;
	fallevent[7][pickid] = CreatePickup(fallicon, 14,-2591.9812011719, 165.93399047852, 3.6275281906128);
	fallevent[7][objid] = CreateObject(6056, -2594.0368652344, 164.31967163086, 14.834365844727, 0, 0, 270.22491455078);
	tval = CreateObject(6056, -2595.197265625, 159.45599365234, 6.4515190124512, 0, 123.99996948242, 270.2197265625);
	GetObjectPos(fallevent[7][objid],fallevent[7][ux],fallevent[7][uy],fallevent[7][uz]);
	GetObjectRot(fallevent[7][objid],fallevent[7][uax],fallevent[7][uay],fallevent[7][uaz]);
	GetObjectPos(tval,fallevent[7][ex],fallevent[7][ey],fallevent[7][ez]);
	GetObjectRot(tval,fallevent[7][eax],fallevent[7][eay],fallevent[7][eaz]);
	DestroyObject(tval);
	fallevent[7][pickx] = -2591.9812011719,fallevent[7][picky] = 165.93399047852,fallevent[7][pickz] = 3.6275281906128;
	//9:krankenhaus, fallender container
	fallevent[8][fallorroll] = 1;
	CreateObject(1393, -2685.5310058594, 566.31518554688, 32.068176269531, 0, 0, 0);
	fallevent[8][objid] = CreateObject(2935, -2685.390625, 566.31518554688, 29.785243988037, 0, 0, 0);
	tval = CreateObject(2935, -2685.390625, 566.31518554688, 15.006858825684, 0, 0, 0);
	fallevent[8][pickid] = CreatePickup(fallicon, 14, -2685.3815917969, 554.0087890625, 14.002467155457);
    fallevent[8][pickx] = -2685.3815917969,fallevent[8][picky] = 554.0087890625,fallevent[8][pickz] = 14.0024671554578;
    GetObjectPos(fallevent[8][objid],fallevent[8][ux],fallevent[8][uy],fallevent[8][uz]);
	GetObjectPos(tval,fallevent[8][ex],fallevent[8][ey],fallevent[8][ez]);
	DestroyObject(tval);
    //10: airport, kippender turm
    fallevent[9][fallorroll] = 2;
    fallevent[9][objid] = CreateObject(3259, -1741.9005126953, -597.28637695313, 14.595653533936, 0, 0, 0);
    tval = CreateObject(3259, -1742.4351806641, -594.03533935547, 14.58437538147, -90, 0, 0);
    fallevent[9][pickid] = CreatePickup(fallicon, 14, -1742.2584228516, -592.84680175781, 16.350337982178);
    fallevent[9][pickx] = -1742.2584228516,fallevent[9][picky] = -592.84680175781,fallevent[9][pickz] = 16.350337982178;
    GetObjectPos(fallevent[9][objid],fallevent[9][ux],fallevent[9][uy],fallevent[9][uz]);
    GetObjectRot(fallevent[9][objid],fallevent[9][uax],fallevent[9][uay],fallevent[9][uaz]);
	GetObjectPos(tval,fallevent[9][ex],fallevent[9][ey],fallevent[9][ez]);
	GetObjectRot(tval,fallevent[9][eax],fallevent[9][eay],fallevent[9][eaz]);
	DestroyObject(tval);
	//11: nähe pd, rollende bäume
	CreateObject(13435, -1603.2102050781, 465.92614746094, 9.653117752075, 0, 0, 130); //10.0 anstatt 9.6
	fallevent[10][fallorroll] = 2;
	fallevent[10][objid] = CreateObject(684, -1605.9144287109, 463.08135986328, 8.3804368972778, 0, 0, 314.1201171875);
	tval = CreateObject(684, -1602.0032958984, 457.17562866211, 6.3276529312134, 0, 0, 248.47607421875+180);
	fallevent[10][pickid] = CreatePickup(fallicon, 14, -1603.5062255859, 460.70913696289, 6.4758329391479);
	fallevent[10][pickx] = -1603.5062255859,fallevent[10][picky] = 460.70913696289,fallevent[10][pickz] = 6.4758329391479;
	GetObjectPos(fallevent[10][objid],fallevent[10][ux],fallevent[10][uy],fallevent[10][uz]);
    GetObjectRot(fallevent[10][objid],fallevent[10][uax],fallevent[10][uay],fallevent[10][uaz]);
	GetObjectPos(tval,fallevent[10][ex],fallevent[10][ey],fallevent[10][ez]);
	GetObjectRot(tval,fallevent[10][eax],fallevent[10][eay],fallevent[10][eaz]);
	DestroyObject(tval);
	//fallevents ende
	
	
	staticpickup[0] = CreatePickup(1247,14,-1604.6794433594,721.50329589844,11.811748504639);
	new quer[256],howmany;
	format(quer,256,"SELECT * FROM nfslv_versteck");
	mysql_query(quer);
	mysql_store_result();
	howmany = mysql_num_fields();
	mysql_free_result();
	
    for(new p=1;p<=howmany;p++)
    {
	    new form[128];
	    format(quer,256,"SELECT * FROM nfslv_versteck WHERE id='%d'",p);
	    mysql_query(quer);
	    mysql_store_result();
	    
	    mysql_fetch_field("x",form);
     	verstecke[p][vx] = floatstr(form);
		mysql_fetch_field("y",form);
     	verstecke[p][vy] = floatstr(form);
     	mysql_fetch_field("z",form);
     	verstecke[p][vz] = floatstr(form);
     	mysql_fetch_field("a",form);
     	verstecke[p][va] = floatstr(form);
		verstecke[p][pickid] = CreatePickup(1273,14,verstecke[p][vx],verstecke[p][vy],verstecke[p][vz]); //versteck
		mysql_free_result();
	}
	
	wtxt = TextDrawCreate(5.000000, 435.000000, "Sonnig");
	TextDrawBackgroundColor(wtxt, 255);
	TextDrawFont(wtxt, 1);
	TextDrawSetOutline(wtxt, 1);
	TextDrawSetProportional(wtxt, 1);
	
	for(new stingerid = 0; stingerid < sizeof(iPickups); stingerid++)
	{
		iPickups[stingerid][0] = -1;
        iPickups[stingerid][1] = -1;
        iPickups[stingerid][2] = -1;
        iPickups[stingerid][3] = -1;
        iPickups[stingerid][4] = -1;
	}
	
	staticpickup[6] = CreatePickup(1274,14,-1638.4340820313,1204.1064453125,7.1796884536743); //autohaus
	staticpickup[7] = CreatePickup(1274,14,-1955.6865,301.8482,41.1963);
	print(" ------- NFS:MW GM geladen --------- ");
	print(" ----------------------------------- ");
	return 1;
}

Float:GetDistance(Float:x1,Float:y1,Float:z1,Float:x3,Float:y3,Float:z3)
{
	return floatsqroot(floatpower(floatabs(floatsub(x3,x1)),2)+floatpower(floatabs(floatsub(y3,y1)),2)+floatpower(floatabs(floatsub(z3,z1)),2));
}

forward changeweather();
public changeweather()
{
	SetWorldTime(24);
	
	HTTP(1,HTTP_POST,"de.wetter.yahoo.com/vereinigte-staaten/kalifornien/san-francisco-2487956/","","sfw");
	return 1;
}

forward sfw(index, response_code, data[]);
public sfw(index, response_code, data[])
{
	new work[128],tid[4];
	tid[1] = strlen("yw-cond")+strfind(data,"yw-cond")+2;
	tid[2] = strfind(data,"</div>",false,tid[1]);
	strmid(work,data,tid[1],tid[2]);
	new found = 0;
	if(strfind(work,"Regen") != -1 || strfind(work,"Schauer") != -1) SetWeather(16); found = 1;
	if(strfind(work,"Nebel") != -1 || strfind(work,"Schnee") != -1) SetWeather(09); found = 1;
	if(found == 0) SetWeather(10);

	new ffind;
	for(new cu=0;cu<=strlen(work);cu++)
	{
		ffind = strfind(work,"Ã¶");
	    if(ffind != -1)
		{
			strdel(work,ffind,ffind+2);
			strins(work,"oe",ffind);
		}
		ffind = strfind(work,"Ã");
	    if(ffind != -1)
		{
			strdel(work,ffind,ffind+2);
			strins(work,"ue",ffind);
		}
		
	}
	new File:checkw = fopen("we.txt",io_write);
	fwrite(checkw,work);
	fclose(checkw);

	TextDrawSetString(wtxt,work);
	
	return 1;
}

public OnGameModeExit()
{
	for(new resp=0;resp!=slots;resp++)
	{
	    ForceClassSelection(resp);
	    SetPlayerHealth(resp,0);
	}
    mysql_close();
	return 1;
}

stock PopPlayerTires(playerid)
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid != 0)
	{
		new panels, doors, lights, tires;
		GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, 15);
	}
}

stock CreateLargeStinger(Float:X, Float:Y, Float:Z, Float:A, virtualworld, timer,playerid)
{
	for(new stingerid = 0; stingerid < sizeof(iPickups); stingerid++)
	{
		if(iPickups[stingerid][0] == -1)
		{
		    new Float:dis1 = floatsin(-A, degrees), Float:dis2 = floatcos(-A, degrees);
			iPickups[stingerid][0] = CreateObject(2892, X, Y, Z, 0.0, 0.0, A,100.0);
			iPickups[stingerid][1] = CreatePickup(1007, 14, X+(4.0*dis1), Y+(4.0*dis2), Z, virtualworld);
			iPickups[stingerid][2] = CreatePickup(1007, 14, X+(1.25*dis1), Y+(1.25*dis2), Z, virtualworld);
			iPickups[stingerid][3] = CreatePickup(1007, 14, X-(4.0*dis1), Y-(4.0*dis2), Z, virtualworld);
			iPickups[stingerid][4] = CreatePickup(1007, 14, X-(1.25*dis1), Y-(1.25*dis2), Z, virtualworld);
			if(timer > 0)
			{
				SetTimerEx("DestroyStinger", timer, 0, "ii", stingerid,playerid); 
			}
			return stingerid;
		}
	}
	return -1;
}

forward DestroyStinger(stingerid,playerid);
public DestroyStinger(stingerid,playerid)
{
	DestroyObject(iPickups[stingerid][0]);
	DestroyPickup(iPickups[stingerid][1]);
	DestroyPickup(iPickups[stingerid][2]);
	DestroyPickup(iPickups[stingerid][3]);
	DestroyPickup(iPickups[stingerid][4]);
	iPickups[stingerid][0] = -1;
	iPickups[stingerid][1] = -1;
	iPickups[stingerid][2] = -1;
	iPickups[stingerid][3] = -1;
	iPickups[stingerid][4] = -1;
}

forward ToggleControle(playerid,istrue);
public ToggleControle(playerid,istrue)
{
	SetPVarInt(playerid,"control",istrue);
	TogglePlayerControllable(playerid,istrue);
	return 1;
}

forward splitfu(strsrc[], strdest[][], delimiter);
public splitfu(strsrc[], strdest[][], delimiter)
{
    new i, li;
    new aNum;
    new len;
    while(i <= strlen(strsrc))
    {
        if(strsrc[i] == delimiter || i == strlen(strsrc))
        {
            len = strmid(strdest[aNum], strsrc, li, i, 128);
            strdest[aNum][len] = 0;
            li = i+1;
            aNum++;
        }
        i++;
    }
    return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid,-1649.9751,1207.4336,20.8567-2);
	SetPlayerVirtualWorld(playerid,playerid+1);

	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT * FROM nfslv_cars WHERE user='%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	new data[512], field[7][256],rlclass=classid;
	mysql_fetch_row(data,"$");
	if(mysql_num_rows()>0)
	{
		for(new lo=0;lo!=rlclass;lo++)
		{
	        mysql_fetch_row(data,"$");
		}
	}
	splitfu(data, field, '$');
	mysql_free_result();
	SetPVarInt(playerid,"carid",strval(field[1]));
	SetPVarInt(playerid,"color1",strval(field[3]));
	SetPVarInt(playerid,"color2",strval(field[4]));
	SetPVarInt(playerid,"paintjob",strval(field[5]));
	SetPVarInt(playerid,"mysqlchoice",strval(field[6]));
	DestroyVehicle(GetPVarInt(playerid,"tcarid"));

	new tca=CreateVehicle(strval(field[1]),-1649.9751,1207.4336,20.8567,60.0213,strval(field[3]),strval(field[4]),500000);
	SetPVarInt(playerid,"tcarid",tca);
	SetVehicleVirtualWorld(tca,playerid+1);
	PutPlayerInVehicle(playerid,tca,0);

	SetPlayerCameraPos(playerid,-1656.3488,1205.5580,21.1563+1);
	SetPlayerCameraLookAt(playerid,-1649.9751,1207.4336,20.8567);

	new mid[16],pos[2];
	pos[1] = -1;
	for(new i=0;i<=13;i++)
	{
		pos[0] = strfind(field[2],"|",true,pos[1]+1);
		pos[1] = strfind(field[2],"|",true,pos[0]+1);
		if(pos[1] == -1) break;
		strmid(mid,field[2],pos[0]+1,pos[1]);
		tuning[playerid][i] = strval(mid);
	}

	for(new tu=0;tu<=13;tu++) AddVehicleComponent(tca,tuning[playerid][tu]);
	if(strval(field[5]) != 9) ChangeVehiclePaintjob(tca,strval(field[5]));

	format(data,512,"%s",VehicleNames[strval(field[1])-400]);
    GameTextForPlayer(playerid,data,3000,3);

	return 1;
}

public OnPlayerConnect(playerid)
{
	loggedin[playerid] = 0,adminlevel[playerid] = 0;
	if(!checkban(playerid)) return 0;
	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT pw FROM login WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
		mysql_free_result();

		format(mysqlquery[playerid],256,"SELECT * FROM nfslv_dt WHERE name = '%s'",player_name[playerid]);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
		if(mysql_num_rows() <= 0)
		{
	    	new nim[16],randomcar,tmpoutput[128];
			GetPlayerName(playerid,nim,16);
			switch(random(3))
			{
			    case 0: randomcar=400;
			    case 1: randomcar=404;
			    case 2: randomcar=458;
			}
			format(mysqlquery[playerid],256,"INSERT INTO nfslv_dt (alvl,name,toplist,igmoney,versteck) VALUES ('0','%s','0','5000','%d')",nim,random(5)+1);
			mysql_query(mysqlquery[playerid]);
			adminlevel[playerid] = 0;
			loggedin[playerid] = 1;

			format(mysqlquery[playerid],256,"SELECT MAX(unid) FROM nfslv_cars");
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			mysql_fetch_field("MAX(unid)",tmpoutput);
			new tuni = strval(tmpoutput)+1;

			format(mysqlquery[playerid],256,"INSERT INTO nfslv_cars (unid,user,carid,tuning,color1,color2,paintjob) VALUES ('%d','%s','%d','|0||0||0||0||0||0||0||0||0||0||0||0||0||0|','%d','%d','9')",tuni,nim,randomcar,random(50),random(50));
			mysql_query(mysqlquery[playerid]);

			new num[16];
  			GetPlayerName(playerid,num,16);
	        format(mysqlquery[playerid],256,"SELECT * FROM nfslv_dt WHERE name = '%s'",num);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();

            mysql_fetch_field("toplist",tmpoutput);
			SetPVarInt(playerid,"toplist",strval(tmpoutput));
			SetPlayerScore(playerid,strval(tmpoutput));
            mysql_fetch_field("igmoney",tmpoutput);
			SetMoney(playerid,strval(tmpoutput));
			mysql_fetch_field("versteck",tmpoutput);
			SetPVarInt(playerid,"versteck",strval(tmpoutput));
			format(tmpoutput,128,"#--");
			TextDrawSetString(txtdraw[1][playerid],tmpoutput);
			for(new i=0;i<=13;i++) tuning[playerid][i] = 0;
		}
		
		mysql_free_result();
		ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"Willkommen zurück","Willkommen auf dem Need for Speed:Most Wanted Server\nDieser Server ist Teil des Savandreas Networks\nWebsite: www.savandreas.com\n\nBitte gib dein Passwort ein:","Absenden","");
	}
	else ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen auf dem Need for Speed:Most Wanted Server\nDieser Server ist Teil des Savandreas Networks\nBans werden im Netzwerk geteilt\n\nBitte gib ein geheimes Passwort ein:","Registrieren","");
	mysql_free_result();
	
	txtdraw[0][playerid] = TextDrawCreate(546.000000, 30.000000, "0 SC");
	TextDrawBackgroundColor(txtdraw[0][playerid], 255);
	TextDrawFont(txtdraw[0][playerid], 3);
	TextDrawLetterSize(txtdraw[0][playerid], 0.500000, 1.000000);
	TextDrawColor(txtdraw[0][playerid], -1);
	TextDrawSetOutline(txtdraw[0][playerid], 1);
	TextDrawSetProportional(txtdraw[0][playerid], 1);

	txtdraw[1][playerid] = TextDrawCreate(500.000000, 23.000000, "#--");
	TextDrawBackgroundColor(txtdraw[1][playerid], 255);
	TextDrawFont(txtdraw[1][playerid], 3);
	TextDrawLetterSize(txtdraw[1][playerid], 0.500000, 5.700000);
	TextDrawColor(txtdraw[1][playerid], -1);
	TextDrawSetOutline(txtdraw[1][playerid], 1);
	TextDrawSetProportional(txtdraw[1][playerid], 1);
	TextDrawUseBox(txtdraw[1][playerid], 1);
	TextDrawBoxColor(txtdraw[1][playerid], 255);
	TextDrawTextSize(txtdraw[1][playerid], 540.000000, 50.000000);

	barrid[1][playerid] = CreateProgressBar(548.000000, 57.000000, 57, 5, COLOR_GREEN, 100); //nitro
	barrid[0][playerid] = CreateProgressBar(45.000000, 322.000000, 90, 5, COLOR_WHITE, 100); //wanted
	
	txtdraw[3][playerid] = TextDrawCreate(546.000000, 42.000000, "0 km/h");
	TextDrawBackgroundColor(txtdraw[3][playerid], 255);
	TextDrawFont(txtdraw[3][playerid], 3);
	TextDrawLetterSize(txtdraw[3][playerid], 0.500000, 1.000000);
	TextDrawColor(txtdraw[3][playerid], COLOR_WHITE);
	TextDrawSetOutline(txtdraw[3][playerid], 1);
	TextDrawSetProportional(txtdraw[3][playerid], 1);
	
	info[playerid] = Create3DTextLabel(" ",COLOR_WHITE,0,0,0,50.0,0,1);
	
	SetPVarInt(playerid,"opponent",-1);
	SetPVarInt(playerid,"autospecid",-1);
	
    SetPlayerMapIcon(playerid, 0, -1604.6794433594,721.50329589844,11.811748504639, 30, 0, 1);
    for(new p=1;p<=5;p++) SetPlayerMapIcon(playerid, p, verstecke[p][vx],verstecke[p][vy],verstecke[p][vz], 31, 0, 0);
    SetPlayerMapIcon(playerid, 6, -1638.4340820313,1204.1064453125,7.1796884536743, 55, 0, 1);
    SetPlayerMapIcon(playerid, 7,-1935.9417,234.5023,34.3125,27,0,1);
    SetPlayerMapIcon(playerid, 8,-1955.6865,301.8482,41.1963,52,0,1);
    for(new uf=0;uf!=sizeof(fallevent);uf++) if(fallevent[uf][triggered] == 0) SetPlayerMapIcon(playerid, uf+9,fallevent[uf][pickx],fallevent[uf][picky],fallevent[uf][pickz], 23, 0);
    
	return 1;
}

getvehhealth(playerid)
{
	new result,Float:heals,rresult[128];
	GetVehicleHealth(GetPlayerVehicleID(playerid),heals);
	result = floatround(heals/100);
	for(new b=0;b!=result;b++) format(rresult,128,"%sII",rresult);
	switch(result)
	{
	    case 1..3: format(rresult,128,"{FF3700}%s",rresult);
	    case 4..7: format(rresult,128,"{FF9E03}%s",rresult);
	    case 8..10: format(rresult,128,"{30A60F}%s",rresult);
	}
	return rresult;
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

forward bansql(playerid,reason[],automa);
public bansql(playerid,reason[],automa)
{
	new sinfo[128];
	GetPlayerName(playerid,player_name[playerid],16);
	if(automa)
	{
	    format(mysqlquery[playerid],256,"Du wurdest gekickt wegen %s",reason);
    	SendClientMessage(playerid,COLOR_RED,mysqlquery[playerid]);
    	return Kick(playerid);
	}
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

public OnPlayerDisconnect(playerid, reason)
{
    GetPlayerName(playerid,player_name[playerid],16);
	if(GetPlayerWantedLevel(playerid) > 0)
	{
	    format(mysqlquery[playerid],256,"UPDATE nfslv_dt SET igmoney=igmoney-%d WHERE name='%s'",GetPlayerWantedLevel(playerid)*3000,player_name[playerid]);
    	mysql_query(mysqlquery[playerid]);
	}
	if(GetPVarInt(playerid,"inrace") == 1)
	{
	    new opponent = GetPVarInt(playerid,"opponent");
	    SetPVarInt(playerid,"inrace",0);
	    SetPVarInt(opponent,"inrace",0);
	    SetPVarInt(playerid,"opponent",-1);
	    SetPVarInt(opponent,"opponent",-1);
		WithMoney(opponent,GetPVarInt(playerid,"startigmoney"));
  		AddMoney(playerid,GetPVarInt(playerid,"startigmoney"));
	    GameTextForPlayer(opponent,"~g~Sieg",3000,3);
	    SendClientMessage(opponent,COLOR_GREY,"Dein Kontrahent hat den Server verlassen");
	    SendClientMessage(opponent,COLOR_GREY,"Du hast automatisch gewonnen");
		addrlmoney(playerid,GetPVarInt(playerid,"startrlmoney"));
		addrlmoney(opponent,-GetPVarInt(playerid,"startrlmoney")); //negativ, geldabzug
		DisablePlayerRaceCheckpoint(playerid);
		DisablePlayerRaceCheckpoint(opponent);
		if(GetPVarInt(playerid,"blacklistrace") && GetPVarInt(opponent,"toplist")<GetPVarInt(playerid,"toplist"))
		{
			new backu=GetPVarInt(playerid,"toplist");
			SetPVarInt(playerid,"toplist",GetPVarInt(opponent,"toplist"));
			SetPVarInt(opponent,"toplist",backu);
		}
		ToggleControle(opponent,1);
	}
	if(GetPVarInt(playerid,"inrace") == 2 && GetPVarInt(playerid,"driveto") == playerid)
	{
		for(new i;i!=slots;i++)
	    {
	        if((GetPVarInt(i,"inrace") == 2 || GetPVarInt(i,"inrace") == 3) && GetPVarInt(i,"driveto") == playerid)
	        {
	            SendClientMessage(i,COLOR_GREY,"Der Veranstalter hat das Rennen verlassen");
	            SendClientMessage(i,COLOR_GREY,"Das Rennen wurde abgesagt");
	            ToggleControle(i,1);
	            DisablePlayerRaceCheckpoint(i);
	            RemovePlayerMapIcon(i,i+20);
	        }
	    }
	}
	for(new p=1;p!=10;p++) RemovePlayerMapIcon(playerid,p);
    DestroyVehicle(GetPVarInt(playerid,"tcarid"));
    Delete3DTextLabel(info[playerid]);
    TextDrawDestroy(txtdraw[0][playerid]);
    TextDrawDestroy(txtdraw[1][playerid]);
    DestroyProgressBar(barrid[0][playerid]);
    DestroyProgressBar(barrid[1][playerid]);
    TextDrawDestroy(txtdraw[3][playerid]);
    DestroyObject(GetPVarInt(playerid,"gpsarr"));
    DestroyObject(GetPVarInt(playerid,"sirene"));
    DestroyObject(GetPVarInt(playerid, "neon"));
    DestroyObject(GetPVarInt(playerid, "neon1"));
    EUM_DestroyForPlayer(playerid);
	savestats(playerid);
	return 1;
}

forward savestats(playerid);
public savestats(playerid)
{
    new formattuning[256];
    format(formattuning,256,"|%d||%d||%d||%d||%d||%d||%d||%d||%d||%d||%d||%d||%d||%d|",tuning[playerid][0],tuning[playerid][1],tuning[playerid][2],tuning[playerid][3],tuning[playerid][4],tuning[playerid][5],tuning[playerid][6],tuning[playerid][7],tuning[playerid][8],tuning[playerid][9],tuning[playerid][10],tuning[playerid][11],tuning[playerid][12],tuning[playerid][13]);
	GetPlayerName(playerid,player_name[playerid],16);
	new savequery[1024];
	format(savequery,1024,"UPDATE nfslv_dt SET alvl='%d', toplist='%d', igmoney='%d', versteck='%d' WHERE name='%s'",adminlevel[playerid],GetPVarInt(playerid,"toplist"),GetPVarInt(playerid,"igmoney"),GetPVarInt(playerid,"versteck"),player_name[playerid]);
	if(GetPVarInt(playerid,"versteck") == 0) return 0;
	mysql_query(savequery);
	
	format(mysqlquery[playerid],256,"UPDATE nfslv_cars SET tuning='%s', color1='%d', color2='%d' WHERE unid='%d'",formattuning,GetPVarInt(playerid,"color1"),GetPVarInt(playerid,"color2"),GetPVarInt(playerid,"mysqlchoice"));
	mysql_query(mysqlquery[playerid]);
//	print(mysqlquery[playerid]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(loggedin[playerid] == 0) return 0;
	if(GetPVarInt(playerid,"iscop") == 1 && GetPlayerWantedLevel(GetPVarInt(playerid,"folgen")) > 0) return spawncop(playerid,1);
	triggerachiv(playerid,23);
	SetPVarInt(playerid,"iscop",0);
	
	new spaces = 5,tmpoutput2[128];
	if(GetPVarInt(playerid,"spmsg") == 0)
	{
	    SetPVarInt(playerid,"spmsg",1);
	    SetTimerEx("cooldown",5000,0,"ii",playerid,5);
	    
	    SendClientMessage(playerid,COLOR_GREY,"Wenn du versuchen willst, die Racer als Cop aufs Korn zu nehmen,");
		SendClientMessage(playerid,COLOR_GREY,"fahr zum Polizeipräsidium und bewirb dich dort");
		SendClientMessage(playerid,COLOR_GREY,"Solltest du ein neues Auto brauchst, schau beim Autohändler vorbei");
		SendClientMessage(playerid,COLOR_GREY,"Wenn du deine Karre aufmotzen willst, fahr zur Tuninggarage");
		SendClientMessage(playerid,COLOR_GREY,"Das Automenü erreichst du durch Drücken der ' 2 '");
		
		if(GetPVarInt(playerid,"toplist") > 0 && GetPVarInt(playerid,"sponce") == 0)
		{
		    SetPVarInt(playerid,"sponce",1);
			format(tmpoutput2,128,"Blacklistfahrer #%d '%s' ist online gekommen",GetPVarInt(playerid,"toplist"),player_name[playerid]);
			SendClientMessageToAll(COLOR_RED,tmpoutput2);
			spaces -= 1;
			for(new inf=0;inf<=GetMaxPlayers();inf++)
			{
			    if(inf != playerid)
			    {
					if(IsPlayerConnected(inf) && ((GetPVarInt(inf,"toplist")-1 == GetPVarInt(playerid,"toplist")) || (GetPVarInt(playerid,"toplist") == 15 && GetPVarInt(inf,"toplist") == 0))) SendClientMessage(inf,COLOR_RED,"Du kannst diesen Spieler nun herausfordern");
					if(((GetPVarInt(playerid,"toplist") == GetPVarInt(inf,"toplist")-1) || (GetPVarInt(inf,"toplist") == 15 && GetPVarInt(playerid,"toplist") == 0)) && IsPlayerConnected(inf))
					{
						GetPlayerName(inf,player_name[inf],16);
						format(tmpoutput2,128,"Blacklistfahrer #%d '%s' ist online",GetPVarInt(inf,"toplist"),player_name[inf]);
						SendClientMessage(playerid,COLOR_RED,tmpoutput2);
						spaces -= 1;
					}
				}
			}
		}
	 	if(spaces > 0) for(new o=0;o!=spaces;o++) SendClientMessage(playerid,COLOR_GREY," ");
 	}
	SetPVarInt(playerid,"spawned",1);
	
    new Float:readit[4];
    if(GetPVarInt(playerid,"versteck") > 0)
    {
		readit[0] = verstecke[GetPVarInt(playerid,"versteck")][vx];
	    readit[1] = verstecke[GetPVarInt(playerid,"versteck")][vy];
	    readit[2] = verstecke[GetPVarInt(playerid,"versteck")][vz];
	    readit[3] = verstecke[GetPVarInt(playerid,"versteck")][va];
	}
	else
	{
	    readit[0] = verstecke[1][vx];
	    readit[1] = verstecke[1][vy];
	    readit[2] = verstecke[1][vz];
	    readit[3] = verstecke[1][va];
	}
	    
	SetWantedLevel(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerInterior(playerid,0);
	ToggleControle(playerid,1);
	SetCameraBehindPlayer(playerid);
	
	DestroyVehicle(GetPVarInt(playerid,"tcarid"));
	new tca;
	tca = CreateVehicle(GetPVarInt(playerid,"carid"),readit[0],readit[1],readit[2],readit[3],GetPVarInt(playerid,"color1"),GetPVarInt(playerid,"color2"),999999);

	switch(GetPVarInt(playerid,"carid"))
	{
	    case 409:triggerachiv(playerid,43);
	    case 416:triggerachiv(playerid,44);
	}

	SetPlayerVirtualWorld(playerid,playerid+1);
	SetVehicleVirtualWorld(tca,playerid+1);
	SetPVarInt(playerid,"vwsp",1);
	for(new tu=0;tu<=13;tu++) AddVehicleComponent(tca,tuning[playerid][tu]);
	if(GetPVarInt(playerid,"paintjob") != 9) ChangeVehiclePaintjob(tca,GetPVarInt(playerid,"paintjob"));
	SetPlayerPos(playerid,readit[0],readit[1],readit[2]);
    SetTimerEx("gettoveh",1000,0,"ii",playerid,tca);
	SetPVarInt(playerid,"tcarid",tca);
	Attach3DTextLabelToPlayer(info[playerid],playerid,0,0,1);
	KillTimer(GetPVarInt(playerid,"ctimer"));
	SetPVarInt(playerid,"ctimer",SetTimerEx("refresh3d",5000,0,"i",playerid));
	KillTimer(GetPVarInt(playerid,"timer"));
	SetPVarInt(playerid,"timer",SetTimerEx("speedo",250,0,"i",playerid));
	KillTimer(GetPVarInt(playerid,"coppostimer"));
	SetPVarInt(playerid,"coppostimer",SetTimerEx("coppostimer",6000,0,"i",playerid) );
	DestroyObject(GetPVarInt(playerid,"sirene"));
	
	SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
	ShowProgressBarForPlayer(playerid, barrid[0][playerid]);
	SetProgressBarValue(barrid[0][playerid],0.0);
	UpdateProgressBar(barrid[0][playerid],playerid);
	
	ShowProgressBarForPlayer(playerid, barrid[1][playerid]);
	SetProgressBarValue(barrid[1][playerid],100.0);
	UpdateProgressBar(barrid[1][playerid],playerid);
	
	for(new ppl=0;ppl!=slots;ppl++)
	{
	    if(ppl != playerid)
	    {
	        HideProgressBarForPlayer(ppl, barrid[0][playerid]);
	        HideProgressBarForPlayer(ppl, barrid[1][playerid]);
	    }
	}
	
	TextDrawShowForPlayer(playerid,txtdraw[0][playerid]);
	TextDrawShowForPlayer(playerid,txtdraw[1][playerid]);
	TextDrawShowForPlayer(playerid,txtdraw[3][playerid]);
	TextDrawShowForPlayer(playerid,wtxt);
	getrlmoney(playerid);//macht textdraw selber

	new fsk2[3],tmpoutput[3][128];
	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT * FROM login WHERE name='%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	mysql_fetch_field("rac_blife",tmpoutput[0]);
	mysql_fetch_field("rac_bneon",tmpoutput[1]);
	mysql_fetch_field("rac_bskin",tmpoutput[2]);
	fsk2[2] = strval(tmpoutput[2])-1; //skin
	fsk2[1] = strval(tmpoutput[1]); //neon
	fsk2[0] = strval(tmpoutput[0]); //health
	mysql_free_result();
	
	if(fsk2[2] == -1) SetPlayerSkin(playerid,101);
	else
	{
		SetPlayerSkin(playerid,fsk2[2]);
		triggerachiv(playerid,36);
	}
	
	if(fsk2[0] > 0)
	{
		SetVehicleHealth(tca,1000.0+float(fsk2[0])*10);
		triggerachiv(playerid,37);
	}
	if(fsk2[1] > 0)
	{
	    DestroyObject(GetPVarInt(playerid, "neon"));
	    DestroyObject(GetPVarInt(playerid, "neon1"));
	    new id = 0;
		switch(fsk2[1])
		{
		    case 1:id = 18648;
		    case 2:id = 18647;
		    case 3:id = 18649;
		    case 4:id = 18652;
		    case 5:id = 18651;
		    case 6:id = 18650;
		}
		triggerachiv(playerid,38);
		SetPVarInt(playerid, "neon", CreateObject(id,0,0,0,0,0,0));
		SetPVarInt(playerid, "neon1", CreateObject(id,0,0,0,0,0,0));
	    AttachObjectToVehicle(GetPVarInt(playerid, "neon"), tca, -0.65, 0.0, -0.35, 0.0, 0.0, 0.0); //-0.70
	    AttachObjectToVehicle(GetPVarInt(playerid, "neon1"), tca, 0.65, 0.0, -0.35, 0.0, 0.0, 0.0);
	}

	return 1;
}

public OnEnterExitModShop(playerid,enterexit,interiorid)
{
	return 1;
}

forward coppostimer(playerid);
public coppostimer(playerid)
{
    KillTimer(GetPVarInt(playerid,"coppostimer"));
	SetPVarInt(playerid,"coppostimer",SetTimerEx("coppostimer",6000,0,"i",playerid) );
	
	if(GetPVarInt(playerid,"vwsp") == 1)
	{
	    new Float:readit[4];
		readit[0] = verstecke[GetPVarInt(playerid,"versteck")][vx];
	    readit[1] = verstecke[GetPVarInt(playerid,"versteck")][vy];
	    readit[2] = verstecke[GetPVarInt(playerid,"versteck")][vz];
		if(!IsPlayerInRangeOfPoint(playerid, 10.0,readit[0],readit[1],readit[2]) || GetPlayerWantedLevel(playerid) > 0)
		{
	    	SetVehicleVirtualWorld(GetPVarInt(playerid,"tcarid"),0);
	    	SetPlayerVirtualWorld(playerid,0);
	    	PutPlayerInVehicle(playerid,GetPVarInt(playerid,"tcarid"),0);
	    	SetPVarInt(playerid,"vwsp",0);
	    	triggerachiv(playerid,41);
		}
	}
	
	//coprespawn
	new Float:gfu[4];
	GetVehicleZAngle(GetPlayerVehicleID(playerid),gfu[3]);
	GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
	if(!IsPlayerInRangeOfPoint(playerid,25,GetPVarFloat(playerid,"sqlx"),GetPVarFloat(playerid,"sqly"),GetPVarFloat(playerid,"sqlz")))
	{
		SetPVarFloat(playerid,"sqlx",gfu[0]);
	    SetPVarFloat(playerid,"sqly",gfu[1]);
	    SetPVarFloat(playerid,"sqlz",gfu[2]);
	    SetPVarFloat(playerid,"sqla",gfu[3]);
	}
    
    //anticheat
    new Float:tz[4];
	GetPlayerPos(playerid,tz[0],tz[1],tz[2]);
	MapAndreas_FindZ_For2DCoord(tz[0],tz[1],tz[3]);
	if(tz[2] >= tz[3]+100 && GetPlayerInterior(playerid) == 0 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 497) bansql(playerid,"Airbreak",1);
	if(GetPlayerWeapon(playerid) > 0 && GetPlayerWeapon(playerid) < 46)
	{
		new gpx[128];
		format(gpx,128,"Waffenhack (%d)",GetPlayerWeapon(playerid));
		bansql(playerid,gpx,1);
	}
	
    return 1;
 }

forward speedo(playerid);
public speedo(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
    SetTimerEx("speedo",250,0,"i",playerid);
    if(!IsPlayerInAnyVehicle(playerid)) return 0;
	new formspeed[128],gpspe;
	gpspe = GetPlayerSpeed(playerid,true);
	format(formspeed,128,"%d km/h",gpspe);
    TextDrawSetString(txtdraw[3][playerid],formspeed);
    if(gpspe > 0 && gpspe < 80) TextDrawColor(txtdraw[3][playerid],COLOR_WHITE);
    if(gpspe > 80 && gpspe < 180) TextDrawColor(txtdraw[3][playerid],COLOR_YELLOW);
    if(gpspe > 180)
	{
        TextDrawColor(txtdraw[3][playerid],COLOR_RED);
        if(GetPlayerWantedLevel(playerid) == 0 && GetPVarInt(playerid,"iscop") == 0)
		{
		    triggerachiv(playerid,24);
			SetWantedLevel(playerid,1);
		}
	}
	
	TextDrawShowForPlayer(playerid,txtdraw[3][playerid]);
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
	TextDrawSetString(txtdraw[0][playerid],tmpoutput2);
	TextDrawShowForPlayer(playerid,txtdraw[0][playerid]);

	return calcu;
}

forward refresh3d(playerid);
public refresh3d(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	KillTimer(GetPVarInt(playerid,"ctimer"));
	SetPVarInt(playerid,"ctimer",SetTimerEx("refresh3d",2000,0,"i",playerid));
    new mform[128];
	GetPlayerName(playerid,player_name[playerid],16);
	if(GetPVarInt(playerid,"iscop") != 1)
	{
	    DestroyObject(GetPVarInt(playerid,"sirene"));
		if(GetPVarInt(playerid,"toplist") > 0) format(mform,128,"%s\nBlacklist #%d\nWantedlevel: %d\n%s",player_name[playerid],GetPVarInt(playerid,"toplist"),GetPlayerWantedLevel(playerid),getvehhealth(playerid));
		else format(mform,128,"%s\nBlacklist #--\nWantedlevel: %d\n%s",player_name[playerid],GetPlayerWantedLevel(playerid),getvehhealth(playerid));
	}
	else
	{
	    format(mform,128,"Polizist %s\nEinsatzstufe: %d\n%s",player_name[playerid],GetPlayerWantedLevel(GetPVarInt(playerid,"folgen")),getvehhealth(playerid));
	}
	if(GetPVarInt(playerid,"invisible") > 0) format(mform,128," ");
	Update3DTextLabelText(info[playerid],COLOR_WHITE,mform);
	SetPlayerScore(playerid,GetPVarInt(playerid,"toplist"));

	if(GetPVarInt(playerid,"toplist") == 0) format(mform,128,"#--");
	else format(mform,128,"#%d",GetPVarInt(playerid,"toplist"));
	TextDrawSetString(txtdraw[1][playerid],mform);
	
	if(GetPlayerVehicleID(playerid) == 413 && GetPlayerVirtualWorld(playerid) == playerid+1) savesql(playerid);

	new Float:th,Float:tz[4];
	GetPlayerPos(playerid,tz[0],tz[1],tz[2]);
	GetVehicleHealth(GetPVarInt(playerid,"tcarid"),th);
	if(GetPVarInt(playerid,"autospecid") == -1 && IsPlayerInAnyVehicle(playerid) && GetPVarInt(playerid,"iscop") == 0) SetPlayerHealth(playerid,th/10);
	MapAndreas_FindZ_For2DCoord(tz[0],tz[1],tz[3]);
	if(tz[3] == 0 && GetPlayerSpeed(playerid,true) < 5 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 497)
	{
	    triggerachiv(playerid,39);
	    if(GetPlayerWantedLevel(playerid) > 0)
	    {
	    	ToggleControle(playerid,1);
			GameTextForPlayer(playerid,"~r~Verhaftet",5000,3);
            WithMoney(playerid,GetPlayerWantedLevel(playerid)*500);
            SetPVarInt(playerid,"heat",0);
            OnPlayerSpawn(playerid);
            
            for(new sc=0;sc!=slots;sc++)
			{
			    if(IsPlayerConnected(sc) && GetPVarInt(sc,"iscop") != 0 && GetPVarInt(sc,"folgen") == playerid)
			    {
			        GameTextForPlayer(sc,"~g~Verhaftet",5000,3);
			        AddMoney(sc,GetPlayerWantedLevel(playerid)*200);
			        triggerachiv(sc,31);
			        if(GetPVarInt(sc,"iscop") == 2) triggerachiv(sc,42);
				}
			}
			SetWantedLevel(playerid,0);
			SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
			SetProgressBarValue(barrid[0][playerid],0.0);
			UpdateProgressBar(barrid[0][playerid],playerid);
		}
		else
		{
		    ToggleControle(playerid,0);
	    	GameTextForPlayer(playerid,"~r~Auto defekt",2000,3);
	    	SetTimerEx("ToggleControle",1000,0,"ii",playerid,1);
			SetTimerEx("OnPlayerSpawn",1100,0,"i",playerid);
		}
		WithMoney(playerid,100);
	}
	if(th <= 220 && th != 0)
	{
	    ToggleControle(playerid,0);
	    GameTextForPlayer(playerid,"~r~Auto defekt",5000,3);
	    WithMoney(playerid,100);
	    if(GetPlayerWantedLevel(playerid) == 0)
		{
			SetTimerEx("ToggleControle",1000,0,"ii",playerid,1);
			SetTimerEx("OnPlayerSpawn",1100,0,"i",playerid);
		}
		triggerachiv(playerid,40);
	}
	return 1;
}

forward SetWantedLevel(playerid,lvl);
public SetWantedLevel(playerid,lvl)
{
	SetPlayerWantedLevel(playerid,lvl);
	switch(lvl)
	{
	    case 0:SetPlayerColor(playerid,0x30A60FAA);
	    case 1:SetPlayerColor(playerid,0xB7FF00AA);
	    case 2:SetPlayerColor(playerid,0x83B504AA);
	    case 3:SetPlayerColor(playerid,0xFF9E03AA);
	    case 4:SetPlayerColor(playerid,0xB36F04AA);
	    case 5:SetPlayerColor(playerid,0xFF3700AA);
	    case 6:SetPlayerColor(playerid,0x691802AA);
	}
	if(lvl!=0) PlayCrimeReportForPlayer(playerid,playerid,lvl+2);
	SetPVarInt(playerid,"escaping",0);
	KillTimer(GetPVarInt(playerid,"escapetimer"));
	if(lvl == 0)
	{
	    SetPVarInt(playerid,"escaping",0);
	    SetPVarInt(playerid,"heat",0);
	    ToggleControle(playerid,1);
	    DestroyPlayerObject(playerid,GetPVarInt(playerid,"tb1"));
	    DestroyPlayerObject(playerid,GetPVarInt(playerid,"tb2"));
	}
	else
	{
	    SetPVarInt(playerid,"escapetimer",SetTimerEx("escape",500,0,"i",playerid));
	    SetPVarInt(playerid,"tb1",CreatePlayerObject(playerid,994, -1939.0089111328, 240.72265625, 33.4609375, 0, 0, 0,100));
        SetPVarInt(playerid,"tb2",CreatePlayerObject(playerid,994, -2717.2495117188, 220.75881958008, 3.484375, 0, 0, 270.27026367188,100));
	}
	return 1;
}

stock GetPlayerSpeed(playerid,bool:kmh) // by misco
{
  new Float:Vx,Float:Vy,Float:Vz,Float:rtn;
  if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),Vx,Vy,Vz); else GetPlayerVelocity(playerid,Vx,Vy,Vz);
  rtn = floatsqroot(floatabs(floatpower(Vx + Vy + Vz,2)));
  return kmh?floatround(rtn * 100 * 1.61):floatround(rtn * 100);
}

forward escape(playerid);
public escape(playerid)
{
	if(GetPlayerWantedLevel(playerid) == 0 || !IsPlayerConnected(playerid)) return 0;
    SetPVarInt(playerid,"escaping",GetPVarInt(playerid,"escaping")+1);
	if(GetPVarInt(playerid,"escaping") >= 60*2*5 && GetPVarInt(playerid,"heat") >= -1) //5 minuten (*2=500ms)
	{
		SetWantedLevel(playerid,GetPlayerWantedLevel(playerid)+1); //startet eigenen timer
		for(new sc=0;sc!=slots;sc++)
		{
		    if(IsPlayerConnected(sc) && GetPVarInt(sc,"iscop") != 0 && GetPVarInt(sc,"folgen") == playerid)
		    {
		        triggerachiv(sc,52);
			}
		}
		return 1;
	}
	new Float:wfc[3],anyone = 0;
	GetPlayerPos(playerid,wfc[0],wfc[1],wfc[2]);
	for(new sc=0;sc!=slots;sc++)
	{
	    if(IsPlayerConnected(sc) && GetPVarInt(sc,"iscop") != 0 && GetPVarInt(sc,"folgen") == playerid)
	    {
	        if(IsPlayerInRangeOfPoint(sc,50,wfc[0],wfc[1],wfc[2]))
	        {
	            anyone = 1;
	            if(IsPlayerInRangeOfPoint(sc,12,wfc[0],wfc[1],wfc[2])) anyone = 2;
	            break;
	        }
	    }
	}
	if(anyone == 1 || anyone == 2)
	{
	    if(anyone == 1 && GetPVarInt(playerid,"heat") < 0) SetPVarInt(playerid,"heat",GetPVarInt(playerid,"heat")+2);
	    if(anyone == 2 && GetPlayerSpeed(playerid,false) <= float(20)) SetPVarInt(playerid,"heat",GetPVarInt(playerid,"heat")+10);
	}
	else
	{
		if(GetPVarInt(playerid,"inverst") == 1) SetPVarInt(playerid,"heat",GetPVarInt(playerid,"heat")-2);
		else SetPVarInt(playerid,"heat",GetPVarInt(playerid,"heat")-1);
	}
	new rh = (GetPlayerWantedLevel(playerid)*100)+GetPVarInt(playerid,"heat");
	
	if(rh <= 0) //case geht nich wg kontanten
	{
	    AddMoney(playerid,GetPlayerWantedLevel(playerid)*200);
	    if(GetPVarInt(playerid,"toplist")>0)
		{
		    new blex=(17-GetPVarInt(playerid,"toplist"))*GetPlayerWantedLevel(playerid)*100;
		    AddMoney(playerid,blex);
		    format(mysqlquery[playerid],256,"Du hast einen Blacklist-Bonus in Höhe von %d$ bekommen",blex);
		    SendClientMessage(playerid,COLOR_GREY,mysqlquery[playerid]);
		}
		switch(GetPlayerWantedLevel(playerid))
		{
		    case 6:triggerachiv(playerid,50);
		}
		SetWantedLevel(playerid,0);
		ToggleControle(playerid,1);
		SetPVarInt(playerid,"heat",0);
		SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
		SetProgressBarValue(barrid[0][playerid],0.0);
		UpdateProgressBar(barrid[0][playerid],playerid);
		GameTextForPlayer(playerid,"~g~Entkommen",5000,3);
		triggerachiv(playerid,32);
		return 1;
	}
	if(rh <= (GetPlayerWantedLevel(playerid)*100)-2) SetProgressBarColor(barrid[0][playerid], 0x92D95BFF);
	if(rh >= (GetPlayerWantedLevel(playerid)*100)-1) SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
	if(rh >= (GetPlayerWantedLevel(playerid)*100)+10) SetProgressBarColor(barrid[0][playerid], 0xFF7F00FF);
	if(rh >= (GetPlayerWantedLevel(playerid)*100)+100)
	{
	    for(new sc=0;sc!=slots;sc++)
		{
		    if(IsPlayerConnected(sc) && GetPVarInt(sc,"iscop") != 0 && GetPVarInt(sc,"folgen") == playerid)
		    {
		        GameTextForPlayer(sc,"~g~Verhaftet",5000,3);
		        AddMoney(sc,GetPlayerWantedLevel(playerid)*200);
		        triggerachiv(sc,31);
		        if(GetPVarInt(sc,"iscop") == 2) triggerachiv(sc,42);
		        switch(GetPlayerWantedLevel(playerid))
				{
				    case 6:triggerachiv(sc,51);
				}
			}
		}
	
	    ToggleControle(playerid,1);
	    SetProgressBarColor(barrid[0][playerid],COLOR_WHITE);
	    UpdateProgressBar(barrid[0][playerid],playerid);
		GameTextForPlayer(playerid,"~r~Verhaftet",5000,3);
        SetPVarInt(playerid,"heat",0);
        WithMoney(playerid,GetPlayerWantedLevel(playerid)*100);
        OnPlayerSpawn(playerid);
        
		SetWantedLevel(playerid,0);
		return 1;
	}
	if(rh > (GetPlayerWantedLevel(playerid)*100)) SetProgressBarValue(barrid[0][playerid], float(rh-(GetPlayerWantedLevel(playerid)*100))); //*10
    new Float:proz,calcint;
	if(rh < (GetPlayerWantedLevel(playerid)*100))
	{
	    proz = (GetPVarInt(playerid,"heat") * 100) / GetPlayerWantedLevel(playerid)*100;
	    calcint = floatround(proz/10);
	    calcint = floatround(calcint/1000)*(-1);
	    SetProgressBarValue(barrid[0][playerid], float(calcint));
	}
	UpdateProgressBar(barrid[0][playerid],playerid);

	//für cops
	for(new gop=0;gop!=slots;gop++)
	{
	    if(IsPlayerConnected(gop) && gop != playerid && GetPVarInt(gop,"folgen") == playerid && GetPVarInt(gop,"iscop") != 0)
	    {
	        if(rh > (GetPlayerWantedLevel(playerid)*100)) SetProgressBarValue(barrid[0][gop], float(rh-(GetPlayerWantedLevel(playerid)*100)));
	        else SetProgressBarValue(barrid[0][gop], float(calcint));
	        
	        if(rh <= (GetPlayerWantedLevel(playerid)*100)-2) SetProgressBarColor(barrid[0][gop], 0x92D95BFF);
			if(rh >= (GetPlayerWantedLevel(playerid)*100)-1) SetProgressBarColor(barrid[0][gop], COLOR_WHITE);
			if(rh >= (GetPlayerWantedLevel(playerid)*100)+10) SetProgressBarColor(barrid[0][gop], 0xFF7F00FF);
	        
	        UpdateProgressBar(barrid[0][gop],gop);
	    }
	}

	KillTimer(GetPVarInt(playerid,"escapetimer"));
	SetPVarInt(playerid,"escapetimer",SetTimerEx("escape",500,0,"i",playerid));
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(GetPVarInt(playerid,"iscop") != 0) return 1;
    if(GetPlayerWantedLevel(playerid) > 0)
	{
		ToggleControle(playerid,1);
		SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
		SetProgressBarValue(barrid[0][playerid],0.0);
		UpdateProgressBar(barrid[0][playerid],playerid);
		GameTextForPlayer(playerid,"~r~Verhaftet",5000,3);
        WithMoney(playerid,GetPlayerWantedLevel(playerid)*100);
        //OnPlayerSpawn(playerid);
        SetPVarInt(playerid,"heat",0);
        for(new sc=0;sc!=slots;sc++)
		{
		    if(IsPlayerConnected(sc) && GetPVarInt(sc,"iscop") != 0 && GetPVarInt(sc,"folgen") == playerid)
		    {
		        GameTextForPlayer(sc,"~g~Verhaftet",5000,3);
		        AddMoney(sc,GetPlayerWantedLevel(playerid)*200);
		        triggerachiv(sc,31);
		        if(GetPVarInt(sc,"iscop") == 2) triggerachiv(sc,42);
			}
		}
		SetWantedLevel(playerid,0);
	}
	WithMoney(playerid,100);
    SetPVarInt(playerid,"spawned",0);
    DestroyVehicle(GetPVarInt(playerid,"tcarid"));
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
	new formmsg[256];
	if(GetPVarInt(playerid,"iscop") == 1)
	{
	    format(formmsg,256,"[Funk] %s",text);
	    for(new sendto=0;sendto!=slots;sendto++) if(IsPlayerConnected(sendto) && GetPVarInt(sendto,"iscop") == 1 && GetPVarInt(playerid,"folgen") == GetPVarInt(sendto,"folgen")) SendClientMessage(sendto,COLOR_FUNK,formmsg);
	}
	else
	{
	    if(strcmp(text,"Trooper ist der Beste") == 0) triggerachiv(playerid,56);
	    GetPlayerName(playerid,player_name[playerid],16);
	    new color[10];
	    switch(GetPlayerWantedLevel(playerid))
		{
		    case 0:strins(color,"30A60F",0);
		    case 1:strins(color,"B7FF00",0);
		    case 2:strins(color,"83B504",0);
		    case 3:strins(color,"FF9E03",0);
		    case 4:strins(color,"B36F04",0);
		    case 5:strins(color,"FF3700",0);
		    case 6:strins(color,"691802",0);
		}
	    format(formmsg,256,"{%s}%s:{AFAFAF} %s",color,player_name[playerid],text);
	    new Float:close[3];
	    GetPlayerPos(playerid,close[0],close[1],close[2]);
	    for(new sendto=0;sendto!=slots;sendto++) if(IsPlayerConnected(sendto) && IsPlayerInRangeOfPoint(sendto,5000000.0,close[0],close[1],close[2])) SendClientMessage(sendto,COLOR_GREY,formmsg);
	}
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(adminlevel[playerid] == 0) return 1;
    dcmd(streetview,10,cmdtext);
    dcmd(movie,5,cmdtext);
	dcmd(sirene,6,cmdtext);
	dcmd(gmx,3,cmdtext);
	dcmd(givecar,7,cmdtext);
	dcmd(invisible,9,cmdtext);
	dcmd(wartung,7,cmdtext);
	dcmd(freeze,6,cmdtext);
	dcmd(setw,4,cmdtext);
	dcmd(unfreeze,8,cmdtext);
	dcmd(spectate,8,cmdtext);
	dcmd(ban,3,cmdtext);
	dcmd(kick,4,cmdtext);
	dcmd(gethere,7,cmdtext);
	return 1;
}

dcmd_streetview(playerid,params[])
{
	new para[2];
	if(sscanf(params, "dd",para[0],para[1])) return SendClientMessage(playerid,COLOR_RED,"/streetview [ID] [1/0]");
	switch(para[1])
	{
	    case 0:
	    {
	        SetPlayerVirtualWorld(playerid,0);
	        DestroyVehicle(GetPVarInt(playerid,"tcarid"));
	        ForceClassSelection(playerid);
	        SetPlayerHealth(playerid,0);
	    }
	    case 1:
	    {
	        new Float:gpu[3];
	        GetPlayerPos(playerid,gpu[0],gpu[1],gpu[2]);
	        SetPlayerVirtualWorld(playerid,playerid+1);
	        DestroyVehicle(GetPVarInt(playerid,"tcarid"));
	        SetPVarInt(playerid,"tcarid",CreateVehicle(413,gpu[0],gpu[1],gpu[2],0,0,0,5000));
	        PutPlayerInVehicle(playerid,GetPVarInt(playerid,"tcarid"),0);
	        SendClientMessage(playerid,COLOR_GREY,"Du bist im Streetview-Auto. Fahr auf den Straßen herum, save alle 2 sekunden");
	    }
	}
	return 1;
}

dcmd_movie(playerid,params[]) 
{
	#pragma unused playerid
	new para[3],strpara[256];
    sscanf(params, "dds",para[0],para[1],strpara);
	switch(para[0])
	{
		case 1:
		{
		    SetWeather(para[1]);
		}
		case 2:
		{
		    TextDrawDestroy(txtdraw[0][para[1]]);
		    TextDrawDestroy(txtdraw[1][para[1]]);
		    DestroyProgressBar(barrid[0][para[1]]);
		    DestroyProgressBar(barrid[1][para[1]]);
		    TextDrawDestroy(txtdraw[3][para[1]]);
		}
		case 3:
		{
		    for(new fa=0;fa!=slots;fa++) RepairVehicle(GetPlayerVehicleID(fa));
		}
		case 4:
		{
		    SendClientMessageToAll(COLOR_RED,strpara);
		}
		case 5:
		{
			TogglePlayerSpectating(para[1],1);
			PlayerSpectateVehicle(para[1],GetPlayerVehicleID(strval(strpara)));
		}
		case 6: TogglePlayerSpectating(para[1],0);
		case 7:
		{
		    AddMoney(para[1],50000);
		    new Float:gp[3];
			GetPlayerPos(para[1],gp[0],gp[1],gp[2]);
			DestroyVehicle(GetPVarInt(para[1],"tcarid"));
			new tcar = CreateVehicle(strval(para[2]),gp[0],gp[1],gp[2],0,0,0,500);
			PutPlayerInVehicle(para[1],tcar,0);
			SetPVarInt(para[1],"tcarid",tcar);
			SetPVarInt(para[1],"carid",strval(para[2]));
		}
		case 8:
		{
		    new Float:px[3];
			GetVehiclePos(GetPlayerVehicleID(para[1]),px[0],px[1],px[2]);
			SetVehiclePos(GetPlayerVehicleID(strval(para[2])),px[0],px[1],px[2]+2);
		}
		case 9:
		{
		    SetPVarInt(para[1],"nitro",0);
		}
		case 10:
		{
		    for(new co=0;co!=slots;co++)
		    {
		        GameTextForPlayer(co,"~r~3",1000,3);
		        SetTimerEx("moviecount",1000,0,"ii",co,3);
		    }
		}
		case 11:
		{
		    PutPlayerInVehicle(para[1],GetPlayerVehicleID(strval(strpara)),1);
		}
		case 12:Delete3DTextLabel(info[para[1]]);
		case 13:
		{
		    new Float:knote[6];
			GetPlayerPos(playerid,knote[0],knote[1],knote[2]);
			GetVehicleZAngle(GetPlayerVehicleID(playerid),knote[3]);
			knote[0]=knote[0]+(para[1] * floatsin(-knote[3], degrees));
			knote[1]=knote[1]+(para[1] * floatcos(-knote[3], degrees));
			SetPlayerRaceCheckpoint(playerid,1,knote[0],knote[1],knote[2],0,0,0,10.0);
		}
		case 14: GameTextForPlayer(para[1],"~r~Verhaftet",3000,3);
	}
	return 1;
}

forward moviecount(playerid,za);
public moviecount(playerid,za)
{
	za -= 1;
	switch(za)
	{
	    case 2:GameTextForPlayer(playerid,"~y~2",1000,3);
	    case 1:GameTextForPlayer(playerid,"~y~1",1000,3);
	    case 0:GameTextForPlayer(playerid,"~g~GO",1000,3);
	}
	if(za != 0) SetTimerEx("moviecount",1000,0,"ii",playerid,za);

	return 1;
}

dcmd_gethere(playerid, params[])
{
	if(adminlevel[playerid] == 0) return 0;
	new Float:px[3];
	GetVehiclePos(GetPlayerVehicleID(playerid),px[0],px[1],px[2]);
	SetVehiclePos(GetPlayerVehicleID(strval(params)),px[0],px[1],px[2]+2);
 	return 1;
}

dcmd_setw(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    wanteds,
		pID;
	if(sscanf(params, "dd",pID,wanteds))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /setw [playerid] [Sterne]");
	}
	SetWantedLevel(pID,wanteds);
	return 1;
}

dcmd_kick(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 0; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "ds",pID,sGrund))
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
	triggerachiv(pID,53);
	Kick(pID);
	return 1;
}

dcmd_ban(playerid, params[])
{
	if(adminlevel[playerid] < 2) { return SendClientMessage(playerid,COLOR_RED,"Du brauchst adm lvl 2 !"); }

	new
	    sGrund[128],
		pID;
	if(sscanf(params, "ds",pID,sGrund))
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
	bansql(pID,sGrund,0);
	return 1;
}

dcmd_sirene(playerid,params[])
{
    if(strval(params) == 1)
	{
		SetPVarInt(playerid,"sirene",CreateObject(18646,0,0,0,0,0,0,100));
		AttachObjectToVehicle(GetPVarInt(playerid,"sirene"),GetPlayerVehicleID(playerid),0.2,0,0.71,0,0,0);
	}
	else DestroyObject(GetPVarInt(playerid,"sirene"));
	return 1;
}

dcmd_gmx(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] == 0) return 1;
	SendClientMessageToAll(COLOR_RED,"Server wird neugestartet");
	SendClientMessageToAll(COLOR_RED,"Fortschritte wurden gespeichert");
	for(new lol=0;lol<=slots;lol++) if(IsPlayerConnected(lol)) savestats(lol);
	GameModeExit();
 	return 1;
}

dcmd_spectate(playerid,params[])
{
	if(adminlevel[playerid] == 0) return 1;
	if(!strlen(params)) return TogglePlayerSpectating(playerid,0);
	TogglePlayerSpectating(playerid,1);
	PlayerSpectateVehicle(playerid,GetPlayerVehicleID(strval(params)));
	return 1;
}

dcmd_wartung(playerid,params[])
{
	#pragma unused params
	if(adminlevel[playerid] != 3) return 1;
	if(wartung == 0)
	{
		SendRconCommand("hostname -Server unter Bearbeitung-");
		wartung = 1;
		SendClientMessageToAll(COLOR_RED,"Der Server wurde in den Wartungszustand versetzt");
		SendClientMessageToAll(COLOR_RED,"Während diesem können nur Teammitglieder auf dem Server bleiben");
		SendClientMessageToAll(COLOR_RED,"Bitte warte, bis der Server wieder freigegeben ist");
		for(new wa=0;wa!=slots;wa++) if(IsPlayerConnected(wa) && adminlevel[wa] == 0) Kick(wa);
	}
	else
	{
	    wartung = 0;
	    SendClientMessageToAll(COLOR_GREEN,"Server wurde geöffnet");
	    new str[128];
    	GetServerVarAsString("hostname", str, sizeof(str));
    	format(str,128,"hostname %s",str);
	    SendRconCommand(str);
	}
	return 1;
}

dcmd_unfreeze(playerid, params[])
{
    if(adminlevel[playerid] == 0) {return 1; }
    if(GetPVarInt(strval(params),"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Spieler wurde noch nicht gemeldet");
	ToggleControle(strval(params),1);
	return 1;
}

dcmd_freeze(playerid, params[])
{
	if(adminlevel[playerid] == 0) {return 1; }
	new
	    sGrund[128],
		pID;
	if(sscanf(params, "ds",pID,sGrund))
	{
		return SendClientMessage(playerid,COLOR_RED,"Syntax: /freeze [playerid] [Grund]");
	}
	if(GetPVarInt(pID,"reported") == 0 && adminlevel[playerid] == 1) return SendClientMessage(playerid,COLOR_RED,"Spieler wurde noch nicht gemeldet");
	if(!IsPlayerConnected(pID))
	{
	    return SendClientMessage(playerid,COLOR_RED,"ID not online");
	}
	new
		ThePlayer[MAX_PLAYER_NAME],
	    string[128];
	GetPlayerName(pID,ThePlayer,sizeof(ThePlayer));
	format(string,sizeof(string),"%s (ID %d) wurde eingefroren,Grund: %s",ThePlayer,pID,sGrund);
	SendClientMessageToAll(COLOR_GREY,string);
	ToggleControle(pID,1);
	return 1;
}

dcmd_invisible(playerid,params[])
{
	if(adminlevel[playerid] == 0) return 1;
	LinkVehicleToInterior(GetPlayerVehicleID(playerid),strval(params));
	SetPVarInt(playerid,"invisible",strval(params));
	return 1;
}

forward savesql(playerid);
public savesql(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return 0;
	new Float:gfu[4],formmsg[1024];
	GetVehiclePos(GetPlayerVehicleID(playerid),gfu[0],gfu[1],gfu[2]);
	GetVehicleZAngle(GetPlayerVehicleID(playerid),gfu[3]);
	if(IsPlayerInRangeOfPoint(playerid,2,GetPVarFloat(playerid,"sqlx"),GetPVarFloat(playerid,"sqly"),GetPVarFloat(playerid,"sqlz"))) return 0;
    SetPVarFloat(playerid,"sqlx",gfu[0]);
    SetPVarFloat(playerid,"sqly",gfu[1]);
    SetPVarFloat(playerid,"sqlz",gfu[2]);
    SetPVarFloat(playerid,"sqla",gfu[3]);
	format(formmsg,1024,"INSERT INTO streetview_lv (x,y,z,a) VALUES ('%f','%f','%f','%f')",gfu[0],gfu[1],gfu[2],gfu[3]);
	mysql_query(formmsg);
	//format(formmsg,128,"Gespeichert ! [%d]",random(5000));
	//SendClientMessage(playerid,COLOR_GREY,formmsg);
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

dcmd_givecar(playerid,params[])
{
	if(adminlevel[playerid] != 3) return 1;
	new Float:gp[3];
	GetPlayerPos(playerid,gp[0],gp[1],gp[2]);
	DestroyVehicle(GetPVarInt(playerid,"tcarid"));
	new tcar = CreateVehicle(strval(params),gp[0],gp[1],gp[2],0,0,0,500);
	PutPlayerInVehicle(playerid,tcar,0);
	SetPVarInt(playerid,"tcarid",tcar);
	SetPVarInt(playerid,"carid",strval(params));
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	TogglePlayerControllable(playerid,1);
	return 1;
}

forward gettoveh(playerid,vehicleid);
public gettoveh(playerid,vehicleid)
{
	if(IsPlayerInAnyVehicle(playerid)) return 1;
	PutPlayerInVehicle(playerid,vehicleid,0);
	SetTimerEx("gettoveh",500,0,"ii",playerid,vehicleid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == 1 && GetPVarInt(playerid,"autospecid") == -1) SetTimerEx("gettoveh",500,0,"ii",playerid,GetPVarInt(playerid,"tcarid"));
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

forward addrlmoney(playerid,moneten);
public addrlmoney(playerid,moneten)
{
    GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"UPDATE login SET rlmoney=rlmoney+%d WHERE name = '%s'",moneten,player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	return 1;
}

forward racewin(playerid,opponent);
public racewin(playerid,opponent)
{
    triggerachiv(playerid,29);
    switch(GetPVarInt(playerid,"startmode"))
    {
        case 2:triggerachiv(playerid,45);
        case 0:triggerachiv(playerid,46);
        case 3:triggerachiv(playerid,47);
    }
	SetPVarInt(playerid,"inrace",0);
	SetPVarInt(opponent,"inrace",0);
	SetPVarInt(playerid,"opponent",-1);
	SetPVarInt(opponent,"opponent",-1);
	WithMoney(opponent,GetPVarInt(playerid,"startigmoney"));
	AddMoney(playerid,GetPVarInt(playerid,"startigmoney"));
	GameTextForPlayer(opponent,"~r~Niederlage",3000,3);
	GameTextForPlayer(playerid,"~g~Sieg",3000,3);
	addrlmoney(playerid,GetPVarInt(playerid,"startrlmoney"));
	addrlmoney(opponent,-GetPVarInt(playerid,"startrlmoney")); //negativ, geldabzug
	DisablePlayerRaceCheckpoint(playerid);
	DisablePlayerRaceCheckpoint(opponent);
	if(GetPVarInt(playerid,"blacklistrace"))
	{
	    triggerachiv(playerid,30);
	    if(GetPVarInt(playerid,"toplist") > GetPVarInt(opponent,"toplist") || (GetPVarInt(opponent,"toplist") ==15 && GetPVarInt(playerid,"toplist") == 0))
	    {
			new backu=GetPVarInt(playerid,"toplist");
	    	SetPVarInt(playerid,"toplist",GetPVarInt(opponent,"toplist"));
	    	SetPVarInt(opponent,"toplist",backu);
		}
		GetPlayerName(playerid,player_name[playerid],16);
		GetPlayerName(opponent,player_name[opponent],16);
		format(mysqlquery[playerid],256,"UPDATE nfslv_cars SET user='%s' WHERE unid='%d'",player_name[playerid],GetPVarInt(opponent,"mysqlchoice"));
		mysql_query(mysqlquery[playerid]);
		format(mysqlquery[playerid],256,"SELECT * FROM nfslv_cars WHERE user='%s'",player_name[opponent]);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
		
		SendClientMessage(playerid,COLOR_GREY,"Du hast den Wagen deines Gegners gewonnen");
		SendClientMessage(opponent,COLOR_GREY,"Du hast deinen Wagen verloren");
		
		if(mysql_num_rows() == 0)
		{
		    mysql_free_result();
		    new tmpoutput[256];
		    SendClientMessage(opponent,COLOR_GREY,"Dir wurde ein neuer Wagen bereitgestellt");
     		format(mysqlquery[playerid],256,"SELECT MAX(unid) FROM nfslv_cars");
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			mysql_fetch_field("MAX(unid)",tmpoutput);
			new randomcar,tuni = strval(tmpoutput)+1;
			mysql_free_result();
            switch(random(3))
			{
			    case 0: randomcar=400;
			    case 1: randomcar=404;
			    case 2: randomcar=458;
			}
			format(mysqlquery[playerid],256,"INSERT INTO nfslv_cars (unid,user,carid,tuning,color1,color2,paintjob) VALUES ('%d','%s','%d','|0||0||0||0||0||0||0||0||0||0||0||0||0||0|','%d','%d','9')",tuni,player_name[opponent],randomcar,random(50),random(50));
			mysql_query(mysqlquery[playerid]);
		}
		mysql_free_result();
		ForceClassSelection(opponent);
		DestroyVehicle(GetPVarInt(opponent,"tcarid"));
		SetPlayerHealth(opponent,0);
	}

	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    DisablePlayerRaceCheckpoint(playerid);
	new opponent = GetPVarInt(playerid,"opponent");
	if(GetPVarInt(playerid,"inrace") == 3)
	{
	    ToggleControle(playerid,0);
	    ShowPlayerDialog(playerid,15,0,"Straßenrennen","Hier wird gerade ein \nStraßenrennen veranstaltet\n\nMöchtest du teilnehmen ?","Ja","Nein");
	    return 1;
	}
	if(GetPVarInt(playerid,"inrace") == 2)
	{
	    triggerachiv(playerid,28);
	    SendClientMessage(playerid,COLOR_GREY,"Du hast das Rennen gewonnen");
		for(new p;p!=slots;p++)
		{
		    if(GetPVarInt(p,"inrace") == 2 && GetPVarInt(p,"driveto") == GetPVarInt(playerid,"driveto"))
		    {
		        DisablePlayerRaceCheckpoint(p);
		        SetPVarInt(p,"inrace",0);
		        if(p!=playerid) SendClientMessage(p,COLOR_GREY,"Du hast das Rennen verloren");
		    }
		}
		AddMoney(playerid,GetPVarInt(playerid,"teilnehmer")*GetPVarInt(playerid,"startigmoney"));
		/*
        if(GetPVarInt(playerid,"toplist")>0)
        {
            new infos[128],boni=(17-GetPVarInt(playerid,"toplist"))*GetPVarInt(playerid,"startigmoney");
            AddMoney(playerid,boni);
			
			format(infos,128,"Du hast einen Blacklist-Bonus von %d$ bekommen",boni);
            SendClientMessage(playerid,COLOR_GREY,infos);
        }
        */
	    return 1;
	}
	if(GetPVarInt(playerid,"inrace") == 1)
	{
	    if(GetPVarInt(playerid,"instart") == 3)
	    {
	        racewin(playerid,opponent);
			return 1;
	    }
	    if(GetPVarInt(playerid,"instart") == 2)
	    {
	        if(GetPVarInt(playerid,"startmode") == 1)
	        {
	            SetPVarInt(playerid,"instart",3);
	            GameTextForPlayer(playerid,"Jetzt zurueck",2000,3);
                SetPlayerRaceCheckpoint(playerid,1,GetPVarFloat(opponent,"startrx"),GetPVarFloat(opponent,"startry"),GetPVarFloat(opponent,"startrz"),0,0,0,15.0);
	            return 1;
	        }
	        if(GetPVarInt(playerid,"startmode") == 2)
	        {
	            if(GetPVarInt(playerid,"driftpoints") >= GetPVarInt(opponent,"driftpoints"))
	            {
	                racewin(playerid,opponent);
	            }
	            else
	            {
	                racewin(opponent,playerid);
	            }
	        
	        	CallRemoteFunction("driftanz","ii",playerid,0);
				CallRemoteFunction("driftanz","ii",opponent,0);
				return 1;
			}
			if(GetPVarInt(playerid,"startmode") == 3)
			{
			    KillTimer(GetPVarInt(playerid,"heatrace"));
			    KillTimer(GetPVarInt(opponent,"heatrace"));
			    SetPVarInt(playerid,"heat",0);
			    SetPVarInt(opponent,"heat",0);
			}
			
	        racewin(playerid,opponent);
			return 1;
	    }
		if(GetPVarInt(playerid,"instart") == 1) return 0;
		if(GetPVarInt(playerid,"instart") == 0)
		{
		    SetPVarInt(playerid,"instart",1);
			if(GetPVarInt(opponent,"instart") == 0)
			{
			    DisablePlayerRaceCheckpoint(playerid);
			    ToggleControle(playerid,0);
				SendClientMessage(playerid,COLOR_GREY,"Warte auf deinen Gegner");
			}
			else
			{
			    DisablePlayerRaceCheckpoint(playerid);
			    ToggleControle(playerid,0);
			    GameTextForPlayer(playerid,"~r~Ready",3000,3);
			    GameTextForPlayer(opponent,"~r~Ready",3000,3);
			    if(GetPVarInt(opponent,"startmode") == 1)
			    {
			        SetPlayerRaceCheckpoint(playerid,0,GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),GetPVarFloat(opponent,"startrx"),GetPVarFloat(opponent,"startry"),GetPVarFloat(opponent,"startrz"),10.0);
                	SetPlayerRaceCheckpoint(opponent,0,GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),GetPVarFloat(opponent,"startrx"),GetPVarFloat(opponent,"startry"),GetPVarFloat(opponent,"startrz"),10.0);
			    }
			    else
			    {
			    	SetPlayerRaceCheckpoint(playerid,1,GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),0,0,0,10.0);
                	SetPlayerRaceCheckpoint(opponent,1,GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),0,0,0,10.0);
				}
				SetTimerEx("startrace",1000,0,"iii",3,playerid,opponent);
				
				if(GetPVarInt(playerid,"startmode") == 2)
				{
					CallRemoteFunction("driftanz","ii",playerid,1);
					CallRemoteFunction("driftanz","ii",opponent,1);
				}

				return 1;
			}
		}
	}
	DisablePlayerRaceCheckpoint(playerid);
	return 1;
}

forward startrace2(sec,playerid,veranst);
public startrace2(sec,playerid,veranst)
{
	sec -= 1;
	switch(sec)
	{
	    case 2: GameTextForPlayer(playerid,"~y~Set",3000,3);
	    case 1: GameTextForPlayer(playerid,"~g~GO",3000,3);
	}
	if(sec == 2) return SetTimerEx("startrace2",1000,0,"iii",sec,playerid,veranst);
	ToggleControle(playerid,1);
    SetWantedLevel(playerid,GetPVarInt(veranst,"startwanteds"));
    
	return 1;
}

forward startrace(sec,playerid,opponent);
public startrace(sec,playerid,opponent)
{
	sec -= 1;
	switch(sec)
	{
	    case 2: GameTextForPlayer(playerid,"~y~Set",3000,3);
	    case 1: GameTextForPlayer(playerid,"~g~GO",3000,3);
	}
	switch(sec)
	{
	    case 2: GameTextForPlayer(opponent,"~y~Set",3000,3);
	    case 1: GameTextForPlayer(opponent,"~g~GO",3000,3);
	}
	if(sec == 2) return SetTimerEx("startrace",1000,0,"iii",sec,playerid,opponent);
	ToggleControle(playerid,1);
	ToggleControle(opponent,1);
    SetWantedLevel(playerid,GetPVarInt(playerid,"startwanteds"));
    SetWantedLevel(opponent,GetPVarInt(playerid,"startwanteds"));
    SetPVarInt(playerid,"instart",2);
    SetPVarInt(opponent,"instart",2);
    if(GetPVarInt(playerid,"startmode") == 3)
	{
	    SetWantedLevel(playerid,6);
        SetWantedLevel(opponent,6);
        SetPVarInt(playerid,"heatrace",SetTimerEx("heatrace_func",5000,0,"i",playerid));
        SetPVarInt(opponent,"heatrace",SetTimerEx("heatrace_func",5000,0,"i",opponent));
	}
	return 1;
}

forward heatrace_func(playerid);
public heatrace_func(playerid)
{
	if(!IsPlayerConnected(playerid) || GetPlayerWantedLevel(playerid) != 6 || GetPVarInt(playerid,"inrace") != 1) return 0;
	SetPVarInt(playerid,"heatrace",SetTimerEx("heatrace_func",5000,0,"i",playerid));
	
	new Float:knote[6],tmp2[128];
	GetPlayerPos(playerid,knote[0],knote[1],knote[2]);
	//GetVehicleZAngle(GetPlayerVehicleID(playerid),knote[3]);
	knote[4]=knote[0]+(125 * floatsin(-knote[3], degrees));
	knote[5]=knote[1]+(125 * floatcos(-knote[3], degrees));
	for(new gc=50;gc<=150;gc+=25)
	{
		format(mysqlquery[playerid],256,"SELECT * FROM streetview_lv WHERE x BETWEEN '%f' AND '%f' && y BETWEEN '%f' AND '%f' ORDER BY x ASC",knote[4]-gc,knote[4]+gc,knote[5]-gc,knote[5]+gc);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
		if(mysql_num_fields() >= 1) break;
		else mysql_free_result();
	}
	if(mysql_num_fields() == 0) return 0;
	mysql_fetch_field("x",tmp2);
	knote[0] = floatstr(tmp2);
	mysql_fetch_field("y",tmp2);
	knote[1] = floatstr(tmp2);
	mysql_fetch_field("z",tmp2);
	knote[2] = floatstr(tmp2);
	mysql_fetch_field("a",tmp2);
	knote[3] = floatstr(tmp2);
	mysql_free_result();
	
	switch(random(2))
	{
	    case 0:
	    {
			new tblock = CreateObject(4526,knote[0],knote[1],knote[2]+1,0,0,knote[3],200.0);
			SetTimerEx("destroyblock",30000,0,"ii",tblock,playerid);
	    }
	    case 1:
	    {
            CreateLargeStinger(knote[0],knote[1],knote[2]-0.5,knote[3]+90, 0, 20000,playerid);
	    }
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

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	for(new go=0;go!=slots;go++)
	{
	    if(objectid == GetPVarInt(go,"fallnail"))
	    {
	        new Float:wtf[6];
	        GetObjectPos(objectid,wtf[0],wtf[1],wtf[2]);
	        GetObjectRot(objectid,wtf[3],wtf[4],wtf[5]);
	        DestroyObject(objectid);
            CreateLargeStinger(wtf[0],wtf[1],wtf[2], wtf[5]-0.5, 0, 20000,go);
            return 1;
	    }
	}
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

forward autohaus(playerid);
public autohaus(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new gky[6];
	GetPlayerKeys(playerid,gky[0],gky[1],gky[2]);
	SetPlayerCameraPos(playerid,-1656.3488,1205.5580,21.1563+1);
	SetPlayerCameraLookAt(playerid,-1649.9751,1207.4336,20.8567);
	SetPlayerVirtualWorld(playerid,playerid+1);
	switch(gky[2])
	{
	    case 128:SetPVarInt(playerid,"autospecid",GetPVarInt(playerid,"autospecid")+1);
	    case -128:SetPVarInt(playerid,"autospecid",GetPVarInt(playerid,"autospecid")-1);
	}
	
	if(gky[0] & KEY_FIRE)
	{
	        SetPlayerVirtualWorld(playerid,0);
	        DestroyVehicle(GetPVarInt(playerid,"tcarid"));
            new tca = CreateVehicle(GetPVarInt(playerid,"carid"),-1643.3273,1213.2695,6.9135,45.5669,GetPVarInt(playerid,"color1"),GetPVarInt(playerid,"color2"),999999);
			SetPlayerPos(playerid,-1643.3273,1213.2695,6.9135);
			for(new tu=0;tu<=13;tu++) AddVehicleComponent(tca,tuning[playerid][tu]);
			if(GetPVarInt(playerid,"paintjob") != 9) ChangeVehiclePaintjob(tca,GetPVarInt(playerid,"paintjob"));
			PutPlayerInVehicle(playerid,tca,0);
			SetPVarInt(playerid,"tcarid",tca);
			SetCameraBehindPlayer(playerid);
			SetPVarInt(playerid,"autospecid",-1);
			SetVehicleHealth(tca,GetPVarFloat(playerid,"thea"));
			return 1;
   	}
	if(gky[0] & KEY_SECONDARY_ATTACK)
	{
		if(GetPVarInt(playerid,"carreq2") <= GetPVarInt(playerid,"igmoney"))
	    {
	        if(GetPVarInt(playerid,"carreq3") == 0 || (GetPVarInt(playerid,"toplist") != 0 && GetPVarInt(playerid,"toplist")<=GetPVarInt(playerid,"carreq3")))
			{
                WithMoney(playerid,GetPVarInt(playerid,"carreq2"));
			    SetPlayerVirtualWorld(playerid,0);
			    SetPVarInt(playerid,"autospecid",-1);
			    triggerachiv(playerid,20);
				new tmpoutput[256];
				format(mysqlquery[playerid],256,"SELECT MAX(unid) FROM nfslv_cars");
				mysql_query(mysqlquery[playerid]);
				mysql_store_result();
				mysql_fetch_field("MAX(unid)",tmpoutput);
				new tuni = strval(tmpoutput)+1;
				GetPlayerName(playerid,player_name[playerid],16);
				format(mysqlquery[playerid],256,"INSERT INTO nfslv_cars (unid,user,carid,tuning,color1,color2,paintjob) VALUES ('%d','%s','%d','|0||0||0||0||0||0||0||0||0||0||0||0||0||0|','%d','%d','9')",tuni,player_name[playerid],GetPVarInt(playerid,"carreq1"),random(50),random(50));
				mysql_query(mysqlquery[playerid]);
				mysql_free_result();
		        SendClientMessage(playerid,COLOR_GREY,"Das Auto wird zum Versteck geliefert");
			}
      	}
	    else SendClientMessage(playerid,COLOR_GREY,"Du kannst dieses Auto noch nicht kaufen");
	}
	if(gky[2] != 0 || GetPVarInt(playerid,"autospecid") < 0)
	{
	    DestroyVehicle(GetPVarInt(playerid,"tcarid"));
		if(GetPVarInt(playerid,"autospecid") < 0) SetPVarInt(playerid,"autospecid",25);
		if(GetPVarInt(playerid,"autospecid") > 25) SetPVarInt(playerid,"autospecid",0);
		
		gky[3] = car_info[GetPVarInt(playerid,"autospecid")][3],gky[4] = car_info[GetPVarInt(playerid,"autospecid")][4];
		gky[5] = car_info[GetPVarInt(playerid,"autospecid")][5];
		
		SetPVarInt(playerid,"carreq1",gky[3]);
		SetPVarInt(playerid,"carreq2",gky[4]);
		SetPVarInt(playerid,"carreq3",gky[5]);
		SetPVarInt(playerid,"tcarid",CreateVehicle(gky[3],-1649.9751,1207.4336,20.8567,60.0213,1,1,5000));
		SetVehicleVirtualWorld(GetPVarInt(playerid,"tcarid"),playerid+1);
		new formout[128];
		clearchat(playerid);
		format(formout,128,"Auto : %s",VehicleNames[gky[3]-400]);
		SendClientMessage(playerid,COLOR_GREY,formout);
		format(formout,128,"Preis : %d",gky[4]);
		SendClientMessage(playerid,COLOR_GREY,formout);
		if(gky[5] != 0) format(formout,128,"Blacklistplatz : %d",gky[5]);
		else if(gky[5] != 0) format(formout,128,"Blacklistplatz : --");
		SendClientMessage(playerid,COLOR_GREY,formout);
		for(new cl=0;cl!=7;cl++) SendClientMessage(playerid,COLOR_GREY," ");
	}
    SetTimerEx("autohaus",100,0,"i",playerid);
	return 1;
}

forward clearchat(playerid);
public clearchat(playerid)
{
	for(new cl=0;cl!=15;cl++) SendClientMessage(playerid,COLOR_GREY," ");
	return 1;
}

forward hidefunc(playerid,verst);
public hidefunc(playerid,verst)
{
	if(!IsPlayerInRangeOfPoint(playerid,10,verstecke[verst][vx],verstecke[verst][vy],verstecke[verst][vz]))
	{
		new lvl=GetPlayerWantedLevel(playerid);
	    switch(lvl)
		{
		    case 0:SetPlayerColor(playerid,0x30A60FAA);
		    case 1:SetPlayerColor(playerid,0xB7FF00AA);
		    case 2:SetPlayerColor(playerid,0x83B504AA);
		    case 3:SetPlayerColor(playerid,0xFF9E03AA);
		    case 4:SetPlayerColor(playerid,0xB36F04AA);
		    case 5:SetPlayerColor(playerid,0xFF3700AA);
		    case 6:SetPlayerColor(playerid,0x691802AA);
		}
		SetPVarInt(playerid,"inverst",0);
	    //SetPlayerColor(playerid,(GetPlayerColor(playerid)|0xFFFFFF00));
	}
	else
	{
	    SetPVarInt(playerid,"inverst",1);
		KillTimer(GetPVarInt(playerid,"hidetimer"));
		SetPVarInt(playerid,"hidetimer",SetTimerEx("hidefunc",10000,0,"ii",playerid,verst));
		SetPlayerColor(playerid,(GetPlayerColor(playerid)&0xFFFFFF00));
	}
 	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == staticpickup[0])
	{
	    DestroyPickup(pickupid);
	    staticpickup[0] = CreatePickup(1247,14,-1604.6794433594,721.50329589844,11.811748504639,0); //pd
	    if(GetPlayerWantedLevel(playerid) > 0)
		{
		    PopPlayerTires(playerid);
		    triggerachiv(playerid,27);
		    return 0;
		}
		if(GetPVarInt(playerid,"iscop") == 0 && GetPlayerWantedLevel(playerid) == 0) return ShowPlayerDialog(playerid,3,0,"Polizist werden","Möchtest du temporär Polizist werden ?","Ja","Nein");
	}
	if(pickupid == staticpickup[7])
	{
	    DestroyPickup(pickupid);
	    staticpickup[7] = CreatePickup(1274,14,-1955.6865,301.8482,41.1963);
	    if(GetPVarInt(playerid,"carsell_cool") == 0)
	    {
	        SetPVarInt(playerid,"carsell_cool",1);
	        SetTimerEx("cooldown",60000,0,"ii",playerid,7);
		    if(GetPlayerWantedLevel(playerid) == 0)
		    {
			    GetPlayerName(playerid,player_name[playerid],16);
				format(mysqlquery[playerid],256,"SELECT * FROM nfslv_cars WHERE user='%s'",player_name[playerid]);
				mysql_query(mysqlquery[playerid]);
				if(mysql_num_rows() == 1) return SendClientMessage(playerid,COLOR_GREY,"Du hast nurnoch ein Auto");
				mysql_store_result();
				new data[512], field[7][256],carslots[50][3],index=0,sellstring[2048],found=0;
				while(mysql_fetch_row(data,"$"))
				{
				    splitfu(data, field, '$');
				    carslots[index][0] = strval(field[1]);
					found=0;
				    for(new chu=0;chu<=sizeof(car_info);chu++)
					{
						if(car_info[chu][3] == carslots[index][0])
						{
						    carslots[index][1]=car_info[chu][4]/2;
						    carslots[index][2]=strval(field[6]);
						    found=1;
						    break;
						}
					}
					if(found == 0) carslots[index][1]=0;
					format(sellstring,2048,"%s | %d$ [%d]\n%s",VehicleNames[carslots[index][0]-400],carslots[index][1],carslots[index][2],sellstring);
				    index += 1;
				}
				mysql_free_result();
			    ShowPlayerDialog(playerid,882,2,"Auto verkaufen",sellstring,"Verkaufen","Abbrechen");
			}
   		}
		return 1;
     	//markme
	}
	if(pickupid == staticpickup[6])
	{
	    DestroyPickup(pickupid);
	    staticpickup[6] = CreatePickup(1274,14,-1638.4340820313,1204.1064453125,7.1796884536743); //autohaus
		if(GetPVarInt(playerid,"iscop") == 0 && GetPlayerWantedLevel(playerid) == 0)
		{
		    new Float:thea;
		    GetVehicleHealth(GetPlayerVehicleID(playerid),thea);
		    SetPVarFloat(playerid,"thea",thea);
		    RemovePlayerFromVehicle(playerid);
		    SetPlayerVirtualWorld(playerid,playerid+1);
		    DestroyVehicle(GetPVarInt(playerid,"tcarid"));
		    SetPVarInt(playerid,"autospecid",0);
		    clearchat(playerid);
			SendClientMessage(playerid,COLOR_GREY,"Drücke Rechts/Links, um zwischen Autos zu wechseln");
			SendClientMessage(playerid,COLOR_GREY,"Drück Enter, um das Auto zu kaufen, und dein aktuelles zu verkaufen");
			SendClientMessage(playerid,COLOR_GREY,"Drück LMouse, um das Autohaus zu verlassen");
			SetTimerEx("autohaus",250,0,"i",playerid);
		}
		return 1;
	}
	if(GetPVarInt(playerid,"iscop") == 1) return 1; //keine platten,vertecke,fallevents für cops
    for(new p=1;p!=5;p++)
    {
	    if(pickupid == verstecke[p][pickid])
	    {
	        if(p != GetPVarInt(playerid,"versteck")) triggerachiv(playerid,54);
	        DestroyPickup(pickupid);
	        verstecke[p][pickid] = CreatePickup(1273,14,verstecke[p][vx],verstecke[p][vy],verstecke[p][vz]); //versteck
			SetPVarInt(playerid,"versteck",p);
			if(GetPVarInt(playerid,"verst_cool") == 0)
			{
			    SetPVarInt(playerid,"verst_cool",1);
			    SetTimerEx("cooldown",20000,0,"ii",playerid,6);
				RepairVehicle(GetPVarInt(playerid,"tcarid"));
				KillTimer(GetPVarInt(playerid,"hidetimer"));
				SetPVarInt(playerid,"hidetimer",SetTimerEx("hidefunc",10000,0,"ii",playerid,p));
				SetPlayerColor(playerid,(GetPlayerColor(playerid)&0xFFFFFF00));
				SetPVarInt(playerid,"inverst",1);
				savestats(playerid);
				if(GetPlayerWantedLevel(playerid)==0) ShowPlayerDialog(playerid,9393,0,"Auto wechseln","Möchtest du das Auto wechseln?","Ja","Nein");
				else triggerachiv(playerid,48);
			}
			return 1;
		}
	}
	for(new su=0;su!=sizeof(fallevent);su++)
	{
	    if(pickupid == fallevent[su][pickid] && fallevent[su][triggered] == 0)
	    {
	        fallevent[su][triggered] = 1;
	        DestroyPickup(pickupid);
            for(new uf=0;uf!=slots;uf++) RemovePlayerMapIcon(uf,su+9);
	        GameTextForPlayer(playerid,"~y~Stopper benutzt",2000,3);
	        triggerachiv(playerid,26);
	        CreateExplosion(fallevent[su][ux],fallevent[su][uy],fallevent[su][uz], 12, 0.1);
	        if(fallevent[su][fallorroll] == 1)
	        {
	            MoveObject(fallevent[su][objid],fallevent[su][ex],fallevent[su][ey],fallevent[su][ez],fallspeed);
	        }
	        else
	        {
	            MoveObject(fallevent[su][objid],fallevent[su][ex],fallevent[su][ey],fallevent[su][ez],20.0);
                RotateObject(fallevent[su][objid],fallevent[su][eax],fallevent[su][eay],fallevent[su][eaz], 20.0);
			}
			return SetTimerEx("resetfall",60000,0,"i",su);
	    }
	}
    for(new stingerid = 0; stingerid < sizeof(iPickups); stingerid++)
	{
    	if(pickupid == iPickups[stingerid][1])
		{
		    new Float:X, Float:Y, Float:Z, Float:A;
		    GetObjectPos(iPickups[stingerid][0], X, Y, Z);
		    GetObjectRot(iPickups[stingerid][0], A, A, A);
		    new Float:dis1 = floatsin(-A, degrees), Float:dis2 = floatcos(-A, degrees);
	        PopPlayerTires(playerid);
	        DestroyPickup(pickupid);
    	    iPickups[stingerid][1] = CreatePickup(1007, 14, X+(4.0*dis1), Y+(4.0*dis2), Z, GetPlayerVirtualWorld(playerid));
    	    break;
    	}
    	else if(pickupid == iPickups[stingerid][2])
		{
	    	new Float:X, Float:Y, Float:Z, Float:A;
		    GetObjectPos(iPickups[stingerid][0], X, Y, Z);
		    GetObjectRot(iPickups[stingerid][0], A, A, A);
		    new Float:dis1 = floatsin(-A, degrees), Float:dis2 = floatcos(-A, degrees);
	        PopPlayerTires(playerid);
	        DestroyPickup(pickupid);
    	    iPickups[stingerid][2] = CreatePickup(1007, 14, X+(1.25*dis1), Y+(1.25*dis2), Z, GetPlayerVirtualWorld(playerid));
    	    break;
    	}
    	else if(pickupid == iPickups[stingerid][3])
		{
		    new Float:X, Float:Y, Float:Z, Float:A;
		    GetObjectPos(iPickups[stingerid][0], X, Y, Z);
		    GetObjectRot(iPickups[stingerid][0], A, A, A);
		    new Float:dis1 = floatsin(-A, degrees), Float:dis2 = floatcos(-A, degrees);
	        PopPlayerTires(playerid);
	        DestroyPickup(pickupid);
			iPickups[stingerid][3] = CreatePickup(1007, 14, X-(4.0*dis1), Y-(4.0*dis2), Z, GetPlayerVirtualWorld(playerid));
    	    break;
    	}
    	else if(pickupid == iPickups[stingerid][4])
		{
		    new Float:X, Float:Y, Float:Z, Float:A;
		    GetObjectPos(iPickups[stingerid][0], X, Y, Z);
		    GetObjectRot(iPickups[stingerid][0], A, A, A);
		    new Float:dis1 = floatsin(-A, degrees), Float:dis2 = floatcos(-A, degrees);
	        PopPlayerTires(playerid);
	        DestroyPickup(pickupid);
			iPickups[stingerid][4] = CreatePickup(1007, 14, X-(1.25*dis1), Y-(1.25*dis2), Z, GetPlayerVirtualWorld(playerid));
    	    break;
    	}
    }
	return 1;
}

forward resetfall(su);
public resetfall(su)
{
	fallevent[su][triggered] = 0;
	fallevent[su][pickid] = CreatePickup(fallicon,14,fallevent[su][pickx],fallevent[su][picky],fallevent[su][pickz]);
	if(fallevent[su][fallorroll] == 1)
	{
		MoveObject(fallevent[su][objid],fallevent[su][ux],fallevent[su][uy],fallevent[su][uz],550.0);
	}
	else
	{
		MoveObject(fallevent[su][objid],fallevent[su][ux],fallevent[su][uy],fallevent[su][uz],550.0);
        SetObjectRot(fallevent[su][objid],fallevent[su][uax],fallevent[su][uay],fallevent[su][uaz]);
	}
	for(new uf=0;uf!=slots;uf++) SetPlayerMapIcon(uf, su+9,fallevent[su][pickx],fallevent[su][picky],fallevent[su][pickz], 23, 0);
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	SetTimerEx("checkmoney",1000,0,"i",playerid);
	return 1;
}

forward checkmoney(playerid);
public checkmoney(playerid)
{
    if(GetPlayerMoney(playerid) >= GetPVarInt(playerid,"igmoney"))
	{
		return bansql(playerid,"Moneyhack (Tuning)",1);
	}
    SetMoney(playerid,GetPVarInt(playerid,"igmoney")-(GetPVarInt(playerid,"igmoney")-GetPlayerMoney(playerid)));
    for(new sv=0;sv<=13;sv++) tuning[playerid][sv] = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid),sv);
    triggerachiv(playerid,25);
    savestats(playerid);
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    SetPVarInt(playerid,"paintjob",paintjobid);
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    //if(GetPlayerInterior(playerid) == 0) bansql(playerid,"Tuninghack");
    if(color1 == 0 && color2 == 0) return 0;
	if(GetPlayerMoney(playerid) >= GetPVarInt(playerid,"igmoney") && (color1 != GetPVarInt(playerid,"color1") ||  color1 != GetPVarInt(playerid,"color1")) ) bansql(playerid,"Moneyhack (Spray)",1);
	SetMoney(playerid,GetPVarInt(playerid,"igmoney")-(GetPVarInt(playerid,"igmoney")-GetPlayerMoney(playerid)));
	SetPVarInt(playerid,"color1",color1);
	SetPVarInt(playerid,"color2",color2);
	triggerachiv(playerid,34);
	savestats(playerid);
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

#define step 15

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPVarInt(playerid,"control") == 0) return 0;

    if((GetPVarFloat(playerid,"startrx") == 0.0 || GetPVarFloat(playerid,"endrx") == 0.0 )&& GetPVarInt(playerid,"choosepos") == 1) //positionswähler
	{
	    new hasn = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), CARMODTYPE_NITRO);
	    SetPVarInt(playerid,"comp",hasn);
	    if(hasn != 0)
	    {
	    	RemoveVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
	    	AddVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
		}
	    
	    if(newkeys == KEY_ANALOG_DOWN || newkeys & KEY_ANALOG_DOWN) SetPVarFloat(playerid,"cy",floatsub(GetPVarFloat(playerid,"cy"),step));
		if(newkeys == KEY_ANALOG_UP || newkeys & KEY_ANALOG_UP) SetPVarFloat(playerid,"cy",floatadd(GetPVarFloat(playerid,"cy"),step));
		if(newkeys == KEY_ANALOG_LEFT || newkeys & KEY_ANALOG_LEFT) SetPVarFloat(playerid,"cx",floatsub(GetPVarFloat(playerid,"cx"),step));
		if(newkeys == KEY_ANALOG_RIGHT || newkeys & KEY_ANALOG_RIGHT) SetPVarFloat(playerid,"cx",floatadd(GetPVarFloat(playerid,"cx"),step));
		new Float:tz;
		MapAndreas_FindZ_For2DCoord(GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),tz);
		SetPVarFloat(playerid,"cz",tz+GetPVarInt(playerid,"ch"));
		
		SetPlayerCameraPos(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz"));
		SetPlayerCameraLookAt(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz")-1);
		
	    if(newkeys == KEY_FIRE || newkeys & KEY_FIRE || newkeys & KEY_ACTION)
	    {
	        if(GetPVarFloat(playerid,"startrx") == 0.0)
	        {
				SetPVarFloat(playerid,"startrx",GetPVarFloat(playerid,"cx"));
				SetPVarFloat(playerid,"startry",GetPVarFloat(playerid,"cy"));
				SetPVarFloat(playerid,"startrz",tz);
				SendClientMessage(playerid,COLOR_GREY,"Startpunkt festgelegt");
				SendClientMessage(playerid,COLOR_GREY,"Markiere nun das Ziel ebenfalls per LMouse");
				return 1;
			}
			if(GetPVarFloat(playerid,"endrx") == 0.0)
	        {
	            if(GetDistance(GetPVarFloat(playerid,"startrx"),GetPVarFloat(playerid,"startry"),0,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),0) < 400.0) return SendClientMessage(playerid,COLOR_GREY,"Zielpunkt zu nah am Startpunkt");
	        	SetPVarFloat(playerid,"endrx",GetPVarFloat(playerid,"cx"));
				SetPVarFloat(playerid,"endry",GetPVarFloat(playerid,"cy"));
				SetPVarFloat(playerid,"endrz",tz);
				SendClientMessage(playerid,COLOR_GREY,"Zielpunkt festgelegt");
				SetCameraBehindPlayer(playerid);
				SetPVarInt(playerid,"choosepos",0);
				showrmenu(playerid);
				return 1;
	        }
		}
	}
	
	if((newkeys == KEY_FIRE || newkeys & KEY_FIRE || newkeys & KEY_ACTION) && GetPVarInt(playerid,"nitst") == 0)
	{
		new hasn = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), CARMODTYPE_NITRO);
		if(hasn == 0 && GetPVarInt(playerid,"comp") == 0) return 1; //kein nitro
		if(hasn != 0 && GetPVarInt(playerid,"comp") == 0) triggerachiv(playerid,33);
		SetPVarInt(playerid,"comp",hasn);
		SetPVarInt(playerid,"nitro",GetPVarInt(playerid,"nitro")+1);
		if(GetPVarInt(playerid,"nitro") >= 100)
		{
		    RemoveVehicleComponent(GetPlayerVehicleID(playerid),hasn);
	    	AddVehicleComponent(GetPlayerVehicleID(playerid),hasn);
	    	SetPVarInt(playerid,"nitst",0);
		    return 1;
		}
		KillTimer(GetPVarInt(playerid,"nitrefi"));
		SetProgressBarValue(barrid[1][playerid],100.0-float(GetPVarInt(playerid,"nitro")));
		UpdateProgressBar(barrid[1][playerid],playerid);
		SetPVarInt(playerid,"nitst",1);
		SetPVarInt(playerid,"nittimer",SetTimerEx("nitrof",100,0,"ii",playerid,hasn));
	}
	if((oldkeys == KEY_FIRE || oldkeys & KEY_FIRE || oldkeys & KEY_ACTION) && GetPVarInt(playerid,"nitst") == 1)
	{
	    SetPVarInt(playerid,"nitst",0);
	    RemoveVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
	    AddVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
	    KillTimer(GetPVarInt(playerid,"nittimer"));
	    SetPVarInt(playerid,"nitrefi",SetTimerEx("nitrefi",300,0,"i",playerid));
	}

	if(newkeys & KEY_SUBMISSION && GetPVarInt(playerid,"inrace") == 0 && GetPlayerWantedLevel(playerid) == 0)
	{
		if(GetPVarInt(playerid,"iscop") == 0) return EUM_ShowForPlayer(playerid, 1, "Was tun ?", "1. Strassenrennen erstellen~n~2. Spieler herausfordern~n~3. Blacklistrennen~n~4. Polizei aergern~n~5. Undercover-Auftraege~n~~n~6. Informationen~n~7. Cheater melden~n~8. Credits~n~9. Auszeichnungen", 9);
		if(GetPVarInt(playerid,"iscop") == 1)
		{
			if(GetPVarInt(playerid,"chopper") == 0) EUM_ShowForPlayer(playerid,5,"Was tun ?","1. Zuruecksetzen~n~2. Zu Helikopter wechseln~n~3. Strassensperre anfordern~n~4. Nagelband anfordern",4);
			else EUM_ShowForPlayer(playerid,6,"Was tun ?","1. Nagelband abwerfen~n~2. Zu Bodeneinheit wechseln",2);
		}
	}
	return 1;
}

forward nitrefi(playerid);
public nitrefi(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new ck[3];
	GetPlayerKeys(playerid,ck[0],ck[1],ck[2]);
	if((ck[0] & KEY_ACTION || ck[0] & KEY_FIRE) && GetPVarInt(playerid,"nitst") == 0)
	{
	    RemoveVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
	    SetPVarInt(playerid,"nitst",1);
	    KillTimer(GetPVarInt(playerid,"nitrefi"));
	    return 1;
	    //return OnPlayerKeyStateChange(playerid,KEY_FIRE,0);
	}
	SetPVarInt(playerid,"nitro",GetPVarInt(playerid,"nitro")-1);
	if(GetPVarInt(playerid,"nitro") <= 0) return 0;
	SetProgressBarValue(barrid[1][playerid],100.0-float(GetPVarInt(playerid,"nitro")));
	UpdateProgressBar(barrid[1][playerid],playerid);
	SetPVarInt(playerid,"nitrefi",SetTimerEx("nitrefi",300,0,"i",playerid));
	return 1;
}

forward nitrof(playerid,comp);
public nitrof(playerid,comp)
{
	if(!IsPlayerConnected(playerid)) return 0;
    
	if(GetPVarInt(playerid,"nitro") >= 100)
	{
	    ToggleControle(playerid,0);
	    RemoveVehicleComponent(GetPlayerVehicleID(playerid),GetPVarInt(playerid,"comp"));
	   	//AddVehicleComponent(GetPlayerVehicleID(playerid),comp);
	   	ToggleControle(playerid,1);
	    return 1;
	}
	SetProgressBarValue(barrid[1][playerid],100.0-float(GetPVarInt(playerid,"nitro")));
	UpdateProgressBar(barrid[1][playerid],playerid);
	new hasn = GetPVarInt(playerid,"comp");
	switch(hasn)
	{
	    case 1008:SetPVarInt(playerid,"nitro",GetPVarInt(playerid,"nitro")+10);
	    case 1009:SetPVarInt(playerid,"nitro",GetPVarInt(playerid,"nitro")+5);
		case 1010:SetPVarInt(playerid,"nitro",GetPVarInt(playerid,"nitro")+2);
	}
	SetPVarInt(playerid,"nittimer",SetTimerEx("nitrof",100,0,"ii",playerid,hasn));
	return 1;
}

stock Float:GetAngleBetweenPoints(Float:X1,Float:Y1,Float:X2,Float:Y2)
{
  new Float:angle=atan2(X2-X1,Y2-Y1);
  if(angle>360)angle-=360;
  if(angle<0)angle+=360;
  return angle;
}

forward cooldown(playerid,ris);
public cooldown(playerid,ris)
{
	switch(ris)
	{
	    case 1:SetPVarInt(playerid,"spawncool",0);
	    case 2:SetPVarInt(playerid,"fordercool",0);
	    case 3:SetPVarInt(playerid,"meldecool",0);
	    case 4:
		{
			SetPVarInt(playerid,"block",0);
			DisablePlayerRaceCheckpoint(playerid);
		}
		case 5:SetPVarInt(playerid,"spmsg",0);
		case 6:SetPVarInt(playerid,"verst_cool",0);
		case 7:SetPVarInt(playerid,"carsell_cool",0);
	}
	return 1;
}

public OnPlayerResponse(playerid, option)
{
    if(EUM_Indentify(playerid, 1)) //1. Strassenrennen~n~2. Spieler herausfordern~n~3. Polizei aergern~n~~n~4. Informationen~n~5.Cheater melden~n~6.Credits
    {
        EUM_DestroyForPlayer(playerid);
        switch(option)
        {
            case 1:
			{
			    SetPVarInt(playerid,"strmoney",100);
				SetPVarFloat(playerid,"endrx",0.0);
				SetPVarFloat(playerid,"endry",0.0);
				SetPVarFloat(playerid,"endrz",0.0);
				SetPVarInt(playerid,"startwanteds",0);
				SetPVarInt(playerid,"startigmoney",0);
				SetPVarInt(playerid,"inrace",2);
				showrmenu(playerid);
				return 1;
			}
			case 2:
            {
                if(GetPVarInt(playerid,"fordercool") == 1) return SendClientMessage(playerid,COLOR_GREY,"Du kannst jede Minute nur eine Person herausfordern");
                new inrange[256],menucount = 0;
                format(inrange,256,"Waehle einen Gegner aus:");
                for(new sear=0;sear!=slots;sear++)
                {
                    if(IsPlayerConnected(sear) && GetPVarInt(sear,"spawned") == 1 && GetPVarInt(playerid,"iscop") == 0 && sear!=playerid)
                    {
                        new Float:gpo[3];
                        GetPlayerPos(sear,gpo[0],gpo[1],gpo[2]);
                        if(IsPlayerInRangeOfPoint(playerid,100.0,gpo[0],gpo[1],gpo[2]))
                        {
                            GetPlayerName(sear,player_name[sear],16);
                            menucount+=1;
                            format(inrange,256,"%s~n~%d. %s",inrange,sear+1,player_name[sear]);
                        }
                    }
                }
                if(menucount == 0) return SendClientMessage(playerid,COLOR_GREY,"Keine Konkurrenten in der Umgebung");
                else EUM_ShowForPlayer(playerid, 3, "Herausfordern",inrange,slots);
                SetPVarInt(playerid,"fordercool",1);
                SetTimerEx("cooldown",60000,0,"ii",playerid,2);
				return 1;
            }
            case 3:
            {
                if(GetPVarInt(playerid,"fordercool") == 1) return SendClientMessage(playerid,COLOR_GREY,"Du kannst jede Minute nur eine Person herausfordern");
                
                for(new sear=0;sear!=slots;sear++)
                {
                    if(IsPlayerConnected(sear) && GetPVarInt(sear,"spawned") == 1 && GetPVarInt(playerid,"iscop") == 0 && sear != playerid)
                    {
                        if((GetPVarInt(playerid,"toplist")-1==GetPVarInt(sear,"toplist")) || (GetPVarInt(playerid,"toplist") == 0 && GetPVarInt(sear,"toplist")==15))
                        {
	                        new Float:gpo[3];
	                        GetPlayerPos(sear,gpo[0],gpo[1],gpo[2]);
	                        if(IsPlayerInRangeOfPoint(playerid,100.0,gpo[0],gpo[1],gpo[2]))
	                        {
	                            race(playerid,sear,1);
	                            return 1;
	                        }
                        }
                    }
                }
                SetPVarInt(playerid,"fordercool",1);
                SendClientMessage(playerid,COLOR_GREY,"Kein Blacklistfahrer in der Umgebung");
                SetTimerEx("cooldown",60000,0,"ii",playerid,2);
                return 1;
            }
            case 4:
            {
                if(GetPlayerWantedLevel(playerid)<6)
                {
					ToggleControle(playerid,0);
					SetTimerEx("argern",5000,0,"i",playerid);
				}
				return 1;
            }
            case 5:
            {
                new endstring[1024];
				for(new sort=1;sort<=6;sort++)
				{
					for(new sul=0;sul!=slots;sul++)
					{
					    if(IsPlayerConnected(sul) && GetPlayerWantedLevel(sul) == sort)
					    {
					        GetPlayerName(sul,player_name[sul],16);
					        format(endstring,1024,"[%d*]%s[ID %d]\n%s",sort,player_name[sul],sul,endstring);
					    }
					}
				}
				if(strlen(endstring) < 5) return SendClientMessage(playerid,COLOR_GREY,"Aktuell wirst du nicht benötigt");
				ShowPlayerDialog(playerid,3334,2,"Aufträge",endstring,"Verfolgen","Abbrechen");
            }
            case 6:return ShowPlayerDialog(playerid,912,0,"Informationen","Auf diesem Server des Savandreas Networks geht es um\neine möglichst gute Umsetzung des Spieles 'Need for Speed:Most Wanted'\nin ein für GTA San Andreas passendes Spielprinzip\n\nNaechste Seite: Die Blacklist","Weiter","Abbrechen");
			case 7:
			{
			    if(GetPVarInt(playerid,"meldecool") == 1) return SendClientMessage(playerid,COLOR_GREY,"Du kannst jede Minute nur eine Person melden");
                SetPVarInt(playerid,"meldecool",1);
                SetTimerEx("cooldown",60000,0,"ii",playerid,3);
			    new inrange[256],menucount = 0;
                format(inrange,256,"Wer hat gecheatet ?");
                for(new sear=0;sear!=slots;sear++)
                {
                    if(IsPlayerConnected(sear) && GetPVarInt(sear,"spawned") == 1 && sear != playerid)
                    {
                        new Float:gpo[3];
                        GetPlayerPos(sear,gpo[0],gpo[1],gpo[2]);
                        if(IsPlayerInRangeOfPoint(playerid,500.0,gpo[0],gpo[1],gpo[2]))
                        {
                            GetPlayerName(sear,player_name[sear],16);
                            menucount += 1;
                            format(inrange,256,"%s~n~%d. %s",inrange,sear+1,player_name[sear]);
                        }
                    }
                }
                if(menucount == 0) SendClientMessage(playerid,COLOR_GREY,"Keine Spieler in der Umgebung");
                else EUM_ShowForPlayer(playerid, 4, "Melden",inrange,slots);
                return 1;
			}
			case 8:
			{
			    triggerachiv(playerid,35);
				return ShowPlayerDialog(playerid,916,0,"Credits","Trooper[Y]\tScripting\nStrickenkid\tMySQL Plugin\nLuka P.\tEUM\nToribio\t\tProgressbar\n[nl]daplayer\tRotation-Include","Ok","");
			}
			case 9:return showachiv(playerid);
		}
        return 1;
    }
    if(EUM_Indentify(playerid, 3))
	{
		EUM_DestroyForPlayer(playerid);
		race(playerid,option-1,0);
		return 1;
	}
    if(EUM_Indentify(playerid, 4)) //cheatermeldung
    {
        new formrep[256];
        SetPVarInt(option-1,"reported",1);
		GetPlayerName(playerid,player_name[playerid],16);
		GetPlayerName(option-1,player_name[option-1],16);
        format(formrep,256,"[Adm] Spieler %s (%d) hat Spieler %s (%d) gemeldet",player_name[playerid],playerid,player_name[option-1],option-1);
        for(new rep=0;rep!=slots;rep++) if(adminlevel[rep] > 0 && IsPlayerConnected(rep)) SendClientMessage(rep,COLOR_RED,formrep);
        SendClientMessage(playerid,COLOR_GREEN,"Deine Meldung wurde abgeschickt und wird bearbeitet");
        SendClientMessage(playerid,COLOR_GREEN,"Vielen Dank, dass Sie Cheater melden und helfen,");
        SendClientMessage(playerid,COLOR_GREEN,"den Server sauber zu halten");
		return EUM_DestroyForPlayer(playerid);
    }
    if(EUM_Indentify(playerid, 5))
    {
        EUM_DestroyForPlayer(playerid);
        switch(option)
        {
            case 1: spawncop(playerid,0);
            case 2:
            {
                new choppi[2];
				switch(GetPlayerWantedLevel(GetPVarInt(playerid,"folgen")))
				{
				    case 1,2:choppi[0] = 0;
				    case 3,4:choppi[0] = 1;
				    case 5,6:choppi[0] = 2;
				}
				for(new gc=0;gc!=slots;gc++) if(IsPlayerConnected(gc) && GetPVarInt(gc,"iscop") == 1 && GetPVarInt(gc,"folgen") == GetPVarInt(playerid,"folgen") && GetPVarInt(playerid,"chopper") == 1) choppi[1] += 1;
				if(choppi[1] >= choppi[0]) return SendClientMessage(playerid,COLOR_GREY,"Aktuell keine Helikopterunterstützung frei");
                SetPVarInt(playerid,"chopper",1);
                new Float:pu[3];
                GetPlayerPos(playerid,pu[0],pu[1],pu[2]);
                DestroyVehicle(GetPVarInt(playerid,"tcarid"));
                SetPVarInt(playerid,"tcarid",CreateVehicle(497,pu[0],pu[1],pu[2]+250,0,0,0,5000));
                PutPlayerInVehicle(playerid,GetPVarInt(playerid,"tcarid"),0);
                return 1;
            }
            case 3:
            {
                if(GetPVarInt(playerid,"block") == 1) return SendClientMessage(playerid,COLOR_GREY,"Die alte Blockade wurde noch nicht abgebaut");
                SetPVarInt(playerid,"block",1);
                SetTimerEx("cooldown",20000,0,"ii",playerid,4);
                
				new Float:knote[6],tmp2[128];
				GetPlayerPos(GetPVarInt(playerid,"folgen"),knote[0],knote[1],knote[2]);
				//GetVehicleZAngle(GetPlayerVehicleID(GetPVarInt(playerid,"folgen")),knote[3]);
				knote[4]=knote[0]+(175 * floatsin(-knote[3], degrees));
				knote[5]=knote[1]+(175 * floatcos(-knote[3], degrees));
				for(new gc=50;gc<=400;gc+=25)
				{
					format(mysqlquery[playerid],256,"SELECT * FROM streetview_lv WHERE x BETWEEN '%f' AND '%f' && y BETWEEN '%f' AND '%f' ORDER BY x ASC",knote[4]-gc,knote[4]+gc,knote[5]-gc,knote[5]+gc);
					mysql_query(mysqlquery[playerid]);
					mysql_store_result();
					if(mysql_num_fields() >= 1) break;
					else mysql_free_result();
				}
				if(mysql_num_fields() == 0) return SendClientMessage(playerid,COLOR_GREY,"Es gab Fehler beim Aufbau, versuch es später noch einmal");
				mysql_fetch_field("x",tmp2);
				knote[0] = floatstr(tmp2);
				mysql_fetch_field("y",tmp2);
				knote[1] = floatstr(tmp2);
				mysql_fetch_field("z",tmp2);
				knote[2] = floatstr(tmp2);
				mysql_fetch_field("a",tmp2);
				knote[3] = floatstr(tmp2);
				mysql_free_result();

				new tblock = CreateObject(4526,knote[0],knote[1],knote[2]+1,0,0,knote[3],200.0);
				SetTimerEx("destroyblock",30000,0,"ii",tblock,playerid);
				SetPlayerRaceCheckpoint(playerid,1,knote[0],knote[1],knote[2],0,0,0,30);
				return 1;
            }
            case 4:
            {
                if(GetPVarInt(playerid,"block") == 1) return SendClientMessage(playerid,COLOR_GREY,"Die alte Blockade wurde noch nicht abgebaut");
                SetPVarInt(playerid,"block",1);
                SetTimerEx("cooldown",20000,0,"ii",playerid,4);
                
				new Float:knote[6],tmp2[128];
				GetPlayerPos(GetPVarInt(playerid,"folgen"),knote[0],knote[1],knote[2]);
				//GetVehicleZAngle(GetPlayerVehicleID(GetPVarInt(playerid,"folgen")),knote[3]);
				knote[4]=knote[0]+(175 * floatsin(-knote[3], degrees));
				knote[5]=knote[1]+(175 * floatcos(-knote[3], degrees));
				for(new gc=50;gc<=400;gc+=25)
				{
					format(mysqlquery[playerid],256,"SELECT * FROM streetview_lv WHERE x BETWEEN '%f' AND '%f' && y BETWEEN '%f' AND '%f' ORDER BY x ASC",knote[4]-gc,knote[4]+gc,knote[5]-gc,knote[5]+gc);
					mysql_query(mysqlquery[playerid]);
					mysql_store_result();
					if(mysql_num_fields() >= 1) break;
					else mysql_free_result();
				}
				if(mysql_num_fields() == 0) return SendClientMessage(playerid,COLOR_GREY,"Es gab Fehler beim Aufbau, versuch es später noch einmal");
				mysql_fetch_field("x",tmp2);
				knote[0] = floatstr(tmp2);
				mysql_fetch_field("y",tmp2);
				knote[1] = floatstr(tmp2);
				mysql_fetch_field("z",tmp2);
				knote[2] = floatstr(tmp2);
				mysql_fetch_field("a",tmp2);
				knote[3] = floatstr(tmp2);
				mysql_free_result();

				CreateLargeStinger(knote[0],knote[1],knote[2]-0.5,knote[3]+90, 0, 20000,playerid);
				SetPlayerRaceCheckpoint(playerid,1,knote[0],knote[1],knote[2],0,0,0,30);
				return 1;
            }
        }
    }
    if(EUM_Indentify(playerid, 6))
    {
        EUM_DestroyForPlayer(playerid);
        switch(option)
        {
            case 2:
			{
				SetPVarInt(playerid,"chopper",0);
				return spawncop(playerid,1);
			}
            case 1:
            {
                if(GetPVarInt(playerid,"block") == 1) return SendClientMessage(playerid,COLOR_GREY,"Das alte Nagelband wurde noch nicht entfernt");
                SetPVarInt(playerid,"block",1);
                SetTimerEx("cooldown",20000,0,"ii",playerid,4);
                
                new Float:gfx[5];
                GetPlayerPos(playerid,gfx[0],gfx[1],gfx[2]);
                GetVehicleZAngle(GetPlayerVehicleID(playerid),gfx[4]);
                new tobj=CreateObject(2892,gfx[0],gfx[1],gfx[2],0,0,gfx[4]+90,100.0);
                SetPVarInt(playerid,"fallnail",tobj);
                MapAndreas_FindZ_For2DCoord(gfx[0],gfx[1],gfx[3]);
                MoveObject(tobj,gfx[0],gfx[1],gfx[3],40.0);
                triggerachiv(playerid,22);
                return 1;
            }
		}
	}
	/*
	if(EUM_Indentify(playerid, 7)) //EUM_ShowForPlayer(playerid, 7, "Zuruecksetzen ?","Moechtest du zuruecksetzen?\n1. Ja\n2. Nein",2);
	{
	    EUM_DestroyForPlayer(playerid);
		if(option == 1) spawncop(playerid);
	}
	*/ //zu nervig
	EUM_DestroyForPlayer(playerid);
    return 1;
}

forward destroyblock(id,playerid);
public destroyblock(id,playerid)
{
	SetPVarInt(playerid,"block",0);
	return DestroyObject(id);
}

forward race(playerid,opponent,blacklist);
public race(playerid,opponent,blacklist)
{
	if(playerid == opponent) return 0;
	if(GetPlayerWantedLevel(opponent) > 0)
	{
	    SendClientMessage(playerid,COLOR_GREY,"Dein Gegner hat noch Wanteds");
	    return 0;
	}
	if(blacklist)
	{
	    new costen = (17-GetPVarInt(playerid,"toplist"))*10000;
	    if(GetPVarInt(playerid,"igmoney")<costen)
	    {
	        format(mysqlquery[playerid],256,"Du benötigst mind. %d$, um diesen Platz herausfordern zu können",costen);
			return SendClientMessage(playerid,COLOR_GREY,mysqlquery[playerid]);
	    }
	}
    
	GetPlayerName(playerid,player_name[playerid],16);
	GetPlayerName(opponent,player_name[opponent],16);
	SetPVarString(playerid,"opponent_name",player_name[opponent]);
	SetPVarString(opponent,"opponent_name",player_name[playerid]);
	
	SetPVarInt(playerid,"inrace",1);
	SetPVarInt(opponent,"inrace",1);
	SetPVarInt(playerid,"startmode",0);
	SetPVarInt(opponent,"startmode",0);
	SetPVarInt(playerid,"opponent",opponent);
	SetPVarInt(opponent,"opponent",playerid);
	SetPVarInt(playerid,"blacklistrace",blacklist);
	SetPVarInt(opponent,"blacklistrace",blacklist);
	SetPVarFloat(playerid,"startrx",0.0);
	SetPVarFloat(playerid,"startry",0.0);
	SetPVarFloat(playerid,"startrz",0.0);
	SetPVarFloat(playerid,"endrx",0.0);
	SetPVarFloat(playerid,"endry",0.0);
	SetPVarFloat(playerid,"endrz",0.0);
	SetPVarInt(playerid,"startwanteds",0);
	SetPVarInt(playerid,"startigmoney",0);
	SetPVarInt(playerid,"startrlmoney",0);
	SendClientMessage(playerid,COLOR_GREY,"Bitte treffen Sie alle nötigen Einstellungen für das Rennen");
	SendClientMessage(opponent,COLOR_GREY,"Ihr Kontrahent stellt die Rennbedingungen ein, bitte warten");
	showrmenu(playerid);
	return 1;
}

forward argern(playerid);
public argern(playerid)
{
    ToggleControle(playerid,1);
    SetWantedLevel(playerid,GetPlayerWantedLevel(playerid)+2);
    triggerachiv(playerid,21);
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 0;
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

forward inrace3(playerid);
public inrace3(playerid)
{
	if(GetPVarInt(playerid,"inrace") == 3) SetPVarInt(playerid,"inrace",0);
	return 1;
}

forward startstreetr(playerid);
public startstreetr(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new countteil=0;
    for(new i;i!=slots;i++)
	{
		if(GetPVarInt(i,"inrace") == 3 && GetPVarInt(i,"driveto") == playerid)
		{
	    	SendClientMessage(i,COLOR_GREY,"Das Rennen wurde ohne dich gestartet");
            DisablePlayerRaceCheckpoint(i);
            RemovePlayerMapIcon(i,i+20);
            SetPVarInt(i,"inrace",0);
      	}
      	if(GetPVarInt(i,"inrace") == 2 && GetPVarInt(i,"driveto") == playerid) countteil+=1;
  	}
  	if(countteil <= 1)
  	{
  	    SendClientMessage(playerid,COLOR_GREY,"Das Rennen wurde wegen zu wenigen Teilnehmern abgesagt");
        DisablePlayerRaceCheckpoint(playerid);
        RemovePlayerMapIcon(playerid,playerid+20);
        SetPVarInt(playerid,"inrace",0);
        ToggleControle(playerid,1);
        return 1;
  	}
  	SetPVarInt(playerid,"teilnehmer",countteil);
  	for(new i;i!=slots;i++)
	{
		if(GetPVarInt(i,"inrace") == 2 && GetPVarInt(i,"driveto") == playerid)
      	{
      	    RemovePlayerMapIcon(i,i+20);
      	    SendClientMessage(i,COLOR_GREY,"Das Rennen wird gestartet");
      	    GameTextForPlayer(i,"~r~Ready",3000,3);
      	    SetPlayerRaceCheckpoint(i,1,GetPVarFloat(playerid,"endrx"),GetPVarFloat(playerid,"endry"),GetPVarFloat(playerid,"endrz"),0,0,0,10.0);
			SetTimerEx("startrace2",1000,0,"iii",3,i,playerid);
			WithMoney(i,GetPVarInt(playerid,"startigmoney"));
			SetPVarInt(i,"teilnehmer",countteil);
      	}
  	}
	    
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
    if(!response && (dialogid == 1 || dialogid == 2)) return Kick(playerid);
	switch(dialogid)
	{
	    case 882:
	    {
	        if(!response) return 1;
	        GetPlayerName(playerid,player_name[playerid],16);
	        new selopt[2],prog[128];
	        strmid(prog,inputtext,strfind(inputtext," | ")+3,strfind(inputtext," ",false,strfind(inputtext," | ")+4)-1);
	        selopt[0] = strval(prog);
	        strmid(prog,inputtext,strfind(inputtext,"[")+1,strfind(inputtext,"]"));
	        selopt[1]=strval(prog);
	        strmid(prog,inputtext,0,strfind(inputtext," | "));

	        for(new sufu=0;sufu<=sizeof(car_info);sufu++)
	        {
	            if(strcmp(prog,VehicleNames[car_info[sufu][3]-400]) == 0)
	            {
	                
	                format(mysqlquery[playerid],256,"DELETE FROM nfslv_cars WHERE unid='%d'",selopt[1]);
					mysql_query(mysqlquery[playerid]);
					AddMoney(playerid,car_info[sufu][4]);
					SendClientMessage(playerid,COLOR_GREY,"Auto erfolgreich verkauft");
					triggerachiv(playerid,49);
					return 1;
	            }
	        }
			SendClientMessage(playerid,COLOR_GREY,"ERROR");
	        return 1;
	    }
	    case 9393:
	    {
	        if(!response) return 1;
			ForceClassSelection(playerid);
			DestroyVehicle(GetPVarInt(playerid,"tcarid"));
			SetPlayerHealth(playerid,0);
	    }
	    case 15:
	    {
	        if(!response)
	        {
	            ToggleControle(playerid,1);
	            SetPVarInt(playerid,"instart",0);
	            SetPVarInt(playerid,"inrace",0);
	            DisablePlayerRaceCheckpoint(playerid);
             	RemovePlayerMapIcon(playerid,playerid+20);
             	return 1;
	        }
	        ToggleControle(playerid,0);
		    SendClientMessage(playerid,COLOR_GREY,"Warte auf den Start des Rennens");
		    SetPVarInt(playerid,"instart",1);
		    SetPVarInt(playerid,"inrace",2);
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
	        format(message, sizeof(message), "Nachricht gesendet an %s(%d): %s", clickedplayer, ClickedPlayerID, inputtext);
	        SendClientMessage(playerid, 0xFFFFFFFF, message);
	        format(message, sizeof(message), "Nachricht von %s(%d): %s", playername, playerid, inputtext);
	        SendClientMessage(ClickedPlayerID[playerid], 0xFFFFFFFF, message);
	        return 1;

	    }
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
            ShowPlayerDialog(playerid,910,0,inputtext,ffield,"Zurück","Schließen");
            return 1;
        }
        case 910:
        {
            if(!response) return 0;
            showachiv(playerid);
        }
	    case 12: //Einsatz festlegen\nWantedlevel festlegen\nZiel festlegen\nRennen starten
		{
		    if(!response) return SetPVarInt(playerid,"inrace",0);
		    switch(listitem)
		    {
		        case 2:
				{
				    new Float:gfu[3];
				    GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
				    SetPVarFloat(playerid,"startrx",gfu[0]);
				    SetPVarFloat(playerid,"startry",gfu[1]);
				    SetPVarFloat(playerid,"startrz",gfu[2]);
					SetPVarFloat(playerid,"endrx",0.0);
					SetPVarFloat(playerid,"endry",0.0);
					SetPVarFloat(playerid,"endrz",0.0);
					SetPVarInt(playerid,"ch",30);
					SetPVarInt(playerid,"choosepos",1);
				    SendClientMessage(playerid,COLOR_GREY,"Benutz das NumPad, um die Position zu wechseln");
				    SendClientMessage(playerid,COLOR_GREY,"Drücke LMouse, um das Ziel zu markieren");
				    
				    SetPVarFloat(playerid,"cx",gfu[0]);
				    SetPVarFloat(playerid,"cy",gfu[1]);
				    SetPVarFloat(playerid,"cz",gfu[2]+GetPVarInt(playerid,"ch"));
				    SetPlayerCameraPos(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz"));
				    SetPlayerCameraLookAt(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz")-1);
				    return 1;
				}
				case 1: ShowPlayerDialog(playerid,153,2,"Wantedlevel festlegen","1 Stern\n2 Sterne\n3 Sterne\n4 Sterne\n5 Sterne\n6 Sterne","Setzen","Keine");
				case 0: ShowPlayerDialog(playerid,154,1,"IG-Geldpreis festlegen","Wieviel soll jeder Teilnehmer beitragen ?","Setzen","Abbrechen");
				case 3:
				{
					if(GetPVarFloat(playerid,"endrx") == 0.0)
					{
					    SendClientMessage(playerid,COLOR_GREY,"Du musst ein Ziel festlegen");
					    return showrmenu(playerid);
					}
				    if(GetPVarInt(playerid,"startigmoney") == 0)
				    {
					    SendClientMessage(playerid,COLOR_GREY,"Du musst mindestens einen IG-Geldpreis festlegen");
					    return showrmenu(playerid);
					}
					ToggleControle(playerid,0);
					SetPVarInt(playerid,"driveto",playerid);
					GetPlayerName(playerid,player_name[playerid],16);
					format(mysqlquery[playerid],256,"%s hat ein Straßenrennen eröffnet",player_name[playerid]);
					SendClientMessageToAll(COLOR_GREY,mysqlquery[playerid]);
		            format(mysqlquery[playerid],256,"Bedingung: %d$ und %d Wanteds",GetPVarInt(playerid,"startigmoney"),GetPVarInt(playerid,"startwanteds"));
					SendClientMessageToAll(COLOR_GREY,mysqlquery[playerid]);
					SendClientMessageToAll(COLOR_GREY,"Das Rennen startet innerhalb von 3 Minuten bei mind. 2 Teilnehmern");
                    for(new subm=0;subm!=slots;subm++)
					{
						if(IsPlayerConnected(subm) && GetPVarInt(subm,"inrace") == 0 && subm != playerid && GetPlayerWantedLevel(subm) == 0)
						{
						    SetPVarInt(subm,"inrace",3);
						    SetPVarInt(subm,"driveto",playerid);
						    SetTimerEx("inrace3",60000*3,0,"i",subm);
						    SetPlayerRaceCheckpoint(subm,0,GetPVarFloat(playerid,"startrx"),GetPVarFloat(playerid,"startry"),GetPVarFloat(playerid,"startrz"),GetPVarFloat(playerid,"endrx"),GetPVarFloat(playerid,"endry"),GetPVarFloat(playerid,"endrz"),15.0);
                            SetPlayerMapIcon(subm,subm+20,GetPVarFloat(playerid,"startrx"),GetPVarFloat(playerid,"startry"),GetPVarFloat(playerid,"startrz"),53,0,MAPICON_GLOBAL);
						}
					}
					SetPlayerMapIcon(playerid,playerid+20,GetPVarFloat(playerid,"startrx"),GetPVarFloat(playerid,"startry"),GetPVarFloat(playerid,"startrz"),53,0,MAPICON_GLOBAL);
					SetTimerEx("startstreetr",60000*3,0,"i",playerid);
					/*
					counter[playerid] = TextDrawCreate(550.000000,400.000000,"Zeit: ~n~180");
					TextDrawUseBox(counter[playerid],1);
					TextDrawBoxColor(counter[playerid],0x00000066);
					TextDrawTextSize(counter[playerid],-23.000000,110.000000);
					TextDrawAlignment(counter[playerid],2);
					TextDrawBackgroundColor(counter[playerid],0x000000ff);
					TextDrawFont(counter[playerid],3);
					TextDrawLetterSize(counter[playerid],0.399999,1.000000);
					TextDrawColor(counter[playerid],0xffffffff);
					TextDrawSetOutline(counter[playerid],1);
					TextDrawSetProportional(counter[playerid],1);
					TextDrawSetShadow(counter[playerid],1);
					TextDrawShowForPlayer(playerid,counter[playerid]);
					*/
					SetPVarInt(playerid,"street_cd_v",180);
					SetTimerEx("street_cd",1000,0,"i",playerid);
					
					return 1;
				}
		
		    }
		}
		case 1: //register
	    {
	    	if(wartung == 1)
			{
			    SendClientMessage(playerid,COLOR_RED,"Der Server ist aktuell unter Bearbeitung, du kannst nicht beitreten");
			    SendClientMessage(playerid,COLOR_RED,"Versuch es bitte später erneut");
				return Kick(playerid);
			}
	        if(!strlen(inputtext)) return ShowPlayerDialog(playerid,1,DIALOG_STYLE_INPUT,"Willkommen","Willkommen auf dem Need for Speed:Most Wanted\nDieser Server ist Teil des Savandreas Networks\nBans werden im Netzwerk geteilt\n\nBitte gib ein geheimes Passwort ein:","Registrieren","");
			new nim[16],randomcar,tmpoutput[128];
			GetPlayerName(playerid,nim,16);
			switch(random(3))
			{
			    case 0: randomcar=400;
			    case 1: randomcar=404;
			    case 2: randomcar=458;
			}
			format(mysqlquery[playerid],256,"INSERT INTO nfslv_dt (alvl,name,toplist,igmoney,versteck) VALUES ('0','%s','0','5000','%d')",nim,random(5)+1);
			mysql_query(mysqlquery[playerid]);
			adminlevel[playerid] = 0;
			loggedin[playerid] = 1;

			format(mysqlquery[playerid],256,"SELECT MAX(unid) FROM nfslv_cars");
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();
			mysql_fetch_field("MAX(unid)",tmpoutput);
			new tuni = strval(tmpoutput)+1;

			format(mysqlquery[playerid],256,"INSERT INTO nfslv_cars (unid,user,carid,tuning,color1,color2,paintjob) VALUES ('%d','%s','%d','|0||0||0||0||0||0||0||0||0||0||0||0||0||0|','%d','%d','9')",tuni,nim,randomcar,random(50),random(50));
			mysql_query(mysqlquery[playerid]);
			
			format(mysqlquery[playerid],128,"REPLACE INTO login (name,pw) VALUES ('%s','%s')",nim,inputtext);
			mysql_query(mysqlquery[playerid]);
			mysql_free_result();
			
			new num[16];
  			GetPlayerName(playerid,num,16);
	        format(mysqlquery[playerid],256,"SELECT * FROM nfslv_dt WHERE name = '%s'",num);
			mysql_query(mysqlquery[playerid]);
			mysql_store_result();

			mysql_fetch_field("toplist",tmpoutput);
			SetPVarInt(playerid,"toplist",strval(tmpoutput));
			SetPlayerScore(playerid,strval(tmpoutput));
            mysql_fetch_field("igmoney",tmpoutput);
			SetMoney(playerid,strval(tmpoutput));
			mysql_fetch_field("versteck",tmpoutput);
			SetPVarInt(playerid,"versteck",strval(tmpoutput));
			format(tmpoutput,128,"#--");
			TextDrawSetString(txtdraw[1][playerid],tmpoutput);
            mysql_free_result();
			
	        new output1[128];
			format(output1,sizeof(output1),"%s hat den Server betreten",nim);
			SendClientMessageToAll(COLOR_GREY,output1);
			//SetTimerEx("forcespawn",3000,0,"i",playerid);
			for(new i=0;i<=13;i++) tuning[playerid][i] = 0;
			SetTimerEx("payday",30*60*1000,0,"i",playerid);
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
		            mysql_free_result();
		            new num[16];
				  	GetPlayerName(playerid,num,16);
	                format(mysqlquery[playerid],256,"SELECT * FROM nfslv_dt WHERE name = '%s'",num);
					mysql_query(mysqlquery[playerid]);
					mysql_store_result();
	    			loggedin[playerid] = 1;

				 	new tmpoutput[256];

				 	mysql_fetch_field("toplist",tmpoutput);
				 	SetPVarInt(playerid,"toplist",strval(tmpoutput));
				 	mysql_fetch_field("versteck",tmpoutput);
				 	SetPVarInt(playerid,"versteck",strval(tmpoutput));
				 	GetPlayerName(playerid,player_name[playerid],16);
                    mysql_fetch_field("igmoney",tmpoutput);
				 	SetMoney(playerid,strval(tmpoutput)+5);
				 	mysql_fetch_field("versteck",tmpoutput);
					SetPVarInt(playerid,"versteck",strval(tmpoutput));
					if(GetPVarInt(playerid,"toplist") > 0) format(tmpoutput,128,"#%d",GetPVarInt(playerid,"toplist"));
					else format(tmpoutput,128,"#--");
					TextDrawSetString(txtdraw[1][playerid],tmpoutput);

					if(mysql_fetch_field("alvl",tmpoutput))
					{
					    if(strval(tmpoutput) != 0)
					    {
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
							    SendClientMessage(playerid,COLOR_RED,"Der Server ist aktuell unter Bearbeitung, du kannst nicht beitreten");
							    SendClientMessage(playerid,COLOR_RED,"Versuch es bitte später erneut");
								return Kick(playerid);
							}
					    }
						adminlevel[playerid] = strval(tmpoutput);
					}
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
		    SetTimerEx("payday",30*60*1000,0,"i",playerid);
		    return 1;
		}
		case 912: //ShowPlayerDialog(playerid,912,0,"Informationen","Auf diesem Server des Savandreas Networks geht es um\neine möglichst gute Umsetzung des Spieles 'Need for Speed:Most Wanted'\nin ein für GTA San Andreas passendes Spielprinzip\nAuf diesem Server gibt es, wie im Original, eine Blacklist,\nauf der die besten 15 Racer gelistet sind\nGewinne gegen jeden Blacklistfahrer, um dich hochzuarbeiten","Weiter","Abbrechen");
		{
		    if(!response) return 0;
		    TextDrawColor(txtdraw[1][playerid],COLOR_RED);
		    TextDrawShowForPlayer(playerid,txtdraw[1][playerid]);
            ShowPlayerDialog(playerid,913,0,"Die Blacklist","Auf diesem Server gibt es, wie im Original, eine Blacklist,\nauf der die besten 15 Racer gelistet sind\nGewinne gegen jeden Blacklistfahrer, um dich hochzuarbeiten und mehr Autos freizuschalten\n\nNächste Seite: Geld","Weiter","Abbrechen");
		}
		case 913:
		{
		    TextDrawColor(txtdraw[1][playerid],-1);
		    TextDrawShowForPlayer(playerid,txtdraw[1][playerid]);
		    if(!response) return 0;
		    GivePlayerMoney(playerid,999999);
			ShowPlayerDialog(playerid,914,0,"Geld","Auf diesem Server gibt es zwei Arten von Geld:\nReales und virtuelles Geld\nUm Virtuelles zu verdienen, fordere andere Racer heraus,\nund erleichtere Sie um den eingesetzten Betrag\nMit diesem Geld kannst du dein Auto verbessern oder dir ein Neues kaufen\n\nNächste Seite: Reales Geld","Weiter","Abbrechen");
		}
		case 914:
		{
			AddMoney(playerid,0);
			if(!response) return 0;
			TextDrawColor(txtdraw[0][playerid],COLOR_RED);
			TextDrawShowForPlayer(playerid,txtdraw[0][playerid]);
			ShowPlayerDialog(playerid,915,0,"Savandreas Coins (SC)","Um einen zusätzlichen, interessanten Faktor hinzuzufügen,\n ist es bei möglich, Savandreas Coins (SC) zu verdienen\nDiese sind wie reales Geld, um welches du spielen kannst,\noder für welches du dir Bonusfeatures freischalten kannst\nDu kannst dir SC sogar in Euro überweisen lassen\nUm dein Konto aufzustocken, besuch unsere Website www.savandreas.com\n\nNächste Seite: Polizist werden","Weiter","Abbrechen");
		}
		case 915:
		{
		    TextDrawColor(txtdraw[0][playerid],-1);
		    TextDrawShowForPlayer(playerid,txtdraw[0][playerid]);
		    if(!response) return 0;
			ShowPlayerDialog(playerid,917,0,"Polizist werden","Wie in der Realität gibt es auch auf diesem Server Polizisten,\ndie für Geld illegalen Streetracern einen Riegel vorschiebt\nUm Polizist zu werden, fahr zum Polizeipräsidium und lass dich anheuern\n\nNächste Seite: Verfolgungen","Weiter","Abbrechen");
		}
		case 917:
		{
		    if(!response) return 0;
            SetProgressBarColor(barrid[0][playerid], COLOR_RED);
			UpdateProgressBar(barrid[0][playerid],playerid);
			ShowPlayerDialog(playerid,918,0,"Verfolgungen","Während du auf der Flucht bist,\nfärbt sich der Balken grün und füllt sich\nIst der Balken gefüllt, bist du entkommen\nWird der Balken aber rot und voll,\nwirst du grade hochgenommen\nIst dieser Balken voll, bist du verhaftet\n\nNächste Seite: Nitro","Weiter","Abbrechen");
		}
		case 918:
		{
		    SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
			UpdateProgressBar(barrid[0][playerid],playerid);
			if(!response) return 0;
			SetProgressBarColor(barrid[1][playerid], COLOR_RED);
			UpdateProgressBar(barrid[1][playerid],playerid);
		    ShowPlayerDialog(playerid,916,0,"Nitro","Sobald dein Auto eine Nitro-Einspritzung hat,\nkannst du durch Drücken von STRG/LMOUSE\ndas Nitro aktivieren\nSolange du Nitro gedrückt hälst,\nsinkt der Balken immer mehr\nIst der Balken leer, musst du warten, bis es sich aufgefüllt hat","Ende","");
		}
		case 916:
		{
		    SetProgressBarColor(barrid[1][playerid], COLOR_GREEN);
			UpdateProgressBar(barrid[1][playerid],playerid);
			triggerachiv(playerid,55);
			return 0;
		}
		case 3:
		{
		    if(!response) return 0;
			new endstring[1024];
			for(new sort=1;sort<=6;sort++)
			{
				for(new sul=0;sul!=slots;sul++)
				{
				    if(IsPlayerConnected(sul) && GetPlayerWantedLevel(sul) == sort)
				    {
				        GetPlayerName(sul,player_name[sul],16);
				        format(endstring,1024,"[%d*]%s[ID %d]\n%s",sort,player_name[sul],sul,endstring);
				    }
				}
			}
			if(strlen(endstring) < 5) return SendClientMessage(playerid,COLOR_GREY,"Aktuell wirst du nicht benötigt");
			DestroyVehicle(GetPVarInt(playerid,"tcarid"));
		    SetPlayerPos(playerid,973.2206,8.1626,1001.1484);
			SetPlayerInterior(playerid,3);
			SetPlayerFacingAngle(playerid, 182.2034);
			SetPlayerCameraPos(playerid,972.7090,-2.7833,1001.1484);
			SetPlayerCameraLookAt(playerid,973.2206,8.1626,1001.1484);
			SetPlayerVirtualWorld(playerid,playerid+1);
			SetPlayerSkin(playerid,280);
			SetPVarInt(playerid,"iscop",1);
			ToggleControle(playerid,0);
			ShowPlayerDialog(playerid,4,2,"Aufträge",endstring,"Verfolgen","Abbrechen");
		}
		case 3334: //undercover-cops
		{
		    if(!response) return 1;
		    DestroyObject(GetPVarInt(playerid, "neon"));
	    	DestroyObject(GetPVarInt(playerid, "neon1"));
	    	new midid[128],rlid;
			strmid(midid,inputtext,strfind(inputtext,"[ID ")+strlen("[ID "),strfind(inputtext,"]",false,strfind(inputtext,"[ID ")));
			rlid = strval(midid);
            SetPVarInt(playerid,"folgen",rlid);
            SetPVarInt(playerid,"iscop",2);
            copfollow(playerid,2);
            SendClientMessage(playerid,COLOR_GREY,"Los gehts - nimm den Racer fest !");
		}
		case 4:
		{
		    SetPlayerVirtualWorld(playerid,0);
		    SetPlayerInterior(playerid,0);
		    if(!response)
		    {
		        SetPVarInt(playerid,"iscop",0);
		        return OnPlayerSpawn(playerid);
		    }
		    new midid[128],rlid;
			strmid(midid,inputtext,strfind(inputtext,"[ID ")+strlen("[ID "),strfind(inputtext,"]",false,strfind(inputtext,"[ID ")));
			rlid = strval(midid);
            SetPVarInt(playerid,"folgen",rlid);
            DestroyObject(GetPVarInt(playerid, "neon"));
	    	DestroyObject(GetPVarInt(playerid, "neon1"));
	    	spawncop(playerid,1);
            copfollow(playerid,1);
            ToggleControle(playerid,1);
            SetPlayerColor(playerid,0x002EB8AA);
		}
		case 152:
		{
	        new opponent = GetPVarInt(playerid,"opponent");
		    if(!response)
		    {
		        SetPVarInt(playerid,"inrace",0);
				SetPVarInt(opponent,"inrace",0);
				SetPVarInt(playerid,"opponent",-1);
				SetPVarInt(opponent,"opponent",-1);
				SendClientMessage(playerid,COLOR_GREY,"Du hast die Herausforderung abgelehnt");
				SendClientMessage(playerid,COLOR_GREY,"Deine Herausforderung wurde abgelehnt");
				if(GetPVarInt(playerid,"blacklistrace"))
				{
				    WithMoney(playerid,3000);
				    SendClientMessage(playerid,COLOR_GREY,"Da du für ein Blacklistrennen rausgefordert wurdest, hast du eine Geldstrafe erhalten");
				    AddMoney(opponent,3000);
				    SendClientMessage(opponent,COLOR_GREY,"Du hast 3000$ als Entschädigung erhalten");
				}
				return 1;
		    }
		    switch(listitem)
		    {
				case 0: ShowPlayerDialog(playerid,156,0,"Renneinstellungen - Hilfe","Hilfe anzeigen - Zeigt diese Hilfe an\nStrecke festlegen - Legt Start- und Endpunkt fest\nIG-Geldpreis festlegen - Setzt den Einsatz des virtuellen Geldes\nRL-Geldpreis festlegen - Setzt den Einsatz des echten Geldes\nRennen starten - Startet das Rennen","Ok","");
				case 1:
				{
				    SetPVarFloat(playerid,"startrx",0.0);
					SetPVarFloat(playerid,"startry",0.0);
					SetPVarFloat(playerid,"startrz",0.0);
					SetPVarFloat(playerid,"endrx",0.0);
					SetPVarFloat(playerid,"endry",0.0);
					SetPVarFloat(playerid,"endrz",0.0);
					SetPVarInt(playerid,"ch",30);
					SetPVarInt(playerid,"choosepos",1);
				    SendClientMessage(playerid,COLOR_GREY,"Benutz das NumPad, um die Position zu wechseln");
				    SendClientMessage(playerid,COLOR_GREY,"Drücke LMouse, um den Start zu markieren");
				    new Float:gfu[3];
				    GetPlayerPos(playerid,gfu[0],gfu[1],gfu[2]);
				    SetPVarFloat(playerid,"cx",gfu[0]);
				    SetPVarFloat(playerid,"cy",gfu[1]);
				    SetPVarFloat(playerid,"cz",gfu[2]+GetPVarInt(playerid,"ch"));
				    SetPlayerCameraPos(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz"));
				    SetPlayerCameraLookAt(playerid,GetPVarFloat(playerid,"cx"),GetPVarFloat(playerid,"cy"),GetPVarFloat(playerid,"cz")-1);
				    return 1;
				}
				case 2: ShowPlayerDialog(playerid,153,2,"Wantedlevel festlegen","1 Stern\n2 Sterne\n3 Sterne\n4 Sterne\n5 Sterne\n6 Sterne","Setzen","Keine");
				case 3: ShowPlayerDialog(playerid,154,1,"IG-Geldpreis festlegen","Welchen Ingame-Geldbetrag soll der\nGewinner erhalten ?","Setzen","Abbrechen");
				case 4: ShowPlayerDialog(playerid,155,1,"SC-Preis festlegen","Wieviel echtes Geld soll der\nGewinner erhalten ?\n(Währung = Cent)","Setzen","Abbrechen");
				case 5: ShowPlayerDialog(playerid,158,2,"Rennmodus auswählen","Sprint\nRundkurs\nDrift\nHeatrace","Setzen","Abbrechen");
				case 6:
				{
					if(GetPVarFloat(playerid,"startrx") == 0.0 || GetPVarFloat(playerid,"endrx") == 0.0)
					{
					    SendClientMessage(playerid,COLOR_GREY,"Du musst ein Start & Ziel festlegen");
					    return showrmenu(playerid);
					}
				    if(GetPVarInt(playerid,"startigmoney") == 0)
				    {
					    SendClientMessage(playerid,COLOR_GREY,"Du musst mindestens einen IG-Geldpreis festlegen");
					    return showrmenu(playerid);
					}
					if(GetPVarInt(playerid,"igmoney") < GetPVarInt(playerid,"startigmoney") || GetPVarInt(opponent,"igmoney") < GetPVarInt(playerid,"startigmoney"))
					{
					    SendClientMessage(playerid,COLOR_GREY,"Einer der Teilnehmer hat nicht soviel IG-Geld");
					    return showrmenu(playerid);
					}
					if(getrlmoney(playerid) < GetPVarInt(playerid,"startrlmoney") || getrlmoney(opponent) < GetPVarInt(playerid,"startrlmoney"))
					{
					    SendClientMessage(playerid,COLOR_GREY,"Einer der Teilnehmer hat nicht soviel RL-Geld");
					    return showrmenu(playerid);
					}
					new getr[256];
					switch(GetPVarInt(playerid,"startmode"))
					{
						case 0:format(getr,256,"Bist du mit diesen Renneinstellungen einverstanden ?\nSterne:%d\nIG-Geldpreis:%d\nRL-Geldpreis:%d\nModus: Sprint",GetPVarInt(playerid,"startwanteds"),GetPVarInt(playerid,"startigmoney"),GetPVarInt(playerid,"startrlmoney"));
                        case 1:format(getr,256,"Bist du mit diesen Renneinstellungen einverstanden ?\nSterne:%d\nIG-Geldpreis:%d\nRL-Geldpreis:%d\nModus: Rundkurs",GetPVarInt(playerid,"startwanteds"),GetPVarInt(playerid,"startigmoney"),GetPVarInt(playerid,"startrlmoney"));
                        case 2:format(getr,256,"Bist du mit diesen Renneinstellungen einverstanden ?\nSterne:%d\nIG-Geldpreis:%d\nRL-Geldpreis:%d\nModus: Drift",GetPVarInt(playerid,"startwanteds"),GetPVarInt(playerid,"startigmoney"),GetPVarInt(playerid,"startrlmoney"));
                        case 3:format(getr,256,"Bist du mit diesen Renneinstellungen einverstanden ?\nSterne:%d\nIG-Geldpreis:%d\nRL-Geldpreis:%d\nModus: Heatrace",GetPVarInt(playerid,"startwanteds"),GetPVarInt(playerid,"startigmoney"),GetPVarInt(playerid,"startrlmoney"));
					}
					
					SetPlayerCameraPos(opponent,GetPVarInt(playerid,"endrx"),GetPVarInt(playerid,"endry"),GetPVarInt(playerid,"endrz")+30);
					SetPlayerCameraLookAt(opponent,GetPVarInt(playerid,"endrx"),GetPVarInt(playerid,"endry"),GetPVarInt(playerid,"endrz"));

					ShowPlayerDialog(opponent,157,0,"Renneinstellungen prüfen",getr,"Ja","Nein");
					SendClientMessage(playerid,COLOR_GREY,"Dein Kontrahent prüft nun deine Einstellungen");
					return 1;
				}
			}
		}
		case 153:
		{
		    if(!response) SetPVarInt(playerid,"startwanteds",0);
		    else SetPVarInt(playerid,"startwanteds",listitem+1);
            showrmenu(playerid);
		}
		case 154:
		{
		    if(!response) return showrmenu(playerid);
		    SetPVarInt(playerid,"startigmoney",strval(inputtext));
		    showrmenu(playerid);
		}
		case 155:
		{
		    if(!response) return showrmenu(playerid);
		    SetPVarInt(playerid,"startrlmoney",strval(inputtext));
		    showrmenu(playerid);
		}
		case 156: showrmenu(playerid);
		case 157:
		{
		    new opponent = GetPVarInt(playerid,"opponent");
		    SetCameraBehindPlayer(playerid);
		    if(!response)
		    {
                if(GetPVarInt(playerid,"blacklistrace") == 0)
                {
					SendClientMessage(playerid,COLOR_GREY,"Dein Partner überarbeitet die Einstellungen noch einmal");
					SendClientMessage(opponent,COLOR_GREY,"Deine Einstellungen wurden nicht akzeptiert, bitte überarbeite diese nochmal !");
					return showrmenu(opponent);
				}
				else SendClientMessage(playerid,COLOR_GREY,"In einem Blacklistrennen kannst du keine Einstellungen ablehnen");
		    }
		    
		    SetPVarFloat(playerid,"startrx",GetPVarFloat(opponent,"startrx"));
			SetPVarFloat(playerid,"startry",GetPVarFloat(opponent,"startry"));
			SetPVarFloat(playerid,"startrz",GetPVarFloat(opponent,"startrz"));
			SetPVarFloat(playerid,"endrx",GetPVarFloat(opponent,"endrx"));
			SetPVarFloat(playerid,"endry",GetPVarFloat(opponent,"endry"));
			SetPVarFloat(playerid,"endrz",GetPVarFloat(opponent,"endrz"));
			SetPVarInt(playerid,"startmode",GetPVarInt(opponent,"startmode"));
			SetPVarInt(playerid,"startwanteds",GetPVarInt(opponent,"startwanteds"));
			SetPVarInt(playerid,"startigmoney",GetPVarInt(opponent,"startigmoney"));
			SetPVarInt(playerid,"startrlmoney",GetPVarInt(opponent,"startrlmoney"));
			SendClientMessage(playerid,COLOR_GREY,"Fahr zum Startpunkt und warte dort auf den Start des Rennens");
			SendClientMessage(opponent,COLOR_GREY,"Fahr zum Startpunkt und warte dort auf den Start des Rennens");

			if(GetPVarInt(playerid,"blacklistrace"))
			{
				WithMoney(opponent,(17-GetPVarInt(playerid,"toplist"))*10000);
				AddMoney(playerid,(17-GetPVarInt(playerid,"toplist"))*10000);
			}

			SetPlayerRaceCheckpoint(playerid,0,GetPVarFloat(opponent,"startrx"),GetPVarFloat(opponent,"startry"),GetPVarFloat(opponent,"startrz"),GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),15.0);
            SetPlayerRaceCheckpoint(opponent,0,GetPVarFloat(opponent,"startrx"),GetPVarFloat(opponent,"startry"),GetPVarFloat(opponent,"startrz"),GetPVarFloat(opponent,"endrx"),GetPVarFloat(opponent,"endry"),GetPVarFloat(opponent,"endrz"),15.0);
			
			SetPVarInt(playerid,"instart",0);
			SetPVarInt(opponent,"instart",0);
            SetPVarInt(playerid,"inrace",1);
            SetPVarInt(opponent,"inrace",1);
		}
		case 158:
		{
		    if(!response) SetPVarInt(playerid,"startmode",0);
		    else SetPVarInt(playerid,"startmode",listitem);
            showrmenu(playerid);
		}
	}
	return 1;
}

forward street_cd(playerid);
public street_cd(playerid)
{
	SetPVarInt(playerid,"street_cd_v",GetPVarInt(playerid,"street_cd_v")-1);
	format(mysqlquery[playerid],256,"Zeit: ~n~%d",GetPVarInt(playerid,"street_cd_v"));
	//TextDrawSetString(counter[playerid],mysqlquery[playerid]);
	//TextDrawShowForPlayer(playerid,counter[playerid]);
	GameTextForPlayer(playerid,mysqlquery[playerid],1000,3);
	
	if(GetPVarInt(playerid,"street_cd_v") > 0)
	{
		for(new i;i!=slots;i++)
		{
	      	if(GetPVarInt(i,"inrace") == 2 && GetPVarInt(i,"driveto") == playerid) GameTextForPlayer(i,mysqlquery[playerid],1000,3);
		}
		SetTimerEx("street_cd",1000,0,"i",playerid);
	}

	return 1;
}

forward showrmenu(playerid);
public showrmenu(playerid)
{
    switch(GetPVarInt(playerid,"inrace"))
    {
        case 1:ShowPlayerDialog(playerid,152,2,"Renneinstellungen","Hilfe anzeigen\nStrecke festlegen\nWantedlevel festlegen\nIG-Geldpreis festlegen\nRL-Geldpreis festlegen\nRennmodus ändern\nRennen Starten","Ändern","Ablehnen");
        case 2:ShowPlayerDialog(playerid,12,2,"Straßenrennen erstellen","Einsatz festlegen\nWantedlevel festlegen\nZiel festlegen\nRennen starten","Ok","Abbrechen");
    }
	
	return 1;
}

forward copfollow(playerid,undercover); //1=cop,2=undercover
public copfollow(playerid,undercover)
{
	if(!IsPlayerConnected(playerid) || GetPVarInt(playerid,"iscop") == 0) return 0;
	if(!IsPlayerConnected(GetPVarInt(playerid,"folgen")) || GetPlayerWantedLevel(GetPVarInt(playerid,"folgen")) == 0)
	{
	    SetProgressBarValue(barrid[0][playerid], 0);
		SetProgressBarColor(barrid[0][playerid], COLOR_WHITE);
		UpdateProgressBar(barrid[0][playerid],playerid);
	    
	    new endstring[1024];
		for(new sort=1;sort<=6;sort++)
		{
			for(new sul=0;sul!=slots;sul++)
			{
			    if(IsPlayerConnected(sul) && GetPlayerWantedLevel(sul) == sort)
			    {
			        GetPlayerName(sul,player_name[sul],16);
			        format(endstring,1024,"[%d*]%s[ID %d]\n%s",sort,player_name[sul],sul,endstring);
			    }
			}
		}
		if(undercover == 1)
		{
			DestroyObject(GetPVarInt(playerid,"sirene"));
			DestroyVehicle(GetPVarInt(playerid,"tcarid"));
			if(strlen(endstring) < 5)
			{
				return OnPlayerSpawn(playerid);
			}
			SetPlayerPos(playerid,973.2206,8.1626,1001.1484);
			SetPlayerInterior(playerid,3);
			SetPlayerFacingAngle(playerid, 182.2034);
			SetPlayerCameraPos(playerid,972.7090,-2.7833,1001.1484);
			SetPlayerCameraLookAt(playerid,973.2206,8.1626,1001.1484);
			SetPlayerVirtualWorld(playerid,playerid+1);
			SetPlayerSkin(playerid,280);
			SetPVarInt(playerid,"iscop",1);
			ToggleControle(playerid,0);
			ShowPlayerDialog(playerid,4,2,"Aufträge",endstring,"Verfolgen","Abbrechen");
			return 0;
		}
		if(undercover == 2)
		{
		    SetPVarInt(playerid,"iscop",0);
		    return SendClientMessage(playerid,COLOR_GREY,"Auftrag abgeschlossen");
		}
	}
	SetTimerEx("copfollow",2000,0,"ii",playerid,undercover);
	if(undercover == 1)
	{
		new Float:gpu[4];
		GetPlayerPos(GetPVarInt(playerid,"folgen"),gpu[0],gpu[1],gpu[2]);
		GetVehicleHealth(GetPlayerVehicleID(playerid),gpu[3]);
		if(gpu[3] < 220)
		{
		    ToggleControle(playerid,0);
		    SetTimerEx("ToggleControle",2000,0,"ii",playerid,1);
		    SetTimerEx("spawncop",2100,0,"ii",playerid,1);
		}
	}
	return 1;
}

forward spawncop(playerid,force);
public spawncop(playerid,force)
{
    if(GetPVarInt(playerid,"spawncool") == 1 && force == 0) return SendClientMessage(playerid,COLOR_GREY,"Du kannst jede 20 Sekunden nur einmal zurücksetzen");
    SetTimerEx("cooldown",20000,0,"ii",playerid,1);
    SetPVarInt(playerid,"spawncool",1);
	new model;
	new Float:knote[6];
	
	new tmp2[128];
	GetPlayerPos(GetPVarInt(playerid,"folgen"),knote[0],knote[1],knote[2]);
	GetVehicleZAngle(GetPlayerVehicleID(GetPVarInt(playerid,"folgen")),knote[3]);
	knote[4]=knote[0]+(175 * floatsin(-knote[3], degrees));
	knote[5]=knote[1]+(175 * floatcos(-knote[3], degrees));
	for(new gc=50;gc<=500;gc+=50)
	{
		format(mysqlquery[playerid],256,"SELECT * FROM streetview_lv WHERE x BETWEEN '%f' AND '%f' && y BETWEEN '%f' AND '%f' ORDER BY x ASC",knote[4]-gc,knote[4]+gc,knote[5]-gc,knote[5]+gc);
		mysql_query(mysqlquery[playerid]);
		mysql_store_result();
        if(mysql_num_fields() >= 1) break;
		else mysql_free_result();
	}
	if(mysql_num_fields() == 0) return SendClientMessage(playerid,COLOR_GREY,"Es gab Fehler beim Spawn, versuch es später noch einmal");
	mysql_fetch_field("x",tmp2);
	knote[0] = floatstr(tmp2);
	if(knote[0] == 0) return SendClientMessage(playerid,COLOR_GREY,"Es gab Fehler beim Spawn, versuch es später noch einmal");
	mysql_fetch_field("y",tmp2);
	knote[1] = floatstr(tmp2);
	mysql_fetch_field("z",tmp2);
	knote[2] = floatstr(tmp2);
	mysql_fetch_field("a",tmp2);
	knote[3] = floatstr(tmp2);
	mysql_free_result();
	
	DestroyVehicle(GetPVarInt(playerid,"tcarid"));
	
	if(GetPVarInt(playerid,"chopper") == 1)
	{
		if(GetPlayerWantedLevel(GetPVarInt(playerid,"folgen"))<3)
		{
		    SetPVarInt(playerid,"chopper",0);
		}
		else
		{
	        SetPVarInt(playerid,"tcarid",CreateVehicle(497,knote[0],knote[1],knote[2]+250,0,0,0,5000));
	        PutPlayerInVehicle(playerid,GetPVarInt(playerid,"tcarid"),0);
        }
        return 1;
    }
	
	switch(GetPlayerWantedLevel(GetPVarInt(playerid,"folgen")))
	{
	    case 1:model=598;
	    case 2:model=596;
	    case 3:model=596;
	    case 4:model=490;
	    case 5:model=541; //bullet
	    case 6:model=451; //infernus
	}
	SetPVarInt(playerid,"tcarid",CreateVehicle(model,knote[0],knote[1],knote[2],knote[3],0,0,5000));
	
	if(model==541 || model==451)
	{
	    SetPVarInt(playerid,"sirene",CreateObject(18646,0,0,0,0,0,0,100));
	    AttachObjectToVehicle(GetPVarInt(playerid,"sirene"),GetPVarInt(playerid,"tcarid"),0.2,0,0.51,0,0,0);
	}
	PutPlayerInVehicle(playerid,GetPVarInt(playerid,"tcarid"),0);
	return 1;
}

forward SetMoney(playerid,amount);
public SetMoney(playerid,amount)
{
    SetPVarInt(playerid,"igmoney",amount);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,amount);
	return 1;
}

forward WithMoney(playerid,amount);
public WithMoney(playerid,amount)
{
    SetPVarInt(playerid,"igmoney",GetPVarInt(playerid,"igmoney")-amount);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,GetPVarInt(playerid,"igmoney"));
	return 1;
}

forward AddMoney(playerid,amount);
public AddMoney(playerid,amount)
{
    SetPVarInt(playerid,"igmoney",GetPVarInt(playerid,"igmoney")+amount);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,GetPVarInt(playerid,"igmoney"));
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
	new dialog[128];
 	new clickedplayer[MAX_PLAYER_NAME];
  	GetPlayerName(clickedplayerid, clickedplayer, sizeof(clickedplayer));
   	format(dialog, sizeof(dialog), "Nachricht an %s", clickedplayer);
    ShowPlayerDialog(playerid,177,DIALOG_STYLE_INPUT,"Private Nachricht",dialog,"Senden","Abbrechen");
    ClickedPlayerID[playerid] = clickedplayerid;
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
	for(new i=1;i<=200;i++)
	{
		pos[0] = i-1;
		pos[1] = i;
		strmid(mid,ids,pos[0],pos[1]);
        format(mysqlquery[playerid],256,"SELECT * FROM achiev_strings WHERE nummer = '%d' AND server='2'",i);
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

forward countachiv(playerid);
public countachiv(playerid)
{
	GetPlayerName(playerid,player_name[playerid],16);
	format(mysqlquery[playerid],256,"SELECT achievements FROM achievements WHERE name = '%s'",player_name[playerid]);
	mysql_query(mysqlquery[playerid]);
	mysql_store_result();
	new ids[256];
	mysql_fetch_field("achievements",ids);
	mysql_free_result();
	new mid[128],pos[2],gesa;
	for(new i=1;i<=200;i++)
	{
		pos[0] = i-1;
		pos[1] = i;
		strmid(mid,ids,pos[0],pos[1]);
		if(strval(mid)==1) gesa+=1;
	}
	return gesa;
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
			
			format(ffield,256,"%s hat die Auszeichnung '%s' erhalten",player_name[playerid],tit);
			SendClientMessageToAll(COLOR_GREEN,ffield);
			break;
		}
	}
	format(tlong,512,"UPDATE achievements SET achievements = '%s' WHERE name = '%s'",ids,player_name[playerid]);
	mysql_query(tlong);

	return 1;
}
