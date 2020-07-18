# syntax = docker/dockerfile:1.0-experimental

FROM bitwalker/alpine-elixir-phoenix:1.10.3

LABEL Maintainer="Brady Fontenot"
# Set exposed ports
EXPOSE 3000

ENV MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Set build time environment variables
# Run frontend build, compile, and digest assets
RUN --mount=type=secret,id=secret_keys export SECRET_KEY_BASE=$(sed -n 1p /run/secrets/secret_keys) && \
    export REDDIT_API_KEY=$(sed -n 2p /run/secrets/secret_keys) && \
    export REDDIT_CLIENT_ID=$(sed -n 3p /run/secrets/secret_keys) && \
    export REDDIT_REDIRECT_URI=$(sed -n 4p /run/secrets/secret_keys) && \
    cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest
 
# USER bradyfontenot

CMD ["mix", "phx.server"]