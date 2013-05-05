class PagseguroDecimalValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value.nil? || value =~ /^\d+\.\d{2}$/
      object.errors.add(attribute, error_message)
    end
  end

  def error_message
    " must be a decimal and have 2 digits after the dot"
  end
end
