--Nightmare Archfiend
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x45}
function s.spcon(e,c)
	if c==nil then return true end
    local tp=c:GetControler()
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,42956963+1,0x45,TYPES_TOKEN,2000,2000,6,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
        and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	for i=1,2 do
		local token=Duel.CreateToken(tp,42956963+1)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
        local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(s.damop)
			token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		Duel.Damage(c:GetPreviousControler(),800,REASON_EFFECT)
	end
	e:Reset()
end
function s.sumfilter(c)
	return (c:IsLevelBelow(3) and c:IsType(TYPE_TUNER)) or (c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDefense(0) and (c:IsLevel(3) or c:IsLevel(4)))
end
function s.thfilter(c)
	return (c:IsRace(RACE_ROCK) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_DRAGON) and (c:IsLevel(4) or c:IsLevel(5) or c:IsLevel(6))) and not c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and c:IsAbleToHand()
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_MZONE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(s.sumfilter))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		    c:CompleteProcedure()
		    Duel.BreakEffect()
	    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	    	local sg=g:Select(tp,1,1,nil)
	    	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	    	Duel.ConfirmCards(1-tp,sg)
	    end
    end
end