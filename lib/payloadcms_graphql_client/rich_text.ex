defmodule PayloadcmsGraphqlClient.RichText do
  @moduledoc """
  Conveniences for handling Payload CMS rich text fields.
  """

  import Bitwise

  @custom_renderer_key %{
    "block" => :block,
    "inlineBlock" => :inline_block,
    "upload" => :upload
  }
  @custom_renderer_required Map.keys(@custom_renderer_key)

  def to_html(%{root: root}, options \\ %{}) do
    render(root, options)
  end

  def render(%{type: "root", children: children}, options) do
    children
    |> Enum.flat_map(&render(&1, options))
    |> Enum.join()
  end

  def render(%{type: "heading", tag: tag} = node, options) do
    case renderer(:heading, options) do
      nil ->
        ["<#{tag}>"] ++ Enum.flat_map(node.children, &render(&1, options)) ++ ["</#{tag}>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "list", tag: "ul"} = node, options) do
    case renderer(:unordered_list, options) do
      nil ->
        ["<ul>"] ++
          Enum.flat_map(node.children, &render(&1, options)) ++
          ["</ul>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "list", tag: "ol"} = node, options) do
    case renderer(:ordered_list, options) do
      nil ->
        attributes = if node[:start], do: " start=\"#{node.start}\"", else: ""

        ["<ol#{attributes}>"] ++
          Enum.flat_map(node.children, &render(&1, options)) ++
          ["</ol>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "listitem"} = node, options) do
    case renderer(:list_item, options) do
      nil ->
        ["<li>"] ++ Enum.flat_map(node.children, &render(&1, options)) ++ ["</li>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "paragraph"} = node, options) do
    case renderer(:paragraph, options) do
      nil ->
        ["<p>"] ++ Enum.flat_map(node.children, &render(&1, options)) ++ ["</p>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "linebreak"}, _options), do: ["<br>"]

  def render(%{type: "link", fields: %{url: url} = fields, children: children} = node, options) do
    case renderer(:link, options) do
      nil ->
        new_tab = Map.get(fields, :newTab, false)
        target = if new_tab, do: "_blank", else: "_self"

        [~s(<a href="#{url}" target="#{target}">)] ++
          Enum.flat_map(children, &render(&1, options)) ++ ["</a>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "table"} = node, options) do
    case renderer(:table, options) do
      nil ->
        render_table(node, options)

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "tablerow"} = node, options) do
    case renderer(:tablerow, options) do
      nil ->
        render_tablerow(node, options)

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "tablecell"} = node, options) do
    case renderer(:tablecell, options) do
      nil ->
        render_tablecell(node, options)

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: "text", format: format} = node, options) when (format &&& 1) == 1 do
    format = bxor(format, 1)
    node = Map.put(node, :format, format)
    ["<b>"] ++ render(node, options) ++ ["</b>"]
  end

  def render(%{type: "text", format: format} = node, options) when (format &&& 2) == 2 do
    format = bxor(format, 2)
    node = Map.put(node, :format, format)
    ["<em>"] ++ render(node, options) ++ ["</em>"]
  end

  def render(%{type: "text", format: format} = node, options) when (format &&& 16) == 16 do
    format = bxor(format, 16)
    node = Map.put(node, :format, format)
    ["<code>"] ++ render(node, options) ++ ["</code>"]
  end

  def render(%{type: "text", format: format} = node, options) when (format &&& 64) == 64 do
    format = bxor(format, 64)
    node = Map.put(node, :format, format)
    ["<sup>"] ++ render(node, options) ++ ["</sup>"]
  end

  def render(%{type: "text", text: text}, _options) do
    [text]
  end

  def render(%{type: "horizontalrule"} = node, options) do
    case renderer(:horizontalrule, options) do
      nil ->
        ["<hr>"]

      renderer ->
        renderer.(node, options)
    end
  end

  def render(%{type: type} = node, options) when type in @custom_renderer_required do
    name = Map.fetch!(@custom_renderer_key, type)

    case renderer!(name, options) do
      {:ok, renderer} ->
        renderer.(node, options)

      {:error, error} ->
        raise """
        Error rendering #{name} node: #{inspect(node)}

        A custom renderer is required for '#{type}' nodes.

        Error: #{error}
        """
    end
  end

  def render(node, options) do
    message =
      """
      No render/2 clause matching for node: #{inspect(node)}

      Options: #{inspect(options)}
      """

    raise message
  end

  def render_table(node, options) do
    ["<table>"] ++
      Enum.flat_map(node.children, &render(&1, options)) ++
      ["</table>"]
  end

  def render_tablerow(node, options) do
    ["<tr>"] ++ Enum.flat_map(node.children, &render(&1, options)) ++ ["</tr>"]
  end

  def render_tablecell(node, options) do
    tag =
      if node.headerState == 1 do
        "th"
      else
        "td"
      end

    attributes =
      if node.colSpan != 1 do
        " colspan=\"#{node.colSpan}\""
      else
        ""
      end

    attributes =
      if node.rowSpan != 1 do
        attributes <> " rowspan=\"#{node.rowSpan}\""
      else
        attributes
      end

    ["<#{tag}#{attributes}>"] ++
      Enum.flat_map(node.children, &render(&1, options)) ++ ["</#{tag}>"]
  end

  defp renderer!(name, %{renderers: renderers} = options) do
    renderer = renderer(name, options)

    if renderer do
      {:ok, renderer}
    else
      {
        :error,
        """
        No `#{name}` function supplied in options.renders

        Supplied renderers:
        #{renderers |> Map.keys() |> inspect()}
        """
      }
    end
  end

  defp renderer!(name, options) do
    {
      :error,
      """
      Can't find renderer for `#{name}` as
      no `:renderers` were supplied in options:

      options: #{options |> Map.keys() |> inspect()}
      """
    }
  end

  defp renderer(name, %{renderers: renderers}) do
    renderers[name]
  end

  defp renderer(_name, _options), do: nil
end
