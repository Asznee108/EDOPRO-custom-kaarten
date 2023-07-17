--Red Luminous Hypernova Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Synchro summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,5,5,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,1)
	--Must first be synchro summoned
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
    --to battle phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --battle twice 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_BP_TWICE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(1)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.bpcon)
    e2:SetOperation(s.bpop)
	c:RegisterEffect(e2)
    --always Battle destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(511010508)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.battg)
	e3:SetValue(s.batval)
	c:RegisterEffect(e3)
    --Cannot be destroyed
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	--Double tuner
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(21142671)
	c:RegisterEffect(e6)
	--inactivate
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,1)
	e7:SetValue(s.aclimit)
	c:RegisterEffect(e7)
    --atk
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)
    --damage negation battle
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetOperation(s.op1)
	c:RegisterEffect(e9)
	--attack up (damage)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCode(EFFECT_UPDATE_ATTACK)
	e10:SetValue(s.flagval)
	c:RegisterEffect(e10)
	--Immune monster effects
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_IMMUNE_EFFECT)
	e11:SetValue(s.efilter)
	c:RegisterEffect(e11)
	--cannot be target
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetValue(aux.tgoval)
	c:RegisterEffect(e12)
	--attack up (damage opponent)
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,7))
	e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e13:SetCode(EVENT_DAMAGE)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCondition(s.atkcon)
	e13:SetOperation(s.atkop)
	c:RegisterEffect(e13)
	--Banish itself and all opponent's cards
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(id,5))
	e14:SetCategory(CATEGORY_REMOVE)
	e14:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e14:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e14:SetCode(EVENT_CHAINING)
	e14:SetRange(LOCATION_MZONE)
	e14:SetCountLimit(1,id+2)
	e14:SetCondition(s.rmcon)
	e14:SetCost(s.rmcost)
	e14:SetTarget(s.rmtg)
	e14:SetOperation(s.rmop)
	c:RegisterEffect(e14)
	--special summon this banished card
	local e15=Effect.CreateEffect(c)
	e15:SetDescription(aux.Stringid(id,6))
	e15:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e15:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e15:SetCode(EVENT_PHASE+PHASE_END)
	e15:SetRange(LOCATION_REMOVED)
	e15:SetCountLimit(1,id+3)
	e15:SetCondition(s.spcon2)
	e15:SetTarget(s.sptg2)
	e15:SetOperation(s.spop2)
	c:RegisterEffect(e15)
end
s.synchro_nt_required=1
--skip to battle phase when synchro summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
	--End Turn
	local c=e:GetHandler()
	--prevent activations for the rest of that phase
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(1,1)
	e0:SetValue(1)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--skip phases until Battle Phase
	local p=Duel.GetTurnPlayer()
	Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(p,PHASE_END,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
	Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,p==tp and 2 or 1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_EP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_MAIN1,Duel.GetCurrentPhase()<=PHASE_MAIN1 and 2 or 1)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_EP)
	e3:SetTargetRange(0,1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
    end
end
--conduct 2 battle phases
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon2)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetLabel(e:GetHandler():GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.bpcon2(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
--always destroy battle
function s.battg(e,c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.batval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--atk gain for Tuner
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,TYPE_TUNER)*500
end
--damage negation battle
function s.op1(e,tp,eg,ep,ev,re,r,rp)
local dam=Duel.GetBattleDamage(tp)
local c=e:GetHandler()
if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,0) end
	if dam>0 then
	    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
		c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)-Duel.GetBattleDamage(tp))
		Duel.ChangeBattleDamage(tp,0)
	end
end
--attack up (damage)
function s.flagval(e,c)
	return e:GetHandler():GetFlagEffectLabel(id) and -e:GetHandler():GetFlagEffectLabel(id) or 0
end
--attack up (damage opponent)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r&REASON_BATTLE==REASON_BATTLE
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetLabelObject(e)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
--Immune monster effects
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--banish this card and opponent's cards
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,rc:GetLocation(),1,nil) 
		and c:IsAbleToRemove() end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,rc:GetLocation(),nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,rc:GetLocation(),nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
--special summon this banished card
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp 
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--cannot activate banished cards
function s.aclimit(e,re,tp)
	return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,1,nil,re:GetHandler():GetCode())
end