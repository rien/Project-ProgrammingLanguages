functor
import
   Application
   Board
   System(showInfo:ShowInfo)
export
   refereeFor:RefereeFor
define
   /* RefereeFor
    *
    * Play a game on a board of the given Size,
    * between two player which can be communicated with trough the ports P1 and P2.
    * The function returns a tuple with two Ports: one for each player.
    */
   fun {RefereeFor P1 P2 Size}

      % Which port for whic player?
      fun {PortFor P}
         case P
         of p1 then P1
         [] p2 then P2
         end
      end

      % Using the current State and an incoming message, calculate the next state
      fun {ConsumeMsg OldState Msg}
         local
            state(board:B player:CP again:A) = OldState
            msg(player:RP move:M) = Msg
         in
            % First, check if the current player
            if RP == CP
            then {JudgeMove CP M B A}
            else
               {ShowInfo "Player "#RP#" did not wait his/her turn!"}
               {EndGame CP}
               nil
            end
         end
      end

      % Decide if the current move is valid and return a new state accordingly
      fun {JudgeMove Player Move OldBoard Again}
         % Helper method: Execute the move
         fun {DoMove}
            submitMove(f(Fr Fc) t(Tr Tc)) = Move
         in
            {Board.set Player Fr Fc {Board.set empty Tr Tc OldBoard}}
         end
         NextBoard
         NextPlayer
         NextAgain
      in
         if true %TODO valid move?
         then
            % The move is valid, change board and player
            NextBoard = {DoMove}
            NextPlayer = {Other Player}
            NextAgain = false

            % check if the make is ended
            if {GameIsEnded NextBoard}
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
               NextAgain = true
            end
         end
         % Send a request to the (new) player
         {Send {PortFor NextPlayer} moveRequest(board: NextBoard)}
         {Board.show NextBoard}
         state(board:NextBoard player:NextPlayer again:NextAgain)
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

      % The initial state
      InitState = state(player:p1 board:{Board.init Size} again:false)

      % Start the referee thread with the initial state
      RP = {RefereePort InitState ConsumeMsg}
   in
      {ShowInfo "Game started!"}
      %  Send a request to player 1. The game is on.
      {Send P1 moveRequest(board: InitState.board)}
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

   /* Check if the game is ended
    * There are two ways this can be achieved:
    * - One of the pawns reached the other side
    * - There are no moves possible
    */
   fun {GameIsEnded Board}
      false
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
