defmodule PropCheck.Test.TypeTest do
  use ExUnit.Case
  alias PropCheck.Type.TypeExpr
  alias PropCheck.Type
  # @moduletag capture_log: true

  test "all types available" do
    types =
      PropCheck.Test.Types
      |> PropCheck.TypeGen.defined_types()
      |> List.flatten()

    assert types != []
  end

  test "create the typedef" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:tree, 1)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{name: n, kind: k, params: ps, expr: e} = typedef
    assert :tree == n
    assert :opaque == k
    assert [:t] == ps

    # IO.inspect e
    %TypeExpr{constructor: :union, args: u_args} = e
    # Problem: node(t) must be a :ref and not be a :literal
    cs = u_args |> Enum.map(fn %TypeExpr{constructor: c} -> c end)
    # this is the :leaf part
    assert cs |> Enum.any?(&(&1 == :literal))
    # this is the node part
    assert cs |> Enum.any?(&(&1 == :tuple))
  end

  test "preorder of the tree" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:tree, 1)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e} = typedef
    # |> IO.inspect
    pre = TypeExpr.preorder(e)

    constructors = pre |> Enum.map(fn %TypeExpr{constructor: c} -> c end)
    assert [:union, :literal, :tuple, :literal, :var, :ref, :ref] == constructors
  end

  test "simple types" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_numbers, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef

    # IO.inspect typedef

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:ref] == constructors
    assert %TypeExpr{constructor: :ref, args: [:integer]} = e
  end

  test "native tuples" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_int_tuple, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:tuple, :ref, :ref] == constructors
  end

  test "native lists" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_list, 1)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: [:t]} = typedef

    # IO.inspect e
    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:list, :var] == constructors
  end

  test "explicit lists" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:safe_stack, 1)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: [:t]} = typedef

    # IO.inspect e
    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:tuple, :ref, :list, :var] == constructors
  end

  test "nonempty lists" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_non_empty_list, 1)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: [:t]} = typedef

    # IO.inspect e
    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:list, :var, :literal] == constructors
  end

  test "maps" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_map, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef
    # IO.inspect e

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:map, :tuple, :ref, :ref, :tuple, :ref, :ref] == constructors
  end

  test "structs" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_struct, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef
    # IO.inspect e

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:map, :tuple, :literal, :ref, :tuple, :literal, :list, :ref] == constructors
  end

  test "unions" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:yesno, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef
    # IO.inspect e

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:union, :literal, :literal] == constructors
  end

  test "ranges" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:my_small_numbers, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef
    # IO.inspect e

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:range, :literal, :literal] == constructors
  end

  test "any function" do
    typedef =
      PropCheck.Test.Types.__type_debug__(:any_fun, 0)
      |> PropCheck.Type.parse_type()

    assert %PropCheck.Type{} = typedef

    %PropCheck.Type{expr: e, params: []} = typedef
    # IO.inspect e

    constructors =
      e
      |> TypeExpr.preorder()
      |> Enum.map(fn %TypeExpr{constructor: c} -> c end)

    assert [:fun, :list, :literal, :ref] == constructors
  end

  test "environment construction" do
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0

    env = PropCheck.Type.create_environment(types, mod)

    assert env |> Map.has_key?({mod, :any_fun, 0})
    assert env |> Map.has_key?({mod, :my_non_empty_list, 1})
    assert env |> Map.has_key?({mod, :safe_stack, 1})
  end

  test "check non-recursive types" do
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0
    env = Type.create_environment(types, mod)

    refute Type.is_recursive({mod, :my_numbers, 0}, env)
    refute Type.is_recursive({mod, :yesno, 0}, env)
    refute Type.is_recursive({mod, :my_list, 1}, env)
    refute Type.is_recursive({mod, :safe_stack, 1}, env)
  end

  test "check recursive types" do
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0
    env = Type.create_environment(types, mod)

    assert Type.is_recursive({mod, :tree, 1}, env)
  end

  test "check mutual recursive types" do
    require Logger
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0
    _env = Type.create_environment(types, mod)

    # assert Type.is_recursive({mod, :t_nat, 0}, env)
    Logger.error("No support yet, thus: testing check mutual recursive types is not executed!")
  end

  test "simple type generator" do
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0
    env = Type.create_environment(types, mod)

    type_mfa = {mod, :my_numbers, 0}
    _ast = Type.type_generator(type_mfa, env |> Map.get(type_mfa))
  end

  test "all to be generated functions are there" do
    mod = PropCheck.Test.Types
    types = PropCheck.Test.Types.__type_debug__()
    assert length(types) > 0
    _env = Type.create_environment(types, mod)

    mod.my_numbers()
  end
end
