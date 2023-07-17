--D/D/D Crusade King Ganelon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),7,2,s.ovfilter,aux.Stringid(id,4),99)
    --atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
    --Special Summon or attach
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    --Attach 1 "Dark Contract" card from your field or GY to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
s.listed_series={0x10af,0xaf,0xae}
s.listed_names={id}
--Alt Summoning Condition
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRankBelow(6) and c:IsSetCard(0x10af,lc,SUMMON_TYPE_XYZ,tp)
end
--Gain ATK
function s.atkval(e,c)
	return c:GetOverlayCount()*500
end
--Special Summon or attach
function s.filter(c)
	return c:IsSetCard(0xaf) and c:IsMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,ft) end
    local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tp,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if not tc then return end
	local spchk=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
    if not (spchk or c) then return end
	local op=Duel.SelectEffect(tp,
		{spchk,aux.Stringid(id,2)},
		{c,aux.Stringid(id,3)})
	local success_chk=nil
	if op==1 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		success_chk=true
	else
        Duel.HintSelection(tc,true)
		Duel.Overlay(c,tc)
	end
    Duel.Damage(tp,500,REASON_EFFECT)
end
--Attach "Dark Contract" card
function s.mtfilter(c)
	return c:IsSetCard(0xae)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end
    local val=c:GetOverlayGroup():FilterCount(Card.IsSetCard,nil,0xae)*1000+1
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Overlay(c,g)
        local val=c:GetOverlayGroup():FilterCount(Card.IsSetCard,nil,0xae)*1000
        Duel.Recover(tp,val,REASON_EFFECT)
        Duel.Damage(1-tp,val,REASON_EFFECT)
	end
end