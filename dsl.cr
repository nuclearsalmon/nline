require "./action/search"

module Nline
  module DSL(InT, OutT, RootOutT)
    # accept pattern, but don't do any processing on it
    def accept(pattern : Regex) : Nil
      register { |event| !(pattern.match(event.data).nil?) }
    end

    # FIXME: use args and kwards, inherit documentation from nanosearchaction
    def on(
        pattern : Regex, 
        optional : Bool = false,
        sequential : Bool = false,
        return_block : Bool = false,
        &block : (Nano(InT, OutT), Regex::MatchData, InT) -> Nil) : Nil
      instance = NanoSearchAction(InT, RootOutT).new(
        root: self.root,
        pattern: pattern, 
        optional: optional,
        sequential: sequential,
        return_block: return_block,
        &block)
      register { |event| instance.parse(event) }
    end

    # match zero to many times
    def zero_to_many(&) : Nil
      instance = NanoMultiAction(InT, OutT).new(self.root, optional: true)
      with instance yield
      register { |event| instance.parse(event) { |x| x } }
    end

    # match one to many times
    def one_to_many(&) : Nil
      instance = NanoMultiAction(InT, OutT).new(self.root, optional: false)
      with instance yield
      register { |event| instance.parse(event) { |x| x } }
    end
  end
end
