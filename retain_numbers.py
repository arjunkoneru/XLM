from indic_transliteration import sanscript
from indic_transliteration.sanscript import SchemeMap, SCHEMES, transliterate
import pandas as pd
import csv
import argparse

def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("--language", required=True)
        parser.add_argument("--input", required=True, help="path to input file; use - for stdin")
        parser.add_argument("--output", required=True, help="path to output file")
        args = parser.parse_args()
        with open(args.input,mode='r',encoding='utf-8') as data:
            with open(args.output,mode='w',encoding='utf-8') as output:
                for line in data:
                    line = retain_numbers(str(line),args.language)
                    output.write(line)

def retain_numbers(txt,lg):
    nums = [ 0,1,2,3,4,5,6,7,8,9,'.']
    if (lg == 'te'):
        keys = [transliterate(str(x),sanscript.HK, sanscript.TELUGU) for x in nums ]
    if (lg == 'kn'):
        keys = [transliterate(str(x),sanscript.HK, sanscript.KANNADA) for x in nums ]
    txt = list(txt)
    for i in range(len(txt)):
        if txt[i] in keys:
            if (lg == 'te'):
                txt[i] = transliterate(txt[i],sanscript.TELUGU, sanscript.HK)
            if (lg == 'kn'):
                txt[i] = transliterate(txt[i],sanscript.KANNADA, sanscript.HK)
        if (txt[i] == '|'):
            txt[i]='.'
    return "".join(txt)

if __name__ == '__main__':
        main()

