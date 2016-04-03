module Hoge
  module Fuga
    class Piyo
      def initialize(name)
        @name = name
      end

      def hi
        puts "Hi, my name is #{@name}"
      end
    end
  end
end
