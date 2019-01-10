#!/bin/bash

optimize_jpg() {
        local infile="$1"
        local outfile="$2"
        convert "$infile" -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB "$outfile"
}
optimize_png() {
        local infile="$1"
        local outfile="$2"
        convert "$infile" -strip "$outfile"
}

optimize_gif() {
        local infile="$1"
        local outfile="$2"
        convert "$infile" -strip "$outfile"
}

main() {
        local infile="$1"
        local outfile="$2"
        case "$infile" in
                *.jpg ) optimize_jpg "$infile" "$outfile";;
                *.jpeg ) optimize_jpg "$infile" "$outfile";;
                *.png ) optimize_png "$infile" "$outfile";;
                *.gif ) optimize_gif "$infile" "$outfile";;
                * ) echo "Error...";;
        esac
}

main "$@"

