--Not Done Yet
local s,id=GetID()
function s.initial_effect(c)
	--immune
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_REMOVED)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--act
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCost(s.rmcost)
	c:RegisterEffect(e1)
    --cannot lose
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_LOSE_LP)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetTargetRange(1,1)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --nvm make em lose
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCondition(s.condition)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetLP(tp)<=0 or Duel.GetLP(1-tp)<=0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
end