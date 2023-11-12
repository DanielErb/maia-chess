import os
import os.path
import random
import shutil

random.seed(1)

#
#train_dir = '../data/pgns_ranged_training/'
#test_dir = '../data/pgns_ranged_testing/'
target_per_year = 20

def main():
    print("Current Working Directory:", os.getcwd())
    print("started replication-move_training.py")
    script_dir = os.path.dirname(os.path.abspath(__file__))
    train_dir = os.path.join(script_dir, '../data/pgns_ranged_training/')
    test_dir = os.path.join(script_dir, '../data/pgns_ranged_testing/')
    pgns_ranged_blocks_dir = os.path.join(script_dir, '../data/pgns_ranged_blocks/')
    
    for elo in sorted(os.scandir(pgns_ranged_blocks_dir), key=lambda x: x.name):
        if elo.name in ['1000','2000']:
            continue
        print(elo.name)
        train_path = os.path.join(train_dir, elo.name)
        os.makedirs(train_path, exist_ok = True)
        test_path = os.path.join(test_dir, elo.name)
        os.makedirs(test_path, exist_ok = True)
        count_train = 0
        num_missing = 0
        count = 0
        for year in sorted(os.scandir(elo.path), key = lambda x : x.name):
            #targets = sorted(os.scandir(year.path), key = lambda x : int(x.name.split('.')[0]))[:-1] for some unexpected reason, they excluded the last item and just didnt do anything with it
            targets = sorted(os.scandir(year.path), key = lambda x : int(x.name.split('.')[0]))
            print(targets)
            if year.name == '2019':
                for i, t in enumerate(targets[-3:]):
                    shutil.copy(t.path, os.path.join(test_path, f"{i+1}.pgn"))
                targets = targets[:-3]
            random.shuffle(targets)
            for t in targets[:target_per_year + num_missing]:
                count_train += 1
                shutil.copy(t.path, os.path.join(train_path, f"{count_train}_{year.name}.pgn"))
            if len(targets[:target_per_year + num_missing]) < target_per_year + num_missing:
                num_missing = target_per_year + num_missing - len(targets[:target_per_year + num_missing])
            else:
                num_missing = 0
            c = len(os.listdir(year.path))
            print(year.name, c, count_train)
            count += c
        print(f"Total count for ELO {elo.name}: {count}")
    

if __name__ == '__main__':
    main()
