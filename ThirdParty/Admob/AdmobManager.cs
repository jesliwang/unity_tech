using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using GoogleMobileAds.Api;
using GoogleMobileAds.Api.Mediation;
using NLibCs;
using NdreamPayment;
using PaperPlaneTools;

public class AdmobManager : Framework.TMonoSingleton<AdmobManager>
{

    private string admobRvAdUnitID = string.Empty;

    private Coroutine ShowCoroutine = null;

    private Action m_CompleteCallBack = null;
    private Action m_StartCallBack = null;
    private Action m_CloseCallBack = null;

    private List<Action> CompleteCallBacks = new List<Action>();
    private List<Action> CloseCallBacks = new List<Action>();

    private RewardedAd rewardedAd = null;

    public bool m_Init = false;

    public bool m_bRvLoading = false;

    public int LoadTryCount = 0;

    public AdmobManager()
    {
        Init();
    }

    public void Init()
    {
        try
        {
            if (m_Init == true)
            {
                return;
            }

            // Initialize the Google Mobile Ads SDK.
            MobileAds.Initialize(initStatus => 
            {
                LoadTryCount = 0;
                m_Init = true;
                NDebug.Log("AdmobManager Init");
            });
        }
        catch(Exception ex)
        {
            NDebug.Log("AdmobManager Init Exception!!!! : " + ex);

        }
    }
    public void LoadAdMobRV(bool force  = true)
    {
        if (m_Init == false)
        {
            NDebug.Log("AdmobManager LoadAdMobRV : m_Init == false");
            return;
        }

        if( PlatformTrackerManager.Instance.IsEnableTracking() == false )
        {
            NDebug.Log("AdmobManager LoadAdMobRV : IsEnableTracking == false");
            return;
        }

        NAuthPlugin.SetEnableFBADNetworkTracking(true);

        m_bRvLoading = true;

        if( force == true || rewardedAd == null || (rewardedAd != null && rewardedAd.IsLoaded() == false) )
        {
#if UNITY_ANDROID
            admobRvAdUnitID = Util.IsLIVE() ? TableConstUIData.Instance.CONST_GOOGLE_AD_LOAD_AOS : TableConstUIData.Instance.CONST_GOOGLE_AD_LOAD_AOS_QA;
#elif UNITY_IPHONE
        admobRvAdUnitID = Util.IsLIVE() ? TableConstUIData.Instance.CONST_GOOGLE_AD_LOAD_IOS : TableConstUIData.Instance.CONST_GOOGLE_AD_LOAD_IOS_QA;
#endif
            rewardedAd = new RewardedAd(admobRvAdUnitID);

            // Called when an ad request has successfully loaded.
            rewardedAd.OnAdLoaded += HandleRewardedAdLoaded;
            // Called when an ad request failed to load.
            rewardedAd.OnAdFailedToLoad += HandleRewardedAdFailedToLoad;
            // Called when an ad is shown.
            rewardedAd.OnAdOpening += HandleRewardedAdOpening;
            // Called when an ad request failed to show.
            rewardedAd.OnAdFailedToShow += HandleRewardedAdFailedToShow;
            // Called when the user should be rewarded for interacting with the ad.
            rewardedAd.OnUserEarnedReward += HandleUserEarnedReward;
            // Called when the ad is closed.
            rewardedAd.OnAdClosed += HandleRewardedAdClosed;

            // Create an empty ad request.
            AdRequest request = new AdRequest.Builder().Build();
            rewardedAd.LoadAd(request);

            NDebug.Log("AdmobManager LoadAdMobRV ::: 0 " + admobRvAdUnitID);
        }
    }

    public void ShowAD(bool firstKill = false)
    {
        if (Util.IsEDITOR() == true)
        {
            return;
        }

        if( PlatformTrackerManager.Instance.IsEnableTracking() == true )
        {
            if (rewardedAd != null && rewardedAd.IsLoaded())
            {
                NDebug.Log("AdmobManager ShowAD Show");
                rewardedAd.Show();
            }
            else
            {
                if (firstKill != true)
                {
                    MessageBoxDlg messageBoxDlg = UIFormManager.Instance.GetUIForm<MessageBoxDlg>();
                    if (messageBoxDlg != null)
                    {
                        messageBoxDlg.Set(NTextManager.Instance.GetText("COMMON_UI_ADVERTISING_NOT_CONNECTED1"),
                                          NTextManager.Instance.GetText("COMMON_UI_ADVERTISING_NOT_CONNECTED2"),
                                          NTextManager.Instance.GetText("UI_COMMON_CONFIRM_YES")
                                          );
                        messageBoxDlg.Open();
                    }
                }

                if (m_bRvLoading == false)
                {
                    LoadAdMobRV(true);
                }
            }
        }
        else
        {
            ShowTrackingMessageBox();
        }
    }

    //*** AdMob RV Callback
    public void HandleRewardedAdLoaded(object sender, EventArgs args)
    {
        LoadTryCount = 0;
        m_bRvLoading = false;
        NDebug.Log("AdmobManager HandleRewardedAdLoaded event received");
    }

