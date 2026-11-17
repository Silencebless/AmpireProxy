#!/bin/sh
# Создаёт платформенные папки (android, ios, macos, windows, linux), если их ещё нет.
# Нужен установленный Flutter 3.27.4 или новее.
set -e
cd "$(dirname "$0")/.."
if [ ! -d android ] || [ ! -d ios ]; then
  flutter create --org app.ampire --project-name ampire --platforms=android,ios,macos,windows,linux .
fi
