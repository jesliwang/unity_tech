using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;
using PlatformLogin;

namespace FirebaseLogin
{
    public class FirebaseLoginError
    {
        public eFirebaseAuthError eErrorCode { get; set; } = eFirebaseAuthError.None;
        public string strErrorMessage { get; set; } = string.Empty;

        public FirebaseLoginError()
        {

        }

        public FirebaseLoginError( eFirebaseAuthError eCode, string strMessage )
        {
            eErrorCode = eCode;
            strErrorMessage = strMessage;
        }
    }

    public class FirebaseLogin_Base : PlatformLogin_Base
    {
        // repo : https://stackoverflow.com/questions/53036083/google-firebase-how-to-catch-specific-auth-exception-errors-unity/53036084#53036084
        public FirebaseLoginError GetFirebaseError(AggregateException exception)
        {
            FirebaseLoginError ret = new FirebaseLoginError();

            foreach (Exception e in exception.Flatten().InnerExceptions)
            {
                Firebase.FirebaseException firebaseEx = e as Firebase.FirebaseException;
                if (firebaseEx != null)
                {
                    ret.eErrorCode = (eFirebaseAuthError)firebaseEx.ErrorCode;
                    ret.strErrorMessage = firebaseEx.ToString();
                    break;
                }
                else
                {
                    Firebase.Auth.FirebaseAccountLinkException ex = e as Firebase.Auth.FirebaseAccountLinkException;
                    if (ex != null)
                    {
                        ret.eErrorCode = (eFirebaseAuthError)ex.ErrorCode;
                        ret.strErrorMessage = ex.ToString();
                        break;
                    }
                }
            }

            return ret;
        }

        public void GetFirebaseError(AggregateException exception, out eFirebaseAuthError eErrorCode, out string strEnumCode, out string strMsg )
        {
            eErrorCode = eFirebaseAuthError.None;
            strEnumCode = "";
            strMsg = "";

            foreach (Exception e in exception.Flatten().InnerExceptions)
            {
                Firebase.FirebaseException firebaseEx = e as Firebase.FirebaseException;
                if (firebaseEx != null)
                {
                    eErrorCode = (eFirebaseAuthError)firebaseEx.ErrorCode;
                    strEnumCode = eErrorCode.ToString();
                    strMsg = firebaseEx.ToString();
                    break;
                }
                else
                {
                    Firebase.Auth.FirebaseAccountLinkException ex = e as Firebase.Auth.FirebaseAccountLinkException;
                    if( ex != null )
                    {
                        eErrorCode = (eFirebaseAuthError)firebaseEx.ErrorCode;
                        strEnumCode = eErrorCode.ToString();
                        strMsg = firebaseEx.ToString();
                        break;
                    }
                }
            }
        }
    }
}