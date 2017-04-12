functor
import
   Browser
   System( showInfo:ShowInfo)
   Helper( joinTuple:JoinTuple
           makeListWith:MakeListWith
           makeTupleWith:MakeTupleWith
           otherPlayer:OtherPlayer
           directionFor:DirectionFor
           andThen:AndThen
         )
export
   show:Show
   init:Init
   set:Set
   validMovesFor:ValidMovesFor

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
         fun {ReplaceCol Idx OldElem}
            if Idx == ColNum
            then NewElem
            else OldElem
            end
         end

         % Replace the requested row with a row where the new element is replaced
         fun {ReplaceRow Idx Row}
            if Idx == RowNum
            then {Record.mapInd Row ReplaceCol}
            else Row
            end
         end
      in
         {Record.mapInd Board ReplaceRow}
      end
   end

   /* ValidMovesFor
    *
    * Returns a list of all the valid moves for the given player.
    * These moves are structured as move(f(FR FC) t(TR TC))
    * where FR and FC are the row and column from which a pawn originated
    * and TR and TR are the row and column to which the pawn can be moved.
    */
   fun {ValidMovesFor Player Board}
      Dir = {DirectionFor Player}

      % Return a list of all the possible moves that are possible
      % form the given position.
      fun {AccessibleFrom R C}
         L1
         L2
         L3
         SlayLeft
         SlayRight
         RD = R+Dir % Next row
         CL = C-1   % One column left
         CR = C+1   % One column right
         Other = {OtherPlayer Player}
         W = {Width Board}

         fun {Move To} % Create the tuple mv(f(R C) t(R C))
            mv(f(R C) To)
         end
      in
         % One step forward
         if Board.(RD).C == empty
         then L1 = t(RD C)|nil
         else L1 = nil
         end

         % Take right opponent diagonally
         if CL > 0 
         then SlayLeft = Board.RD.CL == Other
         else SlayLeft = false
         end

         if SlayLeft
         then L2 = t(RD CL)|L1
         else L2 = L1
         end

         % Take left oppononet diagonally
         if CR < (W+1)
         then SlayRight = Board.RD.CR == Other
         else SlayRight = false
         end

         if SlayRight
         then L3 = t(RD CR)|L2
         else L3 = L2
         end

         % Create the moves
         {Map L3 Move}
      end

      % Look in each row
      fun {CheckRow RowIdx Acc Row}
         % Look at each cell for pawns of the player
         fun {CheckCell ColIdx Acc Cell}
            if Cell == Player
            then
            {Append {AccessibleFrom RowIdx ColIdx} Acc}
            else Acc
            end
         end
      in
         {Append {Record.foldLInd Row CheckCell nil} Acc}
      end
   in
      {Record.foldLInd Board CheckRow nil}
   end

end
