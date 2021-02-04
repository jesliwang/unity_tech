# 동일한 Albedo 텍스쳐일 경우, 다수의 Normal값 순서대로 정렬합니다.
# 다음 Normal Texture의 경우 처리를 생략합니다. (T_cm_DefaultNormal_a_01_dn,T_cm_DefaultNormal_Bake)
# 다음 Albedo Texture의 경우 처리를 생략합니다. (Black_D, Black_D1, mask_1_1_1, NoTexture)


import csv
# 변수 선언 -----------------------------------------------------------------------
ListPath = "[CleanupList]/"
LoadCSV = "Total.csv"
SaveCSV = "Total_Cleanup.csv"
ExceptionAlbedo = ("Black_D", "Black_D1", "mask_1_1_1", "NoTexture")
ExceptionNormal = ("T_cm_DefaultNormal_a_01_dn","T_cm_DefaultNormal_Bake")
# ---------------------------------------------------------------------------------

def getCsv(CsvPath, CsvFile) :
    csvList = []
    f = open(CsvPath + CsvFile, 'r')
    csvReader = csv.reader(f)
    # 불필요 텍스쳐 포함한 항목들 제외
    for i in csvReader :
        TexAN = [i[0].strip(), i[1].strip()]
        CheckAlbedo = 1
        for j in range(0, len(ExceptionAlbedo)) :
            if (TexAN[0].strip() == ExceptionAlbedo[j]) :
                CheckAlbedo = 0
        CheckNormal = 1
        for j in range(0, len(ExceptionNormal)):
            if (TexAN[1].strip() == ExceptionNormal[j]):
                CheckNormal = 0
        if (CheckAlbedo and CheckNormal == 1) :
            csvList.append(TexAN)
    f.close()
    print('csvList길이는: %d' % len(csvList))
    return csvList


# 중복 검사 및 정렬
def CheckOverlap(List) :
    TempList_First = []
    TempList_Last = []
    for i in range(0, len(List)) :
        TempList_First.append(List[i][0])
        TempList_Last.append(List[i][1])
    SubList_First = []
    SubList_Temp = []
    SubList_Last = []
    CleanupList = []
    NewList = list(set(TempList_First))
    for i in range(0, len(NewList)) :
        print("+++----- Start -----+++")
        print("대상 텍스트: %s" % NewList[i])
        SubList_Temp = []
        FirstCount = TempList_First.count(NewList[i])
        print("Albedo 텍스쳐 수: %d" % FirstCount)

        if (FirstCount == 1):
            FindNum = TempList_First.index(NewList[i])
            SubList_First.append(TempList_First[FindNum])
            SubList_Temp.append(TempList_Last[FindNum])
            SubList_Temp.append(1)
            SubList_Last.append(SubList_Temp)
            print("Normal 텍스쳐 종류: 1")
        else :
            SubList_First.append(NewList[i])
            for k in range(0, len(TempList_First)):
                if (NewList[i] == TempList_First[k]) :
                    SubList_Temp.append(TempList_Last[k])

            # 재정렬
            #for k in SubList_Temp :
                #print("K: %s" % k)
            CleanupList = list(set(SubList_Temp))
            print("Normal 텍스쳐 종류.: %d" % len(CleanupList))

            a_List_Title = []
            a_List_Num = []

            if (len(CleanupList) > 1 ) :
                a_List_Title.append(CleanupList[0])
                a_List_Num.append(SubList_Temp.count(CleanupList[0]))

                for k in range(1, len(CleanupList)) :
                    TempNum = SubList_Temp.count(CleanupList[k])
                    for r in range(0, len(a_List_Num)) :
                        print("중간점검: ", a_List_Num)
                        if ( TempNum > a_List_Num[r] ) :
                            print('새로운 Normal Tex 반복 수: %d / 기존 Normal Tex 반복 수: %d' % (TempNum, a_List_Num[r]) )
                            a_List_Num.insert(r, TempNum)
                            a_List_Title.insert(r, CleanupList[k])
                            break
                        else :
                            a_List_Num.append(TempNum)
                            a_List_Title.append(CleanupList[k])
                
                
                SubList_Temp = []
                for k in range(0, len(a_List_Title)) :
                    SubList_Temp.append(a_List_Title[k])
                    SubList_Temp.append(a_List_Num[k])
                print("Normal Tex명 / 반복횟수")
                print(SubList_Temp)
                SubList_Last.append(SubList_Temp)
            else :
                print("Normal 텍스쳐 종류: ", SubList_Temp)
                b_List_Temp = []
                b_List_Temp.append(CleanupList[0])
                b_List_Temp.append(SubList_Temp.count(CleanupList[0]))
                print("Normal 텍스쳐 종류/수: ", b_List_Temp)
                SubList_Last.append(b_List_Temp)

    # Return을 위한 List 재구성
    RemakeList = []
    for i in range(0, len(SubList_First)) :
        RemakeList_Temp = []
        RemakeList_Temp.append(SubList_First[i])
        if (len(SubList_Last[i]) <= 2) :
            Temp = [' ']
            RemakeList_Temp = RemakeList_Temp + SubList_Last[i] + Temp
        else :
            Temp1 = []
            Temp2 = []
            Temp1.append(SubList_Last[i][0])
            Temp1.append(SubList_Last[i][1])
            for k in range(2, len(SubList_Last[i])) :
                Temp2.append(SubList_Last[i][k])
            RemakeList_Temp = RemakeList_Temp + Temp1
            RemakeList_Temp.append(Temp2)
        print("ReTemp:")
        print(RemakeList_Temp)
        RemakeList.append(RemakeList_Temp)
    return RemakeList


if __name__ == '__main__' :

    DataList = getCsv(ListPath, LoadCSV)
    #TargetList = DataList
    TargetList = CheckOverlap(DataList)


    # CSV생성 후 출력
    f = open(ListPath + SaveCSV, 'w', encoding='utf-8', newline='')
    csvWriter = csv.writer(f)
    csvWriter.writerow(["Albedo Texture", "Normal Texture", "Normal Num", "Extra info"])
    for i in range(0, len(TargetList)):
        csvWriter.writerow([TargetList[i][0], TargetList[i][1], TargetList[i][2], TargetList[i][3]])
    f.close()

