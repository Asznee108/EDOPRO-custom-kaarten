--Ruin Resonator 
local s,id=GetID()
function s.initial_effect(c)
   --Can be used as material from the hand for DARK Dragon Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
	e1:SetValue(s.synval)
	c:RegisterEffect(e1)
    --Send 1 monster to GY and add 1 FIRE Fiend monster from the Deck
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_names={id}
s.listed_series={0x17}
--sumlimit
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO)
end
function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_SYNCHRO)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
--hand material
function s.synval(e,mc,sc)
	return sc:IsAttribute(ATTRIBUTE_DARK) and sc:IsRace(RACE_DRAGON)
end
----Send 1 monster to GY and add 1 FIRE Fiend monster from the Deck
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
    s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FIEND) 
     and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.tgfilter(c,tp)
	return (c:IsSetCard(0x57) or (c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)))
     and c:IsMonster() and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,1,nil,nil)
	if #g>0 and #g2>0 and Duel.SendtoGrave(g,REASON_EFFECT) then
		local sg=g2:Select(tp,1,1,nil,nil)
        Duel.SendtoHand(sg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
	end
end