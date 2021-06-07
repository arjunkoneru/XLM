#!/bin/bash
src_lang=en
tgt_lang=kn
derom_tgt=false
ROOT=~/XLM_Translation/XLM/
src_file="./data/processed/en-kn-ml-ta-te/10k_pmindia/test".en-kn.$src_lang
model_dir=$ROOT/dumped/multi/en-kn-ml-ta-te/supervised/en-kn/
model_path="$model_dir/best-valid_kn-en_mt_bleu.pth"
exp_name="$model_dir/$src_lang-$tgt_lang.sacrebleu"
exp_id=1
hyp_file=$exp_name/$exp_id/$src_lang-$tgt_lang.hyp.$tgt_lang
#ref_file_orig='./src.te'
ref_file_orig="./data/data_final/test."en-kn.$tgt_lang
INDICNLP=./tools/indic_nlp_library
DETOKENIZE_INDIC=$INDICNLP/src/indicnlp/tokenize/indic_detokenize.py
TOKENIZE_INDIC=./indic_tok.py
MOSES=./tools/mosesdecoder/scripts
DIR=$exp_name/$exp_id
charpy=$ROOT/CharacTER/CharacTER.py
ref_file=$DIR/$src_lang-$tgt_lang.ref.$tgt_lang
LC=./tools/mosesdecoder/scripts/tokenizer/lowercase.perl
mkdir -p $DIR
cp $ref_file_orig $ref_file
cat $src_file | python translate.py --exp_name $exp_name --exp_id $exp_id --src_lang $src_lang --tgt_lang $tgt_lang --model_path $model_path --output_path $hyp_file
sed -r -i 's/(@@ )|(@@ ?$)//g' $hyp_file

function indicdetokenize() {
        lg=$1
        echo detokenizing data with $DETOKENIZE_INDIC for $lg	
	python $DETOKENIZE_INDIC $DIR/hypothesis.derom.$tgt_lang $DIR/hypothesis.$tgt_lang $lg
}

function mosesdetokenize(){
	lg=$1
      	if [ ! -d "$MOSES" ]; then
                cd "tools/"
                git clone https://github.com/moses-smt/mosesdecoder.git
                cd ../
        fi
        tools/mosesdecoder/scripts/tokenizer/detokenizer.perl -l $lg < $hyp_file > $exp_name/$exp_id/hypothesis.$tgt_lang
}

if [[ "$tgt_lang" != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
        echo "deromanizing"
        python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$tgt_lang" --input "$hyp_file" --output "$DIR/hypothesis.derom.$tgt_lang"  --evalmode true --deromanize true
        if [ "$derom_tgt" == "true" ]; then
                python "$TOKENIZE_INDIC" --indic_nlp_path "$INDICNLP" --language "$tgt_lang" --input "$ref_file" --output "$DIR/reference.derom.$tgt_lang" --evalmode true --deromanize true
        fi
fi


if [[ $tgt_lang != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
	indicdetokenize $tgt_lang
else
	mosesdetokenize $tgt_lang
fi

if [[ "$tgt_lang" != "en" ]] && [[ "$tgt_lang" != "de" ]]; then
	if [ "$derom_tgt" == "true" ]; then
		#python retain_numbers.py --input $DIR/hypothesis.derom.$tgt_lang --output $DIR/hypothesis.retain.$tgt_lang --language $tgt_lang
		cat $DIR/hypothesis.$tgt_lang | ~/XLM_Translation/XLM/sacrebleu $DIR/reference.derom.$tgt_lang -tok spm
		#python evalbleu.py --hyp $DIR/hypothesis.derom.$tgt_lang --ref $DIR/reference.derom.$tgt_lang
		python $charpy -o $DIR/hypothesis.$tgt_lang -r $DIR/reference.derom.$tgt_lang
	else
		python retain_numbers.py --input $DIR/hypothesis.$tgt_lang --output $DIR/hypothesis.retain.$tgt_lang --language $tgt_lang
		cat $DIR/hypothesis.retain.$tgt_lang | ~/XLM_Translation/XLM/sacrebleu $ref_file -tok spm 
		#python evalbleu.py --hyp $DIR/hypothesis.retain.$tgt_lang --ref $ref_file
                python $charpy -o $DIR/hypothesis.retain.$tgt_lang -r $ref_file	
	fi
else
	cat $DIR/hypothesis.$tgt_lang | ~/XLM_Translation/XLM/sacrebleu $ref_file -tok spm
	#python evalbleu.py --hyp $DIR/hypothesis.$tgt_lang --ref $ref_file
	python $charpy -o $DIR/hypothesis.$tgt_lang -r $ref_file	
fi
