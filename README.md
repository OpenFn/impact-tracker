# ImpactTracker

## Local Development

You will need an instance of Postgresql that is available locally (either running on your
machine or in a container).

Copy `.env.example` to `.env` and update where necessary. You can then use these env variables as
follows:

```bash
env $(cat .env | grep -v '#' | xargs) mix ecto.migrate
env $(cat .env | grep -v '#' | xargs) iex -S mix phx.server
```

### Checking integration with Lightning

If you are running Lightning locally, you can use the docker compose setup to run IT locally as well.

```bash
# Only needed for the initial setup - generate certs for use by the postgres container
./local_testing/generate_certs.sh
```

```bash
# Start ImpactTracker up - it will listen on port 4001
docker compose -f local_testing/docker-compose.yml up --build -d
```

Configure you local Lightning instance to use http://127.0.0.1:4000 for usage tracking and you will
be able to submit to this instance.

## Running tests

Copy `.env.example` to `.env.test` and update where necessary. You can then use these env variables
as follows:

```bash
env $(cat .env.test | grep -v '#' | xargs) mix test
```
