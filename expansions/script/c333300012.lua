--Red Fury
local s,id=GetID()
Duel.LoadScript ("c420.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --act in set turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
    --Add "Red" card from Deck or GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
    --Synchro Summon from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_ATTACK+TIMING_END_PHASE)
	e4:SetCondition(aux.exccon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x543}
s.listed_names={id}
function s.filter(c,e,tp)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	return Duel.IsExistingMatchingCard(s.matfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp,c)
end
function s.matfilter1(c,tp,syncard)
	local loc
	if c:IsLocation(LOCATION_HAND) then loc=LOCATION_GRAVE else loc=LOCATION_HAND end
	return Duel.IsExistingMatchingCard(s.matfilter2,tp,loc,0,1,c,syncard,c)
end
function s.matfilter2(c,syncard,mc)
	return syncard:IsSynchroSummonable(nil,Group.FromCards(c,mc)) and syncard:IsRed()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local g1=Duel.SelectMatchingCard(tp,s.matfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,tc)
		local loc
		if g1:GetFirst():IsLocation(LOCATION_HAND) then loc=LOCATION_GRAVE else loc=LOCATION_MZONE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,loc,0,1,1,nil,tc,g1:GetFirst())
		g2:Merge(g1)
		Duel.SynchroSummon(tp,tc,nil,g2)
	end
end
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function s.thcfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thfilter(c)
    return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and (c:IsRed() or c:ListsArchetype(0x57)) and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.filter2(c,e,tp,mg)
	if not c.synchro_type or not c:IsType(TYPE_SYNCHRO) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) then return false end
	local proceff={c:GetCardEffect(EFFECT_SPSUMMON_PROC)}
	for _,eff in ipairs(proceff) do
		if (eff:GetValue()&SUMMON_TYPE_SYNCHRO)~=0 then
			if eff:GetCondition()(eff,c,nil,mg) then return true end
		end
	end
	return false
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	if chkc then return #mg>0 and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,mg) end
	if chk==0 then return #mg>0 and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	if tc and tc:IsRelateToEffect(e) and #mg>0 and s.filter2(tc,e,tp,mg) then
		local proceff={tc:GetCardEffect(EFFECT_SPSUMMON_PROC)}
		local effs={}
		for _,eff in ipairs(proceff) do
			if (eff:GetValue()&SUMMON_TYPE_SYNCHRO)~=0 then
				if eff:GetCondition()(eff,tc,nil,mg) then table.insert(effs,eff) end
			end
		end
		local eff=effs[1]
		if #effs>1 then
			local desctable = {}
			for _,index in ipairs(effs) do
				table.insert(desctable,index:GetDescription())
			end
			eff=effs[Duel.SelectOption(tp,false,table.unpack(desctable)) + 1]
		end
		if eff:GetTarget()(eff,tp,nil,nil,nil,e,nil,nil,nil,tc,nil,mg) and Duel.SendtoGrave(eff:GetLabelObject(),REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)>0 and Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		eff:SetLabelObject(nil)
		Duel.SpecialSummonComplete()
	end
end