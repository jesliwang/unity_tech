using Firebase.Auth;
using Firebase.Extensions;
using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PlatformLogin;
using WasServer.Common;
using System.Threading.Tasks;

namespace FirebaseLogin
{
    public class FirebaseLogin_CustomUIWithLinkServiceEmail : FirebaseLogin_Base
    {
        private bool bIsGuestUser = false;
        protected LinkServiceEmailParameter m_Parameter = null;
        private FirebaseUser m_User = null;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as LinkServiceEmailParameter;
            if (m_Parameter != null)
            {
                PublicUIMethod.ShowLoadingSpin(true);
                NDebug.Log("FirebaseLogin_CustomUIWithLinkServiceEmail: params = {0}", m_Parameter.Email);

                m_User = FirebaseLoginManager.Instance.CurrentUser;
                if (m_User != null)
                {
                    bIsGuestUser = FirebaseLoginManager.Instance.IsGuestUser();
                    Credential credential = EmailAuthProvider.GetCredential(m_Parameter.Email, m_Parameter.Password);
                    m_User.LinkWithCredentialAsync(credential).ContinueWithOnMainThread(OnResult);
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_CustomUIWithLinkServiceEmail: error_message = params is null");
            }
        }

        internal void OnResult(Task<FirebaseUser> result)
        {
            if( result.IsCompleted && !result.IsCanceled && !result.IsFaulted )
            {
                FirebaseUser data = result.Result;
                NDebug.Log("FirebaseLogin_CustomUIWithLinkServiceEmail is Success : Provider: {0}, ID: {1}", data.ProviderId, data.UserId );
                FirebaseLoginManager.Instance.Execute<FirebaseLogin_LinkTokenAsync>(new LinkServicTypeParameter(eAuthType.EMAIL, bIsGuestUser));
            }
            else
            {
                PublicUIMethod.ShowLoadingSpin(false);
                PlatformLoginManager.Instance.ReconnetLogin = false;

                if (result.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithLinkServiceEmail : Canceld");
                }

                if (result.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(result.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithLinkServiceEmail : Error: Message {0}", result.Exception.ToString());

                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, result.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithLinkServiceEmail : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);

                        if (error.eErrorCode == eFirebaseAuthError.EmailAlreadyInUse)
                        {
                            //이미 사용 중인 이메일입니다.
                            PublicUIMethod.ShowPopUpAlarmDlg("UI_ALREADY_USE_EMAIL");
                        }
                        else if (error.eErrorCode == eFirebaseAuthError.ProviderAlreadyLinked)
                        {
                            // ALREADY_EXISTS_GAMEINFO  
                            // 연결하고자 하는 계정은 이미 가입된 계정입니다  
                            PublicUIMethod.ShowPopUpAlarmDlg("UI_LINK_EMAIL_ALREADY");
                        }
                        else if( error.eErrorCode == eFirebaseAuthError.RequiresRecentLogin )
                        {
                            // 마지막 인증시간이 오래되었을때 재인증이 필요합니다.
                            // 게스트 계정이 아닐때만 에러 메세지를 출력합니다.
                            if( FirebaseLoginManager.Instance.IsGuestUser() == false )
                            {
                                PublicUIMethod.ShowPopUpAlarmDlg("ERROR_SYSTEM_FAIL_AUTHENTICATION");
                            }
                            FirebaseLoginManager.Instance.ReAuth(OnEmailLink);
                        }
                        else if(error.eErrorCode == eFirebaseAuthError.InvalidEmail)
                        {
                            // 잘못된 이메일 형식을 사용했을떄
                            PublicUIMethod.ShowPopUpAlarmDlg("ERROR_INPUT_RIGHT_EMAIL");
                        }
                        else if (error.eErrorCode != eFirebaseAuthError.WebContextCancelled && error.eErrorCode != eFirebaseAuthError.Cancelled)
                        {
                            PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                        }
                    }
                }

                EmailManagementDlg dlg = UIFormManager.Instance.FindUIForm<EmailManagementDlg>();
                if (dlg != null)
                {
                    dlg.OnResultEmailLink(eLoginCallbackResult.FAIL);
                }
            }
        }

        void OnEmailLink()
        {
            Credential credential = EmailAuthProvider.GetCredential(m_Parameter.Email, m_Parameter.Password);
            m_User.LinkWithCredentialAsync(credential).ContinueWithOnMainThread(OnResult);
        }
    }
}