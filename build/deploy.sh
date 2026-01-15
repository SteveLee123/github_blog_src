#!/usr/bin/env sh

set -e

npm run build

cd dist

git init
git config user.name 'Young-LAO'
git config user.email '1597374034@qq.com'
git add -A
git commit -m 'deploy'

git push -f git@github.com:Young-LAO/github_blog_src.git master:gh-pages

cd -
