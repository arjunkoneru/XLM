# XLM-with-cross-translation
This repo add cross translation loss to [XLM](https://github.com/facebookresearch/XLM). To reproduce the paper [Unsupervised Machine Translation on Dravidian Languages](https://www.aclweb.org/anthology/2021.dravidianlangtech-1.7.pdf) follow these steps

1. Clone into XLM
2. Copy train.py and src folder to your copy of XLM
3. Use cross translation similarly to back translation (pt-steps 'en-kn-te,te-kn-en' to do cross translation using English-Telugu parallel data and Kannada as language
where we generate intermediate translations)

**NOTE** - Make sure that you have validation and test data for all languages used in the cross translation. If you do not have this data, you can do small modification to the code
or create some dummy files.
