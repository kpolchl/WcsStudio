FROM elixir:alpine AS build

# install build dependencies
RUN apk add --update git build-base nodejs npm vips-dev

WORKDIR /wcs_studio

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# mix and elixir dependency
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# config dependencies
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# JS, dependencies 
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets

#Copy files 

COPY config ./config
COPY assets ./assets
COPY priv ./priv
COPY lib ./lib

#Build
RUN mix assets.deploy

# build release
COPY config/runtime.exs config/
RUN mix compile

RUN mix release standard

# prepare release image
FROM elixir:alpine AS app
# install runtime dependencies
RUN apk add --update openssl postgresql-client vips libstdc++

WORKDIR /app

# Copy files while still as root
COPY --from=build --chown=nobody:nobody /wcs_studio/_build/prod/rel/standard ./
COPY bin/start bin/start

# Set permissions (still as root)
RUN chmod +x bin/start && chown nobody:nobody bin/start

# Now switch to nobody for runtime security
RUN chown nobody:nobody /app
USER nobody:nobody

ENV MIX_ENV=prod PORT=4000
EXPOSE 4000

CMD ["bin/start"]