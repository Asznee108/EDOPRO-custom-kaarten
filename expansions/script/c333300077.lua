--King Red Dragon Archfiend
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(s.matfilter),1,99)
	-- Name becomes "Red Dragon Archfiend" while on the field on in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(70902743)
	c:RegisterEffect(e1)
    --Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indeval)
	c:RegisterEffect(e2)
    --destroy
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    --Add trap and activate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SEARCH)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_BATTLE_START)
	e4:SetCountLimit(1,id)
    e4:SetCondition(s.trcon)
	e4:SetTarget(s.trtg)
	e4:SetOperation(s.trop)
	c:RegisterEffect(e4)
end
s.listed_names={70902743}
s.listed_series={0x543,0x52f}
function s.matfilter(c)
    return c:IsRed() or c:IsKing()
end
function s.indeval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
--Destroy
function s.desfilter(c,lv)
	return c:IsFaceup() and (not c:HasLevel() or c:IsLevelBelow(lv))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local lv=c:GetLevel()
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel()) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,c:GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,c:GetLevel())
	local ct=Duel.Destroy(g,REASON_EFFECT)
	local ig=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #ig==0 then return end
	ig:ForEach(s.negop,e:GetHandler())
end
function s.negop(tc,c)
	--Effects negated
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetValue(RESET_TURN_SET)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
    if tc:IsType(TYPE_TRAPMONSTER) then
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
end
--Search Trap
function s.trcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.filter(c)
	return (c:IsRed() or c:IsKing()) and c:IsTrap() and c:IsAbleToHand()
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
        local te=tc:GetActivateEffect()
        if not te then return end
        local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
        if pre[1] then
            for i,eff in ipairs(pre) do
                local prev=eff:GetValue()
                if type(prev)~='function' or prev(eff,te,tp) then return end
            end
        end
        if tc:CheckActivateEffect(false,false,false)~=nil and not tc:IsHasEffect(EFFECT_CANNOT_TRIGGER)
            and Duel.GetLocationCount(tp,LOCATION_SZONE) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            local tpe=tc:GetType()
            local tg=te:GetTarget()
            local co=te:GetCost()
            local op=te:GetOperation()
            e:SetCategory(te:GetCategory())
            e:SetProperty(te:GetProperty())
            Duel.ClearTargetCard()
            local loc=LOCATION_SZONE
            if (tpe&TYPE_FIELD)~=0 then
                loc=LOCATION_FZONE
                local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
                if Duel.IsDuelType(DUEL_1_FIELD) then
                    if fc then Duel.Destroy(fc,REASON_RULE) end
                    fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
                    if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
                else
                    fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
                    if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
                end
            end
            Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
            if (tpe&TYPE_TRAP+TYPE_FIELD)==TYPE_TRAP+TYPE_FIELD then
                Duel.MoveSequence(tc,5)
            end
            Duel.Hint(HINT_CARD,0,tc:GetCode())
            tc:CreateEffectRelation(te)
            if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
                tc:CancelToGrave(false)
            end
            if te:GetCode()==EVENT_CHAINING then
                local chain=Duel.GetCurrentChain()-1
                local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
                local tc=te2:GetHandler()
                local g=Group.FromCards(tc)
                local p=tc:GetControler()
                if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
                if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
            elseif te:GetCode()==EVENT_FREE_CHAIN then
                if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
                if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
            else
                local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
                if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
                if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
            end
            Duel.BreakEffect()
            local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
            if g then
                local etc=g:GetFirst()
                while etc do
                    etc:CreateEffectRelation(te)
                    etc=g:GetNext()
                end
            end
            tc:SetStatus(STATUS_ACTIVATED,true)
            if not tc:IsDisabled() then
                if te:GetCode()==EVENT_CHAINING then
                    local chain=Duel.GetCurrentChain()-1
                    local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
                    local tc=te2:GetHandler()
                    local g=Group.FromCards(tc)
                    local p=tc:GetControler()
                    if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
                elseif te:GetCode()==EVENT_FREE_CHAIN then
                    if op then op(te,tp,eg,ep,ev,re,r,rp) end
                else
                    local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
                    if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
                end
            else
                --insert negated animation here
            end
            Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
            if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
                Duel.Equip(tp,tc,g:GetFirst())
            end
            tc:ReleaseEffectRelation(te)
            if etc then
                etc=g:GetFirst()
                while etc do
                    etc:ReleaseEffectRelation(te)
                    etc=g:GetNext()
                end
            end
        end
	end
end