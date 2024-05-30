# frozen_string_literal: true

require_relative "column"

module Sheetah
  class Attribute
    def initialize(key:, type:)
      @key = key

      @type =
        case type
        when Hash
          CompositeType.new(**type)
        when Array
          CompositeType.new(composite: :array, scalars: type)
        else
          ScalarType.new(type)
        end
    end

    attr_reader :key, :type

    def each_column(config)
      return enum_for(:each_column, config) unless block_given?

      compiled_type = type.compile(config.types)

      type.each_column do |index, required|
        header, header_pattern = config.header(key, index)

        yield Column.new(
          key: key,
          type: compiled_type,
          index: index,
          header: header,
          header_pattern: header_pattern,
          required: required
        )
      end
    end

    def freeze
      type.freeze
      super
    end

    class Scalar
      def initialize(name)
        @required = name.end_with?("!")
        @name = (@required ? name.slice(0..-2) : name).to_sym
      end

      attr_reader :name, :required
    end

    class ScalarType
      def initialize(scalar)
        @scalar = Scalar.new(scalar)
      end

      def compile(container)
        container.scalar(@scalar.name)
      end

      def each_column
        return enum_for(:each_column) { 1 } unless block_given?

        yield nil, @scalar.required

        self
      end

      def freeze
        @scalar.freeze
        super
      end
    end

    class CompositeType
      def initialize(composite:, scalars:)
        @composite = composite
        @scalars = scalars.map { |scalar| Scalar.new(scalar) }
      end

      def compile(container)
        container.composite(@composite, @scalars.map(&:name))
      end

      def each_column
        return enum_for(:each_column) { @scalars.size } unless block_given?

        @scalars.each_with_index do |scalar, index|
          yield index, scalar.required
        end

        self
      end

      def freeze
        @scalars.freeze
        @scalars.each(&:freeze)
        super
      end
    end

    private_constant :Scalar, :ScalarType, :CompositeType
  end
end
