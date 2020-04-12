defmodule TweetCommentWeb.Surface.OembedComponent do
  use Surface.Component
  import Phoenix.HTML

  property(oembed, :string)

  def render(assigns) do
    ~H"""
    <div>
      {{raw(@oembed)}}
    </div>
    """
  end
end
