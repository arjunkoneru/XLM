#!/bin/bash
src_lang=kn
ref_lang=te
tgt_lang=en
spfirst=false
derom_tgt=false
ROOT=~/XLM_Translation/XLM/
src_file="./data/processed/en-kn-ml-ta-te/10k_pmindia/test".en-kn.$src_lang
model_dir_sp=$ROOT/dumped/multi/en-kn-ml-ta-te/supervised/en-te_smooth
model_path_sp="$model_dir_sp/best-valid_te-en_mt_bleu.pth"
exp_name="cascaded/$src_lang-$ref_lang-$tgt_lang.sacrebleu"
model_dir_usp=$ROOT/dumped/multi/en-kn-ml-ta-te/unsupervised/te-kn/
model_path_usp="$model_dir_usp/best-valid_kn-te_mt_bleu.pth"
exp_id=1
#ref_file_orig='./src.te'
ref_file_orig="./data/data_final/test."en-kn.$tgt_lang
INDICNLP=./tools/indic_nlp_library
DETOKENIZE_INDIC=$INDICNLP/src/indicnlp/tokenize/indic_detokenize.py
TOKENIZE_INDIC=./indic_tok.py
MOSES=./tools/mosesdecoder/scripts
DIR=~/XLM_Translation/XLM/dumped/$exp_name/$exp_id
ref_file=$DIR/$src_lang-$tgt_lang.ref.$tgt_lang
hyp_file=$DIR/$src_lang-$tgt_lang.hyp.$tgt_lang
LC=./tools/mosesdecoder/scripts/tokenizer/lowercase.perl
charpy=$ROOT/CharacTER/CharacTER.py
mkdir -p $DIR
cp $ref_file_orig $ref_file
if [ $spfirst == "false" ]; then 
	cat $src_file | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $src_lang --tgt_lang $ref_lang --model_path $model_path_usp --output_path $DIR/hyp.$ref_lang
	echo Translated complete for first model!
	cat $DIR/hyp.$ref_lang | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $ref_lang --tgt_lang $tgt_lang --model_path $model_path_sp --output_path $hyp_file
	echo Final translation completed
else
	cat $src_file | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $src_lang --tgt_lang $ref_lang --model_path $model_path_sp --output_path $DIR/hyp.$ref_lang
	cat $DIR/hyp.$ref_lang | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $ref_lang --tgt_lang $tgt_lang --model_path $model_path_usp --output_path $hyp_file
fi
sed -r -i 's/(@@ )|(@@ ?$)//g' $hyp_file

function indicdetokenize() {
        lg=$1
        echo detokenizing data with $DETOKENIZE_INDIC for $lg	
	python $DETOKENIZE_INDIC $hyp_file $DIR/hypothesis.$tgt_lang $lg
}

function mosesdetokenize(){
	lg=$1
      	if [ ! -d "$MOSES" ]; then
                cd "tools/"
                git clone https://github.com/moses-smt/mosesdecoder.git
                cd ../
        fi
        tools/mosesdecoder/scripts/tokenizer/detokenizer.perl -l $lg < $hyp_file > $DIR/hypothesis.$tgt_lang
}

if [[ $tgt_lang != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
	indicdetokenize $tgt_lang
else
	mosesdetokenize $tgt_lang
fi

if [[ "$tgt_lang" != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
	echo "deromanizing"
	python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$tgt_lang" --input "$DIR/hypothesis.$tgt_lang" --output "$DIR/hypothesis.derom.$tgt_lang"  --evalmode true --deromanize true
	if [ "$derom_tgt" == "true" ]; then
		python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$tgt_lang" --input "$ref_file" --output "$DIR/reference.derom.$tgt_lang" --evalmode true --deromanize true
	fi
fi	

if [[ "$tgt_lang" != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
	if [ "$derom_tgt" == "true" ]; then
		python evalbleu.py --hyp $DIR/hypothesis.derom.$tgt_lang --ref $DIR/reference.derom.$tgt_lang
	else
                python retain_numbers.py --input $DIR/hypothesis.derom.$tgt_lang --output $DIR/hypothesis.retain.$tgt_lang --language $tgt_lang
                python evalbleu.py --hyp $DIR/hypothesis.retain.$tgt_lang --ref $ref_file
                python $charpy -o $DIR/hypothesis.retain.$tgt_lang -r $ref_file	
	fi
else
	python evalbleu.py --hyp $DIR/hypothesis.$tgt_lang --ref $ref_file
	python $charpy -o $DIR/hypothesis.$tgt_lang -r $ref_file
fi
