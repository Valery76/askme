search:
	grep -R --exclude-dir=tmp --exclude-dir=log --exclude-dir=.git --exclude=*.sqlite3 '$(S)' . || echo 'Nothing is found ...'