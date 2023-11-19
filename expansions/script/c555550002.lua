--Vergil - Sin Devil Trigger
local s,id=GetID()
function s.initial_effect(c)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--unaffected
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_CHAIN_SOLVING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetOperation(s.immop)
	c:RegisterEffect(e2a)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	e2:SetLabelObject(e2a)
	c:RegisterEffect(e2)
	--Doom Virus (Faceup)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--check
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_MSET)
	e4:SetOperation(s.chkop)
	c:RegisterEffect(e4)
	--Special Summon itself
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_PROC)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_EXTRA|LOCATION_GRAVE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,{id,0})
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--Equip up to 3 Equip Spells
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_EQUIP)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetTarget(s.eqtg)
	e6:SetOperation(s.eqop)
	c:RegisterEffect(e6)
	--Attack all monsters
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_ATTACK_ALL)
	e7:SetValue(3)
	c:RegisterEffect(e7)
    --change name
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_CHANGE_CODE)
	e8:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e8:SetValue(555550000)
	c:RegisterEffect(e8)
    --cannot be Tributed, except by effect
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCode(EFFECT_UNRELEASABLE_SUM)
    e9:SetValue(1)
    e9:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e9)
    local e10=e9:Clone()
    e10:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    e10:SetValue(s.sumlimit)
    c:RegisterEffect(e10)
    local e11=Effect.CreateEffect(c)
    e11:SetType(EFFECT_TYPE_SINGLE)
    e11:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e11:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e11:SetValue(1)
    e11:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e11)
    local e12=e11:Clone()
    e12:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(e12)
    local e13=e11:Clone()
    e13:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(e13)
    local e14=e11:Clone()
    e14:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e14)
	--battle destruction check
	aux.GlobalCheck(s,function()
		s[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id,555550000}
--battle destruction check
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsCode(555550000) and ec:IsFaceup() then s[0]=s[0]+1 end
	end
end
--spsummon con
function s.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:ListsCode(555550000) and s[0]>=10
end
--immune
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetAttack())
end
function s.immval(e,te)
	if te:GetOwnerPlayer()~=e:GetHandlerPlayer() then
		if te:IsActiveType(TYPE_MONSTER) then
			local atk=e:GetLabelObject():GetLabel()
			local tc=te:GetHandler()
			return tc:GetAttack()<atk+1
		else 
			return true
		end
	end
end
--send to grave
function s.filter(c,g,pg)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	local conf=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,e:GetHandler())
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		g:Merge(conf)
	end
    Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.filter2(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
--Special Summon this card 
function s.rfilter(c,tp)
	return c:IsCode(555550000) and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.rfilter,1,false,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.rfilter,1,1,false,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Equip equip spells
function s.eqsfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp) and c:ListsCode(555550000)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqsfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqsfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp,c)
	if #g==0 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_EQUIP)
	if #sg>0 then
		for tc in sg:Iter() do
			Duel.Equip(tp,tc,c,true,true)
		end
		Duel.EquipComplete()
	end
end
--cannot be Tributed, except by effect 
function s.sumlimit(e,c)
	return not c:ListsCode(555550000)
end