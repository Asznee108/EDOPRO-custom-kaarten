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
end