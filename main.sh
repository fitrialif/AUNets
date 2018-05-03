#!/usr/bin/env bash
#USE: ./main.sh -AU 1 -gpu 0 -fold 0
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -mode_data|--mode_data)
    mode="$2"
    shift # past argument
    ;;       
    -AU|-au|--AU|--au)
    declare -a AU=( "$2" )
    shift # past argument
    ;;           
    -gpu|--gpu|-GPU|--GPU)
    gpu_id="$2"
    shift # past argument
    ;;    
    -OF|--OF)
    OF="$2"
    shift # past argument
    ;;      
    -fold|--fold)
    declare -a fold=( "$2" )
    shift # past argument
    ;;   
    -finetuning|--finetuning)
    declare -a finetuning=( "$2" )
    shift # past argument
    ;;    
    -HYDRA|--HYDRA)
    HYDRA=true
    shift # past argument
    ;;           
    *)
esac
shift # past argument or value
done

if [ -z ${OF+x} ]; then OF="None"; fi
if [ -z ${mode_data+x} ]; then mode_data="normal"; fi
if [ -z ${AU+x} ]; then declare -a AU=(1 2 4 6 7 10 12 14 15 17 23 24); fi
if [ -z ${finetuning+x} ]; then declare -a finetuning=("emotionnet"); fi
if [ -z ${fold+x} ]; then declare -a fold=( 0 1 2 ); fi
if [ -z ${HYDRA+x} ]; then HYDRA=false; fi


if [ $OF = "None" ] || [ $OF = "Alone" ]; then 
  batch_size=118 
elif [ $OF = "Horizontal" ] || [ $OF = "Vertical" ]; then 
  batch_size=24
else
  if [ $OF = "Channels" ]; then 
    batch_size=118
  elif [ $OF = "Conv" ]; then 
    batch_size=48 
  else
    if [ $OF = "FC6" ]; then
      batch_size=42
    elif [ $OF = "FC7" ]; then
      batch_size=42
    fi
  fi
fi

for enc in "${finetuning[@]}"
do
  for _fold in "${fold[@]}"
  do
    for au in "${AU[@]}"
    do
      command_train="./main.py -- --batch_size=$batch_size --AU=$au --GPU=$gpu_id \
                    --finetuning=$enc --mode_data=$mode_data --fold=$_fold --OF $OF"
      if [ "$HYDRA" = true ]; then command_train+=" --HYDRA"; fi                      
      echo $command_train
      eval $command_train
      echo ""
    done
  done
done