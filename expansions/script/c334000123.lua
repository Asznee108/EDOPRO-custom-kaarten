--Heart of the Cards (Extra Rule)
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.op)
end
function s.op(c)
	--place on deck
	local e1=Effect.GlobalEffect()
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetOperation(s.operation)
	Duel.RegisterEffect(e1,0)
end

--place on deck
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the effect or not
	local b=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	local op=Duel.SelectEffect(tp,
		{b,aux.Stringid(id,0)},
		{b,aux.Stringid(id,1)},
		{b,aux.Stringid(id,5)})
	
	if op==1 then
		--place on deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,ac)
		if #g>0 then
			local tc=g:Select(tp,1,1,nil):GetFirst()
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		elseif Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				local tc2=sg:Select(tp,1,1,nil):GetFirst()
				Duel.MoveSequence(tc2,SEQ_DECKTOP)
			end
		end
	elseif op==2 then
		--switch cards
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		Duel.DisableShuffleCheck()
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
			if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(tc1,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				Duel.BreakEffect()
				Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		elseif Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
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
end