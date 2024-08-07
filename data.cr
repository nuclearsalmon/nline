module Nline
  alias Data = String | Hash(String, String)
  
  abstract class Nano(InT, OutT)
    protected property data : Data? = nil
    @data_mutex = Mutex.new

    private macro data_getter(suffix, data_type)
      protected def data_{{ suffix }} : {{ data_type }}
        data : Data = @data_mutex.synchronize {
          (@data ||= {{ data_type }}.new)
        }

        if data.is_a?({{ data_type }})
          data.as({{ data_type }})
        else
          raise (
            "Incorrect data type.\n" +
            "Expected #{{{ data_type }}}, " +
            "got #{ typeof(data) }")
        end
      end
    end

    data_getter s, String
    data_getter h, Hash(String, String)

    protected def reset : Nil
      @data = nil
    end
  end
end
