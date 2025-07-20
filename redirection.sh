#!/bin/bash

# Redirection: >, >>, <, 2>, &>

# Redirect stdout to file (overwrite)
# echo "Hello World" > output.txt

# ls -l  > filelist.txt # whole insert
# ls -l | cut -d' ' -f9- > filelist.txt # cut column from last to first 9- means 9 columns
# ls -l | awk '{print $3, $4, $5, $6 $9}' > filelist.txt #selecting column postion
# ls -1 > filelist.txt # last column
# ls -1A > filelist.txt #wiht hidden file but not .

# Redirect stderr to file
# ls /nonexistent 2> error.log

# Redirect both stdout and stderr
# command > output.txt 2> error.txt
# ls ./test_dir > output.txt 2> error.txt # e,g command=ls ./test_dir

# Or combined:
# ls -l | cut -d' ' -f3- > combined.txt 2>&1 #with -f colum position positive or negative 3 or 3- 
# 3- means start from postion 3 to last

# command &> combined.txt  # shorthand


# echo "Line 1" > log.txt #override 
# echo "Line 2" >> log.txt  # Appends, doesn't overwrite

# # Append both
# command >> output.log 2>&1


# echo "Line 1" > log.txt
# echo "Line 3" >> log.txt
# echo "Line 2" >> log.txt
# # Read from file instead of keyboard
# sort < log.txt # sort work as a input of the file

# wc -l < log.txt #count

# grep "hello" <<< "search in this string" &> combined.log

# Mail example
# touch message.txt
# mail user@example.com < message.txt


# -s "subject"	Set email subject
# -a file	Attach a file
# -c cc@example.com	CC recipient
# -b bcc@example.com	BCC recipient

# touch message.txt
# echo "This is the email body" > message.txt
# mail -s "Subject Here" user@example.com < message.txt

# alter native:
# (
# echo "Subject: Test Email"
# echo "To: user@example.com"
# echo "From: you@yourdomain.com"
# echo ""
# echo "This is the email body"
# ) | sendmail -t


# Redirect to multiple files (tee)
echo "Message" | tee file1.txt file2.txt

# for tree sturctures: tee
# -d	Show directories only
# -L 2	Limit depth to 2 levels
# -a	Show hidden files



# Redirect to both file and stdout
# command | tee output.txt

# Redirect specific file descriptors
# 1 = stdout, 2 = stderr, 0 = stdin
# command 1> stdout.txt 2> stderr.txt

# # Swap stdout and stderr
# command 3>&1 1>&2 2>&3 3>&-

# # Redirect to /dev/null (discard output)
# command > /dev/null      # Discard stdout
# command 2> /dev/null     # Discard stderr
# command &> /dev/null     # Discard both

# Named pipes (FIFO)
# mkfifo mypipe
# echo "data" > mypipe &   # Write in background
# cat < mypipe             # Read from pipe



# Log both success and errors
# ./script.sh > success.log 2> error.log

# # Create backup while processing
# cat original.txt | tee backup.txt | process_data
# cat original.txt | tee backup.txt | grep "error"  # Extract lines containing "error"
# cat original.txt | tee backup.txt | awk '{print $1}'  # Extract first column
# View live logs, save a backup, and filter errors
# tail -f /var/log/syslog | tee syslog_backup.txt | grep -i "error"

# Generate directory tree and save to multiple files
# tree -L 2 --dirsfirst | tee project_structure.txt overview.txt

# # Separate error handling
# if ! command > output.txt 2> error.txt; then
#     echo "Command failed, check error.txt"
#     cat error.txt
# fi

# # Progress indicator with output capture
# long_running_command 2>&1 | tee >(grep "progress" > progress.log) | grep "error"


# --------------------------------------------------------------------------------------------------------------
### **Named Pipes (FIFOs) Explained: `mkfifo` Example**
---

1. Create a Named Pipe**
```bash
mkfifo mypipe
```
- Creates a special file called `mypipe` that acts as a **First-In-First-Out (FIFO) queue**.
- Unlike regular files, data written to a pipe doesn't persist; it's passed directly between processes.

---

#### **2. Write Data to the Pipe (Background)**
```bash
echo "data" > mypipe &
```
- `echo "data"` writes the string "data" to `mypipe`.
- `&` runs the command in the background (so the shell doesn't hang).
- The command **blocks** until another process reads from the pipe.

---

#### **3. Read Data from the Pipe**
```bash
cat < mypipe
```
- `cat` reads from `mypipe` and prints "data" to the terminal.
- Once read, the data is **gone** from the pipe (unlike regular files).

---

### **How It Works**
1. **No Storage**: Data exists **only while being transferred** (not stored on disk).
2. **Synchronization**:
   - Writing blocks until a reader is ready.
   - Reading blocks until data is available.
3. **Unidirectional**: Data flows **one way** (writer → reader).

---

### **Practical Use Cases**
| Scenario | Example |
|----------|---------|
| **Inter-process communication** | `process1 > mypipe & process2 < mypipe` |
| **Logging** | `application > mypipe & logger < mypipe` |
| **Stream processing** | `sensor_data > mypipe & analyzer < mypipe` |

---

### **Example: Live Data Processing**
```bash
# Terminal 1 (Writer)
while true; do echo "$(date) - New data" > mypipe; sleep 1; done

# Terminal 2 (Reader)
cat < mypipe
```
**Output (Terminal 2):**
```
Mon Jul 10 14:30:00 UTC 2023 - New data
Mon Jul 10 14:30:01 UTC 2023 - New data
...
```

---

### **Key Properties**
| Feature | Description |
|---------|-------------|
| **Blocking** | Writers/readers wait for each other |
| **No Duplication** | Data is consumed once |
| **File Permissions** | Controlled via `chmod` (default: user-only) |

---

### **Cleanup**
```bash
rm mypipe  # Delete the FIFO when done
```

Named pipes are powerful for **real-time communication** between processes without temporary files. Let me know if you'd like a more advanced example!



