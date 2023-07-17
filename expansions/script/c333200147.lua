--Summoned by the King
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={0x543,0x57}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.filter2(c,e,tp,code)
	return not c:IsCode(code) and c:IsAbleToGrave() and ((c:IsType(TYPE_MONSTER) and ((c:IsSetCard(0x57) and c:IsType(TYPE_TUNER)) or ((c:IsLevel(4) or c:IsLevel(5) or c:IsLevel(6)) and not c:IsType(TYPE_TUNER)))))
		or (c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:ListsArchetype(c,0x57) or c:ListsArchetype(c,0x543)))
end
function s.filter(c,e,tp)
	return c:IsAbleToHand() and not c:IsCode(code) and
	((c:IsType(TYPE_MONSTER) and ((c:IsSetCard(0x57) and c:IsType(TYPE_TUNER)) or ((c:IsLevel(4) or c:IsLevel(5) or c:IsLevel(6)) and not c:IsType(TYPE_TUNER)))))
	or (c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:ListsArchetype(c,0x57) or c:ListsArchetype(c,0x543)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,e,tp,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if e:GetHandler():IsLocation(LOCATION_HAND) then end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local c2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,c1:GetFirst():GetCode())
	if c1 and c2 then
		Duel.SendtoHand(c1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c1)
		if c2 then
            Duel.SendtoGrave(c2,REASON_EFFECT)
		end
	end
end