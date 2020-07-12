FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 
ENV MIX_ENV=prod
ENV REDDIT_API_KEY="BTC6RadgwMgZFobk8OAic4C8n-I"
ENV REDDIT_CLIENT_ID="DtBKWrjukvwgjQ"
ENV REDDIT_REDIRECT_URI="https://lit-gorge-30541.herokuapp.com/"
ENV SECRET_KEY_BASE="tyM/chXu25apDbBhPzSk0pcXu+g2z0Nj5oEoxKShVp8QAt5rMWqGcVR3c/8v3YKS"

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

# USER bradyfontenot

CMD ["mix", "phx.server"]