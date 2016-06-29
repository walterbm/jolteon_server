defmodule Jolteon do
  require IEx

  use Application
  use Plug.Router
  alias Plug.Adapters.Cowboy

  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def start( _type, _args ), do: start

  def start do
    Cowboy.http Jolteon, [], port: 4000
  end

  def stop do
    Cowboy.shutdown Jolteon.HTTP
  end

  get "/yellow" do
    request = HTTPotion.post "https://api.particle.io/v1/devices/#{System.get_env("PHOTON_ID")}/yellowLED", [
      body:
        "access_token=" <> URI.encode_www_form(System.get_env("PHOTON_ACCESS_TOKEN")),
      headers: [ "Content-Type": "application/x-www-form-urlencoded" ]
    ]

    response = Poison.decode!(request.body)

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode! (
         %{
           led: "yellow",
           success: HTTPotion.Response.success?(request),
           response: response,
           on: response["return_value"]
         }
       ))
  end

   get "/yellow_status" do
     request = HTTPotion.post "https://api.particle.io/v1/devices/#{System.get_env("PHOTON_ID")}/LEDstatus", [
      body:
        "access_token=" <> URI.encode_www_form(System.get_env("PHOTON_ACCESS_TOKEN")),
      headers: [ "Content-Type": "application/x-www-form-urlencoded" ]
    ]

    response = Poison.decode!(request.body)

    case response["return_value"] do
      1 ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode! (%{ led: "yellow", on: true}))

      0 ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode! (%{ led: "yellow", on: false}))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode! (%{ response: response}))
    end
  end

  post "ledstrip" do
    body = Map.take(conn.params, ["r", "g", "b", "activate"])
    led_commands(conn, to_keyword_list(body))
  end

  post "test" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode! (%{ your_json: conn.params}))
  end


  match _ do
    send_resp(conn, 404, "Does Not Exist")
  end

  defp to_keyword_list(map) do
    Enum.map(map, fn({key, value}) -> {String.to_atom(key), value} end)
  end

  defp led_commands(conn, commands) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode! (%{ response: "lol"}))
  end
 end
