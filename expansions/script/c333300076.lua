--Red Oversynchro
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Synchro summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target(TYPE_SYNCHRO,Card.IsSynchroSummonable))
	e1:SetOperation(s.operation(TYPE_SYNCHRO,Card.IsSynchroSummonable,function(sc,g,tp) Synchro.Send=5 Duel.SynchroSummon(tp,sc,nil,g,#g,#g) end))
	c:RegisterEffect(e1)
    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x57,0x543,0x52f}
s.listed_names={id}
--Synchro Summon
function s.relfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.matfilter(c,e,tp)
	return (c:IsSetCard(0x57) or c:IsRed() or c:IsKing()) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(montype,chkfun)
	return function(c,mg,tp,chk)
		return c:IsType(montype) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0) and (not mg or chkfun(c,nil,mg,#mg,#mg))
	end
end
function s.rescon(exg,chkfun)
	return function(sg,e,tp,mg)
		local _1,_2=aux.dncheck(sg,e,tp,mg)
		return _1 and exg:IsExists(chkfun,1,nil,nil,sg,#sg,#sg),_2
	end
end
function s.target(montype,chkfun)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local exg=Duel.GetMatchingGroup(s.filter(montype,chkfun),tp,LOCATION_EXTRA,0,nil,nil,tp)
		local cancelcon=s.rescon(exg,chkfun)
		if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and (c:IsSetCard(0x57) or c:IsRed() or c:IsKing()) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) and cancelcon(Group.FromCards(chkc)) end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		local min=math.min(math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 99),1)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>4 then ft=4 end
		if chk==0 then return min>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,0) end
		local sg=aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,chk,tp,HINTMSG_SPSUMMON,cancelcon)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
	end
end
function s.operation(montype,chkfun,fun)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetTargetCards(e):Filter(s.relfilter,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		local syng=Duel.GetMatchingGroup(s.filter(montype,chkfun),tp,LOCATION_EXTRA,0,nil,g,tp,true)
		if #syng>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local c=syng:Select(tp,1,1,nil):GetFirst()
			if Duel.SynchroSummon(tp,c,g)>0 then
                local atk=c:GetAttack()
                local lvl=c:GetLevel()
		        if Duel.Destroy(c,REASON_EFFECT)~=0 then
			        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk,lvl)
			        Duel.Destroy(g,REASON_EFFECT)
		        end
            end
		end
	end
end
--Special Summon Tuner from hand or GY
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and aux.exccon
end
function s.scfilter(c,e)
	local tpe=c.synchro_type
	if not tpe then return false end
	local t=c.synchro_parameters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(Synchro.Condition(table.unpack(t)))
	e1:SetTarget(Synchro.Target(table.unpack(t)))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	local res=c:IsSynchroSummonable(nil)
	e1:Reset()
	return res
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local syng=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,g)
		if #g>0 and #syng>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=syng:Select(tp,1,1,nil):GetFirst()
            if tc:IsLocation(LOCATION_EXTRA) then
                Duel.SynchroSummon(tp,tc,nil)
            else
                local tpe=tc.synchro_type
                local t=tc.synchro_parameters
		        local e1=Effect.CreateEffect(e:GetHandler())
		        e1:SetType(EFFECT_TYPE_FIELD)
		        e1:SetCode(EFFECT_SPSUMMON_PROC)
		        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		        e1:SetRange(LOCATION_GRAVE)
		        e1:SetCondition(Synchro.Condition(table.unpack(t)))
		        e1:SetTarget(Synchro.Target(table.unpack(t)))
		        e1:SetOperation(Synchro.Operation)
		        e1:SetValue(SUMMON_TYPE_SYNCHRO)
		        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		        tc:RegisterEffect(e1)
			    Duel.SynchroSummon(tp,tc,nil)
            end
		end
	end
end