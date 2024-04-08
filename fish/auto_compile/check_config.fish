#!/usr/bin/env fish

set CONFIG_PATH ~/.config/auto_compile/compile_options

for line in (cat $CONFIG_PATH)
  # skip empty lines and commentaries
  if test (string match -r -- "^\S*#.*" -- "$line"); or test -z "$line"
    continue
  end
  echo $line
end
