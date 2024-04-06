#!/usr/bin/env fish

set ONLY_LANG_PATH ~/.local/share/auto_compile/only_languages.yml
set LANG_PATH ~/.local/share/auto_compile/languages.yml

set DESIRED_LANG $argv
set DESIRED_LANG (string upper "$DESIRED_LANG")
set DESIRED_LANG (string unescape --style=regex "$DESIRED_LANG")

if not test -f $LANG_PATH
  source ./update_languages.fish
end

set temp (mktemp)

# delete all non-lanugage lines
sed '/^ \+.*/d' $LANG_PATH > $temp
# delete all colons
sed 's/://' $temp > $ONLY_LANG_PATH

rm $temp

#searching for languages
for line in (cat $ONLY_LANG_PATH)
  set line (string upper "$line")

  if test $line = $DESIRED_LANG
    set LANG_FOUND 1
    break
  end
end

#searching for aliases
