--Galaxy-Eyes Photon Xyz Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_names={5133471,101111001,62968263,9260791,511000296,101111043}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Activate
	--create the cards
  local card1=Duel.CreateToken(tp,5133471) --Galaxy Cylcone
  local card2=Duel.CreateToken(tp,73478096) --Photon Emperor
  local card3=Duel.CreateToken(tp,62968263) --GEAD
  local card4=Duel.CreateToken(tp,9260791) --GECD
  local card5=Duel.CreateToken(tp,93717133) --GEPD
  local card6=Duel.CreateToken(tp,511000296) --N iC1000
  -- create a group containing the cards
  local g=Group.FromCards(card1,card2,card3,card4,card5)
  local g2=Group.FromCards(card6)
  -- send cards to GY
  Duel.SendtoGrave(g,REASON_EFFECT)
  -- send cards to opponent's ED
  Duel.SendtoDeck(g2,1-tp,0,REASON_EFFECT)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
    --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g1=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g1:GetFirst()
    local g=Duel.CreateToken(tp,93717133) --GEPD
    if tc and tc:IsFaceup() then
        Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.Overlay(tc,g)
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
	local c=e:GetHandler()
	local nc62=Duel.CreateToken(tp,101111043) --NC62: GEPPD
    local g3=Group.FromCards(nc62)
    local tc=g3:GetFirst()
    if tc then
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP_ATTACK)
        tc:CompleteProcedure()
        g4=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_GRAVE,0,1,999,nil)
        Duel.Overlay(tc,g4)
    end
end