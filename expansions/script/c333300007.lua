--Champion's Revenge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x52f}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsChampion,tp,LOCATION_GRAVE,0,4,nil)
end
function s.filter(c,e,tp)
	return c:IsKing() and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.desfilter(c)
	return c:IsFacedown()
end
function s.atkfilter(c)
	return c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP_ATTACK)
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,nil)
        Duel.Destroy(g,REASON_EFFECT)
        local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_ONFIELD,nil)
	    local tc=g:GetFirst()
	    for tc in aux.Next(g) do
		    --Cannot activate their effects
		    local e1=Effect.CreateEffect(e:GetHandler())
		    e1:SetDescription(3302)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_DISABLE)
		    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		    e1:SetRange(LOCATION_ONFIELD)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		    tc:RegisterEffect(e1)
			local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
            local tc=g:GetFirst()
	        for tc in aux.Next(g) do
		        Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
               --Change their ATK to 0
		        local e2=Effect.CreateEffect(e:GetHandler())
		        e2:SetType(EFFECT_TYPE_SINGLE)
		        e2:SetCode(EFFECT_UPDATE_ATTACK)
		        e2:SetValue(-200)
		        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		        tc:RegisterEffect(e2)
    	    end
    	end
        tc:CompleteProcedure()
    end
end