--Champion's Ambition
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
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
--Destroy
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x152f)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
        local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
            if h2==0 then
               Duel.Draw(1-tp,1,REASON_EFFECT) 
            end
        else
            local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
            if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local sg=g2:Select(tp,1,1,nil)
                Duel.HintSelection(sg)
                Duel.SendtoGrave(sg,REASON_EFFECT)
            end
        end
	end
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