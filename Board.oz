functor
import
   System(showInfo:ShowInfo)
   Helper(join:Join mapIdx:MapIdx makeListWith:MakeListWith)
export
   show:Show
   init:Init
   replaceWith:ReplaceWith
define

   /* Init
    *
    * Return a square matrix of Size
    * with p1 on the first row, p2 on the last
    * and 'empty' in between
    */
   fun {Init Size}
      local
         EmptyRows = for _ in 0..Size-2 collect:C do
            {C {MakeListWith Size empty}}
         end
      in
         {MakeListWith Size p1}|{Append EmptyRows [{MakeListWith Size p2}]}
      end
   end

   /*
    * Show
    *
    * Prints the given board to stdout in a pretty ASCII-frame.
    * Cells with a pawn will be represented by the number
    * of each player (player 1 => 1).
    * Cells without pawn are represented by a dot '.'
    */
   proc {Show Board}
      local
         % Converts a board element to a character
         fun {ToChar Elem}
            case Elem
            of empty then "."
            [] p1 then "1"
            [] p2 then "2"
            end
         end

         % Each element separated by a space
         % Between to pipes to make the sides of the frame
         fun {RowToString Row}
            "| "#{Join {Map Row ToChar} " "}#" |"
         end

         % A nice upper and lower border for the frame
         Border = "+"#{MakeListWith 2*{Length Board}-1 &- }#"+"
      in
      {ShowInfo Border}
      {ShowInfo {Join {Map Board RowToString} "\n"}}
      {ShowInfo Border}
      end
   end

   /* ReplaceWith
    *
    * Return a new Board with NewElem at the given location.
    * When the coordinates are not within the Board's boundaries,
    * the same board is returned.
    */
   fun {ReplaceWith NewElem RowNum ColNum Board}
      local
         % Replace the element in the requested column with the new element
         fun {ReplaceCol OldElem Idx}
            if Idx == ColNum
            then NewElem
            else OldElem
            end
         end

         % Replace the requested row with a row where the new element is replaced
         fun {ReplaceRow Row Idx}
            if Idx == RowNum
            then {MapIdx Row ReplaceCol}
            else Row
            end
         end
      in
         {MapIdx Board ReplaceRow}
      end
   end
end
