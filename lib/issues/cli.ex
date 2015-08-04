defmodule Issues.CLI do
  @default_count 4
  
  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions that end up generating a table of the last _n_ issues in a github project 
  """
  
  def run(argv) do 
    argv
      |> parse_args
      |> process
  end
  
  @doc """
  `argv` can be -h or --help, which returns :help.
    
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.
  
  Return a tuple of `{ user, project, count }`, or `:help` if help was given. 
  """

  def parse_args(argv) do 
    OptionParser.parse(argv, switches: [ help: :boolean], aliases: [ h: :help ])
      |> _parse_args
  end

  defp _parse_args({ [ help: true ], _, _ }), do: :help
  defp _parse_args({ _, [ user, project, count ], _ }), do: { user, project, String.to_integer(count) }
  defp _parse_args({ _, [ user, project ], _ }), do: { user, project, @default_count }
  defp _parse_args(_), do: :help

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ] 
    """
    System.halt(0)
  end

  def process({user, project, _count}) do 
    Issues.GithubIssues.fetch(user, project)
      |> decode_response
      |> convert_to_list_of_hashdicts
      |> sort_into_ascending_order
      |> Enum.take(_count)
      |> Issues.TableFormatter.print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0) 
    IO.puts "Error fetching from Github: #{message}" 
    System.halt(2)
  end

  def convert_to_list_of_hashdicts(list) do 
    list
      |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  def sort_into_ascending_order(list) do
    Enum.sort list, fn i1, i2 -> 
      i1["created_at"] <= i2["created_at"] 
    end
  end

end