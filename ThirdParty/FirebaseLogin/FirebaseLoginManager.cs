using Framework;
using FirebaseLogin;
using PlatformLogin;
using Firebase.Auth;
using Firebase.Extensions;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using NLibCs;
using PaperPlaneTools;
using BaseTable;

// repo : https://firebase.google.com/docs/reference/unity/namespace/firebase/auth?hl=ko
public enum eFirebaseAuthError
{
    None = 0,
    Unimplemented = -1,
    Failure = 1,
    InvalidCustomToken,
    CustomTokenMismatch,
    InvalidCredential,
    UserDisabled,
    AccountExistsWithDifferentCredentials,
    OperationNotAllowed,
    EmailAlreadyInUse,
    RequiresRecentLogin,
    CredentialAlreadyInUse,
    InvalidEmail,
    WrongPassword,
    TooManyRequests,
    UserNotFound,
    ProviderAlreadyLinked,
    NoSuchProvider,
    InvalidUserToken,
    UserTokenExpired,
    NetworkRequestFailed,
    InvalidApiKey,
    AppNotAuthorized,
    UserMismatch,
    WeakPassword,
    NoSignedInUser,                           // This error is only reported on Android.
    ApiNotAvailable,                          // This error is only reported on Android.
    ExpiredActionCode,
    InvalidActionCode,
    InvalidMessagePayload,
    InvalidPhoneNumber,
    MissingPhoneNumber,                       // This error is iOS-specific.
    InvalidRecipientEmail,
    InvalidSender,
    InvalidVerificationCode,
    InvalidVerificationId,
    MissingVerificationCode,
    MissingVerificationId,
    MissingEmail,
    MissingPassword,                          // This error is only reported on Android.
    QuotaExceeded,
    RetryPhoneAuth,                            // This error is only reported on Android.
    SessionExpired,
    AppNotVerified,                           // This error is iOS-specific.
    AppVerificationFailed,                    // This error is iOS-specific.
    CaptchaCheckFailed,                       // This error is iOS-specific.
    InvalidAppCredential,                     // This error is iOS-specific.
    MissingAppCredential,                     // This error is iOS-specific.
    InvalidClientId,                          // This error is iOS-specific.
    InvalidContinueUri,                       // This error is iOS-specific.
    MissingContinueUri,
    KeychainError,                            // This error is iOS-specific.
    MissingAppToken,                          // This error is iOS-specific.
    MissingIosBundleId,                       // This error is iOS-specific.
    NotificationNotForwarded,                 // This error is iOS-specific.
    UnauthorizedDomain,                       // This error is iOS-specific.
    WebContextAlreadyPresented,
    WebContextCancelled,
    DynamicLinkNotActivated,
    Cancelled,
    InvalidProviderId,
    WebInternalError,
    WebStorateUnsupported,
    TenantIdMismatch,
    UnsupportedTenantOperation,
    InvalidLinkDomain,
    RejectedCredential,
    PhoneNumberNotFound,
    InvalidTenantId,
    MissingClientIdentifier,
    MissingMultiFactorSession,
    MissingMultiFactorInfo,
    InvalidMultiFactorSession,
    MultiFactorInfoNotFound,
    AdminRestrictedOperation,
    UnverifiedEmail,
    SecondFactorAlreadyEnrolled,
    MaximumSecondFactorCountExceeded,
    UnsupportedFirstFactor,
    EmailChangeNeedsVerification
}

public class FirebaseLoginManager : NrTSingleton<FirebaseLoginManager>
{
    private FirebaseLogin_Base m_CurrentClass;
    private FirebaseLogin_Base m_PreviousClass;
    private Dictionary<string, FirebaseLogin_Base> m_DicLoginType = new Dictionary<string, FirebaseLogin_Base>();
    private UrgentNotice m_UrgentNoticeData = null;
    private FirebaseAuth m_Auth;
    private Action m_ReAuthCallback = null;

    public FirebaseAuth Auth { get { return m_Auth; } }
    public FirebaseUser CurrentUser
    {
        get
        {
            if (m_Auth != null) return m_Auth.CurrentUser;
            return null;
        }
    }

    private string m_CurrentLanguage = "en";

    public string IDToken { get; set; }

    public string LinkUserKey { get; set; }
    public string LinkAccountID { get; set; }
    public string LinkCurrentUserName { get; set; }
    public int LinkCurrentLv { get; set; }
    public string LinkCurrentGuildName { get; set; }
    public UInt64 LinkCurrentPortraitImageID { get; set; }
    public uint LinkCurrentServerID { get; set; }
    public bool Initialized { get; set; } = false;

    /// <summary>
    /// Initializes a new instance of the <see cref="FieldCommandCtrl"/> class.
    /// </summary>
    /// <param name="owner">The owner.</param>
    FirebaseLoginManager()
    {
    }

    public bool Initialize()
    {
        Init();
        return true;
    }

    /// <summary>
    /// 초기화 부분 각각에 위치에 버튼을 찿아서 리스트에 넣는다.
    /// 각 종류에 인디케이터 클래스를 등록
    /// </summary>
    public void Init()
    {
        if (Initialized)
            return;

        m_CurrentClass = null;
        m_PreviousClass = null;

#if !UNITY_EDITOR && FIREBASE_LOGIN
        FirebaseLoginInit();

        UnregisterClass();

        AddCommandClass<FirebaseLogin_TokenAsync>();
        AddCommandClass<FirebaseLogin_CustomUIWithEmailJoin>();
        AddCommandClass<FirebaseLogin_CustomUIWithEmailLogin>();
        AddCommandClass<FirebaseLogin_CustomUIWithManualLogin>();
        AddCommandClass<FirebaseLogin_RequestCustomToken>();
        AddCommandClass<FirebaseLogin_ResetCustomToken>();
        AddCommandClass<FirebaseLogin_CheckExistUser>();

        AddCommandClass<FirebaseLogin_CustomUIWithLinkServiceEmail>();
        AddCommandClass<FirebaseLogin_CustomUIWithLinkServices>();
        AddCommandClass<FirebaseLogin_LinkTokenAsync>();
        AddCommandClass<FirebaseLogin_SendChangePasswordMail>();
        AddCommandClass<FirebaseLogin_ChangePasswordByEmailAccount>();
        AddCommandClass<FirebaseLogin_ReAuthServices>();
        AddCommandClass<FirebaseLogin_RuntimePermission>();
#endif
        Initialized = true;
    }

