generated_dir=../suzaku.github.io/

hugo
cp -r public/* $generated_dir
cd $generated_dir
git push
cd -
