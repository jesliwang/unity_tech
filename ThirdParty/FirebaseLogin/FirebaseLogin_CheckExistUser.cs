using NLibCs;
using System;
using PlatformLogin;
using WasServer.Common;

namespace FirebaseLogin
{
    /// <summary>
    /// 디바이스UUID로 계정 생성 흔적이 있는지 확인
    /// </summary>
    public class FirebaseLogin_CheckExistUser : FirebaseLogin_Base
    {
        public override void Execute(IParameter arg = null)
        {
            PublicUIMethod.ShowLoadingSpin(true);

            var request = new SU_CHECK_EXIST_USER_WITH_DEVICEID_REQ();
            request.DeviceUUID = FirebaseLoginManager.Instance.GetDeviceId();

            NDebug.Log("FirebaseLogin_CheckExistUser: params = DeviceID: {0}", request.DeviceUUID);

            GameMain.Instance.StartCoroutine(new WebRequestOperation().RequestPOST(GameFramework.Instance.authURL + "/checkExistUser", request, OnSuccess, OnFail));
        }

        private void OnSuccess(string text, Action<object[]> callback, object[] param)
        {
            PublicUIMethod.ShowLoadingSpin(false);
            try
            {
                var JsonData = Newtonsoft.Json.JsonConvert.DeserializeObject<SU_CHECK_EXIST_USER_WITH_DEVICEID_ACK>(text);
                if (JsonData != null)
                {
                    if (JsonData.nResult == 0)
                    {
                        eExistUserType eType = (eExistUserType)JsonData.nAuthValue;
                        NDebug.Log("FirebaseLogin_CheckExistUser: Success -  DeviceID: {0}, ExistUserType: {1}", JsonData.strDeviceUUID, eType);
                        PromiseLoader.Instance._check_exist_user_callback(eType);
                    }
                    else
                    {
                        NDebug.Log("FirebaseLogin_CheckExistUser: Failed -  DeviceID: {0}, Error: {1}({2}) - {3}", JsonData.strDeviceUUID, JsonData.strErrorCode, JsonData.nResult, JsonData.strErrorMessage);
                        OnError(JsonData.strErrorMessage, JsonData.nResult, JsonData.strErrorCode);
                    }
                }
            }
            catch (Exception e)
            {
                NDebug.LogError("Json: Exception : {0}", "FirebaseLogin_CheckExistUser", e.Message);
                OnError(e.Message, -1, "ExceptionError");
            }
        }

        private void OnFail(string text, WebRequestError error)
        {
            NDebug.LogError("FirebaseLogin_CheckExistUser OnFail : {0}", error.ToString());
            OnError(error.ToString(), -1, "OnFailError");
        }

        private void OnError(string strErrorMessage, int nErrorCode, string strErrorCode)
        {
            PublicUIMethod.ShowLoadingSpin(false);
            PlatformLoginManager.Instance.ReconnetLogin = false;

            NDebug.LogError("FirebaseLogin_CheckExistUser OnError : {0}({1}) - {2}", strErrorCode, nErrorCode, strErrorMessage);
            PromiseLoader.Instance._check_exist_user_callback(eExistUserType.NONE);
        }
    }
}