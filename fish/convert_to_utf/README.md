# fish script that converts any file to utf-8

## Dependencies

enca

## Usage

<pre>
Usage: convert_to_utf [OPTION]... [FILE]
Converts file to utf-8 using enca

Available options: 
-l, --language=LANGUAGE: selects preferable language (english, chinese, etc (russian by default)).
                         For example: when language is set to russian any 8 bit encoding
                         will be recognized as russian 
--list_languages:        lists all available languages 

-b, --backup:            creates backup file (filename.bak) in the working directory
-h, --help:              see this help
</pre>
