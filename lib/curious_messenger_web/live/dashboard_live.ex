defmodule CuriousMessengerWeb.DashboardLive do
  require Logger

  use CuriousMessengerWeb, :live_view
  use Phoenix.HTML

  alias CuriousMessenger.{Auth, Chat}
  alias CuriousMessenger.Chat.Conversation
  alias CuriousMessengerWeb.DashboardView
  alias CuriousMessenger.Repo
  alias Ecto.Changeset

  def mount(_params, %{"current_user" => current_user}, socket) do
    CuriousMessengerWeb.Endpoint.subscribe("user_conversations_#{current_user.id}")

    {:ok,
     socket
     |> assign(current_user: current_user)
     |> assign(title: nil)
     |> assign_new_conversation_changeset()
     |> assign_contacts(current_user)}
  end

  # Build a changeset for the newly created conversation, initially nesting a single conversation
  # member record - the current user - as the conversation's owner.
  #
  # We'll use the changeset to drive a form to be displayed in the rendered template.
  defp assign_new_conversation_changeset(socket) do
    changeset =
      %Conversation{}
      |> Conversation.changeset(%{
        "conversation_members" => [%{owner: true, user_id: socket.assigns[:current_user].id}]
      })

    assign(socket, :conversation_changeset, changeset)
  end

  # Assign all users as the contact list.
  defp assign_contacts(socket, _current_user) do
    users = Auth.list_auth_users()

    assign(socket, :contacts, users)
  end

  # Create a conversation based on the payload that comes from the form (matched as `conversation_form`).
  # If its title is blank, build a title based on the nicknames of conversation members.
  # Finally, reload the current user's `conversations` association, and re-assign it to the socket,
  # so the template will be re-rendered.
  def handle_event(
        "create_conversation",
        %{"conversation" => conversation_form},
        %{
          assigns: %{
            conversation_changeset: changeset,
            current_user: current_user,
            contacts: contacts
          }
        } = socket
      ) do
    title =
      if conversation_form["title"] == "" do
        build_title(changeset, contacts)
      else
        conversation_form["title"]
      end

    conversation_form = Map.put(conversation_form, "title", title)

    case Chat.create_conversation(conversation_form) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, err} ->
        Logger.error(inspect(err))
        {:noreply, socket}
    end
  end

  # Add a new member to the newly created conversation.
  # "user-id" is passed from the link's "phx_value_user_id" attribute.
  # Finally, assign the changeset containing the new member's definition to the socket,
  # so the template can be re-rendered.
  def handle_event(
        "add_member",
        %{"user-id" => new_member_id},
        %{assigns: %{conversation_changeset: changeset}} = socket
      ) do
    {:ok, new_member_id} = Ecto.Type.cast(:integer, new_member_id)

    old_members = socket.assigns[:conversation_changeset].changes.conversation_members
    existing_ids = old_members |> Enum.map(& &1.changes.user_id)

    cond do
      new_member_id not in existing_ids ->
        new_members = [%{user_id: new_member_id} | old_members]

        new_changeset = Changeset.put_change(changeset, :conversation_members, new_members)

        {:noreply, assign(socket, :conversation_changeset, new_changeset)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "update_form",
        %{"conversation" => %{"title" => title} = params},
        socket
      ) do
    IO.inspect(socket)

    if title != nil do
      {:noreply, assign(socket, :title, title)}
    else
      {:noreply, socket}
    end
  end

  # Remove a member from the newly create conversation and handle it similarly to
  # when a member is added.
  def handle_event(
        "remove_member",
        %{"user-id" => removed_member_id},
        %{assigns: %{conversation_changeset: changeset}} = socket
      ) do
    {:ok, removed_member_id} = Ecto.Type.cast(:integer, removed_member_id)

    old_members = socket.assigns[:conversation_changeset].changes.conversation_members
    new_members = old_members |> Enum.reject(&(&1.changes[:user_id] == removed_member_id))

    new_changeset = Changeset.put_change(changeset, :conversation_members, new_members)

    {:noreply, assign(socket, :conversation_changeset, new_changeset)}
  end

  def handle_event("restore_state", %{"form_data" => form_data}, socket) do
    # Decode form data sent from the pre-disconnect form
    decoded_form_data = Plug.Conn.Query.decode(form_data)

    # Since the new LiveView has already run the mount function, we have the changeset assigned
    %{assigns: %{conversation_changeset: changeset}} = socket

    # Now apply decoded form data to that changeset
    restored_changeset =
      changeset
      |> Conversation.changeset(decoded_form_data["conversation"])

    # Reassign the changeset, which will then trigger a re-render
    {:noreply, assign(socket, :conversation_changeset, restored_changeset)}
  end

  def handle_info(%{event: "new_conversation", payload: new_conversation}, socket) do
    user = socket.assigns[:current_user]
    annotated_conversation = new_conversation |> Map.put(:notify, true)

    user = %{
      user
      | conversations:
          (user.conversations |> Enum.map(&Map.delete(&1, :notify))) ++ [annotated_conversation]
    }

    {:noreply, assign(socket, :current_user, user)}
  end

  defp build_title(changeset, contacts) do
    user_ids = Enum.map(changeset.changes.conversation_members, & &1.changes.user_id)

    contacts
    |> Enum.filter(&(&1.id in user_ids))
    |> Enum.map(& &1.nickname)
    |> Enum.join(", ")
  end

  def remove_member_link(contacts, user_id, current_user_id) do
    nickname = contacts |> Enum.find(&(&1.id == user_id)) |> Map.get(:nickname)

    link("#{nickname} #{if user_id == current_user_id, do: "(me)", else: "✖"} ",
      to: "#!",
      phx_click: unless(user_id == current_user_id, do: "remove_member"),
      phx_value_user_id: user_id
    )
  end

  def add_member_link(user) do
    link(user.nickname,
      to: "#!",
      phx_click: "add_member",
      phx_value_user_id: user.id
    )
  end

  def contacts_except(contacts, current_user) do
    Enum.reject(contacts, &(&1.id == current_user.id))
  end

  def disable_create_button?(assigns) do
    Enum.count(assigns[:conversation_changeset].changes[:conversation_members]) < 2
  end
end
