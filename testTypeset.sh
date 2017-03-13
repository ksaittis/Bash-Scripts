set -A filenames $(ls $1)
typeset -L14 fname
let numcols=5

for ((count = 0; count < ${#filenames[*]} ; count++)); do
    fname=${filenames[count]}
    print -rn "$fname  "
    if (( (count+1) % numcols == 0 )); then
        print           # newline
    fi
done

if (( count % numcols != 0 )); then
    print
fi