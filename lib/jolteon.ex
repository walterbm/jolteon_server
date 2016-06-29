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
    request = photon_request("/yellowLED")

    response = Poison.decode!(request.body)

    conn |> ok_response(
      %{
        led: "yellow",
        success: HTTPotion.Response.success?(request),
        response: response,
        on: response["return_value"]
      }
    )
  end

  get "/yellow_status" do
    request = photon_request("/LEDstatus")

    response = Poison.decode!(request.body)

    case response["return_value"] do
      1 ->
        conn |> ok_response(%{ led: "yellow", on: true})
      0 ->
        conn |> ok_response(%{ led: "yellow", on: false})
      _ ->
        conn |> ok_response(%{ response: response})
    end
  end

  post "ledstrip" do
    body = Map.take(conn.params, ["r", "g", "b", "activate"])

    cond do
      Map.has_key?(body,"activate") ->
        request = photon_request("/ls", body["activate"])
        response = Poison.decode!(request.body)
        conn |> ok_response(%{on: body["activate"], response: response})
      Map.keys(body) == ["b", "g", "r"] ->
        request = photon_request("/ls_rgb", Enum.join([body["r"],body["g"],body["b"]],","))
        response = Poison.decode!(request.body)
        conn |> ok_response(%{rgb: Enum.join([body["r"],body["g"],body["b"]],","), response: response})
      true ->
        conn |> ok_response(%{error: "fuck you"})
    end
  end

  post "test" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode! (%{ your_json: conn.params}))
  end

  match _ do
    send_resp(conn, 404, "Does Not Exist")
  end

  defp ok_response(conn, response) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp( 200, Poison.encode!(response) )
  end

  defp photon_request(endpoint) do
    HTTPotion.post "https://api.particle.io/v1/devices/#{System.get_env("PHOTON_ID")}#{endpoint}", [
      body:
        "access_token=" <> URI.encode_www_form(System.get_env("PHOTON_ACCESS_TOKEN")),
      headers: [ "Content-Type": "application/x-www-form-urlencoded" ]
    ]
  end

  defp photon_request(endpoint, params) do
    HTTPotion.post "https://api.particle.io/v1/devices/#{System.get_env("PHOTON_ID")}#{endpoint}", [
      body:
        "access_token=" <> URI.encode_www_form(System.get_env("PHOTON_ACCESS_TOKEN")) <>
        "&params=" <> URI.encode_www_form("#{params}"),
      headers: [ "Content-Type": "application/x-www-form-urlencoded" ]
    ]
  end

 end
