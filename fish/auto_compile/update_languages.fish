#!/usr/bin/env fish

set SHARE_PATH ~/.local/share/auto_compile
set ONLY_LANG_FILE_NAME available_languages
set LANG_DATA_FILE_NAME available_languages_data
set LANG_YML_NAME languages.yml

# if directory doesn't exist then create it
if not test -d $SHARE_PATH
  mkdir $SHARE_PATH 
end

# erase all data in files $ONLY_LANG_FILE_NAME and $LANG_DATA_FILE_NAME
cat /dev/null > $SHARE_PATH/$ONLY_LANG_FILE_NAME
cat /dev/null > $SHARE_PATH/$LANG_DATA_FILE_NAME

# download languages.yml from github-linguist repo
curl https://raw.githubusercontent.com/github-linguist/linguist/master/lib/linguist/languages.yml -o $SHARE_PATH/languages.yml

set temp (mktemp)

# delete commentaries and '---' line
sed '/^#.*/d;1d' $SHARE_PATH/$LANG_YML_NAME > $temp

# fill $LANG_DATA_FILE_NAME file
for line in (cat $temp)

  if test (string match -r -- "^\S.*:" -- "$line")
    if test "$prog_type"
      for line_1 in $lang_data
        echo $line_1 >> $SHARE_PATH/$LANG_DATA_FILE_NAME
      end
    end

    set -e lang_data
    set -a lang_data "$line"
  end

  if test (string match -r -- "^ +\S.*:" -- "$line")
    if test (string match -r -- "aliases:" -- "$line"); or test (string match -r -- "extensions:" -- "$line")
      set data_to_write 1
    else
      set data_to_write ""
    end
    if test (string match -r -- "^ +type:" -- "$line")
      if test (string match -r -- "programming" -- "$line")
        set prog_type 1
      else
        set prog_type ""
      end
    end
  end

  if test $data_to_write
    set -a lang_data "$line"
  end

end

# add last language if its type is programming
if test $prog_type
  for line in $lang_data
    echo $line >> $SHARE_PATH/$LANG_DATA_FILE_NAME
  end
end

# remove all '"' and '- '
sed 's/\"//g' $SHARE_PATH/$LANG_DATA_FILE_NAME > $temp
sed 's/\-//' $temp > $SHARE_PATH/$LANG_DATA_FILE_NAME

rm $temp

# fill $ONLY_LANG_FILE_NAME file
for line in (cat $SHARE_PATH/$LANG_DATA_FILE_NAME)

  # finding language section
  set temp_lang (string match -r "^\S.*" -- "$line")

  if test $temp_lang
    set in_aliases_section ""
    echo $aliases >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
    set -e aliases
    set -a aliases $temp_lang
    set -a aliases (string replace -- ":" "" $temp_lang)
    #set temp_lang (string replace -- ":" "" $temp_lang)
    #echo "$temp_lang" >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
  end
  
  if test (string match -r -- "^ +\S.*:" -- "$line")
    if test (string match -r -- "aliases:" -- "$line")
      set in_aliases_section 1
      continue
    else
      set in_aliases_section ""
    end
  end

  if test $in_aliases_section
    set aliases (string join ", " "$aliases" (string replace -- "   " "" "$line"))
    #string replace -- "  " "" "$line" >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
  end

end

echo $aliases >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
