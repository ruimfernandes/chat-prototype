defmodule ChatPrototypeWeb.WelcomeLive do
  use ChatPrototypeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       stage: :welcome,
       user_name: "",
       form: to_form(%{user_name: ""})
     )}
  end

  def render(assigns) do
    case assigns.stage do
      :welcome ->
        render_welcome_menu(assigns)

      :rooms_list ->
        ~H"""
        <div>
          <.live_component
            module={ChatPrototypeWeb.RoomsListLive}
            id="rooms_list"
            user_name={assigns.user_name}
          />
        </div>
        """
    end
  end

  def render_welcome_menu(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Welcome to chat</p>

      <.simple_form class="mt-40" for={@form} phx-submit="sign_in">
        <b> Please set your username </b>
        <p>User name: <.input field={@form[:user_name]} value={@form.params.user_name} /></p>
        <.button>Sign in</.button>
      </.simple_form>
    </div>
    """
  end

  def handle_event("sign_in", %{"user_name" => user_name}, socket) do
    {:noreply,
     assign(socket,
       stage: :rooms_list,
       user_name: user_name
     )}
  end
end
