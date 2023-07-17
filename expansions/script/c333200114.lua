--Ore No Tarn, Duraw!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,nil,nil)
		aux.GlobalCheck(s,function()
		s[0]=nil
		s[1]=nil
		s[2]=0
		s[3]=0
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	end)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local ge1=Effect.CreateEffect(e:GetHandler())
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PREDRAW)
		ge1:SetCondition(s.flipcon)
		ge1:SetOperation(s.flipop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
        Duel.RegisterEffect(ge2,1)
	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
    local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_ADJUST)
	ge1:SetCountLimit(1,id)
	ge1:SetCondition(s.drawcon)
	ge1:SetOperation(s.drawpop)
	Duel.RegisterEffect(ge1,1)
	local ge2=ge1:Clone()
    Duel.RegisterEffect(ge2,0)
	--Starting hand select
	local ge3=Effect.CreateEffect(c)
    ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge3:SetCode(EVENT_ADJUST)
	ge3:SetCountLimit(1,EFFECT_COUNT_CODE_DUEL)
	ge3:SetCondition(s.drawcon2)
	ge3:SetTarget(s.drawtg2)
	ge3:SetOperation(s.drawpop2)
	Duel.RegisterEffect(ge3,1)
	local ge4=ge3:Clone()
    Duel.RegisterEffect(ge4,0)
	aux.GlobalCheck(s,function()
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_ADJUST)
		e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetOperation(s.actionop)
		Duel.RegisterEffect(e4,0)
	end )
	aux.EnableExtraRules(c,s,s.ActionStart)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local c=e:GetHandler()
	return c:GetFlagEffect(id)==0 and Duel.GetCurrentChain()==0 and Duel.GetTurnCount()~=1 and Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
    	and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.drawpop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--draw replace
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
function s.drawcon2(e,tp,eg,ep,ev,re,r,rp)
	--condition
		return rp~=tp and Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,5,nil)
end
function s.drawtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.drawpop2(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	--draw replace
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(p)
	Duel.BreakEffect()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,nil)
	if #g>1 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:Select(tp,5,5,nil)
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.actionfilter(c)
	return c:IsType(TYPE_ACTION) and not c.af and not c:IsOriginalCode(id)
end
function s.actionop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(Duel.GetMatchingGroup(s.actionfilter,tp,0xff,0xff,nil),nil,-2,REASON_RULE)
	e:Reset()
end
function s.ActionStart()
	Duel.LoadScript("c151000000.lua")
	ActionDuel.Start()
end