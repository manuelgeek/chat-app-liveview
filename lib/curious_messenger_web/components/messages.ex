defmodule CuriousMessengerWeb.Components.Messages do
  @moduledoc false

  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="pb-20" id="conversation" phx-hook="ConversationHooks">
      <%= for message <- @messages do %>
        <div data-incoming={ if Map.get(message, :incoming), do: true, else: false  } class={ if message.user.id === @user.id, do: "text-right bg-green-100 justify-self-end my-3 rounded py-3 px-6", else: "text-left bg-blue-100 justify-self-end my-3 rounded py-3 px-6"}>
          <p class="text-2xl font-bold"><%= message.user.nickname %></p> <%= message.content %>
        </div>
      <% end %>
    </div>
    """
  end
end
