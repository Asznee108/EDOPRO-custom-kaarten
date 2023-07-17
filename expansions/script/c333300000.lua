--Resonant Creation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTarget(aux.TargetBoolFunction(s.sumfilter))
	c:RegisterEffect(e2)
    -- Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x57}
function s.sumfilter(c)
    return c:IsAttackBelow(1500) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER)
end
function s.confilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.tgfilter(c,e)
	return c:IsSetCard(0x57) and c:IsCanBeEffectTarget(e)
end
function s.spfilter(c,e,tp)
    return (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND))
end
function s.resconfunc(cg)
	-- Creates a rescon function to be used with Auxiliary.SelectUnselectGroup
	-- that will ensure cards in sg will have at least one card in cg with the same name.
	-- It also ensures that each card has one exclusive pair.
	return function (sg,e,tp,mg)
		local code1=sg:GetFirst():GetLevel()
		local f1=cg:Filter(Card.IsLevel,nil,code1)
		if #f1<1 then return end
		if #sg>1 then
			local code2=sg:GetNext():GetLevel()
			return (code1==code2 and #f1>1)
				or (cg-f1):IsExists(Card.IsLevel,1,nil,code2)
		end
		return true
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e)
	local rescon=s.resconfunc(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,1,nil,e))
	if chk==0 then return ft>0 and aux.SelectUnselectGroup(tg,e,tp,1,1,rescon,0) end
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(s.confilter),tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(tg,e,tp,1,2,rescon,0) then
		ft=math.min(2,ft)
	else ft=1 end
	local g=aux.SelectUnselectGroup(tg,e,tp,1,ft,rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#g,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	local gc=#g
	if gc==0 then return end
	local rescon=s.resconfunc(g)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,1,nil,e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<gc
		or (gc>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		or not aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,0) then return end
	local ssg=aux.SelectUnselectGroup(sg,e,tp,gc,gc,rescon,1,tp,HINTMSG_SPSUMMON)
	if #g==#ssg then
		for sc in ssg:Iter() do
			-- Special summon
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
            Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		end
	end
end