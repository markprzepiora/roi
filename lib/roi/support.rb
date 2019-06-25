# typed: false
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

    if !Hash.instance_methods.include?(:dig)
      def dig(head, *rest)
        [head, *rest].reduce(self) do |value, accessor|
          next_value =
            case value
            when ::Array
              value.at(accessor)
            when ::Hash
              value[accessor]
            when ::Struct
              value[accessor] if value.members.include?(accessor)
            else
              begin
                break value.dig(*rest)
              rescue NoMethodError
                raise TypeError, "#{value.class} does not have a #dig method"
              end
            end

          break nil if next_value.nil?
          next_value
        end
      end
    end
  end

  refine Array do
    if !Array.instance_methods.include?(:to_h)
      def to_h
        Hash[*flatten(1)]
      end
    end

    if !Array.instance_methods.include?(:dig)
      def dig(head, *rest)
        [head, *rest].reduce(self) do |value, accessor|
          next_value =
            case value
            when ::Array
              value.at(accessor)
            when ::Hash
              value[accessor]
            when ::Struct
              value[accessor] if value.members.include?(accessor)
            else
              begin
                break value.dig(*rest)
              rescue NoMethodError
                raise TypeError, "#{value.class} does not have a #dig method"
              end
            end

          break nil if next_value.nil?
          next_value
        end
      end
    end
  end

  refine Struct do
    if !Struct.instance_methods.include?(:dig)
      def dig(head, *rest)
        [head, *rest].reduce(self) do |value, accessor|
          next_value =
            case value
            when ::Array
              value.at(accessor)
            when ::Hash
              value[accessor]
            when ::Struct
              value[accessor] if value.members.include?(accessor)
            else
              begin
                break value.dig(*rest)
              rescue NoMethodError
                raise TypeError, "#{value.class} does not have a #dig method"
              end
            end

          break nil if next_value.nil?
          next_value
        end
      end
    end
  end

  refine Regexp do
    def match?(string, pos = 0)
      !!match(string, pos)
    end unless //.respond_to?(:match?)
  end
end
