--Spirit Resonator
local s,id=GetID()
function s.initial_effect(c)
	--synchro custom
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--Synchro Summon using GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_HAND_SYNCHRO)
	e2:SetLabel(511000806)
	e2:SetValue(s.synval)
	c:RegisterEffect(e2)
    --Synchro Summon monster from GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(511002081)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetOperation(s.synchk)
		Duel.RegisterEffect(ge2,0)
	end)
end
--Synchro Summon using GY 511000806
function s.synval(e,c,sc)
    if c:IsLocation(LOCATION_GRAVE) and (c:IsRace(RACE_FIEND) or c:IsRace(RACE_DRAGON)) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
        e1:SetLabel(511000806)
        e1:SetTarget(s.synchktg)
        c:RegisterEffect(e1)
        return true
    else 
        return false end
end
function s.chk2(c)     
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end     
    local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO)}     
    for i=1,#te do         
        local e=te[i]         
        if e:GetLabel()==511000806 then return true end     
    end     
    return false 
end
function s.synchktg(e,c,sg,tg,ntg,tsg,ntsg)
    if c then
        if #sg>=20 or (not tg:IsExists(s.chk2,1,c) and not ntg:IsExists(s.chk2,1,c) and not sg:IsExists(s.chk2,1,c)) then return false end
        local res=true
        local ttg=tg:Filter(aux.TRUE,nil)
        local nttg=ntg:Filter(aux.TRUE,nil)
        local trg=tg:Clone()
        local ntrg=ntg:Clone()
        trg:Sub(ttg)
        ntrg:Sub(nttg)
        return res,trg,ntrg
    else
        return #sg<20
    end
end
function s.synopfilter(c)
    if not c:IsLocation(LOCATION_GRAVE) or not c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
    local te={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
    for i=1,#te do
        local e=te[i]
        if e:GetLabel()~=511000806 then return false end
    end
    return true
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
    local tsg=sg:Clone()
    if tsg:IsExists(s.synopfilter,1,nil) then
        return tsg:GetFirst():IsRace(RACE_FIEND) or tsg:GetFirst():IsRace(RACE_DRAGON),false
    else
        return true,false
    end
end
--Synchro Summon monster from GY
function s.regfilter(c)
	return c.synchro_type and c:IsType(TYPE_SYNCHRO) and c:GetFlagEffect(511002081+1)==0
end
function s.synchk(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.regfilter,tp,0xff,0xff,nil)
	local tc=sg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(511002081+1,0,0,0)
		local tpe=tc.synchro_type
		local t=tc.synchro_parameters
		if tc.synchro_type==1 then
			local f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm=table.unpack(t)
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,s.reqm(reqm)))
			e1:SetTarget(Synchro.Target(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,s.reqm(reqm)))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		elseif tc.synchro_type==2 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(table.unpack(t),s.reqm()))
			e1:SetTarget(Synchro.Target(table.unpack(t),s.reqm()))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		elseif tc.synchro_type==3 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetCondition(Synchro.Condition(table.unpack(t),s.reqm()))
			e1:SetTarget(Synchro.Target(table.unpack(t),s.reqm()))
			e1:SetOperation(Synchro.Operation)
			e1:SetValue(SUMMON_TYPE_SYNCHRO)
			tc:RegisterEffect(e1)
		end
		tc=sg:GetNext()
	end
end
function s.reqm(reqm)
	return function(g,sc,tp)
				return g:IsExists(Card.IsHasEffect,1,nil,511002081) and (not reqm or reqm(g,sc,tp))
			end
end