--Black Rose Princess
local s,id=GetID()
function s.initial_effect(c)
	--Take "Rose" monster from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thspcost)
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special Summon "Black Rose Dragon"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BLACK_ROSE_DRAGON}
s.listed_series={0x123}
--Take "Rose" monster from Deck
function s.thspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.thspfilter(c,e,tp,zone_chk)
	return c:IsSetCard(0x123) and (c:IsAbleToHand() or (zone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zone_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local zone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone_chk):GetFirst()
	if sc then
		aux.ToHandOrElse(sc,tp,
			function(c)
				return zone_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function(c)
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end,
			aux.Stringid(id,3)
		)
	end
end
--Special Summon "Black Rose Dragon"
function s.spcfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_PLANT))
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re and eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_BLACK_ROSE_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
        sc:CompleteProcedure()
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		--Gain 1500 ATK
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e2,true)
    end
end