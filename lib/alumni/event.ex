defmodule Alumni.Event do
  alias __MODULE__

  defstruct [
    :start_time,
    :end_time,
    :name,
    :description,
    :link
  ]

  def to_json(%Event{
    start_time: start_time,
    end_time: end_time,
    name: name,
    description: description,
    link: link
  }) do
    %{
      "startTime" => start_time,
      "endTime" => end_time,
      "name" => name,
      "description" => description,
      "link" => link
    }
  end
end
