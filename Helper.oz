functor
export
   mapIdx:MapIdx
   join:Join
   makeListWith:MakeListWith
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

   /* MapIdx
    *
    * Works like Map but also gives the index as second argument
    * of the current item to the consumer.
    */
   fun {MapIdx List Func}
      local
         fun {Iteration Idx List Func}
            case List of nil then nil
            [] X|Xs then {Func X Idx}|{Iteration Idx+1 Xs Func}
            end
         end
      in
         {Iteration 0 List Func}
      end
   end
end
