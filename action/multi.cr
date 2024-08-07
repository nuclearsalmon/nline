module Nline
  # collect events in any order, can be optional
  class NanoMultiAction(InT, RootOutT) < NanoRoot(InT, Bool)
    include DSL(InT, Bool, RootOutT)

    getter root : Nano(InT, RootOutT)
    @matched = Set(InT -> Bool).new

    def initialize(@root : Nano(InT, RootOutT), @optional : Bool)
    end

    def parse(event : InT) : Bool?
      @actions.each { |action|
        match = action.call(event)
        @matched << action if match
      }
      amount_matched = @matched.size
      if amount_matched == @actions.size
        yield true 
      elsif @optional
        yield true
      else
        yield false
      end
    end

    def reset
      super
      @matched.clear
    end
  end
end
