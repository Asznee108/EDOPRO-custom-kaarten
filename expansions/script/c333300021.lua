--Rugged Soul
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_SPSUMMON+TIMING_END_PHASE)
	e1:SetTarget(s.eqtg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.filter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.eqfilter(c,tp,oc)
	return (c:IsControler(1-tp) or (c:IsType(TYPE_SYNCHRO))) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE+LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA,LOCATION_MZONE,1,1,nil,tp,tc):GetFirst()
	if not ec then return end
	local loc=ec:GetLocation()
	if s.equipop(tc,e,tp,ec) and loc==LOCATION_EXTRA then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	    e1:SetProperty(EFFECT_FLAG_DELAY)
	    e1:SetCode(EVENT_TO_GRAVE)
		e1:SetCondition(s.spcon)
	    e1:SetTarget(s.sptg)
	    e1:SetOperation(s.spop)
		ec:RegisterEffect(e1)
    elseif s.equipop(tc,e,tp,ec) and loc==LOCATION_MZONE then
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetCategory(CATEGORY_DAMAGE)
	    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	    e2:SetCode(EVENT_TO_GRAVE)
	    e2:SetCondition(s.damcon)
	    e2:SetTarget(s.damtg)
	    e2:SetOperation(s.damop)
		ec:RegisterEffect(e2)
	end
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return false end
    local atk=tc:GetBaseAttack()
    if atk>0 then
	    --atkup
	    local e1=Effect.CreateEffect(tc)
	    e1:SetType(EFFECT_TYPE_EQUIP)
	    e1:SetCode(EFFECT_UPDATE_ATTACK)
	    e1:SetValue(atk/2)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	    tc:RegisterEffect(e1)
	    local e2=Effect.CreateEffect(c)
	    e2:SetType(EFFECT_TYPE_SINGLE)
	    e2:SetCode(EFFECT_EQUIP_LIMIT)
	    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	    e2:SetValue(true)
	    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	    tc:RegisterEffect(e2)
    end
	return true
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_SYNCHRO,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local c=e:GetHandler()
	local player=c:GetOwner()
    local dam=c:GetBaseAttack()
	Duel.SetTargetPlayer(player)
	Duel.SetTargetParam(dam/2)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,player,dam/2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end