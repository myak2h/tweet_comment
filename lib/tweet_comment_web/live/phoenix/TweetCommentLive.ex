defmodule TweetCommentWeb.TweetCommentLive do
  use Phoenix.LiveView

  alias TweetCommentWeb.CommentLiveComponent

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
     <%= live_component @socket, CommentLiveComponent, id: "comment_live_component" %>
    """
  end
end
