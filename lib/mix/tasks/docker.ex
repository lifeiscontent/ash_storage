defmodule Mix.Tasks.Docker do
  @moduledoc """
  Tasks for managing Docker containers.
  """

  defmodule Start do
    @moduledoc """
    Starts all Docker containers (PostgreSQL, MinIO).

    ## Examples

        mix docker.start

    """
    use Mix.Task

    @shortdoc "Starts all Docker containers"
    def run(_) do
      Mix.shell().info("Starting containers...")
      {_, 0} = System.cmd("docker-compose", ["up", "-d"], into: IO.stream(:stdio, :line))

      # Parse docker-compose.yml to get environment variables
      {postgres_user, postgres_password} = get_postgres_credentials()
      postgres_port = get_postgres_port()
      {minio_user, minio_password} = get_minio_credentials()
      minio_api_port = get_minio_port("9000")
      minio_console_port = get_minio_port("9001")

      Mix.shell().info("Waiting for PostgreSQL to be ready...")
      wait_for_postgres(postgres_user)

      Mix.shell().info(
        "PostgreSQL is ready at localhost:#{postgres_port} with username '#{postgres_user}' and password '#{postgres_password}'"
      )

      Mix.shell().info("Waiting for MinIO to be ready...")
      wait_for_minio(minio_api_port)
      Mix.shell().info("MinIO is ready at:")

      Mix.shell().info(
        "  API: http://localhost:#{minio_api_port} with username '#{minio_user}' and password '#{minio_password}'"
      )

      Mix.shell().info("  Console: http://localhost:#{minio_console_port}")
    end

    defp wait_for_postgres(postgres_user) do
      case System.cmd(
             "docker-compose",
             ["exec", "-T", "postgres", "pg_isready", "-U", postgres_user],
             stderr_to_stdout: true
           ) do
        {_, 0} ->
          :ok

        _ ->
          Mix.shell().info("PostgreSQL is not ready yet... waiting")
          :timer.sleep(2000)
          wait_for_postgres(postgres_user)
      end
    end

    defp get_postgres_credentials do
      case File.read("docker-compose.yml") do
        {:ok, content} ->
          user = extract_env_var(content, "POSTGRES_USER") || "postgres"
          password = extract_env_var(content, "POSTGRES_PASSWORD") || "postgres"
          {user, password}

        _ ->
          {"postgres", "postgres"}
      end
    end

    defp get_postgres_port do
      case File.read("docker-compose.yml") do
        {:ok, content} ->
          # Look for ports under the postgres service
          case Regex.run(~r/postgres:.*?ports:\s*-\s*"(\d+):(\d+)"/s, content) do
            [_, host_port, _] -> host_port
            _ -> "5432"
          end

        _ ->
          "5432"
      end
    end

    defp get_minio_port(default_port) do
      case File.read("docker-compose.yml") do
        {:ok, content} ->
          # Look for the specified port mapping under the minio service
          case Regex.run(~r/minio:.*?ports:.*?-\s*"(\d+):#{default_port}"/s, content) do
            [_, host_port] -> host_port
            _ -> default_port
          end

        _ ->
          default_port
      end
    end

    defp extract_env_var(content, var_name) do
      case Regex.run(~r/#{var_name}:\s*([^\s]+)/, content) do
        [_, value] -> value
        _ -> nil
      end
    end

    defp get_minio_credentials do
      case File.read("docker-compose.yml") do
        {:ok, content} ->
          user = extract_minio_env_var(content, "MINIO_ROOT_USER") || "minioadmin"
          password = extract_minio_env_var(content, "MINIO_ROOT_PASSWORD") || "minioadmin"
          {user, password}

        _ ->
          {"minioadmin", "minioadmin"}
      end
    end

    defp extract_minio_env_var(content, var_name) do
      case Regex.run(~r/minio:.*?#{var_name}:\s*([^\s]+)/s, content) do
        [_, value] -> value
        _ -> nil
      end
    end

    defp wait_for_minio(port) do
      url = "http://localhost:#{port}/minio/health/live"

      case System.cmd("curl", ["-s", "-f", url], stderr_to_stdout: true) do
        {_, 0} ->
          :ok

        _ ->
          Mix.shell().info("MinIO is not ready yet... waiting")
          :timer.sleep(2000)
          wait_for_minio(port)
      end
    end
  end

  defmodule Stop do
    @moduledoc """
    Stops all Docker containers.

    ## Examples

        mix docker.stop

    """
    use Mix.Task

    @shortdoc "Stops all Docker containers"
    def run(_) do
      Mix.shell().info("Stopping all containers...")
      {_, 0} = System.cmd("docker-compose", ["down"], into: IO.stream(:stdio, :line))
      Mix.shell().info("All containers stopped.")
    end
  end
end
