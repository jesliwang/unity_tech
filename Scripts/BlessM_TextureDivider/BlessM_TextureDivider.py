from PyQt5 import QtCore, QtGui, QtWidgets
from PIL import Image
import ctypes

class Math:
    # Find FileName
    def Find_FileName(Filename):
        Temp_Num = Filename.count("/")
        Temp_String = Filename.split("/")
        print(Temp_String[Temp_Num])
        return (Temp_String[Temp_Num])

    def Find_SavePath(Fullname, Fileformat):
        Temp_Num = Fullname.find(Fileformat)
        New_String = Fullname.replace("." + Fileformat, "")
        print(New_String)
        return New_String

    # Check POT
    def Check_POT(Size):
        if (Size[0] != Size[1]): return False
        if (Size[0] % 2 == 0) : return True
        else: return False
    # 최대 공약수 구하기 함수
    def gcd(a, b):
        while (b != 0):
            temp = a % b
            a = b
            b = temp
        return abs(a)
    # 최소 공배수 계산 함수
    def lcm(a, b):
        gcd_value = Math.gcd(a, b)
        if (gcd_value == 0): return 0  # 인수가 둘다 0일 때의 에러 처리
        return abs((a * b) / gcd_value)



class Ui_Dialog(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName("Dialog")
        Dialog.resize(392, 322)
        self.groupBox = QtWidgets.QGroupBox(Dialog)
        self.groupBox.setGeometry(QtCore.QRect(10, 10, 371, 141))
        font = QtGui.QFont()
        font.setPointSize(10)
        font.setBold(True)
        font.setItalic(False)
        font.setWeight(75)
        self.groupBox.setFont(font)
        self.groupBox.setObjectName("groupBox")
        self.lbl_ImgName = QtWidgets.QLabel(self.groupBox)
        self.lbl_ImgName.setGeometry(QtCore.QRect(30, 80, 311, 16))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.lbl_ImgName.setFont(font)
        self.lbl_ImgName.setFrameShape(QtWidgets.QFrame.NoFrame)
        self.lbl_ImgName.setObjectName("lbl_ImgName")
        self.lbl_ImgFormat = QtWidgets.QLabel(self.groupBox)
        self.lbl_ImgFormat.setGeometry(QtCore.QRect(30, 100, 151, 16))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.lbl_ImgFormat.setFont(font)
        self.lbl_ImgFormat.setObjectName("lbl_ImgFormat")
        self.pBtn_SelFile = QtWidgets.QPushButton(self.groupBox)
        self.pBtn_SelFile.setGeometry(QtCore.QRect(30, 20, 311, 51))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.pBtn_SelFile.setFont(font)
        self.pBtn_SelFile.setObjectName("pBtn_SelFile")
        self.pBtn_SelFile.clicked.connect(self.Select_File)

        self.lbl_ImgRes = QtWidgets.QLabel(self.groupBox)
        self.lbl_ImgRes.setGeometry(QtCore.QRect(180, 100, 151, 16))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.lbl_ImgRes.setFont(font)
        self.lbl_ImgRes.setObjectName("lbl_ImgRes")
        self.lbl_ImgPOT = QtWidgets.QLabel(self.groupBox)
        self.lbl_ImgPOT.setGeometry(QtCore.QRect(30, 120, 321, 16))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.lbl_ImgPOT.setFont(font)
        self.lbl_ImgPOT.setObjectName("lbl_ImgPOT")
        self.groupBox_2 = QtWidgets.QGroupBox(Dialog)
        self.groupBox_2.setGeometry(QtCore.QRect(10, 160, 371, 91))
        font = QtGui.QFont()
        font.setPointSize(10)
        font.setBold(True)
        font.setWeight(75)
        self.groupBox_2.setFont(font)
        self.groupBox_2.setObjectName("groupBox_2")
        self.label_5 = QtWidgets.QLabel(self.groupBox_2)
        self.label_5.setGeometry(QtCore.QRect(30, 30, 106, 12))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.label_5.setFont(font)
        self.label_5.setObjectName("label_5")
        self.cbx_ImgNum = QtWidgets.QComboBox(self.groupBox_2)
        self.cbx_ImgNum.setGeometry(QtCore.QRect(160, 20, 76, 22))
        self.cbx_ImgNum.setObjectName("cbx_ImgNum")
        self.cbx_ImgNum.addItems(["5", "6", "7", "8", "9", "10", "11", "12", "13", "14"])
        self.cbx_ImgNum.setCurrentText("10")
        self.cbx_ImgRes = QtWidgets.QComboBox(self.groupBox_2)
        self.cbx_ImgRes.setGeometry(QtCore.QRect(160, 55, 76, 22))
        self.cbx_ImgRes.setObjectName("cbx_ImgRes")
        self.cbx_ImgRes.addItems(["128", "256", "512"])
        self.cbx_ImgRes.setCurrentText("256")
        self.label_6 = QtWidgets.QLabel(self.groupBox_2)
        self.label_6.setGeometry(QtCore.QRect(30, 60, 106, 12))
        font = QtGui.QFont()
        font.setPointSize(9)
        font.setBold(False)
        font.setWeight(50)
        self.label_6.setFont(font)
        self.label_6.setObjectName("label_6")
        self.pBtn_Execute = QtWidgets.QPushButton(Dialog)
        self.pBtn_Execute.setGeometry(QtCore.QRect(10, 260, 371, 51))
        self.pBtn_Execute.setObjectName("pBtn_Execute")
        self.pBtn_Execute.clicked.connect(self.ExecuteDivide)

        self.retranslateUi(Dialog)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

       # self.pBtn_SelFile.click(vkSelect_File)

    def retranslateUi(self, Dialog):
        _translate = QtCore.QCoreApplication.translate
        Dialog.setWindowTitle(_translate("Dialog", "BlessM GI Texture Divider | Ver.1.2 | by JYP"))
        self.groupBox.setTitle(_translate("Dialog", "1. 원본 이미지 설정"))
        self.lbl_ImgName.setText(_translate("Dialog", "- Name:"))
        self.lbl_ImgFormat.setText(_translate("Dialog", "- Format :"))
        self.pBtn_SelFile.setText(_translate("Dialog", "Select imageFile"))
        self.lbl_ImgRes.setText(_translate("Dialog", "- Resolution : "))
        self.lbl_ImgPOT.setText(_translate("Dialog", "- Power of 2 : "))
        self.groupBox_2.setTitle(_translate("Dialog", "2. 분할 이미지 설정"))
        self.label_5.setText(_translate("Dialog", "+ 한 변의 이미지 수"))
        self.label_6.setText(_translate("Dialog", "+ 각 이미지 해상도"))
        self.pBtn_Execute.setText(_translate("Dialog", "분할 실행"))

     # 메시지박스
    #def MsgBoxFinished():
    #    tkinter.messagebox.showinfo("완료", "분할완료!")


    def Select_File(self):
        print("Push Button")
        File_Input = QtWidgets.QFileDialog.getOpenFileName()
        global img_Input
        img_Input = Image.open(File_Input[0])
        self.lbl_ImgName.setText("- Name : " + str(Math.Find_FileName(img_Input.filename)))
        self.lbl_ImgFormat.setText("- Format : " + img_Input.format)
        self.lbl_ImgRes.setText("- Resolution : " + str(img_Input.size[0]) + " x " + str(img_Input.size[1]))
        self.lbl_ImgPOT.setText("- Power of 2 : " + str(Math.Check_POT(img_Input.size)))

    def ExecuteDivide(self):
        print("Push Divide")
        Num_Terrain = int(self.cbx_ImgNum.currentText())
        print("Set Terrain Num : %d" % Num_Terrain)
        New_Size = int(self.cbx_ImgRes.currentText())
        New_Size = (New_Size, New_Size)
        print("Set Texture Res : %d x %d" % (New_Size[0], New_Size[1]))

        print (img_Input.format)

        result = Math.lcm(Num_Terrain, img_Input.height)
        result = int(float(result))
        print(result)

        #TGA파일의 Alpha처리 문제로 인한 대처방안_1
        red, green, blue, A_Channel = img_Input.split()
        image_RGB = img_Input.convert("RGB")
        resize_Img = image_RGB.resize((result,result), Image.LANCZOS) #NEAREST, BILINEAR, BICUBIC LANCZOS
        resize_A = A_Channel.resize((result,result), Image.LANCZOS)
        resize_Img.putalpha(resize_A)

        Val_ResizeLength = int(float(result / Num_Terrain))
        print(Val_ResizeLength)

        Num_Loop = result // Num_Terrain
        print("Loop : " + str(Num_Loop))
        Val_Count = 1
        print(str(Val_Count))
        New_FileName = Math.Find_SavePath(img_Input.filename, img_Input.format)

        for i in range(0, Num_Terrain):
            Val_Vertical = i * Val_ResizeLength
            for k in range(0, Num_Terrain):
                Val_Horizontal = k * Val_ResizeLength
                New_Area = (Val_Horizontal, Val_Vertical, Val_Horizontal + Val_ResizeLength, Val_Vertical + Val_ResizeLength)
                print(str(Val_Horizontal) + ", " + str(Val_Vertical) + ", " + str(Val_ResizeLength) + ", " + str(
                    Val_ResizeLength))
                img_Cropped = resize_Img.crop(New_Area)
                # TGA파일의 Alpha처리 문제로 인한 대처방안_2
                New_R, New_G, New_B, New_A = img_Cropped.split()
                img_RGB= img_Cropped.convert("RGB")
                img_Resized = img_RGB.resize(New_Size, Image.LANCZOS)
                img_A = New_A.resize(New_Size, Image.LANCZOS)
                img_Resized.putalpha(img_A)

                img_Resized.save(New_FileName + '_' + str(i + 1) + "_" + str(k + 1) + '.TGA')
                Val_Count = Val_Count + 1
        print(str(Val_Count-1))
        print("Done!")
        ctypes.windll.user32.MessageBoxW(None, "완료", "분할완료!!!", 0)
        #messagebox.showinfo("완료", "분할완료!")

if __name__ == "__main__":
    import sys

    app = QtWidgets.QApplication(sys.argv)
    Dialog = QtWidgets.QDialog()
    ui = Ui_Dialog()
    ui.setupUi(Dialog)
    Dialog.show()
    sys.exit(app.exec_())




