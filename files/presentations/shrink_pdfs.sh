#!bin/bash
# shrink_pdfs.sh
for file in $(find . -name '*.pdf'); do
  ~/shrinkpdf.sh $file > $file
done

wait
echo "**** PROCESS DONE: All PDF files shrunk ****"
