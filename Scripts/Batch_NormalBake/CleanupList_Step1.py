import csv

def getCsv(CsvPath, CsvFile, ReadRowNum) :
    csvList = []
    f = open(CsvPath + CsvFile, 'r')
    csvReader = csv.reader(f)
    for i in csvReader :
        csvList.append(i[ReadRowNum])
    f.close()
    return csvList

if __name__ == '__main__' :

    #----------------------------------------------------------------------------------
    # 변수 선언 -----------------------------------------------------------------------
    ListPath = "[CleanupList]/"
    LoadCSV = "BG___1_COR.csv"
    SaveCSV = "BG___1_COR_ANList.csv"
    NormalTexParamName = "*[Normal]"
    AlbedoTexParamName = "*[Albedo]"
    SplitText = "*"
    # ---------------------------------------------------------------------------------
    # ---------------------------------------------------------------------------------

    DataList = getCsv(ListPath, LoadCSV, 1)
    TargetList = []
    for i in range(0, len(DataList)) :
        if (DataList[i].find(NormalTexParamName) != -1) :
            if (DataList[i].find(AlbedoTexParamName) != -1):
                print("%d : %s" % (i,DataList[i]))
                SplitedList = (DataList[i].strip()).split(SplitText)

                TexAN = ["[Albedo]", "[Normal]"]
                for k in range(0, len(SplitedList)) :
                    print("%d : %s" % (k, SplitedList[k] ))
                    if (SplitedList[k].find("[Normal]") != -1) :
                        TexAN[1] = SplitedList[k].replace("[Normal] : ", "")
                    if (SplitedList[k].find("[Albedo]") != -1):
                        TexAN[0] = SplitedList[k].replace("[Albedo] : ", "")
                TargetList.append(TexAN)
                print("Texture Link: A - %s   /   N - %s" % (TexAN[0], TexAN[1]))


    # CSV생성 후 출력
    f = open(ListPath + SaveCSV, 'w', encoding='utf-8', newline='')
    csvWriter = csv.writer(f)
    csvWriter.writerow(["Albedo Texture", "Normal Texture"])
    for i in range(0 , len(TargetList)) :
        csvWriter.writerow([TargetList[i][0], TargetList[i][1]])
    f.close()

