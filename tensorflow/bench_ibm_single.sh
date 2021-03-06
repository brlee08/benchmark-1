#/bin/bash

DATA_DIR=/nvme3T/brlee/imagenet/tfrecord
LOG_DIR=/gpfs/gpfs_gl4_16mb/b7p284za/benchmark/tensorflow/output_single
#EVAL_DIR=/gpfs/gpfs_gl4_16mb/b7p284za/benchmark/tensorflow/eval_single
TIMESTAMP=$(date +%m%d%H%M)

#EVALUATION SETTING
TRAIN_DIR=/gpfs/gpfs_gl4_16mb/b7p284za/benchmark/tensorflow/train_log
SUMMARY_VERBOSITY=1
SUMMARIES_STEPS=1000

SAMPLE_SIZE=1281167
NUM_EPOCHS=10
NUM_GPU=4

INPUT_BATCH=128
INPUT_MODEL="googlenet"
#INPUT_MODEL="alexnet"
#INPUT_MODEL="vgg11"
#INPUT_MODEL="vgg16"
#INPUT_MODEL="vgg19"
#INPUT_MODEL="lenet"
#INPUT_MODEL="overfeat"
#INPUT_MODEL="trivial"
#INPUT_MODEL="inception3"
#INPUT_MODEL="inception4"
#INPUT_MODEL="resnet50"
#INPUT_MODEL="resnet101"
#INPUT_MODEL="resnet152"

NUM_BATCHES=$((${SAMPLE_SIZE} * ${NUM_EPOCHS} / ${INPUT_BATCH} / ${NUM_GPU}))
#NUM_BATCHES=1000
VARIABLE_UPDATE=replicated

echo "NUM_BATCHES : ${NUM_BATCHES}"
source /opt/DL/tensorflow/bin/tensorflow-activate
export PYTHONPATH=/gpfs/gpfs_gl4_16mb/b7p284za/anaconda3/lib/python3.6/site-packages

mkdir -p ${LOG_DIR}

train() {
    MODEL=$1
    BATCH_SIZE=$2
    TIMESTAMP=$(date +%m%d%H%M)
    LOG_FILE="${LOG_DIR}/output_${MODEL}_e${NUM_EPOCHS}_b${BATCH_SIZE}.${TIMESTAMP}.log"
    python tf_cnn_benchmarks/tf_cnn_benchmarks.py \
        --model=${MODEL} --batch_size=${BATCH_SIZE} --num_batches=${NUM_BATCHES} --num_gpus=${NUM_GPU} \
        --data_name=imagenet --train_dir=${TRAIN_DIR} --data_dir=${DATA_DIR} --variable_update=${VARIABLE_UPDATE} \
	--summary_verbosity=${SUMMARY_VERBOSITY} --save_summaries_steps=${SUMMARIES_STEPS} \
        2>&1 | tee ${LOG_FILE}
}

time train ${INPUT_MODEL} ${INPUT_BATCH}
