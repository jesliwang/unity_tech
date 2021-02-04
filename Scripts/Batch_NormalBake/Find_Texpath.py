import os
import csv

# 변수 선언 -----------------------------------------------------------------------
ListPath = "[CleanupList]/"
LoadCSV = "Total_Cleanup.csv"
SaveCSV = "Total_Path.csv"
Path_Textures = "D:/[BlessMobile]/[BG_Textures]/Game/BG/"
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

def Find_Path(path_Files, name_Texture, File_Extension):
    Fullname = ""
    for (path, dir, files) in os.walk(path_Files):
        #print("length: %d" % len(files))
        for filename in files:
            print(filename)
            TargetName = (name_Texture + File_Extension)
            print(TargetName)
            print("Tex: %s / %s" % (filename, TargetName))
            if (filename == TargetName) :
                Fullname = path + "/" + filename
                Fullname = Fullname.replace("\\", "/")
                print("Finded!! %s" % (Fullname))
    return Fullname
# ---------------------------------------------------------------------------------
# 메인 함수 -----------------------------------------------------------------------
if __name__ == '__main__' :
    DataList = getCsv(ListPath, LoadCSV)

    Path_TexList = []
    for i in range(1, len(DataList)) :
        #print("Data0: %s / 1: %s" % (DataList[i][0], DataList[i][1]))
        TexPath = [Find_Path(Path_Textures, DataList[i][0], ".TGA"), Find_Path(Path_Textures, DataList[i][1], ".TGA")]
        Path_TexList.append(TexPath)

    # CSV생성 후 출력
    f = open(ListPath + SaveCSV, 'w', encoding='utf-8', newline='')
    csvWriter = csv.writer(f)
    csvWriter.writerow(["Albedo Path", "Normal Path"])
    for i in range(0, len(Path_TexList)):
        csvWriter.writerow([Path_TexList[i][0], Path_TexList[i][1]])
    f.close()
    print("Completed")
