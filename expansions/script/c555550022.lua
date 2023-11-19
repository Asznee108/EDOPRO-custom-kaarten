--Bone Freezing Chains
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id,555550000}
function s.spcheck(sg,tp,exg,e)
	return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,sg:GetSum(Card.GetLevel),sg)
end
function s.exfilter(c,e,tp,sg)
	return c:ListsCode(555550000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevel(sg:GetSum(Card.GetLevel)) 
end
function s.cgfilter(c)
	return c:IsMonster() and c:ListsCode(555550000)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.cgfilter,0,false,s.spcheck,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mg=Duel.SelectReleaseGroupCost(tp,s.cgfilter,1,99,false,s.spcheck,nil,e)
	e:SetLabel(mg:GetSum(Card.GetLevel))
	Duel.Release(mg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,nil,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.sefilter(c,e,tp,lv)
	return c:ListsCode(555550000) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_FUSION)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local g=Duel.GetMatchingGroup(s.sefilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,e:GetLabel())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,lv,1,ft)
	if sg and #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end