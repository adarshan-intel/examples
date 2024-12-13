#!/bin/bash
# set -e

### Latency runs

# ```bash
# $ KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
#     gramine-sgx benchmark_app -i <image files> \
#     -m model/<public | intel>/<model_dir>/<INT8 | FP16 | FP32>/<model_xml_file> \
#     -d CPU -b 1 -t 20 -api sync
# ```

# Default values
NUM_RUNS=${NUM_RUNS:-1}
IMAGE_FILES=${IMAGE_FILES:-<default_image_files>}
MODEL_DIR=${MODEL_DIR:-model/intel/bert-large-uncased-whole-word-masking-squad-0001/FP16}
MODEL_XML_FILE=${MODEL_XML_FILE:-bert-large-uncased-whole-word-masking-squad-0001.xml}

source openvino_env/bin/activate
make clean && make SGX=1

if [ ! -d "output" ]; then
    mkdir output
fi

# Throughput runs
KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-sgx ./benchmark_app \
    -m $MODEL_DIR/$MODEL_XML_FILE \
    -d CPU -b 1 -t $NUM_RUNS > output/Throughput.txt

# Latency runs
KMP_AFFINITY=granularity=fine,noverbose,compact,1,0 numactl --cpubind=0 --membind=0 \
    gramine-sgx ./benchmark_app -i $IMAGE_FILES \
    -m $MODEL_DIR/$MODEL_XML_FILE \
    -d CPU -b 1 -t $NUM_RUNS -api sync > output/Latency.txt

echo "All runs complete ✅"
