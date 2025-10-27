#!/usr/bin/env bash
#
# auto_append.sh (Optimized, File-based Queue)
#
# Randomly appends a word from ieltsWords.txt to README.md.
# This version is optimized for simplicity and robustness by using a file-based queue.
# It pre-processes the words into a clean "pool" and then uses a shuffled "queue"
# to draw from, ensuring excellent performance and resilience.

set -euo pipefail

# --- Configuration ---
WORDS_FILE="./ieltsWords.txt"
OUTPUT_FILE="./README.md"
SLEEP_SECONDS=5

# Hidden files for storing the script's state.
WORD_POOL_FILE=".auto_append_word_pool.txt"
WORD_QUEUE_FILE=".auto_append_word_queue.txt"
# ---

# --- Initialization ---

# Gracefully handle Ctrl+C for a clean script shutdown.
trap 'echo ""; echo "Script terminated by user."; exit 0' INT TERM

# Ensure `shuf` (from coreutils) is available.
if ! command -v shuf &> /dev/null; then
    echo "Error: 'shuf' command not found. This script requires GNU coreutils." >&2
    echo "Please consider adding 'pkgs.coreutils' to your .idx/dev.nix file." >&2
    exit 1
fi

# Initialize or update the word pool if the source file is newer.
# This prevents reprocessing on every script start.
if [[ ! -f "$WORD_POOL_FILE" || "$WORDS_FILE" -nt "$WORD_POOL_FILE" ]]; then
    echo "Source file is newer or word pool is missing. Regenerating word pool..."

    # Create a clean "pool" of valid words from the source file.
    # 1. Remove Windows carriage returns.
    # 2. Filter out lines containing "word list" (case-insensitive).
    # 3. Trim leading/trailing whitespace from every line.
    # 4. Filter out any lines that are now empty.
    sed 's/\r$//' "$WORDS_FILE" | \
        grep -vi "word list" | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        grep . > "$WORD_POOL_FILE"

    # After regenerating the pool, the queue is invalid.
    rm -f "$WORD_QUEUE_FILE"

    echo "Word pool regenerated."
fi

# Check if the pool is empty.
if [[ ! -s "$WORD_POOL_FILE" ]]; then
    echo "Error: No valid words were found in '$WORDS_FILE' after filtering." >&2
    exit 1
fi

total_words=$(wc -l < "$WORD_POOL_FILE")
echo "Initialization complete. Using a pool of $total_words valid words."

# --- Main Loop ---

while true; do
    # If the queue file is empty or doesn't exist, it's time to reshuffle from the pool.
    if [[ ! -s "$WORD_QUEUE_FILE" ]]; then
        echo "Word queue is empty. Reshuffling from the pool..."
        shuf "$WORD_POOL_FILE" > "$WORD_QUEUE_FILE"
        echo "Reshuffled $total_words words into the queue."
    fi

    # Atomically read and remove the top line from the queue.
    # `head -n 1` gets the word.
    # `tail -n +2` gets the rest of the file.
    # The temporary file and `mv` make the removal atomic.
    next_word=$(head -n 1 "$WORD_QUEUE_FILE")
    tail -n +2 "$WORD_QUEUE_FILE" > "$WORD_QUEUE_FILE.tmp" && mv "$WORD_QUEUE_FILE.tmp" "$WORD_QUEUE_FILE"

    # Append the word to the output file.
    echo "$next_word" >> "$OUTPUT_FILE"

    # Log the action.
    remaining=$(wc -l < "$WORD_QUEUE_FILE")
    echo "Appended: '$next_word' (Words remaining in queue: $remaining)"

    # Wait before the next cycle.
    sleep "$SLEEP_SECONDS"
done
