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
    public class FirebaseLogin_LinkTokenAsync : FirebaseLogin_Base
    {
        private LinkServicTypeParameter m_Parameter = null;
        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as LinkServicTypeParameter;
            if (m_Parameter != null)
            {
                if (FirebaseLoginManager.Instance.CurrentUser != null)
                {
                    NDebug.Log("FirebaseLogin_LinkTokenAsync IsGuestUser : {0}", m_Parameter.bWasGuestUser);
                    FirebaseLoginManager.Instance.CurrentUser.ReloadAsync().ContinueWithOnMainThread(OnResult);
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_LinkTokenAsync: error_message = params is null");
            }
        }

        void OnResult(Task task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_LinkTokenAsync: Reload Success");
                FirebaseLoginManager.Instance.CurrentUser.TokenAsync(true).ContinueWithOnMainThread(OnResultTokenAsync);
            }
            else
            {
                if (task.IsCanceled)
                {
                    NDebug.Log("FirebaseLogin_LinkTokenAsync: OnResult IsCanceled");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_LinkTokenAsync: Error: Message {0}", task.Exception.ToString());

                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_LinkTokenAsync : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                    }
                }

                if (m_Parameter.AuthType == eAuthType.EMAIL)
                {
                    EmailManagementDlg dlg = UIFormManager.Instance.FindUIForm<EmailManagementDlg>();
                    if (dlg != null)
                    {
                        dlg.OnResultEmailLink(eLoginCallbackResult.FAIL);
                    }
                }
            }
        }

        void OnResultTokenAsync(Task<string> result)
        {
            PublicUIMethod.ShowLoadingSpin(false);
            if (result.IsCompleted == true && !result.IsCanceled && !result.IsFaulted)
            {
                FirebaseLoginManager.Instance.IDToken = result.Result;
                FirebaseUser localUser = FirebaseLoginManager.Instance.CurrentUser;

                PopupAccountDlg.SyncAccountInfo(); //UI 갱신인듯......
                FirebaseLoginManager.Instance.ShowLogUserInfo();

                var id = localUser.UserId.ToString();
                var pw = FirebaseLoginManager.Instance.IDToken.ToString();

                LoginStageWorker.Instance.SetUserLoginID(id);
                LoginStageWorker.Instance.SetUserLoginPW(pw);

                FirebaseLoginManager.Instance.SaveLastLoginAuthType(m_Parameter.AuthType);

                if (m_Parameter.AuthType == eAuthType.EMAIL)
                {
                    EmailManagementDlg dlg = UIFormManager.Instance.FindUIForm<EmailManagementDlg>();
                    if (dlg != null)
                    {
                        dlg.OnResultEmailLink(eLoginCallbackResult.SUCCESS);
                    }
                }
                else if (m_Parameter.AuthType == eAuthType.GOOGLE)
                {
                    PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_GOOGLE");
                }
                else if (m_Parameter.AuthType == eAuthType.FACEBOOK)
                {
                    PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_FACEBOOK");
                }
                else if( m_Parameter.AuthType == eAuthType.APPLE )
                {
                    PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_APPLE");
                }

                if(m_Parameter.bWasGuestUser == true )
                {
                    PlayerPrefs.SetInt("ResetCustomToken", 1);
                    PlayerPrefs.Save();
                    FirebaseLoginManager.Instance.Execute<FirebaseLogin_ResetCustomToken>();
                }

                User.Instance.SendGS_ACCOUNT_LINKINFO_UPDATE_NFY();
            }
            else
            {
                if (result.IsCanceled)
                {
                    NDebug.Log("FirebaseLogin_LinkTokenAsync OnResult IsCanceled");
                }

                if (result.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(result.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_LinkTokenAsync : Error: Message {0}", result.Exception.ToString());

                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, result.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_LinkTokenAsync : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                    }
                }

                if (m_Parameter.AuthType == eAuthType.EMAIL)
                {
                    EmailManagementDlg dlg = UIFormManager.Instance.FindUIForm<EmailManagementDlg>();
                    if (dlg != null)
                    {
                        dlg.OnResultEmailLink(eLoginCallbackResult.FAIL);
                    }
                }
            }
        }
    }
}