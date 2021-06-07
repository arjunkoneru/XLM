#!/bin/bash
src_lang=kn
tgt_lang=en
ROOT=~/XLM_Translation/XLM/
SRCDIR="$ROOT/data/processed/de-en-kn-ta-te/10k_pmindia/"
src_file="$SRCDIR/test".en-kn.$src_lang
model_dir=$ROOT/dumped/multi/de-en-kn-ta-te/joint_cross/finetune
model_path="$model_dir/best-valid_kn-en_mt_bleu.pth"
exp_name="$model_dir/$src_lang-$tgt_lang.sacrebleu"
exp_id=1
DIR=$ROOT/data/processed/de-en-kn-ta-te/synthetic/
hyp_file=$DIR/train.en-kn.$tgt_lang
mkdir -p $DIR
cat $src_file | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $src_lang --tgt_lang $tgt_lang --model_path $model_path --output_path $hyp_file
python $ROOT/preprocess.py $SRCDIR/vocab $hyp_file
cp $SRCDIR/train.en-kn.kn.pth $DIR
