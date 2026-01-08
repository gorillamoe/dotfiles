#!/usr/bin/env bash

# Install dotnet packages until zana supports them natively
echo "📦 Installing .NET global tools"
dotnet tool install --global csharp-ls
dotnet tool install --global csharpier

