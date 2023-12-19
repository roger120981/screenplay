defmodule ScreenplayWeb.ConfigController do
  use ScreenplayWeb, :controller

  alias ScreensConfig.Screen
  alias ScreensConfig.V2.GlEink
  alias Screenplay.Config.PermanentConfig
  alias Screenplay.ScreensConfig.Cache, as: ScreensConfigCache
  alias Screenplay.PendingScreensConfig.Cache, as: PendingScreensConfigCache

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def add(conn, %{"screen_id" => screen_id, "screen" => screen, "etag" => etag}) do
    case PermanentConfig.add_new_screen(screen_id, screen, etag) do
      :ok ->
        send_resp(conn, 200, "OK")

      {:error, :etag_mismatch} ->
        send_resp(conn, 400, "Config version mismatch")

      {:error, :config_not_fetched} ->
        send_resp(conn, 400, "S3 Operation Failed: Get")

      {:error, :config_not_written} ->
        send_resp(conn, 400, "S3 Operation Failed: Put")
    end
  end

  def delete(conn, %{"screen_id" => screen_id, "etag" => etag}) do
    case PermanentConfig.delete_screen(screen_id, etag) do
      :ok ->
        send_resp(conn, 200, "OK")

      {:error, :etag_mismatch} ->
        send_resp(conn, 400, "Config version mismatch")

      {:error, :config_not_fetched} ->
        send_resp(conn, 400, "S3 Operation Failed: Get")

      {:error, :config_not_written} ->
        send_resp(conn, 400, "S3 Operation Failed: Put")
    end
  end

  def existing_screens(conn, %{"place_id" => place_id, "app_id" => app_id}) do
    app_id_atom = String.to_existing_atom(app_id)

    filter_fn = fn
      {_, %Screen{app_id: ^app_id_atom} = config} ->
        place_id_has_screen?(place_id, String.to_existing_atom(app_id), config)

      _ ->
        false
    end

    live_screens = ScreensConfigCache.screens(&filter_fn.(&1))
    pending_screens = PendingScreensConfigCache.screens(&filter_fn.(&1))

    json(conn, %{live_screens: live_screens, pending_screens: pending_screens})
  end

  defp place_id_has_screen?(place_id, :gl_eink_v2, %Screen{
         app_params: %GlEink{footer: %{stop_id: stop_id}}
       }),
       do: place_id === stop_id

  defp place_id_has_screen?(place_id, app_id, _),
    do:
      raise("place_id_has_screen/2 not implemented for app_id: #{app_id}, place_id: #{place_id}")
end
