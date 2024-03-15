--Rosanna, the Seraphim Angel of Roses
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x123),1,99,s.matfilter,nil,nil,s.matfilter2)
	--Must first be Synchro Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--cannot be destroyed
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --ATK gain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    --destroy replace
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.destg)
	e3:SetValue(s.value)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(id)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.con)
	e4:SetTarget(s.tg)
	e4:SetOperation(s.op)
	c:RegisterEffect(e4)
end
s.listed_series={0x123}
s.listed_names={CARD_BLACK_ROSE_DRAGON,id}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x123,scard,sumtype,tp)
end
function s.cfilter(c,sc,tp)
	return c:IsLevelAbove(7)
end
function s.matfilter2(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil,sc,tp)
end
--atk gain
function s.atkfilter(c)
	return (c:IsCode(CARD_BLACK_ROSE_DRAGON) or c:ListsCode(CARD_BLACK_ROSE_DRAGON)) and c:GetAttack()>0 and not c:IsCode(id)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsLocation(LOCATION_MZONE) or chkc:IsLocation(LOCATION_GRAVE)) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
--prevent destruction and destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsControler,nil,tp)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0 and #g>0
	end
	e:SetLabel(#g)
	return Duel.SelectEffectYesNo(tp,e:GetHandler())
end
function s.value(e,c)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(e:GetHandlerPlayer())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.RaiseEvent(e:GetHandler(),id,e,0,0,tp,0)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetLabelObject():GetLabel()>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject():GetLabel(),nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	e:GetLabelObject():SetLabel(0)
end