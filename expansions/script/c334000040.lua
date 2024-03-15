--Rose Dragon's Garden
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special Summon 1 "Rose Token"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	--Special Summon 1 monster from the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    --Destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.desreptg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
    -- Rose indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1123))
	e5:SetValue(1)
	c:RegisterEffect(e5)
    --gain lp
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.lpcon)
	e6:SetOperation(s.lpop)
	c:RegisterEffect(e6)
	--Change its name to "Black Garden"
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CHANGE_CODE)
	e7:SetRange(LOCATION_FZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	e7:SetValue(71645242)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0x1123}
s.listed_names={id,71645242,TOKEN_ROSE}
--Special Summon Rose Token
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:GetSummonType()~=SUMMON_TYPE_SPECIAL+0x20
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local sf=0
	if eg:IsExists(s.cfilter,1,nil,0) then
		sf=sf+1
	end
	if eg:IsExists(s.cfilter,1,nil,1) then
		sf=sf+2
	end
	e:SetLabel(sf)
	return sf~=0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id,e,r,rp,ep,e:GetLabel())
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	local p
	if bit.extract(ev,tp)~=0 and bit.extract(ev,1-tp)~=0 then
		p=PLAYER_ALL
	elseif bit.extract(ev,tp)~=0 then
		p=tp
	else
		p=1-tp
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,p,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(aux.FaceupFilter(Card.IsRelateToEffect,e),nil)
	local change=false
	for tc in aux.Next(g) do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e1) and math.ceil(preatk/2)==tc:GetAttack() then change=true end
	end
	if not change then return end
	if bit.extract(ev,tp)~=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ROSE,0x123,TYPES_TOKEN,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then
		local token=Duel.CreateToken(tp,TOKEN_ROSE)
		Duel.SpecialSummonStep(token,0x20,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
	if bit.extract(ev,1-tp)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(1-tp,TOKEN_ROSE,0x123,TYPES_TOKEN,800,800,2,RACE_PLANT,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp) then
		local token=Duel.CreateToken(1-tp,TOKEN_ROSE)
		Duel.SpecialSummonStep(token,0x20,1-tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	Duel.SpecialSummonComplete()
end
--Special Summon monster with equal or less atk
function s.spfilter(c,atk,e,tp)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0x20,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_PLANT),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	if chk==0 then return e:GetHandler():IsDestructable(e) and g:FilterCount(Card.IsDestructable,nil,e)==#g 
		and Duel.GetMZoneCount(tp,g)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,atk,e,tp) end
	g:AddCard(e:GetHandler())
	Duel.Destroy(g,REASON_COST)
	e:SetLabel(atk)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,atk,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Gain LP
function s.lpfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsRace(RACE_PLANT)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lpfilter,1,nil)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(e:GetHandlerPlayer(),500,REASON_EFFECT)
end
--Prevent own destruction
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup() end
	return Duel.SelectYesNo(tp,aux.Stringid(id,3))
end
function s.repval(e,c)
	return c:IsOnField() and c:IsReason(REASON_EFFECT)
end
