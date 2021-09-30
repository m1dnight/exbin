defmodule ExbinWeb.Plug.StaticFilesPipelineTest do
  # I don't like that this test is designed to test the entire pipeline,
  # including CustomLogo plug and NotFound plug, as well as any future
  # custom files things, however they're pretty inter-linked and we need
  # to be able to do all-up integration tests, so this seems like the
  # best way to do it.

  defmodule IfNoCustomLogoSet do
    use ExbinWeb.ConnCase, async: true

    describe "application layout" do
      test "sets correct logo path and dimensions if no custom logo path set", %{conn: conn} do
        conn = get(conn, "/")
        assert html_response(conn, 200) =~ "src=\"/images/logo.png\" width=\"30\" height=\"30\""
      end

      test "default logo is available", %{conn: conn} do
        # This test is here because it tests that our *normal* Plug.Static for assets is working correctly with the correct paths
        conn = get(conn, "/images/logo.png")
        assert {"content-type", "image/png"} in conn.resp_headers
      end
    end
  end

  defmodule WithCustomLogoSet do
    use ExbinWeb.ConnCase, async: false
    import Exbin.Factory

    setup do
      orig_custom_logo_path = Application.get_env(:exbin, :custom_logo_path)
      orig_custom_logo_size = Application.get_env(:exbin, :custom_logo_size)

      # Because the plug doesn't actually care about the file type we can use a
      # plain text file, which will be easier to validate.
      test_file = "/tmp/exbin_static_#{:rand.uniform()}/test_#{:rand.uniform()}.txt"
      File.mkdir!(Path.dirname(test_file))
      File.write!(test_file, "#{test_file}")
      Application.put_env(:exbin, :custom_logo_path, test_file)

      on_exit(fn ->
        Application.put_env(:exbin, :custom_logo_path, orig_custom_logo_path)
        Application.put_env(:exbin, :custom_logo_size, orig_custom_logo_size)
        File.rm!(test_file)
        File.rmdir!(Path.dirname(test_file))
      end)

      {:ok, test_file_path: test_file}
    end

    test "does not interfere with snippets starting with the string 'files'", %{conn: conn} do
      insert!(:snippet, %{name: "filesAreCool", content: "filesAreCool works great!"})
      conn = get(conn, "/filesAreCool")
      assert html_response(conn, 200) =~ "filesAreCool works great!"
    end

    test "properly sets custom logo path and dimensions in the layout", %{conn: conn} do
      r = :rand.uniform()
      s = Enum.random(10..50)
      Application.put_env(:exbin, :custom_logo_path, "/tmp/test_logo_filename_#{r}.png")
      Application.put_env(:exbin, :custom_logo_size, s)
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "src=\"/files/test_logo_filename_#{r}.png\" width=\"#{s}\" height=\"#{s}\""
    end

    test "correctly shows error if requested file not in static path", %{conn: conn} do
      conn = get(conn, "/files/definitely_not_a_file_#{:rand.uniform()}.not-a-png")
      assert text_response(conn, 404) == "File Not Found"
    end

    test "correctly serves file from static folder if proper path given", %{conn: conn, test_file_path: test_file} do
      conn = get(conn, "/files/#{Path.basename(test_file)}")

      assert conn.state == :file
      assert conn.status == 200
      assert conn.resp_body == test_file #The file is created with it's own path as the contents so that we can verify we've got the right one
    end
  end
end
