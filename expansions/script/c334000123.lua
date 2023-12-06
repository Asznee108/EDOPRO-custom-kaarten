--Heart of the Cards (Extra Rule)
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op(c)
	--place on deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,0)
    --replace hand
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2,0)
end
--place on deck
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,ac)
	if #g>0 then
        local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.MoveSequence(tc,SEQ_DECKTOP)
    elseif Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,1,1,nil)
	    if #sg>0 then
		    local tc2=sg:Select(tp,1,1,nil):GetFirst()
		    Duel.MoveSequence(tc2,SEQ_DECKTOP)
	    end
	end
end
--replace hand
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,ac)
	local sg1=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
	if #g>0 and #sg1>0 then
        local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tc1=sg1:Select(tp,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tp,tc1)
		if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(tc1,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			Duel.BreakEffect()
			Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
    elseif Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,1,1,nil)
	    if #sg>0 then
		    local tc=sg:Select(tp,1,1,nil):GetFirst()
		    Duel.SendtoHand(tc,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tc1=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.ConfirmCards(1-tp,tc1)
			if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(tc1,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				Duel.BreakEffect()
				Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
	    end
	end
end