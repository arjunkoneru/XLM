import sacrebleu
import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--hyp", required=True, help = "path to hypothesis file")
parser.add_argument("--ref", required=True, help = "path to reference file")
args = parser.parse_args()

def main():
    hyp = pd.read_csv(args.hyp, header = None, sep='\r\n', engine = 'python',skip_blank_lines=False,escapechar="\\")
    ref = pd.read_csv(args.ref, header = None, sep = '\r\n', engine = 'python',skip_blank_lines=False)
    hyp.fillna(" ",inplace=True)
    hyp = hyp[hyp.columns[0]].tolist()
    ref = ref[ref.columns[0]].tolist()
    print(hyp[1])
    print(ref[1])
    print("Number of reference sentences", len(ref))
    print("Number of hypothesis sentences", len(hyp))
    bleu = sacrebleu.corpus_bleu(hyp, [ref])
    print("Sacrebleu score -----> {}".format(bleu.score))
if __name__ == '__main__':
	main()
