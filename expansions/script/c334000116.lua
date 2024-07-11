--D/D Count Surveyor
local s,id=GetID()
function s.initial_effect(c)
    --pendulum summon
	Pendulum.AddProcedure(c)
	--Stacking Pendulum Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2 end)
	e1:SetOperation(s.stackop)
	c:RegisterEffect(e1)
    --Disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
    --Add this card to hand
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x10af,0xaf,0xae}
s.listed_names={id}
--Stack
function s.stackop(e,tp,eg,ev,ep,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local mg=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,tc)
	if #mg==0 then return end
	Duel.Overlay(tc,mg)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    tc:RegisterEffect(e1,true)
end
function s.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup()
	local val=e:GetHandler():GetAttack()
	for tc in g:Iter() do
		local atk=tc:IsMonster() and tc:GetAttack() or 0
		val=val+atk
	end
	return val
end
--Disable
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x10af),tp,LOCATION_MZONE,0,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsOriginalType(TYPE_MONSTER)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsOriginalType(TYPE_MONSTER) and not tc:IsDisabled() and tc:IsControler(1-tp) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
        if tc:IsLocation(LOCATION_SZONE) or c:IsLocation(LOCATION_PZONE) then
            Duel.ChangePosition(tc,POS_FACEDOWN)
        end
	end
end
--Add this card to hand
function s.cfilter(c,tp)
	return (c:IsSetCard(0xaf) or c:IsSetCard(0xae)) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end