require 'dentaku'

module Commands
  class Calculator
    def evaluate(data)
      expression = clean_input(data)
      calculate(expression)
    end

    private

    def clean_input(input)
      input.gsub(',', '.').gsub('=', '')
    end

    def calculate(expression)
      result = Dentaku::Calculator.new.evaluate(expression)
      return result.to_f.round(2)
    end
  end
end
