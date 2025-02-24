--Red King Highlander
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
    --Attribute
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e0)
    --to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Negate Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
    --Set 1 Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={0x52f}
--Send "King" cardd from Deck to grave
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsKing() and c:IsAbleToGrave() 
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
end
--Negate Summon
function s.disfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and eg:IsExists(s.disfilter,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.synfilter(c,e,tp,sync)
	return Duel.CheckLocation(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sync
end
function s.fusfilter(c,e,tp,fusc,mg)
	return Duel.CheckLocation(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
		and (c:GetReason()&0x40008)==0x40008 and c:GetReasonCard()==fusc
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE|FUSPROC_NOTFUSION)
end
function s.xyzfilter(c,e,tp,xyz)
	return Duel.CheckLocation(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
		and (c:GetReason()&0x200000)==0x200000 and c:GetReasonCard()==xyz
end
function s.linkfilter(c,e,tp,link)
	return Duel.CheckLocation(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
		and (c:GetReason()&0x10000000)==0x10000000 and c:GetReasonCard()==link
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	for tc in aux.Next(g) do
		local mg=tc:GetMaterial()
		local ov=tc:GetOverlayGroup()
		local ct=#mg
		local sumtype=tc:GetSummonType()
		local p=tc:GetControler()
		Duel.NegateSummon(tc)
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_EXTRA)
		and ct>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
			if (sumtype==SUMMON_TYPE_SYNCHRO and 
				mg:FilterCount(aux.NecroValleyFilter(s.synfilter),nil,e,tp,tc)==ct)
				or (sumtype==SUMMON_TYPE_FUSION and 
				mg:FilterCount(aux.NecroValleyFilter(s.fusfilter),nil,e,tp,tc)==ct)
				or (sumtype==SUMMON_TYPE_XYZ and 
				ov:FilterCount(aux.NecroValleyFilter(s.xyzfilter),nil,e,tp,tc)==ct)
				or (sumtype==SUMMON_TYPE_LINK and 
				mg:FilterCount(aux.NecroValleyFilter(s.linkfilter),nil,e,tp,tc)==ct) then
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
				e1:SetValue(0xffffff)
				Duel.RegisterEffect(e1,tp)
				local tc2=mg:GetFirst()
				while tc2 do
					if tc2:IsPreviousLocation(LOCATION_ONFIELD) then
						Duel.MoveToField(tc2,tp,tc2:GetPreviousControler(),tc2:GetPreviousLocation(),tc2:GetPreviousPosition(),true,(1<<tc2:GetPreviousSequence()))
					elseif tc2:IsPreviousLocation(LOCATION_HAND) then
						Duel.SendtoHand(tc2,tc2:GetPreviousControler(),REASON_EFFECT)
					elseif tc2:IsPreviousLocation(LOCATION_REMOVED) then
						Duel.Remove(tc2,tc2:GetPreviousPosition(),REASON_EFFECT)
					elseif tc2:IsPreviousLocation(LOCATION_DECK) or tc2:IsPreviousLocation(LOCATION_EXTRA) then
						Duel.SendtoDeck(tc2,tc2:GetPreviousControler(),SEQ_DECKSHUFFLE,REASON_EFFECT)
					end
					tc2=mg:GetNext()
				end
			end
		end
	end
end
--Set Trap from Deck
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp~=tp
end
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		local e0=Effect.CreateEffect(tc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e0)
	end
end