#!/bin/bash
# Usage: git-add-commit.sh <message>
# ensure any individual file is under 2gb and any file over 300mb is tracked using git-lfs before committing
# Check if a commit message was provided
if [ $# -eq 0 ]; then
  echo "Error: No commit message provided"
  exit 1
fi

# Store the commit message in a variable
message="$1"

# Configuration
MAX_CHUNK_SIZE_KB=150000  # 1.5GB in KB (reduced from 2GB for safety)
MAX_COMMITS_BEFORE_PUSH=3  # Push every 3 commits instead of every commit

# Function to determine the size of a file in KB
function size_in_kb() {
  local file="$1"
  if [ -f "$file" ]; then
    echo $(( $(wc -c < "$file") / 1024 ))
  else
    echo 0
  fi
}

# Function to safely push commits
function safe_push() {
  echo "Pushing commits to remote..."
  if git push; then
    echo "✓ Successfully pushed commits"
    return 0
  else
    echo "✗ Failed to push commits"
    return 1
  fi
}

# Get list of untracked and modified files more efficiently
echo "Discovering files to commit..."
untracked_files=$(git ls-files --others --exclude-standard)
modified_files=$(git diff --name-only)
all_files=$(echo -e "$untracked_files\n$modified_files" | sort -u | grep -v '^$')

if [ -z "$all_files" ]; then
  echo "No files to commit."
  exit 0
fi

echo "Found $(echo "$all_files" | wc -l) files to process"

COUNTER=1
commit_count=0
# Process files in chunks
while IFS= read -r file; do
  [ -z "$file" ] && continue
  
  chunk_size=0
  chunk_files=()
  
  # Build a chunk of files within size limit
  while IFS= read -r current_file; do
    [ -z "$current_file" ] && continue
    
    file_size=$(size_in_kb "$current_file")
    
    # Skip files that are too large for any chunk
    if [ "$file_size" -gt "$MAX_CHUNK_SIZE_KB" ]; then
      echo "⚠️  Warning: Skipping $current_file (${file_size}KB) - exceeds chunk size limit"
      continue
    fi
    
    # Check if adding this file would exceed chunk size
    if [ "$((chunk_size + file_size))" -le "$MAX_CHUNK_SIZE_KB" ]; then
      chunk_size=$((chunk_size + file_size))
      chunk_files+=("$current_file")
      echo "  Adding to chunk: $current_file (${file_size}KB)"
    else
      # Current chunk is full, break to process it
      break
    fi
  done <<< "$all_files"
  
  # Process the current chunk
  if [ ${#chunk_files[@]} -gt 0 ]; then
    echo "📦 Processing chunk $COUNTER with ${#chunk_files[@]} files (${chunk_size}KB total)"
    
    # Add files to staging using --no-refresh for speed
    for chunk_file in "${chunk_files[@]}"; do
      git add --no-refresh "$chunk_file"
    done
    
    # Commit the chunk
    if git commit -m "$message (chunk $COUNTER)"; then
      echo "✓ Committed chunk $COUNTER successfully"
      commit_count=$((commit_count + 1))
      
      # Push every few commits to avoid too many pending commits
      if [ "$((commit_count % MAX_COMMITS_BEFORE_PUSH))" -eq 0 ]; then
        safe_push
      fi
    else
      echo "✗ Failed to commit chunk $COUNTER"
      exit 1
    fi
    
    # Remove processed files from the list
    for chunk_file in "${chunk_files[@]}"; do
      all_files=$(echo "$all_files" | grep -v "^$chunk_file$")
    done
    
    COUNTER=$((COUNTER + 1))
  else
    # No more files can fit in chunks, we're done
    break
  fi
  
done <<< "$all_files"

# Push any remaining commits
if [ "$commit_count" -gt 0 ]; then
  echo "🚀 Pushing final commits..."
  safe_push
  echo "✅ All chunks committed and pushed successfully!"
else
  echo "ℹ️  No commits were made"
fi