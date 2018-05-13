defmodule AlumniWeb.EventController do
  use AlumniWeb, :controller

  alias Alumni.Event
  alias Alumni.GoogleCalendar

  def list(conn, _params) do
    event_list =
      GoogleCalendar.get_events()
      |> Enum.map(&Event.to_json/1)

    json(conn, event_list)
  end
end
