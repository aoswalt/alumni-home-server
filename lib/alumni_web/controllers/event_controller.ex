defmodule AlumniWeb.EventController do
  use AlumniWeb, :controller

  @calendar_id Application.get_env(:alumni, :google)[:calendar_id]
  @events_url "https://www.googleapis.com/calendar/v3/calendars/#{@calendar_id}/events?maxResults=5"

  @jwt_claim_iss "alumni-calendar@nss-alumni.iam.gserviceaccount.com"
  @jwt_claim_scope "https://www.googleapis.com/auth/calendar.readonly"
  @jwt_claim_aud "https://www.googleapis.com/oauth2/v4/token"

  @private_key Application.get_env(:alumni, :google)[:private_key]

  @token_url "https://www.googleapis.com/oauth2/v4/token"
  @token_grant_type "urn:ietf:params:oauth:grant-type:jwt-bearer"

  def list(conn, _params) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    event_list =
      (@events_url <> "&timeMin=#{now}")
      |> HTTPoison.get!([{"Authorization", "Bearer #{get_token()}"}])
      |> Map.get(:body)
      |> Poison.decode!()
      |> Map.get("items")
      |> Enum.map(&reshape_event/1)

    json(conn, event_list)
  end

  defp reshape_event(event) do
    %{
      "startTime" => event["start"]["dateTime"],
      "endTime" => event["end"]["dateTime"],
      "name" => event["summary"],
      "description" => event["description"],
      "link" => event["htmlLink"]
    }
  end

  defp get_token() do
    body =
      {:form,
       [
         {"grant_type", @token_grant_type},
         {"assertion", make_jwt()}
       ]}

    @token_url
    |> HTTPoison.post!(body)
    |> Map.get(:body)
    |> Poison.decode!()
    |> Map.get("access_token")
  end

  defp make_jwt() do
    key = JOSE.JWK.from_pem(@private_key)

    %{
      iss: @jwt_claim_iss,
      scope: @jwt_claim_scope,
      aud: @jwt_claim_aud,
      exp: System.system_time(:seconds) + 3600,
      iat: System.system_time(:seconds)
    }
    |> Joken.token()
    |> Joken.sign(Joken.rs256(key))
    |> Joken.get_compact()
  end
end
