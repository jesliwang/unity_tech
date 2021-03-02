using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using System;
using System.Collections.Generic;
using UnityEngine.Networking;
using System.IO;

public class CustomDownloadOperation
{
    public IEnumerator Download(string imageID)
    {
        bool bDownloadMode = false;
        string fileName = string.Format("{0}{1}", imageID, ".jpg");
        string url = string.Empty;
        if (HttpImageDownloadManager.Instance.IsLocalExists(fileName, "CustomPortrait") == true)
        {
            url = "file://" + HttpImageDownloadManager.Instance.GetLocalPathForFile(fileName, "CustomPortrait");
        }
        else
        {
            bDownloadMode = true;
            url = string.Format("{0}{1}", CustomPortraitManager.Instance.PortraitUrl, fileName);
        }

        NDebug.Log("Portrait url = " + url);

        UnityWebRequest imageRequest = UnityWebRequestTexture.GetTexture(url);

        yield return imageRequest.SendWebRequest();

        if (imageRequest.isNetworkError || imageRequest.isHttpError)
        {
            Debug.Log(imageRequest.error);
            CustomPortraitManager.Instance.DownloadComplate(imageID, null);
        }
        else
        {
            Texture2D texture = ((DownloadHandlerTexture)imageRequest.downloadHandler).texture;
            CustomPortraitManager.Instance.DownloadComplate(imageID, texture);

            if (bDownloadMode == true)
            {
                HttpImageDownloadManager.Instance.CreateDownloadFolder("CustomPortrait");
                string saveFile = HttpImageDownloadManager.Instance.GetLocalPathForFile(fileName, "CustomPortrait");

                FileStream fileStream = new FileStream(saveFile, FileMode.Create, FileAccess.Write);
                fileStream.Write(imageRequest.downloadHandler.data, 0, imageRequest.downloadHandler.data.Length);

                fileStream.Flush();
                fileStream.Close();
            }
        }
    }
}
