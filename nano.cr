require "./data"
require "./dsl"

module Nline
  abstract class Nano(InT, OutT)
    def root : self; self; end

    abstract def parse(event : InT) : OutT?

    def parse(event : InT, &) : OutT?
      yield parse(event)
    end

    protected def collect : OutT?; nil; end

    def collect_eof : OutT?; nil; end

    def collect_eof(&) : OutT?
      yield collect_eof
    end

    #macro finished  # hack, the compiler doesn't get it otherwise
    #  def parse(event : InT) : OutT?
    #    super
    #    #previous_def
    #  end
    #end
  end

  abstract class NanoRoot(InT, OutT) < Nano(InT, OutT)
    include DSL(InT, OutT, OutT)

    getter actions = [] of InT -> Bool?  # alias Action = InT -> Bool?

    macro inherited
      def self.new(*args, **kwargs, &)
        instance = self.class.new(*args, **kwargs)
        with instance yield instance
        instance
      end
    end

    protected def register(&action : InT -> Bool?) : Nil
      @actions << action
    end
  end

  abstract class NanoAll(InT, OutT) < NanoRoot(InT, OutT)
    def parse(event : InT, &) : OutT?
      yield collect if @actions.all? { |action| 
        result = action.call(event)
      }
    end
  end

  abstract class NanoAny(InT, OutT) < NanoRoot(InT, OutT)
    def parse(event : InT, &) : OutT?
      do_collect = false
      actions_it = @actions.each

      @actions.each { |action| 
        do_collect = true if action.call(event)
      }
      yield collect if do_collect
    end
  end

  # collect events in sequence order
  abstract class NanoSeq(InT, OutT) < NanoRoot(InT, OutT)
    @step = 0

    def parse(event : InT) : OutT?
      match = false
      locked_step = false
      @actions.each_with_index { |action, index|
        next unless index >= @step

        match = action.call(event)
        pp "match: #{match}"
        if match.nil?
          locked_step = true
        elsif match
          @step += 1 unless locked_step
        else
          @step = 0 unless locked_step
          break
        end
      }
      collect if match && !locked_step
    end
  end
end
