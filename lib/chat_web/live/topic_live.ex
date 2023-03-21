defmodule ChatWeb.TopicLive do
  use ChatWeb, :live_view
  require Logger

  def mount(params = %{"topic_name" => topic_name}, _session, socket) do
    username = AnonymousNameGenerator.generate_random()
    # external resource for random names

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic_name)
      ChatWeb.Presence.track(self(), topic_name, username, %{})
    end

    # subscribing the LiveView process to a PubSub topic and tracking the user's presence on that topic. This is an important step in enabling real-time communication between the server and the client, as it allows the server to send messages to the LiveView process when new data becomes available.

    {:ok,
     assign(socket,
       topic_name: topic_name,
       users_online: [],
       username: username,
       message: "",
       chat_messages: [],
       temporary_assigns: [chat_messages: []]
     )}
  end

  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message_data = %{msg: message, username: socket.assigns.username, uuid: UUID.uuid1()}

    ChatWeb.Endpoint.broadcast(socket.assigns.topic_name, "new_message", message_data)
    {:noreply, assign(socket, message: "")}

    # The ChatWeb.Endpoint.broadcast/3 function is used to broadcast the message. The first argument to this function is the name of the topic to which the message should be broadcasted. In this case, the name of the topic is socket.assigns.topic_name, which is a string that represents the name of the topic. The second argument is the name of the event, which is new_message in this case. The third argument is the actual data of the message, which is message_data.

    # When the message is broadcasted to all clients subscribed to the specified topic, Phoenix LiveView will handle the message and update the view accordingly.

    # The code block then returns a tuple with two elements. The first element is the atom :noreply, which indicates that no reply needs to be sent to the client. The second element is a new socket with the message field in its assigns map set to an empty string. This is done to clear the message field in the LiveView form after the message has been sent.
  end

  def handle_event("message_change", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  def handle_info(%{event: "new_message", payload: message_data}, socket) do
    Logger.info(chat_messages: socket.assigns.chat_messages)

    {:noreply, assign(socket, chat_messages: [message_data])}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    users_online = ChatWeb.Presence.list(socket.assigns.topic_name) |> Map.keys()
    Logger.info(presence_diff: users_online)
    {:noreply, assign(socket, users_online: users_online)}
  end

  def user_msg_heex(assigns = %{msg_data: %{msg: msg, username: username, uuid: uuid}, me: me}) do
    ~H"""
    <li
      id={uuid}
      class={"relative #{if username == me, do: "bg-grey ml-40", else: "bg-green-300 mr-40"} mb-2 py-5 px-4 border rounded-xl"}
    >
      <div class="flex justify-between space-x-3">
        <div class="min-w-0 flex-1">
          <a href="#" class="block focus:outline-none">
            <span class="absolute inset-0" aria-hidden="true"></span>
            <p class="truncate text-sm font-medium text-gray-900 mb-4"><%= username %></p>
          </a>
        </div>
      </div>
      <div class="mt-1">
        <p class="text-sm text-gray-600 line-clamp-2"><%= msg %></p>
      </div>
    </li>
    """
  end
end
