#!/usr/bin/env bash

# Lua Language Server release tag to install
LUA_LANGUAGE_SERVER_RELEASE_TAG="3.7.4"

# Download and install lua-language-server
curl -L https://github.com/LuaLS/lua-language-server/releases/download/$LUA_LANGUAGE_SERVER_RELEASE_TAG/lua-language-server-$LUA_LANGUAGE_SERVER_RELEASE_TAG-linux-x64.tar.gz -o lua-language-server.tar.gz && \
  tar -xvf lua-language-server.tar.gz -C lua-language-server && \
  sudo mv lua-language-server/bin/lua-language-server /usr/bin && \
  rm -rf lua-language-server.tar.gz lua-language-server
