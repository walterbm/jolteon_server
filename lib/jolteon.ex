defmodule Jolteon do
  require IEx

  use Application
  use Plug.Router
  alias Plug.Adapters.Cowboy

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

  match _ do
    send_resp(conn, 404, "Does Not Exist")
  end
 end

