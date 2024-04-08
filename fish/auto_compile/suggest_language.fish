#!/usr/bin/env fish

if not test "$argv"
  echo suggest_language: No arguments!
  exit 1
end

set DESIRED_LANG (string upper "$argv")
#set DESIRED_LANG (string escape --style=regex "$DESIRED_LANG")

if not test $DESIRED_LANG
  echo suggest_language: Bad arguments!
  exit 1
end

set SHARE_PATH ~/.local/share/auto_compile/
set LANG_FILE_NAME available_aliases
set ONLY_LANG_FILE_NAME available_languages

# check if there is any matches with $DESIRED_LANG in $LANG_FILE_NAME
for line in (cat $SHARE_PATH/$LANG_FILE_NAME)
  set line (string upper "$line")
  # if line contains $DESIRED_LANG
  if test (string match -r -- "$DESIRED_LANG" -- "$line")
    set temp (string split ": " "$line")

    set current_lang $temp[1]

    set aliases (string split ", " "$temp[2]")
    
    # if any alias of language fully matches $DESIRED_LANG then echo language's name
    if contains "$DESIRED_LANG" $aliases
      echo $current_lang
      exit 0
    end

    set -a possible_languages "$temp[2]"
  end
end

# if there's no full match for $DESIRED_LANG
# then try to find the closest match
for line in $possible_languages
  set line (string split ", " "$line")
  for entry in $line
    # if found a partial match with $DESIRED_LANG in some lang's aliases then echo lang name
    if test (string match -r -- "^$DESIRED_LANG" -- "$entry"); or test (string match -r -- "$DESIRED_LANG\$" -- "$entry")
      echo $line[1]
      set found_close_match 1
      break
    end
  end
end

if not test $found_close_match
  echo $possible_languages
end

