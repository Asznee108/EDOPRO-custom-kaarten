--Overtune Synchron
local s,id=GetID()
function s.initial_effect(c)
	--Special summon (from hand)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --special summon (GY)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
    --substitute "Synchron" Tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(20932152)
	c:RegisterEffect(e3)
    --synchro other monsters Level 1
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetOperation(s.synop2)
	c:RegisterEffect(e4)
    --Synchro monster treatment
	local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
	e5:SetTarget(s.target1)
	e5:SetOperation(s.operation1)
	c:RegisterEffect(e5)
    --tuner treatment
	local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.target2)
	e6:SetOperation(s.operation2)
	c:RegisterEffect(e6)
    -- Change Type or Attribute or Name of a monster
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(s.chtg)
	e7:SetOperation(s.chop)
	c:RegisterEffect(e7)
end
s.listed_series={0x1017}
function s.spcfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and not c:IsPublic()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_EXTRA,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_EXTRA,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_CONFIRM,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleExtra(tp)
	g:DeleteGroup()
end
function s.spfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtraAsCost()
end
function s.spcon2(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,0,REASON_COST)
	g:DeleteGroup()
end
function s.synop2(e,tg,ntg,sg,lv,sc,tp)
    return (#sg-1)<lv,true
end
function s.filter1(c)
	return c:IsFaceup() and not c:IsType(TYPE_SYNCHRO)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_SYNCHRO)
		tc:RegisterEffect(e1)
	end
end
function s.filter2(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,99,nil)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
    while tc do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_ADD_TYPE)
	    	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	    	e1:SetValue(TYPE_TUNER)
	    	tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
function s.chfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil,e)
    if chk==0 then return #g>0 end
    local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))
    e:SetLabel(op)
    if e:GetLabel()==0 then
        local rc=aux.AnnounceAnotherRace(g,tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local sg=g:FilterSelect(tp,Card.IsDifferentRace,1,1,nil,rc)
        Duel.SetTargetCard(sg)
        e:SetLabel(0,rc)
    elseif e:GetLabel()==0 then
        local att=aux.AnnounceAnotherAttribute(g,tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local sg=g:FilterSelect(tp,Card.IsDifferentAttribute,1,1,nil,att)
        Duel.SetTargetCard(sg)
        e:SetLabel(1,att)
    else
        local ac=Duel.AnnounceCard(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local sg=g:FilterSelect(tp,Card.IsFaceup,1,1,nil,nil)
        Duel.SetTargetCard(sg)
        e:SetLabel(2,ac)
    end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local op,decl=e:GetLabel()
	if op==0 and tc:IsDifferentRace(decl) then
		-- Change monster type
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(decl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	elseif op==1 and tc:IsDifferentAttribute(decl) then
		-- Change attribute
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(decl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
    elseif op==2 then
		-- Change name
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(decl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
