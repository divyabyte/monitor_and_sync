#!/bin/bash

# Set the path to the folder you want to monitor
folder_to_watch="/home/morbius/Documents/projects/bash/mnotify/test"
dest_dir="/home/morbius/Documents/projects/bash/mnotify/test1"

# Function to sync a file to the destination directory
sync_file() {
    source_file="$1"
    dest_file="$dest_dir/$(basename "$source_file")"
    
    # Add your synchronization logic here
    cp "$source_file" "$dest_file"
    echo "Syncing $source_file to $dest_file"
}

# Function to send a notification
send_notification() {
    # You can customize this part based on your notification preferences
    notify-send "File Change Notification" "A new file or changes detected in $1"
}

# Function to print the content of a file
print_file_content() {
    echo "Content of $1:"
    cat "$1"
}

rsync -av --exclude=".git" "$folder_to_watch/" "$dest_dir/"

# Monitor the folder for events
inotifywait -m -r -e create,modify --format '%w%f' "$folder_to_watch" |
while read file_changed; do
    # Send a notification when a new file is created or an existing file is modified
    send_notification "$file_changed"

    # Sync the file to the destination directory in parallel, limit to 2 jobs (adjust as needed)
    sync_file "$file_changed" &

    # Print the content of the changed file
    print_file_content "$file_changed"
done
