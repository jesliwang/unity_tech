using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System;

public class CustomPortraitManager : NrTSingleton<CustomPortraitManager>
{
    public class CheckTimerInfo
    {
        protected float m_UpdateCheckDeltaNow = 0.0f;
        protected float m_UpdateCheckDelta = 2.0f;

        public CheckTimerInfo(float addTime)
        {
            m_UpdateCheckDeltaNow = 0.0f;
            m_UpdateCheckDelta = addTime;
        }

        public void Update()
        {
            m_UpdateCheckDeltaNow += Time.deltaTime;
        }

        public void Restart()
        {
            m_UpdateCheckDeltaNow = 0.0f;
        }

        public bool IsFinish()
        {
            if (m_UpdateCheckDeltaNow > m_UpdateCheckDelta)
            {
                return true;
            }

            return false;
        }
    }

    //=========================================================================

    public class LifeTimeInfo
    {
        private float m_LastUseTime = 0.0f;
        private float m_AutoDestroyTime = 60.0f;

        public LifeTimeInfo(float lifeTime)
        {
            m_AutoDestroyTime = lifeTime;
            StartLifeTime();
        }

        public void StartLifeTime()
        {
            m_LastUseTime = Time.unscaledTime;
        }

        public bool IsAutoDestroyTime()
        {
            float durationTime = Time.unscaledTime - m_LastUseTime;
            if (durationTime > m_AutoDestroyTime)
            {
                return true;
            }
            return false;
        }

        public float GetRemainTime()
        {
            float durationTime = Time.unscaledTime - m_LastUseTime;
            return m_AutoDestroyTime - durationTime;
        }
    }
    public class DlgInfo
    {
        public string UID { get; private set; }
        public List<Action<Texture, string>> Actions;
    }

    string m_PortraitUrl;
    public string PortraitUrl
    {
        get
        {
            if (Util.IsEDITOR() == true)
            {
                return "https://ndream-cf.s3.us-west-2.amazonaws.com/portrait_image/";
            }
            return m_PortraitUrl;
        }
        set { m_PortraitUrl = value; }
    }

    string m_PortraitImageUploadFolder;

    public string PortraitImageUploadFolder
    {
        get
        {
            if (Util.IsEDITOR() == true)
            {
                return "portrait_image/";
            }
            return m_PortraitImageUploadFolder;
        }
        set { m_PortraitImageUploadFolder = value; }
    }


    private Dictionary<string, Texture> m_TexturePoolList = new Dictionary<string, Texture>(); //로딩 완료된 텍스쳐
    private Dictionary<string, List<Action<Texture, string>>> m_TextureLoadingList = new Dictionary<string, List<Action<Texture, string>>>(); //로딩중인 텍스쳐 두번 들어올때를 대비 한다.

    // 너무 자주 어데이트가 일어나는것을 방지 하기 위하여 체크
    private CheckTimerInfo m_UpdateCheckTime = new CheckTimerInfo(2.0f);
    // 삭제 대기중인 리스트
    protected Dictionary<string, LifeTimeInfo> m_DicLifeTimeDestory = new Dictionary<string, LifeTimeInfo>();

    private Texture2D m_TempTexture = null;

    CustomPortraitManager()
    {
        HttpImageDownloadManager.Instance.DeleteDownloadFolder("CustomPortrait");
    }

    public bool Initialize()
    {
        return true;
    }

