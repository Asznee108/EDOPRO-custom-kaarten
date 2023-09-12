--The Ruler's Synchro
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Special Summon 1 "Crimson Dragon" from your Extra Deck

end
s.listed_names={CARD_CRIMSON_DRAGON,CARD_RED_DRAGON_ARCHFIEND,id}
--Special Summon Synchro Monster 
function s.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.rescon(synchro,scard)
	return	function(sg,e,tp,mg)
				sg:AddCard(synchro)
				local res=Duel.GetLocationCountFromEx(tp,tp,sg,scard)>0 
					and sg:CheckWithSumEqual(Card.GetLevel,scard:GetLevel(),#sg,#sg)
				sg:RemoveCard(synchro)
				return res
			end
end
function s.filter2(c,e,tp,sc)
	local rg=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_MZONE,0,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave() and aux.SpElimFilter(c,true) 
		and aux.SelectUnselectGroup(rg,e,tp,nil,2,s.rescon(c,sc),0)
end
function s.filter3(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToGrave() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g1:GetFirst()
	if sc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil,tp,sc)
		local synchro=g2:GetFirst()
		local rg=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_MZONE,0,synchro)
		local sg=aux.SelectUnselectGroup(rg,e,tp,1,2,s.rescon(synchro,sc),1,tp,HINTMSG_TOGRAVE,s.rescon(synchro,sc))
		sg:AddCard(synchro)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end
--Special Summon "The Crimson Dragon"
