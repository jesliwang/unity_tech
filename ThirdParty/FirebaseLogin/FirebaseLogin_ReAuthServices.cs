using Firebase.Auth;
using Firebase.Extensions;
using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading.Tasks;
using PlatformLogin;

namespace FirebaseLogin
{
    public class FirebaseLogin_ReAuthServices : FirebaseLogin_Base
    {
        private ReAuthParameter m_Parameter = null;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as ReAuthParameter;
            if (m_Parameter != null)
            {
                FirebaseAuth auth = FirebaseLoginManager.Instance.Auth;
                NDebug.Log("FirebaseLogin_ReAuthServices: params = Auth: {0}, PlatformIDToken: {1}, PlatformAccessToken: {2}", m_Parameter.AuthType, m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken);
                if(auth.CurrentUser == null )
                {
                    NDebug.LogError("FirebaseLogin_ReAuthServices: error_message = FirebaseUser is null");
                }

                PublicUIMethod.ShowLoadingSpin(true);
                if (m_Parameter.AuthType == eAuthType.GOOGLE || m_Parameter.AuthType == eAuthType.FACEBOOK || (m_Parameter.AuthType == eAuthType.APPLE && Util.IsIOS()))
                {
                    Credential cred = null;

                    if (m_Parameter.AuthType == eAuthType.GOOGLE)
                    {
                        cred = GoogleAuthProvider.GetCredential(m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken.Equals("") ? null : m_Parameter.PlatformAccessToken );
                    }
                    else if (m_Parameter.AuthType == eAuthType.FACEBOOK)
                    {
                        cred = FacebookAuthProvider.GetCredential(m_Parameter.PlatformIDToken);
                    }
                    else if(m_Parameter.AuthType == eAuthType.APPLE )
                    {
                        cred = OAuthProvider.GetCredential("apple.com", m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken, null);
                    }
                    auth.CurrentUser.ReauthenticateAsync(cred).ContinueWithOnMainThread(OnResult);
                }
                else if (m_Parameter.AuthType == eAuthType.APPLE && Util.IsANDROID())
                {
                    FederatedOAuthProviderData providerData = new FederatedOAuthProviderData();
                    providerData.ProviderId = "apple.com";
                    providerData.Scopes = new List<string>() { "email", "name" };
                    FederatedOAuthProvider provider = new FederatedOAuthProvider();
                    provider.SetProviderData(providerData);
                    auth.CurrentUser.ReauthenticateWithProviderAsync(provider).ContinueWithOnMainThread(OnResultBySign);
                }
                else if (m_Parameter.AuthType == eAuthType.GUEST)
                {
                    auth.SignInWithCustomTokenAsync(m_Parameter.PlatformIDToken).ContinueWithOnMainThread(OnResultByUser);
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_ReAuthServices: error_message = Unknown Auth: {0}", m_Parameter.AuthType);
                    return;
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_ReAuthServices: error_message = params is null");
            }
        }

        internal void OnResult(Task task)
        {
            PublicUIMethod.ShowLoadingSpin(false);

            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_ReAuthServices : Success: ID: {0}, Name: {1}", FirebaseLoginManager.Instance.Auth.CurrentUser.UserId, FirebaseLoginManager.Instance.Auth.CurrentUser.DisplayName);
                FirebaseLoginManager.Instance.SaveLastReAuthTimeByCurrentTime();
                FirebaseLoginManager.Instance.PlayReAuthCallback();
                if (m_Parameter.AuthType != eAuthType.GUEST)
                {
                    PopUpAlarmDlg popupAlramDlg = UIFormManager.Instance.OpenUIForm<PopUpAlarmDlg>();
                    popupAlramDlg.SetForce(NTextManager.Instance.GetText("UI_LOGIN_APPLE_REAUTHORIZATION_SUCCESS"));
                }
            }
            else
            {
                // 에러가 발생하면 재인증을 진행했던 플랫폼 로그아웃 처리를 한다.
                FirebaseLoginManager.Instance.PlatformLogout(m_Parameter.AuthType);

                if (task.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_ReAuthServices : Canceld");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);
                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_ReAuthServices : Error: Message {0}", task.Exception.ToString());
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_ReAuthServices : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        
                        // 다른 계정으로 인증을 했을경우
                        if ( error.eErrorCode == eFirebaseAuthError.UserMismatch )
                        {
                            PublicUIMethod.ShowPopUpAlarmDlg("UI_LOGIN_APPLE_REAUTHORIZATION_FAIL");
                        }
                        else if (error.eErrorCode != eFirebaseAuthError.WebContextCancelled && error.eErrorCode != eFirebaseAuthError.Cancelled)
                        {
                            PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                        }
                    }
                }

                var loginDlg = UIFormManager.Instance.OpenUIForm<EmailManagementDlg>();
                if( loginDlg != null )
                {
                    loginDlg.Close();
                }
            }
        }

        internal void OnResultBySign(Task<SignInResult> task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_ReAuthServices : Success: ID: {0}, Name: {1}", task.Result.User.UserId, task.Result.User.DisplayName);
            }
            OnResult(task);
        }

        internal void OnResultByUser(Task<FirebaseUser> task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_ReAuthServices : Success: ID: {0}, Name: {1}", task.Result.UserId, task.Result.DisplayName);
            }
            OnResult(task);
        }
    }
}
