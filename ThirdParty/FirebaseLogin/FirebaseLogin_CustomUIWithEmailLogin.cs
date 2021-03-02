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
    public class FirebaseLogin_CustomUIWithEmailLogin : FirebaseLogin_Base
    {
        private EmailLoginParameter m_Parameter = null;
        private FirebaseUser m_User = null;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as EmailLoginParameter;
            if (m_Parameter != null)
            {
                PublicUIMethod.ShowLoadingSpin(true);
                NDebug.Log("FirebaseLogin_CustomUIWithEmailLogin: params = email: {0}, password: {1}", m_Parameter.Email, m_Parameter.Password);

                m_User = FirebaseLoginManager.Instance.CurrentUser;
                if (m_User != null)
                {
                    if( m_User.Email.Equals(m_Parameter.Email) )
                    {
                        NDebug.LogError("User already signed: {0} ({1})", m_User.UserId, m_User.Email);
                        FirebaseLoginManager.Instance.Execute<FirebaseLogin_TokenAsync>(new LoginParameter(eAuthType.EMAIL));
                        return;
                    }

                    NDebug.LogError("User already signed: {0} ({1}) prev account is sign out!", m_User.UserId, m_User.UserId);
                    FirebaseLoginManager.Instance.Auth.SignOut();
                }
                FirebaseLoginManager.Instance.Auth.SignInWithEmailAndPasswordAsync(m_Parameter.Email, m_Parameter.Password).ContinueWithOnMainThread(OnResult);                
            }
            else
            {
                NDebug.LogError("Firebase_Login: error_message = params is null");
            }
        }

        internal void OnResult(Task<FirebaseUser> task)
        {
            if (task.IsCompleted == true && !task.IsCanceled && !task.IsFaulted)
            {
                m_User = task.Result;
                NDebug.Log("FirebaseLogin_CustomUIWithEmailLogin : Success: ID: {0}, Name: {1}", m_User.UserId, m_User.DisplayName);                
                FirebaseLoginManager.Instance.Execute<FirebaseLogin_TokenAsync>(new LoginParameter(eAuthType.EMAIL));
            }
            else
            {
                PlatformLoginManager.Instance.ReconnetLogin = false;
                PublicUIMethod.ShowLoadingSpin(false);

                if (task.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithEmailLogin : Canceld");
                }

                if (task.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(task.Exception);
                    if(error.eErrorCode == eFirebaseAuthError.None )
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithEmailLogin : Error: Message {0}", task.Exception.ToString());

                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithEmailLogin : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);

                        if(error.eErrorCode == eFirebaseAuthError.WrongPassword )
                        {
                            // WRONG_PWD
                            // 비밀번호가 일치하지않습니다
                            PublicUIMethod.ShowPopUpAlarmDlg("ERROR_INPUT_RIGHT_PASSWORD");
                        }
                        else if(error.eErrorCode == eFirebaseAuthError.InvalidEmail || error.eErrorCode == eFirebaseAuthError.UserNotFound)
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
    }
}
