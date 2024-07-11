--Dragoon de Fleur
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Destroy and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={19642774}
--Material check
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_TUNER,lc,sumtype,tp)
end
--Destroy and Special Summon
function s.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsSummonLocation(LOCATION_HAND)
end
function s.spfilter(c,e,tp)
    return (c:IsCode(19642774) or c:ListsCode(19642774)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=eg:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) 
    and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_SYNCHRO) 
    and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
    and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)) 
    or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
    and c:IsLevel(8) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
        local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
        if tc:IsType(TYPE_SYNCHRO) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        else
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end