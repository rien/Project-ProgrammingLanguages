functor
import
   System(showInfo:ShowInfo)
export
   andThen:AndThen
   join:Join
   joinTuple:JoinTuple
   makeListWith:MakeListWith
   makeTupleWith:MakeTupleWith
   otherPlayer:OtherPlayer
   directionFor:DirectionFor
define

   /* Returns true when L is an empty list.
    * False otherwise
    */
   fun {IsEmpty L}
      case L
      of nil then true
      else false
      end
   end

   fun {AndThen A B}
      if A
      then true
      else B
      end
   end

   fun {OtherPlayer P}
      case P
      of p1 then p2
      [] p2 then p1
      end
   end

   fun {DirectionFor Player}
      case Player
      of p1 then 1
      [] p2 then ~1
      end
   end

   /* MakeListWith
    *
    * Returns a list of length Len, all elements are Elem's.
    */
   fun {MakeListWith Len Elem}
      if Len > 0
      then Elem|{MakeListWith Len-1 Elem}
      else nil
      end
   end


   /* MakeListWith
    *
    * Returns a tuple of length Len, all elements are Elem's.
    * The elements go from 1 to Len (inclusive).
    */
   fun {MakeTupleWith Name Len Elem}
      T
   in
      T = {MakeTuple Name Len}
      for I in 1..Len do
         T.I = Elem
      end
      T % Return
   end

   /* Join
    *
    * Joins a list of strings with a separator between them.
    * Example: Join ["Foo" "Bar" "Baz"] "++"
    * => "Foo++Bar++Baz"
    */
   fun {Join StrList Sep}
      case StrList
      of nil then ""
      [] X|nil then X
      [] X|Xr  then X#Sep#{Join Xr Sep}
      end
   end

   /* JoinTuple
    *
    * Joins a list of strings with a separator between them.
    * Example: Join ["Foo" "Bar" "Baz"] "++"
    * => "Foo++Bar++Baz"
    */
   fun {JoinTuple Tup Sep}
      Length = {Width Tup}
      fun {Iteration I Acc}
         if I >= Length
         then Acc#Tup.I
         else {Iteration I+1 Acc#Tup.I#Sep}
         end
      end
   in
      {Iteration 1 ""}
   end
end
