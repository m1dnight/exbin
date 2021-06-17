defmodule ExBinWeb.LayoutView do
  use ExBinWeb, :view

  def is_reader_view(conn = %Plug.Conn{path_info: path_info}) do
    List.first(path_info) == "reader"
  end
end
