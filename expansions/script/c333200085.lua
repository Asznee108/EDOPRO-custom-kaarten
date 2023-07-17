--Chaos Ultimate Dragon
local s,id=GetID()
function s.initial_effect(c)
	--revive limit
    c:EnableReviveLimit()
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--immune effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	--atkup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_ONFIELD)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
end
s.listed_series={0xcf}
function s.rvlimit(e)
	return not e:GetHandler():IsLocation(LOCATION_HAND)
end
function s.hspfilter(c,e,tp)
	return c:IsSetCard(0xcf) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_RITUAL+TYPE_EFFECT)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,nil)
	local g1=rg:Filter(Card.IsType,nil,TYPE_FUSION)
	local g2=rg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	local g3=rg:Filter(Card.IsType,nil,TYPE_XYZ)
	local g4=rg:Filter(Card.IsType,nil,TYPE_RITUAL)
	local g5=rg:Filter(Card.IsType,nil,TYPE_EFFECT)
	return Duel.GetLocationCount(tp,LOCATION_ONFIELD)>-5 and #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 
		and aux.SelectUnselectGroup(g1,e,tp,1,1,aux.ChkfMMZ(1),0)
		and aux.SelectUnselectGroup(g2,e,tp,1,1,aux.ChkfMMZ(1),0)
		and aux.SelectUnselectGroup(g3,e,tp,1,1,aux.ChkfMMZ(1),0)
		and aux.SelectUnselectGroup(g4,e,tp,1,1,aux.ChkfMMZ(1),0)
		and aux.SelectUnselectGroup(g5,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.hspfilter,nil)
	local g1=rg:Filter(Card.IsType,nil,TYPE_FUSION)
	local g2=rg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	local g3=rg:Filter(Card.IsType,nil,TYPE_XYZ)
	local g4=rg:Filter(Card.IsType,nil,TYPE_RITUAL)
	local g5=rg:Filter(Card.IsType,nil,TYPE_EFFECT)
	local mg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #mg1>0 then 
		local mg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
		mg1:Merge(mg2)
		if #mg1>1 then
			local mg3=aux.SelectUnselectGroup(g3,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
			mg1:Merge(mg3)
			if #mg1>2 then
			    local mg4=aux.SelectUnselectGroup(g4,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
			    mg1:Merge(mg4)
			    if #mg1>3 then
			       local mg5=aux.SelectUnselectGroup(g5,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
			       mg1:Merge(mg5)
			  end
		   end
		end
	end
	if #mg1==5 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.atkfilter(c)
	return c:IsSetCard(0xcf)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,0,nil)*500
end