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
    /// 조이플 메일 생성 및 로그인
    /// </summary>
    public class FirebaseLogin_CustomUIWithEmailJoin : FirebaseLogin_Base
    {
        JoinParameter m_Parameter = null;
        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as JoinParameter;
            if (m_Parameter != null)
            {
                NDebug.Log("FirebaseLogin: params = {0}", m_Parameter.Email);

                PublicUIMethod.ShowLoadingSpin(true);

                FirebaseAuth auth = FirebaseLoginManager.Instance.Auth;
                auth.CreateUserWithEmailAndPasswordAsync(m_Parameter.Email, m_Parameter.Password).ContinueWithOnMainThread(OnResult);
            }
            else
            {
                NDebug.LogError("Joyple_Login: error_message = params is null");
            }
        }

        internal void OnResult(Task<FirebaseUser> result)
        {
            if( result.IsCompleted && !result.IsCanceled && !result.IsFaulted )
            {
                FirebaseUser newUser = result.Result;
                NDebug.Log("FirebaseLogin_CustomUIWithEmailJoin : Success: ID: {0}, Name: {1}", newUser.UserId, newUser.DisplayName);
                FirebaseLoginManager.Instance.Execute<FirebaseLogin_TokenAsync>( new LoginParameter( eAuthType.JOIN) );
            }
            else
            {
                PlatformLoginManager.Instance.ReconnetLogin = false;
                PublicUIMethod.ShowLoadingSpin(false);

                if (result.IsCanceled)
                {
                    NDebug.LogError("FirebaseLogin_CustomUIWithEmailJoin was canceled.");
                }

                if (result.IsFaulted)
                {
                    FirebaseLoginError error = GetFirebaseError(result.Exception);

                    if (error.eErrorCode == eFirebaseAuthError.None)
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithEmailJoin : Error: Message {0}", result.Exception.ToString());
                        PublicUIMethod.ShowPopUpErrorAlarmDlg(0, result.Exception.ToString());
                    }
                    else
                    {
                        NDebug.LogError("FirebaseLogin_CustomUIWithEmailJoin : Error: Code: {0}({1}), Message {2}", error.eErrorCode.ToString(), (int)error.eErrorCode, error.strErrorMessage);
                        if( error.eErrorCode == eFirebaseAuthError.EmailAlreadyInUse )
                        {
                            PublicUIMethod.ShowPopUpAlarmDlg("UI_ALREADY_USE_EMAIL");
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