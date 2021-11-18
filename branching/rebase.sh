#!/bin/bash
# display command line options

count=1
for param in "$@"; do
<<<<<<< HEAD
    echo "\$@ Parameter #$count = $param"
=======
    count=$(( $count + 1 ))
=======
   echo "Next parameter: $param"
   count=$(( $count + 1 ))
>>>>>>> 7ca5030... git-rebase 2
done

echo "====="

