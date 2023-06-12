--Synchron Revving
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x1017}
function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_SYNCHRO)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and Duel.CheckLPCost(tp,500) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
    Duel.PayLPCost(tp,500)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
function s.exfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c.material and c:ListsArchetypeAsMaterial(0x1017)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.spfilter(c,sc)
	return c:IsCode(table.unpack(sc.material))
		and c:IsAbleToGrave()
end
function s.spfilter2(c)
	return c:HasLevel() and c:IsAbleToRemove() and not c:IsType(TYPE_TUNER)
end
function s.rescon(sg,e,tp,mg,flv)
	return sg:GetSum(Card.GetLevel)<=flv
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc1=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ft):GetFirst()
    local lvsc=tc1:GetLevel()
	if not tc1 then return end
	Duel.ConfirmCards(1-tp,tc1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_MZONE,0,1,1,nil,e,tp,cg:GetFirst(),ft):GetFirst()
    local lv=tc:GetLevel()
    local flv=lvsc-lv
	if tc then
		Duel.SendtoGrave(tc,REASON_EFFECT)
        local rg=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,e,tp)
	    local g=aux.SelectUnselectGroup(rg,e,tp,1,math.min(1,nil),s.rescon,1,tp,HINTMSG_REMOVE)
	    if #g>0 then
		    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
            if Duel.SpecialSummon(tc1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
                tc1:CompleteProcedure()
            end
	    end
	end
end