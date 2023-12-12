import argparse
import os
import chess
import chess.pgn

def filter_pgn(input_pgn, output_pgn):
    with open(input_pgn, 'r') as pgn_file:
        pgn_games = []
        while True:
            pgn_game = chess.pgn.read_game(pgn_file)
            if pgn_game is None:
                break
            pgn_games.append(pgn_game)

    filtered_games = []

    for pgn_game in pgn_games:
        board = pgn_game.board()
        filtered_game = chess.pgn.Game()
        castling_moves = 0
        total_moves = 0
        had_checkmate = False
        check_board= board.copy()
        for move in pgn_game.mainline_moves():
            total_moves += 1
            board.push(move)
            if board.is_checkmate():
                had_checkmate = True
            if check_board.is_castling(move):
                castling_moves += 1
        #print(board)
        #print(pgn_game.headers["Result"] + " " + pgn_game.headers["White"] + " - " + pgn_game.headers["Black"])
        #print("Total moves: " + str(total_moves) + ", castling moves: " + str(castling_moves) + ", checkmate: " + str(had_checkmate))
        if had_checkmate == False:
            continue
        if castling_moves == 2:
            node = filtered_game
            counted_castling_moves = 0
            for move in pgn_game.mainline_moves():
                node = node.add_variation(move)
                if check_board.is_castling(move):
                    counted_castling_moves += 1
                    if counted_castling_moves == 2:
                        break
        elif total_moves >= 20:
            moves_count = 0
            node = filtered_game
            for move in pgn_game.mainline_moves():
                node = node.add_variation(move)
                moves_count += 1
                if moves_count == 20:
                    break
        else:  # Not enough moves
            continue

        filtered_game.headers = pgn_game.headers
        filtered_games.append(filtered_game)

    return filtered_games

def process_directory(input_dir, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for file_name in os.listdir(input_dir):
        if file_name.endswith(".pgn"):
            input_file_path = os.path.join(input_dir, file_name)
            output_file_path = os.path.join(output_dir, file_name)
            filtered_games = filter_pgn(input_file_path, output_file_path)

            with open(output_file_path, 'w') as output_file:
                for filtered_game in filtered_games:
                    output_file.write(str(filtered_game) + "\n\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Cuts pgn games')
    parser.add_argument('input_dir', help='Path to the input directory containing PGN files')
    parser.add_argument('output_dir', help='Path to the output directory for processed PGN files')
    
    args = parser.parse_args()

    input_directory = args.input_dir
    output_directory = args.output_dir

    process_directory(input_directory, output_directory)
