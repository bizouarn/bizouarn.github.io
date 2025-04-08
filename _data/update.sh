#!/bin/bash
wget 'https://api.github.com/users/bizouarn/repos?per_page=100' -O 'repo.json'
wget 'https://api.github.com/users/bizouarn/gists?per_page=100' -O 'gist.json'
git add .
git commit -m "🗃 Update data"
git push
