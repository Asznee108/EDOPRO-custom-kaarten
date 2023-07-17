--D/D/D Summon Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Activate
	--create the cards
  local card0=Duel.CreateToken(tp,19808608) --Berfomet
  local card1=Duel.CreateToken(tp,19808608) --Berfomet 2
  local card2=Duel.CreateToken(tp,59123937) --Vice Typhon
  local card3=Duel.CreateToken(tp,19580308) --Lamia
  local card4=Duel.CreateToken(tp,72291412) --Necro Slime
  local card5=Duel.CreateToken(tp,45206713) --Swirl Slime
  local card6=Duel.CreateToken(tp,28406301) --Gryphon
  local card7=Duel.CreateToken(tp,40227329) --Go!
  local card8=Duel.CreateToken(tp,74069667) --OKAR
  local card9=Duel.CreateToken(tp,41546) --Savant Thomas
  local card10=Duel.CreateToken(tp,41546) --Savant Thomas 2
  local card11=Duel.CreateToken(tp,46035545) --Savant Nikola
  local card12=Duel.CreateToken(tp,46035545) --Savant Nikola 2
  -- create a group containing the cards
  local g=Group.FromCards(card0,card1,card1,card2,card3,card4,card5,card6)
  local g2=Group.FromCards(card9,card10,card11,card12)
  -- send cards to GY
  Duel.SendtoGrave(g,REASON_EFFECT)
  -- send to face-up extra deck
  Duel.SendtoExtraP(g2,tp,REASON_EFFECT)
  -- place in pendulum zone
  if Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
    Duel.MoveToField(card7,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    Duel.MoveToField(card8,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
  end
end
function s.pendfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_PZONE,0,1,nil) 
end
function s.thfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
    --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g1=Duel.SelectMatchingCard(tp,s.pendfilter,tp,LOCATION_PZONE,0,1,1,nil)
    local tc=g1:GetFirst()
    if tc and tc:IsFaceup() then
        opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if opt==0 then
            local e1=Effect.CreateEffect(e:GetHandler())
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_CHANGE_LSCALE)
		    e1:SetValue(0)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		    tc:RegisterEffect(e1)
		    local e2=e1:Clone()
		    e2:SetCode(EFFECT_CHANGE_RSCALE)
		    tc:RegisterEffect(e2)
        else
            local e1=Effect.CreateEffect(e:GetHandler())
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_CHANGE_LSCALE)
		    e1:SetValue(11)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		    tc:RegisterEffect(e1)
		    local e2=e1:Clone()
		    e2:SetCode(EFFECT_CHANGE_RSCALE)
		    tc:RegisterEffect(e2)
        end
	end
    local dt=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)
	if dt==0 then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,dt,nil)
		if #g2<0 then return end
		Duel.BreakEffect()
		Duel.SendtoHand(g2,tp,REASON_EFFECT)
    end
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+2)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=3000
end
function s.thfilter2(c)
	return (c:IsCode(511015101) or c:IsCode(511015103) or c:IsCode(511015107)) and c:IsAbleToHand()
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,6)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+2,0,0,0)
	local c=e:GetHandler()
	local ddd=Duel.CreateToken(tp,47198668) --dka
    local ddd2=Duel.CreateToken(tp,47198668) --dka
    local ddd3=Duel.CreateToken(tp,47198668) --dka
    local g0=Group.FromCards(ddd,ddd2,ddd3)
    if Duel.SpecialSummon(g0,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0 then
        Duel.BreakEffect()
        local g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
	        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	        local g1=g:Select(tp,1,1,nil)
	        g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
	        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		        local g2=g:Select(tp,1,1,nil)
		        g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
		        g1:Merge(g2)
		        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			        local g3=g:Select(tp,1,1,nil)
			        g1:Merge(g3)
		        end
	        end
            Duel.SendtoHand(g1,nil,REASON_EFFECT)
	        Duel.ConfirmCards(1-tp,g1)
        end
    end
end