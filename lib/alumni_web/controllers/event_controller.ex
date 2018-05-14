defmodule AlumniWeb.EventController do
  use AlumniWeb, :controller

  alias Alumni.Event
  alias Alumni.GoogleCalendar
  alias Alumni.Meetup

  def list(conn, _params) do
    fetches = [
      Task.async(fn -> GoogleCalendar.get_events() end),
      Task.async(fn -> Meetup.get_events() end)
    ]

    event_list =
      fetches
      |> Task.yield_many()
      |> Enum.map(fn {_task, {:ok, data}} -> data end)
      |> Enum.concat()
      |> Enum.map(&Event.to_json/1)

    json(conn, event_list)
  end
end
