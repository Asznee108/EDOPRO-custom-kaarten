--Tyranno Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_names={38179121,18940556,80280944,83107873,83235263}
s.listed_series={0x10e}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Activate
	--create the cards
  local card1=Duel.CreateToken(tp,80280944) --Giant Rex
  local card2=Duel.CreateToken(tp,83107873) --TDH
  local card3=Duel.CreateToken(tp,38179121) --DEP
  local card4=Duel.CreateToken(tp,18940556) --UCT
  -- create a group containing the cards
  local g=Group.FromCards(card1,card2)
  local g2=Group.FromCards(card3)
  local g3=Group.FromCards(card4)
  -- send cards to GY
  Duel.SendtoGrave(g,REASON_EFFECT)
  --Add card to hand
  Duel.SendtoHand(g2,tp,REASON_EFFECT)
  --add card to bottom deck
  Duel.SendtoDeck(g3,tp,1,REASON_EFFECT)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingTarget(s.effectfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.effectfilter(c)
    return c:IsRace(RACE_DINOSAUR) and c:IsFaceup()
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
  --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
    local g=Duel.GetMatchingGroup(s.effectfilter,tp,LOCATION_MZONE,0,nil)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+2)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=3000
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemove()
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+2,0,0,0)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND,0,1,5,nil)
	Duel.Remove(cg,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	local ti=Duel.CreateToken(tp,83235263) --Tyranno Infinity
    local tc=ti 
    if tc then
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
        --Cannot be tributed
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(3303)
		e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UNRELEASABLE_SUM)
		e4:SetValue(1)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e5)
        local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_PIERCE)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		tc:RegisterEffect(e6)
        --immune
	    local e7=Effect.CreateEffect(c)
	    e7:SetType(EFFECT_TYPE_SINGLE)
	    e7:SetCode(EFFECT_IMMUNE_EFFECT)
	    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	    e7:SetRange(LOCATION_MZONE)
	    e7:SetValue(s.efilter)
	    tc:RegisterEffect(e7)
    end
    Duel.SpecialSummonComplete()
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer() ~= te:GetHandlerPlayer()
		and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack()
end