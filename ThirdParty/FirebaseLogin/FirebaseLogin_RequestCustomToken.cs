using NLibCs;
using System;
using PlatformLogin;
using WasServer.Common;

namespace FirebaseLogin
{
    /// <summary>
    /// 디바이스UUID용 커스텀토큰 요청
    /// </summary>
    public class FirebaseLogin_RequestCustomToken : FirebaseLogin_Base
    {
        private bool bIsReauth = false;

        public override void Execute(IParameter arg = null)
        {
            PublicUIMethod.ShowLoadingSpin(true);

            RequestTokenParameter parameter = arg as RequestTokenParameter;
            if( parameter != null )
            {
                bIsReauth = parameter.bIsReAuth;
            }

            var request = new SU_CUSTOM_TOKEN_REQ();
            request.DeviceUUID = FirebaseLoginManager.Instance.GetDeviceId();

            NDebug.Log("FirebaseLogin_RequestCustomToken: params = DeviceID: {0}", request.DeviceUUID);

            GameMain.Instance.StartCoroutine(new WebRequestOperation().RequestPOST(GameFramework.Instance.authURL + "/customtoken", request, OnSuccess, OnFail));
        }

        private void OnSuccess(string text, Action<object[]> callback, object[] param)
        {
            try
            {
                var JsonData = Newtonsoft.Json.JsonConvert.DeserializeObject<SU_CUSTOM_TOKEN_ACK>(text);
                if (JsonData != null)
                {
                    if( JsonData.nResult == 0 )
                    {
                        NDebug.Log("FirebaseLogin_RequestCustomToken: Success -  DeviceID: {0}, CustomToken: {1}", JsonData.strDeviceUUID, JsonData.strCustomToken);
                        if( bIsReauth == false )
                        {
                            FirebaseLoginManager.Instance.Execute<FirebaseLogin_CustomUIWithManualLogin>(new ManualLoginParameter(eAuthType.GUEST, JsonData.strCustomToken));
                        }
                        else
                        {
                            FirebaseLoginManager.Instance.Execute<FirebaseLogin_ReAuthServices>(new ReAuthParameter(eAuthType.GUEST, JsonData.strCustomToken));
                        }
                    }
                    else
                    {
                        NDebug.Log("FirebaseLogin_RequestCustomToken: Failed -  DeviceID: {0}, Error: {1}({2}) - {3}", JsonData.strDeviceUUID, JsonData.strErrorCode, JsonData.nResult, JsonData.strErrorMessage);
                        OnError(JsonData.strErrorMessage, JsonData.nResult, JsonData.strErrorCode);
                    }
                }
            }
            catch (Exception e)
            {
                NDebug.LogError("Json: Exception : {0}", "FirebaseLogin_RequestCustomToken", e.Message);
                OnError(e.Message, -1, "ExceptionError");                
            }
        }
        private void OnFail(string text, WebRequestError error)
        {
            NDebug.LogError("FirebaseLogin_RequestCustomToken OnFail : {0}", error.ToString());
            OnError(error.ToString(), -1, "OnFailError");
        }

        private void OnError(string strErrorMessage, int nErrorCode, string strErrorCode)
        {
            PublicUIMethod.ShowLoadingSpin(false);
            PlatformLoginManager.Instance.ReconnetLogin = false;

            NDebug.LogError("FirebaseLogin_RequestCustomToken OnError : {0}({1}) - {2}", strErrorCode, nErrorCode, strErrorMessage);

            PublicUIMethod.ShowPopUpErrorAlarmDlg(nErrorCode, string.Format("({0}) - {1}", strErrorCode, strErrorMessage));
            if (bIsReauth == false)
            {
                PromiseLoader.Instance._login_platform_result_callback(eLoginCallbackResult.FAIL);
            }
        }
    }
}