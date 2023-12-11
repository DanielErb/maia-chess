import argparse
import os
import pandas as pd
import bz2
import matplotlib.pyplot as plt

def read_data(file_path):
    if file_path.endswith('.csv'):
        print(f'Reading {file_path}')
        data = pd.read_csv(file_path)
    else:
        with bz2.open(file_path, 'rt') as file:
            print(f'Reading {file_path}')
            data = pd.read_csv(file)
    return data

def smooth_and_calculate_accuracy(data, elo_interval=100):
    elo_buckets = data.groupby(data['elo'] // elo_interval * elo_interval)
    smoothed_accuracy = elo_buckets['model_correct'].mean()
    return smoothed_accuracy

def main():
    parser = argparse.ArgumentParser(description='Generate a plot of Model Accuracy vs Elo for files in subdirectories.')
    parser.add_argument('input_directory', help='Path to the input directory containing subdirectories with files')
    
    args = parser.parse_args()

    input_directory = args.input_directory

    plt.figure(figsize=(10, 6))

    for elo_directory in os.listdir(input_directory):
        elo_path = os.path.join(input_directory, elo_directory)

        if os.path.isdir(elo_path):
            if elo_directory == '1700':
                file_path = os.path.join(elo_path, f'final_maia_{elo_directory}_results.csv')
            else:
                file_path = os.path.join(elo_path, f'final_maia_{elo_directory}_results.csv.bz2')

            if os.path.exists(file_path):
                data = read_data(file_path)
                accuracy_data = smooth_and_calculate_accuracy(data)
                plt.plot(accuracy_data.index, accuracy_data, label=str(elo_directory))

    plt.title('Model Accuracy vs Elo')
    plt.xlabel('Elo')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    main()
