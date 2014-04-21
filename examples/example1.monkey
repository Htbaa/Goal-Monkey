Strict

Import htbaa.goal
Import monkey.list
Import monkey.random
Import reflection

Const GOAL_FART:Int = 100
Const GOAL_SING:Int = 101
Const GOAL_JUMP:Int = 102

Class Actor
	Field name:String
	Field m_pBrain:BotGoalThink
	Field currentSong:String
	
	Method New()
		Self.m_pBrain = New BotGoalThink(Self, 1)
		Self.name = "John Doe"
	End Method
	
	Method Destroy:Void()
		Self.m_pBrain.Destroy()
	End Method
	
	Method Update:Void()
		Self.m_pBrain.Process()
	End Method
	
	Method ToString:String()
		Return "Hello! My name's: " + Self.name
	End Method
End

Class BotGoalThink Extends GoalComposite<Actor>
	Field m_Evaluators:List<GoalEvaluator<T>> = New List<GoalEvaluator<T>>

	Method New(owner:T, type:Int)
		Super.New(owner, type)
		Self.m_Evaluators.AddLast(New BotSingGoalEvaluate(1.0))
		Self.m_Evaluators.AddLast(New BotJumpGoalEvaluate(1.0))
	End Method
	
	Method Activate:Void()
		Self.Arbitrate()
		Self.m_iStatus = STATUS_ACTIVE
	End Method
	
	Method Process:Int()
  		'If status is inactive, call Activate()
  		Self.ActivateIfInactive()

		Local SubgoalStatus:Int = Self.ProcessSubgoals()
		
		If SubgoalStatus = STATUS_COMPLETED Or SubgoalStatus = STATUS_FAILED
			Self.m_iStatus = STATUS_INACTIVE
		End If
		
  		Return Self.m_iStatus
	End Method
	
	Method Terminate:Void()
		Self.Destroy()
	End Method
	
	#Rem
		bbdoc: this method iterates through each goal evaluator and selects the one
		that has the highest score as the current goal
	#End
	Method Arbitrate:Void()
		Local best:Float = 0
		Local MostDesirable:GoalEvaluator<T>
		
		For Local curDes:GoalEvaluator<T> = EachIn Self.m_Evaluators
			Local desirability:Float = curDes.CalculateDesirability(Self.m_pOwner)
			If desirability >= best
				best = desirability
				MostDesirable = curDes
			End If
		Next
		
		'Assert MostDesirable, "TBotGoalThink.Arbitrate() no evaluator selected!"
		If MostDesirable <> Null
			'Seems to cause a memory access violation?
			'Print "MostDesirable: " + GetClass(MostDesirable).Name() + " at " + best
		End
		MostDesirable.SetGoal(Self.m_pOwner)
	End Method
	
	#Rem
		bbdoc: returns true if the given goal is not at the front of the subgoal list 
	#End
	Method NotPresent:Int(GoalType:Int)
		If Not Self.m_SubGoals.IsEmpty()
			Return Not Self.m_SubGoals.First().GetType() = GoalType
		End If
		Return True
	End Method
	
	'Top level goal types
	Method AddGoal_Sing:Void()
		If Self.NotPresent(GOAL_SING)
			'Self.RemoveAllSubgoals()
			Self.AddSubgoal(New BotGoalSing(Self.m_pOwner, GOAL_SING))
		End If
	End Method
	
	Method AddGoal_Jump:Void()
		If Self.NotPresent(GOAL_JUMP)
			'Self.RemoveAllSubgoals()
			Self.AddSubgoal(New BotGoalJump(Self.m_pOwner, GOAL_JUMP))
		End If
	End Method
	
End

Class BotGoalFart Extends Goal<Actor>
	Method New(owner:T, type:Int)
		Super.New(owner, type)
	End Method
	
	Method Activate:Void()
		Self.m_iStatus = STATUS_ACTIVE
	End Method
	
	Method Process:Int()
  		'If status is inactive, call Activate()
  		Self.ActivateIfInactive()
		Print "I'm farting!"
		Self.m_iStatus = STATUS_COMPLETED
  		Return Self.m_iStatus
	End Method
	
	Method Terminate:Void()
		
	End Method
End

Class BotGoalSing Extends GoalComposite<Actor>
	Method New(owner:T, type:Int)
		Super.New(owner, type)
	End Method
	
	Method Activate:Void()
		Self.m_iStatus = STATUS_ACTIVE
		Self.RemoveAllSubgoals()
		Self.AddSubgoal(New BotGoalJump(Self.m_pOwner, GOAL_JUMP))
		Self.AddSubgoal(New BotGoalFart(Self.m_pOwner, GOAL_FART))
	End Method
	
	Method Process:Int()
  		'If status is inactive, call Activate()
  		Self.ActivateIfInactive()
		Print "I'm singing"
		Actor(Self.m_pOwner).currentSong = "song nr " + Int(Rnd(1.0, 100.0))
  		Self.m_iStatus = Self.ProcessSubgoals()
		Return Self.m_iStatus
	End Method
	
	Method Terminate:Void()
		Self.m_pOwner.currentSong = ""
	End Method
End

Class BotSingGoalEvaluate Extends GoalEvaluator<Actor>
	Method New(bias:Float)
		Super.New(bias)
	End Method
	
	Method CalculateDesirability:Float(Owner:T)
		'Sing a song once
		If Owner.currentSong.Length = 0' <> Null
			Return 0.0
		Else
			Return Rnd()
		End If
	End Method
	
	Method SetGoal:Void(Owner:T)
		Owner.m_pBrain.AddGoal_Sing()
	End Method
End

Class BotGoalJump Extends GoalComposite<Actor>
	Method New(owner:Actor, type:Int)
		Super.New(owner, type)
	End Method

	Method Activate:Void()
		Self.m_iStatus = STATUS_ACTIVE
		Self.RemoveAllSubgoals()
		Self.AddSubgoal(New BotGoalFart(Self.m_pOwner, GOAL_FART))
	End Method
	
	Method Process:Int()
  		'If status is inactive, call Activate()
  		Self.ActivateIfInactive()
		Print "I'm jumping"
  		Self.m_iStatus = Self.ProcessSubgoals()
		Return Self.m_iStatus
	End Method
	
	Method Terminate:Void()
		
	End Method
End

Class BotJumpGoalEvaluate Extends GoalEvaluator<Actor>
	Method New(bias:Float)
		Super.New(bias)
	End Method

	Method CalculateDesirability:Float(Owner:T)
		Return Rnd()
	End Method
	
	Method SetGoal:Void(Owner:T)
		Owner.m_pBrain.AddGoal_Jump()
	End Method
End


Function Main:Int()
	Local actor:Actor = New Actor
	Print actor.ToString()
	
	For Local i:Int = 0 To 200
		Print "Count: " + actor.m_pBrain.m_SubGoals.Count()
		actor.Update()
	Next
	Return 0
End