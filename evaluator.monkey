Strict
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
    Summary: Base class to create a goal evaluator
#End
Class GoalEvaluator<T> Abstract
    'when the desirability score for a goal has been evaluated it is multiplied 
    'by this value. It can be used to create bots with preferences based upon
    'their personality
    Field m_dCharacterBias:Float

    #Rem
        Summary: Object creation
    #End
    Method New(CharacterBias:Float)
        Self.m_dCharacterBias = CharacterBias
    End Method

    #Rem
        Summary: returns a score between 0 and 1 representing the desirability of the strategy the concrete subclass represents
    #End
    Method CalculateDesirability:Float(Owner:T) Abstract

    #Rem
        Summary: adds the appropriate goal to the given bot's brain
    #End
    Method SetGoal:Void(Owner:T) Abstract
End
