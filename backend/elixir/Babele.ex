defmodule Babele do
  @moduledoc """
  Babele Elixir Compiler - modern distributed backend.
  """

  defmodule Ty do
    @type t :: :int | :float | :string | :bool | :void
  end

  defmodule Expr do
    @type t ::
            {:int, integer()}
            | {:float, float()}
            | {:string, String.t()}
            | {:bool, boolean()}
            | {:var, String.t()}
            | {:binop, atom(), t(), t()}
            | {:call, String.t(), [t()]}
  end

  defmodule TypeChecker do
    def value_ty({:int, _}), do: :int
    def value_ty({:float, _}), do: :float
    def value_ty({:string, _}), do: :string
    def value_ty({:bool, _}), do: :bool

    def infer(_env, {:int, _}), do: {:ok, :int}
    def infer(_env, {:float, _}), do: {:ok, :float}
    def infer(_env, {:string, _}), do: {:ok, :string}
    def infer(_env, {:bool, _}), do: {:ok, :bool}

    def infer(env, {:var, name}) do
      case Map.fetch(env, name) do
        {:ok, t} -> {:ok, t}
        :error -> {:error, "Variabile non definita: #{name}"}
      end
    end

    def infer(env, {:binop, op, l, r}) do
      with {:ok, lt} <- infer(env, l),
           {:ok, rt} <- infer(env, r) do
        case {op, lt, rt} do
          {_, :int, :int} -> {:ok, :int}
          {_, :float, :float} -> {:ok, :float}
          {:add, :string, :string} -> {:ok, :string}
          {:eq, t, t} -> {:ok, :bool}
          {:lt, :int, :int} -> {:ok, :bool}
          {_, _, _} -> {:error, "Tipi non compatibili: #{lt}, #{rt}"}
        end
      end
    end

    def infer(_env, {:call, _, _}), do: {:ok, :void}
  end

  defmodule CodegenC do
    def expr_to_c({:int, n}), do: Integer.to_string(n)
    def expr_to_c({:float, f}), do: Float.to_string(f)
    def expr_to_c({:string, s}), do: ~s("#{s}")
    def expr_to_c({:bool, true}), do: "1"
    def expr_to_c({:bool, false}), do: "0"
    def expr_to_c({:var, name}), do: name

    def expr_to_c({:binop, op, l, r}) do
      op_str = case op do
        :add -> "+"
        :sub -> "-"
        :mul -> "*"
        :div -> "/"
        :eq -> "=="
        :lt -> "<"
      end
      "(#{expr_to_c(l)} #{op_str} #{expr_to_c(r)})"
    end

    def expr_to_c({:call, name, args}) do
      "#{name}(#{Enum.map_join(args, ", ", &expr_to_c/1)})"
    end

    def generate(stmts) do
      """
      /* Generato da Babele */
      #include <stdio.h>

      int main(void) {
      #{Enum.map_join(stmts, "\n", &stmt_to_c/1)}
          return 0;
      }
      """
    end

    defp stmt_to_c({:let, name, value}) do
      "    const char* #{name} = #{expr_to_c(value)};"
    end

    defp stmt_to_c({:print, value}) do
      ~s(    printf("%s\\n", #{expr_to_c(value)});)
    end
  end

  def main do
    program = [
      {:let, "saluto", {:string, "Ciao, mondo!"}},
      {:print, {:var, "saluto"}}
    ]
    IO.puts(CodegenC.generate(program))
  end
end

Babele.main()
