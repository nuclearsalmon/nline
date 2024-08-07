module Nline
  class NanoSearchAction(InT, RootOutT) < Nano(InT, Bool)
    getter root : Nano(InT, RootOutT)

    @matched_any = false

    def initialize(
        @root : Nano(InT, RootOutT),
        @pattern : Regex, 
        @optional : Bool,
        @sequential : Bool,
        @return_block : Bool,
        &block : (Nano(InT, RootOutT), Regex::MatchData, InT) -> Nil)
      @block = block
    end

    def parse(event : InT) : Bool?
      mdata = @pattern.match(event.data)
      if mdata.nil?
        @sequential ? (@optional ? true : @matched_any) : nil
      else
        result = @block.call(self.root, mdata, event)
        @return_block ? result : nil
      end
    end
  end
end
