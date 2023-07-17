--Stand User - Toru, Wonder of U
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0xfac)))
	c:RegisterEffect(e1)
    --Special summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_HANDES+CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
    aux.GlobalCheck(s,function()
		--Special summon procedure
		local e0=Effect.CreateEffect(c)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_PHASE+PHASE_END)
		e0:SetCountLimit(1)
		e0:SetOperation(s.endop)
		Duel.RegisterEffect(e0,0)
	end)
end
s.listed_series={0xfac}
s.listed_names={333200246}
function s.spfilter1(c)
	return c:IsFaceup() and c:IsCode(333200246)
end
function s.endop(e,tp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter1,Duel.GetTurnPlayer(),LOCATION_MZONE,0,nil)
	local rc=g:GetFirst()
	while rc do
		if rc:GetFlagEffect(id)==0 then
			local e1=Effect.CreateEffect(rc)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCondition(s.ctcon)
			e1:SetLabel(0)
			e1:SetOperation(s.ctop)
			rc:RegisterEffect(e1)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=g:GetNext()
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.ctop(e,tp,c)
	local c=e:GetHandler()
	if not c:IsControler(Duel.GetTurnPlayer()) then return end
	local ct=e:GetLabel()
	if c:GetFlagEffect(id)~=0 and ct==3 then 
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	else
		e:SetLabel(ct+1)
	end
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsCode(333200246) and c:GetFlagEffect(id+1)~=0
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.filter,1,false,1,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.filter,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.ngcfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
function s.posfilter(c)
	return c:IsCanChangePosition()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.ngcfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local dice=Duel.TossDice(tp,1)
	if dice==1 then
		Duel.NegateEffect(ev)
	elseif dice==2 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	    if #g>0 then
		    Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	    end
	elseif dice==3 then
		local sg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	    Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	elseif dice==4 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	    local tc=g:GetFirst()
	    for tc in aux.Next(g) do
		    local e1=Effect.CreateEffect(e:GetHandler())
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		    e1:SetValue(tc:GetAttack()/2)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		    tc:RegisterEffect(e1)
	    end
	elseif dice==5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	else
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end