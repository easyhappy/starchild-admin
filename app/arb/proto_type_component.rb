class ProtoTypeComponent
end

class CreditAmountComponent < Arbre::Component
  builder_method :credit_amount

  def default_class_name
  end

  def tag_name
    "span"
  end

  def build(data, attributes = {})
    super(attributes)
    text_node number_to_currency(
                (
                  (data.is_a?(BigDecimal) ? data : data.to_decimal) / 10**6
                ).round(2),
                unit: ""
              ) + " (raw: #{data})"
  end
end

class PaperAmountComponent < Arbre::Component
  builder_method :paper_amount

  def default_class_name
  end

  def tag_name
    "span"
  end

  def build(data, attributes = {})
    super(attributes)
    text_node (
                (data.is_a?(BigDecimal) ? data : data.to_decimal) / 10**18
              ).round(2).to_s + " (raw: #{data})"
  end
end

class RoundAmountComponent < Arbre::Component
  builder_method :round_amount

  def default_class_name
  end

  def tag_name
    "span"
  end

  def build(data, attributes = {})
    super(attributes)

    case data
    when Internal::Decimal::DecimalMessage
      return text_node data.to_decimal.round(2)
    when BigDecimal, Float
      return text_node data.round(2)
    when String
      return text_node data.to_f.round(2)
    else
      text_node data
    end
  end
end


module ActiveAdmin
  module Views
    class TableFor < Arbre::HTML::Table
      def currency_column(*args, precision: 2, sortable: false)
        
        options = default_options.merge(args.extract_options!)
        title = args[0]
        data = args[1] || args[0]


        b = lambda do |i|
          if i.is_a?(Hash)
              number_to_currency(i[data].to_f.round(precision), unit: "", precision: precision)
          elsif i.send(data).is_a?(Internal::Decimal::DecimalMessage)
              number_to_currency(i.send(data).to_decimal.round(precision), unit: "", precision: precision)
          else
            number_to_currency(i.send(data), unit: "")
          end
        end

        options[:class] = "col-currency"
        options[:sortable] = sortable

        col = Column.new(title, data, @resource_class, options, &b)
        @columns << col

        # Build our header item
        within @header_row do
          build_table_header(col)
        end

        # Add a table cell for each item
        @collection.each_with_index do |resource, index|
          within @tbody.children[index] do
            build_table_cell col, resource
          end
        end
      end
    end
  end
end