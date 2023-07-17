--Red Trap
local s,id=GetID()
Duel.LoadScript("c420.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x543}
s.listed_names={id}
function s.cfilter(c)
	return c:IsFaceup() and c:IsRed() and c:IsType(TYPE_SYNCHRO)
end
function s.costfilter(c)
    return c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
    g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable() and not c:IsCode(id)
end
function s.tfilter(c)
	return c:IsType(TYPE_TRAP) and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_DECK,0,nil)
    local g3=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
		Duel.SSet(tp,tc)
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg2=g2:Select(tp,1,1,nil)
    if #g2>0 then
        Duel.SendtoHand(sg2,tp,REASON_EFFECT)
    end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
    local sg3=g3:Select(tp,1,1,nil)
    local tc2=sg3:GetFirst()
    if #g3>0 then
        Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc2,0)
		Duel.ConfirmDecktop(tp,1)
    end
end