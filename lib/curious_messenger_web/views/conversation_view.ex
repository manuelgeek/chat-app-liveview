defmodule CuriousMessengerWeb.ConversationView do
  use CuriousMessengerWeb, :view

  alias CuriousMessengerWeb.Components.Messages

  def avatar(assigns) do
    ~H"""
    <div class="text-4xl text-blue-500">
      <b>User name:</b> <%= @user.nickname %>
    </div>
    """
  end
end
