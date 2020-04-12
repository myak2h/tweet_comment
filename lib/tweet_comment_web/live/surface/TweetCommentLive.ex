defmodule TweetCommentWeb.Surface.TweetCommentLive do
  use Surface.LiveView

  alias TweetCommentWeb.Surface.CommentLiveComponent

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <CommentLiveComponent id="comment_live_component"/>
    """
  end
end
