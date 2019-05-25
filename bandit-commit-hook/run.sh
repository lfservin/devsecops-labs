cp malicious_file.py $pwd
git add -A
git config user.name "testuser"
git config user.email "testuser@gmail.com"
git commit -m "Commited insecure python file"