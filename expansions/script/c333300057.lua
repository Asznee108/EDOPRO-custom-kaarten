--Red Spear Strike
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
    --pierce
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
    --Self destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
end
s.listed_series={0x543}
s.listed_names={id}
function s.cfilter(c,tp,re)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE) and (c:GetReason()&0x41)==0x41 
    and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRed()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,re)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.cfilter,nil,tp,re)
	local ct=eg:FilterCount(s.cfilter,nil,tp,re)
	local atk=re:GetHandler():GetAttack()
    local def=g:GetSum(Card.GetPreviousDefenseOnField)
    local atkval=ct*atk
    local dam=atkval-def
    Duel.Damage(1-tp,dam,REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.filter(c)
	return c:IsFaceup() and c:IsRed() and c:IsType(TYPE_SYNCHRO) and not c:IsHasEffect(EFFECT_PIERCE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Inflict piercing damage
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3208)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsRed()
end
function s.descon(e)
    local tp=e:GetHandlerPlayer()
	return Duel.GetCurrentPhase()==PHASE_END
		and not Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
end