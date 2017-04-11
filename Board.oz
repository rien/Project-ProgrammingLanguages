functor
import
   System( showInfo:ShowInfo)
   Helper( joinTuple:JoinTuple
           makeListWith:MakeListWith
           makeTupleWith:MakeTupleWith
           mapInd0:MapInd0
           forallInd0:ForAllInd0
         )
export
   show:Show
   init:Init
   set:Set
   get:Get

   /* A board is represented by a tuple board(row(...) ... row()) of rows.
    *
    */
define

   /* Init
    *
    * Return a square matrix of Size
    * with p1 on the first row, p2 on the last
    * and 'empty' in between
    */
   fun {Init Size}
      B
   in
      B = {MakeTuple board Size}
      B.1 = {MakeTupleWith row Size p1}
      for Row in 2..Size-1 do
         B.Row = {MakeTupleWith row Size empty}
      end
      B.Size = {MakeTupleWith row Size p2}
      B % return
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
            "| "#{JoinTuple {Record.map Row ToChar} " "}#" |"
         end

         % A nice upper and lower border for the frame
         Border = "+"#{MakeListWith 2*{Width Board}+1 &- }#"+"
      in
      {ShowInfo Border}
      {ShowInfo {JoinTuple {Record.map Board RowToString} "\n"}}
      {ShowInfo Border}
      end
   end

   /* ReplaceWith
    *
    * Return a new Board with NewElem at the given location.
    * When the coordinates are not within the Board's boundaries,
    * the same board is returned.
    */
   fun {Set NewElem RowNum ColNum Board}
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
            then {MapInd0 Row ReplaceCol}
            else Row
            end
         end
      in
         {MapInd0 Board ReplaceRow}
      end
   end

   /* Get
    *
    * Get the item which is on the given position on the board.
    * Helper method to deal with the 1-indexing of board.
    */
   fun {Get Row Col Board}
     Board.(Row+1).(Col+1)
   end

end
