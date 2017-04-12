functor
import
   Application
   Browser
   Board
   Helper(isEmpty:IsEmpty)
   System(showInfo:ShowInfo)
export
   refereeFor:RefereeFor
define
   /* RefereeFor
    *
    * Play a game on a board of the given size (Rows x Cols),
    * between two player which can be communicated with trough the ports P1 and P2.
    * The function returns a tuple with two Ports: one for each player.
    */
   fun {RefereeFor P1 P2 Rows Cols}

      % Which port for whic player?
      fun {PortFor P}
         case P
         of p1 then P1
         [] p2 then P2
         end
      end

      % Using the current State and an incoming message, calculate the next state
      fun {ConsumeMsg State Msg}
         state(board:_ player:CP again:_ moves:_) = State
         msg(player:RP move:M) = Msg
      in
         % First, check if the current player
         if RP == CP
         then {JudgeMove State M}
         else
            {ShowInfo "Player "#RP#" did not wait his/her turn!"}
            {EndGame CP}
            nil
         end
      end

      % Decide if the current move is valid and return a new state accordingly
      fun {JudgeMove State Move}
         state( board:OldBoard
                player:Player
                again:Again
                moves: ValidMoves
                ) = State

         % Helper method: Execute the move
         fun {DoMove}
            mv(f(Fr Fc) t(Tr Tc)) = Move
         in
            {ShowInfo "From ("#Fr#" "#Fc#") to ("#Tr#" "#Tc#")"}
            {Board.set Player Tr Tc {Board.set empty Fr Fc OldBoard}}
         end

         NextBoard
         NextMoves
         NextPlayer
         NextAgain
         NewSituation
         NoMoreMoves
      in
         if {Member Move ValidMoves.Player}
         then
            % The move is valid, change board and player
            NextBoard = {DoMove}
            NextPlayer = {Other Player}
            NextAgain = false
            NewSituation = {Board.analyse NextBoard}
            NextMoves = NewSituation.moves
            NoMoreMoves = {IsEmpty NextMoves.NextPlayer}

            if (NewSituation.finished.Player orelse NoMoreMoves)
            then {EndGame Player}
            end
         else
            % The move is invalid, check if this is the player's second chance
            if Again
            then {EndGame {Other Player}}
            else
               % Second chance: same board and player
               NextBoard = OldBoard
               NextPlayer = Player
               NextMoves = ValidMoves
               NextAgain = true
            end
         end
         % Send a request to the (new) player
         {Send {PortFor NextPlayer} request(board: NextBoard moves:NextMoves)}
         {Board.show NextBoard}
         state(board:NextBoard player:NextPlayer again:NextAgain moves:NextMoves)
      end

      % End the game and declare Player as the winner
      proc {EndGame Player}
         local Status = gameEnded(winner: Player)
         in
            {Send P1 Status}
            {Send P2 Status}
            {ShowInfo "Player "#Player#" has won!"}
            {Application.exit 0}
         end
      end

      % The initial board
      InitBoard = {Board.init Rows Cols}

      % The initial state
      situation(finished:_ moves:Moves) = {Board.analyse InitBoard}
      InitState = state( player:p1
                         board:InitBoard
                         again:false
                         moves:Moves
                         )

      % Start the referee thread with the initial state
      RP = {RefereePort InitState ConsumeMsg}
   in


      %  Send a request to player 1. The game is on.
      {Send P1 request(board: InitState.board moves:Moves)}
      ports({PlayerPort p1 RP} {PlayerPort p2 RP})
   end

   % Who is the opponent of P?
   fun {Other P}
      case P
      of p1 then p2
      [] p2 then p1
      end
   end

   /* Return a list of possible moves
    */
   fun {CalculateMoves Board}
      nil
   end


   /* Port which receives messages from both players and processes them while
    * keeping an internal (using FoldL).
    */
   fun {RefereePort InitialState Consumer}
      local Port
      in
         thread {FoldL Port Consumer InitialState _} end
         {NewPort Port}
      end
   end

   /* Create a port for a player (p1 or p2) to send messages to the referee
    * Messages sent to these ports are forwarded to the RefPort
    * with an identifier for the sender attached.
    */
   fun {PlayerPort Player RefPort}
      local Port
         proc {SendMsg Msg}
            {ShowInfo "Player "#Player#"'s message came trough"}
            {Send RefPort msg(player:Player move:Msg)}
         end
      in
         thread
            for M in Port do
               {SendMsg M}
            end
         end
         {NewPort Port}
      end
   end
end
