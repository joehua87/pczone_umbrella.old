defmodule Pczone.Scraper.Shopee do
  @limit 100

  def get_product(product_code) do
    query =
      [
        product_id: product_code,
        version: "3.2.0",
        SPC_CDS: "bea52fe7-bcbf-48b6-8a3f-3e9ec6131070",
        SPC_CDS_VER: 2
      ]
      |> Enum.filter(fn {_k, v} -> !!v end)
      |> URI.encode_query()

    url = "https://banhang.shopee.vn/api/v3/product/get_product_detail/?#{query}"

    with {:ok, %{status: 200, body: body}} <-
           Finch.build(:get, url, headers()) |> Finch.request(MyFinch),
         {:ok, %{"error" => 0, "data" => _} = json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def get_all_order_ids() do
    {:ok,
     %{
       "data" => %{
         "page_info" => %{"page_size" => 40, "total" => total}
       }
     }} = get_order_ids()

    page_count = ceil(total / 40)

    1..page_count
    |> Enum.flat_map(fn page ->
      {:ok, %{"data" => %{"orders" => orders}}} = get_order_ids(page_number: page)
      orders
    end)
  end

  def get_order_ids(opts \\ []) do
    query =
      [
        page_number: Keyword.get(opts, :page_number, 1),
        sort_by: Keyword.get(opts, :sort_by, "create_date_desc")
      ]
      |> Enum.filter(fn {_k, v} -> !!v end)
      |> URI.encode_query()

    url = "https://banhang.shopee.vn/api/v3/order/get_order_id_list/?#{query}"

    with {:ok, %{status: 200, body: body}} <-
           Finch.build(:get, url, headers()) |> Finch.request(MyFinch),
         {:ok, %{"code" => 0, "data" => _} = json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def get_order(code) do
    query = URI.encode_query(order_id: code)
    url = "https://banhang.shopee.vn/api/v3/finance/get_one_order?#{query}"

    with {:ok, %{status: 200, body: body}} <-
           Finch.build(:get, url, headers()) |> Finch.request(MyFinch),
         {:ok, %{"code" => 0, "data" => _} = json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def parse_order(%{
        "data" => %{
          # "voucher_price": "100000.00",
          "comm_fee" => comm_fee,
          # "comm_fee": "92263.00",
          # "order_sn": "2211289RF474GC",
          "buyer_address_name" => buyer_address_name,
          # "item_count": _,
          # "paid_amount": "3747200.00",
          "create_time" => created_at,
          # "user_id": 69580817,
          "complete_time" => completed_at,
          "shipping_address" => buyer_address_address,
          # "buyer_paid_amount": "3790500.00",
          "payby_date" => paid_at,
          "order_items" => order_items,
          "card_txn_fee_info" => %{"card_txn_fee" => payment_fee},
          "shipping_fee" => shipment_fee,
          "total_price" => total_price,
          "delivery_time" => delivered_at,
          # "order_id": 123335515193868,
          "buyer_address_phone" => buyer_address_phone
          # "voucher_code": "STORDEC3X",
          # "actual_price": "3747200.00"
        }
      }) do
    # TODO: Get address region
    order = %{
      shipping_address: %Pczone.Address{
        full_name: buyer_address_name,
        address1: buyer_address_address,
        phone: buyer_address_phone
      },
      created_at: created_at,
      completed_at: completed_at,
      paid_at: paid_at,
      delivered_at: delivered_at,
      items: Enum.map(order_items, &parse_order_item/1),
      total: total_price,
      adjustments: [
        %{
          type: "commission",
          value: comm_fee
        },
        %{
          type: "payment",
          value: payment_fee
        },
        %{
          type: "shipment",
          value: shipment_fee
        }
      ]
    }
  end

  def parse_order_item(%{
        "amount" => quantity,
        # "comm_fee_rate"=> 2.,
        "item_id" => product_code,
        "item_model" => %{
          "model_id" => variant_code,
          "price" => price
        }
      }) do
    %{
      variant_id: variant_code,
      product_id: product_code,
      variant_code: variant_code,
      product_code: product_code,
      product_image: %{},
      product_name: "",
      variant_name: "",
      price: price,
      quantity: quantity
    }
  end

  def get_all_products(store_code, opts \\ []) do
    {:ok, %{"total_count" => total}} = get_products(store_code, limit: nil)
    page_count = ceil(total / @limit) - 1

    0..page_count
    |> Enum.flat_map(fn page ->
      {:ok, %{"items" => items}} = get_products(store_code, opts ++ [offset: page * @limit])
      items
    end)
  end

  def get_products(store_code, opts \\ []) do
    offset = Keyword.get(opts, :offset, 0)
    limit = Keyword.get(opts, :limit, @limit)
    sort_by = Keyword.get(opts, :sort_by, "sales")
    order = Keyword.get(opts, :order, "desc")
    filter_sold_out = Keyword.get(opts, :filter_sold_out)

    query =
      [
        shopid: store_code,
        limit: limit,
        offset: offset,
        sort_by: sort_by,
        order: order,
        filter_sold_out: filter_sold_out,
        SPC_CDS: "bea52fe7-bcbf-48b6-8a3f-3e9ec6131070",
        SPC_CDS_VER: 2
      ]
      |> Enum.filter(fn {_k, v} -> !!v end)
      |> URI.encode_query()

    url = "https://shopee.vn/api/v4/shop/search_items?#{query}"

    with {:ok, %{status: 200, body: body}} <- Finch.build(:get, url) |> Finch.request(MyFinch),
         {:ok, %{"error" => 0, "items" => _, "total_count" => _} = json} <- Jason.decode(body) do
      {:ok, json}
    end

    # "https://shopee.vn/api/v4/shop/search_items?filter_sold_out=1&limit=30&offset=0&order=desc&shopid=76922911&sort_by=sales"
  end

  def upload() do
    multipart =
      Multipart.new()
      |> Multipart.add_part(
        Multipart.Part.file_field("/Users/achilles/Documents/y/p_s/i7-9700F-1 copy 7.jpg", :file)
      )

    body_stream = Multipart.body_stream(multipart)
    content_length = Multipart.content_length(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")

    Finch.build(
      "POST",
      "https://banhang.shopee.vn/api/v3/general/upload_image/?SPC_CDS=390335cd-59a1-4b46-83b6-321743a4022b&SPC_CDS_VER=2",
      headers() ++
        [{"Content-Type", content_type}, {"Content-Length", to_string(content_length)}],
      {:stream, body_stream}
    )
    |> Finch.request(MyFinch)
  end

  defp headers() do
    [
      {"cookie", cookie()},
      {"authority", "banhang.shopee.vn"},
      {"user-agent",
       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"}
    ]
  end

  defp cookie() do
    "SC_DFP=GkAnuNLcYuJdZzcewd0C5l5BDyZ1tBtR; SPC_F=EN4GSjRdd5E2hdXm3qEpN3Wg5x3npc3F; REC_T_ID=0bbdfd1a-fd89-11ec-a034-2cea7fa8d770; SC_SSO=-; SC_SSO_U=-; _QPWSDCXHZQA=6daec688-f3f8-4ddf-a16a-ec681bd8443b; SPC_SC_SA_TK=; SPC_SC_SA_UD=; root_csrftoken=d5147444-deb7-4d33-b781-ddbfcdb05a4e; language=vi; __stripe_mid=5b0135f2-c512-489d-8c45-64dca10a2d5f5ee0c2; SPC_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; SPC_U=76924383; hccesp_lttk=AAAAAgAAAAAAAAAFAAAAAQAAAAeBwwi0wpEfjP8s665w+xNomwh1Vh3FtPFdxsbuIEsRAAAAAAAAAAAAAAAAQOy2sB4gJ/PJYkD4nlaU881Ge9El834u1w+x4C3ZFvsuLH9vIXl1LU08xxO8hsSyCpEYx7RdZBV48N9K4o2URgM=; SPC_SI=JLh0YwAAAABUWU9zR2ZMOahoIgEAAAAAeHJHTVdXMmg=; SPC_R_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_R_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; fulfillment-language=vi; SPC_SC_TK=158a6d6a2b54123de3b6f9f79a9e019e; SPC_SC_UD=76924383; SPC_ST=.RTZTanVwamM2ZDA4cUpyODXXIkk63OiD3k4fHgh5F14n2o3wDf8uWcICfCWtqbUruabJY4Z1BBf1iUj43J8LudeQ0h4B8uHCUdMHbyd/z3dzVOB22re+V/E2nidU/daD7gCbPWchI7az1wKbP5mC8xJsm/UcxhIQQP+zVV/oi2zzC8dVRD/LnLQRYDNlUj2PlqNEokejYDjnCz/v740l+w==; SPC_STK=/nGZ6f7cCXtCaCXAX2iugm+ZWHn4OMkbo461cE+YHkTVcV1v3iv74k2zKVqqodZHZQ0V4zWd4wOOC3DoW+O8vMp/HvrgbM2gkQBww0H74E9Ot/52RZqaFwVe2jS4zx2yFS9AfvZI4JzNkY3FUt3h/tE7s5R3SiF8dqqu4OZdX7o=; SPC_WST=OBIHq8M8xZMbf1kkOItMa52XAQ5pmQkEsmbdDAjPmeMaEWZ85lTVXPp99nmMW//BHi7wnsOVOazyihxh4gg1Q+fLh7w9bMXREEmHRJW1BS3qONE32yF2fWnSyrg+2mkQGEDmB9dl9jp2XHYHFqiSanujnUkPv0szpLkW0FE/hQc=; SPC_CDS=bea52fe7-bcbf-48b6-8a3f-3e9ec6131070; SPC_EC=ejZRa2hQUnFTWWR0SEJ1eub6z4eRMZ+vLOjg5jPWQGqeN4gtBBZxiJBSgs9g8BsRuQM+y9fuWBrMx7Ljwe6GUTqnwFIyRm1B6x5TiDJXdWY5fUnteW/yPNxDNTuz5VDKWe2CJ6s1xYUX4h9zjcc5Kk8nsXQ1hXJVaWoEEGF7U6A=; shopee_webUnique_ccd=SuFf5ow82jXoteQfPGf1Ow%3D%3D%7CForN4u%2BsYXC%2BCXvgD%2FPcgO%2FxQxvKoV2GFpUKxD4j1oaU0a%2FR9LhQzbDv3A%2F%2FFAKTbBYhbaI0%2BjICJqPxj1HH1rD55sq9GNvnkY31zQ%3D%3D%7CEa09MUhsvQOFLSvC%7C06%7C3"
  end
end
