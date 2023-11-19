--Show Me Your Motivation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id,555550000}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(555550000)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
        --prevent activations for the rest of that phase
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e0:SetCode(EFFECT_CANNOT_ACTIVATE)
        e0:SetTargetRange(1,1)
        e0:SetValue(1)
        e0:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e0,tp)
        --skip phases until Battle Phase
        local p=Duel.GetTurnPlayer()
        Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(p,PHASE_END,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
        Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
        Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
        Duel.RegisterEffect(e1,tp)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCode(EFFECT_CANNOT_EP)
        e2:SetTargetRange(1,0)
        e2:SetReset(RESET_PHASE+PHASE_MAIN1,Duel.GetCurrentPhase()<=PHASE_MAIN1 and 2 or 1)
        Duel.RegisterEffect(e2,tp)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetCode(EFFECT_CANNOT_EP)
        e3:SetTargetRange(0,1)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
        --prevent activation of this card
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
        e3:SetCode(EFFECT_CANNOT_ACTIVATE)
        e3:SetTargetRange(1,0)
        e3:SetValue(s.limit)
        e3:SetReset(RESET_PHASE+PHASE_END,3)
        Duel.RegisterEffect(e3,tp)
    else
        local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD,0,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_RULE,PLAYER_NONE,1-tp)
        end
    end
end
function s.limit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(id)
end