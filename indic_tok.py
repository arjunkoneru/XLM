import argparse
import csv
import os
import sys
import io
import pandas as pd
from indic_transliteration import sanscript
from indic_transliteration.sanscript import SchemeMap, SCHEMES, transliterate

def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("--indic_nlp_path", required=True,
					help="path to Indic NLP Library root")
        parser.add_argument("--language", required=True)
        parser.add_argument("--remove-nuktas", default=False, action="store_true")
        parser.add_argument("--input", required=True, help="path to input file; use - for stdin")
        parser.add_argument("--output", required=True, help="path to output file")
        parser.add_argument("--romanize" , help="romanize the data?",default="false")
        parser.add_argument("--deromanize", help = "Convert back to romanize", default="false")
        parser.add_argument("--evalmode",help="set to True when evaluating", default=False)
        args = parser.parse_args()
        try:
            sys.path.extend([
	                args.indic_nlp_path,
                        os.path.join(args.indic_nlp_path, "src"),
                ])
            from indicnlp.tokenize import indic_tokenize
            from indicnlp.normalize.indic_normalize import IndicNormalizerFactory
        except:
            raise Exception(
			"Cannot load Indic NLP Library, make sure --indic-nlp-path is correct"
		)

	# create normalizer
        factory = IndicNormalizerFactory()
        normalizer = factory.get_normalizer(
		args.language, remove_nuktas=args.remove_nuktas,
	)
        if(args.romanize == "false"):
            romanize = False
        else:
            romanize = True
        if(args.deromanize == "false"):
            deromanize = False
        else:
            deromanize = True
        print("Romanize: ",romanize,"Deromanize: ",deromanize)
        modified = []
        with open(args.input) as data:
            for cnt,line in enumerate(data):
                x = tokenize(line,normalizer,indic_tokenize,romanize,deromanize,args.language,args.evalmode)
                modified.append(x)
        f = io.open(args.output,'w',encoding='utf-8')
        for cnt in range(len(modified)):
            f.write(modified[cnt])
        f.close()
        #df = pd.read_csv(args.input, header = None, sep='\r\n', engine = 'python',skip_blank_lines=False)[0]
        #df = df.apply(tokenize , args = (normalizer,indic_tokenize,romanize,deromanize,args.language,args.evalmode,))
        #df.to_csv(args.output,index = False,header = None,quoting=csv.QUOTE_NONE,quotechar="",escapechar="\\")

	

def tokenize(input_text,normalizer,indic_tokenize, romanize,deromanize,lg,evalmode):
        #output_text = normalizer.normalize(input_text)
        tokenized_text = str(input_text)
        zwnc = u'\u200d'
        zwnc2=u'\u200d@@'
        zwnc3 = u'\u200c'
        zwnc4=u'\u200c@@'
        rep=''
        if(lg == 'en'):
            return tokenized_text
        tokenized_text = tokenized_text.replace(zwnc,rep)
        if(evalmode!=True):
            tokenized_text =' '.join(indic_tokenize.trivial_tokenize(tokenized_text))
        if(deromanize):
            if(lg == "te"):
                tokenized_text = transliterate(tokenized_text, sanscript.HK, sanscript.TELUGU) 
            if(lg == "kn"):
                tokenized_text= transliterate(tokenized_text, sanscript.HK, sanscript.KANNADA)
            if(lg == "ta"):
                tokenized_text= transliterate(tokenized_text, sanscript.HK, sanscript.TAMIL)
            if(lg == "hi" or lg =="ne"):
                tokenized_text= transliterate(tokenized_text, sanscript.ITRANS ,sanscript.DEVANAGARI)
            if(lg == "ml"):
                tokenized_text= transliterate(tokenized_text, sanscript.HK, sanscript.MALAYALAM)
        elif(romanize):
            if(lg == "te"):
                tokenized_text= transliterate(tokenized_text, sanscript.TELUGU, sanscript.HK) 
            if(lg == "kn"):
                #print("romanize")
                tokenized_text= transliterate(tokenized_text, sanscript.KANNADA, sanscript.HK) 
            if(lg == "ta"):
                tokenized_text= transliterate(tokenized_text, sanscript.TAMIL, sanscript.HK)
            if(lg == "hi" or lg == "ne"):
                tokenized_text= transliterate(tokenized_text, sanscript.DEVANAGARI, sanscript.ITRANS)
            if(lg == "ml"):
                tokenized_text= transliterate(tokenized_text, sanscript.MALAYALAM, sanscript.HK)
        x = tokenized_text
        x= x.replace(zwnc,rep)
        x=x.replace(zwnc2,rep)

        return x

if __name__ == '__main__':
	main()
