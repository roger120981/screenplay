defmodule Screenplay.PendingScreensConfig.Cache do
  @moduledoc """
  Functions to read data from a cached copy of the screens config.
  """

  alias ScreensConfig.Config

  use Screenplay.Cache.Client, table: :pending_screens_config

  @type table_contents :: list(table_entry)

  @type table_entry :: {{:screen, screen_id :: String.t()}, ScreensConfig.Screen.t()}

  def ok?, do: table_exists?()

  def disabled?(screen_id) do
    with_table default: false do
      case :ets.match(@table, {{:screen, screen_id}, %{disabled: :"$1"}}) do
        [[disabled]] -> disabled
        [] -> false
      end
    end
  end

  def screen(screen_id) do
    with_table default: nil do
      case :ets.match(@table, {{:screen, screen_id}, :"$1"}) do
        [[screen]] -> screen
        [] -> nil
      end
    end
  end

  def app_params(screen_id) do
    with_table default: nil do
      case :ets.match(@table, {{:screen, screen_id}, %{app_params: :"$1"}}) do
        [[app_params]] -> app_params
        [] -> nil
      end
    end
  end

  @doc """
  Returns a list of all screen IDs.
  """
  def screen_ids do
    with_table default: [] do
      @table
      |> :ets.match({{:screen, :"$1"}, :_})
      |> List.flatten()
    end
  end

  @doc """
  Returns a list of all screen configurations that satisfy the given filter.
  The filter function will be passed a tuple of {screen_id, screen_config} and should return true if that screen should be included in the results.
  """
  def screens(filter_fn) do
    with_table default: [] do
      filter_reducer = fn
        {{:screen, screen_id}, screen_config}, acc ->
          if filter_fn.({screen_id, screen_config}),
            do: [Map.put(screen_config, :id, screen_id) | acc],
            else: acc

        _, acc ->
          acc
      end

      :ets.foldl(filter_reducer, [], @table)
    end
  end

  @doc """
  Gets the full map of pending screen configurations.

  👉 WARNING: This function is expensive to run and returns a large amount of data.

  Unless you really need to get the entire map, try to use one of the other client functions, or define a new one
  that relies more on :ets.match / :ets.select to limit the size of data returned.
  """
  def pending_screens do
    with_table do
      match_screen_entries = {{:screen, :"$1"}, :"$2"}
      no_guards = []
      output_entry_as_screen_id_screen_config_tuple = [{{:"$1", :"$2"}}]

      match_spec = [
        {match_screen_entries, no_guards, output_entry_as_screen_id_screen_config_tuple}
      ]

      @table
      |> :ets.select(match_spec)
      |> Map.new()
    end
  end

  @doc """
  Gets the entire config struct.

  👉 WARNING: This function is expensive to run and returns a large amount of data.

  Unless you really need to get the entire config, try to use one of the other client functions, or define a new one
  that relies more on :ets.match / :ets.select to limit the size of data returned.
  """
  def config do
    case pending_screens() do
      pending_screens_map when is_map(pending_screens_map) ->
        %Config{screens: pending_screens_map}

      _ ->
        :error
    end
  end
end
