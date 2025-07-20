
# ## What This Command Does
# ```bash
# chmod +r readonly.sh
# ```
# - **Adds read permission** (+r) for all users (owner, group, others)
# - **Does not affect** write or execute permissions
# - **Will work** if you're the file owner or root

# ## Potential Issues
# 1. **If the file is truly read-only**:
#    - Some systems set immutable flags (`chattr +i` in Linux)
#    - In this case, `chmod` won't work until you remove the immutable flag:
#      ```bash
#      sudo chattr -i readonly.sh
#      chmod +r readonly.sh
#      ```

# 2. **If you're not the owner**:
#    - Regular users can't change permissions of files they don't own
#    - Requires sudo:
#      ```bash
#      sudo chmod +r readonly.sh
#      ```

# ## Better Alternatives

# 1. **To make a file readable and also ensure it's writable**:
#    ```bash
#    chmod u+rw readonly.sh  # Give owner read+write
#    ```

# 2. **To make completely readable by everyone**:
#    ```bash
#    chmod a+r readonly.sh  # Explicitly set for all (a)ll users
#    ```

# 3. **To verify current permissions first**:
#    ```bash
#    ls -l readonly.sh  # Check current permissions
#    stat readonly.sh  # More detailed info
#    ```

# ## When You Might Need More
# ```bash
# # If you need to remove write-protection:
# chmod -w readonly.sh  # Remove write permission for all

# # If you need to reset to default:
# chmod 644 readonly.sh  # Common default for regular files
# ```

# Key Notes:
# - `+r` alone doesn't remove existing write protections
# - The command is safe to run (won't damage files)
# - May not work if there are deeper permission restrictions
