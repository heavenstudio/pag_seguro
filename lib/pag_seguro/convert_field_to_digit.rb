module PagSeguro
  module ConvertFieldToDigit
    def attr_reader_as_digit(*fields)
      fields.each do |field|
        define_method(field) do
          begin
            "%.2f" % instance_variable_get("@#{field}")
          rescue ArgumentError, TypeError
            instance_variable_get("@#{field}")
          end
        end
      end
    end
  end
end