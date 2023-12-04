defmodule ChatPrototypeWeb.ChatLiveTest do
  use ChatPrototypeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Mock

  alias ChatPrototype.Server
  alias ChatPrototype.Server.Room

  describe "index" do
    test "shows menu asking for user name", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Welcome to chat app!"
    end

    test "shows main room after submiting user name", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> form("#login_form", %{
               "user_name" => "Rui Fernandes"
             })
             |> render_submit() =~ "Feel free to join any of the rooms below"
    end

    test "joins a room from the main room", %{conn: conn} do
      with_mock Server,
        list_rooms: fn ->
          [
            %{uuid: "room-1", name: "Cars"},
            %{uuid: "room-2", name: "Football"},
            %{uuid: "room-3", name: "Surf"}
          ]
        end do
        {:ok, view, _html} = live(conn, "/")

        view
        |> form("#login_form", %{
          "user_name" => "Rui Fernandes"
        })
        |> render_submit()

        refute has_element?(view, "#menu-room-3", "Surf")

        result =
          view
          |> element("button", "Surf")
          |> render_click()

        assert result =~ "Surf (already joinned)"

        assert has_element?(view, "#menu-room-3", "Surf")
      end
    end

    test "shows a different chat room upon clicking the side menu button", %{conn: conn} do
      with_mocks [
        {Server, [],
         list_rooms: fn ->
           [
             %{uuid: "room-1", name: "Cars"},
             %{uuid: "room-2", name: "Football"},
             %{uuid: "room-3", name: "Surf"}
           ]
         end},
        {Room, [],
         get_messages: fn _room_name -> [%{uuid: "0", user: "TestUser", text: "Hello"}] end}
      ] do
        {:ok, view, _html} = live(conn, "/")

        view
        |> form("#login_form", %{
          "user_name" => "Rui Fernandes"
        })
        |> render_submit()

        assert has_element?(view, "#main-room")
        refute has_element?(view, "#chat-messages")
        refute has_element?(view, "#menu-room-3", "Surf")

        result =
          view
          |> element("button", "Surf")
          |> render_click()

        assert result =~ "Surf (already joinned)"

        assert has_element?(view, "#menu-room-3", "Surf")

        view
        |> element("#menu-room-3", "Surf")
        |> render_click()

        refute has_element?(view, "#main-room")
        assert has_element?(view, "#chat-messages", "TestUser - Hello")
      end
    end

    test "shows new incoming messages on the selected chat room", %{conn: conn} do
      with_mocks [
        {Server, [],
         list_rooms: fn ->
           [
             %{uuid: "room-1", name: "Cars"},
             %{uuid: "room-2", name: "Football"},
             %{uuid: "room-3", name: "Surf"}
           ]
         end},
        {Room, [],
         get_messages: fn _room_name -> [%{uuid: "0", user: "TestUser", text: "Hello."}] end}
      ] do
        {:ok, view, _html} = live(conn, "/")

        view
        |> form("#login_form", %{
          "user_name" => "Rui Fernandes"
        })
        |> render_submit()

        assert has_element?(view, "#main-room")
        refute has_element?(view, "#chat-messages")
        refute has_element?(view, "#menu-room-3", "Surf")

        result =
          view
          |> element("button", "Surf")
          |> render_click()

        assert result =~ "Surf (already joinned)"

        assert has_element?(view, "#menu-room-3", "Surf")

        view
        |> element("#menu-room-3", "Surf")
        |> render_click()

        refute has_element?(view, "#main-room")
        assert has_element?(view, "#chat-messages")

        ChatPrototypeWeb.Endpoint.broadcast("room-3", "new-message", %{
          uuid: UUID.uuid4(),
          user: "Test user",
          text: "testing message"
        })

        assert has_element?(view, "#chat-messages", "Test user - testing message")
      end
    end
  end
end
