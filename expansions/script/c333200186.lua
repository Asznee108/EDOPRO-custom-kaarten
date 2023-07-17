--Odd-Eyes Pendulum Load Support
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
    aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
    aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
function s.thfilter(c)
	return (c:IsCode(511015104) or c:IsCode(511015105) or c:IsCode(511015106)) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>3
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
    --create the cards
    local fc=Duel.CreateToken(tp,41209827) --SVFD
    local sc=Duel.CreateToken(tp,82044279) --CWSD
    local xc=Duel.CreateToken(tp,16195942) --DRXD
    local pc=Duel.CreateToken(tp,16178681) --OEPD
    -- spsummon cards
    Duel.SpecialSummonStep(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_ATTACK)
	  Duel.SpecialSummonStep(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP_ATTACK)
    Duel.SpecialSummonStep(xc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP_ATTACK)
    Duel.SpecialSummonComplete()
    fc:CompleteProcedure()
    sc:CompleteProcedure()
    xc:CompleteProcedure()
    local sg=Group.FromCards(fc,sc,xc)
    Duel.SendtoGrave(sg,REASON_EFFECT)
    Duel.SendtoExtraP(pc,tp,REASON_EFFECT)
    Duel.BreakEffect()
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
			g1:Merge(g2)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g3=g:Select(tp,1,1,nil)
				g1:Merge(g3)
			end
		end
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
end
s.listed_names={41209827,82044279,16195942,16178681,511015104,511015105,511015106}
s.listed_series={0x57}
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
    --opd check
      if Duel.GetFlagEffect(ep,id+1)>0 then return end
      --condition
      return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
  end
function s.desfilter(c)
	return (c:IsCode(511015104) or c:IsCode(511015105))
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
      Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
      Duel.Hint(HINT_CARD,tp,id)
    --opd register
      Duel.RegisterFlagEffect(ep,id+1,0,0,0)
      --des
      local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
      if #g>=1 then
          Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
          Duel.Destroy(g,REASON_EFFECT)
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
      local astro=Duel.CreateToken(tp,511010507) --Astrograph
    local zarc=Duel.CreateToken(tp,511009441) --Z-ARC
    local g3=Group.FromCards(astro,zarc)
    Duel.SendtoHand(g3,tp,REASON_EFFECT)
    Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
  end