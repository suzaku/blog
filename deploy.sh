generated_dir=../suzaku.github.io/

hugo
cp -r public/* $generated_dir
cd $generated_dir
git add --all
git ci -m'Deploy'
git push
cd -
