using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase.Auth;
using Firebase.Extensions;
using System.Threading.Tasks;
using PlatformLogin;

namespace FirebaseLogin
{
    /// <summary>
    /// 사용자 정보 요청
    /// </summary>
    public class FirebaseLogin_TokenAsync : FirebaseLogin_Base
    {
        LoginParameter m_Parameter = null;
        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as LoginParameter;
            if (m_Parameter != null && FirebaseLoginManager.Instance.CurrentUser != null)
            {
                NDebug.Log("FirebaseLogin_TokenAsync: params = {0}", m_Parameter.AuthType);
                FirebaseLoginManager.Instance.CurrentUser.ReloadAsync().ContinueWithOnMainThread(OnReloadResult);
            }
            else
            {
                NDebug.LogError("FirebaseLogin_TokenAsync: error_message = params is null or FirebaseLoginManager.Instance.CurrentUser is null");
            }
        }

        void OnReloadResult(Task task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                FirebaseLoginManager.Instance.CurrentUser.TokenAsync(true).ContinueWithOnMainThread(OnResult);
            }
            else
            {
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);

                if (task.IsCanceled)
                {
                    NDebug.Log("FirebaseLogin_TokenAsync OnResult IsCanceled");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_TokenAsync : Error: Message {0}", task.Exception.ToString());
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_TokenAsync : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                    }

                    try
                    {
                        var errorMsg = string.Format("WOT.User.TokenAsync Fail : {0}", error.eErrorCode == eFirebaseAuthError.None ? task.Exception.ToString() : error.strErrorMessage);
                        DebugLogger.Logger.SendDebugLog(DebugLogger.DebugLogDefine.WOT_RequestProfile_Fail, errorMsg);
                    }
                    catch (Exception ex)
                    {
                        NDebug.LogError("_login_process_wot_token_async : " + ex.ToString());
                    }
                }
            }
            PlatformLoginManager.Instance.ReconnetLogin = false;
        }

        void OnResult(Task<string> result)
        {
            if( result.IsCompleted == true && !result.IsCanceled && !result.IsFaulted )
            {
                FirebaseUser localUser = FirebaseLoginManager.Instance.CurrentUser;

                PopupAccountDlg.SyncAccountInfo(); //UI 갱신인듯......

                FirebaseLoginManager.Instance.IDToken = result.Result;
                FirebaseLoginManager.Instance.ShowLogUserInfo();
                FirebaseLoginManager.Instance.CheckPlatformAuthType();

                LoginStageWorker.Instance.SetUserLoginID(localUser.UserId.ToString());
                LoginStageWorker.Instance.SetUserLoginPW(result.Result);

                if( m_Parameter.AuthType != eAuthType.AUTO_LOGIN )
                {
                    FirebaseLoginManager.Instance.SaveLastLoginAuthType(m_Parameter.AuthType);
                }

                // 남아있는 커스텀 토큰이 있으면 삭제한다.
                if (PlayerPrefs.GetInt("ResetCustomToken", 0) == 1)
                {
                    FirebaseLoginManager.Instance.Execute<FirebaseLogin_ResetCustomToken>();
                }

#if !UNITY_EDITOR && UNITY_ANDROID && !AOS_PANHO
                if (FirebaseLoginManager.Instance.IsAuthenticated() == false && PlayerPrefs.GetInt("PGSLogin_denied", 0) == 0 && FirebaseLoginManager.Instance.IsGuestUser() == false)
                {
                    FirebaseLoginManager.Instance.PGSLogin();
                }
#endif
                if (m_Parameter.AuthType == eAuthType.JOIN)
                {
                    EmailManagementDlg dlg = UIFormManager.Instance.FindUIForm<EmailManagementDlg>();
                    if (dlg != null)
                    {
                        PublicUIMethod.ShowLoadingSpin(false);
                        dlg.OnResultEmailJoin(eLoginCallbackResult.SUCCESS);
                        return;
                    }
                }
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.SUCCESS);
            }
            else
            {
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);

                if (result.IsCanceled)
                {
                    NDebug.Log("FirebaseLogin_TokenAsync OnResult IsCanceled");
                }

                if (result.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(result.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_TokenAsync : Error: Message {0}", result.Exception.ToString());
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, result.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_TokenAsync : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                    }
                    
                    try
                    {
                        var errorMsg = string.Format("WOT.User.TokenAsync Fail : {0}", error.eErrorCode == eFirebaseAuthError.None ? result.Exception.ToString() : error.strErrorMessage);
                        DebugLogger.Logger.SendDebugLog(DebugLogger.DebugLogDefine.WOT_RequestProfile_Fail, errorMsg);
                    }
                    catch (Exception ex)
                    {
                        NDebug.LogError("_login_process_wot_token_async : " + ex.ToString());
                    }
                }
            }
            PlatformLoginManager.Instance.ReconnetLogin = false;
        }
    }
}