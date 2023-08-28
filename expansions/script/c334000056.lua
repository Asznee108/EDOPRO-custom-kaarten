--Windwitch Synchro Fusion Chime
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon 1 "Windwitch" monster using "Windwitch - Winter Bell"
	local fparams={aux.FilterBoolFunction(Card.IsSetCard,0xf0),nil,nil,function(e,tp,mg) return nil,s.fcheck end}
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop(Fusion.SummonEffTG(table.unpack(fparams)),Fusion.SummonEffOP(table.unpack(fparams))))
	c:RegisterEffect(e1)
    -- Set itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={14577226,id}
s.listed_series={0xf0}
--fusion check
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,14577226)
end
--Special Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.spfilter(c,e,tp)
	return c:IsCode(14577226) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
        and (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsLocation(LOCATION_EXTRA))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.exfilter(c,tc)
	return c:IsSetCard(0xf0) and c:IsSynchroSummonable(tc)
end
function s.spop(fustg,fusop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local loc=LOCATION_EXTRA
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp):GetFirst()
	    if not tc then return end
	    if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		    local c=e:GetHandler()
		    -- Cannot attack
		    local e1=Effect.CreateEffect(c)
		    e1:SetDescription(aux.Stringid(id,3))
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_CANNOT_ATTACK)
		    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		    tc:RegisterEffect(e1,true)
		    -- Effects are negated
		    local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
		    e2:SetCode(EFFECT_DISABLE)
		    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		    tc:RegisterEffect(e2)
		    local e3=e2:Clone()
		    e3:SetCode(EFFECT_DISABLE_EFFECT)
		    e3:SetValue(RESET_TURN_SET)
		    tc:RegisterEffect(e3)
		    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	    end
	    Duel.SpecialSummonComplete()
	    local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,tc)
	    local fus=fustg(e,tp,eg,ep,ev,re,r,rp,0)
	    local opt1,opt2=fus,#sg>0
	    if (opt1 or opt2) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		    Duel.BreakEffect()
		    local opt
		    if opt1 and opt2 then
			    opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		    elseif opt1 and not opt2 then
			    opt=Duel.SelectOption(tp,aux.Stringid(id,1))
		    elseif opt2 and not opt1 then
			    opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
		    end
		    if opt==0 then
			    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON+CATEGORY_FUSION_SUMMON)
			    fusop(e,tp,eg,ep,ev,re,r,rp)
		    elseif opt==1 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			    local sc=sg:Select(tp,1,1,nil):GetFirst()
			    Duel.SynchroSummon(tp,sc,tc)
		    end
	    end
    end
end
--Set this card from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and (r&REASON_EFFECT)~=0
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end