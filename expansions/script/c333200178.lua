--Cyber Fusion Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
	aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_names={CARD_CYBER_DRAGON,59281922,5373478,29975188,23893227,1142880,56364287,26439287}
s.listed_series={0x93}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
    --create the cards
    local card1=Duel.CreateToken(tp,CARD_CYBER_DRAGON)
    local card2=Duel.CreateToken(tp,CARD_CYBER_DRAGON)
    local card3=Duel.CreateToken(tp,CARD_CYBER_DRAGON) 
    local card4=Duel.CreateToken(tp,59281922) --Drei
    local card5=Duel.CreateToken(tp,5373478) --Zwei
    local card6=Duel.CreateToken(tp,29975188) --Vier
    local card7=Duel.CreateToken(tp,23893227) --Core
    local card8=Duel.CreateToken(tp,1142880) --Nachster
    local card9=Duel.CreateToken(tp,56364287) --Herz
    -- create a group containing the cards
    local g=Group.FromCards(card1,card2,card3,card4,card5,card6,card7,card8,card9)
    -- send cards to GY
    Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
  --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft>1 and Duel.IsPlayerCanSpecialSummonMonster(tp,26439287,0,TYPES_EFFECT,1100,600,3,RACE_MACHINE,ATTRIBUTE_LIGHT) then
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		for i=1,ft do
			local token=Duel.CreateToken(tp,26439287)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	    Duel.SpecialSummonComplete()
    end
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	  if Duel.GetFlagEffect(ep,id+2)>0 then return end
	  --condition
	  return aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=3000
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+2,0,0,0)
	local c=e:GetHandler()
	local pb=Duel.CreateToken(tp,37630732) --Powerbond
	Duel.SendtoHand(pb,tp,2,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0
	else return val end
end