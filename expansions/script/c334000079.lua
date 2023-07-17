--Angels of the Rose
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon 1 "Rose" monster
	local fparams={aux.FilterBoolFunction(Card.IsSetCard,0x123),nil,s.fextra}
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(fparams)),Fusion.SummonEffOP(table.unpack(fparams))))
	c:RegisterEffect(e1)
    --Give monster battle effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMING_ATTACK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.dbtg)
	e2:SetOperation(s.dbop)
	c:RegisterEffect(e2)
end
s.listed_series={0x123}
s.listed_names={id,CARD_BLACK_ROSE_DRAGON}
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter,tp,LOCATION_GRAVE,0,nil)
end
--Special Summon
function s.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsLevelAbove(7) and c:IsFaceup() 
     and c:IsSetCard(0x123) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,lv,e,tp)
end
function s.filter2(c,lv,e,tp)
	return (c:GetLevel()==lv or (c:GetLevel()<lv-1 and c:IsType(TYPE_TUNER))) and c:IsSetCard(0x123) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.exfilter(c,hg)
	return c:IsSetCard(0x123)
end
function s.operation(fustg,fusop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	    local c=e:GetHandler()
	    local tc=Duel.GetFirstTarget()
	    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetLevel(),e,tp)
	    local sc=g:GetFirst()
	    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		    local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,Card.IsSynchroSummonable,nil,nil,hg)
		    local fus=fustg(e,tp,eg,ep,ev,re,r,rp,0)
		    local opt1,opt2=#sg>0,fus
		    if (opt1 or opt2) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			    Duel.BreakEffect()
			    local opt
			    if opt1 and opt2 then
				    opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			    elseif opt1 and not opt2 then
				    opt=Duel.SelectOption(tp,aux.Stringid(id,2))
			    elseif opt2 and not opt1 then
				    opt=Duel.SelectOption(tp,aux.Stringid(id,3))+1
			    end
			    if opt==0 then
				    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				    local sc=sg:Select(tp,1,1,nil):GetFirst()
				    Duel.SynchroSummon(tp,sc,nil,hg)
			    elseif opt==1 then
				    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON+CATEGORY_FUSION_SUMMON)
				    fusop(e,tp,eg,ep,ev,re,r,rp)
			    end
		    end
	    end
    end
end
--Gain Effect
function s.dbfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_BLACK_ROSE_DRAGON) or (c:IsLevelAbove(5) and c:ListsCode(CARD_BLACK_ROSE_DRAGON))
end
function s.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.dbfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.dbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		--Destroy monster
        local e1=Effect.CreateEffect(c)
	    e1:SetDescription(aux.Stringid(id,6))
	    e1:SetCategory(CATEGORY_DESTROY)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	    e1:SetCode(EVENT_BATTLE_START)
	    e1:SetCondition(s.atkcon)
	    e1:SetOperation(s.atkop)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsLocation(LOCATION_MZONE) and bc and bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local bc=c:GetBattleTarget()
	local atk=bc:GetBaseAttack()
	Duel.Destroy(bc,REASON_EFFECT)
end