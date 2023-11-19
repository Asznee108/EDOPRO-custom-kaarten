--Nightmare, Familiar of V
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	--Send itself to the GY if "V, the Mysterious One" is not face-up on your field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetCondition(s.tgcon)
	c:RegisterEffect(e1)
    --Gains 300 ATK for each monster you control that mentions "Vergil, the Alpha and the Omega"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Destroy 1 monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    --special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcon)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={id,555550000,555550007}
--send itself to GY 
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(555550007)
end
function s.tgcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
--gain atk
function s.atkfilter(c)
	return c:IsFaceup() and c:ListsCode(555550000)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
--destroy cards 
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desfilter(c,s,p)
	local seq=c:GetSequence()
	return seq<5 and c:IsControler(p) and math.abs(seq-s)==1
end
function s.desfilter2(c,g)
	return g:IsContains(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.BreakEffect()
		if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then
			local seq=tc:GetSequence()
			local dg=Group.CreateGroup()
			if seq<5 then dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,tc:GetControler()) end
			if Duel.Destroy(tc,REASON_EFFECT)~=0 and #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		else
			local cg=tc:GetColumnGroup()
			local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_ONFIELD,nil,cg)
			if tc:IsControler(1-tp) then
				g=g:AddCard(tc)
			end
			if #g>0 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
--Special Summon this card 
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
    and not Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end