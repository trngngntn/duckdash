#/bin/sh
env go build --trimpath --mod=vendor --buildmode=plugin -o ./backend.so
mv backend.so ../duckdash_nakama/data/modules/