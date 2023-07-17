--Approach of the Black Arms
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater{handler=c,filter=s.ritualfil,lv=9,extrafil=s.extrafil,extraop=s.extraop}
end
s.listed_names={333200323}
s.fit_monster={333200323} --should be removed in hardcode overhaul
s.listed_series={0xbbc}
function s.ritualfil(c)
	return c:IsCode(333200323) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:HasLevel() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end