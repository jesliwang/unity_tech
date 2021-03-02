using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using WasServer.Common;

public class CustomPortraitUploadManager : NrTSingleton<CustomPortraitUploadManager>
{
    private Action<bool> m_ChangeCallBack = null;
    private Action<bool> m_UploadCallBack = null;
    private readonly int m_DefaultTextureSize = 128;
    private const string CONST_CUSTOM_IMAGE_PATH = "CustomImagePath";

    public string CustomImageFilePath
    {
        get
        {
            if (Util.IsEDITOR() == true)
            {
                return Application.dataPath + "/profileTemp.jpg";
            }
            return PlayerPrefs.GetString(CONST_CUSTOM_IMAGE_PATH);
        }
    }

    CustomPortraitUploadManager()
    {
    }

    public bool Initialize()

    {
        return true;
    }

    public Texture2D GetCustomImageTextureByLocalTempFile()
    {
        string path = CustomPortraitUploadManager.Instance.CustomImageFilePath;

        if (File.Exists(path))
        {
            try
            {
                var bytes = File.ReadAllBytes(path);
                if (bytes.Length > 0)
                {
                    Texture2D tex = new Texture2D(m_DefaultTextureSize, m_DefaultTextureSize);
                    tex.LoadImage(bytes);
                    return tex;
                }
            }
            catch (Exception ex)
            {
                NDebug.LogError(ex.Message);
            }
        }
        else
        {
            NDebug.LogWarning(path + "Not Exist!");
        }

        return null;
    }

    Texture2D ScaleTexture(Texture2D source, int width, int height)
    {
        Texture2D result = new Texture2D(width, height, source.format, false);
        Color[] rpixels = result.GetPixels(0);
        float incX = (1.0f / (float)width);
        float incY = (1.0f / (float)height);
        for (int px = 0; px < rpixels.Length; px++)
        {
            rpixels[px] = source.GetPixelBilinear(incX * ((float)px % width), incY * ((float)Mathf.Floor(px / width)));
        }
        result.SetPixels(rpixels, 0);
        result.Apply();
        return result;
    }

    public Texture2D ResampleAndCrop(Texture2D source, int targetWidth, int targetHeight)
    {
        int sourceWidth = source.width;
        int sourceHeight = source.height;
        float sourceAspect = (float)sourceWidth / sourceHeight;
        float targetAspect = (float)targetWidth / targetHeight;
        int xOffset = 0;
        int yOffset = 0;
        float factor = 1;
        if (sourceAspect > targetAspect)
        { // crop width
            factor = (float)targetHeight / sourceHeight;
            xOffset = (int)((sourceWidth - sourceHeight * targetAspect) * 0.5f);
        }
        else
        { // crop height
            factor = (float)targetWidth / sourceWidth;
            yOffset = (int)((sourceHeight - sourceWidth / targetAspect) * 0.5f);
        }
        Color32[] data = source.GetPixels32();
        Color32[] data2 = new Color32[targetWidth * targetHeight];
        for (int y = 0; y < targetHeight; y++)
        {
            for (int x = 0; x < targetWidth; x++)
            {
                var p = new Vector2(Mathf.Clamp(xOffset + x / factor, 0, sourceWidth - 1), Mathf.Clamp(yOffset + y / factor, 0, sourceHeight - 1));
                // bilinear filtering
                var c11 = data[Mathf.FloorToInt(p.x) + sourceWidth * (Mathf.FloorToInt(p.y))];
                var c12 = data[Mathf.FloorToInt(p.x) + sourceWidth * (Mathf.CeilToInt(p.y))];
                var c21 = data[Mathf.CeilToInt(p.x) + sourceWidth * (Mathf.FloorToInt(p.y))];
                var c22 = data[Mathf.CeilToInt(p.x) + sourceWidth * (Mathf.CeilToInt(p.y))];
                //var f = new Vector2(Mathf.Repeat(p.x, 1f), Mathf.Repeat(p.y, 1f));
                data2[x + y * targetWidth] = Color.Lerp(Color.Lerp(c11, c12, p.y), Color.Lerp(c21, c22, p.y), p.x);
            }
        }

        var tex = new Texture2D(targetWidth, targetHeight);
        tex.SetPixels32(data2);
        tex.Apply(true);
        return tex;
    }

