defmodule PropCheck.Test.Types do
  @moduledoc """
  This module contains various type definitions to check that the generator generation
  works properly. 
  """
  use PropCheck.TypeGen

  @type my_numbers :: integer
  @type my_small_numbers :: 0..100
  @type yesno :: :yes | :no

  @type my_list(t) :: [t]
  @type safe_stack(t) :: {pos_integer, list(t)}
  @type my_non_empty_list(t) :: [t, ...]

  @opaque tree(t) :: :leaf | {:node, t, tree(t), tree(t)}

  @type pair(fst, snd) :: {:pair, fst, snd}
  @type my_int_tuple :: {integer, integer}

  @type my_map :: %{atom => integer, integer => boolean}

  defstruct name: :unknown, args: []
  @type my_struct :: %{name: atom, args: [atom]}

  @type any_fun :: (... -> any)
  @type side_effect :: (() -> any)
  @type call_back :: (atom, boolean -> [atom])

  # mutual recursive types from the "Proper Types" paper
  @type t_nat ::
          non_neg_integer
          | {:+, t_nat, t_nat}
          | {:if, t_cond, t_nat, t_nat}
          | {:from_bits, t_bits}
  @type t_cond ::
          {:=, t_nat, t_nat}
          | {:=, t_real, t_real}
  @type t_real ::
          {:from_nat, t_nat}
          | {:+, t_real, t_real}
  @type t_bits ::
          {:from_nat, t_nat}
          | {:concat, [t_bits | t_nat]}

  # @type empty_bits :: <<>>
  # @type my_3_bits :: << _ :: 3 >>
  # @type my_bitstring_of_bytes :: << _ :: _ * 8 >>
  # Does this type makes sense at all? It does not compile!
  # @type any_bits :: << _ :: 1,  _ :: _ * 8 >>
end
