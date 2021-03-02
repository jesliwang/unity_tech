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
    public class FirebaseLogin_SendChangePasswordMail : FirebaseLogin_Base
    {
        private ManagementEmailAccountParameter m_Parameter = null;
        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as ManagementEmailAccountParameter;
            if (m_Parameter != null)
            {
                PublicUIMethod.ShowLoadingSpin(true);
                FirebaseLoginManager.Instance.Auth.SendPasswordResetEmailAsync(m_Parameter.Email).ContinueWithOnMainThread(OnResult);
            }
            else
            {
                NDebug.LogError("FirebaseLogin_SendChangePasswordMail is Parameter == null");
            }
        }

        internal void OnResult(Task task)
        {
            PublicUIMethod.ShowLoadingSpin(false);

            if ( task.IsCompleted && !task.IsCanceled && !task.IsFaulted )
            {
                PopUpAlarmDlg popupAlramDlg = UIFormManager.Instance.OpenUIForm<PopUpAlarmDlg>();
                popupAlramDlg.SetForce(NTextManager.Instance.GetText("UI_EMAIL_SEND_TEMP_PASSWORD_TITLE_02"));
            }
            else
            {
                FirebaseLoginError error = GetFirebaseError(task.Exception);

                if (error.eErrorCode == eFirebaseAuthError.None)
                {
                    NDebug.LogError("FirebaseLogin_SendChangePasswordMail : Error: Message {0}", task.Exception.ToString());

                    PopUpAlarmDlg popupAlramDlg = UIFormManager.Instance.OpenUIForm<PopUpAlarmDlg>();
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, task.Exception.ToString());                    
                }
                else
                {
                    NDebug.LogError("FirebaseLogin_SendChangePasswordMail : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                    PublicUIMethod.ShowPopUpErrorAlarmDlg((int)error.eErrorCode, string.Format("({0}) - {1}", error.eErrorCode.ToString(), error.strErrorMessage));
                }
            }
        }
    }
}


