defmodule Screenplay.Alerts.Alert do
  @moduledoc """
  Represents a single Outfront Takeover Alert.
  """

  @enforce_keys [:message, :stations, :schedule]
  defstruct [:id] ++ @enforce_keys

  @type id :: non_neg_integer() | nil

  @type canned_message :: %{
          type: :canned,
          id: String.t()
        }

  @type custom_message :: %{
          type: :custom,
          text: String.t()
        }

  @type station :: String.t()

  @type schedule :: %{
          start: DateTime.t() | nil,
          end: DateTime.t() | nil
        }

  @type t :: %__MODULE__{
          id: id(),
          message: canned_message() | custom_message(),
          stations: list(station()),
          schedule: schedule()
        }

  @spec to_json(t()) :: map()
  def to_json(%__MODULE__{id: id, message: message, stations: stations, schedule: schedule}) do
    %{
      "id" => id,
      "message" => message_to_json(message),
      "stations" => stations_to_json(stations),
      "schedule" => schedule_to_json(schedule)
    }
  end

  @spec from_json(map()) :: t()
  def from_json(%{
        "id" => id,
        "message" => message_json,
        "stations" => stations_json,
        "schedule" => schedule_json
      }) do
    %__MODULE__{
      id: id,
      message: message_from_json(message_json),
      stations: stations_from_json(stations_json),
      schedule: schedule_from_json(schedule_json)
    }
  end

  defp message_to_json(%{type: :canned, id: id}) do
    %{"type" => "canned", "id" => id}
  end

  defp message_to_json(%{type: :custom, text: text}) do
    %{"type" => "custom", "text" => text}
  end

  defp message_from_json(%{"type" => "canned", "id" => id}) do
    %{type: :canned, id: id}
  end

  defp message_from_json(%{"type" => "custom", "text" => text}) do
    %{type: :custom, text: text}
  end

  defp station_to_json(station), do: station

  defp station_from_json(station), do: station

  defp stations_to_json(stations) do
    Enum.map(stations, &station_to_json/1)
  end

  defp stations_from_json(stations_json) do
    Enum.map(stations_json, &station_from_json/1)
  end

  defp schedule_to_json(%{start: start_dt, end: end_dt}) do
    %{"start" => serialize_datetime(start_dt), "end" => serialize_datetime(end_dt)}
  end

  defp schedule_from_json(%{"start" => start_json, "end" => end_json}) do
    %{start: parse_datetime(start_json), end: parse_datetime(end_json)}
  end

  defp serialize_datetime(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp serialize_datetime(nil), do: nil

  defp parse_datetime(nil), do: nil

  defp parse_datetime(json) do
    {:ok, dt, _offset} = DateTime.from_iso8601(json)
    dt
  end
end
