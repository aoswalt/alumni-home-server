defmodule Alumni.Meetup do
  alias Alumni.Event

  @api_key Application.get_env(:alumni, :meetup)[:api_key]
  @events_url "https://api.meetup.com/NSS-Alumni-Association/events?key=#{@api_key}"

  def get_events() do
    @events_url
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
    |> Enum.map(&to_event/1)
  end

  def to_event(%{
        "time" => time,
        "duration" => duration,
        "name" => name,
        "description" => description,
        "link" => link
      }) do
    start_time =
      time
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.to_iso8601()

    end_time =
      (time + duration)
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.to_iso8601()

    %Event{
      start_time: start_time,
      end_time: end_time,
      name: name,
      description: description,
      link: link
    }
  end
end
