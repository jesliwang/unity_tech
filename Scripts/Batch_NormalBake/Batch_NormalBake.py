import csv
import cv2 as cv
import numpy as np
import os.path
from NormalBake import NormalTexBake
from PIL import Image

# 변수 선언 -----------------------------------------------------------------------
ListPath = "[CleanupList]/"
LoadCSV = "Total_Path.csv"
Path_Textures = "D:/[BlessMobile]/[BG_Textures]/Game/BG/"
Save_Root = "D:/[BlessMobile]/Baked/"
# ---------------------------------------------------------------------------------
# 함수 정의 -----------------------------------------------------------------------
def getCsv(CsvPath, CsvFile) :
    csvList = []
    f = open(CsvPath + CsvFile, 'r')
    csvReader = csv.reader(f)
    for i in csvReader:
        TexAN = [i[0].strip(), i[1].strip()]
        csvList.append(TexAN)
    f.close()
    print("%d" % len(csvList))
    return csvList
# ---------------------------------------------------------------------------------
# 메인 함수 -----------------------------------------------------------------------
if __name__ == '__main__' :
    DataList = getCsv(ListPath, LoadCSV)
    for i in range(1, len(DataList)):



        print("i: %d, Base: %s, Normal: %s" % (i, DataList[i][0], DataList[i][1]))
        NormalTexBake(DataList[i][0], DataList[i][1], Save_Root)


    print("Batch NormalBake!!")