    public byte[] ResampleAndCrop(byte[] bytes, int targetWidth, int targetHeight)
    {
        Texture2D source = new Texture2D(0, 0);
        source.LoadImage(bytes);

        if (source.width <= m_DefaultTextureSize &&
            source.height <= m_DefaultTextureSize)
        {
            return bytes;
        }
        else
        {
            NDebug.Log("ResampleAndCrop: CustomPortraitSize( {0} / {1} )", source.width, source.height);
        }

        int sourceWidth = source.width;
        int sourceHeight = source.height;
        float sourceAspect = (float)sourceWidth / sourceHeight;
        float targetAspect = (float)targetWidth / targetHeight;
        int xOffset = 0;
        int yOffset = 0;
        float factor = 1;
        if (sourceAspect > targetAspect)
        { // crop width
            factor = (float)targetHeight / sourceHeight;
            xOffset = (int)((sourceWidth - sourceHeight * targetAspect) * 0.5f);
        }
        else
        { // crop height
            factor = (float)targetWidth / sourceWidth;
            yOffset = (int)((sourceHeight - sourceWidth / targetAspect) * 0.5f);
        }
        Color32[] data = source.GetPixels32();
        Color32[] data2 = new Color32[targetWidth * targetHeight];
        for (int y = 0; y < targetHeight; y++)
        {
            for (int x = 0; x < targetWidth; x++)
            {
                var p = new Vector2(Mathf.Clamp(xOffset + x / factor, 0, sourceWidth - 1), Mathf.Clamp(yOffset + y / factor, 0, sourceHeight - 1));
                // bilinear filtering
                var c11 = data[Mathf.FloorToInt(p.x) + sourceWidth * (Mathf.FloorToInt(p.y))];
                var c12 = data[Mathf.FloorToInt(p.x) + sourceWidth * (Mathf.CeilToInt(p.y))];
                var c21 = data[Mathf.CeilToInt(p.x) + sourceWidth * (Mathf.FloorToInt(p.y))];
                var c22 = data[Mathf.CeilToInt(p.x) + sourceWidth * (Mathf.CeilToInt(p.y))];
                //var f = new Vector2(Mathf.Repeat(p.x, 1f), Mathf.Repeat(p.y, 1f));
                data2[x + y * targetWidth] = Color.Lerp(Color.Lerp(c11, c12, p.y), Color.Lerp(c21, c22, p.y), p.x);
            }
        }

        var tex = new Texture2D(targetWidth, targetHeight);
        tex.SetPixels32(data2);
        tex.Apply(true);

        return tex.EncodeToJPG();
    }
    private void UploadProfilePath(byte[] bytes)
    {
        byte[] fix_bytes = ResampleAndCrop(bytes, m_DefaultTextureSize, m_DefaultTextureSize);

        if (User.Instance.UID > 0 && fix_bytes.Length > 0)
        {
            PortraitImageUploadRequest request = new PortraitImageUploadRequest();
            request.FileName = CustomPortraitManager.Instance.PortraitImageUploadFolder + User.Instance.UID.ToString() + ".jpg";
            request.Image = Convert.ToBase64String(fix_bytes);

            string serverUrl = WOTURL.WasServerURL + "/" + "PortraitImageUpload";

            GameMain.Instance.StartCoroutine(new WebRequestOperation().RequestPOST(serverUrl, request, OnSuccess, OnFail));
        }
        else
        {
            OnFail(string.Empty, WebRequestError.Undefined);
        }
    }

    public void UploadProfileImage(Action<bool> callback)
    {
        m_UploadCallBack = callback;

        string path = CustomImageFilePath;

        if (File.Exists(path))
        {
            try
            {
                var bytes = File.ReadAllBytes(path);
                if (bytes.Length > 0)
                {
                    PublicUIMethod.ShowLoadingSpin(true);
                    UploadProfilePath(bytes);
                    return;
                }
            }
            catch (Exception ex)
            {
                NDebug.LogError(ex.Message);
            }
        }
        else
        {
            NDebug.LogWarning(path + "Not Exist!");
        }

        OnFail("", WebRequestError.Undefined);
    }

    private void OnSuccess(string text, Action<object[]> callback, object[] param)
    {
        SimpleJSON.JSONNode node = SimpleJSON.JSON.Parse(text);
        int ResuleCode = node["ResultCode"].AsInt;
        if (ResuleCode == 0)
        {
        }

        if (m_UploadCallBack != null)
        {
            m_UploadCallBack(true);
            m_UploadCallBack = null;
        }

        PublicUIMethod.ShowLoadingSpin(false);

        NDebug.Log("CustomPortraitUploadManager::OnSuccess");
    }
    private void OnFail(string value, WebRequestError error)
    {
        if (m_UploadCallBack != null)
        {
            m_UploadCallBack(false);
            m_UploadCallBack = null;
        }

        PublicUIMethod.ShowLoadingSpin(false);

        NDebug.Log("CustomPortraitUploadManager::OnFail");
    }
    void OnVideoSelect(string vidPath)
    {
    }

