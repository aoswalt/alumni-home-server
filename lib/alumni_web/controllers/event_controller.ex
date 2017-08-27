defmodule AlumniWeb.EventController do
  use AlumniWeb, :controller

  @calendar_id "test"
  @events_url "https://www_googleapis.com/calendar/v3/calendars/#{@calendar_id}/events?maxResults=5"

  def list(conn, _params) do
    now = DateTime.utc_now() |> DateTime.to_iso8601

    @events_url <> "&timeMin=#{now}"
    |> HTTPoison.get!
    |> IO.inspect
    |> (&json(conn, &1)).()
  end
end
