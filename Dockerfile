# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20210902-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.13.3-erlang-25.0-debian-bullseye-20210902-slim
#
ARG BUILDER_IMAGE="hexpm/elixir:1.13.3-erlang-25.0-debian-bullseye-20210902-slim"
ARG RUNNER_IMAGE="node:18.5.0-bullseye-slim"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY apps/pczone/mix.exs ./apps/pczone/mix.exs
COPY apps/pczone_web/mix.exs ./apps/pczone_web/mix.exs
COPY mix.exs.docker ./mix.exs
COPY mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
COPY apps/pczone/lib ./apps/pczone/lib
COPY apps/pczone/priv ./apps/pczone/priv
COPY apps/pczone_web/lib ./apps/pczone_web/lib
COPY apps/pczone_web/priv ./apps/pczone_web/priv


COPY mix.exs ./
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
COPY rel ./
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN npm i -g dew-media-cli

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/pczone_api ./

USER nobody

CMD ["bin/pczone_api", "start"]
