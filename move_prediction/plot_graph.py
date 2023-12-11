import argparse
import pandas as pd
import bz2
import matplotlib.pyplot as plt

def read_data(file_path):
    with bz2.open(file_path, 'rt') as file:
        data = pd.read_csv(file_path)
    return data

def smooth_and_calculate_accuracy(data, elo_interval=100):
    # Create elo buckets and calculate mean accuracy for each bucket
    elo_buckets = data.groupby(data['elo'] // elo_interval * elo_interval)
    smoothed_accuracy = elo_buckets['model_correct'].mean()

    return smoothed_accuracy

def plot_accuracy_vs_elo(elo, accuracy):
    plt.figure(figsize=(10, 6))
    
    # Smoothed data
    plt.plot(elo, accuracy, linestyle='-', color='r', label='1100')
    
    plt.title('Model Accuracy (1100) vs Elo')
    plt.xlabel('Elo')
    plt.ylabel('Accuracy')
    plt.legend()
    plt.grid(True)
    #plt.ylim(0.46, 0.52)
    #plt.xlim(1100, 1900)
    plt.show()

def main():
    parser = argparse.ArgumentParser(description='Generate a plot of Model Accuracy vs Elo.')
    parser.add_argument('input_file', help='Path to the input .csz.bz2 file')
    parser.add_argument('output_file', help='Path to save the output plot')

    args = parser.parse_args()

    data = read_data(args.input_file)
    accuracy_data = smooth_and_calculate_accuracy(data)
    plot_accuracy_vs_elo(accuracy_data.index, accuracy_data)
    plt.savefig(args.output_file)

if __name__ == "__main__":
    main()
