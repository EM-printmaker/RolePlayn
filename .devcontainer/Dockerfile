ARG RUBY_VERSION=3.3.10
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

USER root

RUN apt-get update && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

USER vscode
