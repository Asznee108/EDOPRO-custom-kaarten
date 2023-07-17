--Champion's Tune
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Can be activated from the hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetLabel(0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Check use of "Champion" cards
    aux.GlobalCheck(s,function()
		s[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x152f}
--Champion count
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsChampion() then
		s[0]=s[0]+1
	end
end
--Activate from hand
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.handcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==1
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--Activate
function s.filter(c,tp,mg,ec)
	return c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 and c:IsSynchroSummonable(ec,mg)
end
function s.matfilter(c)
   return c.IsCanBeSynchroMaterial(c) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	local ct=e:GetLabel()
	if chk==0 then
		if ct<3 then
			e:SetDescription(aux.Stringid(id,0))
			local c=e:GetHandler()
		    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
		    local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_ADD_TYPE)
		    e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
		    c:RegisterEffect(e1)
		    local e2=e1:Clone()
		    e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		    e2:SetValue(1)
		    c:RegisterEffect(e2)
            local e3=e1:Clone()
            e3:SetCode(EFFECT_ADD_RACE)
            e3:SetValue(RACE_FIEND)
            c:RegisterEffect(e3)
		    local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp,mg,e:GetHandler())
		    e1:Reset()
		    e2:Reset()
		    return res
		else
			e:SetDescription(aux.Stringid(id,1))
            Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		end
	end
	if ct<3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()<3 then
		s.scop(e,tp,eg,ep,ev,re,r,rp)
	else
		s.atkop(e,tp,eg,ep,ev,re,r,rp)
	end
end
--Synchro Summon using this card
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tg=Group.FromCards(c)
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_ADD_RACE)
    e3:SetValue(RACE_FIEND)
    c:RegisterEffect(e3)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
    local synchro=g:Select(tp,1,1,nil):GetFirst()
	local mg=tg+synchro
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg,e:GetHandler()):GetFirst()
	if sc then
		c:CancelToGrave()
		Duel.SynchroSummon(tp,sc,c,mg)
        --add to hand
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_SPSUMMON)
		e1:SetRange(LOCATION_ALL-LOCATION_HAND)
		e1:SetCondition(s.accon)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
        e1:SetLabelObject(sc)
		c:RegisterEffect(e1)
		c:CancelToGrave()
	end
    local ct=e:GetLabel()
	ct=ct+1
	c:SetTurnCounter(ct)
	e:SetLabel(ct)
	c:ResetFlagEffect(id)
	c:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id,math.min(3,e:GetLabel())))
end
    --Add to hand
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler()==e:GetLabelObject() then
		e:GetLabelObject():ResetFlagEffect(id)
		e:Reset()
		return true
	else
		return false
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
--ATK gain
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local num=s[0]
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(tc:GetAttack()*num)
		tc:RegisterEffect(e1)
	end
end