    public void FirebaseLoginInit()
    {
        NDebug.Log("FirebaseLogin Init");

        m_Auth = FirebaseAuth.DefaultInstance;
        m_Auth.StateChanged += AuthStateChanged;
        m_Auth.IdTokenChanged += IdTokenChanged;

        if( Util.IsFIREBASE_LOGIN() == true )
        {
            NAuthPlugin.SetLogEnable(!Util.IsLIVE());
            NAuthPlugin.GoogleAuthInit();
            NAuthPlugin.FacebookAuthInit(true, Util.IsLIVE() == false);

            NDebug.Log("DeviceMCC: {0}", WOTPlugin.GetDeviceMCC());
            NDebug.Log("DeviceLocale: {0}", WOTPlugin.GetDeviceLocale());
            NDebug.Log("DeviceLanguage: {0}", WOTPlugin.GetDeviceLanguage());
            NDebug.Log("DeviceID: {0}", WOTPlugin.GetDeviceID());
            NDebug.Log("DeviceModel: {0}", WOTPlugin.GetDeviceModel());
            NDebug.Log("DeviceOSVersion: {0}", WOTPlugin.GetDeviceOSVersion());
            NDebug.Log("DeviceManufacturer: {0}", WOTPlugin.GetDeviceManufacturer());
            NDebug.Log("DeviceBrand: {0}", WOTPlugin.GetDeviceBrand());
            NDebug.Log("DeviceIP: {0}", WOTPlugin.GetDeviceIPAddress());
            NDebug.Log("DeviceType: {0}", WOTPlugin.GetDeviceType());
            NDebug.Log("IsRootingDevice: {0}", WOTPlugin.IsRootingDevice());
            NDebug.Log("DeviceVendor: {0}", WOTPlugin.GetDeviceVendor());
        }
    }

    // Track state changes of the auth object.
    void AuthStateChanged(object sender, EventArgs eventArgs)
    {
        FirebaseAuth senderAuth = sender as FirebaseAuth;
        FirebaseUser user = m_Auth.CurrentUser;
        if (senderAuth == m_Auth && senderAuth.CurrentUser != user)
        {
            bool signedIn = user != senderAuth.CurrentUser && senderAuth.CurrentUser != null;
            if (!signedIn && user != null)
            {
                NDebug.Log("FirebaseUser Change {0} -> {1}", user.UserId, senderAuth.CurrentUser.UserId);
            }
        }
    }

    // Track ID token changes.
    void IdTokenChanged(object sender, EventArgs eventArgs)
    {
        FirebaseAuth senderAuth = sender as FirebaseAuth;
        FirebaseUser user = m_Auth.CurrentUser;
        if (senderAuth == m_Auth && senderAuth.CurrentUser != null && senderAuth.CurrentUser == user)
        {
            user.TokenAsync(false).ContinueWithOnMainThread(task =>
            {
                if( task.IsCompleted && !task.IsCanceled && !task.IsFaulted )
                {
                    string newToken = task.Result;
                    NDebug.Log("Firebase ID Token Changed: {0} -> {1} ", IDToken, newToken);
                    IDToken = newToken;
                }                
            });
        }
    }

    public void SetNoticeData(UrgentNotice noticeData)
    {
        m_UrgentNoticeData = noticeData;
    }

