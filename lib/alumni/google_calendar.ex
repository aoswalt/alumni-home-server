defmodule Alumni.GoogleCalendar do
  alias Alumni.Event

  @calendar_id Application.get_env(:alumni, :google)[:calendar_id]
  @events_url "https://www.googleapis.com/calendar/v3/calendars/#{@calendar_id}/events?maxResults=5&singleEvents=true&orderBy=startTime"

  @jwt_claim_iss "alumni-calendar@nss-alumni.iam.gserviceaccount.com"
  @jwt_claim_scope "https://www.googleapis.com/auth/calendar.readonly"
  @jwt_claim_aud "https://www.googleapis.com/oauth2/v4/token"

  @private_key Application.get_env(:alumni, :google)[:private_key]

  @token_url "https://www.googleapis.com/oauth2/v4/token"
  @token_grant_type "urn:ietf:params:oauth:grant-type:jwt-bearer"

  def get_events() do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    (@events_url <> "&timeMin=#{now}")
    |> HTTPoison.get!([{"Authorization", "Bearer #{get_token()}"}])
    |> Map.get(:body)
    |> Poison.decode!()
    |> Map.get("items")
    |> Enum.map(&to_event/1)
  end

  defp to_event(event_response) do
    %Event{
      start_time: event_response["start"]["dateTime"],
      end_time: event_response["end"]["dateTime"],
      name: event_response["summary"],
      description: event_response["description"],
      link: event_response["htmlLink"]
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
