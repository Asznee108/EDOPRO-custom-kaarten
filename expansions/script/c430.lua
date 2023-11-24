--Anime Archtype
if not AnimeArchetype then
	AnimeArchetype = {}
	
	local MakeCheck=function(setcodes,archtable,extrafuncs)
		return function(c,sc,sumtype,playerid)
			sumtype=sumtype or 0
			playerid=playerid or PLAYER_NONE
			if extrafuncs then
				for _,func in pairs(extrafuncs) do
					if Card[func](c,sc,sumtype,playerid) then return true end
				end
			end
			if setcodes then
				for _,setcode in pairs(setcodes) do
					if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
				end
			end
			if archtable then
				if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
			end
			return false
		end
	end

	-- Virus (archetype) 
	AnimeArchetype.OCGVirus={
		86361354,33184167,24725825,22804644,
		170000150,4931121,35027493,39163598,
		54591086,57728570,84491298,100000166,
		511000822,511000823,511002576,511005713,
		800000012,512000080,54974237,86361354,
		33184167,24725825,22804644,48736598,
		84121193,513000122,85555787,511009657,
		511001119
	}
	Card.IsVirus=MakeCheck({0x251},AnimeArchetype.OCGVirus)

	-- King (not finished)
	-- 王
	-- おう
	-- Brron, Mad King of Dark World/The Furious Sea King/Zeman the Ape King
	-- Hot Red Dragon Archfiend King Calamity/Royal Decree
	-- Royal Decree/Royal Decree/Royal Writ of Taxation
	-- Royal Oppression/Imperial Order/Imperial Iron Wall
	-- Royal Prison/Royal Tribute/Pharaoh's Treasure
	-- Pharaonic Protector/Temple of the Kings/Necrovalley
	-- Curse of Royal/King Tiger Wanghu/King's Consonance
	-- King's Consonance/Protector of the Throne/Invader of the Throne
	-- Guardian of the Throne Room/Trial of the Princesses
	-- Royal Keeper/Trap of the Imperial Tomb/Royal Magical Library
	-- Brotherhood of the Fire Fist - Tiger King/Gash the Dust Lord
	-- Number C65: King Overfiend/The Twin Kings, Founders of the Empire/Machine King
	-- Machine King - 3000 B.C./Machine King Prototype/Magical King Moonstar
	-- Barbaroid, the Ultimate Battle Machine/Unformed Void/Amorphactor Pain, the Imagination Dracoverlord
	-- Phantom King Hydride/Gazelle the King of Mythical Beasts/Queen of Autumn Leaves
	-- Ice Queen/Pumpking the King of Ghosts/Lich Lord, King of the Underworld
	-- King Pyron/Demise, King of Armageddon
	-- Dark King of the Abyss/Abyssal Kingshark/Machine Lord Ür
	-- Alector, Sovereign of Birds/Beast King Barbaros/Leo, the Keeper of the Sacred Tree
	-- Sacred Noble Knight of King Artorigus/Endymion, the Master Magician/Digvorzhak, King of Heavy Industry
	-- Beast Machine King Barbaros Ür/Queen's Bodyguard/Queen's Bodyguard
	-- Queen's Pawn/Skull Archfiend of Lightning/Emperor of the Land and Sea
	-- Artorigus, King of the Noble Knights/Gwenhwyfar, Queen of Noble Arms/Hieratic Dragon King of Atum
	-- Absolute King Back Jack/Big Eye/Superancient Deepsea King Coelacanth
	-- Super Quantal Mech King Great Magnus/Princess of Tsurugi
	-- Shinato, King of a Higher Plane/Dark Highlander/Celestial Wolf Lord, Blue Sirius
	-- D/D/D Destiny King Zero Laplace
	-- D/D/D Oblivion King Abyss Ragnarok
	-- D/D/D Chaos King Apocalypse
	-- D/D/D Dragonbane King Beowulf
	-- D/D/D Doom King Armageddon
	-- D/D/D Gust High King Executive Alexander
	-- D/D/D Oracle King d'Arc
	-- D/D/D Cursed King Siegfried
	-- D/D/D Supreme King Kaiser
	-- D/D/D Duo-Dawn King Kali Yuga
	-- D/D/D Marksman King Tell
	-- D/D/D Superdoom King Purplish Armageddon
	-- D/D/D Wave King Caesar
	-- D/D/D Wave Oblivion King Caesar Ragnarok
	-- D/D/D Wave High King Executive Caesar
	-- D/D/D Dragon King Pendragon
	-- D/D/D Rebel King Leonidas
	-- D/D/D Stone King Darius
	-- D/D/D Flame King Genghis
	-- D/D/D Flame High King Executive Genghis
	-- D/D/D Gust King Alexander
	-- Vennominon the King of Poisonous Snakes/Number 8: Heraldic King Genom-Heritage/Rise to Full Height
	-- King of the Swamp/Beastking of the Swamps/Imperial Tombs of Necrovalley
	-- Coach King Giantrainer/Coach Captain Bearman
	-- Morph King Stygi-Gel/Number 3: Cicada King

	-- Red Lotus King, Flame Crime/King Scarlet

	-- archtype:Fire King/Supreme King/Monarch (spell/trap)/Dracoverlord
	AnimeArchetype.OCGKing={
		60990740,13662809,44223284,17573739,89832901,41925941,78651105,19028307,99426834,16768387,6214884,67136033,
		2926176,21686473,47198668,56619314,74069667,92536468,73360025,53375573,53982768,72426662,29424328,11250655,
		68400115,40732515,57274196,45425051,10833828,18710707,30646525,19012345,5818798,22910685,47879985,19748583,
		64514622,14462257,30459350,61740673,90434657,3056267,20438745,83986578,79109599,24590232,55818463,46700124,
		70406920,89222931,96938777,21223277,54702678,34408491,96381979,32995007,30741334,44852429,8463720,15939229,
		74583607,987311,71612253,82956492,51497409,3758046,75326861,70583986,29515122,28290705,27337596,62242678,
		35058857,CARD_NECROVALLEY,47387961,6901008,18891691,63571750,89959682,43791861,51371017,82213171,10071456,29155212,
		4179849,71411377,5901497,58477767,19254117,33950246,51452091,16509093,93016201,26586849,56058888,72405967,
		86742443,86327225,61370518,88307361,29762407,80955168,72709014,24857466,52589809,5309481,10613952,84025439,
		38180759,22858242,
		85457355,100266028,

		100304008,60433216
	}
	Card.IsKing=MakeCheck({0x52f,0xf8,0x81,0xda},AnimeArchetype.OCGKing,{"IsChampion"})

	-- Red (archetype) レッド   (Last updated on 16th Apr 2020)
	-- Sub-archetype: Red-Eyes/Red Dragon Archfiend
	-- U.A. Dreadnought Dunker/Vampire Red Baron/Xtra HERO Dread Decimator/Eternal Dread
	-- Ojama Red/Number C106: Giant Red Hand/Construction Train Signal Red/The Wicked Dreadroot
	-- Red Carpet/Red Cocoon/Red Supernova Dragon/Red Nova Dragon
	-- Red Familiar/Red Rain/Red Screen/SPYRAL GEAR - Big Red
	-- Noble Knight Medraut/Dark Red Enchanter/Super Quantum Red Layer/Destiny HERO - Dreadmaster
	-- Destiny HERO - Dread Servant/Dread Dragon/Number 27: Dreadnought Dreadnoid/Red Warg
	-- Akakieisu/Red Gadget/Red Gardna/Opticlops
	-- Red Sprinter/Red Supremacy/Red Duston/Tyhone #2
	-- Crimson Ninja/Red Nova/Red Medicine/Red Mirror
	-- Red Rising Dragon/Red Resonator/Red Reboot/Emergeroid Call
	-- Red Rose Dragon/Red Wyvern/Lord of the Red/Hundred Eyes 
	
	-- Red Lotus King, Flame Crime/Red Blossoms from Underroot/Majestic Red Dragon/Red Dragon Vase
	-- Scrap-Iron Sacred Statue/Red Zone
	AnimeArchetype.OCGRed={
		71279983,6917479,63813056,35787450,
		37132349,55888045,34475451,62180201,
		41197012,2542230,99585850,97489701,
		8372133,5376159,18634367,30979619,
		59057152,45462639,59975920,40591390,
		36625827,51925772,8387138,45313993,
		38035986,86445415,72318602,14531242,
		14886469,50584941,61019812,56789759,
		14618326,21142671,38199696,8706701,
		66141736,40975574,23002292,70628672,
		26118970,76547525,19025379,95453143,

		100304008,71521025,67030233,87614611,
		85520170,50056656,
	}
	Card.IsRed=MakeCheck({0x543,0x3b,0x1045},AnimeArchetype.OCGRed)

	-- Champion
	-- 王者
	-- おうじゃ
	-- Champion's Vigilance
	Card.IsChampion=MakeCheck({0x152f},{82382815})
end