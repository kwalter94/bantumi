require "./board"

module Bantumi::Game
  enum Player
    North # Owns pits 7 to 13
    South # Owns pits 0 to 6
  end

  class GameState
    def initialize(@board : Board, @player : Player)
      @valid_moves : Hash(Int32, GameState)? = nil
    end

    def valid_moves : Array(Int32)
      find_valid_moves.keys
    end

    def transition(move : Int32) : GameState?
      find_valid_moves[move]
    end

    private def find_valid_moves : Hash(Int32, GameState)
      return @valid_moves if @valid_moves

      @valid_moves = potential_moves.each_with_object({} of Int32 => GameState) do |move, moves|
        state = simulate_move(move, @board, @player)
        next unless state

        moves[move] = state
      end
    end

    private def potential_moves : Array(Int32)
      player_attack_range.map { |i| @board[i] >= 1 }
    end

    private def player_attack_range : Range(Int32, Int32)
      return 0...Board::SOUTH_STORE if @player == Player::South

      (Board::SOUTH_STORE + 1)...Board::NORTH_STORE
    end

    private def simulate_move(move : Int32, board : Board, player : Player) : GameState
      board = board.dup
      counters_in_hand = board.take_all(move)
      position = move + 1

      while counters_in_hand > 0
        position = (position + 1) % Board::BOARD_SIZE if position == opponent_store

        board[position] += 1
        counters_in_hand -= 1

        if counters_in_hand == 0 && board[position] == 1 && position != player_store
          if player_attack_range.include?(position)
            board[player_store] += board.take_all(attack_position_reach(position))
          end

          board[player_store] += board.take_all(position)
        end

        position = (position + 1) % Board::BOARD_SIZE
      end

      if position != Board::NORTH_STORE && position != Board::SOUTH_STORE
        player = player == Player::South ? Player::North : Player::South
      end

      GameState.new(board: board, player: player)
    end

    private def player_store
      @player_store ||= @player == Player::South ? Board::SOUTH_STORE : Board::NORTH_STORE
    end

    private def opponent_store
      @opponent_store ||= @player == Player::South ? Board::NORTH_STORE : Board::SOUTH_STORE
    end

    private def attack_position_reach(position)
      (player_store + (player_store - position)) % Board::BOARD_SIZE
    end
  end
end
