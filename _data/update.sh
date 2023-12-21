#!/bin/bash
wget 'https://api.github.com/users/bizouarn/repos' -O 'repo.json'
wget 'https://api.github.com/users/bizouarn/gists' -O 'gist.json'
git add .
git commit -m "🗃 Update data"
git push
