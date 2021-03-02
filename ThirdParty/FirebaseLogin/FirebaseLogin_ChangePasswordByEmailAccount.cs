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
    public class FirebaseLogin_ChangePasswordByEmailAccount : FirebaseLogin_Base
    {
        private ManagementEmailAccountParameter m_Parameter = null;
        private FirebaseUser m_User = null;
        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as ManagementEmailAccountParameter;
            if (m_Parameter != null)
            {
                m_User = FirebaseLoginManager.Instance.CurrentUser;
                if(m_User != null )
                {
                    Credential cred = EmailAuthProvider.GetCredential(m_Parameter.Email, m_Parameter.Password);

                    if( cred != null )
                    {
                        PublicUIMethod.ShowLoadingSpin(true);
                        m_User.ReauthenticateAsync(cred).ContinueWithOnMainThread(OnCheckResult);
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount is cred == null");
                    }
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount is m_User == null");
                }
            }
            else
            {
                NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount is Parameter == null");
            }
        }

        internal void OnCheckResult(Task task)
        {
            if (task.IsCompleted && !task.IsCanceled && !task.IsFaulted)
            {
                m_User.UpdatePasswordAsync(m_Parameter.NewPassword).ContinueWithOnMainThread(OnResult);
            }
            else
            {
                PublicUIMethod.ShowLoadingSpin(false);

                FirebaseLoginError error = GetFirebaseError(task.Exception);

                if (error.eErrorCode == eFirebaseAuthError.None)
                {
                    NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount::OnCheckResult  : Error: Message {0}", task.Exception.ToString());
                    PublicUIMethod.ShowPopUpErrorAlarmDlg((int)eFirebaseAuthError.None, task.Exception.ToString());
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount::OnCheckResult : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);

                    if (error.eErrorCode == eFirebaseAuthError.WrongPassword)
                    {
                        // WRONG_PWD
                        // 비밀번호가 일치하지않습니다
                        PublicUIMethod.ShowPopUpAlarmDlg("ERROR_INPUT_RIGHT_PASSWORD");
                    }
                    else if (error.eErrorCode == eFirebaseAuthError.InvalidEmail || error.eErrorCode == eFirebaseAuthError.UserNotFound)
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

        internal void OnResult(Task task)
        {
            PublicUIMethod.ShowLoadingSpin(false);

            if (task.IsCompleted && !task.IsCanceled && !task.IsFaulted)
            {
                NDebug.Log("EMAIL_CHANGE_PASSWORD is Success");
                PublicMethod.LogoutAndRestartGame();
            }
            else
            {
                FirebaseLoginError error = GetFirebaseError(task.Exception);

                if (error.eErrorCode == eFirebaseAuthError.None)
                {
                    NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount::OnResult : Error: Message {0}", task.Exception.ToString());
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_ChangePasswordByEmailAccount::OnResult : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                    PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage ));
                }
            }
        }
    }

}