    void OnError(string errorMsg)
    {
        NDebug.Log("CustomPortraitUploadManager::Error : " + errorMsg);
        m_ChangeCallBack = null;
    }
    void OnCancel()
    {
        NDebug.Log("CustomPortraitUploadManager::Cancel by user");
        m_ChangeCallBack = null;

    }
    public void ProfileChangeOnGallery(Action<bool> callback)
    {
        NDebug.Log("CustomPortraitUploadManager::ProfileChangeOnGallery");

        m_ChangeCallBack = callback;

        if (Util.IsEDITOR() == false && PlatformLoginManager.Instance.IsPermissionGranted("WRITE_EXTERNAL_STORAGE") == false )
        {
            PlatformLoginManager.Instance.ExecutePermission(new PlatformLogin.PermissionParameter("WRITE_EXTERNAL_STORAGE", true, OnPermissionGallery, OnPermissionGalleryCancel));
        }
        else
        {
            OnPermissionGallery();
        }
    }

    private void OnPermissionGallery()
    {
        NDebug.Log("CustomPortraitUploadManager::OnPermissionGallery");
        WOTPlugin.OpenGallery(OnAndroidImageCapture);
    }

    private void OnPermissionGalleryCancel()
    {
    }

    public void ProfileChangeOnCamera(Action<bool> callback)
    {
        NDebug.Log("CustomPortraitUploadManager::ProfileChangeOnCamera");
        m_ChangeCallBack = callback;

        if (Util.IsEDITOR() == false)
        {
            if (PlatformLoginManager.Instance.IsPermissionGranted("CAMERA") == true)
            {
                if( PlatformLoginManager.Instance.IsPermissionGranted("WRITE_EXTERNAL_STORAGE") == true )
                {
                    OnPermissionGallery();
                }
                else
                {
                    PlatformLoginManager.Instance.ExecutePermission(new PlatformLogin.PermissionParameter("WRITE_EXTERNAL_STORAGE", true, OnPermissionCemera, OnPermissionCaemraCancel));
                }
            }
            else
            {
                PlatformLoginManager.Instance.ExecutePermission(new PlatformLogin.PermissionParameter("CAMERA", true, OnPermissionCameraSuccess, OnPermissionCaemraCancel));
            }
        }
        else
        {
            OnPermissionGallery();
        }
    }

    public void OnPermissionCameraSuccess()
    {
        if (Util.IsEDITOR() == false)
        {
            PlatformLoginManager.Instance.ExecutePermission(new PlatformLogin.PermissionParameter("WRITE_EXTERNAL_STORAGE", true, OnPermissionCemera, OnPermissionCaemraCancel));
        }
        else
        {
            OnPermissionGallery();
        }
    }

    private void OnPermissionCemera()
    {
        NDebug.Log("CustomPortraitUploadManager::OnPermissionCemera");
        WOTPlugin.OpenCamera(OnAndroidImageCapture);
    }

    private void OnPermissionCaemraCancel()
    {
    }

    public void OnAndroidImageCapture(string jsonNode)
    {
        NDebug.Log("CustomPortraitUploadManager::OnAndroidImageCapture");

        SimpleJSON.JSONNode node = SimpleJSON.JSON.Parse(jsonNode);
        string path = node["path"];
        int result = node["result"].AsInt;

        if (result == 0)
        {
            NDebug.Log(path);
            if (File.Exists(path))
            {
                // 해당 경로의 이미지 파일 있으면 경로를 저장한다.
                PlayerPrefs.SetString(CONST_CUSTOM_IMAGE_PATH, path);
                PlayerPrefs.Save();

                NDebug.Log("CustomPortraitUploadManager::OnAndroidImageCapture - path: {0}", path);

                if (m_ChangeCallBack != null)
                {
                    m_ChangeCallBack(true);
                    m_ChangeCallBack = null;
                }
                return;
            }
            else
            {
                NDebug.LogWarning(path + "Not Exist!");
            }
        }

        if (m_ChangeCallBack != null)
        {
            m_ChangeCallBack(false);
            m_ChangeCallBack = null;
        }
    }

}
