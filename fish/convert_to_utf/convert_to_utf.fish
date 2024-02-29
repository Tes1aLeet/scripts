#! /usr/bin/env fish

#
# simple fish script that converts file to utf-8
#
# prefers russian language over others (enca -L russian)
# for example: any 8 bit encoding will be recognized as russian even if it's not
#
# requiers enca to run
#


argparse 'L/language=' 'h/help' 'no_backup' 'list_languages' -- $argv

if [ $_flag_list_languages ]
  command enca --list languages
  exit 0
end

# display help if flag -h/--help is set or no file specified 
if [ $_flag_h ]; or [ -z $argv ]
  echo "Usage: convert_to_utf [OPTION]... [FILE]"
  echo "Converts file to utf-8 using enca"
  echo
  echo "Available options: "
  echo " -l, --language [LANGUAGE] selects preferable language (english, chinese, etc). Russian by default"
  echo "                           for example: when language is set to russian any 8 bit encoding will be"
  echo "                           recognized as russian"
  echo "     --list_languages      lists all available languages"
  echo
  echo "     --no_backup           prevents creating of backup file (FILE.bak)"
  echo " -h, --help                see this help"
  exit 0
end

# set russian by default (if not set)
if [ ! $_flag_language ]
  set -f _flag_language 'russian'
end

set -l name $argv[1]

# if there's no such file then abort
if [ ! -f $name ]
  echo No such file \'$name\'
  exit 1
end

# if no-backup flag is not set then do a backup
if [ ! $_flag_no_backup ]
  cp $name $name.bak
end

# get encoding with enca and put it in $encoding variable
if ! set -l encoding $(enca -r -L $_flag_language $name) 
  exit 1
end

if [ $encoding = 'UTF-8' ]
  echo Nothing to do... Already in UTF-8!
  exit 1
end


# if iconv returned successfuly
if iconv -f $encoding -t UTF-8 -o $name $name
  echo Successfuly converted file \'$name\' from $encoding to UTF-8 
  exit 0
else
  exit 1
end
