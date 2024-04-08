#!/usr/bin/env fish

if not test "$argv"
  echo suggest_language: No arguments!
  exit 1
end

set DESIRED_LANG "$argv"
set DESIRED_LANG (string upper $argv)
set DESIRED_LANG (string escape --style=regex "$DESIRED_LANG")

if not test $DESIRED_LANG
  echo suggest_language: Bad arguments!
  exit 1
end

set SHARE_PATH ~/.local/share/auto_compile/
set LANG_FILE_NAME available_languages

