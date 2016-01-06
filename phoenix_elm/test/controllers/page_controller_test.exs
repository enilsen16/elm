defmodule PhoenixElm.PageControllerTest do
  use PhoenixElm.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "<div id=\"elm-main\"></div>"
  end
end
