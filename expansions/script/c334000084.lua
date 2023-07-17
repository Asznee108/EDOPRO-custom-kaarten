--Marincess Pearl Matriarch
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12b),2)
    --immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --Prevent destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetTarget(s.infilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkop)
	c:RegisterEffect(e3)
    --Equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
    aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),Card.EquipByEffectAndLimitRegister,e4)
end
s.listed_series={0x12b}
--Immune
function s.imfilter(c,e,te,atk)
    local c=e:GetHandler()
    local atk=c:GetLevel()
    return c:IsAttackBelow(atk-1)
end
function s.efilter(e,te,atk)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner() and s.imfilter(e,te,atk)
end
--Indestructable
function s.infilter(c)
	return c:IsSetCard(0x12b)
end
--Gain ATK 
function s.atkop(e,c)
	local wup=0
	local wg=e:GetHandler():GetEquipGroup()
	for wbc in aux.Next(wg) do
		if wbc:IsSetCard(0x12b) and wbc:IsType(TYPE_LINK) then
			wup=wup+wbc:GetLink()
		end
	end
	return wup*200
end
--Equip or Special Summon 
function s.filter(c,e,tp)
	return c:IsMonster()  and c:IsSetCard(0x12b) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
function s.eqfilter(c)
    return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local zone=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0,tp)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) end
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and zone>0
    local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	local g=eg:Filter(s.filter,nil,e,tp)
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil)
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
    local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 end
	e:SetLabel(op)
    if op==0 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE)
    else
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE)
    end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if e:GetLabel()==0 then
        local zone=aux.GetMMZonesPointedTo(tp,nil,LOCATION_MZONE,0,tp)
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) and zone>0 then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
        end
	else
        local eqc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
            c:EquipByEffectAndLimitRegister(eqc,tp,tc)
        end
	end
end