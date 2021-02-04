import cv2 as cv
import numpy as np
import os.path
from wand.image import Image as WImage
from PIL import Image
import JYP_BlendModes as JYP


# 함수 정의 -----------------------------------------------------------------------
def NormalTexBake( path_BasecolorTex, path_NormalTex, path_SaveRoot):

    # Basecolor와 Normal Texture 존재여부 확인
    if (os.path.exists(path_BasecolorTex) == False) :
        print("::: not exist file(Basecolor)!! - %s" % path_BasecolorTex)
        return 0
    if (os.path.exists(path_NormalTex) == False) :
        print("::: not exist file(Normal)!! - %s" % path_BasecolorTex)
        return 0

    # 파일확장자명 (TGA) 인식오류로 인한 컨버팅(to png)
    BaseImg = Image.open(path_BasecolorTex)
    BasePath, BaseExtension = os.path.splitext(path_BasecolorTex)
    BasePath = BasePath + ".png"
    BaseImg.save(BasePath)
    path_BasecolorTex = BasePath
    BaseSize = BaseImg.size


    NormalImg = Image.open(path_NormalTex)
    NormalSize = NormalImg.size
    if (NormalSize != BaseSize) :
        NewNormalImg = NormalImg.resize(BaseSize, Image.LANCZOS)
        NormalImg = NewNormalImg
    NormalPath, NormalExtension = os.path.splitext(path_NormalTex)
    NormalPath = NormalPath + ".png"
    NormalImg.save(NormalPath)
    path_NormalTex = NormalPath

    # 작업과정에서 생성되는 중간 Texture 저장경로 설정
    T_path_Base, T_ext_Base = os.path.splitext(path_BasecolorTex)
    T_path_Normal, T_ext_Normal = os.path.splitext(path_NormalTex)
    T_path_normalizNormal = T_path_Normal + "_Normaliz" + T_ext_Normal
    T_path_level1G = T_path_Normal + "_Level1G" + T_ext_Normal
    T_path_level2G = T_path_Normal + "_Level2G" + T_ext_Normal
    T_path_normalizeG1 = T_path_Normal + "_NormalizeG1" + T_ext_Normal
    print(T_path_normalizeG1)
    T_path_normalizeG2 = T_path_Normal + "_NormalizeG2" + T_ext_Normal
    T_path_levelB = T_path_Normal + "_LevelB" + T_ext_Normal
    T_path_normalizeB = T_path_Normal + "_NormalizeB" + T_ext_Normal
    T_path_Blend1 = T_path_Base + "_Blend1" + T_ext_Base
    T_path_Blend2 = T_path_Base + "_Blend2" + T_ext_Base
    T_path_Blend3 = T_path_Base + "_Blend3" + T_ext_Base



    SaveFilePath = os.path.dirname(path_BasecolorTex)
    FilePathNum = len(SaveFilePath)
    SaveFilePath = SaveFilePath[2:FilePathNum]
    SaveFilePath = path_SaveRoot + SaveFilePath
    if not os.path.exists(SaveFilePath):
        os.makedirs(SaveFilePath)

    SaveFileName = os.path.basename(path_BasecolorTex)
    print(SaveFilePath + "/" + SaveFileName)
    SaveFilePath = SaveFilePath + "/" + SaveFileName





    # Step1. Invert Green Channel
    src = cv.imread(path_NormalTex, cv.IMREAD_COLOR)

    B, G, R = cv.split(src)
    G = cv.bitwise_not(G)
    img_invertNormal = cv.merge((B, G, R))

    # Step2. Normalize
    img_Normal = cv.normalize(img_invertNormal, img_invertNormal, 0, 255, cv.NORM_MINMAX)
    cv.imwrite(T_path_normalizNormal, img_Normal)

    # Step3. G채널 레벨1
    wand_img = WImage(filename = T_path_normalizNormal)
    wand_img.level(0.06, 0.906, gamma=0.4, channel='green')
    wand_img.save(filename = T_path_level1G)
    cv_imgG1 = cv.imread(T_path_level1G, cv.IMREAD_COLOR)
    cv_imgG1_B, cv_imgG1_G, cv_imgG1_R = cv.split(cv_imgG1)

    cv_imgG1 = cv.merge((cv_imgG1_G, cv_imgG1_G, cv_imgG1_G))
    cv.imwrite(T_path_normalizeG1, cv_imgG1)

    # Step4. G채널 레벨2
    wand_img = WImage(filename = T_path_normalizNormal)
    wand_img.level(0.071, 0.939, gamma=1.7, channel='green')
    wand_img.save(filename = T_path_level2G)
    cv_imgG2 = cv.imread(T_path_level2G, cv.IMREAD_COLOR)
    cv_imgG2_B, cv_imgG2_G, cv_imgG2_R = cv.split(cv_imgG2)
    cv_imgG2 = cv.merge((cv_imgG2_G, cv_imgG2_G, cv_imgG2_G))
    cv_normalizeG = cv.normalize(cv_imgG2, cv_imgG2, 128, 255, cv.NORM_MINMAX)
    cv.imwrite(T_path_normalizeG2, cv_normalizeG)

    # Step5. B채널 레벨
    wand_img = WImage(filename = T_path_normalizNormal)
    wand_img.level(0.73, 1, gamma=1.0, channel='blue')
    wand_img.save(filename = T_path_levelB)
    cv_imgB = cv.imread(T_path_levelB, cv.IMREAD_COLOR)
    cv_imgB_B, cv_imgB_G, cv_imgB_R = cv.split(cv_imgB)
    cv_imgB = cv.merge((cv_imgB_B, cv_imgB_B, cv_imgB_B))
    cv_normalizeB = cv.normalize(cv_imgB, cv_imgB, 128, 255, cv.NORM_MINMAX)
    cv.imwrite(T_path_normalizeB, cv_normalizeB)


    # Step6. BaseColor와 Step4 블랜딩
    cv_imgDN = cv.imread(path_BasecolorTex, cv.IMREAD_COLOR)
    cv_imgWhite = np.zeros((cv_normalizeG.shape[0], cv_normalizeG.shape[1], 3), np.uint8)
    cv_imgWhite[:] = 255
    cv_imgFore = cv.addWeighted(cv_normalizeG, 0.9, cv_imgWhite, 0.1, 0)
    cv_imgFore = cv_imgFore / 255
    cv_imgBack = cv_imgDN / 255
    cv_imgBlend = cv.multiply(cv_imgFore, cv_imgBack) * 255
    cv.imwrite(T_path_Blend1, cv_imgBlend)

    # Step7. Step5와 블랜딩
    cv_imgBlend = cv_imgBlend / 255
    cv_imgFore = cv.addWeighted(cv_normalizeB, 0.85, cv_imgWhite, 0.15, 0)
    cv_imgFore = cv_imgFore / 255
    cv_imgBlend = cv.multiply(cv_imgFore, cv_imgBlend) * 255
    cv.imwrite(T_path_Blend2, cv_imgBlend)
    #cv.imwrite("D:/[BlessMobile]/Baked//[BlessMobile]/[BG_Textures]/Game/BG/3_Prefab/Desert/Texture/T_DesertValley_Camp06_Blend2.png", cv_imgBlend)

    # Step8. Step3과 블랜딩
    cv_imgWhite[:] = 0
    cv_imgG1 = cv.imread(T_path_normalizeG1, -1).astype(float)

    cv_imgG1 = JYP.JYP_Multiply(cv_imgG1,cv_imgG1,1.0).astype(np.uint8)
   # cv_imgG1 = JYP.JYP_Multiply(cv_imgG1, cv_imgG1, 1.0).astype(np.uint8)
    #cv.imwrite( "D:/[BlessMobile]/Baked//[BlessMobile]/[BG_Textures]/Game/BG/3_Prefab/Desert/Texture/T_DesertValley_Camp06_G1.png", cv_imgG1)

    cv_imgFore = cv_imgG1[:, :, :3]
    #cv.imwrite( "D:/[BlessMobile]/Baked//[BlessMobile]/[BG_Textures]/Game/BG/3_Prefab/Desert/Texture/T_DesertValley_Camp06_Blend3.png", cv_imgFore)
    cv_imgFore = cv_imgFore.astype(float)
    cv_imgBlend = JYP.JYP_ColorDodge(cv_imgFore, cv_imgBlend, 0.35).astype(np.uint8)

    # 최종 베이크 텍스쳐 저장
    cv.imwrite(SaveFilePath, cv_imgBlend)

    # 중간 작업용 텍스쳐 삭제
    os.remove(T_path_normalizNormal)
    os.remove(T_path_level1G)
    os.remove(T_path_level2G)
    os.remove(T_path_normalizeG1)
    os.remove(T_path_normalizeG2)
    os.remove(T_path_levelB)
    os.remove(T_path_normalizeB)
    os.remove(T_path_Blend1)
    os.remove(T_path_Blend2)

    # 최종 저장파일 png -> tga로 재변환
    BaseImg = Image.open(SaveFilePath)
    BasePath, BaseExtension = os.path.splitext(SaveFilePath)
    BasePath = BasePath + ".TGA"
    BaseImg.save(BasePath)
    os.remove(BasePath)
    os.remove(NormalPath)

    return 0
# ---------------------------------------------------------------------------------
# 메인 함수 -----------------------------------------------------------------------
if __name__ == '__main__' :
    print ("Execute NormalBake!!")