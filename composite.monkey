Strict
Import monkey.list
Import htbaa.goal
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
#End Rem

#Rem
    bbdoc: Composite goal type
#End Rem
Class GoalComposite Extends Goal Abstract
    Field m_SubGoals:List<Goal> = New List<Goal>

    #Rem
        bbdoc: note how goals start off in the inactive state
    #End Rem
    Method New(pOwner:Object, iType:Int)
        Super.New(pOwner, iType)
    End Method

    #Rem
        bbdoc: when this Object is destroyed make sure any subgoals are terminated and destroyed
    #End Rem
    Method Destroy:Void()
        Self.RemoveAllSubgoals()
        Super.Destroy()
    End Method

    #Rem
        bbdoc: processes any subgoals that may be present this method first removes any completed goals from the front of the subgoal list. It then processes the next goal in the list (if there is one)
    #End Rem
    Method ProcessSubgoals:Int()
        'remove all completed and failed goals from the front of the subgoal list
        While(Not Self.m_SubGoals.IsEmpty() And (Goal(Self.m_SubGoals.First()).IsComplete() Or Goal(Self.m_SubGoals.First()).HasFailed()))
            Goal(Self.m_SubGoals.First()).Terminate()
            Self.m_SubGoals.RemoveFirst()
        Wend

        'if any subgoals remain, process the one at the front of the list
        If Not Self.m_SubGoals.IsEmpty()
            'grab the status of the front-most subgoal
            Local StatusOfSubGoals:Int = Goal(Self.m_SubGoals.First()).Process()
            'we have to test for the special case where the front-most subgoal
            'reports 'completed' *and* the subgoal list contains additional goals.When
            'this is the case, to ensure the parent keeps processing its subgoal list
            'we must return the 'active' status.
            If StatusOfSubGoals = STATUS_COMPLETED And Self.m_SubGoals.Count() > 1
                Return STATUS_ACTIVE
            End If
            Return StatusOfSubGoals
        'no more subgoals to process - return 'completed'
        Else
            Return STATUS_COMPLETED
        End If
    End Method

    #Rem
        bbdoc: passes the message To the front - most subgoal
    #End Rem
    Method ForwardMessageToFrontMostSubgoal:Int(Message:Object)
        If Not Self.m_SubGoals.IsEmpty()
            Return Goal(Self.m_SubGoals.First()).HandleMessage(Message)
        End If
        Return False
    End Method

    #Rem
        bbdoc: logic to run when the goal is activated.
    #End Rem
    Method Activate:Void() Abstract

    #Rem
        bbdoc: logic To run each update-Step
    #End Rem
    Method Process:Int() Abstract

    #Rem
        bbdoc: logic To run when the goal is satisfied. (typically used To switch off, For example, any active steering behaviors)
    #End Rem
    Method Terminate:Void() Abstract

    #Rem
        bbdoc: if a child class of TGoalComposite does not define a message handler the default behavior is to forward the message to the front-most goal
    #End Rem
    Method HandleMessage:Int(message:Object)
        Return Self.ForwardMessageToFrontMostSubgoal(message)
    End Method

    #Rem
        bbdoc: adds a subgoal to the front of the subgoal list
    #End Rem
    Method AddSubgoal:Void(goal:Goal)
        'add the new goal to the front of the list  
        Self.m_SubGoals.AddFirst(goal)
    End Method

    #Rem
        bbdoc: this method iterates through the subgoals and calls each one's Terminate method before deleting the subgoal and removing it from the subgoal list
    #End Rem
    Method RemoveAllSubgoals:Void()
        For Local goal:Goal = EachIn Self.m_SubGoals
            goal.Terminate()
            goal.Destroy()
        Next

        Self.m_SubGoals.Clear()
    End Method
End
