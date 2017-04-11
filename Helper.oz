functor
import
   System(showInfo:ShowInfo)
export
   join:Join
   joinTuple:JoinTuple
   makeListWith:MakeListWith
   makeTupleWith:MakeTupleWith
   mapIdx:MapIdx
   mapInd0:MapInd0
   forAllInd0:ForAllInd0
define

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

   /* MapInd0
    *
    * Like MapInd for tuples, but 0 indexed (and arguments are switched)
    * The function should take an element from the tuple first and an index second.
    */
   fun {MapInd0 Tup Func}
      fun {FuncSub I E}
         {Func E I-1}
      end
   in
      {Record.mapInd Tup FuncSub}
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

   /* MapIdx
    *
    * Works like Map but also gives the index as second argument
    * of the current item to the consumer.
    */
   fun {MapIdx List Func}
      fun {Iteration Idx List Func}
         case List of nil then nil
         [] X|Xs then {Func X Idx}|{Iteration Idx+1 Xs Func}
         end
      end
   in
      {Iteration 0 List Func}
   end

   /* ForEach
    *
    * Loop over all the fields of a tuple while keeping track of the index (zero indexed!).
    * Proc should be a procedure which accepts an element of the tuple and the index.
    */
   proc {ForAllInd0 Tup Proc}
      proc {ProcSub E I}
         {Proc E I-1}
      end
   in
      {Record.forAllInd Tup ProcSub}
   end

   /* FoldLTup
    *
    * Like FoldL bu for Tuples
    */
   fun {FoldLTup Tup Func Acc}
      Length = {Width Tup}
      fun {Iteration I A}
         if I > Length
         then A
         else {Iteration I+1 {Func Tup.I}}
         end
      end
   in
      {Iteration 1 Acc}
   end
end
