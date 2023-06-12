--Performapal Odd-Eyes Warrior
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c,false)
	--indes card eff
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(s.indcon)
	e0:SetValue(s.indval)
	c:RegisterEffect(e0)
    -- Replace Pendulum Scale Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80896940,1))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetValue(SUMMON_TYPE_SYNCHRO+82)
	e2:SetCondition(s.sprcon)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
    --special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --place in pendulum zone
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.listed_series={0x9f,0x98,0x99}
s.listed_series={0x1017}
s.material_setcode=0x1017
function s.tfilter(c,lc,stype,tp)
	return c:IsSetCard(0x1017,lc,stype,tp) or c:IsHasEffect(20932152)
end
function s.indfilter(c)
    return c:IsSetCard(0x9f) or c:IsSetCard(0x98) or c:IsSetCard(0x99)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
function s.indval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end
function s.pendfilter(c)
    return (c:IsSetCard(0x9f) or c:IsSetCard(0x98) or c:IsSetCard(0x99)) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and not c:IsForbidden()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA) and s.penfilter(chkc) end
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_PZONE,0,1,e:GetHandler()) 
        and Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
	local tc=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_PZONE,0,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
        local g=Duel.SelectMatchingCard(tp,s.pendfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_EXTRA,0,1,1)
        if #g>0 then 
            local pc=g:GetFirst()
            Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
    end
end
function s.sfilter(c,tp,sc)
	local rg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_MZONE,0,c)
	return (c:IsSetCard(0x9f) or c:IsSetCard(0x98) or c:IsSetCard(0x99)) and c:IsType(TYPE_PENDULUM) and c:IsReleasable() and c:IsLevelBelow(2147483647)
		and rg:IsExists(s.filterchk,1,nil,rg,Group.CreateGroup(),tp,c,sc)
end
function s.pfilter(c)
	return c:IsLevelBelow(2147483647) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsReleasable()
end
function s.filterchk(c,g,sg,tp,sync,sc)
	sg:AddCard(c)
	sg:AddCard(sync)
	local res=Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0 
		and sg:CheckWithSumEqual(Card.GetLevel,7,#sg,#sg)
	sg:RemoveCard(sync)
	if not res then
		res=g:IsExists(s.filterchk,1,sg,g,sg,tp,sync,sc)
	end
	sg:RemoveCard(c)
	return res
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	local sync=g:GetFirst()
	local rg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_MZONE,0,sync)
	local tc
	local mg=Group.CreateGroup()
	while true do
		local tg=rg:Filter(s.filterchk,mg,rg,mg,tp,sync,c)
		if #tg<=0 then break end
		mg:AddCard(sync)
		local cancel=#mg>1 and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 
			and mg:CheckWithSumEqual(Card.GetLevel,7,#mg,#mg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		tc=Group.SelectUnselect(tg,mg,tp,cancel,cancel)
		if not tc then break end
		mg:RemoveCard(sync)
		if tc~=sync then
			if mg:IsContains(tc) then
				mg:RemoveCard(tc)
			else
				mg:AddCard(tc)
			end
		end
	end
	mg:Merge(g)
	Duel.Release(mg,REASON_COST)
end
function s.spfilter(c,e,tp)
	return (c:IsType(TYPE_TUNER) or c:IsType(TYPE_PENDULUM)) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then 
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end