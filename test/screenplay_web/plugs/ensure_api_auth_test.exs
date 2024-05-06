defmodule ScreenplayWeb.Plugs.EnsureApiAuthTest do
  use ScreenplayWeb.ConnCase

  describe "init/1" do
    test "passes options through unchanged" do
      assert ScreenplayWeb.Plugs.EnsureApiAuth.init([]) == []
    end
  end

  describe "call/2" do
    test "returns 403 when x-api-key header is missing", %{conn: conn} do
      conn = ScreenplayWeb.Plugs.EnsureApiAuth.call(conn, [])

      assert %{status: 403, halted: true, resp_body: "Invalid API key"} = conn
    end

    test "returns 403 when x-api-key does not match app API key", %{conn: conn} do
      conn =
        conn
        |> Plug.Conn.put_req_header("x-api-key", "1234")
        |> ScreenplayWeb.Plugs.EnsureApiAuth.call([])

      assert %{status: 403, halted: true, resp_body: "Invalid API key"} = conn
    end

    @tag :api_authenticated
    test "returns conn unchanged if x-api-key header matches app API key", %{conn: conn} do
      assert ScreenplayWeb.Plugs.EnsureApiAuth.call(conn, []) == conn
    end
  end
end
