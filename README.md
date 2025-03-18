![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-black-text.png?raw=true#gh-light-mode-only)
![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-white-text.png?raw=true#gh-dark-mode-only)

![Elixir CI](https://github.com/ash-project/ash_storage/workflows/CI/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex version badge](https://img.shields.io/hexpm/v/ash_storage.svg)](https://hex.pm/packages/ash_storage)
[![Hexdocs badge](https://img.shields.io/badge/docs-hexdocs-purple)](https://hexdocs.pm/ash_storage)

# AshStorage

AshStorage is an [Ash](https://hexdocs.pm/ash) extension that provides a push-button solution for soft deleting records, instead of destroying them.

## Tutorials

- [Get Started with AshStorage](documentation/tutorials/get-started-with-ash-storage.md)

## Topics

- [How does AshStorage work?](documentation/topics/how-does-ash-storage-work.md)
- [Unstorage](documentation/topics/unstorage.md)

## Reference

- [AshStorage DSL](documentation/dsls/DSL-AshStorage.Resource.md)

## Development

### Testing

This project uses Docker to run PostgreSQL and MinIO for testing. You can use the provided Mix tasks to manage the Docker containers:

```bash
# Start all containers (PostgreSQL, MinIO)
mix docker.start

# Create and migrate the test database
MIX_ENV=test mix test.create
MIX_ENV=test mix test.migrate

# Run tests with the standard Mix test command
mix test

# Run a specific test file
mix test test/storage_test.exs

# Stop all containers when done
mix docker.stop
```

The `docker.start` task starts all containers and waits for them to be ready. It automatically extracts connection details (usernames, passwords, ports) from your docker-compose.yml file. You'll need to create and migrate the database separately before running tests.

MinIO is included to support testing S3 storage adapters. It provides an S3-compatible API at http://localhost:9000 and a web console at http://localhost:9001 (default credentials: minioadmin/minioadmin).

These Mix tasks can be used in any environment. For example, you could use them in development:

```bash
mix docker.start
# Set up your development database
mix ecto.create
mix ecto.migrate
# Run your application
mix phx.server  # If you're using Phoenix
```

Make sure you have Docker and Docker Compose installed on your system.
