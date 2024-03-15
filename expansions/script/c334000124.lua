--Crimson Rose Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Can be treated as a non-Tuner for a Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
    --Reduce this card's Level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    --Search
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --Synchro Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.sccost)
	e5:SetTarget(s.sctg)
	e5:SetOperation(s.scop)
	c:RegisterEffect(e5)
end
s.listed_names={id,CARD_BLACK_ROSE_DRAGON}
s.listed_series={0x123,0x1123}
--Special Summon this card 
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x123)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)==0 or 
        (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil))
end
--Reduce this card's Level 
function s.lvfilter(c,e,tp,lvl)
	return c:GetLevel()<lvl and c:IsLevelBelow(4) and c:IsRace(RACE_PLANT+RACE_DRAGON)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lvl=c:GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,e,tp,lvl) end
	if chk==0 then return c:HasLevel() and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,lvl) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,lvl)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:HasLevel() then
		--Reduce this card's Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-tc:GetLevel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
--Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSetCard(0x123) and r & REASON_SYNCHRO+REASON_LINK ~=0
end
function s.thfilter(c)
	return c:ListsCode(CARD_BLACK_ROSE_DRAGON) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thfilter2(c,e,tp)
	return c:IsSetCard(0x1123) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLevelBelow(4)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,g:GetFirst(),e,tp)
	if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND)
		and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g2:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
	end
end
--Synchro Summon 
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.cfilter(c,e,tp,lv)
	return c:GetLevel()>0
end
function s.rescon(sg,e,tp)
	return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg,sg:GetSum(Card.GetLevel))
end
function s.scfilter(c,e,tp,sg,lv)
	return c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x123)
     and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 
     and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,0)
	end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,1,tp,HINTMSG_REMOVE,function(sg) return sg:IsContains(c) end)
	local lv=g:GetSum(Card.GetLevel)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	Duel.SetTargetParam(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sg,lv)
	local tc=g:GetFirst()
	if tc then
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end