#!/usr/bin/env fish

argparse "h/help" "u/update" -- $argv

if test $_flag_h; or test (count $argv) -eq 0
  
  exit 0
end

set DESIRED_LANG (string upper "$argv")
set SHARE_PATH ~/.local/share/auto_compile/
set EXTENSIONS_PATH extensions/

# if $DESIRED_LANG can be extended to only one valid language then
# set $DESIRED_LANG to that one valid language
set suggested_langs (source ./suggest_language.fish "$DESIRED_LANG")
if test (count $suggested_langs) -eq 1
  set DESIRED_LANG $suggested_langs
end
if test (count $suggested_langs) -eq 0
  echo No matches found!
  exit 1
end
if test (count $suggested_langs) -gt 1
  echo Maybe you\'ve meant one of these\?
  for line in $suggested_langs
    echo "  $line"
  end
  exit 0
end

if not test -d $SHARE_PATH/extensions
  mkdir $SHARE_PATH/extensions
end

# if extensions for $DESIRED_LANG have already been found before
if test -f $SHARE_PATH/extensions/$DESIRED_LANG; and not test $_flag_u
  for line in (cat $SHARE_PATH/extensions/$DESIRED_LANG)
    echo $line 
  end
else
  # if extensions for $DESIRED_LANG are not present
  for line in (source ./get_lang_data.fish "$DESIRED_LANG")
    # if in extensions section
    if test $FOUND_EXTENSIONS
      # if another section begins then exit the loop
      if test (string match -r -- " +\w+" -- "$line")
        break
      # get extensions
      else
        set -a extensions (string match -r -- "\w+\.?\w*" -- "$line")
      end
    end
    # trying to find extensions section
    if test (string match -r -- " +extensions:" -- "$line")
      set FOUND_EXTENSIONS 1
    end
  end
  if test $FOUND_EXTENSIONS
    echo $extensions
    echo $extensions > $SHARE_PATH/extensions/$DESIRED_LANG
  end
end
