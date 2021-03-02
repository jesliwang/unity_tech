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
    public class FirebaseLogin_CustomUIWithLinkServices : FirebaseLogin_Base
    {
        private FirebaseUser m_User = null;
        private ManualLoginParameter m_Parameter = null;
        private bool bIsGuestUser = false;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as ManualLoginParameter;
            if (m_Parameter != null)
            {
                FirebaseAuth auth = FirebaseLoginManager.Instance.Auth;
                FirebaseUser user = auth.CurrentUser;
                if (user != null)
                {
                    bIsGuestUser = FirebaseLoginManager.Instance.IsGuestUser();

                    NDebug.Log("FirebaseLogin_CustomUIWithLinkServices: params = Auth: {0}, PlatformIDToken: {1}, PlatformAccessToken: {2}, Guest: {3}", m_Parameter.AuthType, m_Parameter.PlatformIDToken, m_Parameter.PlatformAccessToken, bIsGuestUser);

                    if (m_Parameter.AuthType == eAuthType.GOOGLE || m_Parameter.AuthType == eAuthType.FACEBOOK || (m_Parameter.AuthType == eAuthType.APPLE && Util.IsIOS()))
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
                        user.LinkWithCredentialAsync(cred).ContinueWithOnMainThread(OnResultByUser);
                    }
                    else if (m_Parameter.AuthType == eAuthType.APPLE && Util.IsANDROID())
                    {
                        FederatedOAuthProviderData providerData = new FederatedOAuthProviderData();
                        providerData.ProviderId = "apple.com";
                        providerData.Scopes = new List<string>() { "email", "name" };
                        FederatedOAuthProvider provider = new FederatedOAuthProvider();
                        provider.SetProviderData(providerData);
                        user.LinkWithProviderAsync(provider).ContinueWithOnMainThread(OnResultBySign);
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices: error_message = Unknown Auth Type: {0}", m_Parameter.AuthType);
                    }
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices: error_message = user is null");
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices: error_message = params is null");
            }
        }

        internal void OnResult(Task task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                FirebaseLoginManager.Instance.Execute<FirebaseLogin_LinkTokenAsync>(new LinkServicTypeParameter(m_Parameter.AuthType, bIsGuestUser));
            }
            else
            {
                PlatformLoginManager.Instance.ReconnetLogin = false;
                PublicUIMethod.ShowLoadingSpin(false);

                // 에러가 발생하면 플랫폼 로그아웃 처리를 한다.
                FirebaseLoginManager.Instance.PlatformLogout(m_Parameter.AuthType);

                if (task.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices : Canceld");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);
                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices : Error: Message {0}", task.Exception.ToString());
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithLinkServices : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);

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
                        else if (error.eErrorCode == eFirebaseAuthError.CredentialAlreadyInUse)
                        {
                            // 해당 계정은 이미 다른 계정에 연동되어 있습니다. 
                            if (m_Parameter.AuthType == eAuthType.GOOGLE)
                                PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_GOOGLE_ALREADY");
                            else if (m_Parameter.AuthType == eAuthType.FACEBOOK)
                                PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_FACEBOOK_ALREADY");
                            else if (m_Parameter.AuthType == eAuthType.APPLE)
                                PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_APPLE_ALREADY");
                        }
                        else if( error.eErrorCode != eFirebaseAuthError.WebContextCancelled && error.eErrorCode != eFirebaseAuthError.Cancelled )
                        {
                            PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                        }
                    }
                }
            }
        }

        internal void OnResultByUser(Task<FirebaseUser> task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted && task.Result != null)
            {
                NDebug.Log("FirebaseLogin_CustomUIWithLinkServices : Success: Auth: {0}, ID: {1}, Name: {2}", task.Result.ProviderId, task.Result.UserId, task.Result.DisplayName);
            }
            OnResult(task);
        }

        internal void OnResultBySign(Task<SignInResult> task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted && task.Result.User != null)
            {
                NDebug.Log("FirebaseLogin_CustomUIWithLinkServices : Success: Auth: {0}, ID: {1}, Name: {2}", task.Result.User.ProviderId, task.Result.User.UserId, task.Result.User.DisplayName);
            }
            OnResult(task);
        }
    }
}