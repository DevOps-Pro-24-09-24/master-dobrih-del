# master-dobrih-del
master-dobrih-del homeworks
ДЗ 2. Git pre-commit job

Inside the repository, there are two important files: `commit-msg` and `pre-commit`.

- `commit-msg`: Used for checking commit messages with regular expressions.
- `pre-commit`: Used for linting `*.py` files in commits.

## How to use:

1. Copy the files to `.git/hooks`:
   ```sh
   cp pre-commit .git/hooks/ && cp commit-msg .git/hooks/ 
   ```
2. Make the scripts executable:
    ```sh
    chmod +x .git/hooks/{pre-commit,commit-msg}
    ```
3. Try to make commits.