    public void Update()
    {
        m_UpdateCheckTime.Update();

        if (m_UpdateCheckTime.IsFinish() == true)
        {
            m_UpdateCheckTime.Restart();
            UpdateLifeTimeDestory();
        }
    }
    public Texture2D GetTempTexture()
    {
        if (m_TempTexture == null)
        {
            m_TempTexture = Resources.Load<Texture2D>("ui/portrait/Custom_256");
        }

        return m_TempTexture;
    }
    // 라이프 타임이 다된 오브젝트 삭제
    private void UpdateLifeTimeDestory()
    {
        if (m_DicLifeTimeDestory.Count == 0)
            return;

        List<string> removeList = new List<string>();
        foreach (var life in m_DicLifeTimeDestory)
        {
            if (life.Value.IsAutoDestroyTime() == true)
            {
                if (m_TexturePoolList.ContainsKey(life.Key) == true)
                {
                    UnityEngine.Object.Destroy(m_TexturePoolList[life.Key]);
                    m_TexturePoolList.Remove(life.Key);
                }
                removeList.Add(life.Key);
                NDebug.Log("LifeTimeDestory : " + life.Key);
            }
        }

        for (int i = 0; i < removeList.Count; i++)
        {
            m_DicLifeTimeDestory.Remove(removeList[i]);
        }
    }
    public Texture Find(string imageID)
    {
        Texture tex = null;
        if (true == m_TexturePoolList.TryGetValue(imageID, out tex))
        {
            return tex;
        }

        return null;
    }
    public void Download(string imageID, Action<Texture, string> callBack)
    {
        Texture tex = null;
        if (true == m_TexturePoolList.TryGetValue(imageID, out tex))
        {
            RemoveLifeTime(imageID);

            callBack?.Invoke(tex, imageID);
        }
        else
        {
            List<Action<Texture, string>> callBackList;
            if (true == m_TextureLoadingList.TryGetValue(imageID, out callBackList))
            {
                callBackList.Add(callBack);
            }
            else
            {
                callBackList = new List<Action<Texture, string>>();
                callBackList.Add(callBack);

                m_TextureLoadingList.Add(imageID, callBackList);
                var operation = new CustomDownloadOperation();
                GameMain.Instance.StartCoroutine(operation.Download(imageID));
            }
        }
    }
    public void DownloadComplate(string imageID, Texture tex)
    {
        List<Action<Texture, string>> callBackList;
        if (true == m_TextureLoadingList.TryGetValue(imageID, out callBackList))
        {
            if (tex != null)
            {
                // 텍스쳐 키가 두번 중첩되는 현상이 발견되어 예외처리합니다.
                if (!m_TexturePoolList.ContainsKey(imageID))
                {
                    m_TexturePoolList.Add(imageID, tex);
                }
            }

            for (int i = 0; i < callBackList.Count; i++)
            {
                callBackList[i]?.Invoke(tex, imageID);
            }

            m_TextureLoadingList.Remove(imageID);
        }
    }

    public void CancelDownload(string imageID, Action<Texture, string> callBack)
    {
        List<Action<Texture, string>> callBackList;
        if (true == m_TextureLoadingList.TryGetValue(imageID, out callBackList))
        {
            for (int i = 0; i < callBackList.Count; i++)
            {
                if (callBackList[i] == callBack)
                {
                    callBackList.Remove(callBack);
                }
            }
        }
    }
    public void ReleaseAll()
    {
        m_TextureLoadingList.Clear();

        foreach (var tex in m_TexturePoolList)
        {
            AddLifeTimeDestory(tex.Key);
        }
    }

    private void RemoveLifeTime(string imageID)
    {
        if (m_DicLifeTimeDestory.ContainsKey(imageID) == true)
        {
            m_DicLifeTimeDestory.Remove(imageID);
        }
    }
    protected void AddLifeTimeDestory(string imageID, float lifeTime = 120.0f)
    {
        if (m_DicLifeTimeDestory.ContainsKey(imageID) == false)
        {
            LifeTimeInfo lifeInfo = new LifeTimeInfo(lifeTime);
            lifeInfo.StartLifeTime();
            m_DicLifeTimeDestory.Add(imageID, lifeInfo);
        }
    }

    public void Release(string imageID)
    {
        if (m_TextureLoadingList.ContainsKey(imageID) == true)
        {
            m_TextureLoadingList.Remove(imageID);
        }
        else
        {
            AddLifeTimeDestory(imageID);
        }
    }
    public void DestoryAll()
    {
        m_DicLifeTimeDestory.Clear();
        m_TextureLoadingList.Clear();

        foreach (var tex in m_TexturePoolList)
        {
            UnityEngine.Object.Destroy(tex.Value);
        }
        m_TexturePoolList.Clear();
    }

    public void ReplaceTextuePool(string imageID, Texture tex)
    {
        if (tex != null)
        {
            if (m_TexturePoolList.ContainsKey(imageID) == true)
            {
                m_TexturePoolList[imageID] = tex;
            }
            else
            {
                m_TexturePoolList.Add(imageID, tex);
            }
        }
    }
}