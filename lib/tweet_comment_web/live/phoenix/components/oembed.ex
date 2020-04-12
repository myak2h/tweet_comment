defmodule TweetCommentWeb.OembedComponent do
  use Phoenix.LiveComponent
  import Phoenix.HTML

  def render(assigns) do
    ~L"""
    <div>
      <%= raw(@oembed) %>
    </div>
    """
  end
end
