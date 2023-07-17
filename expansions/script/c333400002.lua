--Stardust Junk Synchron Warrior Synchro Load Support
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
  local card1=Duel.CreateToken(tp,11069680) --J Converter
  local card2=Duel.CreateToken(tp,63977008) --J Synchron
  local card3=Duel.CreateToken(tp,23571046) --Quillbolt Hedgehog
  local card4=Duel.CreateToken(tp,53855409) --Doppelwarrior
  local card5=Duel.CreateToken(tp,57421866) --Level Eater
  local card6=Duel.CreateToken(tp,92676637) --Tuningware
  local card7=Duel.CreateToken(tp,58518520) --Clear Effector
  local card8=Duel.CreateToken(tp,68543408) --SD Xiaolong
  local card9=Duel.CreateToken(tp,37799519) --SD Synchron
  local card10=Duel.CreateToken(tp,63184227) --SD Trail
  local card11=Duel.CreateToken(tp,91262474) --SD Wurm
  -- create a group containing the cards
  local g=Group.FromCards(card1,card2,card3,card4,card5,card6,card7,card8,card9,card10,card11)
  -- send cards to GY
  Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(5) and not c:IsType(TYPE_TUNER)
end
function s.gyfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(5)
end
function s.lvfilter(c)
	local lv=c:GetLevel()
	return c:IsFaceup() and lv>0 and lv~=1 and not c:IsType(TYPE_TUNER)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
  --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	--create the cards
    local ac=Duel.CreateToken(tp,37675907) --Accel Synchron
    if Duel.SpecialSummon(ac,0,tp,tp,true,true,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        tc=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
        Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP_DEFENSE)
	end
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+2)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=3000
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id+2,0,0,0)
	local c=e:GetHandler()
	local sqd=Duel.CreateToken(tp,35952884) --Shooting Quasar Dragon
    local lsd=Duel.CreateToken(tp,25165047) --Life Stream Dragon
    local afd=Duel.CreateToken(tp,25862681) --Ancient Fairy Dragon
    local brd=Duel.CreateToken(tp,73580471) --Black Rose Dragon
    local bwd=Duel.CreateToken(tp,9012916) --Black-Winged Dragon
    local rda=Duel.CreateToken(tp,70902743) --Red Dragon Archfiend
    local g3=Group.FromCards(lsd,afd,brd,bwd,rda)
    Duel.SendtoDeck(sqd,tp,0,REASON_RULE)
    local sg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
	Duel.SendtoGrave(sg,REASON_RULE)
    local tc=g3:GetFirst()
	for tc in aux.Next(g3) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
        local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCountLimit(1)
		e4:SetLabel(fid)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.rmcon)
		e4:SetOperation(s.rmop)
		Duel.RegisterEffect(e4,tp)
	end
	Duel.SpecialSummonComplete()
    local lvg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=lvg:GetFirst()
	for tc in aux.Next(lvg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
    local card12=Duel.CreateToken(tp,20007374) --Converging Wishes
    Duel.SSet(tp,card12)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end