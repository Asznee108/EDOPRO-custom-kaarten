--Aroma LP Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_series={0xc9}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--immune
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(s.indfilter))
	e1:SetValue(s.indct)
	Duel.RegisterEffect(e1,tp)
end
function s.indfilter(c,tp)
	return c:IsSpellTrap() and (c:IsSetCard(0xc9) or aux.HasListedSetCode(c,0xc9))
end
function s.indct(e,re,r,rp)
	if (r&REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.thfilter(c,tp)
	return (c:IsType(TYPE_CONTINUOUS)) and c:IsSpellTrap() and (c:IsSetCard(0xc9) or aux.HasListedSetCode(c,0xc9)) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) 
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
    --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    local tc=g1:GetFirst()
    if tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+2)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=3000
end
function s.matfilter(c)
    return c:IsCanBeXyzMaterial(sc) and c:IsType(TYPE_MONSTER)
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+2,0,0,0)
	local turn=Duel.GetTurnCount()
    local life=Duel.GetLP(tp)
    local val=turn*life
    Duel.Recover(tp,val,REASON_EFFECT)
end