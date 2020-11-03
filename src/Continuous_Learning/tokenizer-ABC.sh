#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ABSTRACTION_JAR_PATH="$HOME/sequencer/src/Buggy_Context_Abstraction/abstraction/lib/abstraction-1.0-SNAPSHOT-jar-with-dependencies.jar"
ABSTRACTION_TOKENIZER_PATH="$HOME/sequencer/src/Buggy_Context_Abstraction/tokenize.py"
TRUNC_UTIL="$HOME/sequencer/src/Buggy_Context_Abstraction/trimCon.pl"
PATCHES_DIR="$HOME/continuous-learning-data-x"
PATCH_PROCESSOR_PATH="$HOME/sequencer/src/Continuous_Learning/tokenize-1.py"
METADATA_PATH="$HOME/sequencer/src/Continuous_Learning/tmp/metadata.dat"

echo "tokenizer-ABC.sh start"
START=$(date +%s.%N)


# load all patches 
PATCH_FILES=$(find $PATCHES_DIR -name "*.java-[0-9]*")

mkdir $CURRENT_DIR/tmp

COUNT=0

# For each patch:
for FILE in $PATCH_FILES; do
  PROCESSOR_OUTOUT=$(python3 $PATCH_PROCESSOR_PATH $FILE 2> /dev/null) 
  # Process patch file

  if [ -z "$PROCESSOR_OUTOUT" ]; then
    echo "could not process patch $FILE"
    continue # no op
  fi

  IFS=' ' read -ra PARAMS <<< "$PROCESSOR_OUTOUT"
  BUGGY_LINE=${PARAMS[0]}
  BUGGY_FILE_PATH=${PARAMS[1]}

  cp "$BUGGY_FILE_PATH" "$BUGGY_FILE_PATH.java" # abstraction does not work if file extension is not .java 
  BUGGY_FILE_PATH="$BUGGY_FILE_PATH.java"

  # writes to target tmp file 
  # outputs (plus-line-number, filename)

  echo "Input parameters:"
  echo "BUGGY_FILE_PATH = ${BUGGY_FILE_PATH}"
  echo "BUGGY_LINE = ${BUGGY_LINE}"
  echo

  BUGGY_FILE_NAME=${BUGGY_FILE_PATH##*/}
  BUGGY_FILE_BASENAME=${BUGGY_FILE_NAME%.*}


  echo "Abstracting the source file"
  # the code of abstraction-1.0-SNAPSHOT-jar-with-dependencies.jar is in https://github.com/KTH/sequencer/tree/master/src/Buggy_Context_Abstraction/abstraction
  java -jar $ABSTRACTION_JAR_PATH $BUGGY_FILE_PATH $BUGGY_LINE $CURRENT_DIR/tmp
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "Cannot generate abstraction for the buggy file"
    continue
  fi
  echo

  echo "Tokenizing the abstraction"
  python3 $ABSTRACTION_TOKENIZER_PATH $CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract.java $CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized.txt
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "Tokenization failed"
    continue
  fi
  echo

  echo "Truncate the abstraction to 1000 tokens"
  perl $TRUNC_UTIL $CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized.txt $CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized_truncated.txt 1000
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "Truncation failed"
    continue
  fi
  echo
  
  # writes to source tmp file 
  cp "$CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized_truncated.txt" "$CURRENT_DIR/tmp/src-single.txt"
  
  SRC_ACC_FILE="$CURRENT_DIR/tmp/src-train-acc.txt"
  TGT_ACC_FILE="$CURRENT_DIR/tmp/tgt-train-acc.txt"
  
  if [[ $COUNT -eq 0 ]]; then
    SRC_ACC_FILE="$CURRENT_DIR/tmp/src-val-acc.txt"
    TGT_ACC_FILE="$CURRENT_DIR/tmp/tgt-val-acc.txt"
  fi

  # append both to final src/tgt files
  cat "$CURRENT_DIR/tmp/src-single.txt" >> $SRC_ACC_FILE
  cat "$CURRENT_DIR/tmp/tgt-single.txt" >> $TGT_ACC_FILE
  
  # remove tmp files
  rm "$CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract.java"
  rm "$CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized.txt"
  rm "$CURRENT_DIR/tmp/${BUGGY_FILE_BASENAME}_abstract_tokenized_truncated.txt"

  # save metadata
  TMP_DATE=$(date +'%d-%m-%Y %H:%M')
  echo "$FILE $TMP_DATE" >> $METADATA_PATH

  COUNT=$(( $COUNT + 1 ))
  COUNT=$(( $COUNT % 20 ))
done

# end foreach

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $DIFF
echo "tokenizer-ABC.sh done"
echo
exit 0
