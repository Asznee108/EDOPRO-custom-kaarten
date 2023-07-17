--Blue-Eyes Fusion
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(aux.IsMaterialListSetCard,0xdd),Fusion.InHandMat,s.fextra,nil,nil,s.stage2)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_series={0xdd}
function s.fcheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard,0xdd,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK+LOCATION_MZONE,0,nil),s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
	local c=e:GetHandler()
	if chk==0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
	if chk==1 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	   if chk==2 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(c)
        	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
         	e1:SetCondition(s.condition)
         	e1:SetOperation(s.operation)
         	tc.RegisterEffect(e1,true)
         	local e2=Effect.CreateEffect(c)
         	e2:SetType(EFFECT_TYPE_SINGLE)
        	e2:SetCode(EFFECT_MATERIAL_CHECK)
        	e2:SetValue(s.valcheck)
        	e2:SetLabelObject(e1)
			tc.RegisterEffect(e2,true)
	    	end
    	end
    end
end
function s.splimit(e,c)
	return not (c:IsSetCard(0xdd))
end
function s.valcheck(e,c)
    e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsSetCard,nil,0xdd))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>=2 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc.RegisterEffect(e1,true)
	end
end