    public UrgentNotice GetNoticeData()
    {
        return m_UrgentNoticeData;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="type">The type.</param>
    /// <returns></returns>
    public FirebaseLogin_Base GetCommandClass<T>()
    {
        FirebaseLogin_Base FindState = null;
        if (false == m_DicLoginType.TryGetValue(typeof(T).Name, out FindState))
        {
            return null;
        }
        return FindState;

    }
    public FirebaseLogin_Base GetCommandState()
    {
        return m_CurrentClass;
    }

    public FirebaseLogin_Base GetPreviousCommandState()
    {
        return m_PreviousClass;
    }
    public void AddCommandClass<T>() where T : new()
    {
        if (m_DicLoginType.ContainsKey(typeof(T).Name))
        {
            return;
        }

        FirebaseLogin_Base newClass = new T() as FirebaseLogin_Base;
        m_DicLoginType.Add(typeof(T).Name, newClass);
    }

    /// <summary>
    /// Executes the specified new type.
    /// </summary>
    /// <param name="NewType">The new type.</param>
    /// <param name="array">The array.</param>
    public IEnumerator ExecuteCO<T>(IParameter arg = null)
    {
        FirebaseLogin_Base FindClass = GetCommandClass<T>();
        if (FindClass != null)
        {
            m_PreviousClass = m_CurrentClass;
            m_CurrentClass = FindClass;

            NDebug.Log((typeof(T).Name) + " ExecuteCO");

            yield return m_CurrentClass.ExecuteCO(arg);
        }
        else
        {
            NDebug.Log("FirebaseLoginManager Class Find Not Found = ", (typeof(T).Name));
            yield return null;
        }
    }
    public void Execute<T>(IParameter arg = null)
    {
        FirebaseLogin_Base FindClass = GetCommandClass<T>();
        if (FindClass != null)
        {
            m_PreviousClass = m_CurrentClass;
            m_CurrentClass = FindClass;

            NDebug.Log((typeof(T).Name) + " Execute");

            m_CurrentClass.Execute(arg);
        }
        else
        {
            NDebug.Log("FirebaseLoginManager Class Find Not Found = ", (typeof(T).Name));
        }
    }

    public void UnregisterClass()
    {
        foreach (KeyValuePair<string, FirebaseLogin_Base> type in m_DicLoginType)
        {
            type.Value.OnEnd();
        }
        m_DicLoginType.Clear();
    }

    /// <summary>
    /// Mobile Country Code (현재 사용중인 통신 사업자 국가 코드)
    /// ex) 한국일경우 : 450
    /// Wiki : https://en.wikipedia.org/wiki/Mobile_country_code
    /// </summary>
    /// <returns></returns>
    public string GetMCC()
    {
        string mcc = WOTPlugin.GetDeviceMCC();
        NDebug.Log("MCC: {0}", mcc);
        return mcc; 
    }

    public string GetLocale()
    {
        string locale = WOTPlugin.GetDeviceLocale();
        NDebug.Log("Locale: {0}", locale);
        return locale;
    }

    /// <summary>
    /// Device System Language
    /// 설정된 언어의 코드값
    /// ex)Korean – “ko”, English – “en”
    /// </summary>
    /// <returns></returns>
    public string GetCurrentLanguage()
    {
        return m_CurrentLanguage;
    }

    /// <summary>
    /// Unique Device ID
    /// </summary>
    /// <returns>
    /// iOS : [[UIDevice currentDevice].identifierForVendor UUIDString] or CFUUID 
    ///       iOS : 내부적으로 keyChain으로 저장되는 값으로, Device를 Factory Reset (공장 초기화) 되지 않는 이상 유지되는 값
    /// Android : IEME or ANDROID_ID + serialNumber or MacAddress
    /// </returns>
    public string GetDeviceId()
    {
        return WOTPlugin.GetDeviceID();
    }

    /// <summary>
    /// Device Model 정보
    /// </summary>
    /// <returns>
    /// iOS  [[UIDevice currentDevice] model]
    /// ex) iPhone , Ipad , iPad
    /// 
    /// Android
    /// Build.MODEL
    /// ex) SHW-M250S /// </returns>
    public string GetDeviceModel()
    {
        return WOTPlugin.GetDeviceModel();
    }

    public string GetDeviceOSVersion()
    {
        return WOTPlugin.GetDeviceOSVersion();
    }

    /// <summary>
    /// Device 광고 ID
    /// </summary>
    /// <returns>
    /// iOS IDFA
    /// AOS GoogleADID
    /// </returns>
    public string GetDeviceADID()
    {
        if (Util.IsIOS())
            return NAuthPlugin.GetIDFA();
        return NAuthPlugin.GetGoogleADID();
    }

    /// <summary>
    /// Sets the game language.
    /// </summary>
    /// <param name="languageType">Type of the language.</param>
    public void SetGameLanguage(eLANGUAGE_CODE type)
    {
        string lanType = "en";
        switch (type)
        {
            case eLANGUAGE_CODE.NONE: lanType = "en"; break;
            case eLANGUAGE_CODE.KOR: lanType = "ko"; break;
            case eLANGUAGE_CODE.ENG: lanType = "en"; break;
            case eLANGUAGE_CODE.ZHO: lanType = "zh"; break;
            case eLANGUAGE_CODE.JPN: lanType = "ja"; break;
            case eLANGUAGE_CODE.NAN: lanType = "zt"; break;
            case eLANGUAGE_CODE.GER: lanType = "de"; break;
            case eLANGUAGE_CODE.FRA:
            case eLANGUAGE_CODE.IND:
            case eLANGUAGE_CODE.SPA:
            case eLANGUAGE_CODE.POR:
            case eLANGUAGE_CODE.THA:
            case eLANGUAGE_CODE.ITA:
            case eLANGUAGE_CODE.TUR:
            case eLANGUAGE_CODE.VIE:
            //case eLANGUAGE_CODE.ARA:
            case eLANGUAGE_CODE.RUS: lanType = "en"; break;
        }

        NDebug.Log("FirebaseLoginManager Language = :" + lanType);
        m_CurrentLanguage = lanType;
    }

    public string GetCSLanguage(eLANGUAGE_CODE type)
    {
        string lanType = "en";
        switch (type)
        {
            case eLANGUAGE_CODE.NONE: lanType = "en"; break;
            case eLANGUAGE_CODE.KOR: lanType = "ko"; break;
            case eLANGUAGE_CODE.ENG: lanType = "en"; break;
            case eLANGUAGE_CODE.ZHO: lanType = "zh-ch"; break;
            case eLANGUAGE_CODE.JPN: lanType = "ja"; break;
            case eLANGUAGE_CODE.NAN: lanType = "zh-tw"; break;
            case eLANGUAGE_CODE.GER:
            case eLANGUAGE_CODE.FRA:
            case eLANGUAGE_CODE.IND:
            case eLANGUAGE_CODE.SPA:
            case eLANGUAGE_CODE.POR:
            case eLANGUAGE_CODE.THA:
            case eLANGUAGE_CODE.ITA:
            case eLANGUAGE_CODE.TUR:
            case eLANGUAGE_CODE.VIE:
            //case eLANGUAGE_CODE.ARA:
            case eLANGUAGE_CODE.RUS: lanType = "en"; break;
        }

        return lanType;
    }

    public void SetSystemLanuage()
    {
        string lanType = "en";
        switch (Application.systemLanguage)
        {
            case SystemLanguage.Afrikaans: break;
            case SystemLanguage.Arabic: break;
            case SystemLanguage.Basque: break;
            case SystemLanguage.Belarusian: break;
            case SystemLanguage.Bulgarian: break;
            case SystemLanguage.Catalan: break;
            case SystemLanguage.Chinese: lanType = "zh"; break;
            case SystemLanguage.Czech: break;
            case SystemLanguage.Danish: break;
            case SystemLanguage.Dutch: break;
            case SystemLanguage.English: lanType = "en"; break;
            case SystemLanguage.Estonian: break;
            case SystemLanguage.Faroese: break;
            case SystemLanguage.Finnish: break;
            case SystemLanguage.French: break;
            case SystemLanguage.German: lanType = "de"; break;
            case SystemLanguage.Greek: break;
            case SystemLanguage.Hebrew: break;
            case SystemLanguage.Hungarian: break;
            //case SystemLanguage.Hugarian: break;
            case SystemLanguage.Icelandic: break;
            case SystemLanguage.Indonesian: break;
            case SystemLanguage.Italian: break;
            case SystemLanguage.Japanese: lanType = "ja"; break;
            case SystemLanguage.Korean: lanType = "ko"; break;
            case SystemLanguage.Latvian: break;
            case SystemLanguage.Lithuanian: break;
            case SystemLanguage.Norwegian: break;
            case SystemLanguage.Polish: break;
            case SystemLanguage.Portuguese: break;
            case SystemLanguage.Romanian: break;
            case SystemLanguage.Russian: break;
            case SystemLanguage.SerboCroatian: break;
            case SystemLanguage.Slovak: break;
            case SystemLanguage.Slovenian: break;
            case SystemLanguage.Spanish: break;
            case SystemLanguage.Swedish: break;
            case SystemLanguage.Thai: break;
            case SystemLanguage.Turkish: break;
            case SystemLanguage.Ukrainian: break;
            case SystemLanguage.Vietnamese: break;
            case SystemLanguage.Unknown: break;
        }

        NDebug.Log("FirebaseLoginManager Language = :" + lanType);
        m_CurrentLanguage = lanType;
    }

    /// <summary>
    /// 로그인 여부를 나타내는 Session 상태가 Open 인지 확인
    /// </summary>
    /// <returns>
    ///   <c>true</c> if this instance is opened; otherwise, <c>false</c>.
    /// </returns>
    public bool IsLoggedIn()
    {
        return CurrentUser != null;
    }

    /// <summary>
    /// Joyple RefreshToken
    /// </summary>
    /// <returns></returns>
    public string GetIDToken()
    {
        return IDToken;
    }

    /// <summary>
    /// 이전 로그인 타입이 게스트 유저인지 확인
    /// </summary>
    /// <returns>
    /// 게스트 유저였다면 true, 아니라면 false
    /// </returns>
    public bool IsGuestUser()
    {
        if (CurrentUser == null)
            return false;

        // prividerData가 1개이고 ProviderId가 firebase이면 게스트유저이다.
        var providerDataList = new List<IUserInfo>(CurrentUser.ProviderData);
        if( providerDataList.Count == 1 && providerDataList[0].ProviderId.Equals("firebase"))
        {
            return true;
        }
        return false;
        //return CurrentUser != null && CurrentUser.IsAnonymous == true;
    }

    /// <summary>
    /// Joyple 로그인 여부 <분석후 추가 코멘트 작성>
    /// </summary>
    /// <returns>
    /// App 설치 이후에 로그인을 한번이라도 했다면 항상 true
    /// App 삭제시 초기화
    /// </returns>
    public bool IsAlreadyLogin()
    {
        bool bRet = false;
#if UNITY_EDITOR
#else
        // 로컬에 유저 정보가 있는데
        if ( CurrentUser != null )
        {
            // 마지막 접속 방법이 없다면 로그아웃 시킨다.
            if( GetLastLoginAuthType() == eAuthType.NONE)
            {
                m_Auth.SignOut();
            }
            else
            {
                bRet = true;
            }
        }
#endif
        return bRet;
    }

    public void SaveLastLoginAuthType(eAuthType eAuth)
    {
        PlayerPrefs.SetInt("LastLoginType", (int)eAuth);
        if ( CurrentUser != null && (eAuth == eAuthType.EMAIL || eAuth == eAuthType.JOIN))
        {
            PlayerPrefs.SetString("LastLoginEmail", CurrentUser.Email);
        }
        PlayerPrefs.Save();
    }

    public eAuthType GetLastLoginAuthType()
    {
        return (eAuthType)PlayerPrefs.GetInt("LastLoginType", (int)eAuthType.NONE);
    }
    
    public string GetUseLoginEmail()
    {
        return PlayerPrefs.GetString("LastLoginEmail", "");
    }

    /// <summary>
    /// Android : PGS
    /// iOS : Game Center
    /// 연동 여부 확인
    /// </summary>
    /// <returns>
    ///   true : 연결됨
    ///   false : 연결되지 않음
    /// </returns>
    public bool IsAuthenticated()
    {
        return NAuthPlugin.IsSignedInGooglePlayGame();
    }

    /// <summary>
    /// 해당 권한이 허가여부(단일)
    /// </summary>
    /// <ex:Manifest.permission.READ_PHONE_STATE 또는 READ_PHONE_STATE
    /// <returns>
    ///   true : 해당권한이 이미 허가됨
    ///   false : 해당 권한이 허가되지 않음
    /// </returns>
    public bool IsPermissionGranted(string permission)
    {
        return NAuthPlugin.IsPermissionGranted(permission);
    }

    /// <summary>
    /// 해당 권한이 이전에 유저가 거부되었는지 여부
    /// </summary>
    /// ex:Manifest.permission.READ_PHONE_STATE 또는 READ_PHONE_STATE
    /// <returns></returns>
    public bool ShouldShowRequestPermissionRationale(string permission)
    {
        return NAuthPlugin.ShouldShowRequestPermissionRationale(permission);
    }

    /// <summary>
    /// 조이풀 UserKey를 반환한다. 카카오 버전이면 카카오 회원ID를 반환한다.
    /// </summary>
    /// <returns>유저ID</returns>
    public string GetUserID()
    {
        if( CurrentUser != null )
        {
            return CurrentUser.UserId.ToString();
        }

        return string.Empty;
    }

    /// <summary>
    /// 각 플랫폼에 맞는 고객센터 웹뷰를 오픈한다.
    /// </summary>
    public void OpenCSView(bool bHaveUserInfo)
    {
        string link = TableLanguageInfo.Instance.MakeOqupieCSLink(Language.Instance.GetLanguage(), false);

        if( string.IsNullOrEmpty(link) == false )
        {
            string userID = bHaveUserInfo ? User.Instance.UID.ToString() : ""; // 고객ID를 설정합니다. (선택 사항)
            string userName = bHaveUserInfo ? User.Instance.LORD.GetName() : ""; // 고객명을 설정합니다. (선택 사항)

            if (string.IsNullOrEmpty(userName) == false && string.IsNullOrEmpty(userID))
                link += string.Format("&userId={0}&userName={1}", userID, userName);
            NDebug.LogError("OpenCSView URL: {0}", link);
            WOTPlugin.ShowWebView(link, NTextManager.Instance.GetText("UI_CUSTOMER_SERVICE_CENTER"));
        }
        else
        {
            NDebug.LogError("OQUPIE DATA IS NULL: {0}", Language.Instance.GetLanguage());
        }
    }

    /// <summary>
    /// 각 플랫폼에 맞는 공지사항 웹뷰를 오픈한다. 
    /// </summary>
    public void OpenNoticeView()
    {
        WOTPlugin.ShowWebView(SocialManager.Instance.GetCustomerServiceCenterLinkUrl());
    }

    public void SetDontAskOptionalPermissionDenied(string permissionName, bool bValue)
    {
        NAuthPlugin.SetDontAskOptionalPermissionDenied(permissionName, bValue);
    }

    public bool IsDontAskOptionalPermissionDenied(string permissionName)
    {
        return NAuthPlugin.IsDontAskOptionPermissionDenied(permissionName);
    }

    public void ShowPermissionSetting(string permissionName, Action onSuccessed = null, Action onFailed = null)
    {
        //Execute<Joyple_RequestShowApplicationDetailSetting>(new ApplicationDetailSettingParameter(permissionName, onSuccessed, onFailed));
    }

    public void ShowMessageBoxDontAskOptionalPermissionDenied(string permissionName, string title, string msg, bool bGotoPermission, Action onSuccessed = null, Action onFailed = null)
    {
        //MessageBox.Show(title, msg,
        //    (resulMsg) =>
        //    {
        //        if (resulMsg.result == MessageBoxDefine.RESULT_OK)
        //        {
        //            if (bGotoPermission == true)
        //            {
        //                ShowPermissionSetting(permissionName, onSuccessed, onFailed);
        //            }
        //            else
        //            {
        //                onSuccessed?.Invoke();
        //            }
        //        }
        //        else if (resulMsg.result == MessageBoxDefine.RESULT_NO)
        //        {
        //                onFailed?.Invoke();
        //        }
        //    },
        //    global::Util.Text("COMMON_UI_BUTTON_OK"),
        //    global::Util.Text("COMMON_UI_BUTTON_CANCEL"));
    }
    /// <summary>
    /// 각 플랫폼에 맞는 커뮤니티 웹뷰를 오픈한다.
    /// </summary>
    public void OpenCommunityView()
    {
        //string zendeskUrl = GD_Language.Ref.GetCommunityUrl(GnUser.Me.m_kBaseInfo.m_nLanguageKind);
        //PublicMethod.OpenUrl(zendeskUrl);
    }

    /// <summary>
    /// Resources 폴더에 읽기 권한이 존재하지 않을 수 있다.
    /// </summary>
    public IEnumerator CheckFileAccess()
    {
        if (Util.IsFIREBASE_LOGIN() == true && Util.IsANDROID() == true)
        {
            int obbFileAccess = PlayerPrefs.GetInt("ObbFileAccess", 0);
            if (obbFileAccess == 0 && TryFileAccess() == false)
            {
                //ogg 파일 접근 실패시 권한 요청...
                yield return ExecuteCO<FirebaseLogin_RuntimePermission>(new PermissionParameter("WRITE_EXTERNAL_STORAGE"));
            }

            // 권한이 있는데도 파일을 찾지 못하면 OBB파일이 없거나 문제가 있는것이다.
            if( TryFileAccess() == false )
            {
                Alert msgBox = new Alert(NTextManager.Instance.GetText("UI_COMMON_NOTICE"), "Installed game files are corrupted.\nPlease reinstall the game.");

                msgBox.SetPositiveButton(NTextManager.Instance.GetText("UI_COMMON_CONFIRM_CLOSE"), () =>
                {
                    Application.Quit();
                });

                msgBox.AddOptions(new AlertIOSOptions()
                {
                    NegativeButton = AlertIOSButton.Type.Destructive,
                    PreferableButton = Alert.ButtonType.Positive
                });

                msgBox.AddOptions(new AlertAndroidOptions()
                {
                    Cancelable = false
                });

                msgBox.Show();
            }
            else
            {
                if (obbFileAccess == 0)
                {
                    PlayerPrefs.SetInt("ObbFileAccess", 1);
                    PlayerPrefs.Save();
                }
            }
        }
    }

    bool TryFileAccess()
    {
        UnityEngine.GameObject go = UnityEngine.Resources.Load("check_file_access") as UnityEngine.GameObject;
        if (go == null)
        {
            return false;
        }
        return true;
    }

    public bool HasAccessToken()
    {
        return IDToken != null && IDToken != "";
    }

    public void PlatformLogout( eAuthType eAuth = eAuthType.NONE )
    {
        if( eAuth == eAuthType.NONE )
        {
            NAuthPlugin.GoogleSignOut(null);
            NAuthPlugin.FacebookSignOut(null);
        }
        else
        {
            if (eAuth == eAuthType.GOOGLE) NAuthPlugin.GoogleSignOut(null);
            else if (eAuth == eAuthType.FACEBOOK) NAuthPlugin.FacebookSignOut(null);
        }
    }

    public void Logout()
    {
        PlatformTrackerManager.Instance.TrackerEventGamePlayEnd();
        PlatformTrackerManager.Instance.TrackerEventLogout();

        if (IsAuthenticated() == true) NAuthPlugin.GooglePlayGameSignOut(null);
        PlatformLogout();
        Auth.SignOut();

        NDebug.Log("Firebase_Logout Success");
        // 로그 아웃 성공
        SocialManager.Instance.SaveLogoutFlag();
        PlatformLoginManager.Instance.SaveLastLoginAuthType(eAuthType.NONE);        
    }

    public bool IsLinkService(eAuthType eAuth)
    {
        string id = GetLinkServiceID(eAuth);
        return id != "";
    }

    public string GetLinkServiceID(eAuthType eAuth)
    {
        List<string> strServerNameList = new List<string>();

        switch (eAuth)
        {
            case eAuthType.EMAIL: strServerNameList.Add("password"); break;
            case eAuthType.FACEBOOK: strServerNameList.Add("facebook"); break;
            case eAuthType.GOOGLE: strServerNameList.Add("google"); break;
            case eAuthType.APPLE: strServerNameList.Add("apple"); break;
        }

        if (CurrentUser != null && strServerNameList.Count > 0)
        {
            var providerDataList = new List<IUserInfo>(CurrentUser.ProviderData);
            var numberOfProviders = providerDataList.Count;
            if(numberOfProviders > 0)
            {
                for (int i = 0; i < numberOfProviders; ++i)
                {
                    foreach (string name in strServerNameList)
                    {
                        if (providerDataList[i].ProviderId.Contains(name))
                        {
                            return providerDataList[i].UserId.ToString();
                        }
                    }
                }
            }
        }

        return "";
    }

    public bool IsEmailCert()
    {
        FirebaseUser user = CurrentUser;
        if( user != null )
        {
            return user.IsEmailVerified;
        }
        return false;
    }

    public void AuthRestartGame()
    {
        Logout();
        PublicMethod.RestartGame();
    }

    public void NativePlatformLogin(eAuthType eAuth, bool bSilently, bool bIsLink = false)
    {
        if( eAuth == eAuthType.GOOGLE )
        {
            if (bIsLink == false)
            {
                NAuthPlugin.GoogleSignIn(bSilently, NativeLoginCallback);
            }
            else
            {
                NAuthPlugin.GoogleSignIn(bSilently, NativeLinkCallback);
            }
        }
        else if( eAuth == eAuthType.FACEBOOK )
        {
            if (bIsLink == false)
            {
                NAuthPlugin.FacebookSignIn(bSilently, NativeLoginCallback);
            }
            else
            {
                NAuthPlugin.FacebookSignIn(bSilently, NativeLinkCallback);
            }
        }
        else if( eAuth == eAuthType.APPLE )
        {
            if (Util.IsANDROID())
            {
                if (bIsLink == false)
                {
                    Execute<FirebaseLogin_CustomUIWithManualLogin>(new ManualLoginParameter(eAuth, "", ""));
                }
                else
                {
                    Execute<FirebaseLogin_CustomUIWithLinkServices>(new ManualLoginParameter(eAuth, "", ""));
                }
            }
            else
            {
                if (bIsLink == false)
                {
                    NAuthPlugin.AppleSignIn(NativeLoginCallback);
                }
                else
                {
                    NAuthPlugin.AppleSignIn(NativeLinkCallback);
                }
            }
        }
        else if( eAuth == eAuthType.GUEST && bIsLink == false)
        {
            Execute<FirebaseLogin_RequestCustomToken>();
        }
    }

    public void NativePlatformReAuth(eAuthType eAuth)
    {
        if (eAuth == eAuthType.GOOGLE)
        {
            NAuthPlugin.GoogleSignIn(true, NativeReLoginCallback);
        }
        else if (eAuth == eAuthType.FACEBOOK)
        {
            NAuthPlugin.FacebookSignIn(true, NativeReLoginCallback);
        }
        else if( eAuth == eAuthType.APPLE )
        {
            if (Util.IsANDROID())
            {
                Execute<FirebaseLogin_ReAuthServices>(new ReAuthParameter(eAuth, "", ""));
            }
            else
            {
                NAuthPlugin.AppleSignIn(NativeReLoginCallback);
            }
        }
    }

    public void PGSLogin()
    {
        NAuthPlugin.GooglePlayGameSignIn(NativePGSCallback);
        
    }

    public void PGSLogout()
    {
        NAuthPlugin.GooglePlayGameSignOut(NativePGSCallback);
    }

    public void NativeLoginCallback(string jsonString)
    {
        if(jsonString != null )
        {
            JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
            if (info.method == "")
            {
                NDebug.LogError("FirebaseLoginManager: NativeLoginCallback: jsonString is Null");
                PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "jsonString is Null");
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);
                return;
            }
                

            if( info.error == 0 )
            {
                if (info.method == "SIGN_IN")
                {
                    eAuthType auth = eAuthType.GUEST;

                    if (info.platform == "GOOGLE") auth = eAuthType.GOOGLE;
                    else if (info.platform == "FACEBOOK") auth = eAuthType.FACEBOOK;
                    else if (info.platform == "APPLE") auth = eAuthType.APPLE;
                    else
                    {
                        NDebug.LogError("FirebaseLoginManager: NativeLoginCallback: SIGN_IN is Unknown Auth type");
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "SIGN_IN is Unknown Auth type");
                        PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);
                        return;
                    }
                    Execute<FirebaseLogin_CustomUIWithManualLogin>(new ManualLoginParameter(auth, info.idtoken, info.accesstoken));
                }
            }
            else
            {
                NDebug.LogError("FirebaseLoginManager: NativeLoginCallback Error | {0}_Auth_{1} - ErrorMsg: {2}", info.platform, info.method, info.errormsg);
                if ( info.errormsg.Contains("12501") == false && info.errormsg.ToLower().Contains("cancel") == false )
                {
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, info.errormsg);
                }
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);
            }
        }
    }

    public void NativeReLoginCallback(string jsonString)
    {
        if (jsonString != null)
        {
            JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
            if (info.method == "")
            {
                NDebug.LogError("FirebaseLoginManager: NativeReLoginCallback: jsonString is Null");
                PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "jsonString is Null");
                return;
            }


            if (info.error == 0)
            {
                if (info.method == "SIGN_IN")
                {
                    eAuthType auth = eAuthType.GUEST;

                    if (info.platform == "GOOGLE") auth = eAuthType.GOOGLE;
                    else if (info.platform == "FACEBOOK") auth = eAuthType.FACEBOOK;
                    else if (info.platform == "APPLE") auth = eAuthType.APPLE;
                    else
                    {
                        NDebug.LogError("FirebaseLoginManager: NativeReLoginCallback: SIGN_IN is Unknown Auth type");
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "SIGN_IN is Unknown Auth type");
                        return;
                    }
                    Execute<FirebaseLogin_ReAuthServices>(new ReAuthParameter(auth, info.idtoken, info.accesstoken));
                }
            }
            else
            {
                NDebug.LogError("FirebaseLoginManager: NativeReLoginCallback Error | {0}_Auth_{1} - ErrorMsg: {2}", info.platform, info.method, info.errormsg);
                if (info.errormsg.Contains("12501") == false && info.errormsg.ToLower().Contains("cancel") == false)
                {
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, info.errormsg);
                }
            }
        }
    }

    public void NativeLinkCallback(string jsonString)
    {
        if (jsonString != null)
        {
            JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
            if (info.method == "")
            {
                PublicUIMethod.ShowLoadingSpin(false);
                return;
            }
                

            if (info.error == 0)
            {
                if (info.method == "SIGN_IN")
                {
                    eAuthType auth = eAuthType.GUEST;

                    if (info.platform == "GOOGLE") auth = eAuthType.GOOGLE;
                    else if (info.platform == "FACEBOOK") auth = eAuthType.FACEBOOK;
                    else if (info.platform == "APPLE") auth = eAuthType.APPLE;
                    else
                    {
                        NDebug.LogError("FirebaseLoginManager: NativeLinkCallback: SIGN_IN is Unknown Auth type");
                        return;
                    }
                    Execute<FirebaseLogin_CustomUIWithLinkServices>(new ManualLoginParameter(auth, info.idtoken, info.accesstoken));
                }
            }
            else
            {
                NDebug.LogError("FirebaseLoginManager: NativeLinkCallback Error | {0}_Auth_{1} - ErrorMsg: {2}", info.platform, info.method, info.errormsg);
                if (info.errormsg.Contains("12501") == false && info.errormsg.ToLower().Contains("cancel") == false)
                {
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, info.errormsg);
                }
                PublicUIMethod.ShowLoadingSpin(false);
            }
        }
    }

    public void NativePGSCallback(string jsonString)
    {
        if (jsonString != null)
        {
            JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
            if (info.method == "")
            {
                NDebug.LogError("FirebaseLoginManager: NativePGSCallback: jsonString is Null");
                PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "jsonString is Null");
                return;
            }

            bool bChangePlayerPrefs = false;

            if (info.error == 0)
            {
                if (info.method == "SIGN_IN")
                {
                    PlayerPrefs.SetInt("PGSLogin_denied", 0);
                    bChangePlayerPrefs = true;
                    CheckGPGAchievement();
                }
                else if ( info.method == "SIGN_OUT")
                {
                    PlayerPrefs.SetInt("PGSLogin_denied", 1);
                    bChangePlayerPrefs = true;
                    PopUpAlarmDlg popupAlramDlg = UIFormManager.Instance.OpenUIForm<PopUpAlarmDlg>();
                    popupAlramDlg.SetForce(NTextManager.Instance.GetText("UI_OPTION_GAMECENTER_LOGOUT"));
                }
            }
            else
            {
                NDebug.LogError("FirebaseLoginManager: NativePGSCallback Error | {0}_Auth_{1} - ErrorMsg: {2}", info.platform, info.method, info.errormsg);
                //PopUpAlarmDlg popupAlramDlg = UIFormManager.Instance.OpenUIForm<PopUpAlarmDlg>();
                //popupAlramDlg.SetForce(NTextManager.Instance.GetText("ERROR_PROBLEM_SERVICE"));

                if (info.method == "SIGN_IN")
                {
                    PlayerPrefs.SetInt("PGSLogin_denied", 1);
                    bChangePlayerPrefs = true;
                }
            }

            if (bChangePlayerPrefs)
                PlayerPrefs.Save();            
        }
    }

    public void NativePermissionCallback(string jsonString)
    {
        if (jsonString != null)
        {
            JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
            if (info.method == "")
            {
                NDebug.LogError("FirebaseLoginManager: NativePGSCallback: jsonString is Null");
                PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "jsonString is Null");
                return;
            }


            if (info.error == 0)
            {
                NDebug.Log("{0} permission is Gradted", info.method);
            }
            else
            {
                NDebug.LogError("{0} permission is not Gradted", info.method);

                // 요청이 실패한 상태에서 ShouldShowRequestPermissionRationale이 False이면 다시 묻지 않기를 체크하고 거부한 상태로 판단한다.
                if ( NAuthPlugin.ShouldShowRequestPermissionRationale(info.method) == false )
                {
                    NAuthPlugin.SetDontAskOptionalPermissionDenied(info.method, true);
                }                
            }
            PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);
        }
    }

    public void ShowWebView(string strUrl)
    {
        WOTPlugin.ShowWebView(strUrl);
    }

    public bool IsFirstOpen()
    {
        return PlayerPrefs.GetInt("FirstAppOpen", 1) == 1;
    }

    public void SetIsFirstOpen(bool bValue)
    {
        if( IsFirstOpen() != bValue )
        {
            PlayerPrefs.SetInt("FirstAppOpen", bValue == true ? 1 : 0);
            PlayerPrefs.Save();
        }
    }

    public long GetLastReAuthTIme()
    {
        string strTIme = PlayerPrefs.GetString("LastReAuthTime", "0");
        long ret = 0;
        long.TryParse(strTIme, out ret);
        NDebug.Log("GetLastReAuthTIme: {0}", ret);
        return ret;
    }

    public void SaveLastReAuthTimeByCurrentTime()
    {
        long nCurrentUTCTime = (long)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;
        NDebug.Log("SetLastReAuthTimeByCurrentTime: {0}", nCurrentUTCTime);
        PlayerPrefs.SetString("LastReAuthTime", string.Format("{0}", nCurrentUTCTime));
        PlayerPrefs.Save();
    }

    public bool IsNeedReAuth()
    {
        if(CurrentUser != null)
        {
            long nLastTimeStamp = (long)(CurrentUser.Metadata.LastSignInTimestamp / 1000L);
            long nCurrentUTCTime = (long)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalSeconds;
            long nRemainTime = nCurrentUTCTime - nLastTimeStamp;

            NDebug.Log("IsNeedReAuth: LastSignInTimestamp: {0}, FixTimeStamp: {1}, CurrentTime: {2}, RemainTime: {3}", CurrentUser.Metadata.LastSignInTimestamp, nLastTimeStamp, nCurrentUTCTime, nRemainTime);
            if( nRemainTime >= 3500 )
            {
                nRemainTime = nCurrentUTCTime - GetLastReAuthTIme();
                if (nRemainTime > 300)
                    return true;
            }
            return false;
        }
        NDebug.Log("IsNeedReAuth: CurrentUser is Null!");
        return true;
    }

    public bool IsNeedPlatformReauth()
    {
        eAuthType eAuthType = GetLastLoginAuthType();

        if( eAuthType == eAuthType.GUEST )
        {
            return false;
        }
        else if (eAuthType == eAuthType.GOOGLE || eAuthType == eAuthType.FACEBOOK)
        {
            string idToken = NAuthPlugin.GetPlatformIDToken((int)eAuthType);
            string accessToken = NAuthPlugin.GetPlatformAccessToken((int)eAuthType);
            NDebug.Log("IsNeedPlatformReauth: {0} - IDToken: {1}, AccessToken: {2}", eAuthType.ToString(), idToken, accessToken);
            if (idToken.Equals("") == false)
            {
                return false;
            }
        }
        return true;
    }

    public void ReAuth(Action Callback)
    {
        eAuthType eAuthType = GetLastLoginAuthType();
        m_ReAuthCallback = Callback;

        if (eAuthType == eAuthType.GOOGLE || eAuthType == eAuthType.FACEBOOK )
        {
            string idToken = NAuthPlugin.GetPlatformIDToken((int)eAuthType);
            string accessToken = NAuthPlugin.GetPlatformAccessToken((int)eAuthType);
            NDebug.Log("ReAuth: Check PlatformToken: {0} - IDToken: {1}, AccessToken: {2}", eAuthType.ToString(), idToken, accessToken);
            if ( idToken.Equals("") == false )
            {
                Execute<FirebaseLogin_ReAuthServices>(new ReAuthParameter(eAuthType, idToken, accessToken));
            }
            else
            {
                NativePlatformReAuth(eAuthType);
            }
        }
        else if( eAuthType == eAuthType.APPLE )
        {
            NativePlatformReAuth(eAuthType);
        }
        else if (eAuthType == eAuthType.GUEST )
        {
            Execute<FirebaseLogin_RequestCustomToken>(new RequestTokenParameter(true));
        }
    }

    public void PlayReAuthCallback()
    {
        if( m_ReAuthCallback != null )
        {
            m_ReAuthCallback();
            m_ReAuthCallback = null;
        }
    }

    public bool IsAgreeTerms()
    {
        if( CurrentUser != null )
        {
            string key = string.Format("AgreeTerms_{0}", CurrentUser.UserId.ToString());
            if (PlayerPrefs.GetInt(key, 0) == 1)
                return true;
        }
        return false;
    }

    public void SaveAgreeTerms(bool IsEnableNightPush)
    {
        if (CurrentUser != null)
        {
            string key = string.Format("AgreeTerms_{0}", CurrentUser.UserId.ToString());
            string nightPushkey = string.Format("AgreeNightPush_{0}", CurrentUser.UserId.ToString());
            PlayerPrefs.SetInt(key, 1);
            PlayerPrefs.SetInt(nightPushkey, IsEnableNightPush ? 1 : 2);
            PlayerPrefs.Save();
        }
    }

    public int GetNightPushValue()
    {
        if (CurrentUser != null)
        {
            string key = string.Format("AgreeNightPush_{0}", CurrentUser.UserId.ToString());
            return PlayerPrefs.GetInt(key, 0);
        }
        return 0;
    }

    public void DelNightPushValue()
    {
        if (CurrentUser != null)
        {
            string key = string.Format("AgreeNightPush_{0}", CurrentUser.UserId.ToString());
            PlayerPrefs.DeleteKey(key);
        }
    }

    public void EnableADPush( bool bEnable)
    {
        if( CurrentUser != null )
        {
            Firebase.Analytics.FirebaseAnalytics.SetUserProperty("EnableADPush", bEnable ? "1" : "0");
            WOTPushPlugin.OneSignalSetTag("EnableADPush", bEnable ? "1" : "0");
            NDebug.Log("EnableADPush: {0}", bEnable);
        }
    }

    public void EnableNightPush( bool bEnable )
    {
        if (CurrentUser != null)
        {
            Firebase.Analytics.FirebaseAnalytics.SetUserProperty("EnableNightPush", bEnable ? "1" : "0");
            WOTPushPlugin.OneSignalSetTag("EnableNightPush", bEnable ? "1" : "0");
            NDebug.Log("EnableNightPush: {0}", bEnable);
        }
    }

    public void SetPushExternalID( string SN )
    {
        if (CurrentUser != null)
        {
            Firebase.Analytics.FirebaseAnalytics.SetUserId(SN.ToString());
            WOTPushPlugin.OneSignalSetExternalID(SN.ToString());
            NDebug.Log("SetPushExternalID: {0}", SN.ToString());
        }
    }

    public void SetPushTargetServer( string strServer )
    {
        if (CurrentUser != null)
        {
            Firebase.Analytics.FirebaseAnalytics.SetUserProperty("TargetServer", strServer);
            WOTPushPlugin.OneSignalSetTag("TargetServer", strServer);
            NDebug.Log("SetPushTargetServer: {0}", strServer);
        }
    }

    public void SetUserIDByPushSDK( Int64 nUID)
    {
        if (CurrentUser != null)
        {
            Firebase.Analytics.FirebaseAnalytics.SetUserProperty("UID", nUID.ToString());
            WOTPushPlugin.OneSignalSetTag("UID", nUID.ToString());
            NDebug.Log("SetUIDByPush: {0}", nUID);

            Firebase.Analytics.FirebaseAnalytics.SetUserProperty("Market", WOTSettings.TRACKER_MARKET.ToString());
            WOTPushPlugin.OneSignalSetTag("Market", WOTSettings.TRACKER_MARKET.ToString());
        }
    }

    public void ShowCSInquiry()
    {
        string link = TableLanguageInfo.Instance.MakeOqupieCSLink(Language.Instance.GetLanguage(), true);

        if (string.IsNullOrEmpty(link) == false)
        {
            link += string.Format("&userId={0}&userName={1}", User.Instance.UID.ToString(), User.Instance.LORD.GetName());
            NDebug.LogError("ShowCSInquiry URL: {0}", link);
            WOTPlugin.ShowWebView(link, NTextManager.Instance.GetText("UI_CUSTOMER_SERVICE_CENTER"));
        }
        else
        {
            NDebug.LogError("OQUPIE DATA IS NULL: {0}", Language.Instance.GetLanguage());
        }
    }

    public void ShowLogUserInfo()
    {
        NDebug.Log("======================================================================================");
        NDebug.Log("FirebaseUserInfo UserID : {0}", CurrentUser.UserId.ToString());
        NDebug.Log("FirebaseUserInfo ProviderId : {0}", CurrentUser.ProviderId.ToString());
        NDebug.Log("FirebaseUserInfo DisplayName : {0}", CurrentUser.DisplayName.ToString());
        NDebug.Log("FirebaseUserInfo Email : {0}", CurrentUser.Email.ToString());
        NDebug.Log("FirebaseUserInfo IDToken : {0}", IDToken.ToString());
        NDebug.Log("FirebaseUserInfo IsGuestUser : {0}", IsGuestUser());
        NDebug.Log("FirebaseUserInfo CreationTimestamp : {0}", CurrentUser.Metadata.CreationTimestamp);
        NDebug.Log("FirebaseUserInfo LastSignInTimestamp : {0}", CurrentUser.Metadata.LastSignInTimestamp);

        var providerDataList = new List<IUserInfo>(CurrentUser.ProviderData);
        for (int i = 0; i < providerDataList.Count; i++)
        {
            NDebug.Log("FirebaseUserInfo Services_{0} : ProviderId: {1}, UserID: {2}, DisplayName: {3}, Email: {4}", i + 1, providerDataList[i].ProviderId, providerDataList[i].UserId, providerDataList[i].DisplayName, providerDataList[i].Email);
        }
        NDebug.Log("======================================================================================");
    }    

    public void CheckPlatformAuthType()
    {
        NDreamPlatformAuthHelper.Reset();

        if (Util.IsIOS()) NDreamPlatformAuthHelper.SetStoreType((int)NDreamPlatformAuthHelper.eAccountStoreType.APPSTORE);
        else NDreamPlatformAuthHelper.SetStoreType((int)NDreamPlatformAuthHelper.eAccountStoreType.GOOGLE_PLAY);

        if( IsGuestUser() == true )
        {
            NDreamPlatformAuthHelper.AddLinkFlag((int)NDreamPlatformAuthHelper.eAccountLinkType.GUEST);
        }
        else
        {
            for (int i = 0; i < (int)eAuthType.END; i++)
            {
                if (IsLinkService((eAuthType)i) == true)
                {
                    NDreamPlatformAuthHelper.AddLinkFlagByJoyple(i);
                }
            }
        }
        NDebug.Log("NDreamPlatformAuthHelper: {0}", NDreamPlatformAuthHelper.GetJsonString());
    }

    public void CheckGPGAchievement()
    {
        if (Util.IsANDROID() == true && PlatformLoginManager.Instance.IsAuthenticated() == true )
        {
            var iter = QuestManager.Instance.GetChallengeQuestEnum(QuestList.QuestCompleteType.PROCESSING);
            while (iter.MoveNext())
            {
                ChallengeQuest _quest = iter.Current as ChallengeQuest;
                if (_quest != null)
                {
                    NrChallengeQuestDataInfo questinfo = TableChallengeQuestInfo.Instance.Get(_quest.Kind);
                    if (questinfo != null)
                    {
                        for (int j = 0; j < _quest.RewardLevel; j++)
                        {
                            string strAchID = questinfo.GetPlayGamesAchievementID(j);
                            if (!string.IsNullOrEmpty(strAchID))
                            {
                                NDebug.Log("IncrementAchievement: {0}, {1}, {2}", _quest.Kind, j, strAchID);
                                NAuthPlugin.IncrementAchievement(strAchID, 1);
                            }
                        }
                    }
                }
            }
        }
    }

    public void IncrementAchievement(int nQuestKind, int nRewardLevel)
    {
        if (Util.IsANDROID() == true && PlatformLoginManager.Instance.IsAuthenticated() == true)
        {
            ChallengeQuest quest = QuestManager.Instance.GetChallengeQuest(nQuestKind) as ChallengeQuest;
            NrChallengeQuestDataInfo info = TableChallengeQuestInfo.Instance.Get(nQuestKind);

            if (quest != null && info != null)
            {
                string strAchID = info.GetPlayGamesAchievementID(nRewardLevel - 1);
                if (!string.IsNullOrEmpty(strAchID))
                {
                    NDebug.Log("IncrementAchievement: {0}, {1}, {2}", nQuestKind, nRewardLevel - 1, strAchID);
                    NAuthPlugin.IncrementAchievement(strAchID, 1);
                }
            }
        }
    }

    public bool IsSupportedAppleLogin()
    {
        if (Util.IsEDITOR() )
            return false;

        if( Util.IsIOS() )
        {
            string[] VersionToken = PlatformLoginManager.Instance.GetDeviceOSVersion().Split('.');
            if (VersionToken == null || VersionToken.Length < 1)
                return false;

            int version = 0;

            if (int.TryParse(VersionToken[0], out version) == false)
                return false;

            if (version < 13)
                return false;
        }

        return true;
    }
}
