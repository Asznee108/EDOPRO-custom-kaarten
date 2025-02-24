--Champion's Soul 
local s,id=GetID()
function s.initial_effect(c)
    --Can be activated from the hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e0)
	--Synchro Summon using Deck
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	--Synchro Summon using field and GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sctg2)
	e2:SetOperation(s.scop2)
	c:RegisterEffect(e2)
    --Add 1 Spell/Trap from your Deck to your hand that mentions "Synchro Monster" in its text
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

end
s.listed_names={id}
--Synchro Summon using Deck
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		Synchro.Send=0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetOperation(s.regop)
		sc:RegisterEffect(e1)
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end
--Synchro Summon using field and GY 
function s.filter(c,e,tp)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	return Duel.IsExistingMatchingCard(s.matfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp,c)
end
function s.matfilter1(c,tp,syncard)
	local loc
	if c:IsLocation(LOCATION_MZONE) then loc=LOCATION_GRAVE else loc=LOCATION_MZONE end
	return Duel.IsExistingMatchingCard(s.matfilter2,tp,loc,0,1,c,syncard,c)
end
function s.matfilter2(c,syncard,mc)
	return syncard:IsSynchroSummonable(nil,Group.FromCards(c,mc))
end
function s.sctg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local g1=Duel.SelectMatchingCard(tp,s.matfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp,tc)
		local loc
		if g1:GetFirst():IsLocation(LOCATION_MZONE) then loc=LOCATION_GRAVE else loc=LOCATION_MZONE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,loc,0,1,1,nil,tc,g1:GetFirst())
		g2:Merge(g1)
		Duel.SynchroSummon(tp,tc,nil,g2)
	end
end
--Search
function s.check_synchro_summon_effect(c)
    local egroup={c:GetCardEffect()}
    for _,ce in ipairs(egroup) do
        local tpe=ce:GetType()
        if tpe & EFFECT_TYPE_ACTIVATE ~= 0 and ce:GetCategory() & CATEGORY_SPECIAL_SUMMON ~= 0 then
            return true
        end
    end
    return false
end
function s.thfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:ListsCardType(TYPE_SYNCHRO)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end