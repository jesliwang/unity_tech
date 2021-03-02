using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase.Auth;
using Firebase.Extensions;
using System.Threading.Tasks;
using PlatformLogin;
using WasServer.Common;

namespace FirebaseLogin
{
    /// <summary>
    /// 디바이스UUID용 커스텀토큰 삭제 요청
    /// </summary>
    public class FirebaseLogin_ResetCustomToken : FirebaseLogin_Base
    {
        public override void Execute(IParameter arg = null)
        {
            var request = new SU_RESET_CUSTOM_TOKEN_REQ();

            request.strFriebaseID = FirebaseLoginManager.Instance.GetUserID();

            NDebug.Log("FirebaseLogin_ResetCustomToken: params = FirebaseID: {0}", request.strFriebaseID);

            GameMain.Instance.StartCoroutine(new WebRequestOperation().RequestPOST(GameFramework.Instance.authURL + "/customtokenReset", request, OnSuccess, OnFail));
        }

        private void OnSuccess(string text, Action<object[]> callback, object[] param)
        {
            try
            {
                var JsonData = Newtonsoft.Json.JsonConvert.DeserializeObject<SU_RESET_CUSTOM_TOKEN_ACK>(text);
                if (JsonData != null)
                {
                    if (JsonData.nResult == 0)
                    {
                        NDebug.Log("FirebaseLogin_ResetCustomToken: Success");

                        PlayerPrefs.SetInt("ResetCustomToken", 0);
                        PlayerPrefs.Save();

                    }
                    else
                    {
                        NDebug.Log("FirebaseLogin_ResetCustomToken: Failed -  Error: {1}({2}) - {3}", JsonData.strErrorCode, JsonData.nResult, JsonData.strErrorMessage);
                    }
                }
            }
            catch (System.Exception e)
            {
                NDebug.LogError("Json: Exception : {0}", "FirebaseLogin_ResetCustomToken", e.Message);
            }
        }
        private void OnFail(string text, WebRequestError error)
        {
            NDebug.LogError("FirebaseLogin_ResetCustomToken OnFail : {0}", error.ToString());
        }
    }
}