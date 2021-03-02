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
    /// <summary>
    /// 조이플 로그인 호출
    /// </summary>
    public class FirebaseLogin_CustomUIWithManualLogin : FirebaseLogin_Base
    {
        private ManualLoginParameter m_Parameter = null;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as ManualLoginParameter;
            if (m_Parameter != null)
            {
                FirebaseAuth auth = FirebaseLoginManager.Instance.Auth;
                if (auth.CurrentUser != null)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin: Prev User SignOut");
                    auth.SignOut();
                }

                NDebug.Log("FirebaseLogin_CustomUIWithManualLogin: params = Auth: {0}, PlatformIDToken: {1}, PlatformAccessToken: {2}", m_Parameter.AuthType, m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken);

                if( m_Parameter.AuthType == eAuthType.GOOGLE || m_Parameter.AuthType == eAuthType.FACEBOOK || ( m_Parameter.AuthType == eAuthType.APPLE && Util.IsIOS() ) )
                {
                    Credential cred = null;

                    if (m_Parameter.AuthType == eAuthType.GOOGLE)
                    {
                        cred = GoogleAuthProvider.GetCredential(m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken.Equals("") ? null : m_Parameter.PlatformAccessToken);
                    }
                    else if (m_Parameter.AuthType == eAuthType.FACEBOOK)
                    {
                        cred = FacebookAuthProvider.GetCredential(m_Parameter.PlatformIDToken);
                    }
                    else if (m_Parameter.AuthType == eAuthType.APPLE)
                    {
                        cred = OAuthProvider.GetCredential("apple.com", m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken, null);
                    }
                    auth.SignInWithCredentialAsync(cred).ContinueWithOnMainThread(OnResultByUser);
                }
                else if( m_Parameter.AuthType == eAuthType.APPLE && Util.IsANDROID())
                {
                    FederatedOAuthProviderData providerData = new FederatedOAuthProviderData();
                    providerData.ProviderId = "apple.com";
                    providerData.Scopes = new List<string>() { "email", "name" };
                    FederatedOAuthProvider provider = new FederatedOAuthProvider();
                    provider.SetProviderData(providerData);
                    auth.SignInWithProviderAsync(provider).ContinueWithOnMainThread(OnResultBySign);
                }
                else if( m_Parameter.AuthType == eAuthType.GUEST )
                {
                    auth.SignInWithCustomTokenAsync(m_Parameter.PlatformIDToken).ContinueWithOnMainThread(OnResultByUser);
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin: error_message = Unknown Auth: {0}", m_Parameter.AuthType);
                    return;
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin: error_message = params is null");
            }
        }

        internal void OnResult(Task task)
        {
            NDebug.Log("FirebaseLogin_CustomUIWithManualLogin : OnResult");
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted )
            {
                FirebaseLoginManager.Instance.Execute<FirebaseLogin_TokenAsync>(new LoginParameter(m_Parameter.AuthType));
            }
            else
            {
                PlatformLoginManager.Instance.ReconnetLogin = false;
                PublicUIMethod.ShowLoadingSpin(false);

                FirebaseLoginManager.Instance.SaveLastLoginAuthType(eAuthType.NONE);
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);

                if (task.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin : Canceld");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);
                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin : Error: Message {0}", task.Exception.ToString());

                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithManualLogin : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);

                        if (error.eErrorCode == eFirebaseAuthError.WrongPassword)
                        {
                            // WRONG_PWD
                            // 비밀번호가 일치하지않습니다
                            PublicUIMethod.ShowPopUpAlarmDlg("ERROR_INPUT_RIGHT_PASSWORD");
                        }
                        else if (error.eErrorCode == eFirebaseAuthError.InvalidEmail)
                        {
                            // UNREGISTERD_USER
                            // 가입된 이메일 계정이 아닙니다
                            PublicUIMethod.ShowPopUpAlarmDlg("ERROR_DO_NOT_EXIST_EMAIL");
                        }
                        else if (error.eErrorCode != eFirebaseAuthError.WebContextCancelled && error.eErrorCode != eFirebaseAuthError.Cancelled)
                        {
                            PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                        }
                    }
                }
            }
        }

        internal void OnResultByUser(Task<FirebaseUser> task)
        {
            NDebug.Log("FirebaseLogin_CustomUIWithManualLogin : OnResultByUser");
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_CustomUIWithManualLogin : Success: ID: {0}, Name: {1}", task.Result.UserId, task.Result.DisplayName);
            }
            OnResult(task);
        }

        internal void OnResultBySign(Task<SignInResult> task)
        {
            NDebug.Log("FirebaseLogin_CustomUIWithManualLogin : OnResultBySign");
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("FirebaseLogin_CustomUIWithManualLogin : Success: ID: {0}, Name: {1}", task.Result.User.UserId, task.Result.User.DisplayName);
            }
            OnResult(task);
        }
    }
}
