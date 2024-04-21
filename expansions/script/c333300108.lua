--Champion's Pulse
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_ATTACK+TIMING_END_PHASE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Search 1 "Champion" card from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x152f}
--Battle Phase
function s.filter(c)
    return c:IsLevelBelow(4) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
    and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,2,nil,0x152f)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if Duel.GetTurnPlayer()~=tp 
    and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
        e1:SetLabel(Duel.GetTurnCount())
        e1:SetCondition(s.skipcon)
        e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
    end
	Duel.RegisterEffect(e1,tp)
    if Duel.GetTurnPlayer()~=tp 
    and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<PHASE_BATTLE) then
        Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
    end
    if Duel.Recover(1-tp,1000,REASON_EFFECT) 
    and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end
function s.skipcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
--Search
function s.thfilter(c,tp)
	return c:IsSetCard(0x152f) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end