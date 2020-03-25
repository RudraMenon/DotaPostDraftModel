from os import listdir
import re
from os.path import isfile, join

pathToFiles = "apiMatches/"

onlyfiles = [f for f in listdir(pathToFiles)]
gameJson = {}
for fileName in onlyfiles:
    with open(pathToFiles + "/" + fileName, 'r') as f:
        lines = f.readlines()
        gameDict = {}
        for i in range(4):
            gameDict[lines[i].split(":")[0]] = [int(x) for x in re.search("\[(.*)\]", lines[i]).group(1).split(',')]
        for i in range(5, 8):
            line = [x.strip() for x in lines[i].replace("\n", "").split(":")]
            gameDict[line[0]] = bool(line[1]) if i == 6 else int(line[1])
    gameJson[fileName.split(".")[0]] = gameDict
    with open('gamesJson.txt', 'w') as fp:
        fp.write(str(gameJson))
print(str(gameJson))
