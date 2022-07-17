defmodule PczoneWeb.Schema.Common do
  use Absinthe.Schema.Notation

  enum :order_direction do
    value :asc
    value :asc_nulls_last
    value :asc_nulls_first
    value :desc
    value :desc_nulls_last
    value :desc_nulls_first
  end

  enum :order_field_type do
    value :integer
    value :decimal
    value :boolean
    value :time
    value :date
    value :datetime
  end

  enum :product_type do
    value :barebone
    value :motherboard
    value :processor
    value :memory
    value :gpu
    value :hard_drive
    value :psu
    value :chassis
  end

  object :attribute_item do
    field :label, non_null(:string)
    field :value, :string
  end

  object :attribute_group do
    field :title, non_null(:string)
    field :items, non_null(list_of(non_null(:attribute_item)))
  end

  input_object :order_by_input do
    field :field, non_null(:string)
    field :direction, non_null(:order_direction)
    @desc "Use for order field in entry_integer_value, entry_decimal_value & friends"
    field :field_type, :order_field_type
  end

  input_object :paging_input do
    field :page, :integer
    field :page_size, :integer
  end

  object :paging do
    field :page, non_null(:integer)
    field :page_size, non_null(:integer)
    field :total_entities, non_null(:integer)
    field :total_pages, non_null(:integer)
  end

  object :seo do
    field :title, :string
    field :description, :string
    field :keywords, list_of(non_null(:string))
    field :meta, :json
  end

  input_object :seo_input do
    field :title, :string
    field :description, :string
    field :keywords, list_of(non_null(:string))
  end

  input_object :boolean_filter_input do
    field :eq, :boolean
    field :neq, :boolean
  end

  input_object :id_filter_input do
    field :eq, :id
    field :neq, :id
    field :in, list_of(non_null(:id))
    field :nin, list_of(non_null(:id))
  end

  input_object :array_string_filter_input do
    field :any, list_of(non_null(:id))
    field :all, list_of(non_null(:id))
  end

  input_object :string_filter_input do
    field :eq, :string
    field :neq, :string
    field :in, list_of(non_null(:string))
    field :like, :string
    field :ilike, :string
  end

  input_object :path_filter_input do
    field :eq, list_of(non_null(:string))
    field :in, list_of(non_null(:string))
    field :match, :string
  end

  input_object :integer_filter_input do
    field :eq, :integer
    field :neq, :integer
    field :lt, :integer
    field :gt, :integer
    field :lte, :integer
    field :gte, :integer
    field :in, list_of(non_null(:integer))
  end

  input_object :float_filter_input do
    field :eq, :float
    field :neq, :float
    field :lt, :float
    field :gt, :float
    field :lte, :float
    field :gte, :float
    field :in, list_of(non_null(:float))
  end

  input_object :decimal_filter_input do
    field :eq, :decimal
    field :neq, :decimal
    field :lt, :decimal
    field :gt, :decimal
    field :lte, :decimal
    field :gte, :decimal
    field :in, list_of(non_null(:decimal))
  end

  input_object :date_filter_input do
    field :eq, :date
    field :neq, :date
    field :lt, :date
    field :gt, :date
    field :lte, :date
    field :gte, :date
  end

  input_object :datetime_filter_input do
    field :eq, :datetime
    field :neq, :datetime
    field :lt, :datetime
    field :gt, :datetime
    field :lte, :datetime
    field :gte, :datetime
  end

  input_object :fulltext_filter_input do
    field :websearch, :string
    # field :phrase, :string
    # field :plain, :string
  end
end
