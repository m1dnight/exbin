defmodule ExBinWeb.PageControllerTest do
  use ExBinWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "ExBin Development"
  end

end
