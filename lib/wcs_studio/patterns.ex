defmodule WcsStudio.Pattern do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "patterns" do
    field :name, :string
    field :starting_hands, Ecto.Enum, values: [:left_left, :left_right, :right_right, :right_left]
    field :ending_hands, Ecto.Enum, values: [:left_left, :left_right, :right_right, :right_left]
    field :count_num, :integer
    field :video_url, :string
    field :depth, :integer, virtual: true
    belongs_to :dance_type, WcsStudio.DanceType
    has_many :user_patterns, WcsStudio.UserPattern
    many_to_many :lessons, WcsStudio.Lesson, join_through: "lesson_patterns"

    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps()
  end

  def get_all do
    WcsStudio.Repo.all(__MODULE__)
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_tree(root_id) do
    base = from p in __MODULE__, where: p.id == ^root_id

    recursive =
      from p in __MODULE__,
        join: t in "tree",
        on: p.parent_id == t.id

    tree_query = union_all(base, ^recursive)

    flat_list =
      __MODULE__
      |> recursive_ctes(true)
      |> with_cte("tree", as: ^tree_query)
      |> WcsStudio.Repo.all()
      |> WcsStudio.Repo.preload(:dance_type)

    build_tree(flat_list, root_id)
  end

  def get_children(parent_id) do
    __MODULE__
    |> where(parent_id: ^parent_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_roots(dance_type_id) do
    from(p in __MODULE__,
      where: p.dance_type_id == ^dance_type_id and is_nil(p.parent_id)
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def count_patterns do
    from(p in __MODULE__, select: count())
    |> WcsStudio.Repo.one()
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(__MODULE__, id)
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_by_dance_type_id(dance_type_id) do
    __MODULE__
    |> where(dance_type_id: ^dance_type_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_by_id_name_or_hands(dance_type_id, query_string) do
    search_pattern = "%#{query_string}%"

    matching_ids =
      from(p in __MODULE__,
        where: p.dance_type_id == ^dance_type_id and ilike(p.name, ^search_pattern),
        select: %{id: p.id, parent_id: p.parent_id}
      )
      |> WcsStudio.Repo.all()

    root_ids =
      Enum.flat_map(matching_ids, fn
        %{parent_id: nil, id: id} -> [id]
        %{parent_id: parent_id} -> [parent_id]
      end)
      |> Enum.uniq()

    matching_child_ids = Enum.map(matching_ids, & &1.id) |> MapSet.new()

    from(p in __MODULE__,
      where: p.id in ^root_ids,
      order_by: [asc: p.name]
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload([:dance_type, children: :dance_type])
    |> Enum.map(fn root ->
      if root.id in matching_child_ids do
        %{root | children: Enum.sort_by(root.children, & &1.name)}
      else
        filtered = Enum.filter(root.children, &(&1.id in matching_child_ids))
        %{root | children: Enum.sort_by(filtered, & &1.name)}
      end
    end)
  end

  def get_roots_with_children(dance_type_id) do
    from(p in __MODULE__,
      where: p.dance_type_id == ^dance_type_id and is_nil(p.parent_id),
      order_by: [asc: p.name]
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload([:dance_type, children: :dance_type])
    |> Enum.map(fn p ->
      %{p | children: Enum.sort_by(p.children, & &1.name)}
    end)
  end

  def get_roots_without_children(dance_type_id) do
    from(p in __MODULE__,
      left_join: c in __MODULE__,
      on: c.parent_id == p.id,
      where: p.dance_type_id == ^dance_type_id and is_nil(p.parent_id) and is_nil(c.id),
      order_by: [asc: p.name]
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  # All root patterns for a dance type — used to populate child candidate list
  def get_roots_for_dance_type(dance_type_id) do
    from(p in __MODULE__,
      where: p.dance_type_id == ^dance_type_id and is_nil(p.parent_id),
      order_by: [asc: p.name]
    )
    |> WcsStudio.Repo.all()
  end

  # All patterns (roots + children) for a dance type — used to populate child candidate list
  # including patterns that are currently children of other patterns
  def get_all_for_dance_type(dance_type_id) do
    from(p in __MODULE__,
      where: p.dance_type_id == ^dance_type_id,
      order_by: [asc: p.name]
    )
    |> WcsStudio.Repo.all()
  end

  def add(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> WcsStudio.Repo.insert()
  end

  def update(pattern, attrs) do
    pattern
    |> changeset(attrs)
    |> WcsStudio.Repo.update()
  end

  def set_parent(child_id, parent_id) do
    case WcsStudio.Repo.get(__MODULE__, child_id) do
      nil -> {:error, :not_found}
      child -> child |> changeset(%{parent_id: parent_id}) |> WcsStudio.Repo.update()
    end
  end

  def remove_parent(child_id) do
    case WcsStudio.Repo.get(__MODULE__, child_id) do
      nil -> {:error, :not_found}
      child -> child |> changeset(%{parent_id: nil}) |> WcsStudio.Repo.update()
    end
  end

  def delete_pattern(id) do
    case get_by_id(id) do
      nil -> {:error, :not_found}
      pattern -> WcsStudio.Repo.delete(pattern)
    end
  end

  def get_by_id_with_children(id) do
    WcsStudio.Repo.get(__MODULE__, id)
    |> WcsStudio.Repo.preload([:dance_type, :children])
  end

  def hands_options do
    [
      {"Left / Left", :left_left},
      {"Left / Right", :left_right},
      {"Right / Right", :right_right},
      {"Right / Left", :right_left}
    ]
  end

  defp changeset(pattern, attrs) do
    pattern
    |> cast(attrs, [
      :name,
      :starting_hands,
      :ending_hands,
      :count_num,
      :video_url,
      :dance_type_id,
      :parent_id
    ])
    |> validate_required([:name, :dance_type_id])
    |> foreign_key_constraint(:dance_type_id)
    |> foreign_key_constraint(:parent_id)
  end

  defp build_tree(all_nodes, root_id) do
    root = Enum.find(all_nodes, &(&1.id == root_id))
    if root, do: attach_children(%{root | depth: 0}, all_nodes, 0)
  end

  defp attach_children(node, all_nodes, depth) do
    children =
      all_nodes
      |> Enum.filter(&(&1.parent_id == node.id))
      |> Enum.map(&attach_children(%{&1 | depth: depth + 1}, all_nodes, depth + 1))

    %{node | children: children}
  end
end
