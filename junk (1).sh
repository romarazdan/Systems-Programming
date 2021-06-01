###############################################################################
# Author: Michael Zylka, Roma Razdan
# Date: 2/11/2021
# Pledge: I pledge my honor that I have abided by the Stevens Honor System.
# Description: Creates a directory called junk and moves files into the junk
#              directory to allow user to recover the file.
###############################################################################
#!/bin/bash

get_user=$(whoami)
readonly junk_dir="/home/"$get_user"/.junk"

help_flag=0
list_flag=0
purge_flag=0

while getopts ":hlp" option; do
    case "$option" in
        h) help_flag=1
            ;;
        l) list_flag=1
            ;;
        p) purge_flag=1
            ;;
        ?) printf "Error: Unknown option '-%s'.\n" $OPTARG >&2
            help_flag=1
            ;;
    esac
done

count=$(( help_flag + list_flag + purge_flag))

shift "$((OPTIND-1))"

if [ $count -gt 1 ]; then
    echo "Error: Too many options enabled."
    help_flag=1
fi

if  [ $# -eq 0 ] && [ $count -eq 0 ] || [ $count -gt 1 ] || [ $help_flag -eq 1 ]; then
cat <<HEREDOC
Usage: junk.sh [-hlp] [list of files]
    -h: Display help.
    -l: List junked files.
    -p: Purge all files.
HEREDOC
    exit 1
fi

if [ ! -d $junk_dir ]; then
    $(mkdir $junk_dir)
fi

if [ $list_flag -eq 1 ]; then
    #echo -n "total "
    file_count=$( ls -lAF $junk_dir | wc -l 2>/dev/null)  
    const=3
    total=$(($file_count-$const))
    #echo $total
    ls -lAF $junk_dir
fi

if [ $purge_flag -eq 1 ]; then
    $(rm -r $junk_dir)
    $(mkdir $junk_dir)
fi

for f in "$@"; do

    file_listing=$(ls -l "$f" 2>/dev/null)
    if [ ! -z "$file_listing" ]; then
        file_name=$(basename $f)
        $(mv $f $junk_dir/$file_name)
    else
        echo "Warning: '"$f"' not found."
    fi
done

exit 0
