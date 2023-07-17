--Resonator Synchro Load Support
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddPreDrawSkillProcedure(c,1,false,s.flipcon,s.flipop)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
  aux.AddSkillProcedure(c,1,false,s.flipcon3,s.flipop3)
end
s.listed_names={60832978,40159926,77360173,34761841,40583194,40975574,77087109,05780210,97021916,13708425,89127526,13764881,511009513,14886469,41197012,66141736}
s.listed_series={0x57}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Activate
	--create the cards
  local card1=Duel.CreateToken(tp,60832978) --Double
  local card2=Duel.CreateToken(tp,40159926) --Mirror
  local card3=Duel.CreateToken(tp,77360173) --Synkron
  local card4=Duel.CreateToken(tp,34761841) --Crimson
  local card5=Duel.CreateToken(tp,40583194) --Force
  local card6=Duel.CreateToken(tp,40975574) --Red
  local card7=Duel.CreateToken(tp,77087109) --Force
  local card8=Duel.CreateToken(tp,05780210) --Creation
  local card9=Duel.CreateToken(tp,97021916) --Dark
  local card10=Duel.CreateToken(tp,13708425) --Flare
  local card11=Duel.CreateToken(tp,89127526) --Barrier
  local card12=Duel.CreateToken(tp,13764881) --Chain
  local card13=Duel.CreateToken(tp,511009513) --Net
  -- create a group containing the cards
  local g=Group.FromCards(card1,card2,card3,card4,card5,card6,card7,card8,card9,card10,card11,card12,card13)
  -- send cards to GY
  Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
  --opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,e:GetHandler())
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
  --opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
  local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,2,2,nil)
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		--create the cards
    local rs=Duel.CreateToken(tp,14886469) --Red Sprinter
    local rc=Duel.CreateToken(tp,41197012) --Red Carpet
    local g2=Group.FromCards(rs,rc)
    Duel.SendtoHand(g2,tp,2,REASON_EFFECT)
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
	local cr=Duel.CreateToken(tp,34761841) --Crimson Resonator
  local srda=Duel.CreateToken(tp,66141736) --RRD
  local g3=Group.FromCards(cr,srda)
  Duel.SpecialSummon(g3,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end