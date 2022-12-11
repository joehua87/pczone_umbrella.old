defmodule Pczone.GetRegions do
  alias Elixlsx.{Sheet, Workbook}

  def aggregate() do
    items =
      File.read!("/Users/achilles/Projects/pczone_umbrella/data/_provinces.json")
      |> Jason.decode!()
      |> Enum.flat_map(fn %{"id" => province_id, "division_name" => province_name} ->
        # %{id: id, name: name, level: 1}
        File.read!("/Users/achilles/Projects/pczone_umbrella/data/#{province_id}/_.json")
        |> Jason.decode!()
        |> Enum.flat_map(fn %{"id" => district_id, "division_name" => district_name} ->
          File.read!(
            "/Users/achilles/Projects/pczone_umbrella/data/#{province_id}/#{district_id}.json"
          )
          |> Jason.decode!()
          |> Enum.map(fn %{"id" => ward_id, "division_name" => ward_name} ->
            %{
              name: Enum.join([province_name, district_name, ward_name], ", "),
              province_id: "#{province_id}",
              province_name: province_name,
              district_id: "#{district_id}",
              district_name: district_name,
              ward_id: "#{ward_id}",
              ward_name: ward_name
            }
          end)
        end)
      end)

    headers = items |> List.first() |> Map.keys() |> Enum.map(&to_string/1)

    workbook = %Workbook{
      sheets: [%Sheet{name: "Sheet1", rows: [headers] ++ Enum.map(items, &Map.values/1)}]
    }

    Elixlsx.write_to(workbook, "/Users/achilles/Projects/pczone_umbrella/data/provinces.xlsx")

    File.write!(
      "/Users/achilles/Projects/pczone_umbrella/data/provinces.json",
      Jason.encode!(items)
    )
  end

  def get_all_districts() do
    File.read!("/Users/achilles/Projects/pczone_umbrella/data/_provinces.json")
    |> Jason.decode!()
    |> Enum.each(&get_districts(&1["id"]))
  end

  def get_all_wards() do
    File.read!("/Users/achilles/Projects/pczone_umbrella/data/_provinces.json")
    |> Jason.decode!()
    |> Enum.each(&get_all_wards(&1["id"]))
  end

  def get_all_wards(province_id) do
    File.read!("/Users/achilles/Projects/pczone_umbrella/data/#{province_id}/_.json")
    |> Jason.decode!()
    |> Enum.each(&get_wards(province_id, &1["id"]))
  end

  def get_wards(province_id, district_id) do
    output = "/Users/achilles/Projects/pczone_umbrella/data/#{province_id}/#{district_id}.json"
    output |> Path.dirname() |> File.mkdir_p!()

    with {:ok, %{status: 200, body: body}} <-
           Finch.build(
             "GET",
             "https://shopee.vn/api/v4/location/get_child_division_list?division_id=#{district_id}",
             headers()
           )
           |> Finch.request(MyFinch),
         {:ok, %{"data" => %{"divisions" => items}}} <- Jason.decode(body) do
      File.write(output, Jason.encode!(items))
    end
  end

  def get_districts(id) do
    output = "/Users/achilles/Projects/pczone_umbrella/data/#{id}/_.json"
    output |> Path.dirname() |> File.mkdir_p!()

    with {:ok, %{status: 200, body: body}} <-
           Finch.build(
             "GET",
             "https://shopee.vn/api/v4/location/get_child_division_list?division_id=#{id}",
             headers()
           )
           |> Finch.request(MyFinch),
         {:ok, %{"data" => %{"divisions" => items}}} <- Jason.decode(body) do
      File.write(output, Jason.encode!(items))
    end
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
    "SC_DFP=GkAnuNLcYuJdZzcewd0C5l5BDyZ1tBtR; SPC_F=EN4GSjRdd5E2hdXm3qEpN3Wg5x3npc3F; REC_T_ID=0bbdfd1a-fd89-11ec-a034-2cea7fa8d770; SC_SSO=-; SC_SSO_U=-; _QPWSDCXHZQA=6daec688-f3f8-4ddf-a16a-ec681bd8443b; SPC_SC_SA_TK=; SPC_SC_SA_UD=; root_csrftoken=d5147444-deb7-4d33-b781-ddbfcdb05a4e; language=vi; __stripe_mid=5b0135f2-c512-489d-8c45-64dca10a2d5f5ee0c2; SPC_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; SPC_U=76924383; hccesp_lttk=AAAAAgAAAAAAAAAFAAAAAQAAAAeBwwi0wpEfjP8s665w+xNomwh1Vh3FtPFdxsbuIEsRAAAAAAAAAAAAAAAAQOy2sB4gJ/PJYkD4nlaU881Ge9El834u1w+x4C3ZFvsuLH9vIXl1LU08xxO8hsSyCpEYx7RdZBV48N9K4o2URgM=; fulfillment-language=vi; SPC_SC_TK=158a6d6a2b54123de3b6f9f79a9e019e; SPC_SC_UD=76924383; SPC_ST=.RTZTanVwamM2ZDA4cUpyODXXIkk63OiD3k4fHgh5F14n2o3wDf8uWcICfCWtqbUruabJY4Z1BBf1iUj43J8LudeQ0h4B8uHCUdMHbyd/z3dzVOB22re+V/E2nidU/daD7gCbPWchI7az1wKbP5mC8xJsm/UcxhIQQP+zVV/oi2zzC8dVRD/LnLQRYDNlUj2PlqNEokejYDjnCz/v740l+w==; SPC_STK=/nGZ6f7cCXtCaCXAX2iugm+ZWHn4OMkbo461cE+YHkTVcV1v3iv74k2zKVqqodZHZQ0V4zWd4wOOC3DoW+O8vMp/HvrgbM2gkQBww0H74E9Ot/52RZqaFwVe2jS4zx2yFS9AfvZI4JzNkY3FUt3h/tE7s5R3SiF8dqqu4OZdX7o=; SPC_WST=OBIHq8M8xZMbf1kkOItMa52XAQ5pmQkEsmbdDAjPmeMaEWZ85lTVXPp99nmMW//BHi7wnsOVOazyihxh4gg1Q+fLh7w9bMXREEmHRJW1BS3qONE32yF2fWnSyrg+2mkQGEDmB9dl9jp2XHYHFqiSanujnUkPv0szpLkW0FE/hQc=; SPC_CDS=fb365954-18ee-458b-a82b-19dc0f34bc5e; SPC_SI=JLh0YwAAAABUWU9zR2ZMOahoIgEAAAAAeHJHTVdXMmg=; SPC_R_T_ID=M0pegA5+S6kjPZdB6hW+Zj26qUJ2+1WwZCHtWO4Tjp3KTGvm5e5ixNpCg3NxoOMoTA9m63AqeYdgAB2msf+feK0GDbebPwxHNo1zRSdkvhtvCo473247AYToBZxtqW06qmzgyEZi6TEQTrP13pzeJ8RYEOK744i8UTssMe4e0gs=; SPC_R_T_IV=WkRSRElBR2hBUUQ3ODBQSw==; shopee_webUnique_ccd=prxhW0os3Uogz9glVdM9hA==|FoXO4++sYXC+CXvgD/PcgO/xQxvKoV2GFpUKxD4j1oaU0a/R9LhQzbDv3A//FAKTbBYhbaI0+jICJqPxj1HF17n05Me9FdXnkY31zQ==|Ea09MUhsvQOFLSvC|06|3; SPC_EC=cVhwREVYNG9SOGQyNm1TMxrzw0Bq9pE8OU+hG81NR/YoaZdRT0H78mk7U2h2A+1HOAwR7utSDCEI06emj/xqfu5zYeXMHQJ5e8Ot9BqKwkS1WWUKdQrmYIBPNGXNybCme9ZNyA3pQ4hT25uExU6XCEYiNTFB3ijfM1Myee/kQz4="
  end
end
