#!/bin/bash
SRC=en
TGT=ne
ROOT=$(pwd "$0")
INDICNLP=$ROOT/tools/indic_nlp_library
DATA=$ROOT/data/rawdata/iitb
TMP=$ROOT/data/flores/
romanize=true
deromanize=false
MOSES=$ROOT/tools/mosesdecoder/scripts
LC=$ROOT/tools/mosesdecoder/scripts/tokenizer/lowercase.perl
mkdir -p $TMP 
TOKENIZE_INDIC=$ROOT/indic_tok.py
function indictokenize() {
	lg=$1
	TRAIN_SETS=(
		"train"
	)
	VALID_SET="valid"
	TEST_SET="test"

	echo "tokenizing train data with $TOKENIZE_INDIC for $lg"
	for FILE in "${TRAIN_SETS[@]}" ; do
		python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/$FILE.$SRC-$TGT.$lg" --output "$TMP/train.$SRC-$TGT.$lg" --romanize $romanize	
	done

	python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${VALID_SET}.$SRC-$TGT.$lg" --output "$TMP/valid.$SRC-$TGT.$lg" --romanize $romanize 
	python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$lg" --input "$DATA/${TEST_SET}.$SRC-$TGT.$lg" --output "$TMP/test.$SRC-$TGT.$lg"  --romanize $romanize
        #perl $LC < $TMP/train.tok.$lg > $TMP/train.$lg
        #perl $LC < $TMP/valid.tok.$lg > $TMP/valid.$lg
        #perl $LC < $TMP/test.tok.$lg > $TMP/test.$lg

}

function mosestokenize(){
	lg=$1
	TRAIN_SETS=(
		"train"
	)
	VALID_SET="valid"
	TEST_SET="test"
	if [ ! -d "$MOSES" ]; then
		cd "tools/"
		git clone https://github.com/moses-smt/mosesdecoder.git 
		cd ../
	fi
	for FILE in "${TRAIN_SETS[@]}" ; do
		tools/mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 8 -l $lg < "$DATA/$FILE.$SRC-$TGT.$lg" > "$TMP/train.$SRC-$TGT.$lg"  
	done
	tools/mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 8 -l $lg < "$DATA/${VALID_SET}.$SRC-$TGT.$lg" > "$TMP/valid.$SRC-$TGT.$lg"
	tools/mosesdecoder/scripts/tokenizer/tokenizer.perl -threads 8 -l $lg < "$DATA/${TEST_SET}.$SRC-$TGT.$lg" > "$TMP/test.$SRC-$TGT.$lg"
	#perl $LC < $TMP/train.tok.$lg > $TMP/train.$SRC-$TGT.$lg
	#perl $LC < $TMP/valid.tok.$lg > $TMP/valid.$SRC-$TGT.$lg
	#perl $LC < $TMP/test.tok.$lg > $TMP/test.$SRC-$TGT.$lg
	#rm -rf $TMP/*.tok.*
}

echo "$ROOT"

if [ ! -d "$INDICNLP" ]; then
	echo "Cloning Indic NLP Library..."
	mkdir "$ROOT/tools"
	git -C "$ROOT/tools" clone https://github.com/anoopkunchukuttan/indic_nlp_library.git
	pushd "$INDICNLP"
	git reset --hard 0a5e01f2701e0df5bc1f9905334cd7916d874c16
	popd
else
	echo "Indic is already pulled from github. Skipping."
fi


if [[ $SRC != "en" ]] && [[ $SRC != "de" ]] && [[ $SRC != "ro" ]]; then
	indictokenize $SRC
else
	echo "Using Moses Tokenizer for $SRC"
	mosestokenize $SRC
fi

if [[ $TGT != "en" ]] && [[ $TGT != "de" ]] && [[ $TGT != "ro" ]]; then
	indictokenize $TGT
else
	echo "Using Moses Tokenizer for $TGT"
	mosestokenize $TGT
fi
