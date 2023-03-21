defmodule ChatWeb.HomeLive do
  use ChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}

    # The code inside the mount/3 function simply returns a tuple of {:ok, socket}. This tells Phoenix that the LiveView has been successfully mounted, and the socket parameter should be used as the initial state for the LiveView.
  end

  def handle_event("goto_topic", %{"changeset" => %{"topic_name" => topic_name}}, socket) do
    topic_link = "/" <> topic_name

    # The code inside the function first extracts the "topic_name" parameter from the changeset data using pattern matching, and stores it in a variable named topic_name. It then constructs a URL for the new topic page by concatenating "/" and the topic_name variable, and stores it in a variable named topic_link.

    {:noreply, push_redirect(socket, to: topic_link)}

    # Finally, the function returns a tuple of {:noreply, push_redirect(socket, to: topic_link)}. This tells Phoenix to update the current LiveView socket state to socket, and push a redirect event to the client, redirecting the user to the newly created topic page at the URL stored in topic_link.
  end
end

# The handle_event/3 function is a callback function that is called by Phoenix when an event is triggered by the user in the LiveView. In this case, the function is triggered by an event named "goto_topic", which is defined in the phx-submit attribute of the form element in the HTML template.

# The function takes three arguments: the event name ("goto_topic"), a map of parameters sent with the event (in this case, the changeset data), and the current socket state.

# The mount/3 function is a callback function that is called when the LiveView is first mounted, or rendered, in the browser.
# The function takes three arguments: _params, _session, and socket. _params is a map of parameters that may be passed to the LiveView module from the router. _session is a map of session data, which is used to store user-specific data between requests. socket is a map of data that is used to maintain the state of the LiveView module between client-server interactions.
