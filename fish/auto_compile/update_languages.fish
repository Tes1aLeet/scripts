#!/usr/bin/env fish

set SHARE_PATH ~/.local/share/auto_compile
set ONLY_LANG_FILE_NAME available_languages
set LANG_DATA_FILE_NAME available_languages_data

# if directory doesn't exist then create it
if not test -d $SHARE_PATH
  mkdir $SHARE_PATH 
end

# erase all data in files $ONLY_LANG_FILE_NAME and $LANG_DATA_FILE_NAME
cat /dev/null > $SHARE_PATH/$ONLY_LANG_FILE_NAME
cat /dev/null > $SHARE_PATH/$LANG_DATA_FILE_NAME

# download languages.yml from github-linguist repo
#curl https://raw.githubusercontent.com/github-linguist/linguist/master/lib/linguist/languages.yml -o $SHARE_PATH/languages.yml

set temp (mktemp)
set temp_2 (mktemp)

# delete commentaries
sed '/^#.*/d' $SHARE_PATH/languages.yml > $temp_2
# delete --- line and write
sed '/---/d' $temp_2 > $temp

rm $temp_2

# set $prog_type to 1 to write first language's name to file
set prog_type 1

# fill $LANG_DATA_FILE_NAME file
for line in (cat $temp)

  # check if line is language section
  set temp_lang (string match -r -- "^\S*" "$line")
  # if it is a language section
  if test $temp_lang
    set -a lang_data $line
    # if it is also a programming language then write to file
    if test $prog_type
      for line_1 in $lang_data
        echo $line_1 >> $SHARE_PATH/$LANG_DATA_FILE_NAME
      end
    end
    # erase $lang_data list when encountering next language
    set -e lang_data
  end
  
  # check if in any section
  if test (string match -r -- "^ +\S*:" -- "$line")
    # check if in type section
    if test (string match -r -- "^ +type:" -- "$line")
      # check if type of language is programming
      if test (string match -r -- "programming" -- "$line")
        set prog_type 1 
      else
        set prog_type ""
      end
    end
    # check if in aliases section
    if test (string match -r -- "^ +aliases:" -- "$line")
      set write_data 1 
    else
      set write_data ""
    end

    if test (string match -r -- "^ +extensions:" -- "$line")
      set write_data 1
    else
      set write data ""
    end

  end

  if test $write_data
    set -a lang_data $line
  end

end

# write last language to file $LANG_DATA_FILE_NAME
if test $prog_type
  for line in $lang_data
    echo $line >> $SHARE_PATH/$LANG_DATA_FILE_NAME
  end
end


# fill $ONLY_LANG_FILE_NAME file
for line in (cat $SHARE_PATH/$LANG_DATA_FILE_NAME)

  # check if line is language section
  set temp_lang (string match -r -- "^\S*" "$line")
  # if it is a language section
  if test $temp_lang
    string replace ":" "" $line >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
  end

  # check if in any section
  if test (string match -r -- " +\S*:" -- "$line")
    # check if in aliases section
    if test (string match -r -- "^ +aliases:" -- "$line")
      set in_alias_section 1
      continue
    else
      set in_alias_section ""
    end
  end

  # if language is programming and current section is aliases
  # then write current line to file
  if test $in_alias_section
    string replace "  - " "" "$line" >> $SHARE_PATH/$ONLY_LANG_FILE_NAME
  end

end

# remove repeating lines
sort $SHARE_PATH/$ONLY_LANG_FILE_NAME > $temp
cat $temp > $SHARE_PATH/$ONLY_LANG_FILE_NAME
uniq $SHARE_PATH/$ONLY_LANG_FILE_NAME > $temp
cat $temp > $SHARE_PATH/$ONLY_LANG_FILE_NAME

rm $temp
