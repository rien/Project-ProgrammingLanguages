%
% A board to play the game on.
%
% A board is represented by a tuple board(row(...) ... row()) of row tuples.
%
functor
import
   System( showInfo:ShowInfo)
   Helper( joinTuple:JoinTuple
           join:Join
           makeListWith:MakeListWith
           makeTupleWith:MakeTupleWith
           otherPlayer:OtherPlayer
           directionFor:DirectionFor
         )
export
   show:Show
   init:Init
   set:Set
   validMovesFor:ValidMovesFor
   analyse:Analyse
   toList:ToList

define

   /* Init
    *
    * Return a square matrix of Size
    * with p1 on the first row, p2 on the last
    * and 'empty' in between
    */
   fun {Init Rows Cols}
      B
   in
      B = {MakeTuple board Rows}
      B.1 = {MakeTupleWith row Cols p1}
      for Row in 2..Rows-1 do
         B.Row = {MakeTupleWith row Cols empty}
      end
      B.Rows = {MakeTupleWith row Cols p2}
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
         fun {RowToString Idx Row}
            Idx#"| "#{JoinTuple {Record.map Row ToChar} " "}#" |"
         end
         Cols = {Width Board.1}

         % A nice upper and lower border for the frame
         Border = " +"#{MakeListWith 2*Cols+1 &- }#"+"
      in
      {ShowInfo "   "#{Join [I suchthat I in 1..Cols] " "}}
      {ShowInfo Border}
      {ShowInfo {JoinTuple {Record.mapInd Board RowToString} "\n"}}
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
         RD = R+Dir % Next row
         CL = C-1   % One column left
         CR = C+1   % One column right
         Other = {OtherPlayer Player}
         Rows = {Width Board}
         Cols = {Width Board.1}
         EndRow

         fun {Move To} % Create the tuple mv(f(R C) t(R C))
            mv(f(R C) To)
         end
      in
         case Player
         of p1 then EndRow = Rows+1
         [] p2 then EndRow = 0
         end

         if RD == EndRow
         then nil % No moves possible
         else
            % One step forward
            if Board.(RD).C == empty
            then L1 = t(RD C)|nil
            else L1 = nil
            end

            % Take right opponent diagonally
            if CL > 0 andthen Board.RD.CL == Other
            then L2 = t(RD CL)|L1
            else L2 = L1
            end

            % Take left oppononet diagonally
            if CR < (Cols+1) andthen Board.RD.CR == Other
            then L3 = t(RD CR)|L2
            else L3 = L2
            end

            % Create the moves
            {Map L3 Move}
         end
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

   /* Analyse
    *
    * Returns the current situation of a board.
    * The result is the following record:
    * situation( finished: f(p1:Bool p2:Bool)
    *            moves: m( p1:List p2:List)
    *            )
    * -> p1Finish and p2Finish are true when p1 or p2 reached the other side
    * -> moves contain a record with the valid moves for each player
    *    if it would be their turn right now
    */
   fun {Analyse B}
      Last = {Width B}
      fun {IsP1 P}
         P == p1
      end
      fun {IsP2 P}
         P == p2
      end
      P1f = {Record.some B.Last IsP1}
      P2f = {Record.some B.1 IsP2}
      P1m = {ValidMovesFor p1 B}
      P2m = {ValidMovesFor p2 B}
   in
      situation( finished: f(p1: P1f p2: P2f)
                 moves: m(p1:P1m p2:P2m)
                 )
   end

   /*
    * Converts a board (of tuples) to a list of lists.
    */
   fun {ToList B}
      Rows = {Width B}
      Cols = {Width B.1}
      fun {IterateRow RowInd}
         fun {IterateCol ColInd}
            if ColInd < Cols+1
            then B.RowInd.ColInd|{ IterateCol ColInd+1}
            else nil
            end
         end
      in
         if RowInd < Rows+1
         then {IterateCol 1}|{IterateRow RowInd+1}
         else nil
         end
      end
   in
      {IterateRow 1}
   end
end