    public void HandleRewardedAdFailedToLoad(object sender, AdErrorEventArgs args)
    {
        NDebug.Log("AdmobManager  HandleRewardedAdFailedToLoad event received with message: " + args.Message);
        if (LoadTryCount < 5)
        {
            LoadAdMobRV(true);
            LoadTryCount++;
        }
        else
        {
            m_bRvLoading = false;
            LoadTryCount = 0;
        }
    }
    public void HandleRewardedAdOpening(object sender, EventArgs args)
    {
        NDebug.Log("AdmobManager  HandleRewardedAdOpening event received");
    }
    public void HandleRewardedAdFailedToShow(object sender, AdErrorEventArgs args)
    {
        ResultEventProcess();
        LoadAdMobRV(true);

        m_CloseCallBack?.Invoke();

        NDebug.Log("AdmobManager  HandleRewardedAdFailedToShow event received with message: " + args.Message);
    }
    public void HandleRewardedAdClosed(object sender, EventArgs args)
    {
        ResultEventProcess();
        LoadAdMobRV(true);


        if (PaymentManager.Instance.IsPaymentPause())
        {
            CloseCallBacks.Add(m_CloseCallBack);
        }
        else
        {
            m_CloseCallBack?.Invoke();
        }
        NDebug.Log("AdmobManager HandleRewardedAdClosed event received");
    }
    public void ResultEventProcess()
    {
        LoadTryCount = 0;
    }
    public void HandleUserEarnedReward(object sender, Reward args)
    {
        string type = args.Type;
        double amount = args.Amount;

        if (PaymentManager.Instance.IsPaymentPause())
        {
            CompleteCallBacks.Add(m_CompleteCallBack);
        }
        else
        {
            m_CompleteCallBack?.Invoke();
        }

        NDebug.Log("AdmobManager HandleRewardedAdRewarded event received for " + amount.ToString() + " " + type);
    }
    public void ExecuteReconnectPostProcess()
    {
        foreach (var completeCallBack in CompleteCallBacks)
        {
            completeCallBack?.Invoke();
            NDebug.Log("AdmobManager ExecuteReconnectPostProcess completeCallBack");
        }
        CompleteCallBacks.Clear();

        foreach (var closeCallBack in CloseCallBacks)
        {
            closeCallBack?.Invoke();
            NDebug.Log("AdmobManager ExecuteReconnectPostProcess closeCallBack");
        }
        CloseCallBacks.Clear();

        NDebug.Log("AdmobManager ExecuteReconnectPostProcess End");
    }

    public void SetCompleteCallback(Action callback)
    {
        if (m_CompleteCallBack != null)
            m_CompleteCallBack = null;

        m_CompleteCallBack = callback;

        NDebug.Log("AdmobManager SetCompleteCallback");
    }

    public void SetCompleteCallback(Action completeCallback, Action closeCallback)
    {
        if (m_CompleteCallBack != null)
            m_CompleteCallBack = null;

        m_CompleteCallBack = completeCallback;

        if (m_CloseCallBack != null)
            m_CloseCallBack = null;

        m_CloseCallBack = closeCallback;

        NDebug.Log("AdmobManager SetCompleteCallback");
    }

    public void SetCloseCallBack(Action callback)
    {
        if (m_CloseCallBack != null)
            m_CloseCallBack = null;

        m_CloseCallBack = callback;

        NDebug.Log("AdmobManager SetCloseCallBack");
    }
    
    public void SetStartCallback(Action callback)
    {
        if (m_StartCallBack != null)
            m_StartCallBack = null;

        m_StartCallBack = callback;

        NDebug.Log("AdmobManager SetStartCallback");
    }

    public bool IsLoaded()
    {
        if (rewardedAd == null || rewardedAd.IsLoaded() == false)
        {
            return false;
        }

        return true;
    }

    public void ShowTrackingMessageBox()
    {
        Alert msgBox = new Alert(NTextManager.Instance.GetText("UI_COMMON_NOTICE"), NTextManager.Instance.GetText("PERMISSION_IOS_REQUEST_DESC"));

        msgBox.SetPositiveButton(NTextManager.Instance.GetText("PERMISSION_IOS_REQUEST_BUTTON"), () =>
        {
            NAuthPlugin.GotoAppPermissionSetting();
        });

        msgBox.SetNegativeButton(NTextManager.Instance.GetText("UI_BUTTON_CLOSE"), () => { });
        msgBox.Show();
        /*
        MessageBoxDlg messageBoxDlg = UIFormManager.Instance.GetUIForm<MessageBoxDlg>();
        if (messageBoxDlg != null)
        {
            messageBoxDlg.Set(NTextManager.Instance.GetText("UI_COMMON_NOTICE"),
                              "앱 추적 권한 요청에 동의해 주셔야 이용이 가능합니다.\n 앱 설정에서 권한 허용하시기 바랍니다.",
                              "앱 설정으로 가기",
                              NAuthPlugin.GotoAppPermissionSetting,
                              NTextManager.Instance.GetText("UI_BUTTON_CLOSE")
                              );
            messageBoxDlg.Open();
        }*/
    }
}