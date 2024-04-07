#!/usr/bin/env fish

if not test $argv
  echo suggest_language: No arguments!
  exit 1
end

set DESIRED_LANG $argv
set DESIRED_LANG (string upper $argv)
set DESIRED_LANG (string escape --style=regex "$DESIRED_LANG")

if not test $DESIRED_LANG
  echo suggest_language: Bad arguments!
  exit 1
end

set LANG_PATH ~/.local/share/auto_compile/available_languages

# check if some language starts or ends with $DESIRED_LANG
for line in (cat $LANG_PATH)
  if test (string match -r -- "^$DESIRED_LANG.*" -- (string upper $line))
    echo $line
  else
    if test (string match -r -- ".*$DESIRED_LANG\$" -- (string upper $line))
      echo $line
    end
  end

end
