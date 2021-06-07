#!/bin/bash
SRC=en
TGT=hi
ROOT=$(pwd "$0")
INDICNLP=$ROOT/tools/indic_nlp_library
DATA=$ROOT/data_old/en-hi-ne/
TMP=$ROOT/data/multi/en-hi-te-data/
mkdir -p $TMP
romanize=true
LC=$ROOT/tools/mosesdecoder/scripts/tokenizer/lowercase.perl
TOKENIZE_INDIC=$ROOT/indic_tok.py
TRAIN_SETS=(
         "train"
        )
VALID_SET="valid"
TEST_SET="test"
#TRASH=$TMP/trash
#mkdir -p $TRASH
for lg in "$SRC" "$TGT" ; do   
	echo "tokenizing train data with $TOKENIZE_INDIC for $lg"
	for FILE in "${TRAIN_SETS[@]}" ; do
		python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/$FILE.$lg" --output "$TMP/train.$SRC-$TGT.$lg" --romanize $romanize
		#perl $LC < $TRASH/$FILE.$lg > $TMP/train.$lg	
		#python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/$FILE.$SRC-$TGT.$lg" --output "$TMP/train.$SRC-$TGT.$lg" --romanize $romanize 
		#perl $LC < $TRASH/$FILE.$SRC-$TGT.$lg > $TMP/$FILE.$SRC-$TGT.$lg
	done
	python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${VALID_SET}.$lg" --output "$TMP/valid.$SRC-$TGT.$lg"  --romanize $romanize
	#perl $LC < $TRASH/valid.$lg > $TMP/valid.$lg
	#python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${VALID_SET}.$SRC-$TGT.$lg" --output "$TMP/valid.$SRC-$TGT.$lg"  --romanize $romanize
	#perl $LC < $TRASH/valid.$SRC-$TGT.$lg > $TMP/valid.$SRC-$TGT.$lg
	python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${TEST_SET}.$lg" --output "$TMP/test.$SRC-$TGT.$lg"  --romanize $romanize
        #perl $LC < $TRASH/test.$lg > $TMP/test.$lg	
	#python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${TEST_SET}.$SRC-$TGT.$lg" --output "$TMP/test.$SRC-$TGT.$lg"  --romanize $romanize
	#perl $LC < $TRASH/test.$SRC-$TGT.$lg > $TMP/test.$SRC-$TGT.$lg	
done
