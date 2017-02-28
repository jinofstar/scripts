#!/bin/sh

function convert {
    if [ -z "$1" ]; then
        echo "Usage : convert filename charset"
        return;
    fi

    if [ -z "$2" ]; then
        echo "Usage : convert filename charset"
        return;
    fi

    filename=$1
    filetype=$2

    tempName=${filename}~temp~.txt

    echo "convert $filetype to utf-8" "$filename"
    mv "$filename" "$tempName"
    iconv -c -f $filetype -t utf-8 "$tempName" > "$filename"
    rm "$tempName"
}

function convert_file {
    filename=$1
    echo "convert_file : $filename"

    charset=
    chmod 0666 "$filename"
    xattr -d com.apple.FinderInfo "$filename" > /dev/null 2>&1
    xattr -d com.apple.TextEncoding "$filename" > /dev/null 2>&1

    encoding=`file --mime-encoding "$filename"`
    filetype=${encoding##*:}

    #TODO case statement
    if [[ "$filetype" =~ "iso-8859-1" ]]; then
        charset="euc-kr"
    elif [[ "$filetype" =~ "utf-16le" ]]; then
        charset="utf-16le"
    elif [[ "filetype" =~ "iso-2022-kr" ]]; then
        charset="iso-2022-kr"
    elif [[ "$filetype" =~ "unknown-8bit" ]]; then
        charset="CP949"
    elif [[ "$filetype" =~ "utf-16be" ]]; then
        echo "utf-16be" "$filename"
    elif [[ "$filetype" =~ "utf-8" ]]; then
        echo "utf-8 is skipping" "$filename"
    elif [[ "$filetype" =~ "binary" ]]; then
        echo "binary" "$filename"
    else
        echo "$filetype is not converted!"
    fi

    if [[ -n "$charset" ]]; then
        convert "$filename" "$charset"
    fi
}

function convert_dir {
    echo "convert_dir $1"
    dir=$1

    find "$dir" -name "*.smi" -o -name "*.srt" | while read filename
    do
        echo "$filename"
        convert_file "$filename"
    done
}

echo
if [ -z $1 ]; then
    dir="."
elif [ -d $1 ]; then
    dir=$1
elif [ -f $1 ]; then
    convert_file $1
    exit 1
fi

convert_dir $dir
