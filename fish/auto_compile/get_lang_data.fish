#!/usr/bin/env fish

argparse "h/help" "u/update-languages" -- $argv

set PROG_LANG_DATA ~/.local/share/auto_compile/available_languages_data

if test $_flag_h; or test (count $argv) -eq 0
  
  exit
end

if test $_flag_u
  source "update_languages.fish"
  exit
end

set DESIRED_LANG $argv
set DESIRED_LANG (string upper "$DESIRED_LANG")

for line in (cat $PROG_LANG_DATA)

  set current_lang (string replace ":" "" (string match -r -- "^\S.*" -- "$line"))
  set current_lang (string upper "$current_lang")

  if test $LANG_FOUND
    if test $current_lang
      break
    end
    echo $line
  end

  if test "$current_lang" = "$DESIRED_LANG"
    echo "$DESIRED_LANG:"
    set LANG_FOUND 1
  end

end

# if no matches then try to suggest languages
# and if only one language fits then try it 
if not test $LANG_FOUND
  set possible_lang (source ./suggest_language.fish $DESIRED_LANG) 

  if test (count $possible_lang) -eq 1
    source ./get_lang_data.fish $possible_lang
    exit 0
  end

  if test (count $possible_lang) -eq 0
    echo No matches for $DESIRED_LANG
    exit 1
  end

  if test (count $possible_lang) -gt 1
    echo 'Maybe you\'ve meant one of these?'
    for line in $possible_lang
      echo "  $line"
    end
    exit 1
  end
end
