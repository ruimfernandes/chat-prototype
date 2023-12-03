defmodule ChatPrototypeWeb.LoginComponent do
  use ChatPrototypeWeb, :html

  @spec render_login(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render_login(assigns) do
    ~H"""
    <div class="bg-zinc-600 grow p-10 text-gray-100">
      <p class="text-4xl border-b-2">Welcome to this chat app!</p>

      <div class="mt-10 w-80">
        <.simple_form id="login_form" for={@form} phx-submit="sign_in">
          <b>Please set your username</b>
          <p>User name: <.input field={@form["user_name"]} value={@form.params["user_name"]} /></p>
          <.button>Sign in</.button>
        </.simple_form>
      </div>
    </div>
    """
  end
end
