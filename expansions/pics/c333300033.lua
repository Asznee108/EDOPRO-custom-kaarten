--Resonator Rush
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x57}
s.listed_names={id}
function s.costfilter(c,lvl)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(8) and not c:IsPublic()
end
function s.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x57) and c:IsType(TYPE_TUNER) and s.spfilter1(c,e,tp)
end
function s.spfilter3(c,e,tp)
	return s.spfilter1(c,e,tp) and c:HasLevel() and not c:IsType(TYPE_TUNER)
end
function s.synchck(c,lvl)
	return c:IsLevel(lvl) and c:IsType(TYPE_SYNCHRO) and not c:IsPublic()
end
function s.rescon1(sg,e,tp,mg)
	local lvl=sg:GetSum(Card.GetLevel)
	return sg:IsExists(s.spfilter2,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.synchck,tp,LOCATION_EXTRA,0,1,nil,lvl)
end
function s.rescon2(sg,e,tp,mg)
	local lvl=e:GetLabel()
	return sg:IsExists(s.spfilter2,1,nil,e,tp)
		and sg:GetSum(Card.GetLevel)==lvl
end
function s.synchfilter(c,mg)
	return c:IsSynchroSummonable(mg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return ft>0
		and aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,3),s.rescon1,0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--let's stop earlier if there are no zones free
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft==0 then return end
	--Actually special summon
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,3),s.rescon2,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local mg=Duel.GetOperatedGroup()
		local syng=Duel.GetMatchingGroup(s.synchfilter,tp,LOCATION_EXTRA,0,nil,mg)
		if #syng==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=syng:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,sc,mg)
		local te=sc:GetActivateEffect()
		local tep=sc:GetControler()
		if te and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local condition=te:GetCondition()
			local cost=te:GetCost()
			local target=te:GetTarget()
			local operation=te:GetOperation()
			if te:GetCode()==EVENT_FREE_CHAIN
				and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
				and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
				and (not target or target(te,tep,eg,ep,ev,re,r,rp,0)) then
				Duel.ClearTargetCard()
				e:SetProperty(te:GetProperty())
				Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
				if tc:GetType()==TYPE_MONSTER then
					tc:CancelToGrave(false)
				end
				tc:CreateEffectRelation(te)
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
				if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				local tg=g:GetFirst()
				while tg do
					tg:CreateEffectRelation(te)
					tg=g:GetNext()
				end
				if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				tg=g:GetFirst()
				while tg do
					tg:ReleaseEffectRelation(te)
					tg=g:GetNext()
				end
			end
		end
	end
end