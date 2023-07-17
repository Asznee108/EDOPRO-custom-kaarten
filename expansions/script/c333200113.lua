--Test Summon
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 monster from tes
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--act
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCost(s.rmcost)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp,rp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,1,nil,e,tp,rp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_HAND+LOCATION_REMOVED,1,1,nil,e,tp,rp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end