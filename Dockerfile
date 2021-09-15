# podman build -f Dockerfile --target schedy-server-devel -t schedy-server-devel
# podman build -f Dockerfile --target schedy-server -t schedy-server

FROM fedora:32 AS base
RUN dnf -y install ruby rubygems libpq nodejs lz4 unzip  bzip2 procps-ng iproute psmisc mc less aha catatonit
WORKDIR /schedy-server
RUN mkdir ./project


FROM base AS build
RUN dnf -y install '@C Development Tools and Libraries' ruby-devel redhat-rpm-config postgresql-devel zlib-devel patch yarnpkg  openssh-clients
COPY Gemfile Gemfile.lock  ./
RUN gem install bundler:1.13.7
RUN bundle config --local set path vendor/bundle
RUN bundle install --path vendor/bundle
COPY package.json yarn.lock ./
RUN yarn install
COPY Gemfile Gemfile.lock Rakefile ./
COPY app/ ./app/
COPY bin/rake bin/rails bin/spring bin/webpack ./bin/
COPY config/ ./config/
COPY vendor/assets/ ./vendor/assets/
RUN cp ./config/database.yml.example ./config/database.yml
RUN bundle exec rake webpacker:compile
RUN bundle exec rake assets:precompile
RUN rm ./config/database.yml


FROM build AS schedy-server-devel
COPY bin/    ./bin/
COPY db/     ./db/
COPY lib/    ./lib/
COPY public/ ./public/
COPY config.ru  ./
COPY config/database.yml.devel-compose config/database.yml
ENTRYPOINT ["bundle", "exec"]


FROM base AS schedy-server
COPY app/    ./app/
RUN rm -rf   ./app/assets/
COPY app/assets/config/ ./app/assets/config/
COPY bin/    ./bin/
COPY config/ ./config/
COPY db/     ./db/
COPY lib/    ./lib/
COPY public/ ./public/
COPY Gemfile Gemfile.lock Rakefile config.ru  ./
RUN gem install bundler:1.13.7
COPY --from=build /schedy-server/vendor/ /schedy-server/vendor/
COPY --from=build /schedy-server/.bundle/ /schedy-server/.bundle/
COPY --from=build /schedy-server/public/assets/ /schedy-server/public/assets/
COPY --from=build /schedy-server/public/packs/ /schedy-server/public/packs/
ENTRYPOINT ["bundle", "exec"]

