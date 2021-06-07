OUTPATH=DATA/pm_en_te/processed/30k
python train.py

## main parameters
--exp_name xlm_en_te                       # experiment name
--dump_path ./dumped                       # where to store the experiment

## data location / training objective
--data_path $OUTPATH                       # data location
--lgs 'en-te'                              # considered languages
--clm_steps ''                             # CLM objective (for training GPT-2 models)
--mlm_steps 'en,te'                        # MLM objective

## transformer parameters
--emb_dim 1024                             # embeddings / model dimension (2048 is big, reduce if only 16Gb of GPU memory)
--n_layers 12                              # number of layers
--n_heads 16                               # number of heads
--dropout 0.1                              # dropout
--attention_dropout 0.1                    # attention dropout
--gelu_activation true                     # GELU instead of ReLU

## optimization
--batch_size 32                            # sequences per batch
--bptt 256                                 # sequences length  (streams of 256 tokens)
--optimizer adam,lr=0.0001                 # optimizer (training is quite sensitive to this parameter)
--epoch_size 300000                        # number of sentences per epoch
--max_epoch 100000                         # max number of epochs (~infinite here)
--validation_metrics _valid_mlm_ppl        # validation metric (when to save the best model)
--stopping_criterion _valid_mlm_ppl,25     # stopping criterion (if criterion does not improve 25 times)
--fp16 false                                # use fp16 training