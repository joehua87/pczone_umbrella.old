defmodule Pczone.Scraper.Shopee do
  @limit 100
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
        filter_sold_out: filter_sold_out
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
      {"user-agent",
       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"}
    ]
  end

  defp cookie() do
    "SC_DFP=GkAnuNLcYuJdZzcewd0C5l5BDyZ1tBtR; SPC_F=EN4GSjRdd5E2hdXm3qEpN3Wg5x3npc3F; REC_T_ID=0bbdfd1a-fd89-11ec-a034-2cea7fa8d770; SC_SSO=-; SC_SSO_U=-; _QPWSDCXHZQA=6daec688-f3f8-4ddf-a16a-ec681bd8443b; SPC_SC_SA_TK=; SPC_SC_SA_UD=; root_csrftoken=d5147444-deb7-4d33-b781-ddbfcdb05a4e; fulfillment-language=vi; language=vi; __stripe_mid=5b0135f2-c512-489d-8c45-64dca10a2d5f5ee0c2; SPC_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; SPC_U=76924383; SPC_CDS=390335cd-59a1-4b46-83b6-321743a4022b; SPC_SC_TK=85bdf1b6bb4cf6f25c9d2fe3c05de078; SPC_SC_UD=76924383; SPC_ST=.NVNvcENyNnBoRHJ3T1NrWNmrffsBHrMxkKSMO2GlyKGh/FfKAaduavQbvOYPY6KQ1jwOBrngWGEg0Go/KbM5kzak94G7QHpCXBfuDvBDIiex706CaNicei5SULcSZ7bA685TpDU2BmWWW6VVQB2MjC51t9T2F6dxI+GWSts/szbIuv5JthFMnwLratkIkat01AACS57BPcjHuwc8LRrSJQ==; SPC_STK=dxy+jPFxo3ZPiU7ARYbvvUXw0zy/UYlSczQXBYs6aGOz5NiQFJexlMYYPkh2Ih6V7elDRfzBQh+VZUEx0IavP34Im1x0f6W4jza2IH9AIfSSnLduHNJRNw+MTS+FLy2/H+0vqjp5VXFk84WI8O92IQ5CMtR6NSN/NhbesmAUZUI=; SPC_WST=vfiYOy9RPYyYJvLoXuDQbxTnU8t07AuXWrOFICSOX4EyiiVdTm3eJDPqZe6RwlAhBQlEJGz1n8DS2fr9m0nna/t5cgToYo9YbLatuAsLtvXrPp/3EtCl/tPollz+vXNg56nIA62Zte2RPtfc/t5Rbmw82+k1U7wz5UxThN3Y0As=; hccesp_lttk=AAAAAgAAAAAAAAAFAAAAAQAAAAeBwwi0wpEfjP8s665w+xNomwh1Vh3FtPFdxsbuIEsRAAAAAAAAAAAAAAAAQOy2sB4gJ/PJYkD4nlaU881Ge9El834u1w+x4C3ZFvsuLH9vIXl1LU08xxO8hsSyCpEYx7RdZBV48N9K4o2URgM=; SPC_SI=JLh0YwAAAABUWU9zR2ZMOahoIgEAAAAAeHJHTVdXMmg=; SPC_R_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_R_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; SPC_EC=OWFZa1hWN1JJNzd1eTVyYQdCE718PDaE75uOKkfSfJFKbFNkO8yeVKsP0/4vGjmEJDmBu5t7L6+UDh2IEoep2OLIvhiAl/8JwnDmC2uCkl3qzxa5TaogpMyCyuEgajTBnx4kBEGQjUr4ySwRRn7HttO1q8L5jfcK2CSBpDfAQzg=; shopee_webUnique_ccd=xHjuFFzPvjOJxiIrEgmm3A%3D%3D%7CFovN4u%2BsYXC%2BCXvgD%2FPcgO%2FxQxvKoV2GFpUKxD4j1oaU0a%2FR9LhQzbDv3A%2F%2FFAKTbBYhbaI0%2BjICJqPxjljE1L%2F15MawFNjnkY31zQ%3D%3D%7CEa09MUhsvQOFLSvC%7C06%7C3"
  end
end
