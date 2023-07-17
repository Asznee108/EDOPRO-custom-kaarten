--Topologic Chaos Dragon
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
    --Race
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(RACE_DRAGON)
	c:RegisterEffect(e0)
	--banish monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --banish and special summon
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
--Banish Summoned monsters
function s.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return (ec:GetLinkedZone(c:GetPreviousControler())&(1<<c:GetPreviousSequence()))~=0
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	for tc in aux.Next(Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK)) do
		if eg:IsExists(s.cfilter,1,nil,tc) then return true end
	end
	return false
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN+STATUS_FLIP_SUMMON_TURN)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ALL,LOCATION_ALL,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ALL,LOCATION_ALL,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
--Banish and Special Summon
function s.spfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return ~(e:GetHandler():GetLinkedZone()&0x60)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1):GetFirst()
        if tc:GetOwner()==tp and re:GetHandler():IsRelateToEffect(re) then
            Duel.BreakEffect()
            if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
                --Increase ATK
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(1000)
                tc:RegisterEffect(e1)
            end
            Duel.SpecialSummonComplete()
        elseif tc:GetOwner()==1-tp then
            Duel.BreakEffect()
            if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) then
                --Halve ATK
                local e1=Effect.CreateEffect(c)
		        e1:SetType(EFFECT_TYPE_SINGLE)
		        e1:SetCode(EFFECT_SET_ATTACK)
		        e1:SetValue(tc:GetAttack()/2)
		        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		        tc:RegisterEffect(e1)
                local e2=Effect.CreateEffect(c)
		        e2:SetType(EFFECT_TYPE_SINGLE)
		        e2:SetCode(EFFECT_DISABLE)
		        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		        tc:RegisterEffect(e2,true)
		        local e3=Effect.CreateEffect(c)
		        e3:SetType(EFFECT_TYPE_SINGLE)
		        e3:SetCode(EFFECT_DISABLE_EFFECT)
		        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		        tc:RegisterEffect(e3,true)
            end
            Duel.SpecialSummonComplete()
        end
	end
end