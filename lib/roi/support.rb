require 'roi'

module Roi::Support
  refine Hash do
    if !Hash.instance_methods.include?(:slice)
      def slice(*keys)
        keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
        hash = self.class.new
        keys.each { |k| hash[k] = self[k] if has_key?(k) }
        hash
      end
    end
  end

  refine Regexp do
    def match?(string, pos = 0)
      !!match(string, pos)
    end unless //.respond_to?(:match?)
  end
end
