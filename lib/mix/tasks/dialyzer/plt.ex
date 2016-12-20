defmodule Mix.Tasks.Dialyzer.Plt do
  @shortdoc "Runs dialyzer.plt"

  use Mix.Task

  alias Dialyxir.{Plt, Project}

  @spec run([binary]) :: any
  def run(_) do
    {apps, hash} = dependency_hash

    unless check_hash?(hash) do
      Project.plts_list(apps) |> Plt.check()
      File.write(plt_hash_file, hash)
    end
  end

  @spec check_hash?(binary) :: boolean
  defp check_hash?(hash) do
	  case File.read(plt_hash_file) do
      {:ok, stored_hash} -> hash == stored_hash
      _ -> false
    end
  end

  @spec plt_hash_file() :: String.t
  defp plt_hash_file, do: Project.plt_file() <> ".hash"

  @spec dependency_hash :: {[atom], binary}
  def dependency_hash do
    lock_file = Mix.Dep.Lock.read |> :erlang.term_to_binary
    apps = Project.cons_apps |> IO.inspect
    hash = :crypto.hash(:sha, lock_file <> :erlang.term_to_binary(apps))
    {apps, hash}
  end
end
