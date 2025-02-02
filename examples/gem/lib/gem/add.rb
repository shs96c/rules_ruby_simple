# frozen_string_literal: true

module GEM
  class Add # :nodoc:
    def initialize(a, b) # rubocop:disable Naming/MethodParameterName
      @a = a
      @b = b
    end

    def result
      @a + @b
    end
  end
end
