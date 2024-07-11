--Infernity Re-Burning
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Return opponent's card to hand
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xb}
--Draw
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		return (Duel.IsPlayerCanDraw(tp,h1) or h1==0)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0xb)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_EFFECT)
    local sg=Duel.GetOperatedGroup()
    local ct=sg:FilterCount(s.cfilter,nil)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
	    e1:SetType(EFFECT_TYPE_FIELD)
	    e1:SetCode(EFFECT_DRAW_COUNT)
	    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	    e1:SetTargetRange(1,0)
	    e1:SetValue(ct+1)
	    e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
	    Duel.RegisterEffect(e1,tp)
	end
end
--Return opponent's card to hand
function s.thcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0 and aux.exccon
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end