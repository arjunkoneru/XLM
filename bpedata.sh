#!/bin/bash

SRC=en
TGT=te
bpecodes=30000
OUTPATH=data/$SRC-$TGT.supervised/wikitest
FASTBPE=tools/fastBPE/fast
pair=$SRC-$TGT
DATA=data/tokendata_en-te
mkdir -p $OUTPATH

echo Saving Data Files in $OUTPATH

if [ "$1" == 'pt' ]; then \
        $FASTBPE learnbpe $bpecodes $DATA/train.$SRC $DATA/train.$TGT > $OUTPATH/codes
        for split in "train" "valid" "test"; do \
                for lg in "$SRC" "$TGT"; do \
                        $FASTBPE applybpe $OUTPATH/$split.$lg $DATA/$split.$lg $OUTPATH/codes
                done
        done
        cat $OUTPATH/train.$SRC $OUTPATH/train.$TGT >> $OUTPATH/train.$SRC-$TGT
        cat $OUTPATH/train.$SRC-$TGT | $FASTBPE getvocab - > $OUTPATH/vocab &
        for split in "train" "valid" "test"; do \
                for lg in "$SRC" "$TGT"; do \
                        python preprocess.py $OUTPATH/vocab $OUTPATH/$split.$lg
                done
        done
fi
if [ "$1" == 'tr' ]
then
        pretrained_codes=$3/codes
        pretrained_vocab=$3/vocab
        echo 'Loading codes from $pretrained_codes '
        echo 'Loading vocab from $pretrained_vocab '
        for split in "train" "valid" "test"; do \
                for lg in "$SRC" "$TGT"; do \
                        if [ $split !=  'train' ]
                        then
				subword-nmt apply-bpe -c $pretrained_codes < $DATA/$split.$lg > $OUTPATH/$split.$SRC-$TGT.$lg
                                #$FASTBPE applybpe $OUTPATH/$split.$SRC-$TGT.$lg $DATA/$split.$lg $pretrained_codes
                                python preprocess.py $pretrained_vocab $OUTPATH/$split.$SRC-$TGT.$lg
				if [ $2 == "usp" ]; then \
					cp $OUTPATH/$split.$SRC-$TGT.$lg.pth $OUTPATH/$split.$lg.pth
				fi	
                        else
                        	if [ $2 == "sp" ]; then \
                                #$FASTBPE applybpe $OUTPATH/$split.$SRC-$TGT.$lg $DATA/$split.$lg $pretrained_codes
					subword-nmt apply-bpe -c $pretrained_codes  < $DATA/$split.$lg > $OUTPATH/$split.$SRC-$TGT.$lg
                                	python preprocess.py $pretrained_vocab $OUTPATH/$split.$SRC-$TGT.$lg
                           	fi
                           	if [ $2 == "usp" ]; then \
                                	#$FASTBPE applybpe $OUTPATH/$split.$lg $DATA/$split.$lg $pretrained_codes
					subword-nmt apply-bpe -c $pretrained_codes  < $DATA/$split.$lg > $OUTPATH/$split.$lg
                                	python preprocess.py $pretrained_vocab $OUTPATH/$split.$lg
                           	fi
                        fi
                done
        done
fi
