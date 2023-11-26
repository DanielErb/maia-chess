# Aligning Superhuman AI with Human Behavior: Chess as a Model System

## [website](https://maiachess.com)/[paper](https://arxiv.org/abs/2006.01855)/[code](https://github.com/CSSLab/maia-chess)/[lichess](https://lichess.org/team/maia-bots)

A collection of chess engines that play like humans, from ELO 1100 to 1900.

![The accuracy of the different maias across ELO range](images/all_lineplot.png)

In this repo is our 9 final maia models saved as Leela Chess neural networks, and the code to create more and reproduce our results.

Our [website](https://maiachess.com) has information about the project and team.

You can also play against three of of our models on Lichess:

+ [`maia1`](https://lichess.org/@/maia1) is targeting ELO 1100
+ [`maia5`](https://lichess.org/@/maia5) is targeting ELO 1500
+ [`maia9`](https://lichess.org/@/maia9) is targeting ELO 1900
+ [`MaiaMystery`](https://lichess.org/@/MaiaMystery) is for testing new versions of Maia

We also have a Lichess team, [_maia-bots_](https://lichess.org/team/maia-bots), that we will add more bots to.

## How to Run Maia

The Maias are not a full chess framework chess engines, they are just brains (weights) and require a body to work. So you need to load them with [`lc0`](http://lczero.org) and follow the instructions [_here_](http://lczero.org/play/quickstart). Then unlike most other engines you want to *disable* searching, a nodes limit of 1 is what we use. This looks like `go nodes 1` in UCI. Note also, the models are also stronger than the rating they are trained on since they make the _average_ move of a player at that rating.

The links to download the models directly are:

### Models with Lichess Bots

|Targeted Rating | lichess name | link|
|-----|-----|-----|
|1100|[_maia1_](https://lichess.org/@/maia1)|[`maia-1100.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1100.pb.gz)|
|1500|[_maia5_](https://lichess.org/@/maia5)|[`maia-1500.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1500.pb.gz)|
|1900|[_maia9_](https://lichess.org/@/maia9)|[`maia-1900.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1900.pb.gz)|

The bots on Lichess use opening books that are still in development, since the models play the same move every time.

### Other Models

|Targeted Rating | link|
|-----|-----|
|1200|[`maia-1200.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1200.pb.gz)|
|1300|[`maia-1300.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1300.pb.gz)|
|1400|[`maia-1400.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1400.pb.gz)|
|1600|[`maia-1600.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1600.pb.gz)|
|1700|[`maia-1700.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1700.pb.gz)|
|1800|[`maia-1800.pb.gz`](https://github.com/CSSLab/maia-chess/releases/download/v1.0/maia-1800.pb.gz)|

We also have all the models in the [`maia_weights`](https://github.com/CSSLab/maia-chess/tree/master/maia_weights) folder of the repo.

### Example

When running the models on the command line it should look like this:

```
:~/maia-chess$ lc0 --weights=model_files/maia-1100.pb.gz
       _
|   _ | |
|_ |_ |_| v0.26.3 built Dec 18 2020
go nodes 1
Loading weights file from: model_files/maia-1100.pb.gz
Creating backend [cudnn-auto]...
Switching to [cudnn]...
...
info depth 1 seldepth 1 time 831 nodes 1 score cp 6 tbhits 0 pv e2e4
bestmove e2e4
```

`move_prediction/maia_chess_backend` also has the `LeelaEngine` class that uses the config files `move_prediction/model_files/*/config.yaml` to wrap [`python-chess`](https://python-chess.readthedocs.io) and allow the models to be used in Python.

## Datasets

As part of our analysis all the game on Lichess with stockfish analysis were processed into csv files. These can be found [here](http://csslab.cs.toronto.edu/datasets/#maia_kdd)

## Code

### Move Prediction

To create your own maia from a set of chess games in the PGN format:

1. Setup your environment
   1. (optional) Install the `conda` environment, [`maia_env.yml`](maia_env.yml)
   2. Make sure all the required packages are installed from `requirements.txt`
2. Convert the PGN into the training format
   1. Add the [`pgn-extract`](https://www.cs.kent.ac.uk/people/staff/djb/pgn-extract/) tool to your path
   2. Add the [`trainingdata-tool`](https://github.com/DanielUranga/trainingdata-tool) to your path
   3. Run `move_prediction/pgn_to_trainingdata.sh PGN_FILE_PATH OUTPUT_PATH`
   4. Wait a bit as the processing is both IO and CPU intense
   5. The script will create a training and validation set, if you wish to train on the whole set copy the files from `OUTPUT_PATH/validation` to `OUTPUT_PATH/training`
3. Edit `move_prediction/maia_config.yml`
   1. Add  `OUTPUT_PATH/training/*/*` to `input_train`
   2. Add  `OUTPUT_PATH/validation/*/*` to `input_test`
   3. (optional) If you have multiple GPUS change the `gpu` filed to the one you are using
   4. (optional) You can also change all the other training parameters here, like the number of layers
4. Run the training script `move_prediction/train_maia.py PATH_TO_CONFIG`
5. (optional) You can use tensorboard to watch the training progress, the logs are in `runs/CONFIG_BASENAME/`
6. Once complete the final model will be in `models/CONFIG_BASENAME/` directory. It will be the one with the largest number

### Replication

To train the models we present in the paper you need to download the raw files from Lichess then cut them into the training sets and process them into the training data format. This is a similar format to the general training instructions just with our specified data, so you will need to have `trainingdata-tool` and `pgn-extract` on your PATH.

~Also note that running the scripts manually line by line might be necessary as they do not have any flow control logic because we were too lazy to implement it. And that `move_prediction/replication-move_training_set.py` is where the main shuffling and games selection logic is.~

**Flow control logic is now implemented.**
1. Setup your environment
   1. Install the `conda` environment, [`maia_env.yml`](maia_env.yml) - you will need to work with it the entire time so dont forget to activate
   2. Make sure all the required packages are installed from `requirements.txt`
2. Download the games from [Lichess](https://database.lichess.org/) between January 2017 and November 2019 to `data/lichess_raw`
3. (Optional) For simplicity - Give the entire directory running permissions `chmod -R +x directory_name` - otherwise give only to scripts which you run (do notice that some scripts run others so you will need to inspect the code and
see which one need executing/reading writing permissions).
4. The downloaded games from `Lichess` are .pgz.zst format, code wasn't updated in years and still relies on the old format of .bz2 so you will need to run `move_prediction/convert-zst.sh` - make sure you have 
packages `bzip2` and `zstd`.
you will be left with both .pgn.zst and .bz2 files, you can store the .pgn.zst files in another directory for future use but **_DO NOT_ keep them in `data/lichess_raw`**
5. Run `move_prediction/create_trainingFolders.sh`.
6. Run `move_prediction/replication-generate_pgns-all.sh <elo-start> <elo-end> <elo-step>`. For example, to run from elo 1100 to 1900 in steps of 100: `move_prediction/replication-generate_pgns-all.sh 1100 1900 100`.
7. Run `move_prediction/replication-move_training_set.py`.
   1. (optional) - in relation to 6.1, if you are running on different data rather then the one we tested on you will need to modify the file - currently it take september 2019 - november 2019 and from them constructs
      the test file. If you wish to this manually there is another option in section 8.2.
8. Run `move_prediction/replication-make-leela-files-all.sh <elo-start> <elo-end> <elo-step>`. For example, to run from elo 1100 to 1900 in steps of 100: `move_prediction/replication-make-leela-files-all.sh 1100 1900 100`.
   * (optional) if you haven't downloaded septeber 2019 - november 2019 and didnt modify the script in 7 you can manually get the test files -
      for example, in the end you will have all the train files for specific elo here `data/elo_ranges/{elo}/train/{train directories}/supervised-0/`,
      in order to train maia for a spesific elo you will need both train file and test files, you will need to copy manually some file form the train files which i mentioned,
      and copy at least 10 of them to `data/elo_ranges/{elo}/test/{1-3.pgn}/supervised-0/` - noted that this option is not recommended because it creates a mix up between train and test files, but if you just wish
      to test the maia training process this is the best option.
9. Edit `move_prediction/maia_config.yml` and add the elo you want to train:
   1. input_test : `../data/elo_ranges/${elo}/test/*/*`
   2. output_train : `../data/elo_ranges/${elo}/train/*/*`
   3. make sure that you write the full path and not the relative path, because it creates problems depending from where you run the python script,
      so for example: ```
                     /home/daniel/Documents/Maia/maia-chess/data/elo_ranges/1400/train/*/*
                     ```
10. Run the training script `move_prediction/train_maia.py PATH_TO_CONFIG`
11. (optional) You can use tensorboard to watch the training progress, the logs are in `runs/CONFIG_BASENAME/` example:
 ```bash
   tensorboard --logdir=runs
```
We also include some other (but not all) config files that we tested. Although, we still recommend using the final config `move_prediction/maia_config.yml`.

If you wish to generate the testing set we used you can download the December 2019 data and run `move_prediction/replication-make_testing_pgns.sh`. The data is also avaible for download as a CSV [here](http://csslab.cs.toronto.edu/data/chess/kdd/maia-chess-testing-set.csv.bz2). The script for running models on the dataset is [`replication-run_model_on_csv.py`](move_prediction/replication-run_model_on_csv.py) and requires the `lc0` binary on the path.

### Blunder Prediction

To train the blunder prediction models follow these instructions:

1. Setup your environment
   1. (optional) Install the `conda` environment, [`maia_env.yml`](maia_env.yml)
2. Make sure all the required packages are installed from `requirements.txt`
3. Run `blunder_prediction/make_csvs.sh`
   1. You will probably need to update the paths, and may want to change the targets or use a for loop
4. Run `blunder_prediction/mmap_csv.py` on all the csv files
5. Select a config from `blunder_prediction/configs` and update the paths
6. Run `blunder_prediction/train_model.py CONFIG_PATH

## Citation

```
@inproceedings{mcilroyyoung2020maia,
  title={Aligning Superhuman AI with Human Behavior: Chess as a Model System},
  author={McIlroy-Young, Reid and  Sen, Siddhartha and Kleinberg, Jon and Anderson, Ashton},
  year={2020},
  booktitle={Proceedings of the 25th ACM SIGKDD international conference on Knowledge discovery and data mining}
}
```

## License

The software is available under the GPL License.

## Contact

Please [open an issue](https://github.com/CSSLab/maia-chess/issues/new) or email [Reid McIlroy-Young](https://reidmcy.com/) to get in touch
