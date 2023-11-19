--Sword of Sparda, Yamato
local s,id=GetID()
function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
	c:SetUniqueOnField(1,0,id)
    --Equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,555550000),nil,nil,nil,nil,nil,EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	--indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.infilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --atkdown
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    --send to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={id,555550000}
--monsters with more than 0 atk become indestructable
function s.infilter(e,c)
	return c:IsAttackAbove(1)
end
--make monsters lose atk
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and at:IsRelateToBattle() and at:IsFaceup() and Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=Duel.GetAttackTarget()
	if not c:IsRelateToEffect(e) or not at:IsRelateToBattle() or at:IsFacedown() then return end
	local atk=c:GetEquipTarget():GetAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	at:RegisterEffect(e1)
end
--destroy monsters
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget() and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetEquipTarget():GetAttack()) end
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetEquipTarget():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SelectOption(1-tp,aux.Stringid(id,1))
	local atk=e:GetHandler():GetEquipTarget():GetAttack()
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,atk)
	if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end