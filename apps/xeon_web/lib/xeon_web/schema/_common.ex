defmodule XeonWeb.Schema.Common do
  use Absinthe.Schema.Notation

  enum :order_direction do
    value(:asc)
    value(:asc_nulls_last)
    value(:asc_nulls_first)
    value(:desc)
    value(:desc_nulls_last)
    value(:desc_nulls_first)
  end

  enum :order_field_type do
    value(:integer)
    value(:decimal)
    value(:boolean)
    value(:time)
    value(:date)
    value(:datetime)
  end

  enum(:field_value_type,
    values: [
      :boolean,
      :color_palette,
      :date,
      :datetime,
      :decimal,
      :entries,
      :entry,
      :enum_array,
      :enum,
      :images,
      :integer,
      :json,
      :string_array,
      :string,
      :taxon,
      :taxons,
      :time
    ]
  )

  enum(:body_type,
    values: [
      :md,
      :block
    ]
  )

  object :breadcrumb do
    field(:id, non_null(:id))
    field(:slug, non_null(:string))
    field(:title, non_null(:string))
    field(:path, non_null(:string))
    field(:lang, non_null(:string))
  end

  enum :currency do
    value(:usd, as: :USD)
    value(:vnd, as: :VND)
  end

  input_object :order_by_input do
    field(:field, non_null(:string))
    field(:direction, non_null(:order_direction))
    @desc "Use for order field in entry_integer_value, entry_decimal_value & friends"
    field(:field_type, :order_field_type)
  end

  input_object :paging_input do
    field(:page, :integer)
    field(:page_size, :integer)
  end

  object :field_value do
    field(:code, non_null(:string))
    field(:type, non_null(:field_value_type))
    field(:value, :json)
  end

  input_object :field_value_input do
    field(:code, non_null(:string))
    field(:type, non_null(:field_value_type))
    field(:value, :json)
  end

  object :address do
    field(:first_name, non_null(:string))
    field(:last_name, non_null(:string))
    field(:full_name, non_null(:string))
    field(:email, non_null(:string))
    field(:phone, non_null(:string))
    field(:address1, non_null(:string))
    field(:address2, :string)
    field(:zipcode, :string)
    field(:region_code, non_null(:string))
    field(:ward, non_null(:string))
    field(:district, non_null(:string))
    field(:province, non_null(:string))
    field(:region, non_null(:string))
  end

  input_object :address_input do
    field(:first_name, non_null(:string))
    field(:last_name, non_null(:string))
    field(:full_name, non_null(:string))
    field(:email, non_null(:string))
    field(:phone, non_null(:string))
    field(:address1, non_null(:string))
    field(:address2, :string)
    field(:zipcode, :string)
    field(:ward, non_null(:string))
    field(:district, non_null(:string))
    field(:province, non_null(:string))
    field(:region, non_null(:string))
    field(:region_code, non_null(:string))
  end

  object :tax_info do
    field(:name, non_null(:string))
    field(:tax_id, non_null(:string))
    field(:address, non_null(:string))
    field(:email, :string)
    field(:note, :string)
  end

  input_object :tax_info_input do
    field(:name, non_null(:string))
    field(:tax_id, non_null(:string))
    field(:address, non_null(:string))
    field(:email, :string)
    field(:note, :string)
  end

  object :paging do
    field(:page, non_null(:integer))
    field(:page_size, non_null(:integer))
    field(:total_entities, non_null(:integer))
    field(:total_pages, non_null(:integer))
  end

  object :heading do
    field(:title, :string)
    field(:subtitle, :string)
  end

  object :image_value do
    field(:id, non_null(:id))
    field(:title, :string)
    field(:alt, :string)
    field(:size, :decimal)
    field(:width, :decimal)
    field(:height, :decimal)
  end

  object :seo do
    field(:title, :string)
    field(:description, :string)
    field(:keywords, list_of(non_null(:string)))
    field(:meta, :json)
  end

  input_object :heading_input do
    field(:title, :string)
    field(:subtitle, :string)
  end

  input_object :seo_input do
    field(:title, :string)
    field(:description, :string)
    field(:keywords, list_of(non_null(:string)))
  end

  input_object :image_value_input do
    field(:id, non_null(:id))
    field(:title, :string)
    field(:alt, :string)
    field(:size, :decimal)
    field(:width, :decimal)
    field(:height, :decimal)
  end

  input_object :boolean_filter_input do
    field(:eq, :boolean)
    field(:neq, :boolean)
  end

  input_object :id_filter_input do
    field(:eq, :id)
    field(:neq, :id)
    field(:in, list_of(non_null(:id)))
    field(:nin, list_of(non_null(:id)))
  end

  input_object :array_string_filter_input do
    field(:any, list_of(non_null(:id)))
    field(:all, list_of(non_null(:id)))
  end

  input_object :string_filter_input do
    field(:eq, :string)
    field(:neq, :string)
    field(:in, list_of(non_null(:string)))
    field(:like, :string)
    field(:ilike, :string)
  end

  input_object :path_filter_input do
    field(:eq, list_of(non_null(:string)))
    field(:in, list_of(non_null(:string)))
    field(:match, :string)
  end

  input_object :integer_filter_input do
    field(:eq, :integer)
    field(:neq, :integer)
    field(:lt, :integer)
    field(:gt, :integer)
    field(:lte, :integer)
    field(:gte, :integer)
    field(:in, list_of(non_null(:integer)))
  end

  input_object :float_filter_input do
    field(:eq, :float)
    field(:neq, :float)
    field(:lt, :float)
    field(:gt, :float)
    field(:lte, :float)
    field(:gte, :float)
    field(:in, list_of(non_null(:float)))
  end

  input_object :decimal_filter_input do
    field(:eq, :decimal)
    field(:neq, :decimal)
    field(:lt, :decimal)
    field(:gt, :decimal)
    field(:lte, :decimal)
    field(:gte, :decimal)
    field(:in, list_of(non_null(:decimal)))
  end

  input_object :date_filter_input do
    field(:eq, :date)
    field(:neq, :date)
    field(:lt, :date)
    field(:gt, :date)
    field(:lte, :date)
    field(:gte, :date)
  end

  input_object :datetime_filter_input do
    field(:eq, :datetime)
    field(:neq, :datetime)
    field(:lt, :datetime)
    field(:gt, :datetime)
    field(:lte, :datetime)
    field(:gte, :datetime)
  end

  input_object :fulltext_filter_input do
    field(:websearch, :string)
    # field :phrase, :string
    # field :plain, :string
  end
end
