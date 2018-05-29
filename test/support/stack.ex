defmodule PropCheck.Test.Stack do
  # use PropCheck.Properties
  use PropCheck.TypeGen

  # when t: var
  @opaque stack(t) :: [t]

  @spec new(t) :: stack(t) when t: var
  def new(_), do: []

  @spec push(stack(t), t) :: stack(t) when t: var
  def push(s, x), do: [x | s]

  @spec pop(stack(t)) :: {t, stack(t)} when t: var
  def pop([]), do: throw("Empty Stack")
  def pop([x | s]), do: {x, s}

  @spec empty(stack(_t)) :: boolean when _t: var
  def empty([]), do: true
  def empty(_), do: false

  @spec size(stack(_t)) :: non_neg_integer when _t: var
  def size(s), do: length(s)

  # Generator for properties of Stacks
  # def stack(type), do: list(type)
  # def stack(t), do: :proper_types.native_type(__MODULE__, '[t]')
end
