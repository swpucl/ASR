. ./cmd.sh
. ./path.sh

. utils/parse_options.sh
#HLCG 语言模型编码
echo "--------------------- 编码 ---------------------"

model_dir=exp/tri4a_cleaned #model_dir由声学模型生成：final.mdl,tree,etc.
graph_dir=exp/tri4a_cleaned/graph_tg_cl

#local/prepare_dict.sh || exit 1;#mutil_cn 原生字典生成
local/prepare_dict_bigcidian.sh data/local/dict_DaCiDian|| exit 1;#利用bigcidian生成字典

local/train_lms.sh data/local/dict_DaCiDian|| exit 1;

# prepare LM
utils/prepare_lang.sh --position-dependent-phones false \
    data/local/dict_DaCiDian "<UNK>" data/local/lang_DaCiDian data/lang_DaCiDian || exit 1;#生成文件：data/local/lang,data/lang
# train_lms.sh 生成 3gram data/local/lm/3gram-mincount/lm_unpruned.gz
utils/format_lm.sh data/lang_DaCiDian data/local/lm_DaCiDian/3gram-mincount/lm_unpruned.gz \
    data/local/dict_DaCiDian/lexicon.txt data/lang_combined_tg_DaCiDian || exit 1;
utils/mkgraph.sh data/lang_combined_tg_DaCiDian exp/tri4a_cleaned exp/tri4a_cleaned/graph_tg_DaCiDian || exit 1;

echo "--------------------- 解码 ---------------------"
#解码
steps/decode.sh --cmd "$decode_cmd" --config conf/decode.config --nj 10 \
        exp/tri4a_cleaned/graph_tg_DaCiDian data/aishell/test exp/tri4a_cleaned/decode_aishell_test_tg_DaCiDian || exit 1;

echo "--------------------- WER ---------------------"
for x in exp/tri4a_cleaned/decode_aishell_test_*_cl; do
    grep WER $x/cer_* | utils/best_wer.sh
done
