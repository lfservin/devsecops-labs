git clone https://github.com/we45/Cut-The-Funds-NodeJS.git
cd Cut-The-Funds-NodeJS
npm install -g eslint eslint-plugin-security
cp eslintrc.js .eslintrc.js
cp eslint-commit-hook.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit