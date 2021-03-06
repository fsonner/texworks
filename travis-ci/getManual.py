import json, sys, os, os.path, zipfile, tempfile
try:
	# Python3
	from urllib.request import urlopen, urlretrieve
except:
	# Python2
	from urllib2 import urlopen
	from urllib import urlretrieve


fin = urlopen("https://api.github.com/repos/TeXworks/manual/releases/latest")
release = json.loads(fin.read().decode('utf-8'))
fin.close()

for asset in release["assets"]:
	if asset['content_type'] == "application/zip":
		folder = "texworks-help"
		if not os.path.exists(folder):
			os.makedirs()
		print("Downloading %s from %s and uncompressing to %s" % (asset['name'], asset['browser_download_url'], folder))
		tmpfile = tempfile.NamedTemporaryFile(delete = False)
		tmpfile.close()
		urlretrieve(asset['browser_download_url'], tmpfile.name)
		
		with zipfile.ZipFile(tmpfile.name, 'r') as z:
			z.extractall(folder)
		os.remove(tmpfile.name)

	elif asset['content_type'] == "application/pdf" or asset['content_type'] == "[application/pdf]":
		lang = os.path.splitext(asset['name'])[0].rsplit('-', 1)[1]
		folder = os.path.join("texworks-help", "TeXworks-manual", lang)
		if not os.path.exists(folder):
			os.makedirs(folder)
		print("Downloading %s from %s to %s" % (asset['name'], asset['browser_download_url'], folder))
		urlretrieve(asset['browser_download_url'], os.path.join(folder, asset['name']))

	else:
		print("Error: Unknown content type '%s' for file '%s'" % (asset['content_type'], asset['name']))
