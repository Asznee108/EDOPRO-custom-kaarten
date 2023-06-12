--Rose Dragon Synchro Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_names={67441435,12469386,93708824,50164989,80196387,17720747,69167267,44125452,76524506,53325667}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Activate
	--create the cards
  local card1=Duel.CreateToken(tp,67441435) --glow-up bulb
  local card2=Duel.CreateToken(tp,12469386) --rev rose
  local card3=Duel.CreateToken(tp,93708824) --roxrose dragon
  local card4=Duel.CreateToken(tp,50164989) --dark verger
  local card5=Duel.CreateToken(tp,80196387) --RBoR
  -- create a group containing the cards
  local g=Group.FromCards(card1,card2,card3,card4,card5)
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
	--create the cards
    local card6=Duel.CreateToken(tp,17720747) --Witch of the Black Rose
    local card7=Duel.CreateToken(tp,69167267) --Basal Rose Shoot
    local card8=Duel.CreateToken(tp,44125452) --Rose Fairy
    local g2=Group.FromCards(card6,card7)
    Duel.SendtoHand(g2,tp,2,REASON_EFFECT)
    Duel.SendtoDeck(card8,tp,SEQ_DECKTOP,REASON_EFFECT)
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
	local card9=Duel.CreateToken(tp,76524506) --Garden Rose Flora
    local card10=Duel.CreateToken(tp,53325667) --Garden Rose Maiden
    local g3=Group.FromCards(card9,card10)
    local tc=g3:GetFirst()
	while tc do
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
		tc=g3:GetNext()
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end