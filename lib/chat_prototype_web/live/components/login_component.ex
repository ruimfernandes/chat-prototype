defmodule ChatPrototypeWeb.LoginComponent do
  use ChatPrototypeWeb, :html

  @spec render_login(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render_login(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Welcome to chat</p>

      <.simple_form id="login_form" class="mt-40" for={@form} phx-submit="sign_in">
        <b>Please set your username</b>
        <p>User name: <.input field={@form["user_name"]} value={@form.params["user_name"]} /></p>
        <.button>Sign in</.button>
      </.simple_form>
    </div>
    """
  end
end
