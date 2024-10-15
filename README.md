# master-dobrih-del
master-dobrih-del homeworks

Inside repo two important files 'commit-msg' and 'pre-commit'
commit-msg - can be use for cheking commit messeges with regexp
pre-commit - can be use for linting *.py files in commit
How to use:
 - copy files to .git/hooks ```cp pre-commit .git/hooks/ && cp commit-msg} .git/hooks/```
 - make scripts executable: ```chmod +x .git/hooks/{pre-commit,commit-msg}```
 - try to make commits