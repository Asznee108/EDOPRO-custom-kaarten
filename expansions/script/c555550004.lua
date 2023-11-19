--Phantom Sword, Mirage Edge
local s,id=GetID()
function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
	c:SetUniqueOnField(1,0,id)
    --Equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,555550000),nil,nil,nil,nil,nil,EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	--Pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_PIERCE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	c:RegisterEffect(e1)
    --Make itself be able to make a second attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
    c:RegisterEffect(e2)
end
s.listed_names={id,555550000}
--attack again 
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=c:GetEquipTarget()
	local bc=tc:GetBattleTarget()
	return tc==Duel.GetAttacker() and tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE) 
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.GetAttackTarget():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) end
	Duel.GetAttackTarget():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.GetAttackTarget(),1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SelectOption(1-tp,aux.Stringid(id,1))
	local c=e:GetHandler()
	local bc=Duel.GetAttackTarget()
	if not bc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(bc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) then
		--Special summoned monster loses effects
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        bc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        bc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			--Can make a second attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3201)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end