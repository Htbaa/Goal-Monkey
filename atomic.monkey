Strict

Import exception

#Rem
    Copyright (c) 2010-2014 Christiaan Kras

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#End

#Rem
    Summary: Atomic Goal type
#End
Class Goal<T> Abstract
    Const STATUS_ACTIVE:Int = 0
    Const STATUS_INACTIVE:Int = 1
    Const STATUS_COMPLETED:Int = 2
    Const STATUS_FAILED:Int = 3

    Field m_iType:Int
    Field m_pOwner:T
    Field m_iStatus:Int

	Field m_sName:String
	
    #Rem
        Summary: note how goals start off in the inactive state
    #End
    Method New(pOwner:T, iType:Int, sName:String = "UnnamedGoal")
        Self.m_iStatus = STATUS_INACTIVE
        Self.m_pOwner = pOwner
        Self.m_iType = iType
		Self.m_sName = sName
    End Method

    #Rem
        Summary: if m_iStatus = inactive this method sets it to active and calls Activate()
    #End
    Method ActivateIfInactive:Void()
        If Self.IsInactive()
            Self.Activate()
        End If
    End Method

    #Rem
        Summary: If m_iStatus is failed this Method sets it To inactive so that the goal will be reactivated (And therefore re - planned) on the Next update - Step
    #End
    Method ReactivateIfFailed:Void()
        If Self.hasFailed()
            Self.m_iStatus = STATUS_INACTIVE
        End If
    End Method

    #Rem
        Summary: logic to run when the goal is activated.
    #End
    Method Activate:Void() Abstract

    #Rem
        Summary: logic to run each update-step
    #End
    Method Process:Int() Abstract

    #Rem
        Summary: logic To run when the goal is satisfied. (typically used To switch off, For example, any active steering behaviors)
    #End
    Method Terminate:Void() Abstract

    #Rem
        Summary: goals can handle messages. Many don't though, so this defines a default behavior
    #End
    Method HandleMessage:Bool(message:Object)
        Return False
    End Method

    #Rem
        Summary: a Goal is atomic and cannot aggregate subgoals yet we must implement this method to provide the uniform interface required for the goal hierarchy.
    #End
    Method AddSubgoal:Void(goal:Goal)
        Throw New GoalException("Cannot add goals to atomic goals")
    End Method

    #Rem
        Summary: Check if goal has been completed
    #End
    Method IsComplete:Bool()
        Return Self.m_iStatus = STATUS_COMPLETED
    End Method

    #Rem
        Summary: Check if goal is still active
    #End
    Method IsActive:Bool()
        Return Self.m_iStatus = STATUS_ACTIVE
    End Method

    #Rem
        Summary: Check if goal is inactive
    #End
    Method IsInactive:Bool()
        Return Self.m_iStatus = STATUS_INACTIVE
    End Method

    #Rem
        Summary: Check if goal failed to perform its tasks
    #End
    Method HasFailed:Bool()
        Return Self.m_iStatus = STATUS_FAILED
    End Method

    #Rem
        Summary: Returns m_iType:Int
    #End
    Method GetType:Int()
        Return Self.m_iType
    End Method

    #Rem
        Summary: when this Object is destroyed make sure any subgoals are terminated and destroyed
    #End
    Method Destroy:Void()
        Self.m_pOwner = Null
    End Method
	
	#Rem
		Summary: Retrieve name of goal
	#END
	Method Name:String() Property
		Return Self.m_sName
	End
	
	#Rem
		Summary: Set name of goal
	#END
	Method Name:Void(sName:String) Property
		Self.m_sName = sName
	End
End
