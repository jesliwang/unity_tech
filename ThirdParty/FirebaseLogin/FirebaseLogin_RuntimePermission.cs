using Firebase.Auth;
using Firebase.Extensions;
using NLibCs;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading.Tasks;
using PlatformLogin;
using PaperPlaneTools;

namespace FirebaseLogin
{
    public class FirebaseLogin_RuntimePermission : FirebaseLogin_Base
    {
        PermissionParameter m_Parameter = null;

        public override void Execute(IParameter arg = null)
        {
            m_Parameter = arg as PermissionParameter;

            if (FirebaseLoginManager.Instance.IsPermissionGranted(m_Parameter.strPermissionName) == true)
            {
                OnSucced();
            }
            else
            {
                ShowMsgBox();
            }
        }

        public override IEnumerator ExecuteCO(IParameter arg = null)
        {
            m_bDone = false;

            m_Parameter = arg as PermissionParameter;

            if (FirebaseLoginManager.Instance.IsPermissionGranted(m_Parameter.strPermissionName) == true)
            {
                NDebug.Log("{0} permission is Gradted", m_Parameter.strPermissionName);
                m_bDone = true;
                OnSucced();
                yield break;
            }
            else
            {
                ShowMsgBox();
            }

            while (IsDone() == false)
                yield return null;
        }


        public void ShowMsgBox()
        {
            string title = string.Format("[{0}] {1}", m_Parameter.bIsOptional == true ? "선택" : "필수", NTextManager.Instance.GetText("permission_writestore_title"));
            string msg = string.Format("{0}\n{1}", NTextManager.Instance.GetText("permission_writestore_desc1"), NTextManager.Instance.GetText("permission_writestore_desc2"));// "[사진, 미디어, 파일 엑세스] 권한이 필요합니다. [사진, 미디어, 파일 엑세스] 권한에 SD카드 권한이 포함되어 있습니다. 게임이외에 다른 목적으로 사용되지 않으며 개인정보를 보호합니다.";

            Alert msgBox = new Alert(title, msg);

            if (NAuthPlugin.IsDontAskOptionPermissionDenied(m_Parameter.strPermissionName) == true)
            {
                msgBox.SetPositiveButton(NTextManager.Instance.GetText("permission_setting"), () =>
                {
                    NAuthPlugin.GotoAppPermissionSetting();
                });
            }
            else
            {
                msgBox.SetPositiveButton(NTextManager.Instance.GetText("UI_COMMON_CONFIRM_CHECK"), () => 
                {
                    NAuthPlugin.RequestPermission(m_Parameter.strPermissionName, OnResult);
                });
            }

            if( m_Parameter.bIsOptional == true )
            {
                msgBox.SetNegativeButton("닫기", () =>
                {
                });
            }
            /*else
            {
                msgBox.SetNegativeButton(NTextManager.Instance.GetText("UI_COMMON_CONFIRM_CLOSE"), () => 
                {
                    Application.Quit();
                });
            }*/

            msgBox.AddOptions(new AlertIOSOptions()
            {
                NegativeButton = AlertIOSButton.Type.Destructive,
                PreferableButton = Alert.ButtonType.Positive
            });

            msgBox.AddOptions(new AlertAndroidOptions()
            {
                Cancelable = false
            });

            msgBox.Show();
        }

        public void OnResult(string jsonString)
        {
            if (jsonString != null)
            {
                JsonNativeCallback info = JsonUtility.FromJson<JsonNativeCallback>(jsonString);
                if (info.method == "")
                {
                    NDebug.LogError("FirebaseLoginManager: NativePGSCallback: jsonString is Null");
                    PublicUIMethod.ShowPopUpErrorAlarmDlg(0, "jsonString is Null");
                    OnFailed();
                    return;
                }


                if (info.error == 0)
                {
                    NDebug.Log("{0} permission is Gradted", info.method);
                    m_bDone = true;
                    OnSucced();
                }
                else
                {
                    NDebug.LogError("{0} permission is not Gradted", info.method);

                    // 요청이 실패한 상태에서 ShouldShowRequestPermissionRationale이 False이면 다시 묻지 않기를 체크하고 거부한 상태로 판단한다.
                    if (NAuthPlugin.ShouldShowRequestPermissionRationale(info.method) == false)
                    {
                        NAuthPlugin.SetDontAskOptionalPermissionDenied(info.method, true);
                    }

                    if(m_Parameter.bIsOptional == false)
                    {
                        ShowMsgBox();
                    }
                    else
                    {
                        OnFailed();                        
                    }
                }
            }
        }

        void OnSucced()
        {
            if (m_Parameter.SuccessCallback != null)
            {
                m_Parameter.SuccessCallback();
                m_Parameter.SuccessCallback = null;
            }
        }

        void OnFailed()
        {
            if (m_Parameter.FailedCallback != null)
            {
                m_Parameter.FailedCallback();
                m_Parameter.FailedCallback = null;
            }
        }
    }
}


