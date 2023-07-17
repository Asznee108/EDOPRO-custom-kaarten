--Rokket Reloader
local s,id=GetID()
function s.initial_effect(c)
    --reduce level and Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --reload
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetTarget(s.reltg)
    e2:SetOperation(s.relop)
    c:RegisterEffect(e2)
end
s.listed_series={0x102}
function s.spfilter(c,e,tp,lv)
    return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv-1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lv=e:GetHandler():GetLevel()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,lv) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    local lv=c:GetLevel()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,lv)
    if #g>0 and c:IsRelateToEffect(e) then
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetCategory(CATEGORY_LVCHANGE)
            e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_UPDATE_LEVEL)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		    e1:SetValue(-tc:GetLevel())
		    c:RegisterEffect(e1)
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalAttribute(ATTRIBUTE_DARK)
end
function s.relfilter(c)
    return c:IsSetCard(0x102) and c:IsMonster() and c:IsAbleToDeck()
end
function s.reltg(e,tp,ev,eg,re,r,rg,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,2)
    end
end
function s.relop(e,tp,ev,eg,re,r,rg)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g>0 and c:IsRelateToEffect(e) then
        sg=g:Select(tp,1,5,nil)
        Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
		Duel.Draw(tp,2,REASON_EFFECT)
    end
end
