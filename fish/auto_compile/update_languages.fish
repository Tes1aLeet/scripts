#!/usr/bin/env fish

set SHARE_PATH ~/.local/share/auto_compile
set ALIASES_FILE_NAME available_aliases
set LANG_DATA_FILE_NAME available_languages_data
set ONLY_LANG_FILE_NAME available_languages
set LANG_YML_NAME languages.yml

# if directory doesn't exist then create it
if not test -d $SHARE_PATH
  mkdir $SHARE_PATH 
end

# erase all data in files $ALIASES_FILE_NAME and $LANG_DATA_FILE_NAME
cat /dev/null > $SHARE_PATH/$ALIASES_FILE_NAME
cat /dev/null > $SHARE_PATH/$LANG_DATA_FILE_NAME
cat /dev/null > $SHARE_PATH/$ONLY_LANG_FILE_NAME

# download languages.yml from github-linguist repo
curl https://raw.githubusercontent.com/github-linguist/linguist/master/lib/linguist/languages.yml -o $SHARE_PATH/languages.yml

set temp (mktemp)

# delete commentaries and '---' line
sed '/^#.*/d;1d' $SHARE_PATH/$LANG_YML_NAME > $temp

# fill $LANG_DATA_FILE_NAME file
for line in (cat $temp)

  # if $line is language's name
  if test (string match -r -- "^\S.*:" -- "$line")
    # if also language is programming
    if test "$prog_type"
      for line_1 in $lang_data
        echo $line_1 >> $SHARE_PATH/$LANG_DATA_FILE_NAME
      end
      # write language name to file without ':'
      string replace ":" "" "$lang_data[1]" >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
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
  string replace ":" "" "$lang_data[1]" >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
end

# remove all '"' and '- '
sed 's/\"//g' $SHARE_PATH/$LANG_DATA_FILE_NAME > $temp
sed 's/\-//' $temp > $SHARE_PATH/$LANG_DATA_FILE_NAME

rm $temp

# fill $ALIASES_FILE_NAME file
for line in (cat $SHARE_PATH/$LANG_DATA_FILE_NAME)

  # finding language section
  set temp_lang (string match -r "^\S.*" -- "$line")
  # if in language section
  if test $temp_lang
    set in_aliases_section ""
    echo $aliases >> $SHARE_PATH/$ALIASES_FILE_NAME
    set -e aliases
    set -a aliases $temp_lang
    set -a aliases (string replace -- ":" "" $temp_lang)
  end
  
  # finding aliases section
  if test (string match -r -- "^ +\S.*:" -- "$line")
    if test (string match -r -- "aliases:" -- "$line")
      set in_aliases_section 1
      continue
    else
      set in_aliases_section ""
    end
  end
  # if in aliases section
  if test $in_aliases_section
    set aliases (string join ", " "$aliases" (string replace -- "   " "" "$line"))
  end

end

set temp (mktemp)

# fill $ALIASES_FILE_NAME
# sort by the language name length
cat $SHARE_PATH/$ALIASES_FILE_NAME | awk '{ print length(substr($0, 1, index($0, ":"))), $0 }' | sort -n -s | cut -d" " -f2-  >> $temp 

# delete 1st line (it's empty)
sed '1d' $temp > $SHARE_PATH/$ALIASES_FILE_NAME

rm $temp
