import pandas as pd
import argparse
import sys
import os

parser = argparse.ArgumentParser(description = 'Extract parallel data from PMIndia datasets')
parser.add_argument('--pair', type = str, metavar = '', required = True, help = 'Langauage pair in the form of src-tgt')
parser.add_argument('--savedir', type = str, metavar = '', help = 'PATH to save parallel data files')
parser.add_argument('--datadir', type = str, metavar = '', help = 'PATH to data folder if it is not current working directory')
args = parser.parse_args()


def parallel():
	lgs = args.pair.split('-')
	if(len(lgs)!=2):
		print("Enter Language Pair in the format of src-tgt")
		sys.exit(0)
	else:
		src = lgs[0]
		tgt = lgs[1]
	if(src == tgt):
		print("{} is entered as source and target, Extract monolingual corpora instead".format(src))
		sys.exit(0)
	print("Extracting parallel data for {}->{}".format(src,tgt))
	if(src!='en' and tgt!='en'):
		print("Aligning data using english as pivot")
		df_src = read_data(src)
		df_tgt = read_data(tgt)
		src_match = []
		tgt_match = []
		for src_index,src_sent in df_src['en'].items():
			matches = df_tgt[df_tgt['en'] == src_sent]
			if(len(matches)==1):
				tgt_match.append(matches.index[0])
				src_match.append(src_index)
			elif(len(matches)>1): ## Each sentence has multiple valid translations, so map to all the translations
				for match in matches.index:
					tgt_match.append(match)
					src_match.append(src_index)
		df_parallel = df_src.loc[src_match]
		df_parallel[tgt] = list(df_tgt.loc[tgt_match][tgt])
		df_parallel = df_parallel.drop('en',axis = 1) ## Remove english data and store only the parallel sentences
	else:
		if(src == 'en'): ## Change source and target order to match the name in the files
			tmp = tgt
			tgt = src
			src = tmp
		df_parallel = read_data(src)
	split_data(df_parallel,src,tgt)

def split_data(df_parallel,src,tgt):
	## Split data in 80,10,10 split. change if needed
	df_parallel = df_parallel.sample(frac = 1, random_state = 0).reset_index(drop=True)
	total_sentences = df_parallel.shape[0]
	train_set = 0.8
	valid_set = 0.1
	test_set = 0.1
	train_sentences = int(0.8 * total_sentences)
	valid_sentences = int(0.1 * total_sentences)
	test_sentences = total_sentences - train_sentences - valid_sentences
	src_train = df_parallel[0:train_sentences][src]
	src_valid = df_parallel[train_sentences:train_sentences + valid_sentences][src]
	src_test = df_parallel[train_sentences + valid_sentences:][src]
	tgt_train = df_parallel[0:train_sentences][tgt]
	tgt_valid = df_parallel[train_sentences:train_sentences + valid_sentences][tgt]
	tgt_test = df_parallel[train_sentences + valid_sentences:][tgt]
	if(args.savedir!=None):
		fpath = args.savedir
	else:
		fpath = './data/rawdata_' + src + "-" + tgt
	if not os.path.exists(fpath):
		os.mkdir(fpath)
	print("Saving Files in {}".format(fpath))
	src_train.to_csv(fpath +'/train.' + src,index = False,header = None)
	src_valid.to_csv(fpath +'/valid.' + src,index = False,header = None)
	src_test.to_csv(fpath +'/test.' + src,index = False,header = None)
	tgt_train.to_csv(fpath +'/train.' + tgt,index = False, header = None)
	tgt_valid.to_csv(fpath +'/valid.' + tgt,index = False, header = None)
	tgt_test.to_csv(fpath +'/test.' + tgt,index = False, header = None)

def read_data(lg):
	## Because of noise in the datasets specific to each language, some rows are removed/skipped
	if(args.datadir==None):
		fpath = r".\pmindia.v1." + lg + "-en" + ".tsv"
	else:
		fpath = args.datadir + "pmindia.v1." + lg + "-en" + ".tsv"
	if(lg == "te"):
		df_telugu = pd.read_csv(fpath, sep='\t',header = None)
		df_telugu.columns = ['en', lg]
		df_telugu = df_telugu.drop(6136)
		return df_telugu
	if(lg == "kn"):
		df_kannada = pd.read_csv(fpath, sep='\t',header = None,skiprows = [29597])
		df_kannada.columns = ['en', lg]
		return df_kannada

if __name__=='__main__':
	parallel()



