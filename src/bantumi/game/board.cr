module Bantumi::Game
  alias Counters = Int32

  class InvalidPitConfiguration < Exception; end

  class Board
    INITIAL_PIT_CONFIGURATION = [4, 4, 4, 4, 4, 4, 0, 4, 4, 4, 4, 4, 4, 0]
    BOARD_SIZE = INITIAL_PIT_CONFIGURATION.size
    SOUTH_STORE = 0
    NORTH_STORE = BOARD_SIZE / 2

    def initialize(@pits : Array(Int32) = INITIAL_PIT_CONFIGURATION)
      validate_pits_configuration(pits)
    end

    def [](index) : Counters
      @pits[index]
    end

    def []=(index, value)
      @pits[index] = value
    end

    def take_all(index) : Counters
      if index == SOUTH_STORE || index == NORTH_STORE
        raise IndexError.new("Can not take from stores")
      end

      counters = @pits[index]
      @pits[index] = 0

      counters
    end

    def dup
      Board.new(@pits)
    end

    private def validate_pits_configuration()
      raise "Invalid pits configuration size" if @pits.size != BOARD_SIZE

      @pits.each_with_index do |counters, i|
        raise InvalidPitConfiguration.new("Invalid number of pits on ##{i}: #{counters}") if counters.negative?
      end
    end
  end
end
